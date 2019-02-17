Return-Path: <SRS0=1HZa=QY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 059BFC4360F
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 08:34:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C026A2075C
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 08:34:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C026A2075C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 54CD98E0002; Sun, 17 Feb 2019 03:34:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4FABE8E0001; Sun, 17 Feb 2019 03:34:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C2588E0002; Sun, 17 Feb 2019 03:34:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id EC0088E0001
	for <linux-mm@kvack.org>; Sun, 17 Feb 2019 03:34:25 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id 74so11166047pfk.12
        for <linux-mm@kvack.org>; Sun, 17 Feb 2019 00:34:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=Ax/C4dY4nibXkkJ5j1WnGEtke5WKlWdBaSMy/y6AMLA=;
        b=CD1m/6SE75x1DstQC01y/9xpGQH3jt4UF/vnGqcpZJZ3fJSPYemdg4pTE7GmBrKTw7
         P3bjQUzCsxkuTuXNb//SVffNS1BO9ShN4lfojuYezA3ddErk3kureKl9lWfUJ3Tfl7YI
         ZWWrcCjP64pg0idTMMAiuBcQvO5QKAIdfmT00D10Q7d3qYH9+RyPXC9475LlkDPPNfYs
         9BUqUJfj5ItljgoomwzWgFccopWnBRONzTrznuf9MmuQ9FCJxY8qY51d+smJga88wG68
         HzewfEMGvds6r7Uuyv8S3xSFf9FlXscEV7AhR+Fj6wkHZdV0VII4FZ0+DNMAK3fQTMNZ
         tNYQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: AHQUAuafpH4KoJTpPJdTxhihTqCSgpHPo0crdqjx6EgPrmQJD/vnxoTz
	mbRFrdMsP8r+moQnomv1kJN2282n3BPapBhWwYkMtEjKgBJndzyD4OZcaHtzy2yIL1QgpifQk5y
	vLebcFvHhYqLkpoV9POBYOIjUcVN6FzpVljP6FLOc+hogOPbKFt5X1eiEdvA2YXE=
X-Received: by 2002:a62:931a:: with SMTP id b26mr18971405pfe.65.1550392465643;
        Sun, 17 Feb 2019 00:34:25 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZFaJXQCmaRCKhJo91+5z9IrXmH2/48uUH/T4TQ84q3gp6H0WXq2R//QBrrdCUN3i8/EM2Q
X-Received: by 2002:a62:931a:: with SMTP id b26mr18971332pfe.65.1550392464460;
        Sun, 17 Feb 2019 00:34:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550392464; cv=none;
        d=google.com; s=arc-20160816;
        b=IwfZap18y7QKEpAVjXSqUOVW5AmNyC10UtfsGjE3YnxaR67EMWj3ntG/UBD6ewcPjR
         EvhMfnezJ3rfeXCX7eP3kiLdhOWCYs5qa7kwxSDDQYFq/ZYZaOPteMt9qrQRRAywG6GX
         CRdf9nT4/QlOuK98NkbgECJLqT6MBfZKv1qMfFE9sR/mOEkjRApKzhLjDLVg1DtwhoNr
         WQWkD0BteSHLCb48OJ6y5ueCG5mzq47ZnbkDtTWCdqk14btbsUZBs2Tus+LUIOVIP8xS
         yU0O97HRkiGt7nNyL+31SY2/Lq9aqRDJoJn5/Wipcu5vYgxi6/58I16e/JW3PkcZH32u
         Cneg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=Ax/C4dY4nibXkkJ5j1WnGEtke5WKlWdBaSMy/y6AMLA=;
        b=WELWZHQvCwa35GRYgdNqp6ZrEQZOkTiqt5mHd8x2DxXTcGo9B5Xeg6d1qV9AZCqfLc
         d9/DHeVkMnDq7OGHJqFba/Gf7kMbdrS1gJFbFpZgC1hrkO5Ks0RybkiPA73V13YRZQk+
         FgALpzKUrQrDJbOokaUdQUiIH6iUswf+6puAyGl8MdjMxwL/eVmLy6u+gghGpyqOPMlp
         WmnQsLXgBwI7bmGIlh3oXBs2I1ZC4tncUK4PMJcHULrIGsC7U6TLSnlO+X+LchTEFfTF
         IYLGeq6TZhsT2piF9mmVI5bXY2Zr9oKMxuQCepi/snHYvi3uhtTbSPPd2o/6LT72eVBq
         Yofw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id l8si9704295pgm.250.2019.02.17.00.34.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 17 Feb 2019 00:34:24 -0800 (PST)
Received-SPF: neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by ozlabs.org (Postfix) with ESMTPSA id 442Kzd1w66z9sDX;
	Sun, 17 Feb 2019 19:34:21 +1100 (AEDT)
From: Michael Ellerman <mpe@ellerman.id.au>
To: Balbir Singh <bsingharora@gmail.com>, Segher Boessenkool <segher@kernel.crashing.org>
Cc: erhard_f@mailbox.org, jack@suse.cz, linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, aneesh.kumar@linux.vnet.ibm.com
Subject: Re: [PATCH] powerpc/64s: Fix possible corruption on big endian due to pgd/pud_present()
In-Reply-To: <20190217062333.GC31125@350D>
References: <20190214062339.7139-1-mpe@ellerman.id.au> <20190216105511.GA31125@350D> <20190216142206.GE14180@gate.crashing.org> <20190217062333.GC31125@350D>
Date: Sun, 17 Feb 2019 19:34:20 +1100
Message-ID: <87ef86dd9v.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Balbir Singh <bsingharora@gmail.com> writes:
> On Sat, Feb 16, 2019 at 08:22:12AM -0600, Segher Boessenkool wrote:
>> Hi all,
>> 
>> On Sat, Feb 16, 2019 at 09:55:11PM +1100, Balbir Singh wrote:
>> > On Thu, Feb 14, 2019 at 05:23:39PM +1100, Michael Ellerman wrote:
>> > > In v4.20 we changed our pgd/pud_present() to check for _PAGE_PRESENT
>> > > rather than just checking that the value is non-zero, e.g.:
>> > > 
>> > >   static inline int pgd_present(pgd_t pgd)
>> > >   {
>> > >  -       return !pgd_none(pgd);
>> > >  +       return (pgd_raw(pgd) & cpu_to_be64(_PAGE_PRESENT));
>> > >   }
>> > > 
>> > > Unfortunately this is broken on big endian, as the result of the
>> > > bitwise && is truncated to int, which is always zero because
>> 
>> (Bitwise "&" of course).
>> 
>> > Not sure why that should happen, why is the result an int? What
>> > causes the casting of pgd_t & be64 to be truncated to an int.
>> 
>> Yes, it's not obvious as written...  It's simply that the return type of
>> pgd_present is int.  So it is truncated _after_ the bitwise and.
>>
>
> Thanks, I am surprised the compiler does not complain about the truncation
> of bits. I wonder if we are missing -Wconversion

Good luck with that :)

What I should start doing is building with it enabled and then comparing
the output before and after commits to make sure we're not introducing
new cases.

cheers

