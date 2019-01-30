Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2850C282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 11:01:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8784420882
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 11:01:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8784420882
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 233C18E0003; Wed, 30 Jan 2019 06:01:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E41C8E0001; Wed, 30 Jan 2019 06:01:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0FBC48E0003; Wed, 30 Jan 2019 06:01:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id CF3C28E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 06:01:13 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id r16so16073788pgr.15
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 03:01:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=/YZHVnD1s4dRizvZoaDmD6mS+GN1ty0I6hP131I6+io=;
        b=dcB+6piNSfS1u4Yo2DVJs3z5VvQkPm2KukqImDX1mX7fHhON8ZbHFtx79pvK9RX20j
         FAtIxUVCxOeDMzdZ6WP0wZgtu8MQFelcEIenesoCHSmO33IHh/dQy1g4uc19TMGoSC7R
         kFD/8VMwCrimgYIFTuNP1FOji978Srn0AmdOHzhlno5rx4dTt3I1YgoHz0pefmIsTmuq
         xApX9s23EE5YhBLn0XCFpLzJnnU46hB8ogbbO6bUJkkCnaKIQ5pTf9n4H05y5p1w4D8+
         9aAZBmZPiHfM5Sgl4p0rDETf/chwVfYYiB9FhrkBzU2ayJb8f+gxPW30zZADoou7jWtR
         Rwsg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: AJcUukc12Fs79KT9+bbXZ7j2lSCQXhO48f8L1NcnyLe+L1h1aTsBcMU1
	XvlYgq8xADQfdyD8XBtvXgs+aHk0FyMPkKssVAcciVBrgAD9gS3VjpTzfUPAG3RxXuisBbqZtNK
	7vwj6UHRsjdgVKNz6bRBpDxGRNpgSUpQpBU6wUKsmHxHYS099jJLOmyjP0YgX48k=
X-Received: by 2002:a17:902:24a2:: with SMTP id w31mr29306030pla.216.1548846073520;
        Wed, 30 Jan 2019 03:01:13 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7/JnXV3PLRoH+4ianAzStVwomtKxAYkK0/JPM2dGqz7V1DRTgfZdo+6p/bQDGC+jS5hTdh
X-Received: by 2002:a17:902:24a2:: with SMTP id w31mr29305981pla.216.1548846072893;
        Wed, 30 Jan 2019 03:01:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548846072; cv=none;
        d=google.com; s=arc-20160816;
        b=xKp/12MuXS2UiQHDQZ4UAylyhXDHmbSCikeFw4vvx7WSGi+tG5mDK2v6hZrv8gFDXi
         RFpcp4231UyfqNTrIFByHXqkwenxUk7FUGn/X4MxawpeTzRQUC6bSLrD2I9EAv0BBeaq
         mUOGvAfQT1wJb40GLkYbz+RWx3O/EWw73y9nqo3yh9bMyegGtsrUIeq6p6wiSJDRQz8O
         6h7In/1sgW0XOGgZWwTMFoX5yCV61I6cTokoTx/0Cda+tf6tm0S2JUzNCDLkt0ZPyuhq
         cE/izxT7rRa9mJfOJ2pdFO3+SQ9a/SDI5zr7YVnwxXYzdr7f3pYE7M4zpthBJ9m8TfUA
         NExg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=/YZHVnD1s4dRizvZoaDmD6mS+GN1ty0I6hP131I6+io=;
        b=BBs8iHVGiJ9Gs6Cy6Y5so+dsRWfp36NIHXYZ7jIDFjwiKImJ005aGN4QGUtMzIfhle
         kBA8S9x62odOGV+JIH5vsorSPSuXoKFlMsY1e2w+t2vIGnFJghNgJYiSqibcUnXciTNE
         AmTWtHHXo3fD8L8QJ6RxWzrLPgLgMW4g35qN3ZH8uMG+eHbQwG4EnigZsilSq3mV2k4y
         KtV9Wt/XbFdr5D4hioFN12Ftb73aEfU8iAHFg0YEtozqMbfzZ6FDPJAWrQiQE5sKhuAc
         CL5/PfzdpOzoqo6r7BdUPYSPv+vkEBR5eS0XK6/OTnjifV5xobmdgw8aOvV9pOZS0liC
         dmSA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id ay4si1263558plb.235.2019.01.30.03.01.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 Jan 2019 03:01:12 -0800 (PST)
Received-SPF: neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by ozlabs.org (Postfix) with ESMTPSA id 43qL5L2Sryz9s3q;
	Wed, 30 Jan 2019 22:01:10 +1100 (AEDT)
From: Michael Ellerman <mpe@ellerman.id.au>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, npiggin@gmail.com, benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org, x86@kernel.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: Re: [PATCH V5 5/5] arch/powerpc/mm/hugetlb: NestMMU workaround for hugetlb mprotect RW upgrade
In-Reply-To: <20190116085035.29729-6-aneesh.kumar@linux.ibm.com>
References: <20190116085035.29729-1-aneesh.kumar@linux.ibm.com> <20190116085035.29729-6-aneesh.kumar@linux.ibm.com>
Date: Wed, 30 Jan 2019 22:01:09 +1100
Message-ID: <878sz2quiy.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> writes:

> NestMMU requires us to mark the pte invalid and flush the tlb when we do a
> RW upgrade of pte. We fixed a variant of this in the fault path in commit
> Fixes: bd5050e38aec ("powerpc/mm/radix: Change pte relax sequence to handle nest MMU hang")

Odd "Fixes:" again.

> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> ---
>  arch/powerpc/include/asm/book3s/64/hugetlb.h | 12 ++++++++++
>  arch/powerpc/mm/hugetlbpage-hash64.c         | 25 ++++++++++++++++++++
>  arch/powerpc/mm/hugetlbpage-radix.c          | 17 +++++++++++++
>  3 files changed, 54 insertions(+)

Same comment about inlining.

But otherwise looks good.

Reviewed-by: Michael Ellerman <mpe@ellerman.id.au>

cheers

