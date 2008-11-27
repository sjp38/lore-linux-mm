Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mARB2XEx009707
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 27 Nov 2008 20:02:33 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5602A45DD72
	for <linux-mm@kvack.org>; Thu, 27 Nov 2008 20:02:33 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A96445DE4E
	for <linux-mm@kvack.org>; Thu, 27 Nov 2008 20:02:33 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 21D061DB803E
	for <linux-mm@kvack.org>; Thu, 27 Nov 2008 20:02:33 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id CACFBE08001
	for <linux-mm@kvack.org>; Thu, 27 Nov 2008 20:02:32 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 2/2] fs: symlink write_begin allocation context fix
In-Reply-To: <20081127093504.GF28285@wotan.suse.de>
References: <20081127093401.GE28285@wotan.suse.de> <20081127093504.GF28285@wotan.suse.de>
Message-Id: <20081127200014.3CF6.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 27 Nov 2008 20:02:32 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> -int __page_symlink(struct inode *inode, const char *symname, int len,
> -		gfp_t gfp_mask)
> +/*
> + * The nofs argument instructs pagecache_write_begin to pass AOP_FLAG_NOFS
> + */
> +int __page_symlink(struct inode *inode, const char *symname, int len, int nofs)
>  {
>  	struct address_space *mapping = inode->i_mapping;
>  	struct page *page;
>  	void *fsdata;
>  	int err;
>  	char *kaddr;
> +	unsigned int flags = AOP_FLAG_UNINTERRUPTIBLE;
> +	if (nofs)
> +		flags |= AOP_FLAG_NOFS;
>  
>  retry:
>  	err = pagecache_write_begin(NULL, mapping, 0, len-1,
> -				AOP_FLAG_UNINTERRUPTIBLE, &page, &fsdata);
> +				flags, &page, &fsdata);
>  	if (err)
>  		goto fail;
>  
> @@ -2820,8 +2825,7 @@ fail:
>  
>  int page_symlink(struct inode *inode, const char *symname, int len)
>  {
> -	return __page_symlink(inode, symname, len,
> -			mapping_gfp_mask(inode->i_mapping));
> +	return __page_symlink(inode, symname, len, 0);
>  }

your patch always pass 0 into __page_symlink().
therefore it doesn't change any behavior.

right?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
