Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B74E16B0069
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 04:52:36 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id g141so7320389wmd.0
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 01:52:36 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s70si3136010wme.94.2016.09.14.01.52.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Sep 2016 01:52:35 -0700 (PDT)
Date: Wed, 14 Sep 2016 10:52:28 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: fix oom work when memory is under pressure
Message-ID: <20160914085227.GB1612@dhcp22.suse.cz>
References: <1473173226-25463-1-git-send-email-zhongjiang@huawei.com>
 <20160909114410.GG4844@dhcp22.suse.cz>
 <57D67A8A.7070500@huawei.com>
 <20160912111327.GG14524@dhcp22.suse.cz>
 <57D6B0C4.6040400@huawei.com>
 <20160912174445.GC14997@dhcp22.suse.cz>
 <57D7FB71.9090102@huawei.com>
 <20160913132854.GB6592@dhcp22.suse.cz>
 <57D8F8AE.1090404@huawei.com>
 <20160914084219.GA1612@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160914084219.GA1612@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, linux-mm@kvack.org, Xishi Qiu <qiuxishi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Hugh Dickins <hughd@google.com>

On Wed 14-09-16 10:42:19, Michal Hocko wrote:
> [Let's CC Hugh]

now for real...

> 
> On Wed 14-09-16 15:13:50, zhong jiang wrote:
> [...]
> >   hi, Michal
> > 
> >   Recently, I hit the same issue when run a OOM case of the LTP and ksm enable.
> >  
> > [  601.937145] Call trace:
> > [  601.939600] [<ffffffc000086a88>] __switch_to+0x74/0x8c
> > [  601.944760] [<ffffffc000a1bae0>] __schedule+0x23c/0x7bc
> > [  601.950007] [<ffffffc000a1c09c>] schedule+0x3c/0x94
> > [  601.954907] [<ffffffc000a1eb84>] rwsem_down_write_failed+0x214/0x350
> > [  601.961289] [<ffffffc000a1e32c>] down_write+0x64/0x80
> > [  601.966363] [<ffffffc00021f794>] __ksm_exit+0x90/0x19c
> > [  601.971523] [<ffffffc0000be650>] mmput+0x118/0x11c
> > [  601.976335] [<ffffffc0000c3ec4>] do_exit+0x2dc/0xa74
> > [  601.981321] [<ffffffc0000c46f8>] do_group_exit+0x4c/0xe4
> > [  601.986656] [<ffffffc0000d0f34>] get_signal+0x444/0x5e0
> > [  601.991904] [<ffffffc000089fcc>] do_signal+0x1d8/0x450
> > [  601.997065] [<ffffffc00008a35c>] do_notify_resume+0x70/0x78
> 
> So this is a hung task triggering because the exiting task cannot get
> the mmap sem for write because the ksmd holds it for read while
> allocating memory which just takes ages to complete, right?
> 
> > 
> > The root case is that ksmd hold the read lock. and the lock is not released.
> >  scan_get_next_rmap_item
> >          down_read
> >                    get_next_rmap_item
> >                              alloc_rmap_item     #ksmd will loop permanently.
> > 
> > How do you see this kind of situation ? or  let the issue alone.
> 
> I am not familiar with the ksmd code so it is hard for me to judge but
> one thing to do would be __GFP_NORETRY which would force a bail out from
> the allocation rather than looping for ever. A quick look tells me that
> the allocation failure here is quite easy to handle. There might be
> others...
> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
