Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4DA98C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 20:34:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D6162084D
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 20:34:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="reFt6qLk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D6162084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8048B8E0018; Mon, 25 Feb 2019 15:34:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 78D0B8E000C; Mon, 25 Feb 2019 15:34:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 62E538E0018; Mon, 25 Feb 2019 15:34:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 15A888E000C
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 15:34:48 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id t6so7844427pgp.10
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 12:34:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=FmHMOey5zYjBqir8BQ2Fm5h9ilU4HwTBdoph5KPL7ck=;
        b=c56gOuXn1Rfy1QC0pzFMWUP7Mw7cZrbjdIfPZeVnEKwkE407L8dJ2TnI6hW2HOVev5
         n9dpJ57rt5Gu31qfd7r32Gl43xFjRzSRZXhFLjKx3hfoEoRI5k3fJzGBholwopsFQczB
         Oc/vTd7pDfNQjyUQpEZXA+1pg4JoFSAK1Lo452rHhiSGrmLRbgn/HnmkTh0glJ9//EtV
         Ig9jHDbQOOckBYEQ/5lLrcOYAtWhE2lFE5jWh+vlnnE6ZsmEoxak0m2Qx9dK6igI2afC
         oe163W7VO8NpOPMUavooWl2L3LZ1s981UeaKkNNHkqWXcM4rPIJrJK912u5YLIm1fJ51
         r72A==
X-Gm-Message-State: AHQUAuaC6nXGbY5pMgYz3TpH6qaRhcvjeMNEnZNpbH5PA1mhbMQtq059
	FLjFqUeFLgYYyWBn3rR1t5aYm+iDqe+okITsuS8Tb5OeaH3c6MZ8dXTQCmjB9E0sz1hCjOx66J4
	/efS0Gt8jp0oXkUlgiIu2lRV4wVCLqRq6XB3xpgmSwpwAsqObaQjQ0tvYbPhWSpXfAsyZJ004qQ
	yBZYS0AXx4i3J9DgoNzbErpcrdgSB4H9WNQE2zKgUT6RCA4M/sXJ3TIfJlwxbLYatElCEX3HR4e
	rg1RwYqLV0A0ygqTRPn2fUQ41r8RAmDIdkzFOteDI7IZlzoFDwT6x+JCTEl6kjvWvs1ScwZomOu
	B72dQaTQcwYuYcS3LdDWVqCKudPS7DA2piNyVNHSb4AbJ7zyf9HiBq6uBmNrsxbsdjYguVQzSgw
	c
X-Received: by 2002:a63:2c0e:: with SMTP id s14mr1270217pgs.132.1551126887717;
        Mon, 25 Feb 2019 12:34:47 -0800 (PST)
X-Received: by 2002:a63:2c0e:: with SMTP id s14mr1270163pgs.132.1551126886782;
        Mon, 25 Feb 2019 12:34:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551126886; cv=none;
        d=google.com; s=arc-20160816;
        b=WFh3FRAmkeOntaCFaMNYs1DLnpw/UQmEYGZOyDMA3NNS9NeoM7D1fTtSWb548pFNye
         ket/95wjcCkwf5yuDF0oMLmC/i8l8FbtwQGufRDv15Q1O7ibBmO80eARhxM63QdqOm0/
         KbTc78YW6i06Bq8265DRIektZ2IzWA6mLLf0ZCqnWamnnTAyjF1elrSUJkpYgnDTU6Bt
         tAL17TIVDV1W0MJu7wEwEXdkNb6ATvfyPPxpa3lOPDNB9FFng/sPUN1TXxD2PaJHDtua
         +Q+xFNDtO3tOSAOzNNIWBkZJgztiJLpLeL22Fgp/RBW6jVaVYaVGnkyrUM9oBHMjsY2K
         ivKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=FmHMOey5zYjBqir8BQ2Fm5h9ilU4HwTBdoph5KPL7ck=;
        b=LXbJs3rY3tDlKu8ZGs0k/DUUJBCaYRiRn4o9Z6iihyI2LyF772jNTE20IN9KeaJyJb
         NY8VCgjnm5Db8Jokqi/YF7iJ/G6kON92Kv7vj2R5GChRtcV2d0bcBKC0anKvxTqH/XYZ
         ZpR47aeuF1mota1k8Yd8Yixq9Bn0IQ0Y/B9dHm20Qh/RQ0DRcjlInOLG1JEmN0+mgwLl
         OpuicwA30eVbREAluAmhuwDe0BR/GY89OMYOuCQWEzgH32z0C2scAeK15V0Ck1Z4sCVp
         185qplVTeed55D9fdy8aU36q+wQLE0b2rFS5OycAiq28narSgmq7Q6NAK2tWA5odyge0
         /9Eg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=reFt6qLk;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b1sor15531426pgt.72.2019.02.25.12.34.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Feb 2019 12:34:46 -0800 (PST)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=reFt6qLk;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=FmHMOey5zYjBqir8BQ2Fm5h9ilU4HwTBdoph5KPL7ck=;
        b=reFt6qLkikr9MV68tRlb6/U2JuvM9MZ/xzIst8WXo2yxanz2wdmpZf05dcf0bLx8er
         MBn4Ws5i620Rle3Zk+XgZb4UNrUa1zbCocRizS/ESBMQgucJespj897PEvYrT6HHxRt2
         xiAChdipZi7OZmIgTZ6wS5pS8jtmufH8qJKevVWtqWcmY1PJaqUNjNLzKGSuKUTmZXD0
         C6k3eKIX+OGC7OtYmWmGwpuAj2AHPc3lZSOn1mEI7+LLr2W7jS50bv5LRUMgXrU9gEiJ
         vQB35q+afCKz3T9efbDrfY90Jph3/DWI59rp4+Wg+FeOCcloJyGf6As2LPWDnHczSYYv
         9kfg==
X-Google-Smtp-Source: AHgI3IZ5cqwWWpP7deEcZ3lfdJVt2ZgT9Xp/tfF1Yd4X2yc1J58P0kYnE1LQfquVg9af5N14t/Gzog==
X-Received: by 2002:a63:d442:: with SMTP id i2mr20511933pgj.246.1551126885979;
        Mon, 25 Feb 2019 12:34:45 -0800 (PST)
Received: from [100.112.89.103] ([104.133.8.103])
        by smtp.gmail.com with ESMTPSA id m64sm25530706pfi.149.2019.02.25.12.34.44
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 25 Feb 2019 12:34:45 -0800 (PST)
Date: Mon, 25 Feb 2019 12:34:21 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Linus Torvalds <torvalds@linux-foundation.org>
cc: Hugh Dickins <hughd@google.com>, 
    "Darrick J. Wong" <darrick.wong@oracle.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Matej Kupljen <matej.kupljen@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, 
    Dan Carpenter <dan.carpenter@oracle.com>, 
    Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, 
    linux-fsdevel <linux-fsdevel@vger.kernel.org>, 
    Linux-MM <linux-mm@kvack.org>
Subject: Re: [PATCH] tmpfs: fix uninitialized return value in shmem_link
In-Reply-To: <CAHk-=wgO3MPjPpf_ARyW6zpwwPZtxXYQgMLbmj2bnbOLnR+6Cg@mail.gmail.com>
Message-ID: <alpine.LSU.2.11.1902251214220.8973@eggly.anvils>
References: <20190221222123.GC6474@magnolia> <alpine.LSU.2.11.1902222222570.1594@eggly.anvils> <CAHk-=wgO3MPjPpf_ARyW6zpwwPZtxXYQgMLbmj2bnbOLnR+6Cg@mail.gmail.com>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Feb 2019, Linus Torvalds wrote:
> On Fri, Feb 22, 2019 at 10:35 PM Hugh Dickins <hughd@google.com> wrote:
> >
> > When we made the shmem_reserve_inode call in shmem_link conditional, we
> > forgot to update the declaration for ret so that it always has a known
> > value.  Dan Carpenter pointed out this deficiency in the original patch.
> 
> Applied.

Thanks.  And I apologize for letting that slip through: Darrick sent
the patch fragment, I dressed it up, and more or less tricked him into
taking ownership of the bug, when it's I who should have been more careful.

But I'm glad it confirmed your rc8 instinct, rather than messing final :)

> 
> Side note: how come gcc didn't warn about this? Yes, we disable that
> warning for some cases because of lots of false positives, but I
> thought the *default* setup still had it.

I thought so too, and have been puzzled by it.  If I try removing the
initialization of inode from the next function, shmem_unlink(), I do
get the expected warning for that.

> 
> Is it just that the goto ends up confusing gcc enough that it never notices?

Since the goto route did have ret properly initialized, I don't see
why it might have been confusing, but what do I know...

I thought it might be because outside the goto route, ret was used
for nothing but the return value.  But that's disproved: I tried a
very silly "inode->i_flags = ret;" just after d_instantiate(),
and still no warning when ret is uninitialized.

Seems like a gcc bug? But I don't have a decent recent gcc to hand
to submit a proper report, hope someone else can shed light on it.

Hugh

