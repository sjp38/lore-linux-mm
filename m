Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id 50F0D6B0038
	for <linux-mm@kvack.org>; Wed,  7 Jan 2015 04:21:33 -0500 (EST)
Received: by mail-we0-f175.google.com with SMTP id k11so785679wes.20
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 01:21:32 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 8si2363195wjx.166.2015.01.07.01.21.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 Jan 2015 01:21:32 -0800 (PST)
Message-ID: <54ACFA9A.8000405@suse.cz>
Date: Wed, 07 Jan 2015 10:21:30 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH V4 3/4] mm: reduce try_to_compact_pages parameters
References: <1420478263-25207-1-git-send-email-vbabka@suse.cz> <1420478263-25207-4-git-send-email-vbabka@suse.cz> <20150106145710.GD20860@dhcp22.suse.cz> <54ACF851.3040002@suse.cz> <20150107091813.GA16553@dhcp22.suse.cz>
In-Reply-To: <20150107091813.GA16553@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Minchan Kim <minchan@kernel.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 01/07/2015 10:18 AM, Michal Hocko wrote:
> On Wed 07-01-15 10:11:45, Vlastimil Babka wrote:
>> On 01/06/2015 03:57 PM, Michal Hocko wrote:
>> > Hmm, wait a minute
>> > 
>> > On Mon 05-01-15 18:17:42, Vlastimil Babka wrote:
>> > [...]
>> >> -unsigned long try_to_compact_pages(struct zonelist *zonelist,
>> >> -			int order, gfp_t gfp_mask, nodemask_t *nodemask,
>> >> -			enum migrate_mode mode, int *contended,
>> >> -			int alloc_flags, int classzone_idx)
>> >> +unsigned long try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
>> >> +			int alloc_flags, const struct alloc_context *ac,
>> >> +			enum migrate_mode mode, int *contended)
>> >>  {
>> >> -	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
>> >>  	int may_enter_fs = gfp_mask & __GFP_FS;
>> >>  	int may_perform_io = gfp_mask & __GFP_IO;
>> >>  	struct zoneref *z;
>> > 
>> > gfp_mask might change since the high_zoneidx was set up in the call
>> > chain. I guess this shouldn't change to the gfp_zone output but it is
>> > worth double checking.
>> 
>> Yeah I checked that. gfp_zone() operates just on GFP_ZONEMASK part of the flags,
>> and we don't change that.
> 
> That was my understanding as well. Maybe we want
> VM_BUG_ON(gfp_zone(gfp_mask) != ac->high_zoneidx);

That sounds like an arbitrary overkill to me. I think that gfp_zone() was just
used here to save an extra parameter.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
