Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 15FD06B0038
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 22:10:25 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id o3so29274179pgn.13
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 19:10:25 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id q9si23673455pli.252.2017.04.25.19.10.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 19:10:22 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id v14so12304767pfd.3
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 19:10:22 -0700 (PDT)
Message-ID: <1493172615.4828.3.camel@gmail.com>
Subject: Re: [PATCH v2 2/2] mm: skip HWPoisoned pages when onlining pages
From: Balbir Singh <bsingharora@gmail.com>
Date: Wed, 26 Apr 2017 12:10:15 +1000
In-Reply-To: <1493130472-22843-3-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1493130472-22843-1-git-send-email-ldufour@linux.vnet.ibm.com>
	 <1493130472-22843-3-git-send-email-ldufour@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org

On Tue, 2017-04-25 at 16:27 +0200, Laurent Dufour wrote:
> The commit b023f46813cd ("memory-hotplug: skip HWPoisoned page when
> offlining pages") skip the HWPoisoned pages when offlining pages, but
> this should be skipped when onlining the pages too.
> 
> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> ---
>  mm/memory_hotplug.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 6fa7208bcd56..741ddb50e7d2 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -942,6 +942,10 @@ static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
>  	if (PageReserved(pfn_to_page(start_pfn)))
>  		for (i = 0; i < nr_pages; i++) {
>  			page = pfn_to_page(start_pfn + i);
> +			if (PageHWPoison(page)) {
> +				ClearPageReserved(page);

Why do we clear page reserved? Also if the page is marked PageHWPoison, it
was never offlined to begin with? Or do you expect this to be set on newly
hotplugged memory? Also don't we need to skip the entire pageblock?

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
