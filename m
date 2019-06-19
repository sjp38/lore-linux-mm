Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC406C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 10:04:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D66720B1F
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 10:04:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D66720B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=chris-wilson.co.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB3536B0003; Wed, 19 Jun 2019 06:04:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B62BE8E0002; Wed, 19 Jun 2019 06:04:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A78EA8E0001; Wed, 19 Jun 2019 06:04:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5B5626B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 06:04:42 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id y80so1276078wmc.6
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 03:04:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :content-transfer-encoding:to:from:in-reply-to:cc:references
         :message-id:user-agent:subject:date;
        bh=mLb5D5jjVH2I+raMOWto7JJt0ckKsBK/gtCk8zsymwE=;
        b=brK+mXrFvMtI6+eYtC+Q3XbOXtnY4W923tHo8QltRqZ3WUJuA/N4HMYrlRVEUf7G39
         NQ6E87kYfkHYhXR6+mLYpJ0E8BsO7Iy/RIJPCHwttm6CmdRioUq7ALFhgxTHtToTRlrK
         JS1J5wbpJPmH3Q0eYNeUUTq9YlDIeGV7jcU4dfNnLGMrAzA+ydbHAVVqRmnMq5yz1Cxn
         XQYMkoG6oZRifuPEpfqui+vVGrz92z6DiGEsuP9uj6TkaeNb6GJ7BF4ryFe1XM7Lbeb3
         r5e0BNqqvpRYKQmZz+XQH20pVYJk6o5zO3I/YUsh2l+S/Px12I+Uo+lHT9J4a/a2Qbdy
         33Hw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) smtp.mailfrom=chris@chris-wilson.co.uk
X-Gm-Message-State: APjAAAW776i6ePZ+47yCl4VzGLvgRNheEXPsvOGXd9EnPFEp6qrKzgKE
	665E7o2U1s/YH4yzAomi+1g31eCHG1CAc5EzH4wmmGK3Ef2ttwuVMa6TDYcGd/NH8AuDRcAF+lz
	3rI53w+qvd2Jl8IA+LQitYmR4nrNrGT4t2x2WAUIFyltF+QOzQ8UggVBo489ZQOY=
X-Received: by 2002:a7b:ce95:: with SMTP id q21mr7637932wmj.65.1560938681777;
        Wed, 19 Jun 2019 03:04:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwXMbZtfWtMhtCumIoB4/pKlIv/VnDXCGP5Oo4FO/IO/twoDEfvoPdggjjAP9CYy5ou3A4w
X-Received: by 2002:a7b:ce95:: with SMTP id q21mr7637661wmj.65.1560938679140;
        Wed, 19 Jun 2019 03:04:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560938679; cv=none;
        d=google.com; s=arc-20160816;
        b=ODbIPlw+ukO+3JTLnONackg6/hsSaSU3u1O/DPNQjoo5MAfA4CEamzNTKi/HTerjZp
         N2wbw1Mp8p4VIqTDzPj/yEqUPkkv/biUPPN3iCf7sO0MsxKouZxanMSf2vN24Cy98o/2
         OssUNWTexvyC+c2Xe+YOQ5WN5cqVAKTha86ZBm0gZ3LN5tV0tpnhESksluucvD9rmBWb
         97KUxuyAp8xcdzJWkkKBmkWsbj1SsbUqj6Mf1SMGpPRyEsu492JoRIYumfg96PAIjv5V
         XF5/HHdgnNrmos+HcDMfIFqOtSxiIWArSvUrpud1HRdMx5dwELV4+JGTNGq83eLMyKwH
         /wWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:subject:user-agent:message-id:references:cc:in-reply-to:from
         :to:content-transfer-encoding:mime-version;
        bh=mLb5D5jjVH2I+raMOWto7JJt0ckKsBK/gtCk8zsymwE=;
        b=hIwEJaphLTPZSzhu72Hl7ATjlT5MxuOwN+2xAvLEZ91snc415iRoxa2pSIL7MiMSdN
         1KEN0ymJcxVMLEheZY5+XQMhhoaUCrqUEiHF94lDxJldikCy/u4dGMuxKsSIANHiO/sE
         WMnjYUEFr/44Fk3cNnr4LU8pam5nE7lghWrWpZaaq3LlJo/fhUBVa4PAz+rZHgm0rMtv
         936BvaHNN7Oz04UoEeDZcnU3PUD/0Kmke0lxhw+ARDN3euyMTo4Onk5wSkVLTjUzEADU
         mu7y6LomPBkYwVjrfW8VTNlpypkXpszuBepJuwdv2611rhzOB+Xlmgs6YNH092VCZbfx
         GH5g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) smtp.mailfrom=chris@chris-wilson.co.uk
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id y10si14060216wru.164.2019.06.19.03.04.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 03:04:39 -0700 (PDT)
Received-SPF: neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) client-ip=109.228.58.192;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) smtp.mailfrom=chris@chris-wilson.co.uk
X-Default-Received-SPF: pass (skip=forwardok (res=PASS)) x-ip-name=78.156.65.138;
Received: from localhost (unverified [78.156.65.138]) 
	by fireflyinternet.com (Firefly Internet (M1)) with ESMTP (TLS) id 16950740-1500050 
	for multiple; Wed, 19 Jun 2019 11:04:28 +0100
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
To: "Kirill A. Shutemov" <kirill@shutemov.name>
From: Chris Wilson <chris@chris-wilson.co.uk>
In-Reply-To: <156032532526.2193.13029744217391066047@skylake-alporthouse-com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Matthew Wilcox <willy@infradead.org>, linux-fsdevel@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>,
 Song Liu <liu.song.a23@gmail.com>
References: <20190307153051.18815-1-willy@infradead.org>
 <155951205528.18214.706102020945306720@skylake-alporthouse-com>
 <20190612014634.f23fjumw666jj52s@box>
 <156032532526.2193.13029744217391066047@skylake-alporthouse-com>
Message-ID: <156093866933.31375.12797765093948100374@skylake-alporthouse-com>
User-Agent: alot/0.6
Subject: Re: [PATCH v4] page cache: Store only head pages in i_pages
Date: Wed, 19 Jun 2019 11:04:29 +0100
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Quoting Chris Wilson (2019-06-12 08:42:05)
> Quoting Kirill A. Shutemov (2019-06-12 02:46:34)
> > On Sun, Jun 02, 2019 at 10:47:35PM +0100, Chris Wilson wrote:
> > > Quoting Matthew Wilcox (2019-03-07 15:30:51)
> > > > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > > > index 404acdcd0455..aaf88f85d492 100644
> > > > --- a/mm/huge_memory.c
> > > > +++ b/mm/huge_memory.c
> > > > @@ -2456,6 +2456,9 @@ static void __split_huge_page(struct page *pa=
ge, struct list_head *list,
> > > >                         if (IS_ENABLED(CONFIG_SHMEM) && PageSwapBac=
ked(head))
> > > >                                 shmem_uncharge(head->mapping->host,=
 1);
> > > >                         put_page(head + i);
> > > > +               } else if (!PageAnon(page)) {
> > > > +                       __xa_store(&head->mapping->i_pages, head[i]=
.index,
> > > > +                                       head + i, 0);
> > > =

> > > Forgiving the ignorant copy'n'paste, this is required:
> > > =

> > > +               } else if (PageSwapCache(page)) {
> > > +                       swp_entry_t entry =3D { .val =3D page_private=
(head + i) };
> > > +                       __xa_store(&swap_address_space(entry)->i_page=
s,
> > > +                                  swp_offset(entry),
> > > +                                  head + i, 0);
> > >                 }
> > >         }
> > >  =

> > > The locking is definitely wrong.
> > =

> > Does it help with the problem, or it's just a possible lead?
> =

> It definitely solves the problem we encountered of the bad VM_PAGE
> leading to RCU stalls in khugepaged. The locking is definitely wrong
> though :)

I notice I'm not the only one to have bisected a swap related VM_PAGE_BUG
to this patch. Do we have a real fix I can put through our CI to confirm
the issue is resolved before 5.2?
-Chris

