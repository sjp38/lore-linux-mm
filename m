Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8C0236B0253
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 08:27:31 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 4so21762372pge.8
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 05:27:31 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m1si18023649pgq.230.2017.11.24.05.27.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Nov 2017 05:27:30 -0800 (PST)
Date: Fri, 24 Nov 2017 14:27:24 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm:Add watermark slope for high mark
Message-ID: <20171124132724.vkxh74bvx6n7f5wm@dhcp22.suse.cz>
References: <20171124100707.24190-1-peter.enderborg@sony.com>
 <20171124101457.by7eoblmk357jwnz@dhcp22.suse.cz>
 <3ff0a870-4a0e-3b8a-ecfd-3db4c6bbd695@sony.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3ff0a870-4a0e-3b8a-ecfd-3db4c6bbd695@sony.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peter enderborg <peter.enderborg@sony.com>
Cc: linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, "Luis R . Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Alex Deucher <alexander.deucher@amd.com>, "David S . Miller" <davem@davemloft.net>, Harry Wentland <Harry.Wentland@amd.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Tony Cheng <Tony.Cheng@amd.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Dave Jiang <dave.jiang@intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Vlastimil Babka <vbabka@suse.cz>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Nikolay Borisov <nborisov@suse.com>, Mel Gorman <mgorman@suse.de>, Pavel Tatashin <pasha.tatashin@oracle.com>, Linux API <linux-api@vger.kernel.org>

On Fri 24-11-17 14:12:56, peter enderborg wrote:
> On 11/24/2017 11:14 AM, Michal Hocko wrote:
> > On Fri 24-11-17 11:07:07, Peter Enderborg wrote:
> >> When tuning the watermark_scale_factor to reduce stalls and compactions
> >> the high mark is also changed, it changed a bit too much. So this
> >> patch introduces a slope that can reduce this overhead a bit, or
> >> increase it if needed.
> > This doesn't explain what is the problem, why it is a problem and why we
> > need yet another tuning to address it. Users shouldn't really care about
> > internal stuff like watermark tuning for each watermark independently.
> > This looks like a gross hack. Please start over with the problem
> > description and then we can move on to an approapriate fix. Piling up
> > tuning knobs to workaround problems is simply not acceptable.
> >  
> 
> In the original patch - https://lkml.org/lkml/2016/2/18/498 - had a
> 
> discussion about small systems with 8GB RAM. In the handheld world, that's
> a lot of RAM. However, the magic number 2 used in the present algorithm
> is out of the blue. Compaction problems are the same for both small and
> big. So small devices also need to increase watermark to
> get compaction to work and reduce direct reclaims. Changing the low watermark
> makes direct reclaim rate drop a lot. But it will cause kswap to work more,
> and that has a negative impact. Lowering the gap will smooth out the kswap
> workload to suite embedded devices a lot better. This can be addressed by
> reducing the high watermark using the slope patch herein. Im sort of understand
> your opinion on user knobs, but hard-coded magic numbers are even worse.

How can a poor user know how to tune it when _we_ cannot do a qualified
guess and we do know all the implementation details.

Really, describe problems you are seeing with the current code and we
can talk about a proper fix or a heuristic when the fix is
hard/unfeasible.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
