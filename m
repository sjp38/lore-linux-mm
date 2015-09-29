Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 22CDA6B0038
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 04:42:43 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so4742516wic.1
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 01:42:42 -0700 (PDT)
Received: from mail-wi0-x236.google.com (mail-wi0-x236.google.com. [2a00:1450:400c:c05::236])
        by mx.google.com with ESMTPS id lf10si28146481wjc.47.2015.09.29.01.42.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Sep 2015 01:42:41 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so139199819wic.1
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 01:42:41 -0700 (PDT)
Date: Tue, 29 Sep 2015 10:42:38 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 02/11] x86/mm/hotplug: Remove pgd_list use from the
 memory hotplug code
Message-ID: <20150929084238.GA332@gmail.com>
References: <1442903021-3893-1-git-send-email-mingo@kernel.org>
 <1442903021-3893-3-git-send-email-mingo@kernel.org>
 <CA+55aFzN7MMoxzaq-mcNcNoVzUMr0aPHDTipU-OVdaz7_YZ12Q@mail.gmail.com>
 <20150923114453.GA8480@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150923114453.GA8480@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Waiman Long <waiman.long@hp.com>, Thomas Gleixner <tglx@linutronix.de>


* Oleg Nesterov <oleg@redhat.com> wrote:

> On 09/22, Linus Torvalds wrote:
> >
> > However, this now becomes a pattern for the series, and that just makes me think
> >
> >     "Why is this not a 'for_each_mm()' pattern helper?"
> 
> And we already have other users. And note that oom_kill_process() does _not_
> follow this pattern and that is why it is buggy.
> 
> So this is funny, but I was thinking about almost the same, something like
> 
> 	struct task_struct *next_task_with_mm(struct task_struct *p)
> 	{
> 		struct task_struct *t;
> 
> 		p = p->group_leader;
> 		while ((p = next_task(p)) != &init_task) {
> 			if (p->flags & PF_KTHREAD)
> 				continue;
> 
> 			t = find_lock_task_mm(p);
> 			if (t)
> 				return t;
> 		}
> 
> 		return NULL;
> 	}
> 
> 	#define for_each_task_lock_mm(p)
> 		for (p = &init_task; (p = next_task_with_mm(p)); task_unlock(p))
> 
> 
> So that you can do
> 
> 	for_each_task_lock_mm(p) {
> 		do_something_with(p->mm);
> 
> 		if (some_condition()) {
> 			// UNFORTUNATELY you can't just do "break"
> 			task_unlock(p);
> 			break;
> 		}
> 	}
> 
> do you think it makes sense?

Sure, I'm inclined to use the above code from you.

> In fact it can't be simpler, we can move task_unlock() into next_task_with_mm(), 
> it can check ->mm != NULL or p != init_task.

s/can't/can ?

But even with that I'm not sure I can parse your suggestion. Got some (pseudo) code
perhaps?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
