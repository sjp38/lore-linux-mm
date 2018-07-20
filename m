Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 619ED6B0006
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 15:53:49 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id v2-v6so5908544wrr.10
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 12:53:49 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id r14-v6si2193710wrg.106.2018.07.20.12.53.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 20 Jul 2018 12:53:48 -0700 (PDT)
Date: Fri, 20 Jul 2018 21:53:41 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 1/3] perf/core: Make sure the ring-buffer is mapped in
 all page-tables
In-Reply-To: <alpine.DEB.2.21.1807202142130.1694@nanos.tec.linutronix.de>
Message-ID: <alpine.DEB.2.21.1807202152400.1694@nanos.tec.linutronix.de>
References: <1532103744-31902-1-git-send-email-joro@8bytes.org> <1532103744-31902-2-git-send-email-joro@8bytes.org> <CALCETrXJX8tPVgD=Ce41534uneAAobm-HyjeGwVYgJDJ_+-bDw@mail.gmail.com> <alpine.DEB.2.21.1807202126400.1694@nanos.tec.linutronix.de>
 <CALCETrW7o=s7esmE4+SxLPsLv2SvJZU6f7jfsedazZVrot2EqA@mail.gmail.com> <alpine.DEB.2.21.1807202142130.1694@nanos.tec.linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Joerg Roedel <joro@8bytes.org>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, Joerg Roedel <jroedel@suse.de>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>

On Fri, 20 Jul 2018, Thomas Gleixner wrote:
> On Fri, 20 Jul 2018, Andy Lutomirski wrote:
> > On Fri, Jul 20, 2018 at 12:27 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> > > On Fri, 20 Jul 2018, Andy Lutomirski wrote:
> > >> > On Jul 20, 2018, at 6:22 AM, Joerg Roedel <joro@8bytes.org> wrote:
> > >> >
> > >> > From: Joerg Roedel <jroedel@suse.de>
> > >> >
> > >> > The ring-buffer is accessed in the NMI handler, so we better
> > >> > avoid faulting on it. Sync the vmalloc range with all
> > >> > page-tables in system to make sure everyone has it mapped.
> > >> >
> > >> > This fixes a WARN_ON_ONCE() that can be triggered with PTI
> > >> > enabled on x86-32:
> > >> >
> > >> >    WARNING: CPU: 4 PID: 0 at arch/x86/mm/fault.c:320 vmalloc_fault+0x220/0x230
> > >> >
> > >> > This triggers because with PTI enabled on an PAE kernel the
> > >> > PMDs are no longer shared between the page-tables, so the
> > >> > vmalloc changes do not propagate automatically.
> > >>
> > >> It seems like it would be much more robust to fix the vmalloc_fault()
> > >> code instead.
> > >
> > > Right, but now the obvious fix for the issue at hand is this. We surely
> > > should revisit this.
> > 
> > If you commit this under this reasoning, then please at least make it say:
> > 
> > /* XXX: The vmalloc_fault() code is buggy on PTI+PAE systems, and this
> > is a workaround. */
> > 
> > Let's not have code in the kernel that pretends to make sense but is
> > actually voodoo magic that works around bugs elsewhere.  It's no fun
> > to maintain down the road.
> 
> Fair enough. Lemme amend it. Joerg is looking into it, but I surely want to
> get that stuff some exposure in next ASAP.

Delta patch below.

Thanks.

	tglx

8<-------------
--- a/kernel/events/ring_buffer.c
+++ b/kernel/events/ring_buffer.c
@@ -815,8 +815,12 @@ static void rb_free_work(struct work_str
 	vfree(base);
 	kfree(rb);
 
-	/* Make sure buffer is unmapped in all page-tables */
-	vmalloc_sync_all();
+	/*
+	 * FIXME: PAE workaround for vmalloc_fault(): Make sure buffer is
+	 * unmapped in all page-tables.
+	 */
+	if (IS_ENABLED(CONFIG_X86_PAE))
+		vmalloc_sync_all();
 }
 
 void rb_free(struct ring_buffer *rb)
@@ -844,11 +848,13 @@ struct ring_buffer *rb_alloc(int nr_page
 		goto fail_all_buf;
 
 	/*
-	 * The buffer is accessed in NMI handlers, make sure it is
-	 * mapped in all page-tables in the system so that we don't
-	 * fault on the range in an NMI handler.
+	 * FIXME: PAE workaround for vmalloc_fault(): The buffer is
+	 * accessed in NMI handlers, make sure it is mapped in all
+	 * page-tables in the system so that we don't fault on the range in
+	 * an NMI handler.
 	 */
-	vmalloc_sync_all();
+	if (IS_ENABLED(CONFIG_X86_PAE))
+		vmalloc_sync_all();
 
 	rb->user_page = all_buf;
 	rb->data_pages[0] = all_buf + PAGE_SIZE;
