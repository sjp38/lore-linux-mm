Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0F9136B0005
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 04:08:42 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id g62so22760833wme.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 01:08:42 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id in5si8642117wjb.155.2016.02.25.01.08.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 01:08:41 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id a4so2244479wme.3
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 01:08:40 -0800 (PST)
Date: Thu, 25 Feb 2016 10:08:39 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC] ext4: use __GFP_NOFAIL in ext4_free_blocks()
Message-ID: <20160225090839.GC17573@dhcp22.suse.cz>
References: <20160224170912.2195.8153.stgit@buzz>
 <56CEC2EC.5000506@kyup.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56CEC2EC.5000506@kyup.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikolay Borisov <kernel@kyup.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Theodore Ts'o <tytso@mit.edu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dmitry Monakhov <dmonakhov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org

On Thu 25-02-16 11:01:32, Nikolay Borisov wrote:
> 
> 
> On 02/24/2016 07:09 PM, Konstantin Khlebnikov wrote:
> > This might be unexpected but pages allocated for sbi->s_buddy_cache are
> > charged to current memory cgroup. So, GFP_NOFS allocation could fail if
> > current task has been killed by OOM or if current memory cgroup has no
> > free memory left. Block allocator cannot handle such failures here yet.
> > 
> > Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> 
> Adding new users of GFP_NOFAIL is deprecated.

This is not true. GFP_NOFAIL should be used where the allocation failure
is no tolleratable and it is much more preferrable to doing an opencoded
endless loop over page allocator.

> Where exactly does the
> block allocator fail, I skimmed the code and failing ext4_mb_load_buddy
> seems to be handled at all call sites. There are some BUG_ONs but from
> the comments there I guess they should occur when we try to find a page
> and not allocate a new one?

I have posted a similar patch last year:
http://lkml.kernel.org/r/1438768284-30927-6-git-send-email-mhocko@kernel.org
because I could see emergency reboots when GFP_NOFS allocations were
allowed to fail.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
