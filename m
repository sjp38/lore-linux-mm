Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC0E6C31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 14:59:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A2A6821537
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 14:59:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="WzNVrOBd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A2A6821537
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 314216B0007; Fri, 14 Jun 2019 10:59:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C47A6B0008; Fri, 14 Jun 2019 10:59:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B3466B000A; Fri, 14 Jun 2019 10:59:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id EE5F16B0007
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 10:59:28 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id v4so2258136qkj.10
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 07:59:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=5z2Pz9BEyGq7RJT7oSwXGEkkJAkO10nXW654v8UxM6g=;
        b=M/LjxrCK6DXKIw1r2OdZaoEHGcJ1OmoNeRjj7blmjV9qtdoGaMFqR0NSGXmK4ga56S
         F3hWc/r146mhBQHYjadjr6tD1isz9GaFkt7t9uhlSo0VxomuDXpOJPvB8E2xJ1Us3xVb
         4acEgjajFx1qGhSuiVkr/8qZuIz+yyn1J34yqHLkyiaN4J6qef1PJgQUOwLYRBavBXHk
         toNCDEaEK2bkKDBGT1oHEDln++ZDSK2yBoE8U2roVfiFMWW3FS3Ogt51pDRAM3wBSs1/
         bUyy52RTS8QMvtDo3ds+0wd5OCYD7FuqgC4yI1GdxPKK/62GK+HWcsYOYH/gd1sEh9md
         f0pA==
X-Gm-Message-State: APjAAAXJeqC2pIuKvdOXCevdp2uhlIHK4x+MHC8r5nmOfS/sFY9vsCTu
	Bsq2Jwu6gaw5lSFPyyBFSVd5i2UVhc58FSd2JTeY3OuDaOXaLijtr+dlR2g8wlMwTsuWHlvnK54
	5h9sW7fEOOLZjU+rg1oftrrJP10zMIBTqp2FINggTBI1S/ROs9dPP9fNh/ktKUKnZKg==
X-Received: by 2002:ac8:94f:: with SMTP id z15mr46675414qth.265.1560524368733;
        Fri, 14 Jun 2019 07:59:28 -0700 (PDT)
X-Received: by 2002:ac8:94f:: with SMTP id z15mr46675371qth.265.1560524368135;
        Fri, 14 Jun 2019 07:59:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560524368; cv=none;
        d=google.com; s=arc-20160816;
        b=pBNUbzlm2ejCZCZ/7xOaFCBMpvA8BQf2485mtXjaQPD+IFNM+2xzGHad1BuxedVe70
         tnAaZNnwW1rS8GlLjiaOai/BjDJQWx2zBvBBdrcjzkxPM2PzfodzJEZwv3WsV5N7EsUA
         zkRcjzRU2YX+ozZSuw2xI2PW8yLk/EifZfagbCwkW85Mn3sCY0Pbco2ISzUNgEeICRvQ
         MltiWF/GtufyOySbjaisk6FRNCd2ER04vX1L/i/chR4y22PAy6tg2Ct5+gK7R/3/ZTM7
         9yNp1Tdb1GFAYFB01tZSoIBv6UOcCvK5UmjW9p0iK5j5HIntntuO+VQ9NyHDPJZ8R40T
         c3SQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=5z2Pz9BEyGq7RJT7oSwXGEkkJAkO10nXW654v8UxM6g=;
        b=vkejH9hkmn3CY4zICdtqnwZRnwYPzgdLzCuEx0z/9CNmfIv6UYAymOmGWahJNrz5O5
         sZePySe6MM19hjdN8GTlEmt/ZmoLaAre33shFdrdK526Trg2xrzZ0BzXQX2mXwFrlR9k
         P8vpFLTd1yswTOTE9+0Eu/Cs8LGUvWN7njivgkEs5fA0A2sGUAw6ECSyzojijdXXCoIR
         W+pi3YNdT2Ptt5wgIXoJSUpKszasrEDvpQOlHmWyj8upfaO5HYTQKcnfMzXIw0eOpQzT
         ZpdN5q3d09P4HAX4emq+FBnhftxqiOxJ1kOHgjxZx6cPb7oi1Q2NgCj5iIOg53MYjLIu
         VdAA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=WzNVrOBd;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a8sor4898259qtm.7.2019.06.14.07.59.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 14 Jun 2019 07:59:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=WzNVrOBd;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=5z2Pz9BEyGq7RJT7oSwXGEkkJAkO10nXW654v8UxM6g=;
        b=WzNVrOBd17Pk5xfQND6MhYXpenRxgHkYF6+NIHY7bXPGySvJWnA4Yc5m/7jqocYAVx
         nTrcDq6ANA2a920ACj3SsqsjF/thm1dKOTQodWJSnroRL7n10qZOOIuDGVx0ljoBaROR
         hLa/IhZRI7QfKibOJvG/7RzUho1Pu8cy9+Uhnt8lmT6kZeU09kSH02M/IqiDeVEl+E+2
         5s/xKQU+RT5r5a4slL5v/ITGAbcYb+PGmPoI6NegmH/rqdPpxS8Q4dIGUiEvEqy6jrYV
         s6VH8U4Ql0ajpdx5rS6/X/rje8aqnk8n12k9vFWka8I7ICAl41Z1O9v3sUhO3JIEIgBZ
         VSyg==
X-Google-Smtp-Source: APXvYqx3Gg4yTUqFYBGtbb6cacElACxIxE3Pvk81wkhcKZ5g0ia7pAZnlMD1JRW94Q3de08FfWw//Q==
X-Received: by 2002:ac8:2ae8:: with SMTP id c37mr27433373qta.267.1560524367784;
        Fri, 14 Jun 2019 07:59:27 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id g10sm1458390qki.37.2019.06.14.07.59.26
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 07:59:27 -0700 (PDT)
Message-ID: <1560524365.5154.21.camel@lca.pw>
Subject: Re: [PATCH -next] mm/hotplug: skip bad PFNs from
 pfn_to_online_page()
From: Qian Cai <cai@lca.pw>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Dan Williams
	 <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador
 <osalvador@suse.de>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing
 List <linux-kernel@vger.kernel.org>
Date: Fri, 14 Jun 2019 10:59:25 -0400
In-Reply-To: <87lfy4ilvj.fsf@linux.ibm.com>
References: <1560366952-10660-1-git-send-email-cai@lca.pw>
	 <CAPcyv4hn0Vz24s5EWKr39roXORtBTevZf7dDutH+jwapgV3oSw@mail.gmail.com>
	 <CAPcyv4iuNYXmF0-EMP8GF5aiPsWF+pOFMYKCnr509WoAQ0VNUA@mail.gmail.com>
	 <1560376072.5154.6.camel@lca.pw> <87lfy4ilvj.fsf@linux.ibm.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-06-14 at 14:28 +0530, Aneesh Kumar K.V wrote:
> Qian Cai <cai@lca.pw> writes:
> 
> 
> > 1) offline is busted [1]. It looks like test_pages_in_a_zone() missed the
> > same
> > pfn_section_valid() check.
> > 
> > 2) powerpc booting is generating endless warnings [2]. In
> > vmemmap_populated() at
> > arch/powerpc/mm/init_64.c, I tried to change PAGES_PER_SECTION to
> > PAGES_PER_SUBSECTION, but it alone seems not enough.
> > 
> 
> Can you check with this change on ppc64.  I haven't reviewed this series yet.
> I did limited testing with change . Before merging this I need to go
> through the full series again. The vmemmap poplulate on ppc64 needs to
> handle two translation mode (hash and radix). With respect to vmemap
> hash doesn't setup a translation in the linux page table. Hence we need
> to make sure we don't try to setup a mapping for a range which is
> arleady convered by an existing mapping.

It works fine.

> 
> diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
> index a4e17a979e45..15c342f0a543 100644
> --- a/arch/powerpc/mm/init_64.c
> +++ b/arch/powerpc/mm/init_64.c
> @@ -88,16 +88,23 @@ static unsigned long __meminit
> vmemmap_section_start(unsigned long page)
>   * which overlaps this vmemmap page is initialised then this page is
>   * initialised already.
>   */
> -static int __meminit vmemmap_populated(unsigned long start, int page_size)
> +static bool __meminit vmemmap_populated(unsigned long start, int page_size)
>  {
>  	unsigned long end = start + page_size;
>  	start = (unsigned long)(pfn_to_page(vmemmap_section_start(start)));
>  
> -	for (; start < end; start += (PAGES_PER_SECTION * sizeof(struct
> page)))
> -		if (pfn_valid(page_to_pfn((struct page *)start)))
> -			return 1;
> +	for (; start < end; start += (PAGES_PER_SECTION * sizeof(struct
> page))) {
>  
> -	return 0;
> +		struct mem_section *ms;
> +		unsigned long pfn = page_to_pfn((struct page *)start);
> +
> +		if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
> +			return 0;
> +		ms = __nr_to_section(pfn_to_section_nr(pfn));
> +		if (valid_section(ms))
> +			return true;
> +	}
> +	return false;
>  }
>  
>  /*
> 

