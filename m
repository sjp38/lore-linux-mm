Date: Sun, 13 May 2007 22:46:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] resolve duplicate flag no for PG_lazyfree
Message-Id: <20070513224630.3cd0cb54.akpm@linux-foundation.org>
In-Reply-To: <379110250.28666@ustc.edu.cn>
References: <379110250.28666@ustc.edu.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Fengguang Wu <fengguang.wu@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Theodore Ts'o <tytso@mit.edu>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 14 May 2007 10:37:18 +0800 Fengguang Wu <fengguang.wu@gmail.com> wrote:

> PG_lazyfree and PG_booked shares the same bit.
> 
> Either it is a bug that shall fixed by the following patch, or
> the situation should be explicitly documented?
> 
> Signed-off-by: Fengguang Wu <wfg@mail.ustc.edu.cn>
> ---
>  include/linux/page-flags.h |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- linux-2.6.21-mm2.orig/include/linux/page-flags.h
> +++ linux-2.6.21-mm2/include/linux/page-flags.h
> @@ -91,7 +91,7 @@
>  #define PG_buddy		19	/* Page is free, on buddy lists */
>  #define PG_booked		20	/* Has blocks reserved on-disk */
>  
> -#define PG_lazyfree		20	/* MADV_FREE potential throwaway */
> +#define PG_lazyfree		21	/* MADV_FREE potential throwaway */
>  
>  /* PG_owner_priv_1 users should have descriptive aliases */
>  #define PG_checked		PG_owner_priv_1 /* Used by some filesystems */

That's an accident: PG_lazyfree got added but the out-of-tree ext4 patches
didn't get updated.

otoh, the intersection between pages which are PageBooked() and pages which
are PageLazyFree() should be zreo, so it'd be good to actually formalise
this reuse within the ext4 patches.

otoh2, PageLazyFree() could have reused PG_owner_priv_1.

Rik, Ted: any thoughts?  We do need to scrimp on page flags: when we
finally run out, we're screwed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
