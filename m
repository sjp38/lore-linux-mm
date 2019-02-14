Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E4C3C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 20:38:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E14F921916
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 20:38:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E14F921916
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E38D8E0002; Thu, 14 Feb 2019 15:38:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7902A8E0001; Thu, 14 Feb 2019 15:38:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A7F18E0002; Thu, 14 Feb 2019 15:38:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2926C8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 15:38:27 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id h26so5685377pfn.20
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 12:38:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=KAwhWuNiiut9/IOCMTxO38q+0iFaqALYJhDT7CUjoqg=;
        b=pHKVCsuDi68YIQ8pM+yBp7kVRoyNr1OFu7qssnoG7EZI6YwivVQSCQzSI7oSD4lTIJ
         nMy3pSC+BbqI7XNCC9S8Coo45QwGAbwlnfpiJ4yqwEIZnGjKLS0mmvSjzMGJ2+zW+MZa
         ZNInGRDXo5vy9NB0EtojGmdNMfidaLdMysxFcTWx8KsQ/zCH2DkFp3Imnulg9LGXvFTx
         Nfuv0J28Ez1UQSdhfcKNFSaQfvrAIz+96bsIzzTpz4OJKG+hzeR93i7GcRa1s8uB66WV
         0khvfNepM1DZoHbGO+MC/eVxsR5Gi5o75vmuJKs+TK4tDt/1J7zgx4HSwvFthl2+9pB0
         L8Zw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAuamlHnKxSYCfTvCWPxTk4MlI1ifi1VQfth1bcyulVV0jo/EvqCO
	gpTqN0vuy6XYhshyAfHcn5mXZzv+H3PkaWwbKFBngnCMzO//LLeBRuJALtqEc9i8lLlWp3eQd8E
	l1Z3SNYX0yUJn+F5p02POvr7vW/FHxJcRB/ECLeV9lc1ylYJfRmBtFCg6eWS7w8XyRQ==
X-Received: by 2002:aa7:9102:: with SMTP id 2mr5950785pfh.179.1550176706828;
        Thu, 14 Feb 2019 12:38:26 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZuscRiZNfVMdwGYlGKv7/kdWRUTwkt8aZIecyNYRrH9baZskEnOTEAK6msFTOxlu2BT106
X-Received: by 2002:aa7:9102:: with SMTP id 2mr5950736pfh.179.1550176706162;
        Thu, 14 Feb 2019 12:38:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550176706; cv=none;
        d=google.com; s=arc-20160816;
        b=I/u1wPiaDTkiMMe/tMGN5DJ7GUTPlSLIZNulAlkw73x0qi0EyA0wDFq6E+TBHtRpgK
         lMvHKpGtG9PmriiuONvP5TMGDikLEuHqK1vW32eTn1nWTDKHzkBiCMMvJ19jpebwgXE1
         s0vp9ZHBEbRme9cjQfge72RbnCHR+fh6sEWX3h2XAZeh5JGMYioXOkVMvVC/E7p/k9dr
         GlRoAjVCfNDTeX3bcaSDXIPGm6XqsMXjjuJwtH65ory+DLYlzqkvO87N7e/Nzaa8izbO
         94DnLKwdyPAYq0b/DOB7nUbGShmkSf2zIbmoKt4IJ+9su9Lv764GzhQxa52zt4pu2rPw
         uChw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=KAwhWuNiiut9/IOCMTxO38q+0iFaqALYJhDT7CUjoqg=;
        b=HR0348JNikU8Z88sW8AwgnTGIEw6SxBzUgQmdkd+lQyGU4CaCifW6uCvxSNSY8CsQ0
         stRdqlD/JIbCMJkheHxiA0zaRhDKn5Lb7IQNSEy2IcVILYbKALE0YIP0e9fEx9XsqvFV
         biZVZO9GYkoLwNZWawuvT0ixxDuiaAtwlA2csEMdSQhzR25Y5iZkOmaVb0ys7o0tt6x/
         K7mUvYx7sMbz6SxiTatUzXu5Hc7iP67bt9ZvsBvmyFYMMVSzieY9koXk6/EJvBGWk1Kl
         PJoF+k3cR1M6+xasEqTvGdcIDI6auafOPXv4J31RXfa5W3Evn9nrJ6m0RWTmM3aGPC5P
         U02g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b86si3532001pfc.217.2019.02.14.12.38.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 12:38:26 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 5BEAAA7A;
	Thu, 14 Feb 2019 20:38:25 +0000 (UTC)
Date: Thu, 14 Feb 2019 12:38:24 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Peng Fan <peng.fan@nxp.com>
Cc: "labbott@redhat.com" <labbott@redhat.com>, "mhocko@suse.com"
 <mhocko@suse.com>, "vbabka@suse.cz" <vbabka@suse.cz>,
 "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>,
 "rppt@linux.vnet.ibm.com" <rppt@linux.vnet.ibm.com>,
 "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>,
 "rdunlap@infradead.org" <rdunlap@infradead.org>, "andreyknvl@google.com"
 <andreyknvl@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "van.freenix@gmail.com" <van.freenix@gmail.com>, Mike Rapoport
 <rppt@linux.ibm.com>
Subject: Re: [PATCH] mm/cma: cma_declare_contiguous: correct err handling
Message-Id: <20190214123824.fe95cc2e603f75382490bfb4@linux-foundation.org>
In-Reply-To: <20190214125704.6678-1-peng.fan@nxp.com>
References: <20190214125704.6678-1-peng.fan@nxp.com>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 14 Feb 2019 12:45:51 +0000 Peng Fan <peng.fan@nxp.com> wrote:

> In case cma_init_reserved_mem failed, need to free the memblock allocated
> by memblock_reserve or memblock_alloc_range.
> 
> ...
>
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -353,12 +353,14 @@ int __init cma_declare_contiguous(phys_addr_t base,
>  
>  	ret = cma_init_reserved_mem(base, size, order_per_bit, name, res_cma);
>  	if (ret)
> -		goto err;
> +		goto free_mem;
>  
>  	pr_info("Reserved %ld MiB at %pa\n", (unsigned long)size / SZ_1M,
>  		&base);
>  	return 0;
>  
> +free_mem:
> +	memblock_free(base, size);
>  err:
>  	pr_err("Failed to reserve %ld MiB\n", (unsigned long)size / SZ_1M);
>  	return ret;

This doesn't look right to me.  In the `fixed==true' case we didn't
actually allocate anything and in the `fixed==false' case, the
allocated memory is at `addr', not at `base'.

