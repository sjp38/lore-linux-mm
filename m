Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 47B866B0682
	for <linux-mm@kvack.org>; Fri,  4 Aug 2017 06:41:46 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id p62so1048895oih.12
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 03:41:46 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id p185si1089489oia.187.2017.08.04.03.41.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 04 Aug 2017 03:41:45 -0700 (PDT)
Subject: Re: [PATCH] mm, oom: fix potential data corruption when oom_reaper races with writer
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201708040646.v746kkhC024636@www262.sakura.ne.jp>
	<20170804074212.GA26029@dhcp22.suse.cz>
	<201708040825.v748Pkul053862@www262.sakura.ne.jp>
	<20170804091629.GI26029@dhcp22.suse.cz>
In-Reply-To: <20170804091629.GI26029@dhcp22.suse.cz>
Message-Id: <201708041941.JFH26516.HOMtSQFFFOLVJO@I-love.SAKURA.ne.jp>
Date: Fri, 4 Aug 2017 19:41:42 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, wenwei.tww@alibaba-inc.com, oleg@redhat.com, rientjes@google.com, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Fri 04-08-17 17:25:46, Tetsuo Handa wrote:
> > Well, while lockdep warning is gone, this problem is remaining.
> > 
> > diff --git a/mm/memory.c b/mm/memory.c
> > index edabf6f..1e06c29 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -3931,15 +3931,14 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
> >         /*
> >          * This mm has been already reaped by the oom reaper and so the
> >          * refault cannot be trusted in general. Anonymous refaults would
> > -        * lose data and give a zero page instead e.g. This is especially
> > -        * problem for use_mm() because regular tasks will just die and
> > -        * the corrupted data will not be visible anywhere while kthread
> > -        * will outlive the oom victim and potentially propagate the date
> > -        * further.
> > +        * lose data and give a zero page instead e.g.
> >          */
> > -       if (unlikely((current->flags & PF_KTHREAD) && !(ret & VM_FAULT_ERROR)
> > -                               && test_bit(MMF_UNSTABLE, &vma->vm_mm->flags)))
> > +       if (unlikely(!(ret & VM_FAULT_ERROR)
> > +                    && test_bit(MMF_UNSTABLE, &vma->vm_mm->flags))) {
> > +               if (ret & VM_FAULT_RETRY)
> > +                       down_read(&vma->vm_mm->mmap_sem);
> >                 ret = VM_FAULT_SIGBUS;
> > +       }
> > 
> >         return ret;
> >  }
> 
> I have re-read your email again and I guess I misread previously. Are
> you saying that the data corruption happens with the both patches
> applied?

Yes. Data corruption still happens.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
