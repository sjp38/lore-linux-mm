Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D3A366B004D
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 19:25:34 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n53NMbdo021897
	for <linux-mm@kvack.org>; Wed, 3 Jun 2009 17:22:37 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n53NPWf6262150
	for <linux-mm@kvack.org>; Wed, 3 Jun 2009 17:25:32 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n53NPUSV022095
	for <linux-mm@kvack.org>; Wed, 3 Jun 2009 17:25:32 -0600
Subject: Re: [PATCH 23/23] vfs: Teach readahead to use the file_hotplug_lock
From: Badari Pulavarty <pbadari@gmail.com>
In-Reply-To: <1243893048-17031-23-git-send-email-ebiederm@xmission.com>
References: <m1oct739xu.fsf@fess.ebiederm.org>
	 <1243893048-17031-23-git-send-email-ebiederm@xmission.com>
Content-Type: text/plain
Date: Wed, 03 Jun 2009 16:25:29 -0700
Message-Id: <1244071529.6383.11.camel@badari-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Eric W. Biederman" <ebiederm@maxwell.aristanetworks.com>, "Eric W. Biederman" <ebiederm@aristanetworks.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-06-01 at 14:50 -0700, Eric W. Biederman wrote:
> From: Eric W. Biederman <ebiederm@maxwell.aristanetworks.com>
> 
> Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
> ---
>  mm/filemap.c |   25 ++++++++++++++++---------
>  1 files changed, 16 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 379ff0b..5016aa5 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1402,16 +1402,23 @@ SYSCALL_DEFINE(readahead)(int fd, loff_t offset, size_t count)
>  
>  	ret = -EBADF;
>  	file = fget(fd);
> -	if (file) {
> -		if (file->f_mode & FMODE_READ) {
> -			struct address_space *mapping = file->f_mapping;
> -			pgoff_t start = offset >> PAGE_CACHE_SHIFT;
> -			pgoff_t end = (offset + count - 1) >> PAGE_CACHE_SHIFT;
> -			unsigned long len = end - start + 1;
> -			ret = do_readahead(mapping, file, start, len);
> -		}
> -		fput(file);
> +	if (!file)
> +		goto out;
> +
> +	if (!(file->f_mode & FMODE_READ))
> +		goto out_fput;
> +

To be consistent with others, don't you want to do
	  ret = -EIO;
here ?
> +	if (file_hotplug_read_trylock(file)) {
> +		struct address_space *mapping = file->f_mapping;
> +		pgoff_t start = offset >> PAGE_CACHE_SHIFT;
> +		pgoff_t end = (offset + count - 1) >> PAGE_CACHE_SHIFT;
> +		unsigned long len = end - start + 1;
> +		ret = do_readahead(mapping, file, start, len);
> +		file_hotplug_read_unlock(file);
>  	}
> +out_fput:
> +	fput(file);
> +out:
>  	return ret;
>  }
>  #ifdef CONFIG_HAVE_SYSCALL_WRAPPERS

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
