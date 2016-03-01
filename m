Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id C8B936B0253
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 12:18:01 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id l68so45338275wml.0
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 09:18:01 -0800 (PST)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id uw6si38270458wjc.225.2016.03.01.09.18.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Mar 2016 09:18:00 -0800 (PST)
Received: by mail-wm0-f49.google.com with SMTP id n186so47761954wmn.1
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 09:18:00 -0800 (PST)
Date: Tue, 1 Mar 2016 18:17:58 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] exit: clear TIF_MEMDIE after exit_task_work
Message-ID: <20160301171758.GP9461@dhcp22.suse.cz>
References: <1456765329-14890-1-git-send-email-vdavydov@virtuozzo.com>
 <20160301155212.GJ9461@dhcp22.suse.cz>
 <20160301175431-mutt-send-email-mst@redhat.com>
 <20160301160813.GM9461@dhcp22.suse.cz>
 <20160301182027-mutt-send-email-mst@redhat.com>
 <20160301163537.GO9461@dhcp22.suse.cz>
 <20160301184046-mutt-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160301184046-mutt-send-email-mst@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 01-03-16 18:46:38, Michael S. Tsirkin wrote:
> On Tue, Mar 01, 2016 at 05:35:37PM +0100, Michal Hocko wrote:
> > On Tue 01-03-16 18:22:32, Michael S. Tsirkin wrote:
> > > On Tue, Mar 01, 2016 at 05:08:13PM +0100, Michal Hocko wrote:
> > > > On Tue 01-03-16 17:57:04, Michael S. Tsirkin wrote:
> > > > > On Tue, Mar 01, 2016 at 04:52:12PM +0100, Michal Hocko wrote:
> > > > > > [CCing vhost-net maintainer]
> > > > > > 
> > > > > > On Mon 29-02-16 20:02:09, Vladimir Davydov wrote:
> > > > > > > An mm_struct may be pinned by a file. An example is vhost-net device
> > > > > > > created by a qemu/kvm (see vhost_net_ioctl -> vhost_net_set_owner ->
> > > > > > > vhost_dev_set_owner).
> > > > > > 
> > > > > > The more I think about that the more I am wondering whether this is
> > > > > > actually OK and correct. Why does the driver have to pin the address
> > > > > > space? Nothing really prevents from parallel tearing down of the address
> > > > > > space anyway so the code cannot expect all the vmas to stay. Would it be
> > > > > > enough to pin the mm_struct only?
> > > > > 
> > > > > I'll need to research this. It's a fact that as long as the
> > > > > device is not stopped, vhost can attempt to access
> > > > > the address space.
> > > > 
> > > > But does it expect any specific parts of the address space to be mapped?
> > > > E.g. proc needs to keep the mm allocated as well for some files but it
> > > > doesn't pin the address space (mm_users) but rather mm_count (see
> > > > proc_mem_open).
> > > 
> > > At a quick glance, it seems that it's needed: it calls
> > > get_user_pages(mm) and that looks like it will not DTRT (or even fail
> > > gracefully) if mm->mm_users == 0 and exit_mmap/etc was already called
> > > (or is in progress).
> > 
> > yes it will fail gracefully
> 
> 
> What makes get_user_pages fail gracefully in this case,
> if it races with task exiting?

Sorry, I could have been more verbose... The code would have to make sure
that the mm is still alive before calling g-u-p by
atomic_inc_not_zero(&mm->mm_users) and fail if the user count dropped to
0 in the mean time. See how fs/proc/task_mmu.c does that (proc_mem_open
+ m_start + m_stop.

The biggest advanatage would be that the mm address space pin would be
only for the particular operation. Not sure whether that is possible in
the driver though. Anyway pinning the mm for a potentially unbounded
amount of time doesn't sound too nice.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
