Return-Path: <SRS0=rpDk=UV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 142EAC43613
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 09:42:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8CB4120679
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 09:42:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Ts6AebvH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8CB4120679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED2876B0003; Sat, 22 Jun 2019 05:42:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E5BED8E0002; Sat, 22 Jun 2019 05:42:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D22B28E0001; Sat, 22 Jun 2019 05:42:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9ABD76B0003
	for <linux-mm@kvack.org>; Sat, 22 Jun 2019 05:42:43 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id s195so5563300pgs.13
        for <linux-mm@kvack.org>; Sat, 22 Jun 2019 02:42:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:subject:to:cc
         :references:in-reply-to:mime-version:user-agent:message-id
         :content-transfer-encoding;
        bh=9j2IX/8es+MUtSvRFN6FI7AtAfO00jHDIvuYq49EqJ4=;
        b=FY3HwzBtMpiQVFIl5FnCamUHYhhMV02tVAqXgjtlv+0LY7QFxYqH7T6ssvroh+7t2r
         s4jatYgkIPlEuTqCPKBSImgFlgj4wg2v5/+5kgZ2aPME+B+MGODwYAM22gnQw06WeraV
         GbTjcdQaNMmT43aEZwRZwuDETYIV/aggps6ymXyufWq3VJ3cqh7gqhF9nig5oGDo9ldO
         eJmOc/+KH6qbgG4/nKJHlkVvMc1IGd/KE9RfnozOv70S7L7ZeUwiQbhnr5T4r4e/qPxb
         4cs/sQjxCSAY/eF4y2FzwwdgTQT24VwqJQg0Z9VYtuW06Oco/hasxYL58Ddt/9Csdf2A
         K2eA==
X-Gm-Message-State: APjAAAUDzk8CE/UOqAK/9MCEVrgSz7JAPwnWsZKzZCf3b3N7CsfsYKUs
	Z1i9mqHVzpAruANRPWCwN/kd0j8nFzrLXCmtwdLG8G8+ZFyn9CvNulyjdDyzxaxT9xLG4PaOtnw
	Xrb1GNdgjzRmNoZGdApG5cfTKmf+hpIQusyiUcXEDD9G8pm5naOqxV8cErDSPq7S+rA==
X-Received: by 2002:a63:e304:: with SMTP id f4mr22519260pgh.187.1561196562957;
        Sat, 22 Jun 2019 02:42:42 -0700 (PDT)
X-Received: by 2002:a63:e304:: with SMTP id f4mr22519198pgh.187.1561196561915;
        Sat, 22 Jun 2019 02:42:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561196561; cv=none;
        d=google.com; s=arc-20160816;
        b=1DlpCrWNzfh/UIls3xnqa/o0AlJC3RDepKe6zIxN/UFFp2zzhf1q88USkc4wYPj1PX
         /4j1y8ZXB9Uz1JZc4eNmiomaZaSQW4P0zxPBYG0kV2Kx0FiAMHhOQaOaTnhvopYw2Ab1
         N2i/deDgO1SSov7QF3+gxnMO9gCw/f+O89hgPAX+ulKAEsDPOsEhYqQVxcmpntZSfUgq
         g1L2Net+mNDBw5qD4B5oMQNAGd6pi15ZuzINvKfKEOzQImCyHZ5WVnJUwn2VA83SyNPk
         PwIVUdxvpi73VzY3mTRcuD5uRSQivsMZ5bP/mukMdMAsLb//7kOcOF2sbWpwuxvjv0TD
         b27A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:message-id:user-agent:mime-version
         :in-reply-to:references:cc:to:subject:from:date:dkim-signature;
        bh=9j2IX/8es+MUtSvRFN6FI7AtAfO00jHDIvuYq49EqJ4=;
        b=QWEKPb08OeNtJOaF9GTf6/HsjjbsRfGck27ngmm23dW4SxfhBm0Ap8QAsZlkqJeGBT
         ZyXvOV4+jYRDHUcziiRUZeeNFFbfzjfIcWulepoTAeZfwnWbTOzbI5thNRS4Ui2/EbxD
         cJ7svmOjXGl5yxvXQ1OOfsf2LCdH1WLvYrFOFUFLKgZwPKr47GuqWa7ksR7wJNBq+GQP
         ewh+J9ybhKOGy1Nk7suvRQKCm5DdbD4yMNAcS66FZi97s3Ofwgk9Id47LOkVTUCfWoYC
         zGnC+/dLstABPqRxsf2Od8xdAmclLWYvsUula5iLvUgNv/TrN7bont2UXWBAJ+tpWH1o
         5Xuw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Ts6AebvH;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s7sor6289709plq.42.2019.06.22.02.42.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 22 Jun 2019 02:42:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Ts6AebvH;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:subject:to:cc:references:in-reply-to:mime-version
         :user-agent:message-id:content-transfer-encoding;
        bh=9j2IX/8es+MUtSvRFN6FI7AtAfO00jHDIvuYq49EqJ4=;
        b=Ts6AebvHzxuEt7R7gbjgIxoo4iHiicCl3sDn4pN1BZckM0bNb7iQ8db/Rnc5ojI7xK
         Am+VjjmHYsPZbH04bvBDUkevdmvWbmB55qd4JuzFg+Q8g6DWFXiBeRG0YJ8kfK47u1E5
         gCDQyJUhaIPouxgkcfbIzWNh/6fXNX8kqLTqqOF70gPYZfR7sxojn2F2JJpeBIZ+HhWj
         O2dcWwu/QL4xRGvJnSU2bUZjB/JjJXmLYQ7IdYz5WMBhHxfGJeJpBjwg6QhLDy06qTKq
         uDtBFAh4z95tU/HD9nzcWJKhKIH5rtr/zdiK2fZahh/MeJc3voiawu/7zXQTk8tI0Dgv
         QQ9Q==
X-Google-Smtp-Source: APXvYqxQoSAjvHvNNS187noku0m+vdYzBFRilcXKyC8mBY29vB2ASuYueJN/FrkjmvvwxZV72kH54g==
X-Received: by 2002:a17:902:5ac4:: with SMTP id g4mr60474836plm.80.1561196561489;
        Sat, 22 Jun 2019 02:42:41 -0700 (PDT)
Received: from localhost ([1.144.215.73])
        by smtp.gmail.com with ESMTPSA id u5sm4782194pgp.19.2019.06.22.02.42.39
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sat, 22 Jun 2019 02:42:40 -0700 (PDT)
Date: Sat, 22 Jun 2019 19:42:16 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 1/4] mm: Move ioremap page table mapping function to mm/
To: Christophe Leroy <christophe.leroy@c-s.fr>, linux-mm@kvack.org
Cc: linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org
References: <20190610043838.27916-1-npiggin@gmail.com>
	<86991f76-2101-8087-37db-d939d5d744fa@c-s.fr>
	<1560915576.aqf69c3nf8.astroid@bobo.none>
	<7218a243-0d9c-ad90-d409-87663893799e@c-s.fr>
In-Reply-To: <7218a243-0d9c-ad90-d409-87663893799e@c-s.fr>
MIME-Version: 1.0
User-Agent: astroid/0.14.0 (https://github.com/astroidmail/astroid)
Message-Id: <1561196381.zbgk3puxhu.astroid@bobo.none>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Christophe Leroy's on June 19, 2019 11:18 pm:
>=20
>=20
> Le 19/06/2019 =C3=A0 05:43, Nicholas Piggin a =C3=A9crit=C2=A0:
>> Christophe Leroy's on June 11, 2019 3:24 pm:
>>>
>>>
>>> Le 10/06/2019 =C3=A0 06:38, Nicholas Piggin a =C3=A9crit=C2=A0:
>=20
> [snip]
>=20
>>>> diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
>>>> index 51e131245379..812bea5866d6 100644
>>>> --- a/include/linux/vmalloc.h
>>>> +++ b/include/linux/vmalloc.h
>>>> @@ -147,6 +147,9 @@ extern struct vm_struct *find_vm_area(const void *=
addr);
>>>>    extern int map_vm_area(struct vm_struct *area, pgprot_t prot,
>>>>    			struct page **pages);
>>>>    #ifdef CONFIG_MMU
>>>> +extern int vmap_range(unsigned long addr,
>>>> +		       unsigned long end, phys_addr_t phys_addr, pgprot_t prot,
>>>> +		       unsigned int max_page_shift);
>>>
>>> Drop extern keyword here.
>>=20
>> I don't know if I was going crazy but at one point I was getting
>> duplicate symbol errors that were fixed by adding extern somewhere.
>=20
> probably not on a function name ...

I know it sounds crazy :P

>>> As checkpatch tells you, 'CHECK:AVOID_EXTERNS: extern prototypes should
>>> be avoided in .h files'
>>=20
>> I prefer to follow existing style in surrounding code at the expense
>> of some checkpatch warnings. If somebody later wants to "fix" it
>> that's fine.
>=20
> I don't think that's fine to 'fix' later things that could be done right=20
> from the begining. 'Cosmetic only' fixes never happen because they are a=20
> nightmare for backports, and a shame for 'git blame'.
>=20
> In some patches, you add cleanups to make the code look nicer, and here=20
> you have the opportunity to make the code nice from the begining and you=20
> prefer repeating the errors done in the past ? You're surprising me.

Well I never claimed to be consistent. I actually don't mind the
extern keyword so it's probably just my personal preference that
makes me notice something nearby. I have dropped those "cleanup"
changes though, so there.

Thanks,
Nick
=

