Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id D6E7C6B004F
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 11:24:29 -0500 (EST)
Received: by qao25 with SMTP id 25so1693056qao.14
        for <linux-mm@kvack.org>; Thu, 08 Dec 2011 08:24:28 -0800 (PST)
Message-ID: <4EE0E4B9.4050903@gmail.com>
Date: Thu, 08 Dec 2011 11:24:25 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: Question about __zone_watermark_ok: why there is a "+ 1" in computing
 free_pages?
References: <CAKXJSOHu+sQ1NeMsRvFyp2GYoB6g+50boUu=-QvbxxjcqgOAVA@mail.gmail.com> <20111205161443.GA20663@tiehlicka.suse.cz>
In-Reply-To: <20111205161443.GA20663@tiehlicka.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Wang Sheng-Hui <shhuiw@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>

(12/5/11 11:14 AM), Michal Hocko wrote:
> On Fri 25-11-11 09:21:35, Wang Sheng-Hui wrote:
>> In line 1459, we have "free_pages -= (1<<  order) + 1;".
>> Suppose allocating one 0-order page, here we'll get
>>      free_pages -= 1 + 1
>> I wonder why there is a "+ 1"?
>
> Good spot. Check the patch bellow.
> ---
>  From 38a1cf351b111e8791d2db538c8b0b912f5df8b8 Mon Sep 17 00:00:00 2001
> From: Michal Hocko<mhocko@suse.cz>
> Date: Mon, 5 Dec 2011 17:04:23 +0100
> Subject: [PATCH] mm: fix off-by-two in __zone_watermark_ok
>
> 88f5acf8 [mm: page allocator: adjust the per-cpu counter threshold when
> memory is low] changed the form how free_pages is calculated but it
> forgot that we used to do free_pages - ((1<<  order) - 1) so we ended up
> with off-by-two when calculating free_pages.
>
> Spotted-by: Wang Sheng-Hui<shhuiw@gmail.com>
> Signed-off-by: Michal Hocko<mhocko@suse.cz>
> ---
>   mm/page_alloc.c |    2 +-
>   1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 9dd443d..8a2f1b6 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1457,7 +1457,7 @@ static bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
>   	long min = mark;
>   	int o;
>
> -	free_pages -= (1<<  order) + 1;
> +	free_pages -= (1<<  order) - 1;
>   	if (alloc_flags&  ALLOC_HIGH)
>   		min -= min / 2;
>   	if (alloc_flags&  ALLOC_HARDER)

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
