Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F634C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 14:03:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59EDA20856
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 14:03:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59EDA20856
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D50136B0007; Tue, 26 Mar 2019 10:03:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD5DF6B0008; Tue, 26 Mar 2019 10:03:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B76E16B000A; Tue, 26 Mar 2019 10:03:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6122D6B0007
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 10:03:51 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id 41so3987837edq.0
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 07:03:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=eDpDjojg2weANJoDX3uZcykrOVYMbAotBqvlMbk+kE0=;
        b=fXDYpa/CUGJdKCMTHfi+pYnkUOLf9WJkAzYxl2BuaiN0L//5pxl75QoNlt2+D7YBD+
         3RCAqoEPs2bgc62D52Q0JhMJY5xMvIQ96omOEoQNFiom0H7CinOjSh93Tsq0LmHW/zAe
         1y+7VTiowjliP7PK7JUdSaLCTl83NihcqEDOgKTVAZgpYk+skfIutHMRN0a9gw219LsE
         UnpoJn5QhheGNpiisBCewAMvp6W+maJ/2gO3Z9uCVAJqekTsqnnjpAiNx3Jgv15SlAYL
         CILE060V7oCZt4Wrj0nnF7NoIuqTBPBiYloULiTp/AhfxyS2do+Tv3CgvjIOqugXEHV2
         0iNQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAX/yUiouAFNcgbFu9evojqpwa712Tl1lkIYhBXGB1seWTHEdJ4h
	4B2oewWb+f31LUGC3MnM6ZA8c8ENr/DNu9MozwkMKfUJZAxWf0O+xM+qbQQ/wSS9mf6cTY/v8Sx
	nzXQXzmbuLdGweIm32x81sXmjArZjTb7m8mBw4YAeUHFhjfqC1tJ23Bv+KIuKMkk=
X-Received: by 2002:a17:906:7621:: with SMTP id c1mr17840843ejn.47.1553609030862;
        Tue, 26 Mar 2019 07:03:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxyaF27Wq2ZY30nk0EIRrlMqlrsfLi8gMa8dHP/r+fZos+aSDm1H/7ozJ29OgTAsUpFDgBB
X-Received: by 2002:a17:906:7621:: with SMTP id c1mr17840805ejn.47.1553609030050;
        Tue, 26 Mar 2019 07:03:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553609030; cv=none;
        d=google.com; s=arc-20160816;
        b=PPCrQ83LDnayH0qS1KhieGrLhIzKTsircaN8bwNGwG8cQu4+OeLZUWihMtjwHES77E
         ipBsCN4A03ZanlBB5YngLUr6BDubL2Lj5brv7UfFzd9gmJaNWnCs21UTSHr0HWUYqQlE
         AzZ82dYWr3FBVjveD0Lq+OHT+pHf1EizWoqgbqOgepNt8ThDHqP2g/zxC3/Gv5t6lNsu
         KSr6tEFEgVu1H0n3YmKZJJkaPRBI2dq9iS4tBTHTtuyfS/XI309JEWwZJb74Ys2X/0pp
         gZe335fe17uE9WtPIbP5WN24JcXAqdf0HR8fWVOYzlEGjc0SFs6X3/XtImAQE9/GHkC7
         wZqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=eDpDjojg2weANJoDX3uZcykrOVYMbAotBqvlMbk+kE0=;
        b=0L4qzV/QB2ckpZ+UMSuyxWn9536N6/UGhsWBX5FPdmgq3uzOkGofayIG3rl8/iqN/q
         kzOp/IL14MQnyOfcyXrQ9o4SY6h4Z02DUYgak0z5e/yPHrgSpZA2sN64aCkwOLcIs9If
         WLmhEAZTqMYWfMZdXUSTk4odWKgizeFG+hO4MM0r0zNgkiCsbGzsdj/OTarLVKLOye94
         RJPu01Irzg9PLL50MkA5MsOUVfEePLo6EnfpFo5JVK3ACdCK1iydXRNkvPjEqbAw4Iak
         cerjqHgNeR9i/2Xxr3/PYRW9jiQk7Hr2kmZ9mwsVn4vaPkelQsosidngALMOamLTMUWt
         reHA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w1si3301368eju.88.2019.03.26.07.03.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 07:03:50 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 61482AF74;
	Tue, 26 Mar 2019 14:03:49 +0000 (UTC)
Date: Tue, 26 Mar 2019 15:03:48 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Baoquan He <bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, rppt@linux.ibm.com, osalvador@suse.de,
	willy@infradead.org, william.kucharski@oracle.com
Subject: Re: [PATCH v2 2/4] mm/sparse: Optimize sparse_add_one_section()
Message-ID: <20190326140348.GQ28406@dhcp22.suse.cz>
References: <20190326090227.3059-1-bhe@redhat.com>
 <20190326090227.3059-3-bhe@redhat.com>
 <20190326092936.GK28406@dhcp22.suse.cz>
 <20190326100817.GV3659@MiWiFi-R3L-srv>
 <20190326101710.GN28406@dhcp22.suse.cz>
 <20190326134522.GB21943@MiWiFi-R3L-srv>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190326134522.GB21943@MiWiFi-R3L-srv>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 26-03-19 21:45:22, Baoquan He wrote:
> On 03/26/19 at 11:17am, Michal Hocko wrote:
> > On Tue 26-03-19 18:08:17, Baoquan He wrote:
> > > On 03/26/19 at 10:29am, Michal Hocko wrote:
> > > > On Tue 26-03-19 17:02:25, Baoquan He wrote:
> > > > > Reorder the allocation of usemap and memmap since usemap allocation
> > > > > is much simpler and easier. Otherwise hard work is done to make
> > > > > memmap ready, then have to rollback just because of usemap allocation
> > > > > failure.
> > > > 
> > > > Is this really worth it? I can see that !VMEMMAP is doing memmap size
> > > > allocation which would be 2MB aka costly allocation but we do not do
> > > > __GFP_RETRY_MAYFAIL so the allocator backs off early.
> > > 
> > > In !VMEMMAP case, it truly does simple allocation directly. surely
> > > usemap which size is 32 is smaller. So it doesn't matter that much who's
> > > ahead or who's behind. However, this benefit a little in VMEMMAP case.
> > 
> > How does it help there? The failure should be even much less probable
> > there because we simply fall back to a small 4kB pages and those
> > essentially never fail.
> 
> OK, I am fine to drop it. Or only put the section existence checking
> earlier to avoid unnecessary usemap/memmap allocation?

DO you have any data on how often that happens? Should basically never
happening, right?
-- 
Michal Hocko
SUSE Labs

