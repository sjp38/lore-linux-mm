Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF3FCC282CE
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 19:53:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 83C6A2075A
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 19:53:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 83C6A2075A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 30AED6B0269; Mon, 22 Apr 2019 15:53:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E1656B026B; Mon, 22 Apr 2019 15:53:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D2716B026C; Mon, 22 Apr 2019 15:53:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id DD2586B0269
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 15:53:29 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id z7so12889799wrq.0
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 12:53:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=v9Ab9Tj+RVCU4cq2A1m0KjcVYNWbGNVS0C8seFizgB4=;
        b=BNWUms+56egE0p/58p8/5XhMnPQVXEdy2t6PLy82QmqGpQ3VO+Nb8R7qVkcvEk/K7I
         8e7Yh268AMTz8jDmUM+fcniu7iwWUU9ej7ZwimigDyHp3PR/kucojFwTLUOkZK9r0PdC
         hE4VCuqmRWx5TEwfPaNyXfW1NMx17p362Zvh8XXlHvs5KatDNa5RHackI7UJgHsv+Tif
         svT1u/bW+J9FjIe0jLC3VBqw3yiWeJCdSZbA3VHOFe49kRfCoGXsCwM6+GNdu7Ps2dXs
         loKtIPWm9afH4xoF9DIOi8+8knL8pkawqjacksLkYtsGHs0tJInoClAc7fQYR7hqrBLc
         J0IQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAWAeUtMaS/yHX1DZ6sALggz+3F/uy46WNHbsfe+UmVo0/ShT8sN
	vtlNR2ygG3IILHnw2phg172O2aayYjxxjl3Lau5Hg0RnBl/VLRnCU/e4XbYdvOVyxyvW7eQ1Puo
	/hxmfoNtO35ak/OGiHuygunzieJ0wwKE31pXU+PieOck6RtI1RrdtWfzM5bkvfH8/GA==
X-Received: by 2002:a1c:9991:: with SMTP id b139mr14053970wme.53.1555962809504;
        Mon, 22 Apr 2019 12:53:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwYmEOMgoHh7Io4FkxQ5RIDkR5uDHyu0P62RmHzql26BOr+MAoCbqaVpdq32RRNRRA9y/U8
X-Received: by 2002:a1c:9991:: with SMTP id b139mr14053944wme.53.1555962808844;
        Mon, 22 Apr 2019 12:53:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555962808; cv=none;
        d=google.com; s=arc-20160816;
        b=QC1IfEmuaz9mIJv9dkMzKnxstuKyAVPlYYdfOnc9QbTko9cCgv6lf/hIRvQx03eYJq
         xsfjsvKthGzsHAqpHmtXSop2REsK2ys1xlQPR44SIL8b5EP7iEz0T/mj8uRy3jnkmt7o
         aiNFRzR3jL3qkpvkp18uzb9h3pnM/SfNsmQ7jOOR/hQ55nRCcBG3AR6N3vjRdVZZMsmn
         bcuqXVv8EYvemFYkVAR6npX8pWFjo3dfEgcLmDpIf/hpkeJJ1StecQ+KYL5ab/ixWRnB
         BMtN5q5CgvUUZ0HeWub4M/f+CBce8tkAelwQXa5mAlqDSCz9YjTf6crNJCeiAn1Tto6F
         i7qQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=v9Ab9Tj+RVCU4cq2A1m0KjcVYNWbGNVS0C8seFizgB4=;
        b=p0q6csB5QMPfQA7ORVUpjen4m6WcPcXfqvZSxAUhvsIp4kv8C1A0yMKnN80lApbeMc
         4JgwpAB5sqMj+uIe3V+o8AoqZ9+0rUSZ/wJMe0FTvC6BCZ5gHbHxgxKlN1EjxusYJLcF
         7Lpq19V5rGCzVeiw5GDIDYk1tUYvLodT6CK1XX4g6r1Swldl/yUfYnhhZuc6ZVgj9FGg
         FeLKD6UnCJz8NcDG1R9M1R6LkQBm5XOwj75WNUR0aPdUfb+4iv7zr4bMe2+LZSPfdcZu
         bqnnINDNVUwh4KvrD2lXzT+4FIu4lCMPClbdYlOo+sNhyPlU2uUDtKvQpBFkJ9EDCeFJ
         F46w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id 188si9724661wme.63.2019.04.22.12.53.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 12:53:28 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id E2F5668E0F; Mon, 22 Apr 2019 21:53:09 +0200 (CEST)
Date: Mon, 22 Apr 2019 21:53:08 +0200
From: Christoph Hellwig <hch@lst.de>
To: Alexandre Ghiti <alex@ghiti.fr>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH v3 02/11] arm64: Make use of is_compat_task instead of
 hardcoding this test
Message-ID: <20190422195308.GA2224@lst.de>
References: <20190417052247.17809-1-alex@ghiti.fr> <20190417052247.17809-3-alex@ghiti.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190417052247.17809-3-alex@ghiti.fr>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 01:22:38AM -0400, Alexandre Ghiti wrote:
> Each architecture has its own way to determine if a task is a compat task,
> by using is_compat_task in arch_mmap_rnd, it allows more genericity and
> then it prepares its moving to mm/.
> 
> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

