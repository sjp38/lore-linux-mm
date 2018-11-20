Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id EBE826B2079
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 09:33:11 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id k90so127142qte.0
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 06:33:11 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z17si1484750qvc.118.2018.11.20.06.33.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 06:33:11 -0800 (PST)
Subject: Re: [RFC PATCH 3/3] mm, fault_around: do not take a reference to a
 locked page
References: <20181120134323.13007-1-mhocko@kernel.org>
 <20181120134323.13007-4-mhocko@kernel.org>
From: David Hildenbrand <david@redhat.com>
Message-ID: <8e85a64b-2c8f-52f7-bd46-9463d6202806@redhat.com>
Date: Tue, 20 Nov 2018 15:33:07 +0100
MIME-Version: 1.0
In-Reply-To: <20181120134323.13007-4-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <OSalvador@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill@shutemov.name>

On 20.11.18 14:43, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> filemap_map_pages takes a speculative reference to each page in the
> range before it tries to lock that page. While this is correct it
> also can influence page migration which will bail out when seeing
> an elevated reference count. The faultaround code would bail on
> seeing a locked page so we can pro-actively check the PageLocked
> bit before page_cache_get_speculative and prevent from pointless
> reference count churn.
> 
> Cc: "Kirill A. Shutemov" <kirill@shutemov.name>
> Suggested-by: Jan Kara <jack@suse.cz>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/filemap.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 81adec8ee02c..c76d6a251770 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -2553,6 +2553,9 @@ void filemap_map_pages(struct vm_fault *vmf,
>  			goto next;
>  
>  		head = compound_head(page);
> +
> +		if (PageLocked(head))
> +			goto next;
>  		if (!page_cache_get_speculative(head))
>  			goto next;
>  
> 

Right, no sense in referencing a page if we know we will drop the
reference right away.

Reviewed-by: David Hildenbrand <david@redhat.com>

-- 

Thanks,

David / dhildenb
