Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 40E946B0253
	for <linux-mm@kvack.org>; Tue, 18 Aug 2015 06:55:49 -0400 (EDT)
Received: by wijp15 with SMTP id p15so97090834wij.0
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 03:55:48 -0700 (PDT)
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com. [209.85.212.172])
        by mx.google.com with ESMTPS id lg1si32846238wjc.136.2015.08.18.03.55.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Aug 2015 03:55:48 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so91974864wic.0
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 03:55:47 -0700 (PDT)
Date: Tue, 18 Aug 2015 12:55:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC -v2 5/8] ext4: Do not fail journal due to block allocator
Message-ID: <20150818105545.GH5033@dhcp22.suse.cz>
References: <1438768284-30927-1-git-send-email-mhocko@kernel.org>
 <1438768284-30927-6-git-send-email-mhocko@kernel.org>
 <20150818103903.GD5033@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150818103903.GD5033@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, Jan Kara <jack@suse.cz>

On Tue 18-08-15 12:39:03, Michal Hocko wrote:
[...]
> @@ -992,9 +992,8 @@ static int ext4_mb_get_buddy_page_lock(struct super_block *sb,
>  	block = group * 2;
>  	pnum = block / blocks_per_page;
>  	poff = block % blocks_per_page;
> -	page = find_or_create_page(inode->i_mapping, pnum, GFP_NOFS);
> -	if (!page)
> -		return -ENOMEM;
> +	page = find_or_create_page(inode->i_mapping, pnum,
> +				   GFP_NOFS|__GFP_NOFAIL);

Scratch this one. find_or_create_page is allowed to return NULL. The
patch is bogus. I was overly eager to turn all places to not check the
return value.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
