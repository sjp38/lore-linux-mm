Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D508DC10F11
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 18:09:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9822C2075B
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 18:09:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9822C2075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1EFB46B0003; Wed, 10 Apr 2019 14:09:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 19DBF6B0005; Wed, 10 Apr 2019 14:09:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 03FD66B0006; Wed, 10 Apr 2019 14:09:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id BBBC96B0003
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 14:09:04 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id c7so2226443plo.8
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 11:09:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=iX9gKT8W+8rBtFKz31EIx8hyUuPGIQ+33BPkDWxkeN8=;
        b=tI8JRYFr47UTMjLee+4dSnGshsKW5bACIS6eTgmyZtdWGfFxc67HxIVw0a8VRy6G++
         5/KdvNzpUN5W10z+9hFrWgH+UHkWmKrWGDokLZuucrKkctMoSt94ofis4oUSuFSeehIt
         xeyGgQCLvPyQRzOdFAsBd9w7ESEv0Pe18deBDiSmu5Y+sxD/kbO6k+0Upr4gB1qV7EFC
         UeQmyc/BWbQonYXKnZUSIR2fmuUJgZU+64Iiie0HTtaUpnuR2cUwsQi0VG/P70mW5+Xf
         uNnSJ3bVM+ipiL914n37L5xjyaxvgf9LuDNfoaHOOSZp8+6FvyLcT6hKhSEAnrpOxenW
         cjMw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUs2oqEpbRdSIB/HAxNUilquG670u/dWtqCKZjX1omBW+l0M5p+
	DzXXKEYyAfrNnRaRPcPHSyBcf4TTMJq4JgTclgqiWsRVybZdJM1nYgrB5HsVCvFO1L/X1r6ROB+
	VfPctj+lDY+82BX0VfOysDTgGFYIXJlwy0ajFJThdFL20/CiQUwf8VD6mIpP4bK8iWA==
X-Received: by 2002:a62:e418:: with SMTP id r24mr45104730pfh.52.1554919743932;
        Wed, 10 Apr 2019 11:09:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwZRU6JBrG+5oj1vC3dr58jYNUzN/+qfMymaCF7WQYxXhaI+nYg/eccKCE4COzWyWnidPdH
X-Received: by 2002:a62:e418:: with SMTP id r24mr45104662pfh.52.1554919743194;
        Wed, 10 Apr 2019 11:09:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554919743; cv=none;
        d=google.com; s=arc-20160816;
        b=0bGB7N6yHg1ALtHuVIXIGkvtEfYswLAExghfv3hyzGg3JxyxcQT4EIWwPOO/A5xWnU
         xIvSLuZnAYI4YwweyP5wNwqruApMt+7yJMyxoDG0tiCegop/A9os0AsrdBFLBJTMHBjK
         889lk4qv0xwLg0SLSfui8hZJiciB/w8cj5HnumkitgJwLJ0QdaRJPTrWcNti3uXeWRk4
         PfJ12ppbmdrVLuWHDfEJvZQnJEKDYuj0/nSv9B5pq3TLiJlVcmCE3iTK+LzA/uSIbCW0
         A0SCXYsKBpWqCno1ip2ShApuIJeLt9xgM8u8N6CQwlqKERawLH28XYiSne877oTd/mBU
         NuVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=iX9gKT8W+8rBtFKz31EIx8hyUuPGIQ+33BPkDWxkeN8=;
        b=tHu4IMKAVehacLHdDzr0upbxMMAecxhO9sH9ubBFDF8fue/qmvt3bJPHgcaLf5u1Ry
         HcUs7fWzkg9JSMyW/UxLtK0FaEOnWYbvcKP0HvCZp6XNYzhwhPbphCFeszrJmJ+j4Obt
         tKpOdBU7PVIiYCw1fgZu7vLJ2JcXN2EDVZMV9106tdl1ZCifrE2rdStbEfjoeur7d2Pp
         z2yTs01aZ+WfruwkH1JYqwDal+UEj9oYbrtDghd5RjerS8qofi+St4ZQgrABG/zaNfD+
         YtFT+W6gwbyGQOm7nJbCNgCcC73F3pLdAVqELoLtrwRNPrQkbU9lR7cCcTnaIi9mNQfm
         u63Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id i6si31932644pgj.329.2019.04.10.11.09.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 11:09:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 10 Apr 2019 11:09:02 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,334,1549958400"; 
   d="scan'208";a="141643445"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga003.jf.intel.com with ESMTP; 10 Apr 2019 11:09:01 -0700
Date: Wed, 10 Apr 2019 11:08:58 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Huang Shijie <sjhuang@iluvatar.ai>
Cc: Matthew Wilcox <willy@infradead.org>, akpm@linux-foundation.org,
	william.kucharski@oracle.com, palmer@sifive.com, axboe@kernel.dk,
	keescook@chromium.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/2] mm/gup.c: fix the wrong comments
Message-ID: <20190410180857.GD22989@iweiny-DESK2.sc.intel.com>
References: <20190408023746.16916-1-sjhuang@iluvatar.ai>
 <20190408141313.GU22763@bombadil.infradead.org>
 <20190409010832.GA28081@hsj-Precision-5520>
 <20190409202316.GA22989@iweiny-DESK2.sc.intel.com>
 <20190410011850.GA3640@hsj-Precision-5520>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190410011850.GA3640@hsj-Precision-5520>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 10, 2019 at 09:18:50AM +0800, Huang Shijie wrote:
> On Tue, Apr 09, 2019 at 01:23:16PM -0700, Ira Weiny wrote:
> > On Tue, Apr 09, 2019 at 09:08:33AM +0800, Huang Shijie wrote:
> > > On Mon, Apr 08, 2019 at 07:13:13AM -0700, Matthew Wilcox wrote:
> > > > On Mon, Apr 08, 2019 at 10:37:45AM +0800, Huang Shijie wrote:
> > > > > When CONFIG_HAVE_GENERIC_GUP is defined, the kernel will use its own
> > > > > get_user_pages_fast().
> > > > > 
> > > > > In the following scenario, we will may meet the bug in the DMA case:
> > > > > 	    .....................
> > > > > 	    get_user_pages_fast(start,,, pages);
> > > > > 	        ......
> > > > > 	    sg_alloc_table_from_pages(, pages, ...);
> > > > > 	    .....................
> > > > > 
> > > > > The root cause is that sg_alloc_table_from_pages() requires the
> > > > > page order to keep the same as it used in the user space, but
> > > > > get_user_pages_fast() will mess it up.
> > > > 
> > > > I don't understand how get_user_pages_fast() can return the pages in a
> > > > different order in the array from the order they appear in userspace.
> > > > Can you explain?
> > > Please see the code in gup.c:
> > > 
> > > 	int get_user_pages_fast(unsigned long start, int nr_pages,
> > > 				unsigned int gup_flags, struct page **pages)
> > > 	{
> > > 		.......
> > > 		if (gup_fast_permitted(start, nr_pages)) {
> > > 			local_irq_disable();
> > > 			gup_pgd_range(addr, end, gup_flags, pages, &nr);               // The @pages array maybe filled at the first time.
> > > 			local_irq_enable();
> > > 			ret = nr;
> > > 		}
> > > 		.......
> > > 		if (nr < nr_pages) {
> > > 			/* Try to get the remaining pages with get_user_pages */
> > > 			start += nr << PAGE_SHIFT;
> > > 			pages += nr;                                                  // The @pages is moved forward.
> > > 
> > > 			if (gup_flags & FOLL_LONGTERM) {
> > > 				down_read(&current->mm->mmap_sem);
> > > 				ret = __gup_longterm_locked(current, current->mm,      // The @pages maybe filled at the second time
> > >
> > 
> > Neither this nor the get_user_pages_unlocked is filling the pages a second
> The get_user_pages_unlocked() will call the handle_mm_fault which will allocate a
> new page for the empty PTE, and save the new page into the @pages array.

But shouldn't this happen if get_user_pages_unlocked() is called directly?

> 
> 
> > time.  It is adding to the page array having moved start and the page array
> > forward.
> 
> Yes. This will mess up the page order.
> 
> I will read the code again to check if I am wrong :)
> 
> > 
> > Are you doing a FOLL_LONGTERM GUP?  Or are you in the else clause below when
> > you get this bug?
> I do not use FOLL_LONGTERM, I just use the FOLL_WRITE.
> 
> So it seems it runs into the else clause below.

Ok thanks,
Ira

> 
> Thanks
> Huang Shijie
> 
> > 
> > Ira
> > 
> > > 							    start, nr_pages - nr,
> > > 							    pages, NULL, gup_flags);
> > > 				up_read(&current->mm->mmap_sem);
> > > 			} else {
> > > 				/*
> > > 				 * retain FAULT_FOLL_ALLOW_RETRY optimization if
> > > 				 * possible
> > > 				 */
> > > 				ret = get_user_pages_unlocked(start, nr_pages - nr,    // The @pages maybe filled at the second time.
> > > 							      pages, gup_flags);
> > > 			}
> > > 		}
> > > 
> > > 
> 

