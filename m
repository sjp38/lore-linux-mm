Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 032C0C48BD4
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 08:09:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C9A4120883
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 08:09:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C9A4120883
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6665C8E0003; Tue, 25 Jun 2019 04:09:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 617A38E0002; Tue, 25 Jun 2019 04:09:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 506D48E0003; Tue, 25 Jun 2019 04:09:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 011568E0002
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 04:09:19 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id m23so24445363edr.7
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 01:09:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=+YOXEfm1Sow+68lEpOMt9NpK3l+653PYMSuynWkWVM4=;
        b=q5ltvnowOODtT9hbOy1pfsYM3Pb7TwPjrXRIc6nYCZIfbQBOJ7OQtlGbLm92LMGtwU
         WSieVpnzmAk6B/H+SfOQIL14iuO7PZcmJJjgQhI+gAdM2voI03Czg0pFyVAZROqZBH1D
         B+HX1oWx0vfRNSpBhFmdDGfwmoc1BE0seEOJvlU/9jQOhQoA01+s47kyg9v7ag4ofg0e
         n4lJzigfSCRbCxk1v++3nShfSrR3uvHqZsPCYwankXBqybnhcXD1euQfFadd+Y02xg0S
         XpgpXSuMFL8RAlmIoYUSEETTztXqPbAHSnEi4zQhSBzavrpPtIGpXunYuCtfft3JCTfE
         f4Mg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAU0YLz4gz/vU09fgx1/6DBz0NFbUjc1zYKMQKnuAfEmt4U+bksX
	h/EW4MTqB9GAm1qS+vsF/LlfgQTV1wFYlu0SrDlgHco2Xum+kW8I/bYAt+sBL7arXibN6cX0rO7
	6NwsP3oXSxhi1hLOgMXDq0ogAilKifYI0FRkuawoAPUss5FZPI+/Zgea4mb9eNoLY3Q==
X-Received: by 2002:a17:906:1dcc:: with SMTP id v12mr65718180ejh.110.1561450158555;
        Tue, 25 Jun 2019 01:09:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxhGxV10AmLzyyopc0tPCi6ioSWzCiXjyWVUlSwmNC9Yr3sSOY3SUGoH3VeqTCc7jnotX1K
X-Received: by 2002:a17:906:1dcc:: with SMTP id v12mr65718141ejh.110.1561450157733;
        Tue, 25 Jun 2019 01:09:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561450157; cv=none;
        d=google.com; s=arc-20160816;
        b=TBsDXye8KYgbmeaU7VmJ6Iowvr4jnQGRsrgx2KmWyGxBr0rIsyoGteY1rzGDHvAHCj
         z+lrSiVxv4xzpLARRtZuc5p74RsXLcbPCfBHy0KocwtxHbBDAvIE4rAbtFyg/aRD26p4
         /LDv1CY+ssP9FDKDwHCV2z47h3I7B3LZp5DwVblmt8BJ8YLjX0PBuk3v/kCWQ9oS5dLi
         odMSRsv2tzRb9+T/1+0av9JaiIp/rsA8S2qxnEV6449BsI7s/aOVnSIhTZOJmTXhM6hS
         qwOjOG6YCq/JheUSKbgCTkEDfwUz7oXLodZAMfpnH1oP0lHIw2kGmv69EiPDYTltX9+W
         8fdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=+YOXEfm1Sow+68lEpOMt9NpK3l+653PYMSuynWkWVM4=;
        b=tmLkpd5nZsekQ4suzVydXmaC1D0rv7ncOTifVFOkBRa/EP+Av9DEiXnReji2PKf1oQ
         glhmjeSv+ZNZQH3CokiSNu2/eKPiu1LqObZ3NJ1pzeZThM4FW7rWPwuqJTTPmIjrLRi0
         jOFgg11NuEHaI2c2fWkmWVxNypRM8jDnCXC1ePNvbpD+5YfAmD1DRFgayVQHuJDgVSTS
         yQRqhpnjVlxiwRsqV2T9uHCAw6is6CVEbKVblebyxBS58gYl3nvD49ALWeTPhXuLJKbX
         /InetJBUKakqDRk2N3CGRhP3gNf0Uo23bJGNgmoqB86WEuwgx4jnKIjiNyfHdVq/VB8L
         Ykzw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f23si12158617edf.439.2019.06.25.01.09.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 01:09:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DA1A8AD43;
	Tue, 25 Jun 2019 08:09:16 +0000 (UTC)
Date: Tue, 25 Jun 2019 10:09:14 +0200
From: Oscar Salvador <osalvador@suse.de>
To: David Hildenbrand <david@redhat.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com,
	pasha.tatashin@soleen.com, Jonathan.Cameron@huawei.com,
	anshuman.khandual@arm.com, vbabka@suse.cz, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 1/5] drivers/base/memory: Remove unneeded check in
 remove_memory_block_devices
Message-ID: <20190625080909.GA15394@linux>
References: <20190625075227.15193-1-osalvador@suse.de>
 <20190625075227.15193-2-osalvador@suse.de>
 <3e820fee-f82f-3336-ff34-31c66dbbbbfe@redhat.com>
 <0ed2f4ec-cc6f-8b81-46b0-d56d90ac1e86@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0ed2f4ec-cc6f-8b81-46b0-d56d90ac1e86@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 25, 2019 at 10:03:31AM +0200, David Hildenbrand wrote:
> On 25.06.19 10:01, David Hildenbrand wrote:
> > On 25.06.19 09:52, Oscar Salvador wrote:
> >> remove_memory_block_devices() checks for the range to be aligned
> >> to memory_block_size_bytes, which is our current memory block size,
> >> and WARNs_ON and bails out if it is not.
> >>
> >> This is the right to do, but we do already do that in try_remove_memory(),
> >> where remove_memory_block_devices() gets called from, and we even are
> >> more strict in try_remove_memory, since we directly BUG_ON in case the range
> >> is not properly aligned.
> >>
> >> Since remove_memory_block_devices() is only called from try_remove_memory(),
> >> we can safely drop the check here.
> >>
> >> To be honest, I am not sure if we should kill the system in case we cannot
> >> remove memory.
> >> I tend to think that WARN_ON and return and error is better.
> > 
> > I failed to parse this sentence.
> > 
> >>
> >> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> >> ---
> >>  drivers/base/memory.c | 4 ----
> >>  1 file changed, 4 deletions(-)
> >>
> >> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> >> index 826dd76f662e..07ba731beb42 100644
> >> --- a/drivers/base/memory.c
> >> +++ b/drivers/base/memory.c
> >> @@ -771,10 +771,6 @@ void remove_memory_block_devices(unsigned long start, unsigned long size)
> >>  	struct memory_block *mem;
> >>  	int block_id;
> >>  
> >> -	if (WARN_ON_ONCE(!IS_ALIGNED(start, memory_block_size_bytes()) ||
> >> -			 !IS_ALIGNED(size, memory_block_size_bytes())))
> >> -		return;
> >> -
> >>  	mutex_lock(&mem_sysfs_mutex);
> >>  	for (block_id = start_block_id; block_id != end_block_id; block_id++) {
> >>  		mem = find_memory_block_by_id(block_id, NULL);
> >>
> > 
> > As I said when I introduced this, I prefer to have such duplicate checks
> > in place in case we have dependent code splattered over different files.
> > (especially mm/ vs. drivers/base). Such simple checks avoid to document
> > "start and size have to be aligned to memory blocks".
> 
> Lol, I even documented it as well. So yeah, if you're going to drop this
> once, also drop the one in create_memory_block_devices().

TBH, I would not mind sticking with it.
What sticked out the most was that in the previous check, we BUG_on while
here we just print out a warning, so it seemed quite "inconsistent" to me.

And I only stumbled upon this when I was testing a kernel module that
hot-removed memory in a different granularity.

Anyway, I do not really feel strong here, I can perfectly drop this patch as I
would rather have the focus in the following-up patches, which are the important
ones IMO.

> 
> > 
> > If you still insist, then also remove the same sequence from
> > create_memory_block_devices().
> > 
> 
> 
> -- 
> 
> Thanks,
> 
> David / dhildenb
> 

-- 
Oscar Salvador
SUSE L3

