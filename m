Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id AAFBE6B02C4
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 16:12:03 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id y71so383649155pgd.0
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 13:12:03 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id 3si56538094pfh.232.2016.11.28.13.12.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 13:12:02 -0800 (PST)
Subject: Re: [RFC 4/4] mm: Ignore cpuset enforcement when allocation flag has
 __GFP_THISNODE
References: <1479824388-30446-1-git-send-email-khandual@linux.vnet.ibm.com>
 <1479824388-30446-5-git-send-email-khandual@linux.vnet.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <8216916c-c3f3-bad9-33cb-b0da2508f3d0@intel.com>
Date: Mon, 28 Nov 2016 13:12:02 -0800
MIME-Version: 1.0
In-Reply-To: <1479824388-30446-5-git-send-email-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com

On 11/22/2016 06:19 AM, Anshuman Khandual wrote:
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3715,7 +3715,7 @@ struct page *
>  		.migratetype = gfpflags_to_migratetype(gfp_mask),
>  	};
>  
> -	if (cpusets_enabled()) {
> +	if (cpusets_enabled() && !(alloc_mask & __GFP_THISNODE)) {
>  		alloc_mask |= __GFP_HARDWALL;
>  		alloc_flags |= ALLOC_CPUSET;
>  		if (!ac.nodemask)

This means now that any __GFP_THISNODE allocation can "escape" the
cpuset.  That seems like a pretty major change to how cpusets works.  Do
we know that *ALL* __GFP_THISNODE allocations are truly lacking in a
cpuset context that can be enforced?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
