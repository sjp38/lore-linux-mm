Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 7B1E86B0038
	for <linux-mm@kvack.org>; Sun, 14 Jun 2015 03:59:50 -0400 (EDT)
Received: by wiga1 with SMTP id a1so49158642wig.0
        for <linux-mm@kvack.org>; Sun, 14 Jun 2015 00:59:49 -0700 (PDT)
Received: from mail-wi0-x22c.google.com (mail-wi0-x22c.google.com. [2a00:1450:400c:c05::22c])
        by mx.google.com with ESMTPS id vf7si16005997wjc.127.2015.06.14.00.59.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Jun 2015 00:59:49 -0700 (PDT)
Received: by wibdq8 with SMTP id dq8so49317543wib.1
        for <linux-mm@kvack.org>; Sun, 14 Jun 2015 00:59:48 -0700 (PDT)
Date: Sun, 14 Jun 2015 09:59:43 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: why do we need vmalloc_sync_all?
Message-ID: <20150614075943.GA810@gmail.com>
References: <1434188955-31397-1-git-send-email-mingo@kernel.org>
 <20150613185828.GA32376@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150613185828.GA32376@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Waiman Long <Waiman.Long@hp.com>


* Oleg Nesterov <oleg@redhat.com> wrote:

> I didn't read v2 yet, but I'd like to ask a question.
> 
> Why do we need vmalloc_sync_all()?
> 
> It has a single caller, register_die_notifier() which calls it without
> any explanation. IMO, this needs a comment at least.

Yes, it's used to work around crashes in modular callbacks: if the callbacks 
happens to be called from within the page fault path, before the vmalloc page 
fault handler runs, then we have a catch-22 problem.

It's rare but not entirely impossible.

> I am not sure I understand the changelog in 101f12af correctly, but at first 
> glance vmalloc_sync_all() is no longer needed at least on x86, do_page_fault() 
> no longer does notify_die(DIE_PAGE_FAULT). And btw DIE_PAGE_FAULT has no users. 
> DIE_MNI too...
> 
> Perhaps we can simply kill it on x86?

So in theory we could still have it run from DIE_OOPS, and that could turn a 
survivable kernel crash into a non-survivable one.

Note that all of this will go away if we also do the vmalloc fault handling 
simplification that I discussed with Andy:

 - this series already makes the set of kernel PGDs strictly monotonically 
   increasing during the lifetime of the x86 kernel

 - if in a subsequent patch we can synchronize new PGDs right after the vmalloc
   code creates it, before the area is used - so we can remove vmalloc_fault()
   altogether [or rather, turn it into a debug warning initially].
   vmalloc_fault() is a clever but somewhat fragile complication.

 - after that we can simply remove vmalloc_sync_all() from x86, because all active 
   vmalloc areas will be fully instantiated, all the time, on x86.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
