Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9EAC3C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 12:04:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C0EB20854
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 12:04:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="uqJznoMu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C0EB20854
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E5E656B0007; Tue, 19 Mar 2019 08:04:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE4D26B0008; Tue, 19 Mar 2019 08:04:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C5D7A6B000A; Tue, 19 Mar 2019 08:04:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 85F296B0007
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 08:04:25 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 18so3335767pgx.11
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 05:04:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=Zgr9l9vFtMckpomHDmXxh5bQX/YD3f/Lbmy6cvF9P3E=;
        b=VRpCKWYObqujJYPTJuRcNYf8Je36ogx355AHzHUOwPHmh5vtcwdF5r+LiMrUFcUc4B
         TBTLT991ovaXrU2h+0BGvsycRDU2qkbl2B/+24l3YA0+jOiuMACIsSMfyNo9IIQUzRVP
         GrkVstBFfGoxWFBB5pK6+hS0SrthfAgGR1MW9UaH7NS3swJP7dKoo3WhcTEZBnE46yBK
         duIFUOQlPbPQ1lZzi+8PkAEFCsMO5NxmlqrlrpIlspYur9Wdpn+VpJw3r9DVs3ozmUFt
         3s0sy3QkImo/i2svyBtVe7uw6ZLvq1JhcT5PNozU/vgTQmQr6XSlywPKP8DSuAyzOPwX
         L0+Q==
X-Gm-Message-State: APjAAAV7izELovT6dcOvjk/JNUtlEossKF2sb4P0aFvgd+BiqHNma4l8
	N2wHRdHCRNnhwJod3YA34bRzVkNTOWhYpftzTZW+UkqksfBAQN4/Fhj67TSUcKKXQyE986tckvn
	BdTPAF5+jP+JzpOm9JSBbQITtIQnksKz0VmBxmv05IbBWm6hyYffREx2knRVJxJG5Ww==
X-Received: by 2002:a17:902:864a:: with SMTP id y10mr3049932plt.76.1552997065095;
        Tue, 19 Mar 2019 05:04:25 -0700 (PDT)
X-Received: by 2002:a17:902:864a:: with SMTP id y10mr3049809plt.76.1552997063736;
        Tue, 19 Mar 2019 05:04:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552997063; cv=none;
        d=google.com; s=arc-20160816;
        b=R+UVzY//mRk9wK5Cvj/uwQ+yipnR+3eqQr3l0STNjRehNkt7AkStjAIxOAMoNdXIBK
         Zh+zAywtBnGHBgO4mjlvCr9OuiLydhPQqT4sQqROgB9FoIbcm4cylQvW+5j//MWyrYDA
         kxj6eKOlO9zGM0IKkcGobQbIgRh/eb3tsuOVzhG3ON85Tltk4eNOXgjKTvYH7IZMcVG0
         +k/5Q9ud0shbv1oy1PcAIfp5x7ndpcdly2fl3dONWpf2vG08kQe3fOJVbsJ2rQb+O43Y
         UxnXurPTGaXhMTRq89TxVR5kfs4n0VyLjrnycMA9FDdouQ6VG8hnT8RTFVh+ErzSeSGU
         94Mw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=Zgr9l9vFtMckpomHDmXxh5bQX/YD3f/Lbmy6cvF9P3E=;
        b=TV96/31ukzmcNHg36D2qb7s4urtoDhr2qE6lLEKjGFFgIv9HIRgQEXlg8sVgJjJObI
         8flqBhDYYumHcbK/R+Fe4D1aoXrKoIIIGqVs3Oaj+js3li9wxRQZtZCB4+KCZJCGeNfx
         CQMlQ5Zy3nq5T9MfvWOIIGW5T0NuY6FdB2BqtSGVE23WIPB52G/2zdh7S1DRD4VJp/C1
         fpPqaln6jVZ4Brv4xL/M8xzqsT7ShtWb7MGG3A9xEN11gm3Ag4FzHmOgHmfQPcMH9Fv2
         /c1w4t0LwM6lOXhtasW3XbupFUpVKVW7uwRMRGi/4uQ05y2QAF0uQj5e8k455xPXe/ep
         WF1w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=uqJznoMu;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bg2sor19146847plb.20.2019.03.19.05.04.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 05:04:23 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=uqJznoMu;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=Zgr9l9vFtMckpomHDmXxh5bQX/YD3f/Lbmy6cvF9P3E=;
        b=uqJznoMur6KVtluxllHSTMtLsmbXgtR6F/GqhjSsGj4wXKwnGvKiSKl5zAF/ilK+E2
         i2k5GmUGBMUTa3I46PDdjHdXrbyi+cgv1AnNt2K3KOoDvQJaHoHZvaJR5pYAR42vlEw7
         UIWkgdTGvxODpYZKuGhaCe0Yf7/8jG6Hr5tDMv81n027U6eP/SKhuCOwqDc/R9x1nLa+
         W+Ily/RA6E3P68zWuDGWNXYZDoII51WsATxbuyQ8YbSv/lFRdhaRYnDhdYc/P5cLWxMN
         Ucmn5CuA50W+hjNK1LW/PV92MDPQfYdzyF9sEQ1AHTmThzu8WwNmjqYyN/I81JgMe2Ae
         4MSA==
X-Google-Smtp-Source: APXvYqxF1h7pQA9SbXH4i0EHQvYqTodac3jez6r/o4a5QGCCaAGXGZyJJ9eLnT8hPP8mCtbSWgy5MQ==
X-Received: by 2002:a17:902:2963:: with SMTP id g90mr2175435plb.182.1552997062703;
        Tue, 19 Mar 2019 05:04:22 -0700 (PDT)
Received: from kshutemo-mobl1.localdomain (fmdmzpr04-ext.fm.intel.com. [192.55.54.39])
        by smtp.gmail.com with ESMTPSA id o14sm17438540pgn.65.2019.03.19.05.04.20
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 05:04:21 -0700 (PDT)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id 871C23011DA; Tue, 19 Mar 2019 15:04:17 +0300 (+03)
Date: Tue, 19 Mar 2019 15:04:17 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: john.hubbard@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>,
	Christopher Lameter <cl@linux.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>, Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>,
	Jerome Glisse <jglisse@redhat.com>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH v4 1/1] mm: introduce put_user_page*(), placeholder
 versions
Message-ID: <20190319120417.yzormwjhaeuu7jpp@kshutemo-mobl1>
References: <20190308213633.28978-1-jhubbard@nvidia.com>
 <20190308213633.28978-2-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190308213633.28978-2-jhubbard@nvidia.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 08, 2019 at 01:36:33PM -0800, john.hubbard@gmail.com wrote:
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
> This is just one symptom of the larger design problem: real filesystems
> that actually write to a backing device, do not actually support
> get_user_pages() being called on their pages, and letting hardware write
> directly to those pages--even though that pattern has been going on since
> about 2005 or so.
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
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Jason Gunthorpe <jgg@ziepe.ca>
> Cc: Jerome Glisse <jglisse@redhat.com>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Mike Rapoport <rppt@linux.ibm.com>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> 
> Reviewed-by: Jan Kara <jack@suse.cz>
> Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>    # docs
> Reviewed-by: Ira Weiny <ira.weiny@intel.com>
> Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> ---
>  include/linux/mm.h | 24 ++++++++++++++
>  mm/gup.c           | 82 ++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 106 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 5801ee849f36..353035c8b115 100644
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
> diff --git a/mm/gup.c b/mm/gup.c
> index f84e22685aaa..37085b8163b1 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -28,6 +28,88 @@ struct follow_page_context {
>  	unsigned int page_mask;
>  };
>  
> +typedef int (*set_dirty_func_t)(struct page *page);
> +
> +static void __put_user_pages_dirty(struct page **pages,
> +				   unsigned long npages,
> +				   set_dirty_func_t sdf)
> +{
> +	unsigned long index;
> +
> +	for (index = 0; index < npages; index++) {
> +		struct page *page = compound_head(pages[index]);
> +
> +		if (!PageDirty(page))
> +			sdf(page);

How is this safe? What prevents the page to be cleared under you?

If it's safe to race clear_page_dirty*() it has to be stated explicitly
with a reason why. It's not very clear to me as it is.

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

Have you checked if compiler is clever enough eliminate indirect function
call here? Maybe it's better to go with an opencodded approach and get rid
of callbacks?


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

I believe there's an room for improvement for compound pages.

If there's multiple consequential pages in the array that belong to the
same compound page we can get away with a single atomic operation to
handle them all.

> +}
> +EXPORT_SYMBOL(put_user_pages);
> +
>  static struct page *no_page_table(struct vm_area_struct *vma,
>  		unsigned int flags)
>  {
> -- 
> 2.21.0
> 

-- 
 Kirill A. Shutemov

