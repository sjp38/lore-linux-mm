Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EEF96C10F05
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 09:28:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 90C942186A
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 09:28:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="EfTOEFcH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 90C942186A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 211696B0003; Wed, 20 Mar 2019 05:28:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C26A6B0006; Wed, 20 Mar 2019 05:28:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B1856B0007; Wed, 20 Mar 2019 05:28:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id C28766B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 05:28:44 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id u2so1891667pgi.10
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 02:28:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=PMKD8S5T9yArnDmdhpqN5MR0f4dumLtOhH5vwozX4IQ=;
        b=fCCBf3xIQ1qKKQX56AXyiXBsHiKqqCjbgxlLkb3BY4uVAMjPKQK9GpT2bYIV7ufIWL
         aMElmSq5CwHQEDUitAd5mZV2kDyrIw0oUooGMnASO2+Lt1l26QLn/A16Tfruq88L58Fw
         ir7+1RQODfUO7ILGBfviDD68rPnGexwTLh9c4r9cu4LylCVulhUsrVeroM6kG0mJictI
         TRCrdgTx0oDs1VrOyny098REpzcZ1hPA99khxbYf/f4QgfoF/kSuRNFDa+ueFL4Hx3nc
         fH8pAFuhvuNuvPtdN3JvsrUph8ac6O0IDsn0/LWOIR6IJxLmOE4KVDpYtBaFWTi32i5K
         yqtQ==
X-Gm-Message-State: APjAAAWmu3UP8hvfs0ByPN1YQxUC8rwVtFA8743fn2fAJqqYBKOQTVlz
	aDifq6/WSghgetgoNAs0EQd/+E2pnGJEUPLc00Y2XX0qaLpQ6mAU9opKihAaSHhasPUVFwj2fXL
	5eMSd+XVkGKOzxfD9t2gPxfztLYv7DDL2iq/r/WGC7tb1gecZ12ojjD81RPgn/yGz3w==
X-Received: by 2002:a17:902:2c01:: with SMTP id m1mr3552215plb.186.1553074124301;
        Wed, 20 Mar 2019 02:28:44 -0700 (PDT)
X-Received: by 2002:a17:902:2c01:: with SMTP id m1mr3552142plb.186.1553074123076;
        Wed, 20 Mar 2019 02:28:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553074123; cv=none;
        d=google.com; s=arc-20160816;
        b=dF5TpPJz0VlRENkLyFOrqpWvn1g4+l3Q6D+HQDF26Y2vMlc0a2ZrzcqmXgY8yJTKF4
         CvqO5888fOqLoonzII/d1aB8kv0fhxPwDRsTED7CaWDU5ldsjSB3pUBkCLHWa8bernRb
         Gu2iadopBSp9SH+pAQarFamtbrtY4TPFi+ERHiwiifSk3Hq5R/wCMFPJVV1xHX36YStf
         SY9urAoSDh9PyIp2JhBAmMCsUzZbuAXroRKhC8/UYIS226bu0cDtK3cKYmAfQJpFNuAK
         yLjDX2DAfksm8ozXI2Nw6TzdxPYFMoV13naVLql+5CmhvKkPHSQwmo/W4iLd6+in0tXz
         CgLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=PMKD8S5T9yArnDmdhpqN5MR0f4dumLtOhH5vwozX4IQ=;
        b=fuHWKZaPU/Y4NLaRASmnPuFCVcDdD2dvOFpKeWUQBJDplkocwjmtjKrPHulozFtPU3
         TpG6RHOCZQuA2cdzcr2vX5zALk83RHT9goRhV5MQL7UMniDyQkaQn2AhJdFt2K7swDWA
         aA5PpUihrpK8bAF6kQ22hyOlK1QUZk6rFH1guvieJiRWmYI7rdX+auPt0Az88tvc3Xcq
         CQDThxPzgGt7CE78dnr4NBsVz7WmbWnDFZ7udOnfg+LYdCPRW+6oxHf/V0EzV2BeQ6Um
         ojhCVNS48RfWUbhtWw1VPjOJ4h3/KwyXK/Q7nKOHYJ0/hRlOSdW+vA/PDg3dgmnT8cRe
         wNvg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=EfTOEFcH;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w16sor1581167pgj.38.2019.03.20.02.28.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 02:28:42 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=EfTOEFcH;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=PMKD8S5T9yArnDmdhpqN5MR0f4dumLtOhH5vwozX4IQ=;
        b=EfTOEFcH5cnj4doeFG9zxcqsWx8ydGaJhsKvypWgceFUIkZFyY9CLnRWTuxRLp1+ZS
         52khN2+/SXpeLN+uzhC8amB1KBLKmuL+A7F7NA3Tz5/o4x0mtKx0BnZ0QqPlzR43PN9R
         8f84HPNQDXtodyytZx/1A+4+Dcge4L78IVeSvcTfDRLBT+LvzT/nUNPjtzTh+drtfdg2
         B5Ycd2HGe8iPDKPew7MwVqh9UdCQ/rv8b/VBFDdh+Q6X5uPMpK1dY1DTc82hXg+lgkvC
         hK+ug40jMozhArURfK4G7FT7DBI4sFcFMUUfwPnKWrv3o0Omq/FksIP5NnnfzsyxYpoe
         7XMQ==
X-Google-Smtp-Source: APXvYqxSqLim0h0p/+px6G2tqdWX71LosiVLrLstelYvy1G6zCFngK8HljidHMKL3LjJ+hzG22N7Gw==
X-Received: by 2002:a17:902:b481:: with SMTP id y1mr3762966plr.338.1553074121866;
        Wed, 20 Mar 2019 02:28:41 -0700 (PDT)
Received: from kshutemo-mobl1.localdomain ([134.134.139.82])
        by smtp.gmail.com with ESMTPSA id e123sm2034061pfe.35.2019.03.20.02.28.40
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 02:28:40 -0700 (PDT)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id 783A13011DB; Wed, 20 Mar 2019 12:28:36 +0300 (+03)
Date: Wed, 20 Mar 2019 12:28:36 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jerome Glisse <jglisse@redhat.com>, john.hubbard@gmail.com,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>,
	Christopher Lameter <cl@linux.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>, Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v4 1/1] mm: introduce put_user_page*(), placeholder
 versions
Message-ID: <20190320092836.rbc3fscxxpibgt3m@kshutemo-mobl1>
References: <20190308213633.28978-1-jhubbard@nvidia.com>
 <20190308213633.28978-2-jhubbard@nvidia.com>
 <20190319120417.yzormwjhaeuu7jpp@kshutemo-mobl1>
 <20190319134724.GB3437@redhat.com>
 <20190319140623.tblqyb4dcjabjn3o@kshutemo-mobl1>
 <6aa32cca-d97a-a3e5-b998-c67d0a6cc52a@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6aa32cca-d97a-a3e5-b998-c67d0a6cc52a@nvidia.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 01:01:01PM -0700, John Hubbard wrote:
> On 3/19/19 7:06 AM, Kirill A. Shutemov wrote:
> > On Tue, Mar 19, 2019 at 09:47:24AM -0400, Jerome Glisse wrote:
> >> On Tue, Mar 19, 2019 at 03:04:17PM +0300, Kirill A. Shutemov wrote:
> >>> On Fri, Mar 08, 2019 at 01:36:33PM -0800, john.hubbard@gmail.com wrote:
> >>>> From: John Hubbard <jhubbard@nvidia.com>
> >>
> >> [...]
> >>
> >>>> diff --git a/mm/gup.c b/mm/gup.c
> >>>> index f84e22685aaa..37085b8163b1 100644
> >>>> --- a/mm/gup.c
> >>>> +++ b/mm/gup.c
> >>>> @@ -28,6 +28,88 @@ struct follow_page_context {
> >>>>  	unsigned int page_mask;
> >>>>  };
> >>>>  
> >>>> +typedef int (*set_dirty_func_t)(struct page *page);
> >>>> +
> >>>> +static void __put_user_pages_dirty(struct page **pages,
> >>>> +				   unsigned long npages,
> >>>> +				   set_dirty_func_t sdf)
> >>>> +{
> >>>> +	unsigned long index;
> >>>> +
> >>>> +	for (index = 0; index < npages; index++) {
> >>>> +		struct page *page = compound_head(pages[index]);
> >>>> +
> >>>> +		if (!PageDirty(page))
> >>>> +			sdf(page);
> >>>
> >>> How is this safe? What prevents the page to be cleared under you?
> >>>
> >>> If it's safe to race clear_page_dirty*() it has to be stated explicitly
> >>> with a reason why. It's not very clear to me as it is.
> >>
> >> The PageDirty() optimization above is fine to race with clear the
> >> page flag as it means it is racing after a page_mkclean() and the
> >> GUP user is done with the page so page is about to be write back
> >> ie if (!PageDirty(page)) see the page as dirty and skip the sdf()
> >> call while a split second after TestClearPageDirty() happens then
> >> it means the racing clear is about to write back the page so all
> >> is fine (the page was dirty and it is being clear for write back).
> >>
> >> If it does call the sdf() while racing with write back then we
> >> just redirtied the page just like clear_page_dirty_for_io() would
> >> do if page_mkclean() failed so nothing harmful will come of that
> >> neither. Page stays dirty despite write back it just means that
> >> the page might be write back twice in a row.
> > 
> > Fair enough. Should we get it into a comment here?
> 
> How's this read to you? I reworded and slightly expanded Jerome's 
> description:
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index d1df7b8ba973..86397ae23922 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -61,6 +61,24 @@ static void __put_user_pages_dirty(struct page **pages,
>         for (index = 0; index < npages; index++) {
>                 struct page *page = compound_head(pages[index]);
>  
> +               /*
> +                * Checking PageDirty at this point may race with
> +                * clear_page_dirty_for_io(), but that's OK. Two key cases:
> +                *
> +                * 1) This code sees the page as already dirty, so it skips
> +                * the call to sdf(). That could happen because
> +                * clear_page_dirty_for_io() called page_mkclean(),
> +                * followed by set_page_dirty(). However, now the page is
> +                * going to get written back, which meets the original
> +                * intention of setting it dirty, so all is well:
> +                * clear_page_dirty_for_io() goes on to call
> +                * TestClearPageDirty(), and write the page back.
> +                *
> +                * 2) This code sees the page as clean, so it calls sdf().
> +                * The page stays dirty, despite being written back, so it
> +                * gets written back again in the next writeback cycle.
> +                * This is harmless.
> +                */
>                 if (!PageDirty(page))
>                         sdf(page);

Looks good to me.

Other nit: effectively the same type of callback called 'spd' in
set_page_dirty(). Should we rename 'sdf' to 'sdp' here too?

> >>>> +void put_user_pages(struct page **pages, unsigned long npages)
> >>>> +{
> >>>> +	unsigned long index;
> >>>> +
> >>>> +	for (index = 0; index < npages; index++)
> >>>> +		put_user_page(pages[index]);
> >>>
> >>> I believe there's an room for improvement for compound pages.
> >>>
> >>> If there's multiple consequential pages in the array that belong to the
> >>> same compound page we can get away with a single atomic operation to
> >>> handle them all.
> >>
> >> Yes maybe just add a comment with that for now and leave this kind of
> >> optimization to latter ?
> > 
> > Sounds good to me.
> > 
> 
> Here's a comment for that:
> 
> @@ -127,6 +145,11 @@ void put_user_pages(struct page **pages, unsigned long npages)
>  {
>         unsigned long index;
>  
> +       /*
> +        * TODO: this can be optimized for huge pages: if a series of pages is
> +        * physically contiguous and part of the same compound page, then a

Comound pages are always physically contiguous. I initially ment that the
optimization makes sense if they are next to each other in 'pages' array.

> +        * single operation to the head page should suffice.
> +        */
>         for (index = 0; index < npages; index++)
>                 put_user_page(pages[index]);
>  }
> 
> 
> thanks,
> -- 
> John Hubbard
> NVIDIA

-- 
 Kirill A. Shutemov

