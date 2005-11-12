Date: Fri, 11 Nov 2005 16:34:00 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] 2.6.14 patch for supporting madvise(MADV_REMOVE)
Message-Id: <20051111163400.580dd0b8.akpm@osdl.org>
In-Reply-To: <1130947957.24503.70.camel@localhost.localdomain>
References: <1130366995.23729.38.camel@localhost.localdomain>
	<20051028034616.GA14511@ccure.user-mode-linux.org>
	<43624F82.6080003@us.ibm.com>
	<20051028184235.GC8514@ccure.user-mode-linux.org>
	<1130544201.23729.167.camel@localhost.localdomain>
	<20051029025119.GA14998@ccure.user-mode-linux.org>
	<1130788176.24503.19.camel@localhost.localdomain>
	<20051101000509.GA11847@ccure.user-mode-linux.org>
	<1130894101.24503.64.camel@localhost.localdomain>
	<20051102014321.GG24051@opteron.random>
	<1130947957.24503.70.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: andrea@suse.de, linux-kernel@vger.kernel.org, hugh@veritas.com, dvhltc@us.ibm.com, linux-mm@kvack.org, blaisorblade@yahoo.it, jdike@addtoit.com
List-ID: <linux-mm.kvack.org>

Badari Pulavarty <pbadari@us.ibm.com> wrote:
>
> +int vmtruncate_range(struct inode * inode, loff_t offset, loff_t end)
>  +{
>  +	struct address_space *mapping = inode->i_mapping;
>  +
>  +	/*
>  +	 * If the underlying filesystem is not going to provide 
>  +	 * a way to truncate a range of blocks (punch a hole) - 
>  +	 * we should return failure right now.
>  +	 */
>  +	if (!inode->i_op || !inode->i_op->truncate_range)
>  +		return -ENOSYS;
>  +		
>  +	/* XXX - Do we need both i_sem and i_allocsem all the way ? */
>  +	down(&inode->i_sem);
>  +	down_write(&inode->i_alloc_sem);
>  +	unmap_mapping_range(mapping, offset, (end - offset), 1);
>  +	truncate_inode_pages_range(mapping, offset, end);
>  +	inode->i_op->truncate_range(inode, offset, end);
>  +	up_write(&inode->i_alloc_sem);
>  +	up(&inode->i_sem);
>  +
>  +	return 0;
>  +}

Yes, we need to take i_alloc_sem for writing.  To prevent concurrent
direct-io reads from coming in and instantiated by unwritten blocks.

tmpfs doesn't implements direct-io though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
