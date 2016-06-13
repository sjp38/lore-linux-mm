Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 302FD6B007E
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 10:00:57 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id l184so5167783lfl.3
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 07:00:57 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id e13si15046837wme.10.2016.06.13.07.00.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jun 2016 07:00:55 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id r5so15155500wmr.0
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 07:00:55 -0700 (PDT)
Date: Mon, 13 Jun 2016 16:00:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] exit: clear TIF_MEMDIE after exit_task_work
Message-ID: <20160613140052.GJ6518@dhcp22.suse.cz>
References: <20160301171758.GP9461@dhcp22.suse.cz>
 <20160301191906-mutt-send-email-mst@redhat.com>
 <20160314163943.GE11400@dhcp22.suse.cz>
 <20160607125014.GL12305@dhcp22.suse.cz>
 <20160613115041.GG6518@dhcp22.suse.cz>
 <201606132252.IAE00593.OJQSFMtVFOLHOF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606132252.IAE00593.OJQSFMtVFOLHOF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mst@redhat.com, vdavydov@virtuozzo.com, akpm@linux-foundation.org, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 13-06-16 22:52:43, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > I have checked the vnet code and it doesn't seem to rely on
> > copy_from_user/get_user AFAICS. Other users of use_mm() need to copy to
> > the userspace only as well. So we should be perfectly safe to OOM reap
> > address space even when it is shared by the kthread [1] so this is
> > not really needed for the OOM correctness purpose. It would be much
> > nicer if the kthread didn't pin the mm for two long outside of the OOM
> > handling as well of course but that lowers the priority of the change.
> > 
> > [1] http://lkml.kernel.org/r/20160613112348.GC6518@dhcp22.suse.cz
> 
> It seems to me that vhost code relies on copy from the userspace.
> 
> use_mm(dev->mm) and unuse_mm(dev->mm) are used inside vhost_worker().
> work->fn(work) is initialized by vhost_work_init().
> vhost_scsi_open() passes vhost_scsi_complete_cmd_work() and
> vhost_scsi_evt_work() as ->fn, and both functions call __get_user().
> 
> vhost_scsi_complete_cmd_work() {
>   vhost_signal() {
>     vhost_notify() {
>       __get_user()
>     }
>   }
> }
> 
> vhost_scsi_evt_work() {
>   vhost_scsi_do_evt_work() {
>     vhost_get_vq_desc() {
>       __get_user() / __copy_from_user()
>       get_indirect() {
>         copy_from_iter()
>       }
>     }
>   }
> }

Ahh, I've missed those. Thanks for pointing this out! Let me try to find
out whether the code is robust to see unexpected 0 when reading from the
userspace.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
