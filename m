Return-Path: <SRS0=tSF5=RI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.4 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB74EC43381
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 04:15:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6330120675
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 04:15:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6330120675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C8B7D8E0004; Mon,  4 Mar 2019 23:15:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C117F8E0001; Mon,  4 Mar 2019 23:15:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A8B2A8E0004; Mon,  4 Mar 2019 23:15:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 64B8A8E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 23:15:22 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id d2so7719283pfn.2
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 20:15:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=NrzUYlqt9JgzgwnvDtaQelEHqWQXPcanR2iTJv5jcKU=;
        b=rWETUoXS43spF7elwh9f+uiPvuqgYFYtKNpS5tQdFg1j2ijdRDNkSsi4eXG0lQN+gp
         rc6tVfnI9aFev1UyO9MaVxB8yU4q/NBBCOKDuyknjF4irMW+G3zOSMNm+sma5EasyvOs
         1Hq8ZLk293KTjyCrzxib7BrvrhRav0LdHEumUyBGJpf3tZHQz0aKdNV0nmHg8gNfAlqO
         k/YwRiLa009XL9bV5DRIJuHgS/RvPVZNo2SCAIHz42xZukCHfP9uioXdOBOUZmjSq4EA
         mFAqRceeqjNUBuHFvxdLr5nDiNWF6nIl3VFdvDYLC29mIA7U9fuPPgX3/zgWX7SH3rnm
         i1eQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVGH+WphrrPq6pn25b0nkSnwXeElFyTRellj9v5pg4vWY8TW+y8
	B3n6snudVY3is4TSfSMSd5VhzJPoNMqyYZp8gUutQRNu1DAMkKsgmTa4VDxHOW5eMmbnRTFtD7T
	FzgFJmIiZPfWgW1wnLnc6ew1SSqZQwo7RWZ/ep/CirtqIWDZJQ+ZROBrpSpc5X73f8w==
X-Received: by 2002:a17:902:2947:: with SMTP id g65mr24090640plb.258.1551759321715;
        Mon, 04 Mar 2019 20:15:21 -0800 (PST)
X-Google-Smtp-Source: APXvYqxO9wfymA2nnBQWweZ4nuXnFjtfv6xp9bIEZChvJvLLDWYS/1OpC36AxXWgKNJMNnN9gk26
X-Received: by 2002:a17:902:2947:: with SMTP id g65mr24090562plb.258.1551759320562;
        Mon, 04 Mar 2019 20:15:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551759320; cv=none;
        d=google.com; s=arc-20160816;
        b=ubA91onGP4s4NgiIIXax3PjYo3rm2dXzpypu2VQeACAv0BWJGxpy8RutCkmJ1l02aI
         I9L7gDJJeFaNnSQ4DKjlFDFJLqgV/fYS7i5VMEPdcKAKrY/bAE9CMDUAT0mC/c3HZYMy
         Uf9Fk7lCGE3yCHIaoCzw1CxCGWBDW56LCpri0T2xvmjRkd6nVsf9OTefY+ZY3GzGhvwD
         V8Pj1iim3flR/XoYShdgQMp2bJ1Yf5oQ46QbbmRwJMiAr59AeTXTVoJknkEQCtECgX4d
         EUUmJ5BtVrFg0o3HfJcCvGJnDwdERkoSlLgJRbJkJ6Zl9Tm7VGU79n7shsciO3lyD4a5
         QNVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=NrzUYlqt9JgzgwnvDtaQelEHqWQXPcanR2iTJv5jcKU=;
        b=ptyn0kFrLNkdYqc7RU/MJkPcAJ3iJIBoJ+Bp2iKdXeUxX45oZQjVkwtcdU78R+4mZg
         Wi8QI8ClkrirOBYW82Z9UUbUdQihOUFso30E9Jy/Gk91hrvx+S0lqNa5Wj2dC41qy84D
         Yq3kvjIoNwGAHH6eOB9tQztqugXlpXs6aJl0umCOunz1IliOKV739LWQPeOM28FYO5RY
         j8DVUSR5EI0HOvOuo+XY1y7o3yBFDYMGOOUrz0Msj1g9tEiHUP1gPKcrHbSdHujOO5KY
         OdMxiE4hPOyZDr7GjG5tgk/wm1rEkXT8wqZcxiJl0D+kFcCLeBNBah+wPSIzppUaDxnt
         pGBg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id x202si7090436pgx.24.2019.03.04.20.15.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Mar 2019 20:15:20 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 04 Mar 2019 20:15:19 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,442,1544515200"; 
   d="scan'208";a="131290433"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga003.jf.intel.com with ESMTP; 04 Mar 2019 20:15:18 -0800
Date: Mon, 4 Mar 2019 12:13:39 -0800
From: Ira Weiny <ira.weiny@intel.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Artemy Kovalyov <artemyko@mellanox.com>,
	"john.hubbard@gmail.com" <john.hubbard@gmail.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, Jason Gunthorpe <jgg@ziepe.ca>,
	Doug Ledford <dledford@redhat.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>
Subject: Re: [PATCH v2] RDMA/umem: minor bug fix and cleanup in error
 handling paths
Message-ID: <20190304201338.GA28731@iweiny-DESK2.sc.intel.com>
References: <20190302032726.11769-2-jhubbard@nvidia.com>
 <20190302202435.31889-1-jhubbard@nvidia.com>
 <20190302194402.GA24732@iweiny-DESK2.sc.intel.com>
 <2404c962-8f6d-1f6d-0055-eb82864ca7fc@mellanox.com>
 <20190303165550.GB27123@iweiny-DESK2.sc.intel.com>
 <bef8680b-acc5-9f13-f49e-8f36f1939387@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bef8680b-acc5-9f13-f49e-8f36f1939387@nvidia.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 04, 2019 at 03:11:05PM -0800, John Hubbard wrote:
> On 3/3/19 8:55 AM, Ira Weiny wrote:
> > On Sun, Mar 03, 2019 at 11:52:41AM +0200, Artemy Kovalyov wrote:
> >>
> >>
> >> On 02/03/2019 21:44, Ira Weiny wrote:
> >>>
> >>> On Sat, Mar 02, 2019 at 12:24:35PM -0800, john.hubbard@gmail.com wrote:
> >>>> From: John Hubbard <jhubbard@nvidia.com>
> >>>>
> >>>> ...
> >>>> 3. Dead code removal: the check for (user_virt & ~page_mask)
> >>>> is checking for a condition that can never happen,
> >>>> because earlier:
> >>>>
> >>>>      user_virt = user_virt & page_mask;
> >>>>
> >>>> ...so, remove that entire phrase.
> >>>>
> >>>>   		bcnt -= min_t(size_t, npages << PAGE_SHIFT, bcnt);
> >>>>   		mutex_lock(&umem_odp->umem_mutex);
> >>>>   		for (j = 0; j < npages; j++, user_virt += PAGE_SIZE) {
> >>>> -			if (user_virt & ~page_mask) {
> >>>> -				p += PAGE_SIZE;
> >>>> -				if (page_to_phys(local_page_list[j]) != p) {
> >>>> -					ret = -EFAULT;
> >>>> -					break;
> >>>> -				}
> >>>> -				put_page(local_page_list[j]);
> >>>> -				continue;
> >>>> -			}
> >>>> -
> >>>
> >>> I think this is trying to account for compound pages. (ie page_mask could
> >>> represent more than PAGE_SIZE which is what user_virt is being incrimented by.)
> >>> But putting the page in that case seems to be the wrong thing to do?
> >>>
> >>> Yes this was added by Artemy[1] now cc'ed.
> >>
> >> Right, this is for huge pages, please keep it.
> >> put_page() needed to decrement refcount of the head page.
> > 
> > You mean decrement the refcount of the _non_-head pages?
> > 
> > Ira
> > 
> 
> Actually, I'm sure Artemy means head page, because put_page() always
> operates on the head page. 
> 
> And this reminds me that I have a problem to solve nearby: get_user_pages
> on huge pages increments the page->_refcount *for each tail page* as well.
> That's a minor problem for my put_user_page() 
> patchset, because my approach so far assumed that I could just change us
> over to:
> 
> get_user_page(): increments page->_refcount by a large amount (1024)
> 
> put_user_page(): decrements page->_refcount by a large amount (1024)
> 
> ...and just stop doing the odd (to me) technique of incrementing once for
> each tail page. I cannot see any reason why that's actually required, as
> opposed to just "raise the page->_refcount enough to avoid losing the head
> page too soon".

What about splitting a huge page?

From Documention/vm/transhuge.rst

<quoute>
split_huge_page internally has to distribute the refcounts in the head
page to the tail pages before clearing all PG_head/tail bits from the page
structures. It can be done easily for refcounts taken by page table
entries. But we don't have enough information on how to distribute any
additional pins (i.e. from get_user_pages). split_huge_page() fails any
requests to split pinned huge page: it expects page count to be equal to
sum of mapcount of all sub-pages plus one (split_huge_page caller must
have reference for head page).
</quote>

FWIW, I'm not sure why it needs to "store" the reference in the head page for
this.  I don't see any check to make sure the ref has been "stored" but I'm not
really familiar with the compound page code yet.

Ira

> 
> However, it may be tricky to do this in one pass. Probably at first, I'll have
> to do this horrible thing approach:
> 
> get_user_page(): increments page->_refcount by a large amount (1024)
> 
> put_user_page(): decrements page->_refcount by a large amount (1024) MULTIPLIED
>                  by the number of tail pages. argghhh that's ugly.
> 
> thanks,
> -- 
> John Hubbard
> NVIDIA
> 

