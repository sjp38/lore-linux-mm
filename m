Return-Path: <SRS0=2YS/=UB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54615C282DC
	for <linux-mm@archiver.kernel.org>; Sun,  2 Jun 2019 21:48:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F08D6279E6
	for <linux-mm@archiver.kernel.org>; Sun,  2 Jun 2019 21:48:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F08D6279E6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=chris-wilson.co.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2EAF96B000D; Sun,  2 Jun 2019 17:48:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 29BD76B000E; Sun,  2 Jun 2019 17:48:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D8CA6B0010; Sun,  2 Jun 2019 17:48:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id C719D6B000D
	for <linux-mm@kvack.org>; Sun,  2 Jun 2019 17:48:26 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id t10so2699858wrq.0
        for <linux-mm@kvack.org>; Sun, 02 Jun 2019 14:48:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :content-transfer-encoding:to:from:in-reply-to:cc:references
         :message-id:user-agent:subject:date;
        bh=zpbgXFcrbiGi6+ZvSnGtxQJu46rzlIk7eAn1At3qOpI=;
        b=bx+V7CLn7sM/EmDu4lce5OMyRvpbZ0z0YdpXfVwJmEfZ3JCo/tt5+HAGkUmZdCzzRd
         9NMRkMccm4d4JBQ/KE+7Ue1q4IKyzexs9pYdCBDelL8AwZ01NlTUJVPrBHU0EUhYhSeR
         pLZ8XwsTE2auq9xfXIekrlVaFeufL7A+j//PVAwzI+LmKS8VjZk/8ZjNpBv/OAnhUPGm
         BYmaNh9oE1ivEjuugP0KZ9V4T6RdFjTsLgmrsJ5trNRpdgICQDNro1ZLheryZ0OeoUtd
         U97giCTIdpfCbvF8tu2lS/eLXTul8wG4p65cX49eE5af7ih2mgC3oZ6gVaTXtDEKp8Px
         qYhg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) smtp.mailfrom=chris@chris-wilson.co.uk
X-Gm-Message-State: APjAAAWmofW2I59mDTVJ6BE59ilBYOG75ZalgMEbBZ0ur51yF61dkXqU
	Zj3o54kOE6xZfMAgWz/srj0fmI9ICi7urwcOOqHOHk4OR669xgYp9gRl6NmEmsZ8NgEu0CBK9iq
	oz0lzUWCMpCptVLzpbxfxhSudSqATpUuO2edj8Oarz5FDEUTDWySchOIdcMNfPyU=
X-Received: by 2002:a1c:5687:: with SMTP id k129mr11637215wmb.133.1559512106348;
        Sun, 02 Jun 2019 14:48:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1c5D2ieusWHPSuQ3JLXBvLGOOsEg+NpvlIBNrIjk5X8rT6n0QVLBFNYZj1atxXyDMOKm/
X-Received: by 2002:a1c:5687:: with SMTP id k129mr11637194wmb.133.1559512104790;
        Sun, 02 Jun 2019 14:48:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559512104; cv=none;
        d=google.com; s=arc-20160816;
        b=GuLc0eM+NhiAWKxvKaHB+uC5bK/jQxN4uQmKLz+25bRw1a4N0EawS3OgliiYhbaiJF
         ODumhEJld/DPBy+YF/Ku59tvgpcibKx/AKNm43nDvT65P5IRkMKyOP0TgzAngb+uF8nR
         vIxDPkcNxKgu9Iw6mVQDdAsnhTd9+WcLP+LD0Iw69MfAV4isQS+8pmf5Q4D7qtLwaNyC
         1dPT7uTGjBffYTj1aLaHvoD/vJlXObjOPBBrnCOcNl3DVjAcI/L4wQERmZmCkrnBxAMJ
         G2ue7bEPxf1HldtqIcEbfqknvAdZjDn6e8+01VXmEdcDVDKEtMfo5QmQyfrvjCy3iHdF
         GAjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:subject:user-agent:message-id:references:cc:in-reply-to:from
         :to:content-transfer-encoding:mime-version;
        bh=zpbgXFcrbiGi6+ZvSnGtxQJu46rzlIk7eAn1At3qOpI=;
        b=a4rLmAT/LwyHjgGHxGxkrHWC2FcCURXXWDEPouAeL5ar4vNlmUOtcAUs2RJNTG8YJP
         xX0T61t8Zh8gAIzHwqEAw10KLCNjsrEnB4P21GMcpgAymEW/zg3ZZrrBzfFLPcFSUI7L
         vmrctpiAEn5cAzjsBF/ahrX+onDiovB2ETd/Wxh28M0xyfpyvdofbr963+TgwipFEUp9
         BSpRaDGCMkIItyqn97eROP+5b3U5xguVReCk+yvZ01q6l7pKpIINk+K2wls6ZVbPI9dR
         zJREtb1QHN/oiKll1L5WKmzqG/9nnpTyrOwRIOTfV2h2WjsTB2ZulsPIfLb3QgzR7H28
         Q7Qg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) smtp.mailfrom=chris@chris-wilson.co.uk
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id d16si9170484wrj.159.2019.06.02.14.48.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Jun 2019 14:48:24 -0700 (PDT)
Received-SPF: neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) client-ip=109.228.58.192;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) smtp.mailfrom=chris@chris-wilson.co.uk
X-Default-Received-SPF: pass (skip=forwardok (res=PASS)) x-ip-name=78.156.65.138;
Received: from localhost (unverified [78.156.65.138]) 
	by fireflyinternet.com (Firefly Internet (M1)) with ESMTP (TLS) id 16768558-1500050 
	for multiple; Sun, 02 Jun 2019 22:47:39 +0100
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
To: Andrew Morton <akpm@linux-foundation.org>,
 Matthew Wilcox <willy@infradead.org>, linux-fsdevel@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
From: Chris Wilson <chris@chris-wilson.co.uk>
In-Reply-To: <20190307153051.18815-1-willy@infradead.org>
Cc: Matthew Wilcox <willy@infradead.org>,
 "Kirill A. Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>,
 Jan Kara <jack@suse.cz>, Song Liu <liu.song.a23@gmail.com>
References: <20190307153051.18815-1-willy@infradead.org>
Message-ID: <155951205528.18214.706102020945306720@skylake-alporthouse-com>
User-Agent: alot/0.6
Subject: Re: [PATCH v4] page cache: Store only head pages in i_pages
Date: Sun, 02 Jun 2019 22:47:35 +0100
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Quoting Matthew Wilcox (2019-03-07 15:30:51)
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 404acdcd0455..aaf88f85d492 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2456,6 +2456,9 @@ static void __split_huge_page(struct page *page, st=
ruct list_head *list,
>                         if (IS_ENABLED(CONFIG_SHMEM) && PageSwapBacked(he=
ad))
>                                 shmem_uncharge(head->mapping->host, 1);
>                         put_page(head + i);
> +               } else if (!PageAnon(page)) {
> +                       __xa_store(&head->mapping->i_pages, head[i].index,
> +                                       head + i, 0);

Forgiving the ignorant copy'n'paste, this is required:

+               } else if (PageSwapCache(page)) {
+                       swp_entry_t entry =3D { .val =3D page_private(head =
+ i) };
+                       __xa_store(&swap_address_space(entry)->i_pages,
+                                  swp_offset(entry),
+                                  head + i, 0);
                }
        }
 =

The locking is definitely wrong.
-Chris

