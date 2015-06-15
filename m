Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 077B36B0038
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 16:29:03 -0400 (EDT)
Received: by wigg3 with SMTP id g3so89549118wig.1
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 13:29:02 -0700 (PDT)
Received: from mail-wg0-x22a.google.com (mail-wg0-x22a.google.com. [2a00:1450:400c:c00::22a])
        by mx.google.com with ESMTPS id l9si20135453wia.121.2015.06.15.13.29.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 13:29:01 -0700 (PDT)
Received: by wgez8 with SMTP id z8so77850151wge.0
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 13:29:01 -0700 (PDT)
Date: Mon, 15 Jun 2015 22:28:57 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: why do we need vmalloc_sync_all?
Message-ID: <20150615202856.GA13273@gmail.com>
References: <1434188955-31397-1-git-send-email-mingo@kernel.org>
 <20150613185828.GA32376@redhat.com>
 <20150614075943.GA810@gmail.com>
 <20150614200623.GB19582@redhat.com>
 <87bnghit74.fsf@tassilo.jf.intel.com>
 <CALCETrUp5Xm1ZmzoSEGrq1D05myAUhCzNgXvv-Cga8xjEi-CeQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrUp5Xm1ZmzoSEGrq1D05myAUhCzNgXvv-Cga8xjEi-CeQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andi Kleen <andi@firstfloor.org>, Oleg Nesterov <oleg@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Waiman Long <Waiman.Long@hp.com>


* Andy Lutomirski <luto@amacapital.net> wrote:

> On Sun, Jun 14, 2015 at 7:47 PM, Andi Kleen <andi@firstfloor.org> wrote:
> > Oleg Nesterov <oleg@redhat.com> writes:
> >>
> >> But again, the kernel no longer does this? do_page_fault() does 
> >> vmalloc_fault() without notify_die(). If it fails, I do not see how/why a 
> >> modular DIE_OOPS handler could try to resolve this problem and trigger 
> >> another fault.
> >
> > The same problem can happen from NMI handlers or machine check handlers. It's 
> > not necessarily tied to page faults only.
> 
> AIUI, the point of the one and only vmalloc_sync_all call is to prevent 
> infinitely recursive faults when we call a notify_die callback.  The only thing 
> that it could realistically protect is module text or static non-per-cpu module 
> data, since that's the only thing that's reliably already in the init pgd.  I'm 
> with Oleg: I don't see how that can happen, since do_page_fault fixes up vmalloc 
> faults before it calls notify_die.

Yes, but what I meant is that it can happen if due to an unrelated kernel bug and 
unlucky timing we have installed this new handler just when that other unrelated 
kernel bug triggers: say a #GPF crash in kernel code.

In any case it should all be mooted with the removal of lazy PGD instantiation.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
