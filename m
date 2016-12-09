Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2E7016B026A
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 01:51:58 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id xr1so3404999wjb.7
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 22:51:58 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id xw10si32657800wjb.253.2016.12.08.22.51.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 22:51:56 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id u144so1911507wmu.0
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 22:51:56 -0800 (PST)
Date: Fri, 9 Dec 2016 07:51:54 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm: introduce kv[mz]alloc helpers
Message-ID: <20161209065154.GD12012@dhcp22.suse.cz>
References: <20161208103300.23217-1-mhocko@kernel.org>
 <20161209014417.GN4326@dastard>
 <20161209020016.GX1555@ZenIV.linux.org.uk>
 <20161209062224.GB12012@dhcp22.suse.cz>
 <20161209063803.GY1555@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161209063803.GY1555@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Anatoly Stepanov <astepanov@cloudlinux.com>, LKML <linux-kernel@vger.kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, "Michael S. Tsirkin" <mst@redhat.com>, Theodore Ts'o <tytso@mit.edu>, kvm@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-security-module@vger.kernel.org

On Fri 09-12-16 06:38:04, Al Viro wrote:
> On Fri, Dec 09, 2016 at 07:22:25AM +0100, Michal Hocko wrote:
> 
> > > Easier to handle those in vmalloc() itself.
> > 
> > I think there were some attempts in the past but some of the code paths
> > are burried too deep and adding gfp_mask all the way down there seemed
> > like a major surgery.
> 
> No need to propagate gfp_mask - the same trick XFS is doing right now can
> be done in vmalloc.c in a couple of places and that's it; I'll resurrect the
> patches and post them tomorrow after I get some sleep.

That would work as an immediate mitigation. No question about that but
what I've tried to point out in the reply to Dave is that longerm we
shouldn't hide this trickiness inside the vmalloc and rather handle
those users who are requesting NOFS/NOIO context from vmalloc. We
already have a scope api for NOIO and I want to add the same for NOFS.
I believe that much more sane approach is to use the API at those places
which really start/stop reclaim recursion dangerous scope (e.g. the
transaction context) rather than using GFP_NOFS randomly because this
approach has proven to not work properly over years. We have so many
place using GFP_NOFS just because nobody bothered to think whether it is
needed but it must be safe for sure that it is not funny.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
