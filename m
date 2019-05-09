Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1C51C04A6B
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 01:57:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 98FA120863
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 01:57:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 98FA120863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FBA16B0003; Wed,  8 May 2019 21:57:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2ABF36B0006; Wed,  8 May 2019 21:57:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C1BB6B0007; Wed,  8 May 2019 21:57:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id DA9F76B0003
	for <linux-mm@kvack.org>; Wed,  8 May 2019 21:57:37 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 5so469033pff.11
        for <linux-mm@kvack.org>; Wed, 08 May 2019 18:57:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=wEpqnpFSM8O5VLLi15UDk3aENPrHw9YxUZdy83WZvRs=;
        b=FNjbmf18zEhgHRwJNWGg0IIrJh2UHFG+mt6BaJMAzs6Ow5RzjrGiu6yp/gQQaeqQLi
         NoTO+dro1EBSqCFfD+oD7NGw2MYjyqmaAEpiSk8uu04N5v/+f8gO0L4HA2mRSvURCCCK
         sUhTRQGhgijRS0+j2uQ8N2YHvPpEm6HslQP+BSmReitEwi8LytAsH2Gliou4R9ojqkvv
         Lc3oQsJs8pBcBKs6J20u7/9aqQNmd9jhRxQ2g36TL0dkeiiit+709wM0Q3MTgW+Wc/ub
         CRTor415JL0qT6oJjbByAaW2fgu3FJE2D/4HDL8okgbaND5vxFkA3eakRzsr/d7N3RB+
         LTIw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXiwFQhaXUwyANU1ZdD9koRdQ5+BwmcoomxnUYRiKLzkxCIBzYX
	pAvdWjIMbxJ9qYJaX3uGyIrWaTqfbqT/4E1xjfVUpGk1DzcDHqf599jgKCT16uoXY13lv+saLk2
	5mFmXniGyy/tNZiJ3pGZIlaDSRST0PW97V2NqZPqMZd7o6erTeRJ3aqYMIMqIFRJMTg==
X-Received: by 2002:a17:902:29ab:: with SMTP id h40mr1517190plb.269.1557367057568;
        Wed, 08 May 2019 18:57:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwtlOUHSA4wXC3erhzUwB2fzm4Ctk4ExfF967UpRAQf1DfWWUc943t6SEboKPQEAKhdcnZs
X-Received: by 2002:a17:902:29ab:: with SMTP id h40mr1517111plb.269.1557367056738;
        Wed, 08 May 2019 18:57:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557367056; cv=none;
        d=google.com; s=arc-20160816;
        b=JXoKum8eiIaPsJ84wGxmPD9tZ1EmstdHqfoJVtuEgBet3pKQFSr1qupkIJ/LIm6jN3
         BCABiKot9pn6WJn0hQ56CUru245EmOFJez7Gjif7OIfyhDR8+bS3a6ix71Te4xuY0TBy
         HFlMIKzDseDjXEuR0Yd1fwg5ZUpzqSDRnestigXe8lB9PtQpDiN168oePgAa2Hq8yqQS
         ERwYIa775XkEvNA4IMIZjxoSHeTP10C/lW4jOROG21R+MUL+Hn2h0rhbt074/oLx2tJ5
         6sGXDz7DtIqQmvx3hKpAYKclt/zI4zVwobuFESCK0182LaPFn86GqucmlXQ5Bzc0YIfS
         bbVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=wEpqnpFSM8O5VLLi15UDk3aENPrHw9YxUZdy83WZvRs=;
        b=VDXPKbJJevd6W61c8Nj+oqW0hNld09VlmLnyP9UalKSm3Q3LPD4udAPxG3HMxxr5ho
         an51FjjaLpWG/+5YI4umG2XkUidJgR3WVB25VkAyo++GrnRIEBVd0mcUGdeuNYqliq+T
         zXQBzR6EhbCN96Vkwn7AxCKcIiosvLEQAPi3cc4KJo3rNLnq7dIPThrkPzdbwiywhefd
         zVSRha5euqS1EO3ME22JlB3Im/X61DTxsfsMW0lG8mblJkv4piqMOTIoJigQ8ChnpwVf
         nv1uKXI+mDTJgNTx9JCH4GDdbKwFUYBi0YgO3dPnuHH6uA74bb8jTwvtINu2cw/fxRzi
         AoAA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id e6si923749pgc.62.2019.05.08.18.57.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 18:57:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 18:57:36 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga008.fm.intel.com with ESMTP; 08 May 2019 18:57:35 -0700
Date: Wed, 8 May 2019 18:58:09 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org
Subject: Re: [RFC 00/11] Remove 'order' argument from many mm functions
Message-ID: <20190509015809.GB26131@iweiny-DESK2.sc.intel.com>
References: <20190507040609.21746-1-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190507040609.21746-1-willy@infradead.org>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 06, 2019 at 09:05:58PM -0700, Matthew Wilcox wrote:
> From: "Matthew Wilcox (Oracle)" <willy@infradead.org>
> 
> It's possible to save a few hundred bytes from the kernel text by moving
> the 'order' argument into the GFP flags.  I had the idea while I was
> playing with THP pagecache (notably, I didn't want to add an 'order'
> parameter to pagecache_get_page())
> 
> What I got for a -tiny config for page_alloc.o (with a tinyconfig,
> x86-32) after each step:
> 
>    text	   data	    bss	    dec	    hex	filename
>   21462	    349	     44	  21855	   555f	1.o
>   21447	    349	     44	  21840	   5550	2.o
>   21415	    349	     44	  21808	   5530	3.o
>   21399	    349	     44	  21792	   5520	4.o
>   21399	    349	     44	  21792	   5520	5.o
>   21367	    349	     44	  21760	   5500	6.o
>   21303	    349	     44	  21696	   54c0	7.o
>   21303	    349	     44	  21696	   54c0	8.o
>   21303	    349	     44	  21696	   54c0	9.o
>   21303	    349	     44	  21696	   54c0	A.o
>   21303	    349	     44	  21696	   54c0	B.o
> 
> I assure you that the callers all shrink as well.  vmscan.o also
> shrinks, but I didn't keep detailed records.
> 
> Anyway, this is just a quick POC due to me being on an aeroplane for
> most of today.  Maybe we don't want to spend five GFP bits on this.
> Some bits of this could be pulled out and applied even if we don't want
> to go for the main objective.  eg rmqueue_pcplist() doesn't use its
> gfp_flags argument.

Over all I may just be a simpleton WRT this but I'm not sure that the added
complexity justifies the gain.

But other than the 1 patch I don't see anything technically wrong.  So I
guess...

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

> 
> Matthew Wilcox (Oracle) (11):
>   fix function alignment
>   mm: Pass order to __alloc_pages_nodemask in GFP flags
>   mm: Pass order to __get_free_pages() in GFP flags
>   mm: Pass order to prep_new_page in GFP flags
>   mm: Remove gfp_flags argument from rmqueue_pcplist
>   mm: Pass order to rmqueue in GFP flags
>   mm: Pass order to get_page_from_freelist in GFP flags
>   mm: Pass order to __alloc_pages_cpuset_fallback in GFP flags
>   mm: Pass order to prepare_alloc_pages in GFP flags
>   mm: Pass order to try_to_free_pages in GFP flags
>   mm: Pass order to node_reclaim() in GFP flags
> 
>  arch/x86/Makefile_32.cpu      |  2 +
>  arch/x86/events/intel/ds.c    |  4 +-
>  arch/x86/kvm/vmx/vmx.c        |  4 +-
>  arch/x86/mm/init.c            |  3 +-
>  arch/x86/mm/pgtable.c         |  7 +--
>  drivers/base/devres.c         |  2 +-
>  include/linux/gfp.h           | 57 +++++++++++---------
>  include/linux/migrate.h       |  2 +-
>  include/linux/swap.h          |  2 +-
>  include/trace/events/vmscan.h | 28 +++++-----
>  mm/filemap.c                  |  2 +-
>  mm/gup.c                      |  4 +-
>  mm/hugetlb.c                  |  5 +-
>  mm/internal.h                 |  5 +-
>  mm/khugepaged.c               |  2 +-
>  mm/mempolicy.c                | 30 +++++------
>  mm/migrate.c                  |  2 +-
>  mm/mmu_gather.c               |  2 +-
>  mm/page_alloc.c               | 97 +++++++++++++++++------------------
>  mm/shmem.c                    |  5 +-
>  mm/slub.c                     |  2 +-
>  mm/vmscan.c                   | 26 +++++-----
>  22 files changed, 147 insertions(+), 146 deletions(-)
> 
> -- 
> 2.20.1
> 

