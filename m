Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD1B8C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 23:49:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 94C05208CA
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 23:49:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 94C05208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 207B66B0010; Wed, 12 Jun 2019 19:49:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B8A26B0266; Wed, 12 Jun 2019 19:49:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 080E36B0269; Wed, 12 Jun 2019 19:49:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id C692E6B0010
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 19:49:13 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id y5so13085721pfb.20
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 16:49:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=wq9rAsPaxnT+MWeaQyCG0bTAAecSDhi0iHcA45NgI+k=;
        b=EgURH6TmK8eVAVgpV+mflAvYKhejhR1v66RUswB3vntZYm9BQOyxRB2muDN+y0FZ9d
         Lpc1JONeNlNHM9Amw4JFC1izDgOoDKTZR3S74FeXwZDU5hAeHJVtQL1uod+1H+DvV/04
         rEQSJpAhSPPp1eUkrmcrgxeclR89Dw/WzWgKvgUdYao0yNTdPUIsxDJ1nXzKs7ozsfEA
         Ig8el+3n9voGEXiYYj/XoiutN/y6p/oy/SzgKamOYAwpig5rQ8r2MaeYFMSgm9glOd8g
         OnMF1sw+Q/ff6IptLza8r2UfWx0lMpEiE0/njAdWU3d/zS1YVjAJKT9BwH+VU83l9tWF
         79RA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXt5zD6HshpzZp5u/MQJ/elgdB6pzfQqsyNtL19bFeKHry5ZfwV
	Wp4sRKAwtWU9uXB02qHgCEh4+3RmiYBSug+ZQ/DBALHHSzqtDXREcdmIMvv+P6yxgd1dGzs735z
	Fpg+SWw5hYZ88/28ZCoMA7gmgHyNIqUbdu7LjDTf9qosJImoIoal8/fKoDIcIVjJxUg==
X-Received: by 2002:a17:90a:ac0e:: with SMTP id o14mr1762535pjq.142.1560383353446;
        Wed, 12 Jun 2019 16:49:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyhu/jLXaoxBxXE3PuE9fdsa+Vct25a1gn9HkRmDHAaRftHYmvNSkK/HCE8BYWSPAZa8tHX
X-Received: by 2002:a17:90a:ac0e:: with SMTP id o14mr1762486pjq.142.1560383352640;
        Wed, 12 Jun 2019 16:49:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560383352; cv=none;
        d=google.com; s=arc-20160816;
        b=xi2UnsYH43xMRovi70fD3yv37bCdQ1ZnhzeCc8dd+5dkYSWlWxpyLyMnrmFe10qfrF
         g4d6GvQeaB7a2OV9J4iZLNiMHWPJo3rGWgbOURTqidVJfJuAvD3Z6wK+zI+nE2I1iOaG
         IFkwghS9AqO+I8suoraq7/q0qmWZhh3S/OPHXHahjgkuSecagAlBvmtkMv3hFdwnxv6I
         V4Rubba70wjVjvG7Rw6X4F3vih3ej8PU50cjUR4CkN9nIZFPDR2NXjYy0UAAbonruwhb
         /YhNfurJBLut+WXRxM/6OrfrBeDMJ/HMMTe77cNypKpLTjVzJ5L/C2M3V3cXHSjQ1ZHP
         Wbfg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=wq9rAsPaxnT+MWeaQyCG0bTAAecSDhi0iHcA45NgI+k=;
        b=Lf/UqmW+LItFrdg5w/TTdMVL6vj+0A29GQlZ7EmnFAXuTq/zgqGxdesIh9czARQ16x
         nlB79zkNAVRLlnEw8+mcxu9p2lb8fv97w3iAzatOfihu3rJ+DDG7HIBwJrTlbyQb1uHQ
         LOLHtz3kUzfJbRkp78zMM3GQHoHHdEInlmyEb5Q9wqdRUnRJQhfMKki20aQ3Y5o3W1yt
         EnnFGIXPVROIH7AJPu+8pB5ruV3C+M4WV35k7UcYT5L44RN+xFA6apPVFNKy9iIgAbuz
         lGB+0sUwyPy5u5HodQMdgHH7yEhyJ8TBrYkEQ6nQ8fuQryHPwgnzjV4zsd8u6cIJdUYf
         4JzA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id n13si1097985pgv.304.2019.06.12.16.49.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 16:49:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 12 Jun 2019 16:49:11 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga002.jf.intel.com with ESMTP; 12 Jun 2019 16:49:11 -0700
Date: Wed, 12 Jun 2019 16:50:31 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	"Williams, Dan J" <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	John Hubbard <jhubbard@nvidia.com>,
	"Busch, Keith" <keith.busch@intel.com>,
	Christoph Hellwig <hch@infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCHv3 1/2] mm/gup: fix omission of check on FOLL_LONGTERM in
 get_user_pages_fast()
Message-ID: <20190612235031.GF14336@iweiny-DESK2.sc.intel.com>
References: <1559725820-26138-1-git-send-email-kernelfans@gmail.com>
 <87tvcwhzdo.fsf@linux.ibm.com>
 <2807E5FD2F6FDA4886F6618EAC48510E79D8D79B@CRSMSX101.amr.corp.intel.com>
 <20190612135458.GA19916@dhcp-128-55.nay.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190612135458.GA19916@dhcp-128-55.nay.redhat.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 09:54:58PM +0800, Pingfan Liu wrote:
> On Tue, Jun 11, 2019 at 04:29:11PM +0000, Weiny, Ira wrote:
> > > Pingfan Liu <kernelfans@gmail.com> writes:
> > > 
> > > > As for FOLL_LONGTERM, it is checked in the slow path
> > > > __gup_longterm_unlocked(). But it is not checked in the fast path,
> > > > which means a possible leak of CMA page to longterm pinned requirement
> > > > through this crack.
> > > 
> > > Shouldn't we disallow FOLL_LONGTERM with get_user_pages fastpath? W.r.t
> > > dax check we need vma to ensure whether a long term pin is allowed or not.
> > > If FOLL_LONGTERM is specified we should fallback to slow path.
> > 
> > Yes, the fastpath bails to the slowpath if FOLL_LONGTERM _and_ DAX.  But it does this while walking the page tables.  I missed the CMA case and Pingfan's patch fixes this.  We could check for CMA pages while walking the page tables but most agreed that it was not worth it.  For DAX we already had checks for *_devmap() so it was easier to put the FOLL_LONGTERM checks there.
> > 
> Then for CMA pages, are you suggesting something like:

I'm not suggesting this.

Sorry I wrote this prior to seeing the numbers in your other email.  Given
the numbers it looks like performing the check whilst walking the tables is
worth the extra complexity.  I was just trying to summarize the thread.  I
don't think we should disallow FOLL_LONGTERM because it only affects CMA and
DAX.  Other pages will be fine with FOLL_LONGTERM.  Why penalize every call if
we don't have to.  Also in the case of DAX the use of vma will be going
away...[1]  Eventually...  ;-)

Ira

[1] https://lkml.org/lkml/2019/6/5/1049

> diff --git a/mm/gup.c b/mm/gup.c
> index 42a47c0..8bf3cc3 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -2251,6 +2251,8 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
>         if (unlikely(!access_ok((void __user *)start, len)))
>                 return -EFAULT;
> 
> +       if (unlikely(gup_flags & FOLL_LONGTERM))
> +               goto slow;
>         if (gup_fast_permitted(start, nr_pages)) {
>                 local_irq_disable();
>                 gup_pgd_range(addr, end, gup_flags, pages, &nr);
> @@ -2258,6 +2260,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
>                 ret = nr;
>         }
> 
> +slow:
>         if (nr < nr_pages) {
>                 /* Try to get the remaining pages with get_user_pages */
>                 start += nr << PAGE_SHIFT;
> 
> Thanks,
>   Pingfan

