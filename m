Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 569716B0003
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 18:18:58 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id t10-v6so3950996plh.14
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 15:18:58 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n2-v6si5885069plk.255.2018.10.24.15.18.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Oct 2018 15:18:57 -0700 (PDT)
Date: Wed, 24 Oct 2018 15:18:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH] mm: don't reclaim inodes with many attached pages
Message-Id: <20181024151853.3edd9097400b0d52edff1f16@linux-foundation.org>
In-Reply-To: <20181023164302.20436-1-guro@fb.com>
References: <20181023164302.20436-1-guro@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, Michal Hocko <mhocko@kernel.org>, Rik van Riel <riel@surriel.com>, Randy Dunlap <rdunlap@infradead.org>

On Tue, 23 Oct 2018 16:43:29 +0000 Roman Gushchin <guro@fb.com> wrote:

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
> 
> ...
>
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
>  		inode->i_state &= ~I_REFERENCED;
>  		spin_unlock(&inode->i_lock);
>  		return LRU_ROTATE;

hm, why "1"?

I guess one could argue that this will encompass long symlinks, but I
just made that up to make "1" appear more justifiable ;) 
