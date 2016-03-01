Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 191D96B0257
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 11:14:08 -0500 (EST)
Received: by mail-qg0-f47.google.com with SMTP id u110so16368731qge.3
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 08:14:08 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f11si456321qgf.11.2016.03.01.08.14.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Mar 2016 08:14:07 -0800 (PST)
Date: Tue, 1 Mar 2016 18:14:02 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] exit: clear TIF_MEMDIE after exit_task_work
Message-ID: <20160301181136-mutt-send-email-mst@redhat.com>
References: <1456765329-14890-1-git-send-email-vdavydov@virtuozzo.com>
 <20160301155212.GJ9461@dhcp22.suse.cz>
 <20160301175431-mutt-send-email-mst@redhat.com>
 <20160301160813.GM9461@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160301160813.GM9461@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Mar 01, 2016 at 05:08:13PM +0100, Michal Hocko wrote:
> On Tue 01-03-16 17:57:04, Michael S. Tsirkin wrote:
> > On Tue, Mar 01, 2016 at 04:52:12PM +0100, Michal Hocko wrote:
> > > [CCing vhost-net maintainer]
> > > 
> > > On Mon 29-02-16 20:02:09, Vladimir Davydov wrote:
> > > > An mm_struct may be pinned by a file. An example is vhost-net device
> > > > created by a qemu/kvm (see vhost_net_ioctl -> vhost_net_set_owner ->
> > > > vhost_dev_set_owner).
> > > 
> > > The more I think about that the more I am wondering whether this is
> > > actually OK and correct. Why does the driver have to pin the address
> > > space? Nothing really prevents from parallel tearing down of the address
> > > space anyway so the code cannot expect all the vmas to stay. Would it be
> > > enough to pin the mm_struct only?
> > 
> > I'll need to research this. It's a fact that as long as the
> > device is not stopped, vhost can attempt to access
> > the address space.
> 
> But does it expect any specific parts of the address space to be mapped?
> E.g. proc needs to keep the mm allocated as well for some files but it
> doesn't pin the address space (mm_users) but rather mm_count (see
> proc_mem_open).

As I said, I need to research this.

> > > I am not sure I understand the code properly but what prevents from
> > > the situation when a VHOST_SET_OWNER caller dies without calling
> > > VHOST_RESET_OWNER and so the mm would be pinned indefinitely?
> > > 
> > > [Keeping the reset of the email for reference]
> > 
> > We have:
> > 
> > static const struct file_operations vhost_net_fops = {
> >         .owner          = THIS_MODULE,
> >         .release        = vhost_net_release,
> > ...
> > };
> > 
> > When caller dies and after fds are closed,
> > vhost_net_release calls vhost_dev_cleanup and that
> > drops the mm reference.
> 
> Can another process have the device open as well and prevent from
> destruction?

Yes.

> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
