Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.5 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 960ACC10F06
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 22:32:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 37A9C21850
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 22:32:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 37A9C21850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC5A76B0008; Thu, 28 Mar 2019 18:31:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D75286B000C; Thu, 28 Mar 2019 18:31:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C3FC86B000D; Thu, 28 Mar 2019 18:31:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9C93A6B0008
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 18:31:59 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id b1so375706qtk.11
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 15:31:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=1m8ynbNOKItvdpEnMRU4GMqM/97/Po7c3R/uQn1o0t4=;
        b=NjcxmDR2lj7g4cNK/77KGTwbSIxCFeYgDv50fXa8JfF/WQP0Jkkno/iKYahCFDdjbP
         a8ZN/7828A1JVUbSJNuSeZ3coeuSSZQP/X4lmL4K5dGqfYjwgz3U+yEYKrogkRH8omZo
         EDr5/2IRCe2FiiPAQ9T+2I36v7ymL6ofQvGeQjFkvnCUxNnL4gMyQdTVHkLyKu9Fdy1h
         WzAwdSNyGuYtyj8C1YKhuD01azdwLWiM76mkWj9TZC2vtQYgMrpO9W4Thp5VvBZGo0j9
         sZqpoxos0lBVlvBA4Fg8HBMaWDoQO3YjBaqsegu4nzEsJaippj6b6vK/NAxr8YHFJ1Q+
         WIjw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUbj99SdMCjYudJOwySLEJOu4qZoWQPAtINtlkk/aGBmYyMt5VR
	Ih9Wc/L3ZMTVh2nU+3NfaoAUi3uDoMS2oB81juXTKIsNGstbuxXnN0ojgodcBoVk7d31wiRIu5j
	cITMGgHsU70xRqjontJab90sQbKEic5tkIVKXzyhGB1JaWByPwtCjyHGvtwjdz5nSUg==
X-Received: by 2002:a0c:8b69:: with SMTP id d41mr39191790qvc.186.1553812319292;
        Thu, 28 Mar 2019 15:31:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwRZz9A617NLiiL1uTsDWy/SI+Hz9ZBEeWlALdd2V/1Gq6zpp3VOnDuXRfA5ABVwljIReHh
X-Received: by 2002:a0c:8b69:: with SMTP id d41mr39191743qvc.186.1553812318495;
        Thu, 28 Mar 2019 15:31:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553812318; cv=none;
        d=google.com; s=arc-20160816;
        b=KrdTJlm5nCxapjR47cQZc7ekX5DojIjC9P79W9yLcZ1dXaLe17JvfKr9nBg41vUg7g
         L/r/7VJSxasjrsZ7nLIjBNW9MW81o3BbVP8xiUDKM3HcLl455HIfAV99ivIlocN6wgTA
         3PRkhGGbOSdXqCCa+oK4J//889XprgEtUek0sEW/0ZdLmnkINx40ng5vTxBaviMc/l5z
         msh6s6ebaERkpuSM3teHY6//roiGKCb+0Pj+Iqu7FdybUct8SwUp/azyS1PP1nuxptio
         jInW+O7RYEFrbXmYBgUpQqhDnpw9eeiWXVjo18LDyV/ExitRXPK0rbhP5moUjQMy+8G/
         s22A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=1m8ynbNOKItvdpEnMRU4GMqM/97/Po7c3R/uQn1o0t4=;
        b=W0ncO87fBtL+kBX3Mja4m+6ymo2KODaheojjCPI/Mq593orPfS1P4ofi/Vob9ACN2J
         LDtOSgOzsXtZXyCNi8d/Y1kORRjgc3yFKozbhsjjnRnnnUAnj/2CIKKKlgLtn+HbkgIB
         mvGjdHioVGqSPCDvdSM+Azs0+jCXNVUlgp8que/bgPjYhJ0j9j3FTwzNpszkLgwzFARA
         fC6qyyixIvkH3sbFf1kg1a0+5d2EhNCDkDpnojBPw7dLzwR7M+m0NhGEnzY4XsW48HQ4
         LSDNxRouOkalIciWMxTYBxauVBOicKrztcIaYFijYVbzOBgoMePQVd2guNEuUUzSTDUS
         qReQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a2si66207qkl.123.2019.03.28.15.31.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 15:31:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7DE5719CB85;
	Thu, 28 Mar 2019 22:31:57 +0000 (UTC)
Received: from redhat.com (ovpn-121-118.rdu2.redhat.com [10.10.121.118])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 8E2D98F6C1;
	Thu, 28 Mar 2019 22:31:56 +0000 (UTC)
Date: Thu, 28 Mar 2019 18:31:54 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v2 07/11] mm/hmm: add default fault flags to avoid the
 need to pre-fill pfns arrays.
Message-ID: <20190328223153.GG13560@redhat.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
 <20190325144011.10560-8-jglisse@redhat.com>
 <2f790427-ea87-b41e-b386-820ccdb7dd38@nvidia.com>
 <20190328221203.GF13560@redhat.com>
 <555ad864-d1f9-f513-9666-0d3d05dbb85d@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <555ad864-d1f9-f513-9666-0d3d05dbb85d@nvidia.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Thu, 28 Mar 2019 22:31:57 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 03:19:06PM -0700, John Hubbard wrote:
> On 3/28/19 3:12 PM, Jerome Glisse wrote:
> > On Thu, Mar 28, 2019 at 02:59:50PM -0700, John Hubbard wrote:
> >> On 3/25/19 7:40 AM, jglisse@redhat.com wrote:
> >>> From: Jérôme Glisse <jglisse@redhat.com>
> >>>
> >>> The HMM mirror API can be use in two fashions. The first one where the HMM
> >>> user coalesce multiple page faults into one request and set flags per pfns
> >>> for of those faults. The second one where the HMM user want to pre-fault a
> >>> range with specific flags. For the latter one it is a waste to have the user
> >>> pre-fill the pfn arrays with a default flags value.
> >>>
> >>> This patch adds a default flags value allowing user to set them for a range
> >>> without having to pre-fill the pfn array.
> >>>
> >>> Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> >>> Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
> >>> Cc: Andrew Morton <akpm@linux-foundation.org>
> >>> Cc: John Hubbard <jhubbard@nvidia.com>
> >>> Cc: Dan Williams <dan.j.williams@intel.com>
> >>> ---
> >>>  include/linux/hmm.h |  7 +++++++
> >>>  mm/hmm.c            | 12 ++++++++++++
> >>>  2 files changed, 19 insertions(+)
> >>>
> >>> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> >>> index 79671036cb5f..13bc2c72f791 100644
> >>> --- a/include/linux/hmm.h
> >>> +++ b/include/linux/hmm.h
> >>> @@ -165,6 +165,8 @@ enum hmm_pfn_value_e {
> >>>   * @pfns: array of pfns (big enough for the range)
> >>>   * @flags: pfn flags to match device driver page table
> >>>   * @values: pfn value for some special case (none, special, error, ...)
> >>> + * @default_flags: default flags for the range (write, read, ...)
> >>> + * @pfn_flags_mask: allows to mask pfn flags so that only default_flags matter
> >>>   * @pfn_shifts: pfn shift value (should be <= PAGE_SHIFT)
> >>>   * @valid: pfns array did not change since it has been fill by an HMM function
> >>>   */
> >>> @@ -177,6 +179,8 @@ struct hmm_range {
> >>>  	uint64_t		*pfns;
> >>>  	const uint64_t		*flags;
> >>>  	const uint64_t		*values;
> >>> +	uint64_t		default_flags;
> >>> +	uint64_t		pfn_flags_mask;
> >>>  	uint8_t			pfn_shift;
> >>>  	bool			valid;
> >>>  };
> >>> @@ -521,6 +525,9 @@ static inline int hmm_vma_fault(struct hmm_range *range, bool block)
> >>>  {
> >>>  	long ret;
> >>>  
> >>> +	range->default_flags = 0;
> >>> +	range->pfn_flags_mask = -1UL;
> >>
> >> Hi Jerome,
> >>
> >> This is nice to have. Let's constrain it a little bit more, though: the pfn_flags_mask
> >> definitely does not need to be a run time value. And we want some assurance that
> >> the mask is 
> >> 	a) large enough for the flags, and
> >> 	b) small enough to avoid overrunning the pfns field.
> >>
> >> Those are less certain with a run-time struct field, and more obviously correct with
> >> something like, approximately:
> >>
> >>  	#define PFN_FLAGS_MASK 0xFFFF
> >>
> >> or something.
> >>
> >> In other words, this is more flexibility than we need--just a touch too much,
> >> IMHO.
> > 
> > This mirror the fact that flags are provided as an array and some devices use
> > the top bits for flags (read, write, ...). So here it is the safe default to
> > set it to -1. If the caller want to leverage this optimization it can override
> > the default_flags value.
> > 
> 
> Optimization? OK, now I'm a bit lost. Maybe this is another place where I could
> use a peek at the calling code. The only flags I've seen so far use the bottom
> 3 bits and that's it. 
> 
> Maybe comments here?
> 
> >>
> >>> +
> >>>  	ret = hmm_range_register(range, range->vma->vm_mm,
> >>>  				 range->start, range->end);
> >>>  	if (ret)
> >>> diff --git a/mm/hmm.c b/mm/hmm.c
> >>> index fa9498eeb9b6..4fe88a196d17 100644
> >>> --- a/mm/hmm.c
> >>> +++ b/mm/hmm.c
> >>> @@ -415,6 +415,18 @@ static inline void hmm_pte_need_fault(const struct hmm_vma_walk *hmm_vma_walk,
> >>>  	if (!hmm_vma_walk->fault)
> >>>  		return;
> >>>  
> >>> +	/*
> >>> +	 * So we not only consider the individual per page request we also
> >>> +	 * consider the default flags requested for the range. The API can
> >>> +	 * be use in 2 fashions. The first one where the HMM user coalesce
> >>> +	 * multiple page fault into one request and set flags per pfns for
> >>> +	 * of those faults. The second one where the HMM user want to pre-
> >>> +	 * fault a range with specific flags. For the latter one it is a
> >>> +	 * waste to have the user pre-fill the pfn arrays with a default
> >>> +	 * flags value.
> >>> +	 */
> >>> +	pfns = (pfns & range->pfn_flags_mask) | range->default_flags;
> >>
> >> Need to verify that the mask isn't too large or too small.
> > 
> > I need to check agin but default flag is anded somewhere to limit
> > the bit to the one we expect.
> 
> Right, but in general, the *mask* could be wrong. It would be nice to have
> an assert, and/or a comment, or something to verify the mask is proper.
> 
> Really, a hardcoded mask is simple and correct--unless it *definitely* must
> vary for devices of course.

Ok so re-read the code and it is correct. The helper for compatibility with
old API (so that i do not break nouveau upstream code) initialize those to
the safe default ie:

range->default_flags = 0;
range->pfn_flags_mask = -1;

Which means that in the above comment we are in the case where it is the
individual entry within the pfn array that will determine if we fault or
not.

Driver using the new API can either use this safe default or use the
second case in the above comment and set default_flags to something
else than 0.

Note that those default_flags are not set in the final result they are
use to determine if we need to do a page fault. For instance if you set
the write bit in the default flags then the pfns computed above will
have the write bit set and when we compare with the CPU pte if the CPU
pte do not have the write bit set then we will fault. What matter is
that in this case the value within the pfns array is totaly pointless
ie we do not care what it is, it will not affect the decission ie the
decision is made by looking at the default flags.

Hope this clarify thing. You can look at the ODP patch to see how it
is use:

https://cgit.freedesktop.org/~glisse/linux/commit/?h=hmm-odp-v2&id=eebd4f3095290a16ebc03182e2d3ab5dfa7b05ec

Cheers,
Jérôme

