Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f177.google.com (mail-qk0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id 35D206B0255
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 12:54:39 -0400 (EDT)
Received: by qkcf65 with SMTP id f65so5791971qkc.3
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 09:54:39 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 82si20767386qhq.103.2015.09.29.09.54.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Sep 2015 09:54:38 -0700 (PDT)
Date: Tue, 29 Sep 2015 18:51:27 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 02/11] x86/mm/hotplug: Remove pgd_list use from the
	memory hotplug code
Message-ID: <20150929165127.GA17319@redhat.com>
References: <1442903021-3893-1-git-send-email-mingo@kernel.org> <1442903021-3893-3-git-send-email-mingo@kernel.org> <CA+55aFzN7MMoxzaq-mcNcNoVzUMr0aPHDTipU-OVdaz7_YZ12Q@mail.gmail.com> <20150923114453.GA8480@redhat.com> <20150929084238.GA332@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150929084238.GA332@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Waiman Long <waiman.long@hp.com>, Thomas Gleixner <tglx@linutronix.de>

On 09/29, Ingo Molnar wrote:
>
> * Oleg Nesterov <oleg@redhat.com> wrote:
>
> > 	struct task_struct *next_task_with_mm(struct task_struct *p)
> > 	{
> > 		struct task_struct *t;
> >
> > 		p = p->group_leader;
> > 		while ((p = next_task(p)) != &init_task) {
> > 			if (p->flags & PF_KTHREAD)
> > 				continue;
> >
> > 			t = find_lock_task_mm(p);
> > 			if (t)
> > 				return t;
> > 		}
> >
> > 		return NULL;
> > 	}
> >
> > 	#define for_each_task_lock_mm(p)
> > 		for (p = &init_task; (p = next_task_with_mm(p)); task_unlock(p))
> >
> >
> > So that you can do
> >
> > 	for_each_task_lock_mm(p) {
> > 		do_something_with(p->mm);
> >
> > 		if (some_condition()) {
> > 			// UNFORTUNATELY you can't just do "break"
> > 			task_unlock(p);
> > 			break;
> > 		}
> > 	}
> >
> > do you think it makes sense?
>
> Sure, I'm inclined to use the above code from you.
>
> > In fact it can't be simpler, we can move task_unlock() into next_task_with_mm(),
> > it can check ->mm != NULL or p != init_task.
>
> s/can't/can ?

yes, sorry,

> But even with that I'm not sure I can parse your suggestion. Got some (pseudo) code
> perhaps?

I meant

	struct task_struct *next_task_lock_mm(struct task_struct *p)
	{
		struct task_struct *t;

		if (p) {
			task_unlock(p);
			p = p->group_leader;
		} else {
			p = &init_task;
		}

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
		for (p = NULL; (p = next_task_lock_mm(p)); )

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
