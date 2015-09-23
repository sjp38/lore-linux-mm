Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id E685B6B0253
	for <linux-mm@kvack.org>; Wed, 23 Sep 2015 05:57:11 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so36578633pad.1
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 02:57:11 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id gw3si9429282pac.79.2015.09.23.02.57.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Sep 2015 02:57:11 -0700 (PDT)
Received: by pacgz1 with SMTP id gz1so2377386pac.3
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 02:57:11 -0700 (PDT)
Date: Wed, 23 Sep 2015 18:57:57 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [patch] mm, oom: remove task_lock protecting comm printing
Message-ID: <20150923095757.GC640@swordfish>
References: <alpine.DEB.2.10.1509221629440.7794@chino.kir.corp.google.com>
 <20150923080632.GD12318@esperanza>
 <20150923091354.GA640@swordfish>
 <20150923093021.GE12318@esperanza>
 <20150923094358.GB8644@dhcp22.suse.cz>
 <20150923095022.GB640@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150923095022.GB640@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On (09/23/15 18:50), Sergey Senozhatsky wrote:
> On (09/23/15 11:43), Michal Hocko wrote:
> [..]
> > > > the previous name was already null terminated,
> > > 
> > > Yeah, but if the old name is shorter than the new one, set_task_comm()
> > > overwrites the terminating null of the old name before writing the new
> > > terminating null, so there is a short time window during which tsk->comm
> > > might be not null-terminated, no?
> > 
> > Not really:
> >         case PR_SET_NAME:
> >                 comm[sizeof(me->comm) - 1] = 0;
> >                 if (strncpy_from_user(comm, (char __user *)arg2,
> >                                       sizeof(me->comm) - 1) < 0)
> >                         return -EFAULT;
> > 
> > So it first writes the terminating 0 and only then starts copying.
> 
> right.

... no right. that should have been

me->comm[sizeof(me->comm) - 1] = 0;

to be save. no?


> hm, shouldn't set_task_comm()->__set_task_comm() do the same?

or something like this instead

---

 fs/exec.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/exec.c b/fs/exec.c
index b06623a..d7d2de0 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1072,6 +1072,7 @@ EXPORT_SYMBOL_GPL(get_task_comm);
 
 void __set_task_comm(struct task_struct *tsk, const char *buf, bool exec)
 {
+	tsk->comm[sizeof(tsk->comm) - 1] = 0;
 	task_lock(tsk);
 	trace_task_rename(tsk, buf);
 	strlcpy(tsk->comm, buf, sizeof(tsk->comm));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
