Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4DF6C4740A
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 23:26:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 60B7520863
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 23:26:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="eIYFZ/BH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 60B7520863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EAA1A6B0007; Mon,  9 Sep 2019 19:26:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E59A46B0008; Mon,  9 Sep 2019 19:26:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D47556B000A; Mon,  9 Sep 2019 19:26:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0166.hostedemail.com [216.40.44.166])
	by kanga.kvack.org (Postfix) with ESMTP id AE8E36B0007
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 19:26:18 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 4B46C180AD7C3
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 23:26:18 +0000 (UTC)
X-FDA: 75916968036.01.cork57_541412c5ec20e
X-HE-Tag: cork57_541412c5ec20e
X-Filterd-Recvd-Size: 6932
Received: from mail-pg1-f195.google.com (mail-pg1-f195.google.com [209.85.215.195])
	by imf42.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 23:26:17 +0000 (UTC)
Received: by mail-pg1-f195.google.com with SMTP id x15so8725185pgg.8
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 16:26:17 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=SjSMthJTNkjw6lGU7Gi+zgafw5Sbiv6n1l0iOaJFBnY=;
        b=eIYFZ/BHSmQjOTOquVJTUH5h40zErYkLXeHZ+HKrbkK6QjtIi/5vnbIa+0jk7tBd5d
         grR0GbkmPKY2Dm9uFI6V5SVcOubOUKBAlXhWnz9Iabdhlw6CwIG02QFFUob02D3Kha1N
         LkQrgJuasMDZ0AKqKq5axfo7UJaB6+StzjWMA7S3LWUSrS24/N9mKFeE2uJ4w4RfwUqs
         BpdFnG9Jb7NGIySgvmpXYGC00Cf26eKneAkqmSmAvgyfCEdYiudfu00Uwwd6VLzpqwii
         s4emg0A5pnT/OwJasInwdrBzCvU8o12BYcShFAsqg1hnco9tYIbg5j0MxFrRRIUorEQY
         +aHQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:date:from:to:cc:subject:message-id
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=SjSMthJTNkjw6lGU7Gi+zgafw5Sbiv6n1l0iOaJFBnY=;
        b=M8ItvYOZgidfF6IFY+iYAnbQ5sZW3Sq1JD72HyWVZvJ2DKzmO4JJLIS5QMfe2ETpEA
         QQCtdyThRA0ZEksAhi+F8Md95SAMRJhRwrvpiPmDVEjfohh65WIf6s1knaNR3pgd7y4Q
         PIas1BKjgnXTY4bMcOYtpFEmIMFBoGDyBF6JtwIXWBvXkLgQumuUW5nZlnS2Yeyf0NC3
         hlrwd/XpqlTo0ckdT5Ut9mPUnOL2Kx/pXxKmGjLzD/Kk67lybMMmmm88RRK+sj7M2jPc
         ftDm+0HTAMiLZ+Wv52grGBdnGksS+WJvxLRocsAvIbNT034x0iflsG+UE+kD8WyVXoe/
         EVrg==
X-Gm-Message-State: APjAAAUbm9Uya8jSLV6tP7qa66Bu77vgVUd+RIUApIUVpBQNC1BAFu3B
	sx7P2o4eo69U6Qy0kPkC79o=
X-Google-Smtp-Source: APXvYqz/ztHeJ6C/xwKdMpCESja8yOslsB4fpt+zS/NnGuIxBIHRayiNVcjFvSdXoG6iHr1hY3Vgjw==
X-Received: by 2002:a65:68cd:: with SMTP id k13mr24372143pgt.411.1568071576378;
        Mon, 09 Sep 2019 16:26:16 -0700 (PDT)
Received: from google.com ([2620:15c:211:1:3e01:2939:5992:52da])
        by smtp.gmail.com with ESMTPSA id q22sm14239493pgh.49.2019.09.09.16.26.14
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 09 Sep 2019 16:26:15 -0700 (PDT)
Date: Mon, 9 Sep 2019 16:26:13 -0700
From: Minchan Kim <minchan@kernel.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: linux-mm@kvack.org
Subject: Re: [PATCH] mm: fix the race between swapin_readahead and
 SWP_SYNCHRONOUS_IO path
Message-ID: <20190909232613.GA39783@google.com>
References: <1567169011-4748-1-git-send-email-vinmenon@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1567169011-4748-1-git-send-email-vinmenon@codeaurora.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Vinayak,

On Fri, Aug 30, 2019 at 06:13:31PM +0530, Vinayak Menon wrote:
> The following race is observed due to which a processes faulting
> on a swap entry, finds the page neither in swapcache nor swap. This
> causes zram to give a zero filled page that gets mapped to the
> process, resulting in a user space crash later.
> 
> Consider parent and child processes Pa and Pb sharing the same swap
> slot with swap_count 2. Swap is on zram with SWP_SYNCHRONOUS_IO set.
> Virtual address 'VA' of Pa and Pb points to the shared swap entry.
> 
> Pa                                       Pb
> 
> fault on VA                              fault on VA
> do_swap_page                             do_swap_page
> lookup_swap_cache fails                  lookup_swap_cache fails
>                                          Pb scheduled out
> swapin_readahead (deletes zram entry)
> swap_free (makes swap_count 1)
>                                          Pb scheduled in
>                                          swap_readpage (swap_count == 1)
>                                          Takes SWP_SYNCHRONOUS_IO path
>                                          zram enrty absent
>                                          zram gives a zero filled page
> 
> Fix this by reading the swap_count before lookup_swap_cache, which conforms
> with the order in which page is added to swap cache and swap count is
> decremented in do_swap_page. In the race case above, this will let Pb take
> the readahead path and thus pick the proper page from swapcache.

Thanks for the report, Vinayak.

It's a zram specific issue because it deallocates zram block
unconditionally once read IO is done. The expectation was that dirty
page is on the swap cache but with SWP_SYNCHRONOUS_IO, it's not true
any more so I want to resolve the issue in zram specific code, not
general one.

A idea in my mind is swap_slot_free_notify should check the slot
reference counter and if it's higher than 1, it shouldn't free the
slot until. What do you think about?

> 
> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
> ---
>  mm/memory.c | 21 ++++++++++++++++-----
>  1 file changed, 16 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index e0c232f..22643aa 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2744,6 +2744,8 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
>  	struct page *page = NULL, *swapcache;
>  	struct mem_cgroup *memcg;
>  	swp_entry_t entry;
> +	struct swap_info_struct *si;
> +	bool skip_swapcache = false;
>  	pte_t pte;
>  	int locked;
>  	int exclusive = 0;
> @@ -2771,15 +2773,24 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
>  
>  
>  	delayacct_set_flag(DELAYACCT_PF_SWAPIN);
> +
> +	/*
> +	 * lookup_swap_cache below can fail and before the SWP_SYNCHRONOUS_IO
> +	 * check is made, another process can populate the swapcache, delete
> +	 * the swap entry and decrement the swap count. So decide on taking
> +	 * the SWP_SYNCHRONOUS_IO path before the lookup. In the event of the
> +	 * race described, the victim process will find a swap_count > 1
> +	 * and can then take the readahead path instead of SWP_SYNCHRONOUS_IO.
> +	 */
> +	si = swp_swap_info(entry);
> +	if (si->flags & SWP_SYNCHRONOUS_IO && __swap_count(entry) == 1)
> +		skip_swapcache = true;
> +
>  	page = lookup_swap_cache(entry, vma, vmf->address);
>  	swapcache = page;
>  
>  	if (!page) {
> -		struct swap_info_struct *si = swp_swap_info(entry);
> -
> -		if (si->flags & SWP_SYNCHRONOUS_IO &&
> -				__swap_count(entry) == 1) {
> -			/* skip swapcache */
> +		if (skip_swapcache) {
>  			page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma,
>  							vmf->address);
>  			if (page) {
> -- 
> QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
> member of the Code Aurora Forum, hosted by The Linux Foundation
> 

