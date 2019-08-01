Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3124EC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 08:04:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D8BB020838
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 08:04:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D8BB020838
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 708D38E0003; Thu,  1 Aug 2019 04:04:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E0F38E0001; Thu,  1 Aug 2019 04:04:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A7FA8E0003; Thu,  1 Aug 2019 04:04:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0D89F8E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 04:04:12 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id o13so44251178edt.4
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 01:04:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=fKNHH0CDDSmVfLrPCQbfV+BLKRXM4ZY/KL6JtmFI14o=;
        b=Q8tQ5DV5jXYT5Jtz/0IjsXet6FI5FHy+PaOKj6Z+12mbz2mRI41b7J4JSM8X4NFjUm
         0cxRm+ELKQcn7eSABRbUpPOlZ9AyCBXmiGJrG3ioSWv3zcdmQ62UGuRTWpwEfPBKzsoL
         8vwEprB3ENimQRxnOIsWwIW6X3kIWYJZSVOcEJ6WYQYWfGbtWOxsQYbOBzgn49DKX8qx
         UsqrH1pQO7evFlI8mX47MeynbcYybkzs529WrTDTi8iyK9TiS51vA/gYyJhGdWhORrBy
         UoNe+Hd5gWWeVs4YycbthvI7KlSK9UKplgv3+t7aA6SfHA6wyv+/cTuYlNPbd0gy53gB
         Cwbw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXNuC/8tG3RKtLZSyHqqJMAzA2GBJSOiKa0cmp+l7i8TtmwyeeZ
	MmSleoUeD6PInBdIXY/zWKBDax2iBAd7SzMXAxnWRvM/MESUt7SbBtTDoxtnJeqiE8n0Sdwf2tw
	WjmNwQDjHtY7dF6uFNeaYh6Terx69OIpOSfftYDElI+a2a95Z/+Gwco3h9rx0Weg=
X-Received: by 2002:a17:906:6582:: with SMTP id x2mr8113282ejn.2.1564646651606;
        Thu, 01 Aug 2019 01:04:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwNbGkcAxrYwUB+ylHSd0Lx83pwGLYp9Iv5caWtHV1oaWnI/oNpRWwXfTjJogUeLoT5LfU5
X-Received: by 2002:a17:906:6582:: with SMTP id x2mr8113198ejn.2.1564646650829;
        Thu, 01 Aug 2019 01:04:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564646650; cv=none;
        d=google.com; s=arc-20160816;
        b=sNm953a/0hQ73b7alN9tic42OTsQuwIEbAWjS4P+nHOtKrkNmPEK5t6PVXM014cqS5
         AKrdM15aMVanBkVd++uVTsVdZADm6y8KdNH4CErjjIvYzkqCDnHrYONAQC338bvQSIyd
         LjSeeOmrT9DqRQQNO5x5dh6RhMMtRzCDIukdB6tbl9QENrz+juqtfinSIq484xhi7vMJ
         sc5ae9RxzM1lnMVPFiBbqjb+YRBB9pUV30O/2ghKrZQmI3Po1Af0SUMPOAkSYunKQuQR
         XlKnKkOV2ECjjeWAt2VN0BXblAyOXMbGHDYpXKlEVOwOqOzxZZjhHQ2OxQoFbLnAtIy+
         rXQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=fKNHH0CDDSmVfLrPCQbfV+BLKRXM4ZY/KL6JtmFI14o=;
        b=tt4e28yZAi2m1lMSm8uPXsx+pyVq/nJtz9e+CsCqd1p5HTYFaR8EMoutl0HkZNMOCH
         9H7bpRDCHH0Dkd4r8I8NL79ZU8NWjgEBiXK1VYqkdNohDtzfxq/CrPR8BbQQiCnpKQj5
         LZFZZlDjDUeOBQwupD0e0gmU8US72ZZbvqPvUDnac9EwGi7ZX40ZEVqGaaoGXdF/NVe0
         7Bq/n6Jgh245kDjGr0K2yTu6pTtbIBhS2ecuci/wcH73eGTGX8lbqQT90dq1RNiA6LGg
         i8AsG1p5slpzNdkL0k2gXBqIUZ6Rtc1ofscuVUSfG9g1M2oWTCRfQhjVbx5OsIS+DFEb
         0yfw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 57si21001154eds.450.2019.08.01.01.04.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 01:04:10 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 468E0AC91;
	Thu,  1 Aug 2019 08:04:10 +0000 (UTC)
Date: Thu, 1 Aug 2019 10:04:07 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: Rashmica Gupta <rashmica.g@gmail.com>,
	Oscar Salvador <osalvador@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>, pasha.tatashin@soleen.com,
	Jonathan.Cameron@huawei.com, anshuman.khandual@arm.com,
	Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 0/5] Allocate memmap from hotadded memory
Message-ID: <20190801080407.GJ11627@dhcp22.suse.cz>
References: <20190702074806.GA26836@linux>
 <CAC6rBskRyh5Tj9L-6T4dTgA18H0Y8GsMdC-X5_0Jh1SVfLLYtg@mail.gmail.com>
 <20190731120859.GJ9330@dhcp22.suse.cz>
 <4ddee0dd719abd50350f997b8089fa26f6004c0c.camel@gmail.com>
 <20190801071709.GE11627@dhcp22.suse.cz>
 <9bcbd574-7e23-5cfe-f633-646a085f935a@redhat.com>
 <20190801072430.GF11627@dhcp22.suse.cz>
 <e654aa97-6ab1-4069-60e6-fc099539729e@redhat.com>
 <20190801073407.GG11627@dhcp22.suse.cz>
 <7c12f0b1-61a5-ed6f-2c64-4058e47860a3@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7c12f0b1-61a5-ed6f-2c64-4058e47860a3@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 01-08-19 09:50:29, David Hildenbrand wrote:
> On 01.08.19 09:34, Michal Hocko wrote:
> > On Thu 01-08-19 09:26:35, David Hildenbrand wrote:
> >> On 01.08.19 09:24, Michal Hocko wrote:
> >>> On Thu 01-08-19 09:18:47, David Hildenbrand wrote:
> >>>> On 01.08.19 09:17, Michal Hocko wrote:
> >>>>> On Thu 01-08-19 09:06:40, Rashmica Gupta wrote:
> >>>>>> On Wed, 2019-07-31 at 14:08 +0200, Michal Hocko wrote:
> >>>>>>> On Tue 02-07-19 18:52:01, Rashmica Gupta wrote:
> >>>>>>> [...]
> >>>>>>>>> 2) Why it was designed, what is the goal of the interface?
> >>>>>>>>> 3) When it is supposed to be used?
> >>>>>>>>>
> >>>>>>>>>
> >>>>>>>> There is a hardware debugging facility (htm) on some power chips.
> >>>>>>>> To use
> >>>>>>>> this you need a contiguous portion of memory for the output to be
> >>>>>>>> dumped
> >>>>>>>> to - and we obviously don't want this memory to be simultaneously
> >>>>>>>> used by
> >>>>>>>> the kernel.
> >>>>>>>
> >>>>>>> How much memory are we talking about here? Just curious.
> >>>>>>
> >>>>>> From what I've seen a couple of GB per node, so maybe 2-10GB total.
> >>>>>
> >>>>> OK, that is really a lot to keep around unused just in case the
> >>>>> debugging is going to be used.
> >>>>>
> >>>>> I am still not sure the current approach of (ab)using memory hotplug is
> >>>>> ideal. Sure there is some overlap but you shouldn't really need to
> >>>>> offline the required memory range at all. All you need is to isolate the
> >>>>> memory from any existing user and the page allocator. Have you checked
> >>>>> alloc_contig_range?
> >>>>>
> >>>>
> >>>> Rashmica mentioned somewhere in this thread that the virtual mapping
> >>>> must not be in place, otherwise the HW might prefetch some of this
> >>>> memory, leading to errors with memtrace (which checks that in HW).
> >>>
> >>> Does anything prevent from unmapping the pfn range from the direct
> >>> mapping?
> >>
> >> I am not sure about the implications of having
> >> pfn_valid()/pfn_present()/pfn_online() return true but accessing it
> >> results in crashes. (suspend, kdump, whatever other technology touches
> >> online memory)
> > 
> > If those pages are marked as Reserved then nobody should be touching
> > them anyway.
> 
> Which is not true as I remember we already discussed - I even documented
> what PG_reserved can mean after that discussion in page-flags.h (e.g.,
> memmap of boot memory) - that's why we introduced PG_offline after all.

Sorry, my statement was imprecise. What I meant is what we have
documented:
 * PG_reserved is set for special pages. The "struct page" of such a page
 * should in general not be touched (e.g. set dirty) except by its owner.

the owner part is important.
-- 
Michal Hocko
SUSE Labs

