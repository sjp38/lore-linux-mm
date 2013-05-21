Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 236E96B0002
	for <linux-mm@kvack.org>; Mon, 20 May 2013 20:55:38 -0400 (EDT)
Received: by mail-qa0-f51.google.com with SMTP id ii15so95645qab.10
        for <linux-mm@kvack.org>; Mon, 20 May 2013 17:55:37 -0700 (PDT)
Message-ID: <519AC605.4070709@gmail.com>
Date: Mon, 20 May 2013 20:55:33 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 01/02] swap: discard while swapping only if SWAP_FLAG_DISCARD_CLUSTER
References: <cover.1369092449.git.aquini@redhat.com> <e3ae11727f13e1580ae66ce80845e9002ec90ea6.1369092449.git.aquini@redhat.com>
In-Reply-To: <e3ae11727f13e1580ae66ce80845e9002ec90ea6.1369092449.git.aquini@redhat.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, shli@kernel.org, kzak@redhat.com, jmoyer@redhat.com, riel@redhat.com, lwoodman@redhat.com, mgorman@suse.de, kosaki.motohiro@gmail.com

(5/20/13 8:04 PM), Rafael Aquini wrote:
> Intruduce a new flag to make page-cluster fine-grained discards while swapping
> conditional, as they can be considered detrimental to some setups. However,
> keep allowing batched discards at sys_swapon() time, when enabled by the
> system administrator. 
> 
> Signed-off-by: Rafael Aquini <aquini@redhat.com>
> ---
>  include/linux/swap.h |  8 +++++---
>  mm/swapfile.c        | 12 ++++++++----
>  2 files changed, 13 insertions(+), 7 deletions(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 1701ce4..ab2e742 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -19,10 +19,11 @@ struct bio;
>  #define SWAP_FLAG_PREFER	0x8000	/* set if swap priority specified */
>  #define SWAP_FLAG_PRIO_MASK	0x7fff
>  #define SWAP_FLAG_PRIO_SHIFT	0
> -#define SWAP_FLAG_DISCARD	0x10000 /* discard swap cluster after use */
> +#define SWAP_FLAG_DISCARD	0x10000 /* enable discard for swap areas */
> +#define SWAP_FLAG_DISCARD_CLUSTER 0x20000 /* discard swap clusters after use */

>From point of backward compatibility view, 0x10000 should be disable both discarding
when mount and when IO.
And, introducing new two flags, enable mount time discard and enable IO time discard.

IOW, Please consider newer kernel and older swapon(8) conbination.
Other than that, looks good to me.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
