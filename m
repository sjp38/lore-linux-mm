Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id A7A096B007E
	for <linux-mm@kvack.org>; Fri, 22 Apr 2016 08:47:34 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id k200so63431785lfg.1
        for <linux-mm@kvack.org>; Fri, 22 Apr 2016 05:47:34 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id z193si3642256wme.98.2016.04.22.05.47.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Apr 2016 05:47:33 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id w143so3001641wmw.3
        for <linux-mm@kvack.org>; Fri, 22 Apr 2016 05:47:32 -0700 (PDT)
Date: Fri, 22 Apr 2016 14:47:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 17/19] dm: get rid of superfluous gfp flags
Message-ID: <20160422124730.GA11733@dhcp22.suse.cz>
References: <1460372892-8157-1-git-send-email-mhocko@kernel.org>
 <1460372892-8157-18-git-send-email-mhocko@kernel.org>
 <alpine.LRH.2.02.1604150826280.16981@file01.intranet.prod.int.rdu2.redhat.com>
 <20160415130839.GJ32377@dhcp22.suse.cz>
 <alpine.LRH.2.02.1604151437500.3288@file01.intranet.prod.int.rdu2.redhat.com>
 <20160416203135.GC15128@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160416203135.GC15128@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Shaohua Li <shli@kernel.org>

On Sat 16-04-16 16:31:35, Michal Hocko wrote:
> On Fri 15-04-16 14:41:29, Mikulas Patocka wrote:
> > 
> > 
> > On Fri, 15 Apr 2016, Michal Hocko wrote:
> > 
> > > On Fri 15-04-16 08:29:28, Mikulas Patocka wrote:
> > > > 
> > > > 
> > > > On Mon, 11 Apr 2016, Michal Hocko wrote:
> > > > 
> > > > > From: Michal Hocko <mhocko@suse.com>
> > > > > 
> > > > > copy_params seems to be little bit confused about which allocation flags
> > > > > to use. It enforces GFP_NOIO even though it uses
> > > > > memalloc_noio_{save,restore} which enforces GFP_NOIO at the page
> > > > 
> > > > memalloc_noio_{save,restore} is used because __vmalloc is flawed and 
> > > > doesn't respect GFP_NOIO properly (it doesn't use gfp flags when 
> > > > allocating pagetables).
> > > 
> > > Yes and there are no plans to change __vmalloc to properly propagate gfp
> > > flags through the whole call chain and that is why we have
> > > memalloc_noio thingy. If that ever changes later the GFP_NOIO can be
> > > added in favor of memalloc_noio API. Both are clearly redundant.
> > > -- 
> > > Michal Hocko
> > > SUSE Labs
> > 
> > You could move memalloc_noio_{save,restore} to __vmalloc. Something like
> > 
> > if (!(gfp_mask & __GFP_IO))
> > 	noio_flag = memalloc_noio_save();
> > ...
> > if (!(gfp_mask & __GFP_IO))
> > 	memalloc_noio_restore(noio_flag);
> > 
> > That would be better than repeating this hack in every __vmalloc caller 
> > that need GFP_NOIO.
> 
> It is not my intention to change __vmalloc behavior. If you strongly
> oppose the GFP_NOIO change I can drop it from the patch. It is
> __GFP_REPEAT which I am after.

I am dropping the GFP_NOIO part for this patch but now that I am looking
into the code more closely I completely fail why it is needed in the
first place.

copy_params seems to be called only from the ioctl context which doesn't
hold any locks which would lockup during the direct reclaim AFAICS. The
git log shows that the code has used PF_MEMALLOC before which is even
bigger mystery to me. Could you please clarify why this is GFP_NOIO
restricted context? Maybe it needed to be in the past but I do not see
any reason for it to be now so unless I am missing something the
GFP_KERNEL should be perfectly OK. Also note that GFP_NOIO wouldn't work
properly because there are copy_from_user calls in the same path which
could page fault and do GFP_KERNEL allocations anyway. I can send follow
up cleanups unless I am missing something subtle here.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
