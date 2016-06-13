Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 82C496B0005
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 05:38:32 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r5so26123504wmr.0
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 02:38:32 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id a79si14071937wma.76.2016.06.13.02.38.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jun 2016 02:38:31 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5D9XtAW073876
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 05:38:30 -0400
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
	by mx0b-001b2d01.pphosted.com with ESMTP id 23getkfkd6-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 05:38:29 -0400
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 13 Jun 2016 19:38:26 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id A6B1F3578053
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 19:38:24 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u5D9cOPW11141424
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 19:38:24 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u5D9cNNP004716
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 19:38:24 +1000
Date: Mon, 13 Jun 2016 15:08:19 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6v3 02/12] mm: migrate: support non-lru movable page
 migration
References: <1463754225-31311-1-git-send-email-minchan@kernel.org> <1463754225-31311-3-git-send-email-minchan@kernel.org> <20160530013926.GB8683@bbox> <20160531000117.GB18314@bbox>
In-Reply-To: <20160531000117.GB18314@bbox>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <575E7F0B.8010201@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rafael Aquini <aquini@redhat.com>, virtualization@lists.linux-foundation.org, Jonathan Corbet <corbet@lwn.net>, John Einar Reitan <john.reitan@foss.arm.com>, dri-devel@lists.freedesktop.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Gioh Kim <gi-oh.kim@profitbricks.com>

On 05/31/2016 05:31 AM, Minchan Kim wrote:
> @@ -791,6 +921,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
>  	int rc = -EAGAIN;
>  	int page_was_mapped = 0;
>  	struct anon_vma *anon_vma = NULL;
> +	bool is_lru = !__PageMovable(page);
>  
>  	if (!trylock_page(page)) {
>  		if (!force || mode == MIGRATE_ASYNC)
> @@ -871,6 +1002,11 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
>  		goto out_unlock_both;
>  	}
>  
> +	if (unlikely(!is_lru)) {
> +		rc = move_to_new_page(newpage, page, mode);
> +		goto out_unlock_both;
> +	}
> +

Hello Minchan,

I might be missing something here but does this implementation support the
scenario where these non LRU pages owned by the driver mapped as PTE into
process page table ? Because the "goto out_unlock_both" statement above
skips all the PTE unmap, putting a migration PTE and removing the migration
PTE steps.

Regards
Anshuman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
