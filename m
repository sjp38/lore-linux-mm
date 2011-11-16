Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B0E236B0069
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 02:22:17 -0500 (EST)
Message-ID: <4EC36494.30803@redhat.com>
Date: Wed, 16 Nov 2011 15:21:56 +0800
From: Cong Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [Patch] tmpfs: add fallocate support
References: <1321346525-10187-1-git-send-email-amwang@redhat.com>	 <4EC23DB0.3020306@redhat.com> <1321379039.12374.11.camel@nimitz>
In-Reply-To: <1321379039.12374.11.camel@nimitz>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Lennart Poettering <lennart@poettering.net>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

ao? 2011a1'11ae??16ae?JPY 01:43, Dave Hansen a??e??:
> On Tue, 2011-11-15 at 18:23 +0800, Cong Wang wrote:
>>> +static long shmem_fallocate(struct file *file, int mode,
>>> +			    loff_t offset, loff_t len)
>>> +{
>>> +	struct inode *inode = file->f_path.dentry->d_inode;
>>> +	struct address_space *mapping = inode->i_mapping;
>>> +	struct shmem_inode_info *info = SHMEM_I(inode);
>>> +	struct shmem_sb_info *sbinfo = SHMEM_SB(inode->i_sb);
>>> +	pgoff_t start = DIV_ROUND_UP(offset, PAGE_CACHE_SIZE);
>>> +	pgoff_t end = DIV_ROUND_UP((offset + len), PAGE_CACHE_SIZE);
>>> +	pgoff_t index = start;
>>> +	gfp_t gfp = mapping_gfp_mask(mapping);
>>> +	loff_t i_size = i_size_read(inode);
>>> +	struct page *page = NULL;
>>> +	int ret;
>>> +
>>> +	if ((offset + len)<= i_size)
>>> +		return 0;
>
> This seems to say that if the fallocate() call ends before the end of
> the file we should ignore the call.  In other words, this can only be
> used to extend the file, but could not be used to fill in the holes of a
> sparse file.
>
> Is there a reason it was done that way?

Hmm, I missed the case of sparse file, so you are right, I need to fix it.

>
>>> +	if (!(mode&   FALLOC_FL_KEEP_SIZE)) {
>>> +		ret = inode_newsize_ok(inode, (offset + len));
>>> +		if (ret)
>>> +			return ret;
>>> +	}
>
> inode_newsize_ok()'s comments say:
>
>   * inode_newsize_ok must be called with i_mutex held.
>
> But I don't see any trace of it.
>

Hmm, even for tmpfs? I see none of the tmpfs code takes
i_mutex lock though...

>>> +	if (start == end) {
>>> +		if (!(mode&   FALLOC_FL_KEEP_SIZE))
>>> +			i_size_write(inode, offset + len);
>>> +		return 0;
>>> +	}
>
> There's a whitespace borkage like that 'mode&' all over this patch.
> Probably needs a little love.

Odd, it is fine in my local patch, and it passed checkpatch.pl
check before I sent it.

<...>	
>
> This seems to have borrowed quite generously from shmem_getpage_gfp().
> Seems like some code consolidation is in order before this level of
> copy-n-paste.

Yes, I will separate the similar code.

Thanks for review!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
