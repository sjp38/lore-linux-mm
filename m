Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C47DC4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 15:47:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3DEF1206BA
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 15:47:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tycho-ws.20150623.gappssmtp.com header.i=@tycho-ws.20150623.gappssmtp.com header.b="Dz6ShJ2D"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3DEF1206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tycho.ws
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF0626B000C; Thu,  4 Apr 2019 11:47:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D9FAC6B000D; Thu,  4 Apr 2019 11:47:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C19276B000E; Thu,  4 Apr 2019 11:47:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9E8ED6B000C
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 11:47:34 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id u125so2115641ybb.15
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 08:47:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=3mPqVBVpYV5kWx+J5YkGaNb4LYld17CFyVtdp6NS4/A=;
        b=r2FnPXCmznCvWraTLRDNEfB9lWma+/MUTu8KV/qa940C+VUKXr7uItNrjPWeqUdNoz
         /BLpSwIclAyjswMHEEjQwN2ux/65KSKskgZzsTyhxmGYBL7988e2Q7R8LI91uLycpIQB
         KleJbfa44AohwWAt8qupgVoBLSQympedZYkkBM9pFeXTm6y8mwyAgtq/az3c9NLNXMLH
         JVtF+e9JswIl6iAiHNH1bUj9gI5uZCui9gkIPO0lX4YnVQVUiL9nbw3tK52EKaCUYyBE
         qEhgYZ8HLtNFffMWsXZmG5K6J8egAjBjG3Yfinw66+FiYr96B63fpN8XUpP4I6JhvLjQ
         uIhQ==
X-Gm-Message-State: APjAAAXaLQ2I6xyCEzvU6XMUd8p2wPjksUPHIolhOGe6aEjXRFVnyc0l
	tXWeaYKONSjvQChFLs5IDO0xap+3Wd7WhP8hHczOtBtOGZR9a01H9+RdzcEz1nzMd5AYtskNmbR
	5S/uNei3yvRYxJk3q5orJMONbUVB6bX/w7cfhe3y08jV6r6buSXmEG+LNIHjPureykg==
X-Received: by 2002:a25:14d5:: with SMTP id 204mr6234088ybu.106.1554392854391;
        Thu, 04 Apr 2019 08:47:34 -0700 (PDT)
X-Received: by 2002:a25:14d5:: with SMTP id 204mr6234024ybu.106.1554392853650;
        Thu, 04 Apr 2019 08:47:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554392853; cv=none;
        d=google.com; s=arc-20160816;
        b=w2WFlH4Ha26KGb2nzET2PNS0LcKWstDIZhH0yFnGtihG0rMAC6JXc0hEfOLokNi2pC
         fSFQFDKnO4oxTqNLyr3hV+Ji4w4bytxh5qc94EFDEN0KlovLGUvfCA9l6mmwFj0KrLiQ
         Sp02wNWFehAR4Rx//HbgkubB2hcUZF8oj/vi4d1oP+One619q+tklDtRGfldifyNjjwG
         tU13gxlfJFXgXrxahBv8XiR82YSiXwnIxTv1YGz40KAyhiBXV++gd3Ua1IU80ACxe4Y5
         jS8vLEmye/Bp+HsdWQTaDRAB0ccf2O9Bh+NZ9jUnBt5GY5e+I64ZNaTSEFPOlZabGyyn
         KPXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=3mPqVBVpYV5kWx+J5YkGaNb4LYld17CFyVtdp6NS4/A=;
        b=mELuWwbuNjlvryv7gK28VLn7X2VOwBLFvFzqDarhav7wf9AxTwAvAy6vMAS4+vCPZ1
         SPwwPCeHeu9Sk/SQFOMT+uf9RvIierwjcAIr6NPqf0XSPk4G2xYdx6JiLuCY6SzAEd1m
         z+rp/kDyIcIqkv2I/tdLxxWwAAJMfsATVJkdNQIgy9C8M9v+be0fjsr56YBNdR7OLXIY
         N+mmMDOzpli3AxeJol3IuCGnR/JZVWclwMcYqbEtT3QYwiqlbmNdgr5yDSHn+qMnYn03
         pEsWnJuwxdNh2EkF4JtbjAuFXR9G35YK6YwdS0bnOLTc6KfZPFIHkcDxb4zk+C+nug4y
         kVzA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tycho-ws.20150623.gappssmtp.com header.s=20150623 header.b=Dz6ShJ2D;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of tycho@tycho.ws) smtp.mailfrom=tycho@tycho.ws
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s127sor10376491yba.56.2019.04.04.08.47.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Apr 2019 08:47:33 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of tycho@tycho.ws) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tycho-ws.20150623.gappssmtp.com header.s=20150623 header.b=Dz6ShJ2D;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of tycho@tycho.ws) smtp.mailfrom=tycho@tycho.ws
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=tycho-ws.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=3mPqVBVpYV5kWx+J5YkGaNb4LYld17CFyVtdp6NS4/A=;
        b=Dz6ShJ2DbLzee9g0gJX4gJj22VivC/zPtgOmp666dpmAD07PfVgTH88ycTVQEmvIuh
         Tb1mhJgiI4Cj4HpPubsrRrO5eNlG9XfBLazihMKeaf/QfBzbWa80fTtXolwl2krNaA0F
         O2Tgnh8u99aogUzbJBZLIvEgUIC2GisW7xIr9xN3/ZsJYnebUHiUK0GKWfapZCZy9uiZ
         NPksbHjp6YpEcijiUN9CNArEgSx76qcM9ANe9riCQt7mi0enNE81BZgXcLABrT684wju
         +chTSGm4Xat/4J8yu94r9KaVqAD74CUAQ4aV/YbDJ5ugz83XrBKMBkSrt3JUF1YM8D45
         Mw5A==
X-Google-Smtp-Source: APXvYqx7/9aI0EjzCPw47Ay13QcVOTbWYgnGXlIKW3NovKg+zu3yZ3ba0sR42OeFTkO7kCwrgT4oKw==
X-Received: by 2002:a5b:c07:: with SMTP id f7mr6005138ybq.81.1554392853104;
        Thu, 04 Apr 2019 08:47:33 -0700 (PDT)
Received: from cisco ([2601:282:901:dd7b:38ae:7ccc:265c:2d2c])
        by smtp.gmail.com with ESMTPSA id h204sm9052855ywh.52.2019.04.04.08.47.28
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 04 Apr 2019 08:47:32 -0700 (PDT)
Date: Thu, 4 Apr 2019 09:47:27 -0600
From: Tycho Andersen <tycho@tycho.ws>
To: Andy Lutomirski <luto@kernel.org>
Cc: Khalid Aziz <khalid.aziz@oracle.com>,
	Juerg Haefliger <juergh@gmail.com>, jsteckli@amazon.de,
	Andi Kleen <ak@linux.intel.com>, liran.alon@oracle.com,
	Kees Cook <keescook@google.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	deepa.srinivasan@oracle.com, chris hyser <chris.hyser@oracle.com>,
	Tyler Hicks <tyhicks@canonical.com>,
	"Woodhouse, David" <dwmw@amazon.co.uk>,
	Andrew Cooper <andrew.cooper3@citrix.com>,
	Jon Masters <jcm@redhat.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	kanth.ghatraju@oracle.com, Joao Martins <joao.m.martins@oracle.com>,
	Jim Mattson <jmattson@google.com>, pradeep.vincent@oracle.com,
	John Haxby <john.haxby@oracle.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Christoph Hellwig <hch@lst.de>, steven.sistare@oracle.com,
	Laura Abbott <labbott@redhat.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Aaron Lu <aaron.lu@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	alexander.h.duyck@linux.intel.com,
	Amir Goldstein <amir73il@gmail.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	aneesh.kumar@linux.ibm.com, anthony.yznaga@oracle.com,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>, arunks@codeaurora.org,
	Ben Hutchings <ben@decadent.org.uk>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Borislav Petkov <bp@alien8.de>, brgl@bgdev.pl,
	Catalin Marinas <catalin.marinas@arm.com>,
	Jonathan Corbet <corbet@lwn.net>, cpandya@codeaurora.org,
	Daniel Vetter <daniel.vetter@ffwll.ch>,
	Dan Williams <dan.j.williams@intel.com>,
	Greg KH <gregkh@linuxfoundation.org>, Roman Gushchin <guro@fb.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	James Morse <james.morse@arm.com>, Jann Horn <jannh@google.com>,
	Juergen Gross <jgross@suse.com>, Jiri Kosina <jkosina@suse.cz>,
	James Morris <jmorris@namei.org>, Joe Perches <joe@perches.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Joerg Roedel <jroedel@suse.de>, Keith Busch <keith.busch@intel.com>,
	Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	Logan Gunthorpe <logang@deltatee.com>, marco.antonio.780@gmail.com,
	Mark Rutland <mark.rutland@arm.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Michal Hocko <mhocko@suse.com>, Michal Hocko <mhocko@suse.cz>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Ingo Molnar <mingo@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Nicholas Piggin <npiggin@gmail.com>, osalvador@suse.de,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	pavel.tatashin@microsoft.com, Randy Dunlap <rdunlap@infradead.org>,
	richard.weiyang@gmail.com, "Serge E. Hallyn" <serge@hallyn.com>,
	iommu@lists.linux-foundation.org, X86 ML <x86@kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
	LSM List <linux-security-module@vger.kernel.org>,
	Khalid Aziz <khalid@gonehiking.org>
Subject: Re: [RFC PATCH v9 02/13] x86: always set IF before oopsing from page
 fault
Message-ID: <20190404154727.GA14030@cisco>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
 <e6c57f675e5b53d4de266412aa526b7660c47918.1554248002.git.khalid.aziz@oracle.com>
 <CALCETrXvwuwkVSJ+S5s7wTBkNNj3fRVxpx9BvsXWrT=3ZdRnCw@mail.gmail.com>
 <20190404013956.GA3365@cisco>
 <CALCETrVp37Xo3EMHkeedP1zxUMf9og=mceBa8c55e1F4G1DRSQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrVp37Xo3EMHkeedP1zxUMf9og=mceBa8c55e1F4G1DRSQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 03, 2019 at 09:12:16PM -0700, Andy Lutomirski wrote:
> On Wed, Apr 3, 2019 at 6:42 PM Tycho Andersen <tycho@tycho.ws> wrote:
> >
> > On Wed, Apr 03, 2019 at 05:12:56PM -0700, Andy Lutomirski wrote:
> > > On Wed, Apr 3, 2019 at 10:36 AM Khalid Aziz <khalid.aziz@oracle.com> wrote:
> > > >
> > > > From: Tycho Andersen <tycho@tycho.ws>
> > > >
> > > > Oopsing might kill the task, via rewind_stack_do_exit() at the bottom, and
> > > > that might sleep:
> > > >
> > >
> > >
> > > > diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> > > > index 9d5c75f02295..7891add0913f 100644
> > > > --- a/arch/x86/mm/fault.c
> > > > +++ b/arch/x86/mm/fault.c
> > > > @@ -858,6 +858,12 @@ no_context(struct pt_regs *regs, unsigned long error_code,
> > > >         /* Executive summary in case the body of the oops scrolled away */
> > > >         printk(KERN_DEFAULT "CR2: %016lx\n", address);
> > > >
> > > > +       /*
> > > > +        * We're about to oops, which might kill the task. Make sure we're
> > > > +        * allowed to sleep.
> > > > +        */
> > > > +       flags |= X86_EFLAGS_IF;
> > > > +
> > > >         oops_end(flags, regs, sig);
> > > >  }
> > > >
> > >
> > >
> > > NAK.  If there's a bug in rewind_stack_do_exit(), please fix it in
> > > rewind_stack_do_exit().
> >
> > [I trimmed the CC list since google rejected it with E2BIG :)]
> >
> > I guess the problem is really that do_exit() (or really
> > exit_signals()) might sleep. Maybe we should put an irq_enable() at
> > the beginning of do_exit() instead and fix this problem for all
> > arches?
> >
> 
> Hmm.  do_exit() isn't really meant to be "try your best to leave the
> system somewhat usable without returning" -- it's a function that,
> other than in OOPSes, is called from a well-defined state.  So I think
> rewind_stack_do_exit() is probably a better spot.  But we need to
> rewind the stack and *then* turn on IRQs, since we otherwise risk
> exploding quite badly.

Ok, sounds good. I guess we can include something like this patch in
the next series.

Thanks,

Tycho


From 34dce229a4f43f90db823671eb0b8da7c4906045 Mon Sep 17 00:00:00 2001
From: Tycho Andersen <tycho@tycho.ws>
Date: Thu, 4 Apr 2019 09:41:32 -0600
Subject: [PATCH] x86/entry: re-enable interrupts before exiting

If the kernel oopses in an interrupt, nothing re-enables interrupts:

Aug 23 19:30:27 xpfo kernel: [   38.302714] BUG: sleeping function called from invalid context at
./include/linux/percpu-rwsem.h:33
Aug 23 19:30:27 xpfo kernel: [   38.303837] in_atomic(): 0, irqs_disabled(): 1, pid: 1970, name:
lkdtm_xpfo_test
Aug 23 19:30:27 xpfo kernel: [   38.304758] CPU: 3 PID: 1970 Comm: lkdtm_xpfo_test Tainted: G      D
4.13.0-rc5+ #228
Aug 23 19:30:27 xpfo kernel: [   38.305813] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
1.10.1-1ubuntu1 04/01/2014
Aug 23 19:30:27 xpfo kernel: [   38.306926] Call Trace:
Aug 23 19:30:27 xpfo kernel: [   38.307243]  dump_stack+0x63/0x8b
Aug 23 19:30:27 xpfo kernel: [   38.307665]  ___might_sleep+0xec/0x110
Aug 23 19:30:27 xpfo kernel: [   38.308139]  __might_sleep+0x45/0x80
Aug 23 19:30:27 xpfo kernel: [   38.308593]  exit_signals+0x21/0x1c0
Aug 23 19:30:27 xpfo kernel: [   38.309046]  ? blocking_notifier_call_chain+0x11/0x20
Aug 23 19:30:27 xpfo kernel: [   38.309677]  do_exit+0x98/0xbf0
Aug 23 19:30:27 xpfo kernel: [   38.310078]  ? smp_reader+0x27/0x40 [lkdtm]
Aug 23 19:30:27 xpfo kernel: [   38.310604]  ? kthread+0x10f/0x150
Aug 23 19:30:27 xpfo kernel: [   38.311045]  ? read_user_with_flags+0x60/0x60 [lkdtm]
Aug 23 19:30:27 xpfo kernel: [   38.311680]  rewind_stack_do_exit+0x17/0x20

do_exit() expects to be called in a well-defined environment, so let's
re-enable interrupts after unwinding the stack, in case they were disabled.

Signed-off-by: Tycho Andersen <tycho@tycho.ws>
---
 arch/x86/entry/entry_32.S | 6 ++++++
 arch/x86/entry/entry_64.S | 6 ++++++
 2 files changed, 12 insertions(+)

diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
index d309f30cf7af..8ddb7b41669d 100644
--- a/arch/x86/entry/entry_32.S
+++ b/arch/x86/entry/entry_32.S
@@ -1507,6 +1507,12 @@ ENTRY(rewind_stack_do_exit)
 	movl	PER_CPU_VAR(cpu_current_top_of_stack), %esi
 	leal	-TOP_OF_KERNEL_STACK_PADDING-PTREGS_SIZE(%esi), %esp
 
+	/*
+	 * If we oopsed in an interrupt handler, interrupts may be off. Let's turn
+	 * them back on before going back to "normal" code.
+	 */
+	sti
+
 	call	do_exit
 1:	jmp 1b
 END(rewind_stack_do_exit)
diff --git a/arch/x86/entry/entry_64.S b/arch/x86/entry/entry_64.S
index 1f0efdb7b629..c0759f3e3ad2 100644
--- a/arch/x86/entry/entry_64.S
+++ b/arch/x86/entry/entry_64.S
@@ -1672,5 +1672,11 @@ ENTRY(rewind_stack_do_exit)
 	leaq	-PTREGS_SIZE(%rax), %rsp
 	UNWIND_HINT_FUNC sp_offset=PTREGS_SIZE
 
+	/*
+	 * If we oopsed in an interrupt handler, interrupts may be off. Let's turn
+	 * them back on before going back to "normal" code.
+	 */
+	sti
+
 	call	do_exit
 END(rewind_stack_do_exit)
-- 
2.19.1

