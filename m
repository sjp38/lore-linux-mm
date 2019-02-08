Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A81D7C282CC
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 10:32:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6054720823
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 10:32:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6054720823
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED5B68E0089; Fri,  8 Feb 2019 05:32:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E83C48E0002; Fri,  8 Feb 2019 05:32:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D73658E0089; Fri,  8 Feb 2019 05:32:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id AAE778E0002
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 05:32:28 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id b6so2871904qkg.4
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 02:32:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=g0IDnbDno8Vq5B7UYgs5m8vgSufF8+rInYGyF2Rur5w=;
        b=ppCWuWMHqxsg4iEDO789o4n4jqGV8BqJ1uNHnvhDeqbgMAmZyzvu2WTMdkyWX1mjCE
         OvcU/1WoTOZrYGYmJHIHsUXz70brXDv9auodnYo15v+lVp6j/XlLOd3naoB2IiTXid4V
         iQwHA3qkQvOpz5jyiQcJBDLgOnR595vabKEaNmZtK04dAYsPXKy0yQba58Fdn3/G8hEX
         DwA9uKBrksdJsyCCUua4sYX36af/ySeadu7V6+z9yEQ+No3Tqm0nCCVRquyi1U4S7u2F
         M532NjCVe0+EUaCUkmuOu6yZSwctszcimTn7b2E0oknUFrAM5jzPn37SjN4PbaIUQVbs
         pNhw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAubotsLAayw+r5cPGkPbm92LpnWBUmIdoN/Ekkpa/jlXbjJa9akn
	tSMuW71oZZOGLYflbstyBfU0LCQA/JoGDI0qUsvfY0P/gft65vxYm/274kIl/eO+AEWiQD0MGy7
	zMA490Gt1s0mpQpy1R4pvjDnh7n9WL88j7beOBpDFh3w94Oam7p5l/zF5yRHn9vSvxQ==
X-Received: by 2002:ae9:e8c4:: with SMTP id a187mr14637345qkg.150.1549621948358;
        Fri, 08 Feb 2019 02:32:28 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZzChYBdMFIVb92QSCg4HBT3iTfqotXKXxELc837GueQNsDieBEdHdwvtv3cqWjnmaiRyES
X-Received: by 2002:ae9:e8c4:: with SMTP id a187mr14637311qkg.150.1549621947552;
        Fri, 08 Feb 2019 02:32:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549621947; cv=none;
        d=google.com; s=arc-20160816;
        b=yMQhPQVmu6jinAnF/BBZMJAkEOrAsF/MbjC/zIhcTZAJrv3IaPuuQwJhqZML1KH5FV
         qWAtfBI1pkCUVtUFxO7nzJZXXn7BGNK7qtrBz6Q1eEwbpzy7HR7ZjF7mJnzsnOMOXMgV
         1emAZlLbDebYENZVxb9rvSnr2MYVtdV09czlNaAqfjnkjH94MtfjTCEPmVpM11p+qy7K
         f2/5Z7uYrtsZ2F4I0zdTJqc51Pg740Z/Tau32fnPTg/11Nl6+PNhfeKR7hm7tetDbgtJ
         5x39NJk3X+a8kXe4OGgaEXhOjg0Xvol+Ju2G8cItSkpCW984wDdOLVAtw1c5RzfuaLfi
         RrdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=g0IDnbDno8Vq5B7UYgs5m8vgSufF8+rInYGyF2Rur5w=;
        b=qkObOA9d8RYIZ5AhKlmkeSO+J2nqvfQBKn2upNl3Vy8DvFihrB3XQmnK3YAPil+1yP
         tCoDUUM+COLRGc1rOzMJYbBjPAjuBqOYuWcn33fD7Pjk380tf9I8jk8KABI23nehGdpd
         Nyrg6VQ0vPf72WhcLMwpxWNvEzjXPndN4iLO8OPXc4F7tn0HTJOtZaFlLNuAcAr5Sosq
         +XIn9eBMPZ+uUDJtY9kjgX3wJa9MrjEhjrd/sAJLXp8b+9yfu6EMQc9ZFXrlDZ1LxQbK
         FD/WeLfyrJgPyc/otsZS5ysv4dJY3NJyn8FOmxWtDIJCyqLPxdFRbRNsAYVpUwHP/ZY7
         8Gsw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x3si575458qts.341.2019.02.08.02.32.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Feb 2019 02:32:27 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x18AVN6Y134614
	for <linux-mm@kvack.org>; Fri, 8 Feb 2019 05:32:27 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qh5hrq08p-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 08 Feb 2019 05:32:26 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Fri, 8 Feb 2019 10:32:23 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 8 Feb 2019 10:32:17 -0000
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x18AWFLa60555502
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 8 Feb 2019 10:32:16 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id CDC3AA4060;
	Fri,  8 Feb 2019 10:32:15 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id E2B7EA4054;
	Fri,  8 Feb 2019 10:32:13 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.205.183])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Fri,  8 Feb 2019 10:32:13 +0000 (GMT)
Date: Fri, 8 Feb 2019 12:32:12 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: john.hubbard@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
        Al Viro <viro@zeniv.linux.org.uk>,
        Christian Benvenuti <benve@cisco.com>,
        Christoph Hellwig <hch@infradead.org>,
        Christopher Lameter <cl@linux.com>,
        Dan Williams <dan.j.williams@intel.com>,
        Dave Chinner <david@fromorbit.com>,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Doug Ledford <dledford@redhat.com>, Jan Kara <jack@suse.cz>,
        Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>,
        Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>,
        Mike Marciniszyn <mike.marciniszyn@intel.com>,
        Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>,
        LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
        John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
References: <20190208075649.3025-1-jhubbard@nvidia.com>
 <20190208075649.3025-2-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190208075649.3025-2-jhubbard@nvidia.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19020810-4275-0000-0000-0000030D0747
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19020810-4276-0000-0000-0000381B12D4
Message-Id: <20190208103211.GD11096@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-08_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902080076
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 07, 2019 at 11:56:48PM -0800, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> Introduces put_user_page(), which simply calls put_page().
> This provides a way to update all get_user_pages*() callers,
> so that they call put_user_page(), instead of put_page().
> 
> Also introduces put_user_pages(), and a few dirty/locked variations,
> as a replacement for release_pages(), and also as a replacement
> for open-coded loops that release multiple pages.
> These may be used for subsequent performance improvements,
> via batching of pages to be released.
> 
> This is the first step of fixing a problem (also described in [1] and
> [2]) with interactions between get_user_pages ("gup") and filesystems.
> 
> Problem description: let's start with a bug report. Below, is what happens
> sometimes, under memory pressure, when a driver pins some pages via gup,
> and then marks those pages dirty, and releases them. Note that the gup
> documentation actually recommends that pattern. The problem is that the
> filesystem may do a writeback while the pages were gup-pinned, and then the
> filesystem believes that the pages are clean. So, when the driver later
> marks the pages as dirty, that conflicts with the filesystem's page
> tracking and results in a BUG(), like this one that I experienced:
> 
>     kernel BUG at /build/linux-fQ94TU/linux-4.4.0/fs/ext4/inode.c:1899!
>     backtrace:
>         ext4_writepage
>         __writepage
>         write_cache_pages
>         ext4_writepages
>         do_writepages
>         __writeback_single_inode
>         writeback_sb_inodes
>         __writeback_inodes_wb
>         wb_writeback
>         wb_workfn
>         process_one_work
>         worker_thread
>         kthread
>         ret_from_fork
> 
> ...which is due to the file system asserting that there are still buffer
> heads attached:
> 
>         ({                                                      \
>                 BUG_ON(!PagePrivate(page));                     \
>                 ((struct buffer_head *)page_private(page));     \
>         })
> 
> Dave Chinner's description of this is very clear:
> 
>     "The fundamental issue is that ->page_mkwrite must be called on every
>     write access to a clean file backed page, not just the first one.
>     How long the GUP reference lasts is irrelevant, if the page is clean
>     and you need to dirty it, you must call ->page_mkwrite before it is
>     marked writeable and dirtied. Every. Time."
> 
> This is just one symptom of the larger design problem: filesystems do not
> actually support get_user_pages() being called on their pages, and letting
> hardware write directly to those pages--even though that patter has been
> going on since about 2005 or so.
> 
> The steps are to fix it are:
> 
> 1) (This patch): provide put_user_page*() routines, intended to be used
>    for releasing pages that were pinned via get_user_pages*().
> 
> 2) Convert all of the call sites for get_user_pages*(), to
>    invoke put_user_page*(), instead of put_page(). This involves dozens of
>    call sites, and will take some time.
> 
> 3) After (2) is complete, use get_user_pages*() and put_user_page*() to
>    implement tracking of these pages. This tracking will be separate from
>    the existing struct page refcounting.
> 
> 4) Use the tracking and identification of these pages, to implement
>    special handling (especially in writeback paths) when the pages are
>    backed by a filesystem.
> 
> [1] https://lwn.net/Articles/774411/ : "DMA and get_user_pages()"
> [2] https://lwn.net/Articles/753027/ : "The Trouble with get_user_pages()"
> 
> Cc: Al Viro <viro@zeniv.linux.org.uk>
> Cc: Christoph Hellwig <hch@infradead.org>
> Cc: Christopher Lameter <cl@linux.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Dave Chinner <david@fromorbit.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Jason Gunthorpe <jgg@ziepe.ca>
> Cc: Jerome Glisse <jglisse@redhat.com>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Mike Rapoport <rppt@linux.ibm.com>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> 
> Reviewed-by: Jan Kara <jack@suse.cz>
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> ---
>  include/linux/mm.h | 24 ++++++++++++++
>  mm/swap.c          | 82 ++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 106 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 80bb6408fe73..809b7397d41e 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -993,6 +993,30 @@ static inline void put_page(struct page *page)
>  		__put_page(page);
>  }
>  
> +/**
> + * put_user_page() - release a gup-pinned page
> + * @page:            pointer to page to be released
> + *
> + * Pages that were pinned via get_user_pages*() must be released via
> + * either put_user_page(), or one of the put_user_pages*() routines
> + * below. This is so that eventually, pages that are pinned via
> + * get_user_pages*() can be separately tracked and uniquely handled. In
> + * particular, interactions with RDMA and filesystems need special
> + * handling.
> + *
> + * put_user_page() and put_page() are not interchangeable, despite this early
> + * implementation that makes them look the same. put_user_page() calls must

I just hope we'll remember to update when the real implementation will be
merged ;-)

Other than that, feel free to add

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>	# docs 

> + * be perfectly matched up with get_user_page() calls.
> + */
> +static inline void put_user_page(struct page *page)
> +{
> +	put_page(page);
> +}
> +
> +void put_user_pages_dirty(struct page **pages, unsigned long npages);
> +void put_user_pages_dirty_lock(struct page **pages, unsigned long npages);
> +void put_user_pages(struct page **pages, unsigned long npages);
> +
>  #if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
>  #define SECTION_IN_PAGE_FLAGS
>  #endif
> diff --git a/mm/swap.c b/mm/swap.c
> index 4929bc1be60e..7c42ca45bb89 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -133,6 +133,88 @@ void put_pages_list(struct list_head *pages)
>  }
>  EXPORT_SYMBOL(put_pages_list);
>  
> +typedef int (*set_dirty_func)(struct page *page);
> +
> +static void __put_user_pages_dirty(struct page **pages,
> +				   unsigned long npages,
> +				   set_dirty_func sdf)
> +{
> +	unsigned long index;
> +
> +	for (index = 0; index < npages; index++) {
> +		struct page *page = compound_head(pages[index]);
> +
> +		if (!PageDirty(page))
> +			sdf(page);
> +
> +		put_user_page(page);
> +	}
> +}
> +
> +/**
> + * put_user_pages_dirty() - release and dirty an array of gup-pinned pages
> + * @pages:  array of pages to be marked dirty and released.
> + * @npages: number of pages in the @pages array.
> + *
> + * "gup-pinned page" refers to a page that has had one of the get_user_pages()
> + * variants called on that page.
> + *
> + * For each page in the @pages array, make that page (or its head page, if a
> + * compound page) dirty, if it was previously listed as clean. Then, release
> + * the page using put_user_page().
> + *
> + * Please see the put_user_page() documentation for details.
> + *
> + * set_page_dirty(), which does not lock the page, is used here.
> + * Therefore, it is the caller's responsibility to ensure that this is
> + * safe. If not, then put_user_pages_dirty_lock() should be called instead.
> + *
> + */
> +void put_user_pages_dirty(struct page **pages, unsigned long npages)
> +{
> +	__put_user_pages_dirty(pages, npages, set_page_dirty);
> +}
> +EXPORT_SYMBOL(put_user_pages_dirty);
> +
> +/**
> + * put_user_pages_dirty_lock() - release and dirty an array of gup-pinned pages
> + * @pages:  array of pages to be marked dirty and released.
> + * @npages: number of pages in the @pages array.
> + *
> + * For each page in the @pages array, make that page (or its head page, if a
> + * compound page) dirty, if it was previously listed as clean. Then, release
> + * the page using put_user_page().
> + *
> + * Please see the put_user_page() documentation for details.
> + *
> + * This is just like put_user_pages_dirty(), except that it invokes
> + * set_page_dirty_lock(), instead of set_page_dirty().
> + *
> + */
> +void put_user_pages_dirty_lock(struct page **pages, unsigned long npages)
> +{
> +	__put_user_pages_dirty(pages, npages, set_page_dirty_lock);
> +}
> +EXPORT_SYMBOL(put_user_pages_dirty_lock);
> +
> +/**
> + * put_user_pages() - release an array of gup-pinned pages.
> + * @pages:  array of pages to be marked dirty and released.
> + * @npages: number of pages in the @pages array.
> + *
> + * For each page in the @pages array, release the page using put_user_page().
> + *
> + * Please see the put_user_page() documentation for details.
> + */
> +void put_user_pages(struct page **pages, unsigned long npages)
> +{
> +	unsigned long index;
> +
> +	for (index = 0; index < npages; index++)
> +		put_user_page(pages[index]);
> +}
> +EXPORT_SYMBOL(put_user_pages);
> +
>  /*
>   * get_kernel_pages() - pin kernel pages in memory
>   * @kiov:	An array of struct kvec structures
> -- 
> 2.20.1
> 

-- 
Sincerely yours,
Mike.

