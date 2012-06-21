Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 6B5BB6B00D9
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 12:09:29 -0400 (EDT)
Date: Thu, 21 Jun 2012 18:09:02 +0200
From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: Re: [PATCH 10/17] netvm: Allow skb allocation to use PFMEMALLOC
 reserves
Message-ID: <20120621160902.GA6045@breakpoint.cc>
References: <1340192652-31658-1-git-send-email-mgorman@suse.de>
 <1340192652-31658-11-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340192652-31658-11-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>

On Wed, Jun 20, 2012 at 12:44:05PM +0100, Mel Gorman wrote:
> index b534a1b..61c951f 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -505,6 +506,15 @@ struct sk_buff {
>  #include <linux/slab.h>
>  
>  
> +#define SKB_ALLOC_FCLONE	0x01
> +#define SKB_ALLOC_RX		0x02
> +
> +/* Returns true if the skb was allocated from PFMEMALLOC reserves */
> +static inline bool skb_pfmemalloc(struct sk_buff *skb)
> +{
> +	return unlikely(skb->pfmemalloc);
> +}
> +
>  /*
>   * skb might have a dst pointer attached, refcounted or not.
>   * _skb_refdst low order bit is set if refcount was _not_ taken
> @@ -568,7 +578,7 @@ extern bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 1d6ecc8..9a58dcc 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -839,6 +900,13 @@ static void copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
>  	skb_shinfo(new)->gso_type = skb_shinfo(old)->gso_type;
>  }
>  
> +static inline int skb_alloc_rx_flag(const struct sk_buff *skb)
> +{
> +	if (skb_pfmemalloc((struct sk_buff *)skb))
> +		return SKB_ALLOC_RX;
> +	return 0;
> +}
> +
>  /**
>   *	skb_copy	-	create private copy of an sk_buff
>   *	@skb: buffer to copy

If merge this chunk

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 6510a5d..2acfec9 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -510,7 +510,7 @@ struct sk_buff {
 #define SKB_ALLOC_RX		0x02
 
 /* Returns true if the skb was allocated from PFMEMALLOC reserves */
-static inline bool skb_pfmemalloc(struct sk_buff *skb)
+static inline bool skb_pfmemalloc(const struct sk_buff *skb)
 {
 	return unlikely(skb->pfmemalloc);
 }
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index c44ab68..6ce94b5 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -852,7 +852,7 @@ static void copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 
 static inline int skb_alloc_rx_flag(const struct sk_buff *skb)
 {
-	if (skb_pfmemalloc((struct sk_buff *)skb))
+	if (skb_pfmemalloc(skb))
 		return SKB_ALLOC_RX;
 	return 0;
 }


Then you should be able to drop the case in skb_alloc_rx_flag() without adding
a warning.

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
