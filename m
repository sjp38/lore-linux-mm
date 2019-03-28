Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 653A3C10F06
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 22:12:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1770B2184C
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 22:12:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1770B2184C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C27D46B0008; Thu, 28 Mar 2019 18:12:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BAF466B000C; Thu, 28 Mar 2019 18:12:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A75AE6B0266; Thu, 28 Mar 2019 18:12:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7E99A6B0008
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 18:12:08 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id a188so120728qkf.0
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 15:12:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=CEwSl34k6l4FLjjlbRxCU1JxeusG83TWF1XySun55Ik=;
        b=dgSL9tB9Kbgk8zBpgOTsa1oQ017oGVa9drRtQjIodrk899Jt4Vv5WH8I9SzVuycnCb
         tj/At1CKSnpr0G6u4P2SLBZFqvaHgMsA6fyZUmNnJ7u01b2bRLylQ1PzDbnmwmGfJTxA
         KOlioZV+70q/Q8bQHssDNrKMXAoAe/f2gyEjfh+Le3vNY22D0hC4dmJq1mqrrngBZHGq
         8VmMrQibDl1npaGMGT234O8tVtxXIWspI9DPKGqgxgZfZUaxECpVEq78ILbURHz2QzLV
         n1/IFI38eWPowq/w/RCGCMY+HiBqKDhhj53jG9G6YxmyRLGNdeME0aPU4GiKXP3+CCsE
         6PhA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXPh8ZYF6ft/Qd/amjiMLX4D8PYjW79prGk9MKsM1Zk2KrK+yLS
	F0hgkVHtTuHG9vo8cRw9p6+f2s9nhVXXdDJjoAx8SJMkAWE8VZX15BPCfNzfvvELpjkD/hlyJya
	vkJFPITgR/1KsMrINLRU5EP5hmpKtcrA9+2jFRBBDS1u8dmh4bKeDjoO5XJJrx3WR8g==
X-Received: by 2002:a0c:9dc1:: with SMTP id p1mr13580782qvf.60.1553811128244;
        Thu, 28 Mar 2019 15:12:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwgu6kjnoYj+KOLxdzBDRvLyZ3WhALdbGVDCHAh7nUdEvzqiKmXyBxRUjCWn5X1G3UbzloV
X-Received: by 2002:a0c:9dc1:: with SMTP id p1mr13580746qvf.60.1553811127594;
        Thu, 28 Mar 2019 15:12:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553811127; cv=none;
        d=google.com; s=arc-20160816;
        b=XWgZBFJfOP2s/qkRz1yLiU37vECNqItGdpvvuz5dopEGNR4LOw+qslBy7NOtjINov2
         khYG/VrTl7I3Fx0Mw4YDSAUymwyGel76GEwEpVscWxh5wXUfFJtG1NmRZhYqX7KA+JzH
         RqDt3rviZ+4wpts5f8OzBJ2nwZwpGcnXwGZHQc40+028CdPQag10W0Uocz+8+EerilR2
         gWzxSplXDQTY337vxXA2efUwQitNL1PhFxYXduVKUbR+tWrnTkVZODMho/VOZV99XfE2
         zUFyHdSD/tXDYKeifbSW0X4MPcOCWfLNFS5i6MeP9QI1MftGwc/HXqyqUQLSf/dXD7X/
         c8sw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=CEwSl34k6l4FLjjlbRxCU1JxeusG83TWF1XySun55Ik=;
        b=BsaRy2lVanTwG8Y90Zs41yG7s96wogULSpafn8gIdhjQhWkE1vUpjelFMfuHoq6WA7
         E1lCtwXflAKP/XV0RvkXOr0XhqaNeph6Tu4Z2W3Tr7+9sDH34MTDPY5MTxFTObqKhNuC
         6DulMCrYdkA280HdrZabCRgZlK/+ELvz0MBLKMJ9MSEIvhH5L6lRDjOGX9Lb7BVApN70
         tKRqwZbhN4EoZWwTDG/MercnJJqzCJjzJB6xLVhZyOkXEFHVTZuJK/JZxLf8Hw1B7tkE
         iRSf7Ywj2PsHV6qIQHhk4r9vZn017J2gYjj9xp4lOfZZK3rYBQFoMJ9H1AU8wW6DHy3s
         p5rg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p12si151856qtc.238.2019.03.28.15.12.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 15:12:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C942388306;
	Thu, 28 Mar 2019 22:12:06 +0000 (UTC)
Received: from redhat.com (ovpn-121-118.rdu2.redhat.com [10.10.121.118])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 0ECCC1001DDA;
	Thu, 28 Mar 2019 22:12:05 +0000 (UTC)
Date: Thu, 28 Mar 2019 18:12:04 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v2 07/11] mm/hmm: add default fault flags to avoid the
 need to pre-fill pfns arrays.
Message-ID: <20190328221203.GF13560@redhat.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
 <20190325144011.10560-8-jglisse@redhat.com>
 <2f790427-ea87-b41e-b386-820ccdb7dd38@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <2f790427-ea87-b41e-b386-820ccdb7dd38@nvidia.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Thu, 28 Mar 2019 22:12:06 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 02:59:50PM -0700, John Hubbard wrote:
> On 3/25/19 7:40 AM, jglisse@redhat.com wrote:
> > From: Jérôme Glisse <jglisse@redhat.com>
> > 
> > The HMM mirror API can be use in two fashions. The first one where the HMM
> > user coalesce multiple page faults into one request and set flags per pfns
> > for of those faults. The second one where the HMM user want to pre-fault a
> > range with specific flags. For the latter one it is a waste to have the user
> > pre-fill the pfn arrays with a default flags value.
> > 
> > This patch adds a default flags value allowing user to set them for a range
> > without having to pre-fill the pfn array.
> > 
> > Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> > Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: John Hubbard <jhubbard@nvidia.com>
> > Cc: Dan Williams <dan.j.williams@intel.com>
> > ---
> >  include/linux/hmm.h |  7 +++++++
> >  mm/hmm.c            | 12 ++++++++++++
> >  2 files changed, 19 insertions(+)
> > 
> > diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> > index 79671036cb5f..13bc2c72f791 100644
> > --- a/include/linux/hmm.h
> > +++ b/include/linux/hmm.h
> > @@ -165,6 +165,8 @@ enum hmm_pfn_value_e {
> >   * @pfns: array of pfns (big enough for the range)
> >   * @flags: pfn flags to match device driver page table
> >   * @values: pfn value for some special case (none, special, error, ...)
> > + * @default_flags: default flags for the range (write, read, ...)
> > + * @pfn_flags_mask: allows to mask pfn flags so that only default_flags matter
> >   * @pfn_shifts: pfn shift value (should be <= PAGE_SHIFT)
> >   * @valid: pfns array did not change since it has been fill by an HMM function
> >   */
> > @@ -177,6 +179,8 @@ struct hmm_range {
> >  	uint64_t		*pfns;
> >  	const uint64_t		*flags;
> >  	const uint64_t		*values;
> > +	uint64_t		default_flags;
> > +	uint64_t		pfn_flags_mask;
> >  	uint8_t			pfn_shift;
> >  	bool			valid;
> >  };
> > @@ -521,6 +525,9 @@ static inline int hmm_vma_fault(struct hmm_range *range, bool block)
> >  {
> >  	long ret;
> >  
> > +	range->default_flags = 0;
> > +	range->pfn_flags_mask = -1UL;
> 
> Hi Jerome,
> 
> This is nice to have. Let's constrain it a little bit more, though: the pfn_flags_mask
> definitely does not need to be a run time value. And we want some assurance that
> the mask is 
> 	a) large enough for the flags, and
> 	b) small enough to avoid overrunning the pfns field.
> 
> Those are less certain with a run-time struct field, and more obviously correct with
> something like, approximately:
> 
>  	#define PFN_FLAGS_MASK 0xFFFF
> 
> or something.
> 
> In other words, this is more flexibility than we need--just a touch too much,
> IMHO.

This mirror the fact that flags are provided as an array and some devices use
the top bits for flags (read, write, ...). So here it is the safe default to
set it to -1. If the caller want to leverage this optimization it can override
the default_flags value.

> 
> > +
> >  	ret = hmm_range_register(range, range->vma->vm_mm,
> >  				 range->start, range->end);
> >  	if (ret)
> > diff --git a/mm/hmm.c b/mm/hmm.c
> > index fa9498eeb9b6..4fe88a196d17 100644
> > --- a/mm/hmm.c
> > +++ b/mm/hmm.c
> > @@ -415,6 +415,18 @@ static inline void hmm_pte_need_fault(const struct hmm_vma_walk *hmm_vma_walk,
> >  	if (!hmm_vma_walk->fault)
> >  		return;
> >  
> > +	/*
> > +	 * So we not only consider the individual per page request we also
> > +	 * consider the default flags requested for the range. The API can
> > +	 * be use in 2 fashions. The first one where the HMM user coalesce
> > +	 * multiple page fault into one request and set flags per pfns for
> > +	 * of those faults. The second one where the HMM user want to pre-
> > +	 * fault a range with specific flags. For the latter one it is a
> > +	 * waste to have the user pre-fill the pfn arrays with a default
> > +	 * flags value.
> > +	 */
> > +	pfns = (pfns & range->pfn_flags_mask) | range->default_flags;
> 
> Need to verify that the mask isn't too large or too small.

I need to check agin but default flag is anded somewhere to limit
the bit to the one we expect.

Cheers,
Jérôme

