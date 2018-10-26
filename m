Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id BE3286B02E7
	for <linux-mm@kvack.org>; Fri, 26 Oct 2018 04:57:51 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b34-v6so326327edb.3
        for <linux-mm@kvack.org>; Fri, 26 Oct 2018 01:57:51 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a18-v6si1440204ejj.161.2018.10.26.01.57.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Oct 2018 01:57:50 -0700 (PDT)
Date: Fri, 26 Oct 2018 10:57:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm: don't reclaim inodes with many attached pages
Message-ID: <20181026085735.GZ18839@dhcp22.suse.cz>
References: <20181023164302.20436-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181023164302.20436-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, Rik van Riel <riel@surriel.com>, Randy Dunlap <rdunlap@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, dairinin@gmail.com

Spock doesn't seem to be cced here - fixed now

On Tue 23-10-18 16:43:29, Roman Gushchin wrote:
> Spock reported that the commit 172b06c32b94 ("mm: slowly shrink slabs
> with a relatively small number of objects") leads to a regression on
> his setup: periodically the majority of the pagecache is evicted
> without an obvious reason, while before the change the amount of free
> memory was balancing around the watermark.
> 
> The reason behind is that the mentioned above change created some
> minimal background pressure on the inode cache. The problem is that
> if an inode is considered to be reclaimed, all belonging pagecache
> page are stripped, no matter how many of them are there. So, if a huge
> multi-gigabyte file is cached in the memory, and the goal is to
> reclaim only few slab objects (unused inodes), we still can eventually
> evict all gigabytes of the pagecache at once.
> 
> The workload described by Spock has few large non-mapped files in the
> pagecache, so it's especially noticeable.
> 
> To solve the problem let's postpone the reclaim of inodes, which have
> more than 1 attached page. Let's wait until the pagecache pages will
> be evicted naturally by scanning the corresponding LRU lists, and only
> then reclaim the inode structure.

Has this actually fixed/worked around the issue?

> Reported-by: Spock <dairinin@gmail.com>
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Rik van Riel <riel@surriel.com>
> Cc: Randy Dunlap <rdunlap@infradead.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>  fs/inode.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/inode.c b/fs/inode.c
> index 73432e64f874..0cd47fe0dbe5 100644
> --- a/fs/inode.c
> +++ b/fs/inode.c
> @@ -730,8 +730,11 @@ static enum lru_status inode_lru_isolate(struct list_head *item,
>  		return LRU_REMOVED;
>  	}
>  
> -	/* recently referenced inodes get one more pass */
> -	if (inode->i_state & I_REFERENCED) {
> +	/*
> +	 * Recently referenced inodes and inodes with many attached pages
> +	 * get one more pass.
> +	 */
> +	if (inode->i_state & I_REFERENCED || inode->i_data.nrpages > 1) {

The comment is just confusing. Did you mean to say s@many@any@ ?

>  		inode->i_state &= ~I_REFERENCED;
>  		spin_unlock(&inode->i_lock);
>  		return LRU_ROTATE;
> -- 
> 2.17.2

-- 
Michal Hocko
SUSE Labs
