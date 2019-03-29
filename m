Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE879C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 21:15:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9531E2184C
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 21:15:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9531E2184C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2C48B6B0008; Fri, 29 Mar 2019 17:15:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 275FA6B000A; Fri, 29 Mar 2019 17:15:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 166A76B000D; Fri, 29 Mar 2019 17:15:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id E91BD6B0008
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 17:15:33 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id v2so2960206qkf.21
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 14:15:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=Po/nzgdtzi8v6Fo6duX4gx/DPJSZpnrMuV/kmJ0V3mE=;
        b=XSC5YzzK1xKg4Q57FC3jWYy3vBda3hwYy9Q6f9lbmkFBdeFRQeBD74xdl4Ypf1ahcG
         Ft+7+z1dgDP8SagNR5RMlIOImsvrm3hhf4k1OQGBU9Xn4y/nTqa8XO6stW2Wvk0BR6UV
         ltpTjyHSL+x+CMvzkp9lcpTPTHzeH6GRR91r2VfZqCI487TkdhagBN7sCyEuR+9ZYz5b
         QZhEQqW3hDGJeEDldd6F61f/b90FO96FuFfK0gK8CvtuYf45+wZZ9li7fw0YGTneiMFS
         NbXXZ6HqWggK3Qdzbzwx3HZVgEizTXJ3hScsjboli+cT3k4eDbjdKVpH0Vj71UFdqDHm
         f5vw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWONFzYvj8fAtpwb/U9ys2Y2kL3p+13126DirmHN0QxGQnRAz48
	lb0l8NnV2Xbb7NE5pXG+mBbi+MMcv4M0b91q2IX8NoYwead/bfi7KpMT9n5aNE04h0fE5ObFwHF
	f01s8KiN4AzZ2H5K+wjUhPnnKheNCdXK7DFttQMX7ytZHrXujewdjMp4z1M3cZGG5Wg==
X-Received: by 2002:ac8:1943:: with SMTP id g3mr42494096qtk.384.1553894133733;
        Fri, 29 Mar 2019 14:15:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyHZp9nRTZIs8x0mSHsF0HVYdrj16S2zkcbZ7sykcN3td5XSI8NUbEiR3L+8Q2gPHbeCs4A
X-Received: by 2002:ac8:1943:: with SMTP id g3mr42494055qtk.384.1553894133119;
        Fri, 29 Mar 2019 14:15:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553894133; cv=none;
        d=google.com; s=arc-20160816;
        b=E8U+gltPyLk51KwBGTAu5XUHD8SmKbXy4i6WrqKp8a9EwjuWCHVoeHug+9fAqTTdE1
         vbBcg3iLmWz3WbJ51ctnBG3/Scq+JMcXpArppPVdaV6UP/bAkMxTIURvLH2z2I5vtohS
         yCiEm2IzM/F4WClqvgoNzfc79xaC8Szps+AMz2SBLfCN2837Q9B3YpYsK4es/urgC792
         6mwQHN1bvRWj+f/I9NediixKPG0Ug0744fNun+R7Hv5d52KoJ82J4yrzkrlVjT84/w0p
         qbkh34QEttv4O5QzboYVz560xbh7PEr5oa5lZgWHqNXwoLS5hsadHR2pDTrTotNofpn6
         N9pQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=Po/nzgdtzi8v6Fo6duX4gx/DPJSZpnrMuV/kmJ0V3mE=;
        b=rlKBOTCz5YJ6wwqi9lmmtob3I033y1S1js4LKd+8KzAA27zMPRuUEBbAcXF7OIU4SN
         YDmAcjWXtjIb02hgBra5paWtyuPR7Y2QpDkA+N2gsN0HsqpZp9b/uodKJH2rWTl+oktl
         r9DsYYc3B6cpjA1q48Im6OEFo8n/9XYNfIOtZi0AjtI8/vZ1xb9aRZv10oyaDJVnvlde
         S6lfK99fkCn7vtF/bJNXe5AVQxBs6be23enI9HnZNZd2gXr7vT2a2Fjox7y9omAyB/nN
         V0IwMMcGZ8Z+ao4d7E8msgpj5bmGU5Xf6/SjwaE2PDPUTtMOx55mnv2d/RNacZ/GYIDc
         qRyw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k32si957081qvf.200.2019.03.29.14.15.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 14:15:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4B51280E7A;
	Fri, 29 Mar 2019 21:15:32 +0000 (UTC)
Received: from redhat.com (ovpn-125-57.rdu2.redhat.com [10.10.125.57])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 87C3F5C22E;
	Fri, 29 Mar 2019 21:15:31 +0000 (UTC)
Date: Fri, 29 Mar 2019 17:15:29 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Ralph Campbell <rcampbell@nvidia.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v2 01/11] mm/hmm: select mmu notifier when selecting HMM
Message-ID: <20190329211529.GA6124@redhat.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
 <20190325144011.10560-2-jglisse@redhat.com>
 <d4889f44-0cc5-3ef6-deeb-7302c93c1f90@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <d4889f44-0cc5-3ef6-deeb-7302c93c1f90@nvidia.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Fri, 29 Mar 2019 21:15:32 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 01:33:42PM -0700, John Hubbard wrote:
> On 3/25/19 7:40 AM, jglisse@redhat.com wrote:
> > From: Jérôme Glisse <jglisse@redhat.com>
> > 
> > To avoid random config build issue, select mmu notifier when HMM is
> > selected. In any cases when HMM get selected it will be by users that
> > will also wants the mmu notifier.
> > 
> > Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> > Acked-by: Balbir Singh <bsingharora@gmail.com>
> > Cc: Ralph Campbell <rcampbell@nvidia.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: John Hubbard <jhubbard@nvidia.com>
> > Cc: Dan Williams <dan.j.williams@intel.com>
> > ---
> >  mm/Kconfig | 1 +
> >  1 file changed, 1 insertion(+)
> > 
> > diff --git a/mm/Kconfig b/mm/Kconfig
> > index 25c71eb8a7db..0d2944278d80 100644
> > --- a/mm/Kconfig
> > +++ b/mm/Kconfig
> > @@ -694,6 +694,7 @@ config DEV_PAGEMAP_OPS
> >  
> >  config HMM
> >  	bool
> > +	select MMU_NOTIFIER
> >  	select MIGRATE_VMA_HELPER
> >  
> >  config HMM_MIRROR
> > 
> 
> Yes, this is a good move, given that MMU notifiers are completely,
> indispensably part of the HMM design and implementation.
> 
> The alternative would also work, but it's not quite as good. I'm
> listing it in order to forestall any debate: 
> 
>   config HMM
>   	bool
>  +	depends on MMU_NOTIFIER
>   	select MIGRATE_VMA_HELPER
> 
> ...and "depends on" versus "select" is always a subtle question. But in
> this case, I'd say that if someone wants HMM, there's no advantage in
> making them know that they must first ensure MMU_NOTIFIER is enabled.
> After poking around a bit I don't see any obvious downsides either.

You can not depend on MMU_NOTIFIER it is one of the kernel config
option that is not selectable. So any config that need MMU_NOTIFIER
must select it.

> 
> However, given that you're making this change, in order to avoid odd
> redundancy, you should also do this:
> 
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 0d2944278d80..2e6d24d783f7 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -700,7 +700,6 @@ config HMM
>  config HMM_MIRROR
>         bool "HMM mirror CPU page table into a device page table"
>         depends on ARCH_HAS_HMM
> -       select MMU_NOTIFIER
>         select HMM
>         help
>           Select HMM_MIRROR if you want to mirror range of the CPU page table of a

Because it is a select option no harm can come from that hence i do
not remove but i can remove it.

Cheers,
Jérôme

