Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id D81976B0005
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 05:27:46 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id g62so25507576wme.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 02:27:46 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id z2si3328172wmz.40.2016.02.25.02.27.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 02:27:45 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id c200so2617181wme.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 02:27:45 -0800 (PST)
Date: Thu, 25 Feb 2016 11:27:44 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC] ext4: use __GFP_NOFAIL in ext4_free_blocks()
Message-ID: <20160225102743.GF17573@dhcp22.suse.cz>
References: <20160224170912.2195.8153.stgit@buzz>
 <56CEC2EC.5000506@kyup.com>
 <20160225090839.GC17573@dhcp22.suse.cz>
 <56CEC568.6080809@kyup.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56CEC568.6080809@kyup.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikolay Borisov <kernel@kyup.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Theodore Ts'o <tytso@mit.edu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dmitry Monakhov <dmonakhov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org

On Thu 25-02-16 11:12:08, Nikolay Borisov wrote:
> 
> 
> On 02/25/2016 11:08 AM, Michal Hocko wrote:
> > On Thu 25-02-16 11:01:32, Nikolay Borisov wrote:
> >>
> >>
> >> On 02/24/2016 07:09 PM, Konstantin Khlebnikov wrote:
> >>> This might be unexpected but pages allocated for sbi->s_buddy_cache are
> >>> charged to current memory cgroup. So, GFP_NOFS allocation could fail if
> >>> current task has been killed by OOM or if current memory cgroup has no
> >>> free memory left. Block allocator cannot handle such failures here yet.
> >>>
> >>> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> >>
> >> Adding new users of GFP_NOFAIL is deprecated.
> > 
> > This is not true. GFP_NOFAIL should be used where the allocation failure
> > is no tolleratable and it is much more preferrable to doing an opencoded
> > endless loop over page allocator.
> 
> In that case the comments in buffered_rmqueue,

yes, will post the patch. The warning for order > 1 is still valid.

> and the WARN_ON in
> __alloc_pages_may_oom and __alloc_pages_slowpath perhaps should be
> removed since they are misleading?

We are only warning about absurd cases where __GFP_NOFAIL doesn't make
any sense.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
