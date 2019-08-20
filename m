Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1DA17C3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 14:00:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D5A0D22DA9
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 14:00:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ooeAB8Xe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D5A0D22DA9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 74F776B000A; Tue, 20 Aug 2019 10:00:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6FF216B000D; Tue, 20 Aug 2019 10:00:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 616C46B000E; Tue, 20 Aug 2019 10:00:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0229.hostedemail.com [216.40.44.229])
	by kanga.kvack.org (Postfix) with ESMTP id 41F7D6B000A
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 10:00:25 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id EFC9D8248AB2
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 14:00:24 +0000 (UTC)
X-FDA: 75842965968.17.coach02_5adf466d12c5a
X-HE-Tag: coach02_5adf466d12c5a
X-Filterd-Recvd-Size: 4102
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf29.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 14:00:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=TWRaZEAnHrNRlH8ifo3ZQD1iiyxnRF/NRhravPIs25c=; b=ooeAB8XeFx9mkV2wPTzJifUFx
	pwnZtTMR71QaoAV8FOdoBxW7MNR4Mz1zwoow92gi4p/SdNJR06JiZfl/mjclbj93gBZsxfiAayZHV
	JKTp+WGmnFvobB47nn2zHVTG6mKwGQvTt+GVwvR9fi4sJE01o/IStNzFyiuOfyWafDq7PDwDHSPFB
	XUzKT3HFjvdiIA9IHiCz457fuEkDJRoQZT3gg+Ue3jstT0SAnx2JG1ynaxg/ADd5zYr8+0xJmPe7c
	RO4mgPibT3qwx/z9KDiaY7OG5OVPxGNbWqKoz8pw/RpP6nItpEsVzU412On0kN7wv+pJ69t9aKbGL
	esejxAqyw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i04gN-00068l-V4; Tue, 20 Aug 2019 14:00:19 +0000
Date: Tue, 20 Aug 2019 07:00:19 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Alex Shi <alex.shi@linux.alibaba.com>
Cc: cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Dan Williams <dan.j.williams@intel.com>,
	Vlastimil Babka <vbabka@suse.cz>, Ira Weiny <ira.weiny@intel.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Jann Horn <jannh@google.com>, Logan Gunthorpe <logang@deltatee.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	"Tobin C. Harding" <tobin@kernel.org>,
	Michal Hocko <mhocko@suse.com>, Oscar Salvador <osalvador@suse.de>,
	Wei Yang <richard.weiyang@gmail.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Pavel Tatashin <pasha.tatashin@oracle.com>,
	Arun KS <arunks@codeaurora.org>,
	"Darrick J. Wong" <darrick.wong@oracle.com>,
	Amir Goldstein <amir73il@gmail.com>,
	Dave Chinner <dchinner@redhat.com>,
	Josef Bacik <josef@toxicpanda.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Hugh Dickins <hughd@google.com>,
	Kirill Tkhai <ktkhai@virtuozzo.com>,
	Daniel Jordan <daniel.m.jordan@oracle.com>,
	Yafang Shao <laoar.shao@gmail.com>,
	Yang Shi <yang.shi@linux.alibaba.com>
Subject: Re: [PATCH 14/14] mm/lru: fix the comments of lru_lock
Message-ID: <20190820140019.GB24642@bombadil.infradead.org>
References: <1566294517-86418-1-git-send-email-alex.shi@linux.alibaba.com>
 <1566294517-86418-15-git-send-email-alex.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1566294517-86418-15-git-send-email-alex.shi@linux.alibaba.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 20, 2019 at 05:48:37PM +0800, Alex Shi wrote:
> @@ -159,7 +159,7 @@ static inline bool free_area_empty(struct free_area *area, int migratetype)
>  struct pglist_data;
>  
>  /*
> - * zone->lock and the zone lru_lock are two of the hottest locks in the kernel.
> + * zone->lock and the lru_lock are two of the hottest locks in the kernel.
>   * So add a wild amount of padding here to ensure that they fall into separate
>   * cachelines.  There are very few zone structures in the machine, so space
>   * consumption is not a concern here.

But after this patch series, the lru lock is no longer stored in the zone.
So this comment makes no sense.

> @@ -295,7 +295,7 @@ struct zone_reclaim_stat {
>  
>  struct lruvec {
>  	struct list_head		lists[NR_LRU_LISTS];
> -	/* move lru_lock to per lruvec for memcg */
> +	/* perf lruvec lru_lock for memcg */

What does the word 'perf' mean here?


