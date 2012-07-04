Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 746346B0071
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 10:27:27 -0400 (EDT)
Date: Wed, 4 Jul 2012 16:27:24 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 4/7] Use vfs __set_page_dirty interface instead of doing
 it inside filesystem
Message-ID: <20120704142724.GK29842@tiehlicka.suse.cz>
References: <1340880885-5427-1-git-send-email-handai.szj@taobao.com>
 <1340881423-5703-1-git-send-email-handai.szj@taobao.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340881423-5703-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, gthelen@google.com, yinghan@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, sage@newdream.net, ceph-devel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

On Thu 28-06-12 19:03:43, Sha Zhengju wrote:
> From: Sha Zhengju <handai.szj@taobao.com>
> 
> Following we will treat SetPageDirty and dirty page accounting as an integrated
> operation. Filesystems had better use vfs interface directly to avoid those details.
> 
> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
> ---
>  fs/buffer.c                 |    2 +-
>  fs/ceph/addr.c              |   20 ++------------------
>  include/linux/buffer_head.h |    2 ++
>  3 files changed, 5 insertions(+), 19 deletions(-)
> 
> diff --git a/fs/buffer.c b/fs/buffer.c
> index e8d96b8..55522dd 100644
> --- a/fs/buffer.c
> +++ b/fs/buffer.c
> @@ -610,7 +610,7 @@ EXPORT_SYMBOL(mark_buffer_dirty_inode);
>   * If warn is true, then emit a warning if the page is not uptodate and has
>   * not been truncated.
>   */
> -static int __set_page_dirty(struct page *page,
> +int __set_page_dirty(struct page *page,
>  		struct address_space *mapping, int warn)
>  {
>  	if (unlikely(!mapping))
> diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
> index 8b67304..d028fbe 100644
> --- a/fs/ceph/addr.c
> +++ b/fs/ceph/addr.c
> @@ -5,6 +5,7 @@
>  #include <linux/mm.h>
>  #include <linux/pagemap.h>
>  #include <linux/writeback.h>	/* generic_writepages */
> +#include <linux/buffer_head.h>
>  #include <linux/slab.h>
>  #include <linux/pagevec.h>
>  #include <linux/task_io_accounting_ops.h>
> @@ -73,14 +74,8 @@ static int ceph_set_page_dirty(struct page *page)
>  	int undo = 0;
>  	struct ceph_snap_context *snapc;
>  
> -	if (unlikely(!mapping))
> -		return !TestSetPageDirty(page);
> -
> -	if (TestSetPageDirty(page)) {
> -		dout("%p set_page_dirty %p idx %lu -- already dirty\n",
> -		     mapping->host, page, page->index);

I am not familiar with the code but this looks we loose an information
about something bad(?) is going on?

> +	if (!__set_page_dirty(page, mapping, 1))
>  		return 0;
> -	}
>  
>  	inode = mapping->host;
>  	ci = ceph_inode(inode);
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
