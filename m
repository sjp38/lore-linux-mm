Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 483176B0254
	for <linux-mm@kvack.org>; Wed, 23 Sep 2015 07:47:58 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so98022879igb.0
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 04:47:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i6si5313776igi.84.2015.09.23.04.47.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Sep 2015 04:47:57 -0700 (PDT)
Date: Wed, 23 Sep 2015 13:44:53 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 02/11] x86/mm/hotplug: Remove pgd_list use from the
	memory hotplug code
Message-ID: <20150923114453.GA8480@redhat.com>
References: <1442903021-3893-1-git-send-email-mingo@kernel.org> <1442903021-3893-3-git-send-email-mingo@kernel.org> <CA+55aFzN7MMoxzaq-mcNcNoVzUMr0aPHDTipU-OVdaz7_YZ12Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzN7MMoxzaq-mcNcNoVzUMr0aPHDTipU-OVdaz7_YZ12Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Waiman Long <waiman.long@hp.com>, Thomas Gleixner <tglx@linutronix.de>

On 09/22, Linus Torvalds wrote:
>
> However, this now becomes a pattern for the series, and that just makes me think
>
>     "Why is this not a 'for_each_mm()' pattern helper?"

And we already have other users. And note that oom_kill_process() does _not_
follow this pattern and that is why it is buggy.

So this is funny, but I was thinking about almost the same, something like

	struct task_struct *next_task_with_mm(struct task_struct *p)
	{
		struct task_struct *t;

		p = p->group_leader;
		while ((p = next_task(p)) != &init_task) {
			if (p->flags & PF_KTHREAD)
				continue;

			t = find_lock_task_mm(p);
			if (t)
				return t;
		}

		return NULL;
	}

	#define for_each_task_lock_mm(p)
		for (p = &init_task; (p = next_task_with_mm(p)); task_unlock(p))


So that you can do

	for_each_task_lock_mm(p) {
		do_something_with(p->mm);

		if (some_condition()) {
			// UNFORTUNATELY you can't just do "break"
			task_unlock(p);
			break;
		}
	}

do you think it makes sense?


In fact it can't be simpler, we can move task_unlock() into next_task_with_mm(),
it can check ->mm != NULL or p != init_task.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
