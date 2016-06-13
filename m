Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id DEF4D6B025E
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 09:52:56 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id e5so100442182ith.0
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 06:52:56 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id r65si12081791oia.96.2016.06.13.06.52.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Jun 2016 06:52:55 -0700 (PDT)
Subject: Re: [PATCH] exit: clear TIF_MEMDIE after exit_task_work
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160301171758.GP9461@dhcp22.suse.cz>
	<20160301191906-mutt-send-email-mst@redhat.com>
	<20160314163943.GE11400@dhcp22.suse.cz>
	<20160607125014.GL12305@dhcp22.suse.cz>
	<20160613115041.GG6518@dhcp22.suse.cz>
In-Reply-To: <20160613115041.GG6518@dhcp22.suse.cz>
Message-Id: <201606132252.IAE00593.OJQSFMtVFOLHOF@I-love.SAKURA.ne.jp>
Date: Mon, 13 Jun 2016 22:52:43 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, mst@redhat.com
Cc: vdavydov@virtuozzo.com, akpm@linux-foundation.org, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> I have checked the vnet code and it doesn't seem to rely on
> copy_from_user/get_user AFAICS. Other users of use_mm() need to copy to
> the userspace only as well. So we should be perfectly safe to OOM reap
> address space even when it is shared by the kthread [1] so this is
> not really needed for the OOM correctness purpose. It would be much
> nicer if the kthread didn't pin the mm for two long outside of the OOM
> handling as well of course but that lowers the priority of the change.
> 
> [1] http://lkml.kernel.org/r/20160613112348.GC6518@dhcp22.suse.cz

It seems to me that vhost code relies on copy from the userspace.

use_mm(dev->mm) and unuse_mm(dev->mm) are used inside vhost_worker().
work->fn(work) is initialized by vhost_work_init().
vhost_scsi_open() passes vhost_scsi_complete_cmd_work() and
vhost_scsi_evt_work() as ->fn, and both functions call __get_user().

vhost_scsi_complete_cmd_work() {
  vhost_signal() {
    vhost_notify() {
      __get_user()
    }
  }
}

vhost_scsi_evt_work() {
  vhost_scsi_do_evt_work() {
    vhost_get_vq_desc() {
      __get_user() / __copy_from_user()
      get_indirect() {
        copy_from_iter()
      }
    }
  }
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
