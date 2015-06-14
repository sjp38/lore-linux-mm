Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f178.google.com (mail-qc0-f178.google.com [209.85.216.178])
	by kanga.kvack.org (Postfix) with ESMTP id BC0F36B0038
	for <linux-mm@kvack.org>; Sun, 14 Jun 2015 16:07:31 -0400 (EDT)
Received: by qcej3 with SMTP id j3so2355903qce.3
        for <linux-mm@kvack.org>; Sun, 14 Jun 2015 13:07:31 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id iq7si10702004qcb.1.2015.06.14.13.07.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Jun 2015 13:07:31 -0700 (PDT)
Date: Sun, 14 Jun 2015 22:06:23 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: why do we need vmalloc_sync_all?
Message-ID: <20150614200623.GB19582@redhat.com>
References: <1434188955-31397-1-git-send-email-mingo@kernel.org> <20150613185828.GA32376@redhat.com> <20150614075943.GA810@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150614075943.GA810@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Waiman Long <Waiman.Long@hp.com>

On 06/14, Ingo Molnar wrote:
>
> * Oleg Nesterov <oleg@redhat.com> wrote:
>
> > I didn't read v2 yet, but I'd like to ask a question.
> >
> > Why do we need vmalloc_sync_all()?
> >
> > It has a single caller, register_die_notifier() which calls it without
> > any explanation. IMO, this needs a comment at least.
>
> Yes, it's used to work around crashes in modular callbacks: if the callbacks
> happens to be called from within the page fault path, before the vmalloc page
> fault handler runs, then we have a catch-22 problem.
>
> It's rare but not entirely impossible.

But again, the kernel no longer does this? do_page_fault() does vmalloc_fault()
without notify_die(). If it fails, I do not see how/why a modular DIE_OOPS
handler could try to resolve this problem and trigger another fault.

> > I am not sure I understand the changelog in 101f12af correctly, but at first
> > glance vmalloc_sync_all() is no longer needed at least on x86, do_page_fault()
> > no longer does notify_die(DIE_PAGE_FAULT). And btw DIE_PAGE_FAULT has no users.
> > DIE_MNI too...
> >
> > Perhaps we can simply kill it on x86?
>
> So in theory we could still have it run from DIE_OOPS, and that could turn a
> survivable kernel crash into a non-survivable one.

I don't understand... But OK, my understanding of this magic is very limited,
please forget.

Thanks,

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
