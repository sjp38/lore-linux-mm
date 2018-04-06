Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9A4A26B0006
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 04:07:17 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id b9so221545wrj.15
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 01:07:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j49si6708858wra.297.2018.04.06.01.07.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 Apr 2018 01:07:16 -0700 (PDT)
Date: Fri, 6 Apr 2018 10:07:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] writeback: safer lock nesting
Message-ID: <20180406080714.GG8286@dhcp22.suse.cz>
References: <2cb713cd-0b9b-594c-31db-b4582f8ba822@meituan.com>
 <20180406080324.160306-1-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180406080324.160306-1-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Wang Long <wanglong19@meituan.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, npiggin@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 06-04-18 01:03:24, Greg Thelen wrote:
[...]
> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index d4d04fee568a..d51bae5a53e2 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -746,10 +746,11 @@ int inode_congested(struct inode *inode, int cong_bits)
>  	if (inode && inode_to_wb_is_valid(inode)) {
>  		struct bdi_writeback *wb;
>  		bool locked, congested;
> +		unsigned long flags;
>  
> -		wb = unlocked_inode_to_wb_begin(inode, &locked);
> +		wb = unlocked_inode_to_wb_begin(inode, &locked, &flags);

Wouldn't it be better to have a cookie (struct) rather than 2 parameters
and let unlocked_inode_to_wb_end DTRT?

>  		congested = wb_congested(wb, cong_bits);
> -		unlocked_inode_to_wb_end(inode, locked);
> +		unlocked_inode_to_wb_end(inode, locked, flags);
>  		return congested;
>  	}
-- 
Michal Hocko
SUSE Labs
