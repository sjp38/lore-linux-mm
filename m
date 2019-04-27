Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A08EEC43218
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 04:00:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 27924206BF
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 04:00:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="om0/dO3b"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 27924206BF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 92A8F6B0003; Sat, 27 Apr 2019 00:00:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D7F96B0005; Sat, 27 Apr 2019 00:00:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 79EEB6B0006; Sat, 27 Apr 2019 00:00:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 410576B0003
	for <linux-mm@kvack.org>; Sat, 27 Apr 2019 00:00:30 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id o1so3318602pgv.15
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 21:00:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=i/m5ZRNk7cAVz4wurBU96zAR+YAnziWC+vvr6x3mZh0=;
        b=rcYl/GlT/PHU3H/NqLuS981ZPM8DxM6IGJiXTglJNWKGXKMj98LrugkHxqb1a97bUw
         bitl1+TH9uxT0K78/XNCoCa7s0wCsCiz6WveohhWu9HBJjicNv9XJkvdTsA4fC59ytBG
         851UK1TIp9yh89j4SlTwaoXwbYswkNzFms7kLWSvqeqSTpK801z1g/OWpVIE/teHOAnd
         +bIkFvcaLB/uTYIZIdCiXisKcjiRyJAT9ojWbxy1v+8yA8pJ43BEQK/5Xi9bavHH6MNj
         coN5Bzwmpz0YnRa5GyNTg+k9fUKXqKhAoI02L0an+01yUL363Qox7iiARYbfnwjK1HFK
         +K3Q==
X-Gm-Message-State: APjAAAUzOkgkhTBgo2e6J8QH+UC4w0FzNYHDi8cfpNAio1O3tOB3B2cW
	nf4+H0wCo9woACNBIB4vzbV2mDp3PDec99gFaXkm5tq84mNHKwoo+ofXe4d3ZXl3jdXUnLavW5G
	KA82Sbu+ybBWLhEfKYYZN4+oUwAuxKdam8HqkgNFyZH+4HatFOxVzJ7TnWCwJ1DNTfg==
X-Received: by 2002:a65:518d:: with SMTP id h13mr47895727pgq.259.1556337629816;
        Fri, 26 Apr 2019 21:00:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxOuoYeYTG+f0Y4loKOIMsbGXN0t+//3FfBT507UtQpMuJTtQXqfJQ5WJwNNF+vfzm/FQxP
X-Received: by 2002:a65:518d:: with SMTP id h13mr47895652pgq.259.1556337628854;
        Fri, 26 Apr 2019 21:00:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556337628; cv=none;
        d=google.com; s=arc-20160816;
        b=SOA27FZbFT0SKQki19S8ZfI3YzZQw/+XQLIJqlSjdoWtuG2fiV7ip2bSPwjKr7fOos
         ktsnUz+N3ikBcVqHUc005YS/ResVcGHqo5orC6dk2g9sfk92ecwRyj28zA4RdTNI88oT
         r8n0U1cThWOUnpOw2CSoUBjG0GJlam8LQuzVgRkDRlP8upWrZ9OB5tTWZEUbb6TMNai2
         bhx2KPXtKoGSJ4zDEYOidG1LPy585dIQpm2OZmJA5U0H+JkZMWC+zYLkWtR4FteoXJOu
         tdHcsl+l45aLgoRH8nzfNxa8HwY2uxTOCDW2LrLUqNbRBJelSZCa7lvdN3K7pYANFc70
         RqVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=i/m5ZRNk7cAVz4wurBU96zAR+YAnziWC+vvr6x3mZh0=;
        b=B3W7LI4P/KGX3Ara6MjtrHKEfRzmPc2HHjSpdeY87EDup5kd2Pknyp0cHjt7DHBpeu
         53JpsvqiukESa0vl2rkW9aZEq5C37SOs1hswCF0qzc4zNMslNz1TI2KAnlydwz66dL1S
         yrRc0ylrNvG+fkFJA6FAZyJjZzuMEnyA16Z5bYKT28wQdYubQ403GtsLB7KQSy+7dc39
         I53DyMQoPZGiVUbdvUuTV5P+awMTET+W1VQ5mdmd9fNcR5v8kEnZ9G6WkDncIR2xOvEu
         0zLt/AmjEJBzfoqp08HpYo76zMLJpz/BvFgY7xXGvuwVJZ72QdhcdbBG4x4a+y81k2b7
         W7Ow==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="om0/dO3b";
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z127si28962489pfb.254.2019.04.26.21.00.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 26 Apr 2019 21:00:28 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="om0/dO3b";
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:
	Subject:Sender:Reply-To:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=i/m5ZRNk7cAVz4wurBU96zAR+YAnziWC+vvr6x3mZh0=; b=om0/dO3bdLqw+0zMMvofbYpIq
	NhE77Vxez19Lul4FNwBITl1Nejx9YB+dcWM7ag2HHVekeLvH0gPZ4a/NkdetzB4LL3C0Zu93zAOw7
	JPjNPpW81Wu2XWf7fGKz5S1WsKrdmN+pCu3cu0AcwzKz4DcYYvvKueknUbEYG8YgtL6/izIhv6bG6
	+xb5gFMBMwZ/Dq5tqErP4MeVOZamfVwj6e520tEQSXMRvn+y73coCIYbgLDM/Z1s4PXVlSKWWOKLb
	7MbAMjOg9x6jRgiKWyMy9g/wgS41HC78yOKE1tSI+LAhtWDKqPiGZWOZyesgSIxVFKMRToouDkw5L
	f4ShFEFPA==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=midway.dunlab)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hKEVn-0000Sd-IV; Sat, 27 Apr 2019 04:00:27 +0000
Subject: Re: [PATCH v2] docs/vm: add documentation of memory models
To: Mike Rapoport <rppt@linux.ibm.com>, Jonathan Corbet <corbet@lwn.net>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>, linux-doc@vger.kernel.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1556228236-12540-1-git-send-email-rppt@linux.ibm.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <cb3d9579-ca20-bd16-31d9-78d634e7e635@infradead.org>
Date: Fri, 26 Apr 2019 21:00:27 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <1556228236-12540-1-git-send-email-rppt@linux.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/25/19 2:37 PM, Mike Rapoport wrote:
> Describe what {FLAT,DISCONTIG,SPARSE}MEM are and how they manage to
> maintain pfn <-> struct page correspondence.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> ---
> v2 changes:
> * spelling/grammar fixes
> * added note about deprectation of DISCONTIGMEM

                     deprecation

and a few more comments below...


> * added a paragraph about 'struct vmem_altmap'
> 
>  Documentation/vm/index.rst        |   1 +
>  Documentation/vm/memory-model.rst | 183 ++++++++++++++++++++++++++++++++++++++
>  2 files changed, 184 insertions(+)
>  create mode 100644 Documentation/vm/memory-model.rst
> 
> diff --git a/Documentation/vm/index.rst b/Documentation/vm/index.rst
> index b58cc3b..e8d943b 100644
> --- a/Documentation/vm/index.rst
> +++ b/Documentation/vm/index.rst
> @@ -37,6 +37,7 @@ descriptions of data structures and algorithms.
>     hwpoison
>     hugetlbfs_reserv
>     ksm
> +   memory-model
>     mmu_notifier
>     numa
>     overcommit-accounting
> diff --git a/Documentation/vm/memory-model.rst b/Documentation/vm/memory-model.rst
> new file mode 100644
> index 0000000..0b4cf19
> --- /dev/null
> +++ b/Documentation/vm/memory-model.rst
> @@ -0,0 +1,183 @@
> +.. SPDX-License-Identifier: GPL-2.0
> +
> +.. _physical_memory_model:
> +
> +=====================
> +Physical Memory Model
> +=====================
> +
> +Physical memory in a system may be addressed in different ways. The
> +simplest case is when the physical memory starts at address 0 and
> +spans a contiguous range up to the maximal address. It could be,
> +however, that this range contains small holes that are not accessible
> +for the CPU. Then there could be several contiguous ranges at
> +completely distinct addresses. And, don't forget about NUMA, where
> +different memory banks are attached to different CPUs.
> +
> +Linux abstracts this diversity using one of the three memory models:
> +FLATMEM, DISCONTIGMEM and SPARSEMEM. Each architecture defines what
> +memory models it supports, what is the default memory model and

                              what the default memory model is and

> +whether it possible to manually override that default.

   whether it is possible

> +
> +.. note::
> +   At time of this writing, DISCONTIGMEM is considered deprecated,
> +   although it is still in use by several architectures

end with '.'

> +
> +All the memory models track the status of physical page frames using
> +:c:type:`struct page` arranged in one or more arrays.
> +
> +Regardless of the selected memory model, there exists one-to-one
> +mapping between the physical page frame number (PFN) and the
> +corresponding `struct page`.
> +
> +Each memory model defines :c:func:`pfn_to_page` and :c:func:`page_to_pfn`
> +helpers that allow the conversion from PFN to `struct page` and vice
> +versa.

[snip]


thanks.
-- 
~Randy

