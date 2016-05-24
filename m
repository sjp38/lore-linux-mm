Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E22326B0005
	for <linux-mm@kvack.org>; Tue, 24 May 2016 12:33:32 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b124so39257826pfb.1
        for <linux-mm@kvack.org>; Tue, 24 May 2016 09:33:32 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id l89si12717740pfj.19.2016.05.24.09.33.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 May 2016 09:33:31 -0700 (PDT)
Received: by mail-pa0-x235.google.com with SMTP id bt5so8176820pac.3
        for <linux-mm@kvack.org>; Tue, 24 May 2016 09:33:31 -0700 (PDT)
Subject: Re: [PATCH] mm: fix build problems from lookup_page_ext
References: <1464023768-31025-1-git-send-email-yang.shi@linaro.org>
 <6285269.2CksypHdYp@wuerfel>
From: "Shi, Yang" <yang.shi@linaro.org>
Message-ID: <2886daa5-bff5-34d1-956a-ea6fe718bcae@linaro.org>
Date: Tue, 24 May 2016 09:33:30 -0700
MIME-Version: 1.0
In-Reply-To: <6285269.2CksypHdYp@wuerfel>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>, linaro-kernel@lists.linaro.org
Cc: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Arnd,

Thanks a lot for the patch. My bad, sorry for the inconvenience. I 
omitted the specific page_idle change is for 32 bit only.

And, my host compiler looks old which is still 4.8 so it might not catch 
the warning. I will update my compiler.

Regards,
Yang


On 5/24/2016 3:08 AM, Arnd Bergmann wrote:
> A patch for lookup_page_ext introduced several build errors and
> warnings, e.g.
>
> mm/page_owner.c: In function '__set_page_owner':
> mm/page_owner.c:71:2: error: ISO C90 forbids mixed declarations and code [-Werror=declaration-after-statement]
> include/linux/page_idle.h: In function 'set_page_young':
> include/linux/page_idle.h:62:3: error: expected ')' before 'return'
>
> This fixes all of them. Please fold into the original patch.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 38c4fffbad3c ("mm: check the return value of lookup_page_ext for all call sites")
>
> diff --git a/include/linux/page_idle.h b/include/linux/page_idle.h
> index 569c3a180625..fec40271339f 100644
> --- a/include/linux/page_idle.h
> +++ b/include/linux/page_idle.h
> @@ -48,7 +48,7 @@ static inline bool page_is_young(struct page *page)
>  {
>  	struct page_ext *page_ext = lookup_page_ext(page);
>
> -	if (unlikely(!page_ext)
> +	if (unlikely(!page_ext))
>  		return false;
>
>  	return test_bit(PAGE_EXT_YOUNG, &page_ext->flags);
> @@ -58,7 +58,7 @@ static inline void set_page_young(struct page *page)
>  {
>  	struct page_ext *page_ext = lookup_page_ext(page);
>
> -	if (unlikely(!page_ext)
> +	if (unlikely(!page_ext))
>  		return;
>
>  	set_bit(PAGE_EXT_YOUNG, &page_ext->flags);
> @@ -68,7 +68,7 @@ static inline bool test_and_clear_page_young(struct page *page)
>  {
>  	struct page_ext *page_ext = lookup_page_ext(page);
>
> -	if (unlikely(!page_ext)
> +	if (unlikely(!page_ext))
>  		return false;
>
>  	return test_and_clear_bit(PAGE_EXT_YOUNG, &page_ext->flags);
> @@ -78,7 +78,7 @@ static inline bool page_is_idle(struct page *page)
>  {
>  	struct page_ext *page_ext = lookup_page_ext(page);
>
> -	if (unlikely(!page_ext)
> +	if (unlikely(!page_ext))
>  		return false;
>
>  	return test_bit(PAGE_EXT_IDLE, &page_ext->flags);
> @@ -88,7 +88,7 @@ static inline void set_page_idle(struct page *page)
>  {
>  	struct page_ext *page_ext = lookup_page_ext(page);
>
> -	if (unlikely(!page_ext)
> +	if (unlikely(!page_ext))
>  		return;
>
>  	set_bit(PAGE_EXT_IDLE, &page_ext->flags);
> @@ -98,7 +98,7 @@ static inline void clear_page_idle(struct page *page)
>  {
>  	struct page_ext *page_ext = lookup_page_ext(page);
>
> -	if (unlikely(!page_ext)
> +	if (unlikely(!page_ext))
>  		return;
>
>  	clear_bit(PAGE_EXT_IDLE, &page_ext->flags);
> diff --git a/mm/page_owner.c b/mm/page_owner.c
> index 902e39813295..c6cda3e36212 100644
> --- a/mm/page_owner.c
> +++ b/mm/page_owner.c
> @@ -65,9 +65,6 @@ void __set_page_owner(struct page *page, unsigned int order, gfp_t gfp_mask)
>  {
>  	struct page_ext *page_ext = lookup_page_ext(page);
>
> -	if (unlikely(!page_ext))
> -		return;
> -
>  	struct stack_trace trace = {
>  		.nr_entries = 0,
>  		.max_entries = ARRAY_SIZE(page_ext->trace_entries),
> @@ -75,6 +72,9 @@ void __set_page_owner(struct page *page, unsigned int order, gfp_t gfp_mask)
>  		.skip = 3,
>  	};
>
> +	if (unlikely(!page_ext))
> +		return;
> +
>  	save_stack_trace(&trace);
>
>  	page_ext->order = order;
> @@ -111,12 +111,11 @@ void __copy_page_owner(struct page *oldpage, struct page *newpage)
>  {
>  	struct page_ext *old_ext = lookup_page_ext(oldpage);
>  	struct page_ext *new_ext = lookup_page_ext(newpage);
> +	int i;
>
>  	if (unlikely(!old_ext || !new_ext))
>  		return;
>
> -	int i;
> -
>  	new_ext->order = old_ext->order;
>  	new_ext->gfp_mask = old_ext->gfp_mask;
>  	new_ext->nr_entries = old_ext->nr_entries;
> @@ -204,11 +203,6 @@ err:
>  void __dump_page_owner(struct page *page)
>  {
>  	struct page_ext *page_ext = lookup_page_ext(page);
> -	if (unlikely(!page_ext)) {
> -		pr_alert("There is not page extension available.\n");
> -		return;
> -	}
> -
>  	struct stack_trace trace = {
>  		.nr_entries = page_ext->nr_entries,
>  		.entries = &page_ext->trace_entries[0],
> @@ -216,6 +210,11 @@ void __dump_page_owner(struct page *page)
>  	gfp_t gfp_mask = page_ext->gfp_mask;
>  	int mt = gfpflags_to_migratetype(gfp_mask);
>
> +	if (unlikely(!page_ext)) {
> +		pr_alert("There is not page extension available.\n");
> +		return;
> +	}
> +
>  	if (!test_bit(PAGE_EXT_OWNER, &page_ext->flags)) {
>  		pr_alert("page_owner info is not active (free page?)\n");
>  		return;
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
