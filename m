Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7BE2C31E44
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 01:46:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A22820883
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 01:46:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="HXRALFEY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A22820883
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 23F466B026B; Tue, 11 Jun 2019 21:46:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1EF176B026C; Tue, 11 Jun 2019 21:46:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0DF896B026D; Tue, 11 Jun 2019 21:46:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id AFE996B026B
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 21:46:36 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id l26so23421491eda.2
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 18:46:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=LXj97QV1xj0YMzJTfwO7V63Jo2GxebtIwJp0QMGiowU=;
        b=uROIH+HLct+NsqdXJRt7UlpJNV8A38zp4Rk3A/ti9j6vVD40eJUG9sE1enAMHhjPG3
         nqnHeXCt6QCDbSRjB7DZQlSCs2JL+UA1rd5E51GJ5KldO29AIX/m2M6lYl7FRyaOSGhT
         K+GJ6aKo3fzrTZeaEI2a2DVOsNZNzLPsmm2nJ2hsTitfZ2xvkupjyfFGwJvCdHUhVLsp
         gK6wqay7FcK8nSre4EhTij5EAIUqdaR1iyxIYaB4kZkMzzOsJo/33jZdPNlNIX/PXaWF
         pTm22ogL29vGrn7+jHkz9BNr7IbdgWr2pLzqgSGJ9I+mbqJ7Zr32wQxWkM31+emYLgRA
         tf8w==
X-Gm-Message-State: APjAAAW4QfNlmY+SHNT6E4QbppkSA4nkhnf+WkJJ8STjJ2g+xZC5e1qD
	WiY8YLwcgVU+dRsO+yPUlJANh/4NQy22zRFdpq4THpdA08VsELTFlRpp388uUHwqsIpLscLigJr
	4yVgalxu5NBeVqrHzKiujBJLN6JbuEEB1N5owDt8XYjOzcLM2PotO4m7bw7Mjmh7Dag==
X-Received: by 2002:a17:906:c9d7:: with SMTP id hk23mr25558262ejb.260.1560303996104;
        Tue, 11 Jun 2019 18:46:36 -0700 (PDT)
X-Received: by 2002:a17:906:c9d7:: with SMTP id hk23mr25558222ejb.260.1560303995343;
        Tue, 11 Jun 2019 18:46:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560303995; cv=none;
        d=google.com; s=arc-20160816;
        b=SFEiBPMFH9Z9j/YG2LbwOGVbOU6Z9Z+9QAEgEjeTGROES7zgGK+TG/FqrwyM7uwtyA
         nlaAMUsxPXR3QfV99dVAer65tPDAMW8PW6zPV9ZN/z5EPi9rGdb0B4XwWMrgSfjPEUag
         h5HLVSIR6u3ntLpeVGkvejqwymt70RWXgwp3Yw8haNqXimWCU1+4mDX/RAE3BOlhNEGn
         /c89wEv9TuiXIEKlAVI4G8iicg8T4eZpuJL9m6YVSEqgyQNWmFQZ5OQhHZ9tXfLB5bgg
         D8BgST7Tl1ubct25MZO6n/L+DHIPej64MkZgRbkzklf9ZcBshBGlGnSzBXFeBqU9bIJH
         8cuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=LXj97QV1xj0YMzJTfwO7V63Jo2GxebtIwJp0QMGiowU=;
        b=T6wPBud8TyfxJxZYda3yspBSVSabgv5AlkbAryg+XRLxh/CeiWtB8CXv/4a4+19iKk
         G+L5Y5MSESLgaH+zf6h7kKY1gn628ZHejojc7slH7DahmjIp4GDMYEt85t6D4OcYBP06
         UqIhHBei61EcB2fc3tldZv9VX8lQtXV4JWAlXXKqBL0hLGxRVToODnwk5ppzsDo7OIYE
         7O/Mxgpn2QXoFKsfCMdtqXAYGOV/PtFSvmHsna68pBsr92BC8xdmreD2O6Z9kqAdas7t
         O16lnNoiiXcFu96DzjtSVyn29nNzvT5clzPHrS33Uq5q7UmETQdYN+GMDvuk9lRuhcne
         focw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=HXRALFEY;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d9sor1409546edz.11.2019.06.11.18.46.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Jun 2019 18:46:35 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=HXRALFEY;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=LXj97QV1xj0YMzJTfwO7V63Jo2GxebtIwJp0QMGiowU=;
        b=HXRALFEYuiiWfCAMv5ihCzb+blJRwM2p40Q+4CrmWGOBIgEkIDSwBrEmzJYKQ+tQQG
         z2zhnfgt9xZBNdaJnC4IYxdve974bp8GqdRK0VoTR77WKjzD+KD0JIztls5JApZ5hV+F
         OZ26YVVQJtbKfc4dhoGKHLxGltQMUFpy31s8E4bdelVuXnJSkCJzxdSGyZILsBzUq80t
         f2c+1jkR/tn+MjiDAWne64fh2CCM+Ju3910qo87nTjZEZJjXCiYH7ZeVy12toNmoHyaz
         IxnqUNMjynTbSnz5WxKPBzjlGaW/AxuUfXPeCSCnkTypuYPRZ93+e0sfsOSBZY616mof
         zdBg==
X-Google-Smtp-Source: APXvYqwI5Qv0C/a0lrl6mzuoFXDCntFWruXenrhqcLo08+2SpUh6wATX727OIc7E2oRZg6ayc5q2AQ==
X-Received: by 2002:a50:ad01:: with SMTP id y1mr62139325edc.180.1560303994960;
        Tue, 11 Jun 2019 18:46:34 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id a53sm1063966eda.56.2019.06.11.18.46.34
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 18:46:34 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 0011A10081B; Wed, 12 Jun 2019 04:46:34 +0300 (+03)
Date: Wed, 12 Jun 2019 04:46:34 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <willy@infradead.org>, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>,
	Song Liu <liu.song.a23@gmail.com>
Subject: Re: [PATCH v4] page cache: Store only head pages in i_pages
Message-ID: <20190612014634.f23fjumw666jj52s@box>
References: <20190307153051.18815-1-willy@infradead.org>
 <155951205528.18214.706102020945306720@skylake-alporthouse-com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155951205528.18214.706102020945306720@skylake-alporthouse-com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jun 02, 2019 at 10:47:35PM +0100, Chris Wilson wrote:
> Quoting Matthew Wilcox (2019-03-07 15:30:51)
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index 404acdcd0455..aaf88f85d492 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -2456,6 +2456,9 @@ static void __split_huge_page(struct page *page, struct list_head *list,
> >                         if (IS_ENABLED(CONFIG_SHMEM) && PageSwapBacked(head))
> >                                 shmem_uncharge(head->mapping->host, 1);
> >                         put_page(head + i);
> > +               } else if (!PageAnon(page)) {
> > +                       __xa_store(&head->mapping->i_pages, head[i].index,
> > +                                       head + i, 0);
> 
> Forgiving the ignorant copy'n'paste, this is required:
> 
> +               } else if (PageSwapCache(page)) {
> +                       swp_entry_t entry = { .val = page_private(head + i) };
> +                       __xa_store(&swap_address_space(entry)->i_pages,
> +                                  swp_offset(entry),
> +                                  head + i, 0);
>                 }
>         }
>  
> The locking is definitely wrong.

Does it help with the problem, or it's just a possible lead?

-- 
 Kirill A. Shutemov

