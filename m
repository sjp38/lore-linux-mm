Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3E85C10F04
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 22:30:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A068A21B18
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 22:30:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="n3IgNoNh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A068A21B18
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 31FDC8E0004; Thu, 14 Feb 2019 17:30:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A8E68E0001; Thu, 14 Feb 2019 17:30:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 149538E0004; Thu, 14 Feb 2019 17:30:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id C29108E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 17:30:02 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id f3so5345629pgq.13
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 14:30:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=57+CqfjmpoWyrfnhc239KRVxSUTm0mnX+kNtxVFNyHU=;
        b=UMfomC6SYfzl/YHf3HrcXXx0/FRF+kWiJGn50MEPLlBmznOS1dNgdCzAx0+2E7bVHG
         sl4xKn9+EH2vPdMSYF2ICMP1+tf4rhjurxQ2Ga4We4t/D1aQuL59dK+0DK1HnZda+oyJ
         P+koNiG3LBsLswb04F16MqxLFJZNMAVLYTGYWBh62peBRWtEwNvSpy/cjRgxnGW+LGvD
         73ASEYxp8e/Su6FaqMx1mhdO+6X8eqC404wOSSiSkdBL1nCdxukOwDBlN7ibfHN1xIJ8
         sonSqbmjhWBXRnpcVEqGSe/fzRAluk2LeuBDeSK28Lkrffd9IUKjt/49XGZu1VOdREhD
         lW3w==
X-Gm-Message-State: AHQUAuYxG7dxS62TMvmLzwYbTyBTUiMIbQVGrOqn2fMnL4J1upqgeXbY
	YGNAO0u14PsdgVOdUk6RbzEv3339s8rK1IEOO7ny0MrLzuyHGZ46Ou8UP1DMmqpvjlMX3zS+RXj
	1FAzrhmWwMcRraZf8HkMeUcB7mU258Upl4zk83tAte+L4E3HhSu9OizmWj+IXxbKixVHU3CGan+
	vdAdoLbifh+Ma7OeMSbyTQbOBDJifuP+837xYtTKI/xdv7Y3sXMABb2SM8uu61W/9bbyDIex4nq
	7/VuunOvlVbPmsKFUPdm3SMwPk14xppEMJLQZiEUfOcGV/smGOiyzLlO1xRguq4ac2HQ++nCcds
	B1T8RGGXNJjo6CMlGVoQTD0yHDYgcADa0NuhqX/yQZTBClQtUSjmZMAJqKP7RG8fQCjkIjG45Xa
	+
X-Received: by 2002:a63:4703:: with SMTP id u3mr2170487pga.298.1550183402464;
        Thu, 14 Feb 2019 14:30:02 -0800 (PST)
X-Received: by 2002:a63:4703:: with SMTP id u3mr2170432pga.298.1550183401696;
        Thu, 14 Feb 2019 14:30:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550183401; cv=none;
        d=google.com; s=arc-20160816;
        b=06ktLkIw4eSsVGPaVOY7N6TbpGBjYz9F5wjyPsCG9n7smX4qdYkbH2omFDLtdmU+YO
         UtBoWePscL698nLzmUb/8l3+gLvyQSTquPEeTC5dxihl/psQPa5NWRJTQSmF68+rDpGr
         0tWjwPuc44u5LlZ8bVnZLrJfxZWsipMfOPVrh9T2AOhvygpVV4rA4dWcdosDT/WtkRKW
         0aoNDEKLYYO52SvVcwxplYh891XwRxE3Cg0/Mtu2A70h1VVTV9NAEGXGGTPQpJQ6T3KT
         lJM6+BvnrHmZLFHZyfx7N9FaDn5PcSjcKuHUFYfBX6wk/XmOgHyU9rkGoHe2voJfoVr3
         Hz3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=57+CqfjmpoWyrfnhc239KRVxSUTm0mnX+kNtxVFNyHU=;
        b=Qk/wJhWUSh9gSU2kBv7tbitjD8OO5SSOlkXEDw67svgzi/BWbDfLLufT0fjbUpXho4
         Otc107qnjvRdJodPeRyXGcpDNfTAX7SVjIFmi8qHWSOPMUk4/AKFB5LKhwq/j5rLJd5L
         MmSyRy7qWB6IMXo9mJqdHS4Q4CNpEwpKyBygNlQgKT5qlHQUt/lJOMZagjmXyG0aLs7h
         /RomA7EJfjiIEYOklf2kJQ9dHatVVwO0tjt0ozMnCZE7z9GFYUYm4URKfMouGQpgY2Tk
         6+Z9o9CwPJ6HvZmh+XMWVI46ksghqHUdk37iOsZGgI+Bjkvm1erZoIbcAdSNj4/f3z2j
         lBmw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=n3IgNoNh;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m5sor6223019pfm.10.2019.02.14.14.30.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Feb 2019 14:30:01 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=n3IgNoNh;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=57+CqfjmpoWyrfnhc239KRVxSUTm0mnX+kNtxVFNyHU=;
        b=n3IgNoNhVGLIE3Ae/mpYA4gol7LB3wSkbVVitAx2d3rr7+bF978g8xq6VnOX9BsjI4
         42OYeKn8o5QmBa5CcZ6pcwDG6enJI1UzPxnAHOdoQOQpwNy7pUegMSkBJayJnopg0utu
         P2u8emb7/ZW4pXifLX5S82CQHiTTMx3O+7+Di/nWUYMZ1rw24Hhz62VW5UXO2lh89FAB
         iagznw08a9Y1Qy8CZqhng9C5D85SjKsoAXUr9wnjV757vayqLBR65r0g60QRwb405EUM
         V1fUQwLUyPeUfq/lWrDeY/e6xQBnW7efSospsZ8KrivdOmhZVYOZNCUOMM+GIjF46Q/h
         9MmQ==
X-Google-Smtp-Source: AHgI3IZEeU5VJRySDFSpv/e0+oTrxhNeqc1ub76DDcsblsNUiIpAZ8q5PMfzWUfYshuVR6xz7jOSZw==
X-Received: by 2002:aa7:8286:: with SMTP id s6mr6407766pfm.63.1550183401435;
        Thu, 14 Feb 2019 14:30:01 -0800 (PST)
Received: from kshutemo-mobl1.localdomain ([192.55.54.45])
        by smtp.gmail.com with ESMTPSA id a13sm3815595pgq.65.2019.02.14.14.30.00
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 14:30:00 -0800 (PST)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id BDDB13008A8; Fri, 15 Feb 2019 01:29:57 +0300 (+03)
Date: Fri, 15 Feb 2019 01:29:57 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>,
	William Kucharski <william.kucharski@oracle.com>
Subject: Re: [PATCH v2] page cache: Store only head pages in i_pages
Message-ID: <20190214222957.a5o7zkc6p7zlqy3m@kshutemo-mobl1>
References: <20190212183454.26062-1-willy@infradead.org>
 <20190214133004.js7s42igiqc5pgwf@kshutemo-mobl1>
 <20190214211757.GE12668@bombadil.infradead.org>
 <20190214220810.cs2ecomtrqc6m2ap@kshutemo-mobl1>
 <20190214221158.GF12668@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190214221158.GF12668@bombadil.infradead.org>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 14, 2019 at 02:11:58PM -0800, Matthew Wilcox wrote:
> On Fri, Feb 15, 2019 at 01:08:10AM +0300, Kirill A. Shutemov wrote:
> > On Thu, Feb 14, 2019 at 01:17:57PM -0800, Matthew Wilcox wrote:
> > > On Thu, Feb 14, 2019 at 04:30:04PM +0300, Kirill A. Shutemov wrote:
> > > >  - migrate_page_move_mapping() has to be converted too.
> > > 
> > > I think that's as simple as:
> > > 
> > > +++ b/mm/migrate.c
> > > @@ -465,7 +465,7 @@ int migrate_page_move_mapping(struct address_space *mapping,
> > >  
> > >                 for (i = 1; i < HPAGE_PMD_NR; i++) {
> > >                         xas_next(&xas);
> > > -                       xas_store(&xas, newpage + i);
> > > +                       xas_store(&xas, newpage);
> > >                 }
> > >         }
> > >  
> > > 
> > > or do you see something else I missed?
> > 
> > Looks right to me.
> > 
> > BTW, maybe some add syntax sugar from XArray side?
> > 
> > Replace the loop and xas_store() before it with:
> > 
> > 		xas_fill(&xas, newpage, 1UL << compound_order(newpage));
> > 
> > or something similar?
> 
> If we were keeping this code longterm, then yes, something like that
> would be great.  I'm hoping this code is a mere stepping stone towards
> using multi-slot entries for the page cache.

Fair enough.

-- 
 Kirill A. Shutemov

