Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9EE1D6B0282
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 20:37:01 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id v14so152274wmd.3
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 17:37:01 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id i20si2647372wrc.287.2018.02.09.17.36.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 17:36:59 -0800 (PST)
Date: Sat, 10 Feb 2018 01:36:40 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: possible deadlock in get_user_pages_unlocked
Message-ID: <20180210013640.GN30522@ZenIV.linux.org.uk>
References: <001a113f6344393d89056430347d@google.com>
 <20180202045020.GF30522@ZenIV.linux.org.uk>
 <20180202053502.GB949@zzz.localdomain>
 <20180202054626.GG30522@ZenIV.linux.org.uk>
 <20180202062037.GH30522@ZenIV.linux.org.uk>
 <CACT4Y+bDU00aQpJOUK8eB+Kv4HycNwKA=kShUe9kSd0FUqO+FQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+bDU00aQpJOUK8eB+Kv4HycNwKA=kShUe9kSd0FUqO+FQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Eric Biggers <ebiggers3@gmail.com>, syzbot <syzbot+bacbe5d8791f30c9cee5@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, James Morse <james.morse@arm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Ingo Molnar <mingo@kernel.org>, syzkaller-bugs@googlegroups.com

On Fri, Feb 02, 2018 at 09:57:27AM +0100, Dmitry Vyukov wrote:

> syzbot tests for up to 5 minutes. However, if there is a race involved
> then you may need more time because the crash is probabilistic.
> But from what I see most of the time, if one can't reproduce it
> easily, it's usually due to some differences in setup that just don't
> allow the crash to happen at all.
> FWIW syzbot re-runs each reproducer on a freshly booted dedicated VM
> and what it provided is the kernel output it got during run of the
> provided program. So we have reasonably high assurance that this
> reproducer worked in at least one setup.

Could you guys check if the following fixes the reproducer?

diff --git a/mm/gup.c b/mm/gup.c
index 61015793f952..058a9a8e4e2e 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -861,6 +861,9 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 		BUG_ON(*locked != 1);
 	}
 
+	if (flags & FOLL_NOWAIT)
+		locked = NULL;
+
 	if (pages)
 		flags |= FOLL_GET;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
