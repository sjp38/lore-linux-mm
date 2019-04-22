Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2AE59C10F11
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 20:09:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D725D2075A
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 20:09:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D725D2075A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 794B46B0003; Mon, 22 Apr 2019 16:09:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 745A66B0006; Mon, 22 Apr 2019 16:09:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 65A956B0007; Mon, 22 Apr 2019 16:09:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 494386B0003
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 16:09:49 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id x23so11356769qka.19
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 13:09:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=OS2hVKKW50ZmouHzSRmPm/efY8EnPT5441lUIE9oysQ=;
        b=bPeVhlXkWpg/QcAhsP48THijmqI64STR+3tCAQEfOXH3DxCJ7zqC9CEbySw6+M0fXU
         Uof/Z84vfw9UkWo+uEiZS77nz7lNISV9gfQ+zI5SM2xv40aBt6XmTWAc+9RtfW3rvV5j
         gA9jpNFCCbIUBUxvDHSkEGZFuRgKtvAqRn++i3GUC0BBMY0ihGAX3iJQM5MexdaHNS3+
         odj/w47SGAoSJF+mmPAipH66gUVzKIdjWoLIw2mdHFtb3oKXaaQMfGtwyzFoysaYOsaR
         zga+1zsM0SdnvYcYccBx3I1SFA3MUWhFLgMImlpEEN4JNGXrYN1Ecb2dmIao9PuPWFCi
         +fjQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXgP8LDIi+aQvlUxs+pbWPrkfKYI9J4uWxvkXqdzdO1zq1euRc6
	7D9hgzDqq9nYiwjXgx1gWC2pOXmHJoozaqVyy4nTXqc9IGSlXa918KQnv1l6mYYv9lcstdp2cU1
	9jnuDtrrHQYRqBQrJRM20h8AALCPAzvMif+Gb30Elb6Ycq5LMt+22jXTOAmsde8Wrrg==
X-Received: by 2002:ac8:2cb0:: with SMTP id 45mr16768696qtw.92.1555963789086;
        Mon, 22 Apr 2019 13:09:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqws4jSIsaMR9PIIuuwwAgr39soZSyPqZBkGIepzHFs3rq/9EPxIf7yGS2A+iqqi/IqQUPYS
X-Received: by 2002:ac8:2cb0:: with SMTP id 45mr16768646qtw.92.1555963788376;
        Mon, 22 Apr 2019 13:09:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555963788; cv=none;
        d=google.com; s=arc-20160816;
        b=xpc3MgKDkvy6YLBnyIM5bM9fOo7VbMEqkkwR2dEKfKgxbv/1fluJQWTWCDciIplfAC
         b7Ly+9b96eu+pkfljiXPb3vm2ETxJ3mhR9RrL7u4lvzUVOi+QXYFazwLDqq4qFd0xWKY
         70XnkHPxBFlKapsRXVwr18lkGfCD8i8V9xxMBXs8uD1tzaft6VXDhNu81mpXk9vrKN4M
         38Q7ZTL18qgHtbJbDqyEf0NKM6qjKj7QeGo+kmum8OZ/YjumZVp3LSbowtPCJpNccD/v
         e1n1xsfMQdg2Lk2ZculDAqAB0cUThEDXdeCUys47rRSDjx+qVzhHMG5yqgP/TzhfLeJ3
         sm6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=OS2hVKKW50ZmouHzSRmPm/efY8EnPT5441lUIE9oysQ=;
        b=j5R0maAH/Y+V3+KaTAyPGn/J3DMA11aUazVTzPEfry3ihYux2m1NQobzwYtvd3MCji
         04hrdM4zbqPyCoQ5yML/+Xqy8DxbvacF3Xi5MhT0u4DE5Wyj1PYNGQoFMXbV3A4FakHF
         aJyfAKFF6NkEztBhmV7QrtY5QzL/QBsjAbR/ZvP6znnlf0REyPsuYwvYFZ+OR6nAQorA
         UN0LnQthkSXPxH2h3gVl3cUTSyen1W+yZS75di5Qh3bo9fO7YZ1AbTfk87slk4YrUh17
         4bN3mxHvUxLioboMNsphDotbIdUM+LybaGhA5HnuUDOUk9Jk3DLOFrB7R6VqoNG2C30J
         VKVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n201si551538qka.248.2019.04.22.13.09.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 13:09:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1D7CC59468;
	Mon, 22 Apr 2019 20:09:47 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 6880917CFF;
	Mon, 22 Apr 2019 20:09:43 +0000 (UTC)
Date: Mon, 22 Apr 2019 16:09:36 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Laurent Dufour <ldufour@linux.ibm.com>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org,
	kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net,
	jack@suse.cz, Matthew Wilcox <willy@infradead.org>,
	aneesh.kumar@linux.ibm.com, benh@kernel.crashing.org,
	mpe@ellerman.id.au, paulus@samba.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, hpa@zytor.com,
	Will Deacon <will.deacon@arm.com>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	sergey.senozhatsky.work@gmail.com,
	Andrea Arcangeli <aarcange@redhat.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	kemi.wang@intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>,
	David Rientjes <rientjes@google.com>,
	Ganesh Mahendran <opensource.ganesh@gmail.com>,
	Minchan Kim <minchan@kernel.org>,
	Punit Agrawal <punitagrawal@gmail.com>,
	vinayak menon <vinayakm.list@gmail.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	zhong jiang <zhongjiang@huawei.com>,
	Haiyan Song <haiyanx.song@intel.com>,
	Balbir Singh <bsingharora@gmail.com>, sj38.park@gmail.com,
	Michel Lespinasse <walken@google.com>,
	Mike Rapoport <rppt@linux.ibm.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com,
	paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>,
	linuxppc-dev@lists.ozlabs.org, x86@kernel.org
Subject: Re: [PATCH v12 14/31] mm/migrate: Pass vm_fault pointer to
 migrate_misplaced_page()
Message-ID: <20190422200936.GE14666@redhat.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <20190416134522.17540-15-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190416134522.17540-15-ldufour@linux.ibm.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Mon, 22 Apr 2019 20:09:47 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 03:45:05PM +0200, Laurent Dufour wrote:
> migrate_misplaced_page() is only called during the page fault handling so
> it's better to pass the pointer to the struct vm_fault instead of the vma.
> 
> This way during the speculative page fault path the saved vma->vm_flags
> could be used.
> 
> Acked-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

> ---
>  include/linux/migrate.h | 4 ++--
>  mm/memory.c             | 2 +-
>  mm/migrate.c            | 4 ++--
>  3 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> index e13d9bf2f9a5..0197e40325f8 100644
> --- a/include/linux/migrate.h
> +++ b/include/linux/migrate.h
> @@ -125,14 +125,14 @@ static inline void __ClearPageMovable(struct page *page)
>  #ifdef CONFIG_NUMA_BALANCING
>  extern bool pmd_trans_migrating(pmd_t pmd);
>  extern int migrate_misplaced_page(struct page *page,
> -				  struct vm_area_struct *vma, int node);
> +				  struct vm_fault *vmf, int node);
>  #else
>  static inline bool pmd_trans_migrating(pmd_t pmd)
>  {
>  	return false;
>  }
>  static inline int migrate_misplaced_page(struct page *page,
> -					 struct vm_area_struct *vma, int node)
> +					 struct vm_fault *vmf, int node)
>  {
>  	return -EAGAIN; /* can't migrate now */
>  }
> diff --git a/mm/memory.c b/mm/memory.c
> index d0de58464479..56802850e72c 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3747,7 +3747,7 @@ static vm_fault_t do_numa_page(struct vm_fault *vmf)
>  	}
>  
>  	/* Migrate to the requested node */
> -	migrated = migrate_misplaced_page(page, vma, target_nid);
> +	migrated = migrate_misplaced_page(page, vmf, target_nid);
>  	if (migrated) {
>  		page_nid = target_nid;
>  		flags |= TNF_MIGRATED;
> diff --git a/mm/migrate.c b/mm/migrate.c
> index a9138093a8e2..633bd9abac54 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1938,7 +1938,7 @@ bool pmd_trans_migrating(pmd_t pmd)
>   * node. Caller is expected to have an elevated reference count on
>   * the page that will be dropped by this function before returning.
>   */
> -int migrate_misplaced_page(struct page *page, struct vm_area_struct *vma,
> +int migrate_misplaced_page(struct page *page, struct vm_fault *vmf,
>  			   int node)
>  {
>  	pg_data_t *pgdat = NODE_DATA(node);
> @@ -1951,7 +1951,7 @@ int migrate_misplaced_page(struct page *page, struct vm_area_struct *vma,
>  	 * with execute permissions as they are probably shared libraries.
>  	 */
>  	if (page_mapcount(page) != 1 && page_is_file_cache(page) &&
> -	    (vma->vm_flags & VM_EXEC))
> +	    (vmf->vma_flags & VM_EXEC))
>  		goto out;
>  
>  	/*
> -- 
> 2.21.0
> 

