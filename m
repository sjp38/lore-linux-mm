Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D5F4C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 03:48:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 540F520B1F
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 03:48:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tC1fzbkL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 540F520B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F3EDD6B0006; Tue, 18 Jun 2019 23:48:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF0618E0002; Tue, 18 Jun 2019 23:48:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DDEE98E0001; Tue, 18 Jun 2019 23:48:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id A4EC26B0006
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:48:26 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 30so11361846pgk.16
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 20:48:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:subject:to:cc
         :references:in-reply-to:mime-version:user-agent:message-id
         :content-transfer-encoding;
        bh=X6XTYsovFVueps9eDYXkESbdVwlOJdDMq7uOuCJqwXc=;
        b=iHYnPI0lR1uhZU3YJ0NLwPiWfx89G9TCXH8W/dUbQcps+R4/2VdelwKJRorQZ7dsXD
         2XG5i3rDrKjW9rpX/8hIyyUi4Ks5RHT3nxWvUSAEN0pxR21u6T0rS69bntoJlOcdEcFz
         FqohkvRHrDTip+GnKrjg6iDGwakEhRqSwlVhQZ0omUrUBh+jQS0IuZm2XVb7/nLD38xC
         KnSCkS9/4QoWQYlSEqHmFzSsSE8ecH3wtUM7BFcMrUizsIfaasz2jzgtzaL/TxtRcc/x
         DPBKMUi3Ev8gNFlTUHZkakFext8flfxU82a6wo1q7DAh7NlDeobOL+u+VS5ehJspp0S3
         dYEg==
X-Gm-Message-State: APjAAAVe/tu8gmTzazpveMHevxeNyzD6FhmgXm8ERGVDsrBpOjDFsafp
	x5tILsCy6b0iWJtCIDPRiOooT5AAoVEV2KChPkXX4t0AdZBzW+oUdZW1KhgBgWPBAy/4AUp6zLK
	r9xXl9rot0F++zROWW3QkjqrdPlGXHw2A/uGFhUKRTVM3z/U3jD6gsmRQjAUe4HRhhA==
X-Received: by 2002:a17:90a:9a83:: with SMTP id e3mr8644252pjp.105.1560916106226;
        Tue, 18 Jun 2019 20:48:26 -0700 (PDT)
X-Received: by 2002:a17:90a:9a83:: with SMTP id e3mr8644221pjp.105.1560916105553;
        Tue, 18 Jun 2019 20:48:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560916105; cv=none;
        d=google.com; s=arc-20160816;
        b=Lb014Q5fX/5xKfK393rE0jWu5DLtA6B9K+vYWhlZHSySIu+ckx1Oy8ohd3LK+CJFze
         4FVNJwkLU2m1rRMhPtBXyWaKbtjUOfKMO+wbjXU2pP9I3guUSj1m9uQ1teJI1Ofz8lXo
         3fKbNVrVxckISUcfK2BKCM7P6jRAPuAo++nCToFT9rRdTQKCujQuqGI7CDNvc+QbvcvI
         JUjo91wFWvHLgqSAVZj9wMipuChawLzKRflvVpldVXzE67/Xzt5Lw/CHaq+vWG6e7E8L
         DweGaLDDOqPDCWYpoiB4wNugDL2tWclIGNo8Xouh58assqQLmPVsOU1sxozn0221T2PU
         HfvA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:message-id:user-agent:mime-version
         :in-reply-to:references:cc:to:subject:from:date:dkim-signature;
        bh=X6XTYsovFVueps9eDYXkESbdVwlOJdDMq7uOuCJqwXc=;
        b=m2oNCqnYSlmiWppWucuq0wc2+3ddIbcsXRzwbkFJ1N7jSmVCPqf04BbZ1oWO2tGeED
         /XP6C3NxhvctLFpi6bv2VCNplrv1pCTZ620LXn2k/uWx3IniICNApb24lv2H9hZ0gFtJ
         CcXY9Lvmx3p5M/AaeVCKxgPDMmb14JJ7leP/YfsFCD1AM5Oy7VPK37MhqcvtE/1C0KEe
         A9ByW0GCiZK8AysWo15kMu1H4yzglcEF4nzJJ7qk9k6y2p3BYTBH4LyBgCnFgaNekRQO
         6DzvvgXvfEd7rb8/pQxpFni4Y9rAp/1j/Tt4RuPz/a7dcp7W5zRSE1Mo4TbRekLOI8Vo
         yNHg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tC1fzbkL;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v13sor15142568pgr.24.2019.06.18.20.48.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Jun 2019 20:48:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tC1fzbkL;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:subject:to:cc:references:in-reply-to:mime-version
         :user-agent:message-id:content-transfer-encoding;
        bh=X6XTYsovFVueps9eDYXkESbdVwlOJdDMq7uOuCJqwXc=;
        b=tC1fzbkLO4VEb2uG5tpdzpdcGioSEyum/AxMt7rl3u+3W+pwVWz0ir6DqBvt7Sx/pi
         1WlaAg652y+gLKabGhhaJdZC5Xkwvz6PbaHrbWWyz/xljVyoCpISGt95eX7YZTobS1J6
         hwD6aFs6efu0dM1kesEHSloRI9DM5Ny9A+zFW3syvgakwqh6mAX9NzBVCLWSYe6nHfv3
         3xrcez+XQj8IXjVXr74e0U1ufVVsSBKn0K8lBSZjsUxEHztCH5pfIEbRUm8GFCDuTKes
         ZnxHyzQ92i2RQOPqavK4WLESBq1uTY1GCjHjaQDK682QCK2m2V311Qtx8nHh8LNJW9VG
         0PBQ==
X-Google-Smtp-Source: APXvYqxdJiQO254qpFiGA9nxIIwq5CyEWTUc2NnUWtayrZavFfK006a2p6VEwiUzEdlEmOggvyLlnA==
X-Received: by 2002:a63:2b57:: with SMTP id r84mr378763pgr.282.1560916105203;
        Tue, 18 Jun 2019 20:48:25 -0700 (PDT)
Received: from localhost (193-116-92-108.tpgi.com.au. [193.116.92.108])
        by smtp.gmail.com with ESMTPSA id s15sm20952137pfd.183.2019.06.18.20.48.23
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 18 Jun 2019 20:48:24 -0700 (PDT)
Date: Wed, 19 Jun 2019 13:43:19 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 1/4] mm: Move ioremap page table mapping function to mm/
To: Christophe Leroy <christophe.leroy@c-s.fr>, linux-mm@kvack.org
Cc: linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org
References: <20190610043838.27916-1-npiggin@gmail.com>
	<86991f76-2101-8087-37db-d939d5d744fa@c-s.fr>
In-Reply-To: <86991f76-2101-8087-37db-d939d5d744fa@c-s.fr>
MIME-Version: 1.0
User-Agent: astroid/0.14.0 (https://github.com/astroidmail/astroid)
Message-Id: <1560915576.aqf69c3nf8.astroid@bobo.none>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Christophe Leroy's on June 11, 2019 3:24 pm:
>=20
>=20
> Le 10/06/2019 =C3=A0 06:38, Nicholas Piggin a =C3=A9crit=C2=A0:
>> ioremap_page_range is a generic function to create a kernel virtual
>> mapping, move it to mm/vmalloc.c and rename it vmap_range.
>>=20
>> For clarity with this move, also:
>> - Rename vunmap_page_range (vmap_range's inverse) to vunmap_range.
>> - Rename vmap_page_range (which takes a page array) to vmap_pages.
>=20
> Maybe it would be easier to follow the change if the name change was=20
> done in another patch than the move.

I could do that.

>> Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
>> ---
>>=20
>> Fixed up the arm64 compile errors, fixed a few bugs, and tidied
>> things up a bit more.
>>=20
>> Have tested powerpc and x86 but not arm64, would appreciate a review
>> and test of the arm64 patch if possible.
>>=20
>>   include/linux/vmalloc.h |   3 +
>>   lib/ioremap.c           | 173 +++---------------------------
>>   mm/vmalloc.c            | 228 ++++++++++++++++++++++++++++++++++++----
>>   3 files changed, 229 insertions(+), 175 deletions(-)
>>=20
>> diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
>> index 51e131245379..812bea5866d6 100644
>> --- a/include/linux/vmalloc.h
>> +++ b/include/linux/vmalloc.h
>> @@ -147,6 +147,9 @@ extern struct vm_struct *find_vm_area(const void *ad=
dr);
>>   extern int map_vm_area(struct vm_struct *area, pgprot_t prot,
>>   			struct page **pages);
>>   #ifdef CONFIG_MMU
>> +extern int vmap_range(unsigned long addr,
>> +		       unsigned long end, phys_addr_t phys_addr, pgprot_t prot,
>> +		       unsigned int max_page_shift);
>=20
> Drop extern keyword here.

I don't know if I was going crazy but at one point I was getting
duplicate symbol errors that were fixed by adding extern somewhere.
Maybe sleep depravation. However...

> As checkpatch tells you, 'CHECK:AVOID_EXTERNS: extern prototypes should=20
> be avoided in .h files'

I prefer to follow existing style in surrounding code at the expense
of some checkpatch warnings. If somebody later wants to "fix" it
that's fine.

Thanks,
Nick

=

