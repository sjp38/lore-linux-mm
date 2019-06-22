Return-Path: <SRS0=rpDk=UV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.5 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 103A9C43613
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 03:12:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9380F206BA
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 03:12:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9380F206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1761F8E0002; Fri, 21 Jun 2019 23:12:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 127808E0001; Fri, 21 Jun 2019 23:12:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 016828E0002; Fri, 21 Jun 2019 23:12:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id BC1658E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 23:12:04 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id a20so5493743pfn.19
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 20:12:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :archived-at:list-archive:list-post:content-transfer-encoding;
        bh=XreCFVoqb5cdGtVBPsC9hza/l5HKf9Z+A3E6k3OynZc=;
        b=IS/eCI01yqW39557LWA3Ee15X7ddDaezqtcxE9G00wQGs1xDlv92S+lNGciq3t+8dg
         SChBbzNmazp09/RXSWoOXDznNV4V5VJoKZhBtZtMfq1VkNDxKTQh1oRpiM7KEn0g1ZC7
         LaLSlpHGShaXglvSiBoAmJxZl2QhnIbGWLg8UTxcsht6msl3CnFc482U35Qifb8wuMHp
         yXdJml3ZdOMMTtXcdMtRXm1a0mSxb6Efks3hKYJuaCqSwdF1wcFqobUrc0MMpQsdHUGB
         2XStGnVXyJKc4FxtjRhYM8GM/V+o0GpF892kcCLm7ckTZooX/PqHWivBR1+/07sErEMN
         lGmQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.163 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAUl+WOdx7EpeLna6u14sNYkigITvPvWb/FD4lYP5cvpIxQmfqaR
	R8k8+bZ88Hh33OzBRADK+y9lFk/GUxinmv92JnMffLNCMcn6Bu1441J0ViwzcrcAqEGoOFAyTCn
	RfKWKJU2Mxl+Wa4f0+3ykqS22fd81V6KfwDqEHGEUj/jeMSDCuuffMjGt8G1/C6K2FA==
X-Received: by 2002:a17:90a:1b4a:: with SMTP id q68mr10661141pjq.61.1561173124387;
        Fri, 21 Jun 2019 20:12:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzuGRZ+0vQZ5utY5/cYyV1NA1GcI7/E0IuJcDP+ZQeQNg0ng0eJ5LXPgiDoikcS72XhpJfB
X-Received: by 2002:a17:90a:1b4a:: with SMTP id q68mr10661062pjq.61.1561173123393;
        Fri, 21 Jun 2019 20:12:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561173123; cv=none;
        d=google.com; s=arc-20160816;
        b=UWcn0oH4nTPcEHDwzKOjeNhdOnjT+XbY6dpQpjAHtblvdiJdfMOb0a2z8h5QkXSHQU
         SIwreLbl0HtFqoIu9ceG4r/xuRXWbl2NsuJ0o4D2+JdMGo0J8tInKusWS8f7J0wPMnez
         CrXEscbg8+2Ogq9f6maPViRcwBBoz0Pmm8aK38o2tcMZM13Ir2q4CmwCaSHsUQyrdBW0
         Xa8MSXdnd/iPd8V4vBTVimHnOILH3ACaJPJHjK+0jZVN9WVRZsKYDEJCV9KKd+W9inti
         k5oQRFtUD3WfxrlpWyx9QDEDYw9H+oKuq+Uu5MIstRJ5oSrTjBEwqVeojT1srfgvwz2x
         dnvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:list-post:list-archive:archived-at
         :mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=XreCFVoqb5cdGtVBPsC9hza/l5HKf9Z+A3E6k3OynZc=;
        b=BZ8FHpbG7QvvIxZzrb4Pew/eQCamR89SnqfrxQKyv+85mq/zBCEC0F/K9IeiHdFF/n
         LD3ck/SKb9mIT9KphkiXg46doYTEHlboD/ltJZnkVpyCANOrDmQO+7Shi1KXiLT1aj3M
         5NIk82ByU3CqzYZNQnHle+mXsktQgc+/lTCr6OBN/O4xLI5lGK/A4A8szuHtbjUX4FQP
         h3+INyDdomZ7I0ksMEl8Zymivq6rdPa4kX5ebF6v78kGPaR5otx7ckkO7L6OVMObhD3B
         rhK9qT8kmIb6xHqUyCWGxty0Jcdg/9ngr4msGFdpjX02lK9W1D5/fqk3yClD+i2p++Yn
         MAyA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.163 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail3-163.sinamail.sina.com.cn (mail3-163.sinamail.sina.com.cn. [202.108.3.163])
        by mx.google.com with SMTP id t1si4714525pfl.158.2019.06.21.20.12.02
        for <linux-mm@kvack.org>;
        Fri, 21 Jun 2019 20:12:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.3.163 as permitted sender) client-ip=202.108.3.163;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.163 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([221.219.4.32])
	by sina.com with ESMTP
	id 5D0D9C7E00000CCC; Sat, 22 Jun 2019 11:12:01 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 634984394735
From: Hillf Danton <hdanton@sina.com>
To: Song Liu <songliubraving@fb.com>
Cc: linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kirill.shutemov@linux.intel.com,
	kernel-team@fb.com,
	william.kucharski@oracle.com,
	akpm@linux-foundation.org
Subject: Re: [PATCH v6 4/6] khugepaged: rename collapse_shmem() and khugepaged_scan_shmem()
Date: Sat, 22 Jun 2019 11:11:51 +0800
Message-Id: <20190622031151.3316-1-hdanton@sina.com>
In-Reply-To: <20190622000512.923867-1-songliubraving@fb.com>
References: 
MIME-Version: 1.0
Content-Type: text/plain
Archived-At: <https://lore.kernel.org/lkml/20190622000512.923867-5-songliubraving@fb.com/>
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Hello

On Fri, 21 Jun 2019 17:05:10 -0700 Song Liu <songliubraving@fb.com> wrote:
> Next patch will add khugepaged support of non-shmem files. This patch
> renames these two functions to reflect the new functionality:
> 
>     collapse_shmem()        =>  collapse_file()
>     khugepaged_scan_shmem() =>  khugepaged_scan_file()
> 
> Acked-by: Rik van Riel <riel@surriel.com>
> Signed-off-by: Song Liu <songliubraving@fb.com>
> ---
>  mm/khugepaged.c | 13 +++++++------
>  1 file changed, 7 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index 0f7419938008..dde8e45552b3 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -1287,7 +1287,7 @@ static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
>  }
>  
>  /**
> - * collapse_shmem - collapse small tmpfs/shmem pages into huge one.
> + * collapse_file - collapse small tmpfs/shmem pages into huge one.
>   *
>   * Basic scheme is simple, details are more complex:
>   *  - allocate and lock a new huge page;
> @@ -1304,10 +1304,11 @@ static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
>   *    + restore gaps in the page cache;
>   *    + unlock and free huge page;
>   */
> -static void collapse_shmem(struct mm_struct *mm,
> +static void collapse_file(struct vm_area_struct *vma,
>  		struct address_space *mapping, pgoff_t start,
>  		struct page **hpage, int node)
>  {
> +	struct mm_struct *mm = vma->vm_mm;
>  	gfp_t gfp;
>  	struct page *new_page;
>  	struct mem_cgroup *memcg;
> @@ -1563,7 +1564,7 @@ static void collapse_shmem(struct mm_struct *mm,
>  	/* TODO: tracepoints */
>  }
>  
> -static void khugepaged_scan_shmem(struct mm_struct *mm,
> +static void khugepaged_scan_file(struct vm_area_struct *vma,
>  		struct address_space *mapping,
>  		pgoff_t start, struct page **hpage)
>  {
> @@ -1631,14 +1632,14 @@ static void khugepaged_scan_shmem(struct mm_struct *mm,
>  			result = SCAN_EXCEED_NONE_PTE;
>  		} else {
>  			node = khugepaged_find_target_node();
> -			collapse_shmem(mm, mapping, start, hpage, node);
> +			collapse_file(vma, mapping, start, hpage, node);
>  		}
>  	}
>  
>  	/* TODO: tracepoints */
>  }
>  #else
> -static void khugepaged_scan_shmem(struct mm_struct *mm,
> +static void khugepaged_scan_file(struct vm_area_struct *vma,
>  		struct address_space *mapping,
>  		pgoff_t start, struct page **hpage)
>  {
> @@ -1722,7 +1723,7 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
>  				file = get_file(vma->vm_file);
>  				up_read(&mm->mmap_sem);
>  				ret = 1;
> -				khugepaged_scan_shmem(mm, file->f_mapping,
> +				khugepaged_scan_file(vma, file->f_mapping,
>  						pgoff, hpage);
>  				fput(file);

Is it a change that should have put some material in the log message?
Is it unlikely for vma to go without mmap_sem held?
>  			} else {
> -- 
> 2.17.1
> 

Hillf

