Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 934416B0069
	for <linux-mm@kvack.org>; Fri, 16 Sep 2016 18:14:06 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id n24so187596211pfb.0
        for <linux-mm@kvack.org>; Fri, 16 Sep 2016 15:14:06 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id g72si11652155pfe.241.2016.09.16.15.14.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Sep 2016 15:14:05 -0700 (PDT)
Received: by mail-pa0-x22c.google.com with SMTP id id6so29620176pad.3
        for <linux-mm@kvack.org>; Fri, 16 Sep 2016 15:14:05 -0700 (PDT)
Date: Fri, 16 Sep 2016 15:13:56 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: fix oom work when memory is under pressure
In-Reply-To: <20160914085227.GB1612@dhcp22.suse.cz>
Message-ID: <alpine.LSU.2.11.1609161440280.5127@eggly.anvils>
References: <1473173226-25463-1-git-send-email-zhongjiang@huawei.com> <20160909114410.GG4844@dhcp22.suse.cz> <57D67A8A.7070500@huawei.com> <20160912111327.GG14524@dhcp22.suse.cz> <57D6B0C4.6040400@huawei.com> <20160912174445.GC14997@dhcp22.suse.cz>
 <57D7FB71.9090102@huawei.com> <20160913132854.GB6592@dhcp22.suse.cz> <57D8F8AE.1090404@huawei.com> <20160914084219.GA1612@dhcp22.suse.cz> <20160914085227.GB1612@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: zhong jiang <zhongjiang@huawei.com>, akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, linux-mm@kvack.org, Xishi Qiu <qiuxishi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Hugh Dickins <hughd@google.com>

On Wed, 14 Sep 2016, Michal Hocko wrote:
> On Wed 14-09-16 10:42:19, Michal Hocko wrote:
> > [Let's CC Hugh]
> 
> now for real...
> 
> > 
> > On Wed 14-09-16 15:13:50, zhong jiang wrote:
> > [...]
> > >   hi, Michal
> > > 
> > >   Recently, I hit the same issue when run a OOM case of the LTP and ksm enable.
> > >  
> > > [  601.937145] Call trace:
> > > [  601.939600] [<ffffffc000086a88>] __switch_to+0x74/0x8c
> > > [  601.944760] [<ffffffc000a1bae0>] __schedule+0x23c/0x7bc
> > > [  601.950007] [<ffffffc000a1c09c>] schedule+0x3c/0x94
> > > [  601.954907] [<ffffffc000a1eb84>] rwsem_down_write_failed+0x214/0x350
> > > [  601.961289] [<ffffffc000a1e32c>] down_write+0x64/0x80
> > > [  601.966363] [<ffffffc00021f794>] __ksm_exit+0x90/0x19c
> > > [  601.971523] [<ffffffc0000be650>] mmput+0x118/0x11c
> > > [  601.976335] [<ffffffc0000c3ec4>] do_exit+0x2dc/0xa74
> > > [  601.981321] [<ffffffc0000c46f8>] do_group_exit+0x4c/0xe4
> > > [  601.986656] [<ffffffc0000d0f34>] get_signal+0x444/0x5e0
> > > [  601.991904] [<ffffffc000089fcc>] do_signal+0x1d8/0x450
> > > [  601.997065] [<ffffffc00008a35c>] do_notify_resume+0x70/0x78
> > 
> > So this is a hung task triggering because the exiting task cannot get
> > the mmap sem for write because the ksmd holds it for read while
> > allocating memory which just takes ages to complete, right?
> > 
> > > 
> > > The root case is that ksmd hold the read lock. and the lock is not released.
> > >  scan_get_next_rmap_item
> > >          down_read
> > >                    get_next_rmap_item
> > >                              alloc_rmap_item     #ksmd will loop permanently.
> > > 
> > > How do you see this kind of situation ? or  let the issue alone.
> > 
> > I am not familiar with the ksmd code so it is hard for me to judge but
> > one thing to do would be __GFP_NORETRY which would force a bail out from
> > the allocation rather than looping for ever. A quick look tells me that
> > the allocation failure here is quite easy to handle. There might be
> > others...

Yes, very good suggestion in this case: the ksmd code does exactly the
right thing when that allocation fails, but was too stupid to use an
allocation mode which might fail - and it can allocate rather a lot of
slots along that path, so it will be good to let it break out there.

Thank you, Zhongjiang, please send akpm a fully signed-off patch, tagged
for stable, with your explanation above (which was a lot more helpful
to me than what you wrote in your other mail of Sept 13th).  But please
make it GFP_KERNEL | __GFP_NORETRY | __GFP_NOWARN (and break that line
before 80 cols): the allocation will sometimes fail, and we're not at
all interested in hearing about that.

Michal, how would you feel about this or a separate patch adding
__GFP_HIGH to the allocation in ksm's alloc_stable_node()?  That
allocation could cause the same problem, but it is much less common
(so less important to do anything about it), and differs from the
rmap_item case in that if it succeeds, it will usually free a page;
whereas if it fails, the fallback (two break_cow()s) may want to
allocate a couple of pages.  So __GFP_HIGH makes more sense for it
than __GFP_NORETRY: but perhaps we prefer not to add __GFP_HIGHs?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
