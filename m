Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D8BD76B01AD
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 21:41:51 -0400 (EDT)
Received: by pwi7 with SMTP id 7so293330pwi.14
        for <linux-mm@kvack.org>; Wed, 09 Jun 2010 18:41:50 -0700 (PDT)
Message-ID: <4C1042E0.8080403@vflare.org>
Date: Thu, 10 Jun 2010 07:11:52 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: [PATCH V2 2/7] Cleancache (was Transcendent Memory): core files
References: <20100528173550.GA12219@ca-server1.us.oracle.com>
In-Reply-To: <20100528173550.GA12219@ca-server1.us.oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com, konrad.wilk@oracle.com
List-ID: <linux-mm.kvack.org>

Hi,

On 05/28/2010 11:05 PM, Dan Magenheimer wrote:
> [PATCH V2 2/7] Cleancache (was Transcendent Memory): core files

I just finished a rough (but working) implementation of in-kernel
page cache compression backend (called zcache). During this work,
I found some issues with cleancache, mostly related to (lack of)
comments/documentation:


> +
> +static inline int cleancache_init_fs(size_t pagesize)
> +

 - It is not very obvious that this function is called when
an instance of cleancache supported filesystem is *mounted*.
Initially, I thought this is called which any such filesystem
module is loaded.

 - It seems that returning pool_id of 0 is considered as error
condition (as it appears from deactivate_locked_super() changes). 
This seems weird; I think only negative pool_id should considered
as error. Anyway, please add function comments for these.

> +int __cleancache_get_page(struct page *page)
> +{
> +	int ret = 0;
> +	int pool_id = page->mapping->host->i_sb->cleancache_poolid;
> +
> +	if (pool_id >= 0) {
> +		ret = (*cleancache_ops->get_page)(pool_id,
> +						  page->mapping->host->i_ino,
> +						  page->index,
> +						  page);
> +		if (ret == CLEANCACHE_GET_PAGE_SUCCESS)
> +			succ_gets++;
> +		else
> +			failed_gets++;
> +	}
> +	return ret;
> +}

It seems "non-standard" to use '1' as success code. You could simply use
0 for success and negative error code as failure. Then you can also get
rid of CLEANCACHE_GET_PAGE_SUCCESS.

> +
> +int __cleancache_put_page(struct page *page)

What return values stands for successful put? 1? Anyway, following the
same, 0 for success, negative codes for errors, seems to be better.

> +
> +int __cleancache_flush_page(struct address_space *mapping, struct page *page)

> +int __cleancache_flush_inode(struct address_space *mapping)

Return values for all the flush functions is ignored everywhere, so
why not make them return void instead?

> +static inline void cleancache_flush_fs(int pool_id)

Like init_fs, please document that it is called when a cleancache
aware filesystem is unmounted (or in other cases too?).



Page cache compression was a long-pending project. I'm glad its
coming into shape with the help of cleancache :)

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
