Date: Tue, 25 Apr 2006 11:58:25 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 2.6.17-rc1-mm3] add migratepage addresss space op to
 shmem
In-Reply-To: <Pine.LNX.4.64.0604241447520.8904@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0604251153300.29020@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0604242046120.24647@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0604241447520.8904@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 24 Apr 2006, Christoph Lameter wrote:
> On Mon, 24 Apr 2006, Hugh Dickins wrote:
> > 
> > While that's not wrong, wouldn't the right fix be something else?
> 
> His patch avoids going through the fallback functions and allows 
> migrating dirty shmem pages without pageout. That is good.

True.

> Index: linux-2.6/mm/migrate.c
> ===================================================================
> --- linux-2.6.orig/mm/migrate.c	2006-04-18 12:51:31.000000000 -0700
> +++ linux-2.6/mm/migrate.c	2006-04-24 15:03:10.000000000 -0700
> @@ -439,6 +439,11 @@ redo:
>  			goto unlock_both;
>                  }
>  
> +		if (try_to_unmap(page, 1) == SWAP_FAIL) {
> +			rc = -EPERM;
> +			goto unlock_both;
> +		}
> +
>  		/*
>  		 * Default handling if a filesystem does not provide
>  		 * a migration function. We can only migrate clean

Perhaps.  But there seem to be altogether too many ways through this
code: this part of migrate_pages then starts to look rather like,
but not exactly like, swap_page.  Feels like it needs refactoring.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
