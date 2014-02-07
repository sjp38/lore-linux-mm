Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f172.google.com (mail-ea0-f172.google.com [209.85.215.172])
	by kanga.kvack.org (Postfix) with ESMTP id 6F1CF6B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 10:40:27 -0500 (EST)
Received: by mail-ea0-f172.google.com with SMTP id l9so1388380eaj.31
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 07:40:26 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id x3si8890849eea.244.2014.02.07.07.40.24
        for <linux-mm@kvack.org>;
        Fri, 07 Feb 2014 07:40:25 -0800 (PST)
Date: Fri, 7 Feb 2014 10:39:24 -0500
From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] mm: fix page leak at nfs_symlink()
Message-ID: <20140207103924.25ec5baa@tlielax.poochiereds.net>
In-Reply-To: <f4b3dc07dfa55bf7931de36b03aa9ef7e3ff0490.1391785222.git.aquini@redhat.com>
References: <f4b3dc07dfa55bf7931de36b03aa9ef7e3ff0490.1391785222.git.aquini@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-kernel@vger.kernel.org, trond.myklebust@primarydata.com, jstancek@redhat.com, mgorman@suse.de, riel@redhat.com, linux-nfs@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org

On Fri,  7 Feb 2014 13:19:54 -0200
Rafael Aquini <aquini@redhat.com> wrote:

> Changes committed by "a0b8cab3 mm: remove lru parameter from
> __pagevec_lru_add and remove parts of pagevec API" have introduced
> a call to add_to_page_cache_lru() which causes a leak in nfs_symlink() 
> as now the page gets an extra refcount that is not dropped.
> 
> Jan Stancek observed and reported the leak effect while running test8 from
> Connectathon Testsuite. After several iterations over the test case,
> which creates several symlinks on a NFS mountpoint, the test system was
> quickly getting into an out-of-memory scenario.
> 
> This patch fixes the page leak by dropping that extra refcount 
> add_to_page_cache_lru() is grabbing. 
> 
> Signed-off-by: Jan Stancek <jstancek@redhat.com>
> Signed-off-by: Rafael Aquini <aquini@redhat.com>
> ---
>  fs/nfs/dir.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index be38b57..4a48fe4 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -1846,6 +1846,11 @@ int nfs_symlink(struct inode *dir, struct dentry *dentry, const char *symname)
>  							GFP_KERNEL)) {
>  		SetPageUptodate(page);
>  		unlock_page(page);
> +		/*
> +		 * add_to_page_cache_lru() grabs an extra page refcount.
> +		 * Drop it here to avoid leaking this page later.
> +		 */
> +		page_cache_release(page);
>  	} else
>  		__free_page(page);
>  

Looks reasonable as an interim fix and should almost certainly go to
stable.

Longer term, I think it would be best from an API standpoint to fix
add_to_page_cache_lru not to take this extra reference (or to have it
drop it itself) and fix up the callers accordingly. That seems like a
trap for the unwary...

-- 
Jeff Layton <jlayton@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
