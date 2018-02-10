Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D76166B0005
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 22:19:29 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id h10so2338619pgf.3
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 19:19:29 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 37-v6sor97286pld.90.2018.02.09.19.19.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Feb 2018 19:19:28 -0800 (PST)
Date: Fri, 9 Feb 2018 19:19:25 -0800
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: possible deadlock in get_user_pages_unlocked
Message-ID: <20180210031925.GA1041@zzz.localdomain>
References: <001a113f6344393d89056430347d@google.com>
 <20180202045020.GF30522@ZenIV.linux.org.uk>
 <20180202053502.GB949@zzz.localdomain>
 <20180202054626.GG30522@ZenIV.linux.org.uk>
 <20180202062037.GH30522@ZenIV.linux.org.uk>
 <CACT4Y+bDU00aQpJOUK8eB+Kv4HycNwKA=kShUe9kSd0FUqO+FQ@mail.gmail.com>
 <20180210013640.GN30522@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180210013640.GN30522@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Dmitry Vyukov <dvyukov@google.com>, syzbot <syzbot+bacbe5d8791f30c9cee5@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, James Morse <james.morse@arm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Ingo Molnar <mingo@kernel.org>, syzkaller-bugs@googlegroups.com

Hi Al,

On Sat, Feb 10, 2018 at 01:36:40AM +0000, Al Viro wrote:
> On Fri, Feb 02, 2018 at 09:57:27AM +0100, Dmitry Vyukov wrote:
> 
> > syzbot tests for up to 5 minutes. However, if there is a race involved
> > then you may need more time because the crash is probabilistic.
> > But from what I see most of the time, if one can't reproduce it
> > easily, it's usually due to some differences in setup that just don't
> > allow the crash to happen at all.
> > FWIW syzbot re-runs each reproducer on a freshly booted dedicated VM
> > and what it provided is the kernel output it got during run of the
> > provided program. So we have reasonably high assurance that this
> > reproducer worked in at least one setup.
> 
> Could you guys check if the following fixes the reproducer?
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index 61015793f952..058a9a8e4e2e 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -861,6 +861,9 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
>  		BUG_ON(*locked != 1);
>  	}
>  
> +	if (flags & FOLL_NOWAIT)
> +		locked = NULL;
> +
>  	if (pages)
>  		flags |= FOLL_GET;
>  

Yes that fixes the reproducer for me.

- Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
