Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 522EF6B02B4
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 15:05:55 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id p17so2576605wmd.5
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 12:05:55 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id f27si7484731edj.350.2017.08.15.12.05.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Aug 2017 12:05:54 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id A0D231C150E
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 20:05:53 +0100 (IST)
Date: Tue, 15 Aug 2017 20:05:52 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 2/2] mm: Update NUMA counter threshold size
Message-ID: <20170815190552.ctigm5q5nd4r3z76@techsingularity.net>
References: <1502786736-21585-1-git-send-email-kemi.wang@intel.com>
 <1502786736-21585-3-git-send-email-kemi.wang@intel.com>
 <20170815095819.5kjh4rrhkye3lgf2@techsingularity.net>
 <a258ea24-6830-4907-0165-fec17ccb7f9f@linux.intel.com>
 <20170815173050.xn5ffrsvdj4myoam@techsingularity.net>
 <6f58040a-d273-cbd3-98ac-679add61c337@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <6f58040a-d273-cbd3-98ac-679add61c337@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Kemi Wang <kemi.wang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Tue, Aug 15, 2017 at 10:51:21AM -0700, Tim Chen wrote:
> On 08/15/2017 10:30 AM, Mel Gorman wrote:
> > On Tue, Aug 15, 2017 at 09:55:39AM -0700, Tim Chen wrote:
> 
> >>
> >> Doubling the threshold and counter size will help, but not as much
> >> as making them above u8 limit as seen in Kemi's data:
> >>
> >>       125         537         358906028 <==> system by default (base)
> >>       256         468         412397590
> >>       32765       394(-26.6%) 488932078(+36.2%) <==> with this patchset
> >>
> >> For small system making them u8 makes sense.  For larger ones the
> >> frequent local counter overflow into the global counter still
> >> causes a lot of cache bounce.  Kemi can perhaps collect some data
> >> to see what is the gain from making the counters u8. 
> >>
> > 
> > The same comments hold. The increase of a cache line is undesirable but
> > there are other places where the overall cost can be reduced by special
> > casing based on how this counter is used (always incrementing by one).
> 
> Can you be more explicit of what optimization you suggest here and changes
> to inc/dec_zone_page_state?  Seems to me like we will still overflow
> the local counter with the same frequency unless the threshold and
> counter size is changed.

One of the helpers added is __inc_zone_numa_state which doesn't have a
symmetrical __dec_zone_numa_state because the counter is always
incrementing. Because of this, there is little or no motivation to
update the global value by threshold >> 1 because with both inc/dec, you
want to avoid a corner case whereby a loop of inc/dec would do an
overflow every time. Instead, you can always apply the full threshold
and clear it which is fewer operations and halves the frequency at which
the global value needs to be updated.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
