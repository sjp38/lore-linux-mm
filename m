Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F393C4740C
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 16:43:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D5B2A21924
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 16:43:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D5B2A21924
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3CA2B6B0005; Mon,  9 Sep 2019 12:43:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3799A6B0006; Mon,  9 Sep 2019 12:43:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 268E06B0007; Mon,  9 Sep 2019 12:43:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0022.hostedemail.com [216.40.44.22])
	by kanga.kvack.org (Postfix) with ESMTP id 0978E6B0005
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 12:43:04 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 9A668443C
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 16:43:03 +0000 (UTC)
X-FDA: 75915951846.12.legs36_37b94487b9717
X-HE-Tag: legs36_37b94487b9717
X-Filterd-Recvd-Size: 4664
Received: from mga11.intel.com (mga11.intel.com [192.55.52.93])
	by imf08.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 16:43:02 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Sep 2019 09:43:01 -0700
X-IronPort-AV: E=Sophos;i="5.64,486,1559545200"; 
   d="scan'208";a="268129471"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga001-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Sep 2019 09:43:00 -0700
Message-ID: <171e0e86cde2012e8bda647c0370e902768ba0b5.camel@linux.intel.com>
Subject: Re: [PATCH v9 2/8] mm: Adjust shuffle code to allow for future
 coalescing
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Alexander Duyck
	 <alexander.duyck@gmail.com>
Cc: virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, mst@redhat.com, 
 catalin.marinas@arm.com, david@redhat.com, dave.hansen@intel.com, 
 linux-kernel@vger.kernel.org, willy@infradead.org, mhocko@kernel.org, 
 linux-mm@kvack.org, akpm@linux-foundation.org, will@kernel.org, 
 linux-arm-kernel@lists.infradead.org, osalvador@suse.de,
 yang.zhang.wz@gmail.com,  pagupta@redhat.com, konrad.wilk@oracle.com,
 nitesh@redhat.com, riel@surriel.com,  lcapitulino@redhat.com,
 wei.w.wang@intel.com, aarcange@redhat.com,  ying.huang@intel.com,
 pbonzini@redhat.com, dan.j.williams@intel.com,  fengguang.wu@intel.com,
 kirill.shutemov@linux.intel.com
Date: Mon, 09 Sep 2019 09:43:00 -0700
In-Reply-To: <20190909094700.bbslsxpuwvxmodal@box>
References: <20190907172225.10910.34302.stgit@localhost.localdomain>
	 <20190907172520.10910.83100.stgit@localhost.localdomain>
	 <20190909094700.bbslsxpuwvxmodal@box>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-09-09 at 12:47 +0300, Kirill A. Shutemov wrote:
> On Sat, Sep 07, 2019 at 10:25:20AM -0700, Alexander Duyck wrote:
> > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > 
> > Move the head/tail adding logic out of the shuffle code and into the
> > __free_one_page function since ultimately that is where it is really
> > needed anyway. By doing this we should be able to reduce the overhead
> > and can consolidate all of the list addition bits in one spot.
> > 
> > Reviewed-by: Dan Williams <dan.j.williams@intel.com>
> > Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > ---
> >   include/linux/mmzone.h |   12 --------
> >   mm/page_alloc.c        |   70 +++++++++++++++++++++++++++---------------------
> >   mm/shuffle.c           |    9 +-----
> >   mm/shuffle.h           |   12 ++++++++
> >   4 files changed, 53 insertions(+), 50 deletions(-)
> > 
> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > index bda20282746b..125f300981c6 100644
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -116,18 +116,6 @@ static inline void add_to_free_area_tail(struct page *page, struct free_area *ar
> >        area->nr_free++;
> >   }
> >   
> > -#ifdef CONFIG_SHUFFLE_PAGE_ALLOCATOR
> > -/* Used to preserve page allocation order entropy */
> > -void add_to_free_area_random(struct page *page, struct free_area *area,
> > -             int migratetype);
> > -#else
> > -static inline void add_to_free_area_random(struct page *page,
> > -             struct free_area *area, int migratetype)
> > -{
> > -     add_to_free_area(page, area, migratetype);
> > -}
> > -#endif
> > -
> >   /* Used for pages which are on another list */
> >   static inline void move_to_free_area(struct page *page, struct free_area *area,
> >                             int migratetype)
> 
> Looks like add_to_free_area() and add_to_free_area_tail() can be moved to
> mm/page_alloc.c as all users are there now. And the same for struct
> free_area definition (but not declaration).

This can probably be worked into patch 4 instead of doing it here. I could
pull all the functions that are renamed to _free_list from _free_area into
page_alloc.c and leave behind the ones that remained as _free_area such as
get_page_from_free_area. That should make it easier for me to avoid having
to include page_reporting.h in mmzone.h.

I'm not sure I follow what you are saying about the free_area definition.
It looks like it is a part of the zone structure so I would think it still
needs to be defined in the header.


