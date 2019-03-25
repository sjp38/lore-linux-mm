Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7ED2FC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 10:40:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 08ACB207DD
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 10:40:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="OD9Xe4Qo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08ACB207DD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 541AF6B0003; Mon, 25 Mar 2019 06:40:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C8636B0005; Mon, 25 Mar 2019 06:40:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B8796B000A; Mon, 25 Mar 2019 06:40:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id CA0936B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 06:40:13 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id s7so2704384lja.16
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 03:40:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=YRU9mGLD7tBpwsbhnIUDLGmCCUiVmdLvRT8V9m+brSg=;
        b=iixF8jIVGnv9gyzNv0pL4s9Kidare/3T9ZF4qZIX7nGdgNS5kIkWd5qJT67nYE+dcR
         t6b1yYYmTg6M3deNKWq2bHvqjCQepSWH1nXQiqo2diNQiCP1zvflKoitv8xwI29hgpA9
         pwnIjFG2LL2pUf0h3cVrKVOz1p8gyl6JnP3VL0c0+YczOLFvxD4EdrlxsizWUAxH+9gC
         p4L/E4F2eX2gE2wjha922pOCBT+5jkO3isJvNsNXJEcbBiNaKcQhPUL0zbtJh+hOTtTU
         DxLokcSvvkTycq1wFnxEGB8ZtFLpXyzwBr0cFgS1q01Qgh0xTqCRFQ4tDLRQfPwY+V5x
         Y8RQ==
X-Gm-Message-State: APjAAAV6ROakM27TWD8VCXwkWaFz10o4C/9DXu5ayUkhFCvjWKH/tzB8
	eJofRFh6lchVd4UcYABLfFVzMO3djUxd3L3MOkLQ71bAAao6Eb8ixKFDT41MqQeKidtoddrTAh7
	LXhUl7lpCfPMQYfGNx+H/iZ6tgQ2gflJeFleP5Us10gd+FekCFrCJPm4uDSIt/hHpFA==
X-Received: by 2002:ac2:5381:: with SMTP id g1mr11860054lfh.130.1553510412823;
        Mon, 25 Mar 2019 03:40:12 -0700 (PDT)
X-Received: by 2002:ac2:5381:: with SMTP id g1mr11860012lfh.130.1553510411876;
        Mon, 25 Mar 2019 03:40:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553510411; cv=none;
        d=google.com; s=arc-20160816;
        b=Xwy9Ku4VKwUMHqMQq5qE+KOPOUp+u6bIFmie3F452tnnzXrXNA4U7Kt5N2JPpxj2/b
         Z8eXOY6Oy8+PnY5/8UNYp7RPR8pElLAgN4lCwBHpY5shaiaBVLSu4njSAfsKYK5oPov1
         r1q46UqrxXQ+NjHxHVT4q2XPbZSU1Q/KWYwGgi/3dpIZ8/yrTi8mwUOOaP7y1oxItNa2
         y2T3oL5PytRMbxvpq/OLTN8GabaSjdBh3cA8A19dSfvG4LcjLBGcfThiATDzu+L0gz7y
         IXKB5Dk1RazorAKg8cs3+UZ+RIh5Quc0FlKcnZLS5UCAMASjh1mxcHf+ON6un//vzX2w
         hxPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=YRU9mGLD7tBpwsbhnIUDLGmCCUiVmdLvRT8V9m+brSg=;
        b=lzSsRR9ZAp5metbCzUNvg/ENfC/y84tHg9VTwEAWQfDLAUMaDaNsPb1mtfD0/n6wIA
         InHY+FbQlIZlO1Q9zU5tIh8bS3pXCpDHRq/1dQI+lI3qzZXZFOAl/yAa8FsPg5PW1R4s
         xCYDePSN/52xjHSx/xPMU5IWjFesrZr/NA0pLACQDHkqtKoe2fxdqGaUwst59YVpeIUp
         Yjc2Jkn5V5q6i04DG+1TH3SBbDKfHXj9tOD2VlPpwvzUffGov48uT3erNEWv7Bq6YdMU
         SmjwJOi9B2yZCOBfxZQM8l5QSk8aA1fr5/B7Hlg99OVXcuBschk7vz855J5V/XyKeZXE
         lQjg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=OD9Xe4Qo;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r18sor3704979lji.31.2019.03.25.03.40.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Mar 2019 03:40:11 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=OD9Xe4Qo;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=YRU9mGLD7tBpwsbhnIUDLGmCCUiVmdLvRT8V9m+brSg=;
        b=OD9Xe4QoUkWCsNdG7yMOUXXXt67BeRgEv5p4nFEtL5lSl2v+gtkMFB6blyUBc5bs4u
         gqw185I4nYiw7goIuRt0U7rn+Mj9+Njp6DletgqdXmAzxtUch5p24IW9gG4BuhbZYFJf
         sg12G7ptunrmscrxLK46yWvaqjJGznCxrWhiwIxeLfUrE+WWH8E8QXdh6LO+zfB+f1Jm
         PlQdR3wx1BL+9Eu8xOECX38yURD01DYaDdtljg2fxYRHl9hHmJ6jUWQlLEqA/HJpRFhx
         JXaUG9Hh9YZGcfqRRUuccMQs26iawUqSEAD/uxyDyXtp0XZ/P4P1im8OXg/ZP/SP5AOV
         UAuw==
X-Google-Smtp-Source: APXvYqxP9oH0igx2yyoV0GxqC53ui9Xet6Sq2QQ0H4kq5GyMb2nDgXR8ogmu4TfqXq6jSMgA03pRzw==
X-Received: by 2002:a2e:844a:: with SMTP id u10mr1113904ljh.41.1553510411397;
        Mon, 25 Mar 2019 03:40:11 -0700 (PDT)
Received: from kshutemo-mobl1.localdomain ([178.127.192.30])
        by smtp.gmail.com with ESMTPSA id m18sm3377062ljb.35.2019.03.25.03.40.10
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 03:40:10 -0700 (PDT)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id 5A9F330123C; Mon, 25 Mar 2019 13:40:07 +0300 (+03)
Date: Mon, 25 Mar 2019 13:40:07 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mark Rutland <mark.rutland@arm.com>
Subject: Re: Fw: [Bug 202919] New: Bad page map in process syz-executor.5
 pte:9100000081 pmd:47c67067
Message-ID: <20190325104007.hyvsnv2laqkfc7sc@kshutemo-mobl1>
References: <20190320170151.2ed757a48e892ebc05922389@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190320170151.2ed757a48e892ebc05922389@linux-foundation.org>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 05:01:51PM -0700, Andrew Morton wrote:
> 
> kcov_mmap()/kcov_fault_in_area() appear to have produced a pte which
> confused _vm_normal_page().  Could someone please take a look?
> 
> 
> Begin forwarded message:
> 
> Date: Thu, 14 Mar 2019 15:06:47 +0000
> From: bugzilla-daemon@bugzilla.kernel.org
> To: akpm@linux-foundation.org
> Subject: [Bug 202919] New: Bad page map in process syz-executor.5  pte:9100000081 pmd:47c67067
> 
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=202919
> 
>             Bug ID: 202919
>            Summary: Bad page map in process syz-executor.5  pte:9100000081
>                     pmd:47c67067
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 5.0.2
>           Hardware: All
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Page Allocator
>           Assignee: akpm@linux-foundation.org
>           Reporter: zhanggen12@hotmail.com
>         Regression: No
> 
> Created attachment 281823
>   --> https://bugzilla.kernel.org/attachment.cgi?id=281823&action=edit
> bad page map
> 
> BUG: Bad page map in process syz-executor.5  pte:9100000081 pmd:47c67067
> addr:00000000768464c8 vm_flags:100400fb anon_vma:          (null)
> mapping:000000009265a729 index:18f
> file:kcov fault:          (null) mmap:kcov_mmap readpage:          (null)
> CPU: 0 PID: 30290 Comm: syz-executor.5 Not tainted 5.0.2 #1
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:77 [inline]
>  dump_stack+0xca/0x13e lib/dump_stack.c:113
>  print_bad_pte.cold.120+0x2c7/0x2f0 mm/memory.c:526
>  _vm_normal_page+0x111/0x2b0 mm/memory.c:612

Hm. This is print_bad_pte() under 'if (IS_ENABLED(CONFIG_ARCH_HAS_PTE_SPECIAL))'.
I don't see how would we get there since pte (0x9100000081) doesn't have
special flag set (0x200). 'if (likely(!pte_special(pte)))' should not
not allow us to get there.

Very strange.

-- 
 Kirill A. Shutemov

