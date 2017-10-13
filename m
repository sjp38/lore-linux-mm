Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5D6EC6B0038
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 08:04:11 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id p186so5778604wmd.11
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 05:04:11 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e200si955466wmf.111.2017.10.13.05.04.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Oct 2017 05:04:09 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm, page_alloc: fail has_unmovable_pages when seeing
 reserved pages
References: <20171013115835.zaehapuucuzl2vlv@dhcp22.suse.cz>
 <20171013120013.698-1-mhocko@kernel.org>
 <20171013120013.698-2-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d98bfc90-e857-4bbe-bfbc-ee69dc310cc0@suse.cz>
Date: Fri, 13 Oct 2017 14:04:08 +0200
MIME-Version: 1.0
In-Reply-To: <20171013120013.698-2-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 10/13/2017 02:00 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Reserved pages should be completely ignored by the core mm because they
> have a special meaning for their owners. has_unmovable_pages doesn't
> check those so we rely on other tests (reference count, or PageLRU) to
> fail on such pages. Althought this happens to work it is safer to simply
> check for those explicitly and do not rely on the owner of the page
> to abuse those fields for special purposes.
> 
> Please note that this is more of a further fortification of the code
> rahter than a fix of an existing issue.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/page_alloc.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ad0294ab3e4f..a8800b0a5619 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7365,6 +7365,9 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>  
>  		page = pfn_to_page(check);
>  
> +		if (PageReferenced(page))

"Referenced" != "Reserved"

> +			return true;
> +
>  		/*
>  		 * Hugepages are not in LRU lists, but they're movable.
>  		 * We need not scan over tail pages bacause we don't
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
