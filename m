Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 930476B0071
	for <linux-mm@kvack.org>; Wed,  6 May 2015 03:12:51 -0400 (EDT)
Received: by widdi4 with SMTP id di4so11085902wid.0
        for <linux-mm@kvack.org>; Wed, 06 May 2015 00:12:51 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id op8si32484688wjc.112.2015.05.06.00.12.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 06 May 2015 00:12:50 -0700 (PDT)
Date: Wed, 6 May 2015 08:12:46 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/13] Parallel struct page initialisation v4
Message-ID: <20150506071246.GF2462@suse.de>
References: <1430231830-7702-1-git-send-email-mgorman@suse.de>
 <554030D1.8080509@hp.com>
 <5543F802.9090504@hp.com>
 <554415B1.2050702@hp.com>
 <20150504143046.9404c572486caf71bdef0676@linux-foundation.org>
 <20150505104514.GC2462@suse.de>
 <20150505130255.49ff76bbf0a3b32d884ab2ce@linux-foundation.org>
 <20150505221329.GE2462@suse.de>
 <20150505152549.037679566fad8c593df176ed@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150505152549.037679566fad8c593df176ed@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Waiman Long <waiman.long@hp.com>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, May 05, 2015 at 03:25:49PM -0700, Andrew Morton wrote:
> On Tue, 5 May 2015 23:13:29 +0100 Mel Gorman <mgorman@suse.de> wrote:
> 
> > > Alternatively, the page allocator can go off and synchronously
> > > initialize some pageframes itself.  Keep doing that until the
> > > allocation attempt succeeds.
> > > 
> > 
> > That was rejected during review of earlier attempts at this feature on
> > the grounds that it impacted allocator fast paths. 
> 
> eh?  Changes are only needed on the allocation-attempt-failed path,
> which is slow-path.

We'd have to distinguish between falling back to other zones because the
high zone is artifically exhausted and normal ALLOC_BATCH exhaustion. We'd
also have to avoid falling back to remote nodes prematurely. While I have
not tried an implementation, I expected they would need to be in the fast
paths unless I used jump labels to get around it. I'm going to try altering
when we initialise instead so that it happens earlier.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
