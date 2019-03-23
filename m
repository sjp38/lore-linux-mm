Return-Path: <SRS0=0AWy=R2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 142C5C43381
	for <linux-mm@archiver.kernel.org>; Sat, 23 Mar 2019 08:06:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9EAED21019
	for <linux-mm@archiver.kernel.org>; Sat, 23 Mar 2019 08:05:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9EAED21019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EED3E6B0005; Sat, 23 Mar 2019 04:05:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E4A006B0006; Sat, 23 Mar 2019 04:05:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D130A6B0007; Sat, 23 Mar 2019 04:05:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8FACE6B0005
	for <linux-mm@kvack.org>; Sat, 23 Mar 2019 04:05:58 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id m31so1864212edm.4
        for <linux-mm@kvack.org>; Sat, 23 Mar 2019 01:05:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding;
        bh=5ZyeHhk8jX7F5DZbMSHEyIXXEHxKDW+apBnMTk88T7w=;
        b=KZ4cKJ26b1Ba/k/Y57oce5f+LYueUuLt81P1NpWPJ+UrMsoFMAifxW6TekPafgKMog
         Gq0fv6rZVIJrW6quVE23aYMZMBC1Cd5IUUbInRfShTAnv0yUNrbuPDjZyZatDEB5Zaqg
         Zxvrh4ahKgLYZ5OJ7jHfRf5Yt6V6Jvul9L6on7PlQNltoP3SRitznUAhFAprFJa4zg11
         YfTWtsKa2GlvKPCfDNBsZCzyL+qhWDjbVInD5uUrpkHuIC2PTyV4ButymG2hGAuDREAQ
         guMmRiJjdvpMUvLHTodB8HtouP+2MI82n+fsp/5NeFb6wN+v/PRlbVpV9qEEopHOfR/g
         zixQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAXFfH3FalCKgODyC4hx2HBKBjFvSCwTT7Y4nbAejnJYnHr18EAG
	Xko1BZUA4C1iL2yuSB+fTqH/x7sMLtmiZrYsNr8MbOot5gTlhgpawYLDXRiV1z/cYWQ9wsnxpmx
	osh4/j6vkqTaFe4lYdSQHCD9WsMP5THiCOo7cyGQLs9lQbqvsm9Xlz+k7ROFX9r8=
X-Received: by 2002:a17:906:63ca:: with SMTP id u10mr7954970ejk.127.1553328358096;
        Sat, 23 Mar 2019 01:05:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw4pu7K5sYtFE0fsy8IaiVzgrYujdpJTc5yzfwT4QUoFm3d5sK16JpsGHa70QmjrlrmOllx
X-Received: by 2002:a17:906:63ca:: with SMTP id u10mr7954924ejk.127.1553328357128;
        Sat, 23 Mar 2019 01:05:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553328357; cv=none;
        d=google.com; s=arc-20160816;
        b=JnqXvBsXpN3QHMqwK2UCYAk0OoMWvOA4saH2tNGFiEi0NmKSJ1bzGP+MmboPuaA+4Q
         RqZAVEgNmEZE2RDH7u0fVA5OgfmLM2G27Hb+UbH2ao3BAS8VjP0xnIEKHNGsKjMCwkgP
         OieC3H9fRNj0NACvB/4ubIBT+UGzsUnsQ0gcYSljO1tyBM5374eCrA7vqixrD/BVjr9T
         LbPQwvSX6wakVpMEQHtiHfgl7VZKJpBLjioQE8nDkTUkD0IpVDUEFKyUl1lorEFb/R/P
         z6jXUWipMoT3u9xPbaFztPcudRcECXv75ftn3E29goxJ3mM9/T/3JbshV3XOYIW9ThWM
         G6UA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:references:subject:cc:to:from;
        bh=5ZyeHhk8jX7F5DZbMSHEyIXXEHxKDW+apBnMTk88T7w=;
        b=QjTYpBu56+AyMyspzdsI3v0CJxfACs+n90hqH6e6JttgbahmEwLNxBmkopx6Zvl9TL
         uzuzApb1E81bQCqIRZJDdM0Dpw2zOJ+g3mfyZccJmwXFgDqs7RD1A0db3gqanBMyVBxf
         H/1BDilM3nfwJN9qJ97r2OVWS1xmDqu2TOJni5RurqZIQub0urFyuA66sDPhaaLCXPls
         sWEMMk0ExWLSEn0s+ZfPhVfVTSS7sxDPiJkX2Hd6Bdyod6bEBIyNl0gdXjpqxo5K7AXV
         G8aMCRFL4ZM+6FDPQTx6T81Te7JWUa7HJrn6b6oQnTpDfC0QZclLLY53BJAF8k+iiX8h
         p48w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay9-d.mail.gandi.net (relay9-d.mail.gandi.net. [217.70.183.199])
        by mx.google.com with ESMTPS id a20si237115ejj.79.2019.03.23.01.05.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 23 Mar 2019 01:05:57 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.199;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from [192.168.0.11] (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay9-d.mail.gandi.net (Postfix) with ESMTPSA id 6F8B9FF808;
	Sat, 23 Mar 2019 08:05:50 +0000 (UTC)
From: Alex Ghiti <alex@ghiti.fr>
To: Christoph Hellwig <hch@infradead.org>
Cc: Russell King <linux@armlinux.org.uk>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Ralf Baechle <ralf@linux-mips.org>,
 Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
 Palmer Dabbelt <palmer@sifive.com>, Albert Ou <aou@eecs.berkeley.edu>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Luis Chamberlain <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 linux-mips@vger.kernel.org, linux-riscv@lists.infradead.org,
 linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 4/4] riscv: Make mmap allocation top-down by default
References: <20190322074225.22282-1-alex@ghiti.fr>
 <20190322074225.22282-5-alex@ghiti.fr> <20190322132246.GB18602@infradead.org>
Message-ID: <f556e3a3-c4a7-3b4b-90ad-e59686efcd7b@ghiti.fr>
Date: Sat, 23 Mar 2019 04:05:49 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190322132246.GB18602@infradead.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/22/19 9:22 AM, Christoph Hellwig wrote:
>> +config HAVE_ARCH_MMAP_RND_BITS
>> +	def_bool y
> This already is defined in arch/Kconfig, no need to duplicate it
> here, just add a select statement.
Right, I will fix that,

Thanks Christoph,

