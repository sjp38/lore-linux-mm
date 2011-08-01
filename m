Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 6352590015D
	for <linux-mm@kvack.org>; Mon,  1 Aug 2011 12:15:27 -0400 (EDT)
Message-ID: <4E36D110.30407@openvz.org>
Date: Mon, 1 Aug 2011 20:15:12 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] mm: reverse lru scanning order
References: <20110727111002.9985.94938.stgit@localhost6>
In-Reply-To: <20110727111002.9985.94938.stgit@localhost6>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

sorry, this patch is broken.

Konstantin Khlebnikov wrote:
> LRU scanning order was accidentially changed in commit v2.6.27-5584-gb69408e:
> "vmscan: Use an indexed array for LRU variables".
> Before that commit reclaimer always scan active lists first.
>
> This patch just reverse it back.
> This is just notice and question: "Does it affect something?"
>
> Signed-off-by: Konstantin Khlebnikov<khlebnikov@openvz.org>
> ---
>   include/linux/mmzone.h |    3 ++-
>   1 files changed, 2 insertions(+), 1 deletions(-)
>
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index be1ac8d..88fb49c 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -141,7 +141,8 @@ enum lru_list {
>
>   #define for_each_lru(l) for (l = 0; l<  NR_LRU_LISTS; l++)
>
> -#define for_each_evictable_lru(l) for (l = 0; l<= LRU_ACTIVE_FILE; l++)
> +#define for_each_evictable_lru(l) \
> +	for (l = LRU_ACTIVE_FILE; l>= LRU_INACTIVE_ANON; l--)

there must be some thing like this:

+#define for_each_evictable_lru(l) \
+	for (l = LRU_ACTIVE_FILE; (int)l>= LRU_INACTIVE_ANON; l--)

otherwise gcc silently generates there infinite loop =)

>
>   static inline int is_file_lru(enum lru_list l)
>   {
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
