Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A82D36B0003
	for <linux-mm@kvack.org>; Sat, 11 Aug 2018 09:14:51 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id n18-v6so3027920wmc.3
        for <linux-mm@kvack.org>; Sat, 11 Aug 2018 06:14:51 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id b13-v6si8214302wrm.186.2018.08.11.06.14.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sat, 11 Aug 2018 06:14:50 -0700 (PDT)
Date: Sat, 11 Aug 2018 15:14:38 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [4.18.0 rc8 BUG] possible irq lock inversion dependency
 detected
In-Reply-To: <20180811113039.GA10397@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.21.1808111511200.3202@nanos.tec.linutronix.de>
References: <CABXGCsOni6VZTVq6+kfgniX+SO5vc5SSRrn93xa=SMEpw-NNCQ@mail.gmail.com> <20180811113039.GA10397@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>, kvm@vger.kernel.org, linux-mm@kvack.org, Borislav Petkov <bp@suse.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Sat, 11 Aug 2018, Matthew Wilcox wrote:

> On Sat, Aug 11, 2018 at 12:28:24PM +0500, Mikhail Gavrilov wrote:
> > Hi guys.
> > I am catched new bug. It occured when I start virtual machine.
> > Can anyone look?
> 
> I'd suggest that st->lock should be taken with irqsave.  Like this;
> please test.

That should fix it, but that's suboptimal because that's an extra
safe/restore in switch_to(). So we better disable interrupts at the other
call site. Patch below.

Thanks,

	tglx

8<------------------

diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
index 30ca2d1a9231..07ce27082a40 100644
--- a/arch/x86/kernel/process.c
+++ b/arch/x86/kernel/process.c
@@ -416,9 +416,11 @@ static __always_inline void __speculative_store_bypass_update(unsigned long tifn
 
 void speculative_store_bypass_update(unsigned long tif)
 {
-	preempt_disable();
+	unsigned long flags;
+
+	local_irq_save(flags);
 	__speculative_store_bypass_update(tif);
-	preempt_enable();
+	local_irq_restore(flags);
 }
 
 void __switch_to_xtra(struct task_struct *prev_p, struct task_struct *next_p,
