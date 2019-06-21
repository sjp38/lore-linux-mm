Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AAF6CC43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 14:05:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 674CE2166E
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 14:05:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="aWygfjPx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 674CE2166E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE9048E0003; Fri, 21 Jun 2019 10:05:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E98EA8E0001; Fri, 21 Jun 2019 10:05:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D5F058E0003; Fri, 21 Jun 2019 10:05:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id B24A38E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 10:05:44 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id r40so8023469qtk.0
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 07:05:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=DkOzjPryuxAAZ6jj5aW+vqBCJ/xdXKjWwEy6q7BhjEk=;
        b=rZ1M78Q8xr+gY4pANxB3plvYABRTQIW9ZAUjUJnmVuZMi3sUpPbWl875QEIfobJpzK
         QMuw3va3sBfHYxIbbFV3o19p5N+nCfP5XZ80/negISOXGN9FArBAOQ1oyj/xSLVFg6j9
         wmwmyyIHEOIi9zNhBsAca61CXLOmQdt+l6aOI8c0Qcrs6vt0awCwsGAaZIkjIzXDLCeE
         6cbFX9SrbbCX4jXHclWCbTWcNYygjUL+lyM4LVdYq8xnRHHxRjt0HCZzC3bMeQafNpxg
         PHTglEYHp0Um+8eL/YdpYyLz7WqztHAPgXlWaoz8AW/cKIo4Vx3B3yIuIns79wGvO7WW
         h/Gw==
X-Gm-Message-State: APjAAAV2ljbY+Pc/SDbsML8fZ7oOA0GSpwH/WhRT+RDupvoxHu7IRifT
	kONNEg77M3Neh0/VdDztcHil1V33Z0VYrURbJja2ktkBfhmHSTaqVDv87EBdqeRW7WMLIRDwIeN
	U6m5ELTn8GDi3e8Gt8Nim0A4LB4H3ROBbb/cM4MBbOG36o5XjUHaHiFzs5MgRCZZ6rg==
X-Received: by 2002:a0c:aed0:: with SMTP id n16mr45416945qvd.101.1561125944467;
        Fri, 21 Jun 2019 07:05:44 -0700 (PDT)
X-Received: by 2002:a0c:aed0:: with SMTP id n16mr45416888qvd.101.1561125943818;
        Fri, 21 Jun 2019 07:05:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561125943; cv=none;
        d=google.com; s=arc-20160816;
        b=N6rpMeMUA4w9c6gKZBtmq/Kpct9OmJto0Mvaxc5pg15j/txfYveEeXgwlnstmUcSrn
         WUrWuikyRKzn1EuC66XRaJEgh7n4F0LQdUv3SvuE7WW6YiYajXF73w9Fo0EZQ032APmq
         8/lNiWwIbfpwMX9rgf1852FnR+uVM4Q3RiPouy0nwNj0GPVn/HkI7ocgSIyXysErvEk0
         t2l0hbnhFNJbdB9LIJJP0+O3+stD3tnK5TC0uBDRNxS+EI9x3D8vOfarCRjR/6EgFoqT
         YvMT394E8q3D9DhJvxQ5wXKTFTos4L63Jyx7CAOLk05/tst8EKoQrppWDE3CZo68BMSA
         sx0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=DkOzjPryuxAAZ6jj5aW+vqBCJ/xdXKjWwEy6q7BhjEk=;
        b=iZ1jREswpk2yEfCXM6GfXhfhY2OsTAHvhq0cPbTJ4W1X+6aAZB6t6Nu9c8Jgwk4aLD
         uxNMBWEppfy1Orvw7/AZM+AQRfnhPbhcScPmNNN7sAGMP12/E+KrqTq+C9xELtDyHbVR
         to7EDaCamQeCjxsYcNzN6W8QNVc9shFc/OuLz3SHQZ/tmV65wadadh77WegIlGwSej7j
         vzcN/80g7/ibqtbQuOPF13zA7Q8syNe+nFM57tgY8IiRUVA79dWrDpP7XbwIGf8STbvh
         N18+4wgUm8MX6VXUKXYUJRlLWUVU3wWiKfxSUzdy1g1CKJo8Adf5WKzgCVetdETLKXAm
         bbRA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=aWygfjPx;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t58sor2461348qvt.61.2019.06.21.07.05.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 07:05:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=aWygfjPx;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=DkOzjPryuxAAZ6jj5aW+vqBCJ/xdXKjWwEy6q7BhjEk=;
        b=aWygfjPxOlEI1tnMPH+ZEg4lwdm35MlZ9FC2Sv9mNYz1TXYg7zMy65oynguhqHPLHD
         5poTOWoehn2uMjooUllCl96WCJBItvfeaEybY0ihx7Fxw7kb42coN1wbRqEsylbfnfz5
         poQ9cLzRruP/gaTS5r2ivimvPxFxF10jIh6a1t8bY1c5/8nfCSLTPHFwmVvqBcrvoeSR
         IrRjd3ExmNKIoqdYb4sME5daBw+7RTgROqdSMT/mhe4d+vGey9AkE/rEcyeRljT6dNfy
         FwbLskfpDrkSyt1xncxh/ARyaZyhUUMnPNBaOl1L9cqI8FBxyq6cZOpH+4o3AamW6xDj
         GPoA==
X-Google-Smtp-Source: APXvYqzN1Bctip/8rcU9u7A4vdGN+f0/Jibs65Z8bT+DlW7GOUgigVYUV0gNRYHBistcmEEvwVki5g==
X-Received: by 2002:a0c:d610:: with SMTP id c16mr45427150qvj.22.1561125943463;
        Fri, 21 Jun 2019 07:05:43 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id i17sm1269594qkl.71.2019.06.21.07.05.42
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 21 Jun 2019 07:05:42 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1heKAg-0000Jr-7W; Fri, 21 Jun 2019 11:05:42 -0300
Date: Fri, 21 Jun 2019 11:05:42 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@lst.de>, Kamal Dasu <kdasu.kdev@gmail.com>,
	Ralf Baechle <ralf@linux-mips.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>,
	Nicholas Piggin <npiggin@gmail.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>, linux-mips@vger.kernel.org,
	linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 04/16] MIPS: use the generic get_user_pages_fast code
Message-ID: <20190621140542.GO19891@ziepe.ca>
References: <20190611144102.8848-1-hch@lst.de>
 <20190611144102.8848-5-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190611144102.8848-5-hch@lst.de>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 04:40:50PM +0200, Christoph Hellwig wrote:
> diff --git a/arch/mips/include/asm/pgtable.h b/arch/mips/include/asm/pgtable.h
> index 4ccb465ef3f2..7d27194e3b45 100644
> +++ b/arch/mips/include/asm/pgtable.h
> @@ -20,6 +20,7 @@
>  #include <asm/cmpxchg.h>
>  #include <asm/io.h>
>  #include <asm/pgtable-bits.h>
> +#include <asm/cpu-features.h>
>  
>  struct mm_struct;
>  struct vm_area_struct;
> @@ -626,6 +627,8 @@ static inline pmd_t pmdp_huge_get_and_clear(struct mm_struct *mm,
>  
>  #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>  
> +#define gup_fast_permitted(start, end)	(!cpu_has_dc_aliases)
> +

Today this check is only being done on the get_user_pages_fast() -
after this patch it is also done for __get_user_pages_fast().

Which means __get_user_pages_fast is now non-functional on a range of
MIPS CPUs, but that seems OK as far as I can tell, so:

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

However, looks to me like this patch is also a bug fix for this:

commit 5b167c123b3c3582f62cf1896465019bc40fe526
Author: Kamal Dasu <kdasu.kdev@gmail.com>
Date:   Fri Jun 14 17:10:03 2013 +0000

    MIPS: Fix get_user_page_fast() for mips with cache alias
    
    get_user_pages_fast() is missing cache flushes for MIPS platforms with
    cache aliases.  Filesystem failures observed with DirectIO operations due
    to missing flush_anon_page() that use page coloring logic to work with
    cache aliases. This fix falls through to take slow_irqon path that calls
    get_user_pages() that has required logic for platforms where
    cpu_has_dc_aliases is true.

> -	pgdp = pgd_offset(mm, addr);
> -	do {
> -		pgd_t pgd = *pgdp;
> -
> -		next = pgd_addr_end(addr, end);
> -		if (pgd_none(pgd))
> -			goto slow;
> -		if (!gup_pud_range(pgd, addr, next, gup_flags & FOLL_WRITE,
> -				   pages, &nr))

This is different too, the core code has a p4d layer, but I see that
whole thing gets NOP'd by the compiler as mips uses pgtable-nop4d.h -
right?

Jason

