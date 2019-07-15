Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E423C7618F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 19:57:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 403B820659
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 19:57:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="uV4cZMJq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 403B820659
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA75D6B0006; Mon, 15 Jul 2019 15:57:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B31496B0007; Mon, 15 Jul 2019 15:57:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D1AE6B0008; Mon, 15 Jul 2019 15:57:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7AED66B0006
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 15:57:15 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id f22so20851499ioh.22
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 12:57:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=7Sug0O9NXLo3GeKUfp2V2/QUpa/FJDN6PQvg6dxEhGs=;
        b=OuEYIP3A/G6J87sg4NpGtmnZwPEzrLEsbDFJTs/Wzyht+VBXcl63wKpvlYIoY5TjQy
         w6n7oByBaWuITVoBweC2PPnOm8yOmy11Y+QUEptvtABMjsCKEM8PesjdTrYQvW3tHyMQ
         WFza4DZ9AzoMgEUS0+bxmBvKGDEEqnRMLy8fP7NMltOOGPY8WeW2aK0zUw3sYnoKWMCb
         vNqGsqNrW0V7a73coLP8KJAbzfdLgQD+l+A3oWC6/HFmMwNkWD8FjuOII5czTXUQIqCf
         dE7TNEmB0J2sL0RKW4Vjv4cduBz+ub8Jil360QCQLFX2b84IL62HDs5m2SBIEMPjlFU0
         w9Og==
X-Gm-Message-State: APjAAAXRTZJGO4Qsg7H/rKVnmJ2DWEDlqyHZA7x5ZcSYd2xx/xRe2PhI
	/wjLwGDiC0uiGsK6WqhP2f4avbcL/qtZm203XV6rWjYBQswnVHYXqRrPE19Czvf4Me+CjqoLn/z
	4wbh1raUbl6JiW7udbyLymgSYIX9NGaKdLrHZtunrjPvaOSMcDMBlllF4Lk7jsMzR4w==
X-Received: by 2002:a5d:9613:: with SMTP id w19mr5146240iol.140.1563220635261;
        Mon, 15 Jul 2019 12:57:15 -0700 (PDT)
X-Received: by 2002:a5d:9613:: with SMTP id w19mr5146201iol.140.1563220634686;
        Mon, 15 Jul 2019 12:57:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563220634; cv=none;
        d=google.com; s=arc-20160816;
        b=SiAudxF3wDfTUdXrhMan63tRUpuXh6fNlWhwWHosIWNMSDSwXiGkZkHNq82SwL/9VW
         CRog6wmFQd0h1gV94hSCsezUdE3ic1LYtZcrUdILfxGBDabkbIRV2d1dH2f6bZM87Lnp
         jYQMRq7OrGMFrcnww/E2IvLnNgzwzyPifsM2gfN/PopOFIDn/W4O9M+wtNf95LW0XS/E
         UFQTgLwOamHRREyzRkruCglynzfsp/Izz7d/ClMYJkUecExvYI/m5as2JKYvAaUZfgLC
         I8lXLun/suBs+s2uPa2OAUfSYrZ2FTjtbVJ/hykTIKfzDXNbPjiIirBmd1GgxSCTmYAV
         e1PQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=7Sug0O9NXLo3GeKUfp2V2/QUpa/FJDN6PQvg6dxEhGs=;
        b=YcLsotKvX0y5i6UEDCUKoUk2uAkaiJnkPeJ43FPn0TgIodJDZoGPLlAs5YYQBH/lue
         WBV6mIwifc4gkfPMg330vHrkxB9bJrOJltGWSUx9bE/NGm0PmUJwS+Sbm1rZxwgYo6uq
         uIbtcOqXXBHMUtxbM66/pIm/nqhKT5+q5GDecVN0lypIiIu5WeaP7T+UTlV1ubZjIPPI
         FAd5EifSOwVL6VotYT5vrMXd8XN2ySqFQ48J4/hAM4Wu3mpM5ElrQT258mYJNm5sBPPf
         leXWGwAA/fQWtYOkk4gel529a9JoqBaP5qsWibP5+ZHwKvnChyJ+n/Q8Jr3sMB0W3V2m
         OcdA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=uV4cZMJq;
       spf=pass (google.com: domain of henryburns@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=henryburns@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m4sor12676302ioa.21.2019.07.15.12.57.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Jul 2019 12:57:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of henryburns@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=uV4cZMJq;
       spf=pass (google.com: domain of henryburns@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=henryburns@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=7Sug0O9NXLo3GeKUfp2V2/QUpa/FJDN6PQvg6dxEhGs=;
        b=uV4cZMJqpsv1MaFd6v3yIMTqWIdAaQKIAguNPDlxTnTIC7WgDs4hnszEFhEP1JcRgq
         u7tJH+guqw7uOY1t5dCh/8S+VG/+9gq/kkF+RbwCRLUZrmRac3qEWDUKafrdlxPiW6f1
         FhdLcaiZFwkGJ71CzFhmIRnms8ERdOCuXugS/njWjnffoKHD4BeD06b5Ztz+fU5Lgolu
         bu9CZCMkq5cr+8jmfMltSA1rUZi58yYyGh6AGIvt/sI9mhnpOyLRhbBqpr+R+AhoX/bi
         wzN51uAobFbcd30yeizl7wg/YGK5C+TZfHTL1Eeyz52E0RslOBCTc4xNlWoY+LhNBU8H
         mbXQ==
X-Google-Smtp-Source: APXvYqzZADsGOhVi7AHwT2K+8hlL6ssob5cdzmenN7tFOoPtlCcmVYEuQy1e0zQ4Nv38lWLqJn1TbaM5rOCF3jHTB8g=
X-Received: by 2002:a5e:9b05:: with SMTP id j5mr27098490iok.75.1563220634269;
 Mon, 15 Jul 2019 12:57:14 -0700 (PDT)
MIME-Version: 1.0
References: <20190715164705.220693-1-henryburns@google.com> <CAMJBoFMS2BiCdBFBEGE_p5fovDphGqjDjaBYnfGFWhNvCnAvdQ@mail.gmail.com>
In-Reply-To: <CAMJBoFMS2BiCdBFBEGE_p5fovDphGqjDjaBYnfGFWhNvCnAvdQ@mail.gmail.com>
From: Henry Burns <henryburns@google.com>
Date: Mon, 15 Jul 2019 12:56:38 -0700
Message-ID: <CAGQXPTh-Z664T3Uxak-CiRn6Mc-s=esRzURLpwQaN+v0RgxFyg@mail.gmail.com>
Subject: Re: [PATCH] mm/z3fold.c: Reinitialize zhdr structs after migration
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vitaly Vul <vitaly.vul@sony.com>, 
	Shakeel Butt <shakeelb@google.com>, Jonathan Adams <jwadams@google.com>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

>>
>> z3fold_page_migration() calls memcpy(new_zhdr, zhdr, PAGE_SIZE).
>> However, zhdr contains fields that can't be directly coppied over (ex:
>> list_head, a circular linked list). We only need to initialize the
>> linked lists in new_zhdr, as z3fold_isolate_page() already ensures
>> that these lists are empty.
>>
>> Additionally it is possible that zhdr->work has been placed in a
>> workqueue. In this case we shouldn't migrate the page, as zhdr->work
>> references zhdr as opposed to new_zhdr.
>>
>> Fixes: bba4c5f96ce4 ("mm/z3fold.c: support page migration")
>> Signed-off-by: Henry Burns <henryburns@google.com>
>> ---
>>  mm/z3fold.c | 10 ++++++++++
>>  1 file changed, 10 insertions(+)
>>
>> diff --git a/mm/z3fold.c b/mm/z3fold.c
>> index 42ef9955117c..9da471bcab93 100644
>> --- a/mm/z3fold.c
>> +++ b/mm/z3fold.c
>> @@ -1352,12 +1352,22 @@ static int z3fold_page_migrate(struct address_space *mapping, struct page *newpa
>>                 z3fold_page_unlock(zhdr);
>>                 return -EBUSY;
>>         }
>> +       if (work_pending(&zhdr->work)) {
>> +               z3fold_page_unlock(zhdr);
>> +               return -EAGAIN;
>> +       }
>>         new_zhdr = page_address(newpage);
>>         memcpy(new_zhdr, zhdr, PAGE_SIZE);
>>         newpage->private = page->private;
>>         page->private = 0;
>>         z3fold_page_unlock(zhdr);
>>         spin_lock_init(&new_zhdr->page_lock);
>> +       INIT_WORK(&new_zhdr->work, compact_page_work);
>> +       /*
>> +        * z3fold_page_isolate() ensures that this list is empty, so we only
>> +        * have to reinitialize it.
>> +        */
>
>
> On the nitpicking side, we seem to have ensured that directly in migrate :) Looks OK to me otherwise.
Ok, I see it happens in the call to do_compact_page(). Got it, new
patch coming out now.

>
> ~Vitaly
>
>> +       INIT_LIST_HEAD(&new_zhdr->buddy);
>>         new_mapping = page_mapping(page);
>>         __ClearPageMovable(page);
>>         ClearPagePrivate(page);
>> --
>> 2.22.0.510.g264f2c817a-goog
>>

