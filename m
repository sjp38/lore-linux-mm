Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id EBFB86B0005
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 13:20:07 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id i22so42978700ywc.3
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 10:20:07 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c134si14158568qke.97.2016.04.26.10.20.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 10:20:07 -0700 (PDT)
Date: Tue, 26 Apr 2016 13:20:04 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH 17/19] dm: get rid of superfluous gfp flags
In-Reply-To: <20160422124730.GA11733@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1604261307520.12205@file01.intranet.prod.int.rdu2.redhat.com>
References: <1460372892-8157-1-git-send-email-mhocko@kernel.org> <1460372892-8157-18-git-send-email-mhocko@kernel.org> <alpine.LRH.2.02.1604150826280.16981@file01.intranet.prod.int.rdu2.redhat.com> <20160415130839.GJ32377@dhcp22.suse.cz>
 <alpine.LRH.2.02.1604151437500.3288@file01.intranet.prod.int.rdu2.redhat.com> <20160416203135.GC15128@dhcp22.suse.cz> <20160422124730.GA11733@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Shaohua Li <shli@kernel.org>



On Fri, 22 Apr 2016, Michal Hocko wrote:

> On Sat 16-04-16 16:31:35, Michal Hocko wrote:
> > On Fri 15-04-16 14:41:29, Mikulas Patocka wrote:
> > > 
> > > 
> > > On Fri, 15 Apr 2016, Michal Hocko wrote:
> > > 
> > > > On Fri 15-04-16 08:29:28, Mikulas Patocka wrote:
> > > > > 
> > > > > 
> > > > > On Mon, 11 Apr 2016, Michal Hocko wrote:
> > > > > 
> > > > > > From: Michal Hocko <mhocko@suse.com>
> > > > > > 
> > > > > > copy_params seems to be little bit confused about which allocation flags
> > > > > > to use. It enforces GFP_NOIO even though it uses
> > > > > > memalloc_noio_{save,restore} which enforces GFP_NOIO at the page
> > > > > 
> > > > > memalloc_noio_{save,restore} is used because __vmalloc is flawed and 
> > > > > doesn't respect GFP_NOIO properly (it doesn't use gfp flags when 
> > > > > allocating pagetables).
> > > > 
> > > > Yes and there are no plans to change __vmalloc to properly propagate gfp
> > > > flags through the whole call chain and that is why we have
> > > > memalloc_noio thingy. If that ever changes later the GFP_NOIO can be
> > > > added in favor of memalloc_noio API. Both are clearly redundant.
> > > > -- 
> > > > Michal Hocko
> > > > SUSE Labs
> > > 
> > > You could move memalloc_noio_{save,restore} to __vmalloc. Something like
> > > 
> > > if (!(gfp_mask & __GFP_IO))
> > > 	noio_flag = memalloc_noio_save();
> > > ...
> > > if (!(gfp_mask & __GFP_IO))
> > > 	memalloc_noio_restore(noio_flag);
> > > 
> > > That would be better than repeating this hack in every __vmalloc caller 
> > > that need GFP_NOIO.
> > 
> > It is not my intention to change __vmalloc behavior. If you strongly
> > oppose the GFP_NOIO change I can drop it from the patch. It is
> > __GFP_REPEAT which I am after.
> 
> I am dropping the GFP_NOIO part for this patch but now that I am looking
> into the code more closely I completely fail why it is needed in the
> first place.
> 
> copy_params seems to be called only from the ioctl context which doesn't
> hold any locks which would lockup during the direct reclaim AFAICS. The
> git log shows that the code has used PF_MEMALLOC before which is even
> bigger mystery to me. Could you please clarify why this is GFP_NOIO
> restricted context? Maybe it needed to be in the past but I do not see
> any reason for it to be now so unless I am missing something the
> GFP_KERNEL should be perfectly OK. Also note that GFP_NOIO wouldn't work
> properly because there are copy_from_user calls in the same path which
> could page fault and do GFP_KERNEL allocations anyway. I can send follow
> up cleanups unless I am missing something subtle here.
> -- 
> Michal Hocko
> SUSE Labs

The LVM tool calls suspend and resume ioctls on device mapper block 
devices.

When a device is suspended, any bio sent to the device is held. If the 
resume ioctl did GFP_KERNEL allocation, the allocation could get stuck 
trying to write some dirty cached pages to the suspended device.

The LVM tool and the dmeventd daemon use mlock to lock its address space, 
so the copy_from_user/copy_to_user call cannot trigger a page fault.

Mikulas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
