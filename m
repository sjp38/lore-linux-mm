Subject: Re: [PATCH]fix page release issue in filemap_fault
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <3d0408630710080828h7ad160dbxf6cbd8513c1ad3e8@mail.gmail.com>
References: <3d0408630710080828h7ad160dbxf6cbd8513c1ad3e8@mail.gmail.com>
Content-Type: text/plain
Date: Mon, 08 Oct 2007 19:15:23 +0200
Message-Id: <1191863723.20745.26.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yan Zheng <yanzheng@21cn.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, 2007-10-08 at 23:28 +0800, Yan Zheng wrote:
> Hi all
> 
> find_lock_page increases page's usage count, we should decrease it
> before return VM_FAULT_SIGBUS
> 
> Signed-off-by: Yan Zheng<yanzheng@21cn.com>

Nice catch, .23 material?

Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

> ----
> diff -ur linux-2.6.23-rc9/mm/filemap.c linux/mm/filemap.c
> --- linux-2.6.23-rc9/mm/filemap.c	2007-10-07 15:03:33.000000000 +0800
> +++ linux/mm/filemap.c	2007-10-08 23:14:39.000000000 +0800
> @@ -1388,6 +1388,7 @@
>  	size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
>  	if (unlikely(vmf->pgoff >= size)) {
>  		unlock_page(page);
> +		page_cache_release(page);
>  		goto outside_data_content;
>  	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
