Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 38B616B0005
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 04:35:33 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id e201so30519761wme.1
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 01:35:33 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id y21si29505723wmd.12.2016.04.27.01.35.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 01:35:31 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id w143so10595227wmw.3
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 01:35:31 -0700 (PDT)
Date: Wed, 27 Apr 2016 10:35:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 17/19] dm: get rid of superfluous gfp flags
Message-ID: <20160427083530.GD2179@dhcp22.suse.cz>
References: <1460372892-8157-1-git-send-email-mhocko@kernel.org>
 <1460372892-8157-18-git-send-email-mhocko@kernel.org>
 <alpine.LRH.2.02.1604150826280.16981@file01.intranet.prod.int.rdu2.redhat.com>
 <20160415130839.GJ32377@dhcp22.suse.cz>
 <alpine.LRH.2.02.1604151437500.3288@file01.intranet.prod.int.rdu2.redhat.com>
 <20160416203135.GC15128@dhcp22.suse.cz>
 <20160422124730.GA11733@dhcp22.suse.cz>
 <alpine.LRH.2.02.1604261307520.12205@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1604261307520.12205@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Shaohua Li <shli@kernel.org>, dm-devel@redhat.com

[Adding dm-devel@redhat.com to CC]

On Tue 26-04-16 13:20:04, Mikulas Patocka wrote:
> On Fri, 22 Apr 2016, Michal Hocko wrote:
[...]
> > copy_params seems to be called only from the ioctl context which doesn't
> > hold any locks which would lockup during the direct reclaim AFAICS. The
> > git log shows that the code has used PF_MEMALLOC before which is even
> > bigger mystery to me. Could you please clarify why this is GFP_NOIO
> > restricted context? Maybe it needed to be in the past but I do not see
> > any reason for it to be now so unless I am missing something the
> > GFP_KERNEL should be perfectly OK. Also note that GFP_NOIO wouldn't work
> > properly because there are copy_from_user calls in the same path which
> > could page fault and do GFP_KERNEL allocations anyway. I can send follow
> > up cleanups unless I am missing something subtle here.
> 
> The LVM tool calls suspend and resume ioctls on device mapper block 
> devices.
>
> When a device is suspended, any bio sent to the device is held. If the 
> resume ioctl did GFP_KERNEL allocation, the allocation could get stuck 
> trying to write some dirty cached pages to the suspended device.
> 
> The LVM tool and the dmeventd daemon use mlock to lock its address space, 
> so the copy_from_user/copy_to_user call cannot trigger a page fault.

OK, I see, thanks for the clarification! This sounds fragile to me
though. Wouldn't it be better to use the memalloc_noio_save for the
whole copy_params instead? That would force all possible allocations to
not trigger any IO. Something like the following.
---
