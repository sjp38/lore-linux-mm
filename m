Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7347E6B0038
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 19:18:15 -0500 (EST)
Received: by wmww144 with SMTP id w144so152095921wmw.1
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 16:18:15 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o204si32413285wma.118.2015.11.30.16.18.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Nov 2015 16:18:14 -0800 (PST)
Date: Mon, 30 Nov 2015 16:18:11 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 1/4] mm: mmap: Add new /proc tunable for mmap_base
 ASLR.
Message-Id: <20151130161811.592c205d8dc7b00f44066a37@linux-foundation.org>
In-Reply-To: <CAGXu5jK7UzjBxXKQajxhLv-uLk_xQXR_FHOsmW6RLJNeK_-dZg@mail.gmail.com>
References: <1448578785-17656-1-git-send-email-dcashman@android.com>
	<1448578785-17656-2-git-send-email-dcashman@android.com>
	<20151130155412.b1a087f4f6f4d4180ab4472d@linux-foundation.org>
	<20151130160118.e43a2e53a59e347a95a94d5c@linux-foundation.org>
	<CAGXu5jK7UzjBxXKQajxhLv-uLk_xQXR_FHOsmW6RLJNeK_-dZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Daniel Cashman <dcashman@android.com>, LKML <linux-kernel@vger.kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Ingo Molnar <mingo@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Jonathan Corbet <corbet@lwn.net>, Don Zickus <dzickus@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Heinrich Schuchardt <xypron.glpk@gmx.de>, jpoimboe@redhat.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, n-horiguchi@ah.jp.nec.com, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Thomas Gleixner <tglx@linutronix.de>, David Rientjes <rientjes@google.com>, Linux-MM <linux-mm@kvack.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Mark Salyzyn <salyzyn@android.com>, Jeffrey Vander Stoep <jeffv@google.com>, Nick Kralevich <nnk@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, Hector Marco <hecmargi@upv.es>, Borislav Petkov <bp@suse.de>, Daniel Cashman <dcashman@google.com>

On Mon, 30 Nov 2015 16:04:36 -0800 Kees Cook <keescook@chromium.org> wrote:

> >> > +#ifdef CONFIG_HAVE_ARCH_MMAP_RND_BITS
> >> > +   {
> >> > +           .procname       = "mmap_rnd_bits",
> >> > +           .data           = &mmap_rnd_bits,
> >> > +           .maxlen         = sizeof(mmap_rnd_bits),
> >> > +           .mode           = 0600,
> >> > +           .proc_handler   = proc_dointvec_minmax,
> >> > +           .extra1         = (void *) &mmap_rnd_bits_min,
> >> > +           .extra2         = (void *) &mmap_rnd_bits_max,
> >>
> >> hm, why the typecasts?  They're unneeded and are omitted everywhere(?)
> >> else in kernel/sysctl.c.
> >
> > Oh.  Casting away constness.
> >
> > What's the thinking here?  They can change at any time so they aren't
> > const so we shouldn't declare them to be const?
> 
> The _min and _max values shouldn't be changing: they're decided based
> on the various CONFIG options that calculate the valid min/maxes. Only
> mmap_rnd_bits itself should be changing.

hmpf.

From: Andrew Morton <akpm@linux-foundation.org>
Subject: include/linux/sysctl.h: make ctl_table.extra1/2 const

Nothing should be altering these values.  Declare the pointed-to values to
be const so we can actually use const values.

Cc: Kees Cook <keescook@chromium.org>
Cc: Daniel Cashman <dcashman@android.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/sysctl.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN include/linux/sysctl.h~a include/linux/sysctl.h
--- a/include/linux/sysctl.h~a
+++ a/include/linux/sysctl.h
@@ -111,8 +111,8 @@ struct ctl_table
 	struct ctl_table *child;	/* Deprecated */
 	proc_handler *proc_handler;	/* Callback for text formatting */
 	struct ctl_table_poll *poll;
-	void *extra1;
-	void *extra2;
+	const void *extra1;
+	const void *extra2;
 };
 
 struct ctl_node {
diff -puN kernel/sysctl.c~a kernel/sysctl.c
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
