Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 18D116B000E
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 04:03:46 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id h48-v6so744545edh.22
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 01:03:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j24-v6si1696659ejv.17.2018.10.09.01.03.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 01:03:44 -0700 (PDT)
Date: Tue, 9 Oct 2018 10:03:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom_adj: avoid meaningless loop to find processes
 sharing mm
Message-ID: <20181009080343.GE8528@dhcp22.suse.cz>
References: <CGME20181005063208epcms1p22959cd2f771ad017996e2b18266791ea@epcms1p2>
 <20181005063208epcms1p22959cd2f771ad017996e2b18266791ea@epcms1p2>
 <20181009062330.GA8528@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181009062330.GA8528@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yong-Taek Lee <ytk.lee@samsung.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>

On Tue 09-10-18 08:23:30, Michal Hocko wrote:
> [Cc Oleg]

JFYI there was new submission http://lkml.kernel.org/r/20181008011931epcms1p82dd01b7e5c067ea99946418bc97de46a@epcms1p8
> 
> On Fri 05-10-18 15:32:08, Yong-Taek Lee wrote:
> > It is introduced by commit 44a70adec910 ("mm, oom_adj: make sure
> > processes sharing mm have same view of oom_score_adj"). Most of
> > user process's mm_users is bigger than 1 but only one thread group.
> > In this case, for_each_process loop meaninglessly try to find processes
> > which sharing same mm even though there is only one thread group.
> > 
> > My idea is that target task's nr thread is smaller than mm_users if there
> > are more thread groups sharing the same mm. So we can skip loop
> 
> I remember trying to optimize this but ended up with nothing that would
> work reliable. E.g. what prevents a thread terminating right after we
> read mm reference count and result in early break and other process
> not being updated properly?
> 
> > if mm_user and nr_thread are same.
> > 
> > test result
> > while true; do count=0; time while [ $count -lt 10000 ]; do echo -1000 > /proc/
> > 1457/oom_score_adj; count=$((count+1)); done; done;
> 
> Is this overhead noticeable in a real work usecases though? Or are you
> updating oom_score_adj that often really?
> 
> > before patch
> > 0m00.59s real     0m00.09s user     0m00.51s system
> > 0m00.59s real     0m00.14s user     0m00.45s system
> > 0m00.58s real     0m00.11s user     0m00.47s system
> > 0m00.58s real     0m00.10s user     0m00.48s system
> > 0m00.59s real     0m00.11s user     0m00.48s system
> > 
> > after patch
> > 0m00.15s real     0m00.07s user     0m00.08s system
> > 0m00.14s real     0m00.10s user     0m00.04s system
> > 0m00.14s real     0m00.10s user     0m00.05s system
> > 0m00.14s real     0m00.08s user     0m00.07s system
> > 0m00.14s real     0m00.08s user     0m00.07s system
> > 
> > Signed-off-by: Lee YongTaek <ytk.lee@samsung.com>
> > ---
> >  fs/proc/base.c | 4 +++-
> >  1 file changed, 3 insertions(+), 1 deletion(-)
> > 
> > diff --git a/fs/proc/base.c b/fs/proc/base.c
> > index f9f72aee6d45..54b2fb5e9c51 100644
> > --- a/fs/proc/base.c
> > +++ b/fs/proc/base.c
> > @@ -1056,6 +1056,7 @@ static int __set_oom_adj(struct file *file, int oom_adj,
> > bool legacy)
> >         struct mm_struct *mm = NULL;
> >         struct task_struct *task;
> >         int err = 0;
> > +       int mm_users = 0;
> > 
> >         task = get_proc_task(file_inode(file));
> >         if (!task)
> > @@ -1092,7 +1093,8 @@ static int __set_oom_adj(struct file *file, int oom_adj,
> > bool legacy)
> >                 struct task_struct *p = find_lock_task_mm(task);
> > 
> >                 if (p) {
> > -                       if (atomic_read(&p->mm->mm_users) > 1) {
> > +                       mm_users = atomic_read(&p->mm->mm_users);
> > +                       if ((mm_users > 1) && (mm_users != get_nr_threads(p)))
> > {
> >                                 mm = p->mm;
> >                                 atomic_inc(&mm->mm_count);
> >                         }
> > --
> > 
> > *
> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
Michal Hocko
SUSE Labs
