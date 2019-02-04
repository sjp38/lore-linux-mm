Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B45C9C282D7
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 08:45:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 77CAF20820
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 08:45:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 77CAF20820
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E51058E003A; Mon,  4 Feb 2019 03:45:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E00608E001C; Mon,  4 Feb 2019 03:45:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D15708E003A; Mon,  4 Feb 2019 03:45:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8DFD18E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 03:45:22 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id e68so11241159plb.3
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 00:45:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=S9sgKyAfuf9sT095sqV9OP+nfR8i9qRr5YQ+UXN6KEc=;
        b=jV6RxGAliqAV8Du2+XIZWM/90Qp/3KFadGdodB3nhXq9KPnHhIe+nQexfrDfThQWg6
         K/Am7l0Ad7mAeLM/+qCLhp+CTlc6RUNjIZ9ZZ4TRZSyWP0ECRl4lithR/sZvTAra89/a
         b+dpWvBTzpboYcpjuBQdhlbvdoz0AuYk4ossudIEOa5GSbw2EZeqcqc4o9zNUAa2pHgR
         HSnms/q1IBsTglHEwIq39Bf+lH6yc1Yh3i742YIF0aOZgWjWmUsVRW3chqQDfppWYQkP
         rFTOCDunjlWF7Z2QTNve6jefIVREyb5vxjty/zhfkE3PvTmTcaHH0toudy47GXhLzhV8
         jc1A==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: AJcUukeMvtE5XVLTagiKJ1f6MlkNa+pjLsk6tU3JWuxYCodNsqcY7cC+
	/M6ZK0iuYq6wn1rOPjL/O/ex6hhbhT2msIRBl8sA7ey5KIAdSNR5KmlpALI6dSPJrlmkIQ2M88j
	Icv4+2Udk1qaXslzqltM+qH5yjqxuPr8AXqrBkqg5IRO2ULxgg8y4QQG4OGUmnJE=
X-Received: by 2002:a62:a510:: with SMTP id v16mr49872701pfm.18.1549269922232;
        Mon, 04 Feb 2019 00:45:22 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5Y018M/Qd5m49PQx2jnMqV3JR8/ke0HtkP4q0YdS5tkU1WoED1W8xpRMHBjQ5DvlKIAc0+
X-Received: by 2002:a62:a510:: with SMTP id v16mr49872672pfm.18.1549269921316;
        Mon, 04 Feb 2019 00:45:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549269921; cv=none;
        d=google.com; s=arc-20160816;
        b=x/SIrO2Wh3PIR1N8EojvyZBhmQ5FajFk0XmtoEqiACJZlUC5dVL+839HwDNnALTjH9
         GZ/w7pxhuvenVWK5bAEhKKlWcSCSNnko2X8/VxPMAKgBo5Iv0kqS1JyNwLm1JMUUDnAy
         /iBMZ9E/udYkjUtLsxTv/LtGVT1A+K27VJroeA+D7+YgK7Xh8rrLVJCqnoNVWvPT/RIp
         CWhSuw5HwCNNupQvVjrx2IW8nKG8AiQYhsjz+H/rxxhyf+RQQx21mV8QkOsNjxJ9bBf1
         qG4k2RN4Xlw78oUwWj8tDL96DW6c0SgeA4rcgTXfWbUyZVGKuT04tTnSSH+1JsJdwcnO
         MCTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=S9sgKyAfuf9sT095sqV9OP+nfR8i9qRr5YQ+UXN6KEc=;
        b=FCEVPMlJAxrb2IWJ9+b9wGt6jpFa0zz9daEUIY4q5T+OoFWmvTv57+4Mye45sRseG2
         ssH3RGCSfZxa1LsMIUUGYipfY4xpFwNEp9XhYcwcJqsVlEkEOXOzSpTFfuE63lZsaE6A
         kReN9EV1tdJATGHtX3U5LG/pU4SwfTiJuc4x/C3Hw5yy5EW7HIYrLJwLnnNXpMKbkrwg
         beQ2HR1c6a8z1ooKZIsvgBY86IgMN5rBUZknDr5h36aA49lwWdvmJaBtczHz162vH0kp
         g/MOy5CLzDC5HiyazpCBS+b10mIKgzkzvQAL8gQYkEvFlWJrYXttCt+vcmfEMLHRpcbe
         WsBw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id x12si15139439plo.164.2019.02.04.00.45.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 04 Feb 2019 00:45:20 -0800 (PST)
Received-SPF: neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by ozlabs.org (Postfix) with ESMTPSA id 43tLrG3rCyz9s4Z;
	Mon,  4 Feb 2019 19:45:18 +1100 (AEDT)
From: Michael Ellerman <mpe@ellerman.id.au>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Subject: Re: [PATCH v2 10/21] memblock: refactor internal allocation functions
In-Reply-To: <20190203113915.GC8620@rapoport-lnx>
References: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com> <1548057848-15136-11-git-send-email-rppt@linux.ibm.com> <87ftt5nrcn.fsf@concordia.ellerman.id.au> <20190203113915.GC8620@rapoport-lnx>
Date: Mon, 04 Feb 2019 19:45:17 +1100
Message-ID: <878sywndr6.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Mike Rapoport <rppt@linux.ibm.com> writes:
> On Sun, Feb 03, 2019 at 08:39:20PM +1100, Michael Ellerman wrote:
>> Mike Rapoport <rppt@linux.ibm.com> writes:
>> > Currently, memblock has several internal functions with overlapping
>> > functionality. They all call memblock_find_in_range_node() to find free
>> > memory and then reserve the allocated range and mark it with kmemleak.
>> > However, there is difference in the allocation constraints and in fallback
>> > strategies.
...
>> 
>> This is causing problems on some of my machines.
...
>> 
>> On some of my other systems it does that, and then panics because it
>> can't allocate anything at all:
>> 
>> [    0.000000] numa:   NODE_DATA [mem 0x7ffcaee80-0x7ffcb3fff]
>> [    0.000000] numa:   NODE_DATA [mem 0x7ffc99d00-0x7ffc9ee7f]
>> [    0.000000] numa:     NODE_DATA(1) on node 0
>> [    0.000000] Kernel panic - not syncing: Cannot allocate 20864 bytes for node 16 data
>> [    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc4-gccN-next-20190201-gdc4c899 #1
>> [    0.000000] Call Trace:
>> [    0.000000] [c0000000011cfca0] [c000000000c11044] dump_stack+0xe8/0x164 (unreliable)
>> [    0.000000] [c0000000011cfcf0] [c0000000000fdd6c] panic+0x17c/0x3e0
>> [    0.000000] [c0000000011cfd90] [c000000000f61bc8] initmem_init+0x128/0x260
>> [    0.000000] [c0000000011cfe60] [c000000000f57940] setup_arch+0x398/0x418
>> [    0.000000] [c0000000011cfee0] [c000000000f50a94] start_kernel+0xa0/0x684
>> [    0.000000] [c0000000011cff90] [c00000000000af70] start_here_common+0x1c/0x52c
>> [    0.000000] Rebooting in 180 seconds..
>> 
>> 
>> So there's something going wrong there, I haven't had time to dig into
>> it though (Sunday night here).
>
> Yeah, I've misplaced 'nid' and 'MEMBLOCK_ALLOC_ACCESSIBLE' in
> memblock_phys_alloc_try_nid() :(
>
> Can you please check if the below patch fixes the issue on your systems?

Yes it does, thanks.

Tested-by: Michael Ellerman <mpe@ellerman.id.au>

cheers


> From 5875b7440e985ce551e6da3cb28aa8e9af697e10 Mon Sep 17 00:00:00 2001
> From: Mike Rapoport <rppt@linux.ibm.com>
> Date: Sun, 3 Feb 2019 13:35:42 +0200
> Subject: [PATCH] memblock: fix parameter order in
>  memblock_phys_alloc_try_nid()
>
> The refactoring of internal memblock allocation functions used wrong order
> of parameters in memblock_alloc_range_nid() call from
> memblock_phys_alloc_try_nid().
> Fix it.
>
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> ---
>  mm/memblock.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/mm/memblock.c b/mm/memblock.c
> index e047933..0151a5b 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1402,8 +1402,8 @@ phys_addr_t __init memblock_phys_alloc_range(phys_addr_t size,
>  
>  phys_addr_t __init memblock_phys_alloc_try_nid(phys_addr_t size, phys_addr_t align, int nid)
>  {
> -	return memblock_alloc_range_nid(size, align, 0, nid,
> -					MEMBLOCK_ALLOC_ACCESSIBLE);
> +	return memblock_alloc_range_nid(size, align, 0,
> +					MEMBLOCK_ALLOC_ACCESSIBLE, nid);
>  }
>  
>  /**
> -- 
> 2.7.4
>
>
> -- 
> Sincerely yours,
> Mike.

