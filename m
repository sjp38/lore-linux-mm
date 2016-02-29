Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 7B5C86B0005
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 13:44:47 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id l68so2240569wml.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 10:44:47 -0800 (PST)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id s18si33393222wjw.150.2016.02.29.10.44.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 10:44:46 -0800 (PST)
Received: by mail-wm0-f51.google.com with SMTP id l68so3965559wml.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 10:44:46 -0800 (PST)
Date: Mon, 29 Feb 2016 19:44:44 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] exit: clear TIF_MEMDIE after exit_task_work
Message-ID: <20160229184444.GT16930@dhcp22.suse.cz>
References: <1456765329-14890-1-git-send-email-vdavydov@virtuozzo.com>
 <20160229182131.GP16930@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160229182131.GP16930@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 29-02-16 19:21:31, Michal Hocko wrote:
> On Mon 29-02-16 20:02:09, Vladimir Davydov wrote:
> > An mm_struct may be pinned by a file. An example is vhost-net device
> > created by a qemu/kvm (see vhost_net_ioctl -> vhost_net_set_owner ->
> > vhost_dev_set_owner). If such process gets OOM-killed, the reference to
> > its mm_struct will only be released from exit_task_work -> ____fput ->
> > __fput -> vhost_net_release -> vhost_dev_cleanup, which is called after
> > exit_mmap, where TIF_MEMDIE is cleared. As a result, we can start
> > selecting the next victim before giving the last one a chance to free
> > its memory. In practice, this leads to killing several VMs along with
> > the fattest one.
> 
> I am wondering why our PF_EXITING protection hasn't fired up.

OK, I guess I can see it. exit_mm has done tsk->mm = NULL and so we are
skipping over that task because oom_scan_process_thread hasn't checked
PF_EXITING. I will try to think about this some more tomorrow with a
fresh brain.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
