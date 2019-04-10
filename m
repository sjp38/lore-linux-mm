Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F16CC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 07:19:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B20C217D6
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 07:19:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B20C217D6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E645F6B0269; Wed, 10 Apr 2019 03:19:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE8706B026A; Wed, 10 Apr 2019 03:19:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CB3F56B026B; Wed, 10 Apr 2019 03:19:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8EA8B6B0269
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 03:19:37 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k8so719242edl.22
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 00:19:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=DH9Dk8JPmTbXiETVk6AqcypR9Tb4gVQEyOvA24y6AGo=;
        b=fBuG16QG5bPi+W68gbSBqLm/ns7blpUV4jK5tF7UvwyQ4mgEYdtm0zwRGqo0QrINAC
         1DwSothoh5n5KiK0ORW2FtJEM1E+8wmP5STud5WdAPgJuMK5HqmpN5i7TEbCs/eI/Ees
         FAnoa+OuQuP4AhvKk/aUcGx0lAQtRRKvMeA09voJWw9b+26XY4HvVL3++UUVNkbGJch4
         FLi/pWCn9+68JbLXkbtKTkW2r+pah2ta7JF0PUb7FsdcG1BLkSHLto/LIz4yrc7R5laW
         v/tZ0URzCxCBhTWRCfhmUvRWViwTSLtOiJTlrpYCfGDps4/kJh9WLTi/jT2Fxq1OB4Q1
         YmGw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAUbqKpY3hO0SYeEMk8RSo+PJy31WNXhqQISWxmSDwsOrjxlO05P
	DXiFHxD+SAgjbhZrSAQknLKbGOT5fTF6HlWxITe44tbbZqKeHR7U5dIKGPeDhEKABHHH/RPpeil
	QeOm8EqUuJdSDG8izao3LH81xL/qUYIQNO+GTmabhQ4KuvQR0eY2WGRHjr/ziL9g=
X-Received: by 2002:a50:aa4e:: with SMTP id p14mr25879194edc.59.1554880777190;
        Wed, 10 Apr 2019 00:19:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzJCyU5ACERagt7hbt/sw821k/qagmw8ggd9AJFmHxHXnFPqS40yRtFXGkensHm7oFQxtnx
X-Received: by 2002:a50:aa4e:: with SMTP id p14mr25879167edc.59.1554880776590;
        Wed, 10 Apr 2019 00:19:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554880776; cv=none;
        d=google.com; s=arc-20160816;
        b=z5W0g1TUxbhyfG9FUYI6DPq9PNYbvrlllsePDRIh/HQIJ+fi/fR0nsa6QuNcVPY5y2
         zBLplhdLe5p8usXyoawB0VdEKHDDwdj4Nh7IGNxcPpTXUdbA7VQ2BA76h4Rp4ceHhb9G
         JYuU5S3KUAAy6g6ItNk2QLxQ1fR68OTljc0w4vrccVSRAVT7GwcwWzI3CTrR91TnKlfu
         F0hK3dnBLFE9TUo8K0+0bRkg93lBBtHoo7X95DsnA4W5SBuqI59Kd6vXiCvFy+eQoxKV
         rAm3Mb3tCCuYiY/5tjIpQR8prMWi/TLIQcBQ45Ny8BjD1TXXh8yAH272LSRId9CN5AjH
         VaaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=DH9Dk8JPmTbXiETVk6AqcypR9Tb4gVQEyOvA24y6AGo=;
        b=SbhOpw+sloEWkNOGAe/gqex6KGRkuYLk0xZ8Kwpa/EqvZ9OpH04bY4fr8UztbSd+Bt
         H07It+oWwcQWygWqbekbpO5DmLOHQ8PWu65MS+tJ1mv7YLJGYBQRQtey+f0pMrZba1Fw
         BOyQ6p9V3sGnCNK+L7jGCxlhfPE2r29nAkkgEDKbBZV+h5YN5jte8bJrmZWjD+V8kMZS
         zqNFRn/ZSOImCvwQ2sPa/2WBwlgANtZFDAGiaLv/6uqGrEtD7f24lkAUr+kikBEsJCrM
         hhwuqV7lZsONkg/b0/7zb0vwNCEgjClXZMY4+T/DwDgE4a6rT1rJRsSgbAoVAKVf6ToV
         81rQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay11.mail.gandi.net (relay11.mail.gandi.net. [217.70.178.231])
        by mx.google.com with ESMTPS id n11si105173eje.23.2019.04.10.00.19.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 10 Apr 2019 00:19:36 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.178.231;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from [10.30.1.20] (lneuilly-657-1-5-103.w81-250.abo.wanadoo.fr [81.250.144.103])
	(Authenticated sender: alex@ghiti.fr)
	by relay11.mail.gandi.net (Postfix) with ESMTPSA id 20698100009;
	Wed, 10 Apr 2019 07:19:30 +0000 (UTC)
Subject: Re: [PATCH v2 5/5] riscv: Make mmap allocation top-down by default
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Albert Ou <aou@eecs.berkeley.edu>, Kees Cook <keescook@chromium.org>,
 Catalin Marinas <catalin.marinas@arm.com>, Palmer Dabbelt
 <palmer@sifive.com>, Will Deacon <will.deacon@arm.com>,
 Russell King <linux@armlinux.org.uk>, Ralf Baechle <ralf@linux-mips.org>,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Paul Burton <paul.burton@mips.com>, Alexander Viro
 <viro@zeniv.linux.org.uk>, James Hogan <jhogan@kernel.org>,
 linux-fsdevel@vger.kernel.org, linux-riscv@lists.infradead.org,
 linux-mips@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 Luis Chamberlain <mcgrof@kernel.org>
References: <20190404055128.24330-1-alex@ghiti.fr>
 <20190404055128.24330-6-alex@ghiti.fr> <20190410065928.GD2942@infradead.org>
From: Alexandre Ghiti <alex@ghiti.fr>
Message-ID: <978d383e-a120-9963-626e-2395178356c1@ghiti.fr>
Date: Wed, 10 Apr 2019 09:18:37 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.5.2
MIME-Version: 1.0
In-Reply-To: <20190410065928.GD2942@infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: fr
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 04/10/2019 08:59 AM, Christoph Hellwig wrote:
> Looks good,
>
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Thanks Christoph,

Alex

