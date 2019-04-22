Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E04EBC282CE
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 21:36:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B0822075A
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 21:36:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B0822075A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6905B6B0003; Mon, 22 Apr 2019 17:36:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 667CE6B0006; Mon, 22 Apr 2019 17:36:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 554C66B0007; Mon, 22 Apr 2019 17:36:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 35B9B6B0003
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 17:36:24 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id g7so11494973qkb.7
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 14:36:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=8Ec0BDC3SDr2CWg/mc5y7+eafRA+gLLv0ir1dY0Kvfg=;
        b=re9eJ9qme46xdV1DIByi9TyWgtaMKE49VL997CYYps4a1TIiqt7uqf/OT0yLEzhMHE
         2TTxwgYaVQiLg87MxdACvvEq3GduVy+AQQyTNaQSqz9ceBaBgWtXC2Kqw1Hmc4IW/g4t
         fGsX6Qh57gYKxTFJ9t3iS/WhT0gF1DaV8nL3bsJ4TAA1IGkncwmaqOID/pEXhBJ2a20t
         FMaG4VzmbcVzhSy1BOIOSt14Pdh2j0kRVWkqDn21h6GX+b4t1cnSsU8Bz5cHrvvVpIiW
         Xqz6RXCE3C5mKqnNRJrJhndhIkCSw4oMOEHKYVNkvscRF6fNxcq5hj7hCWlXu1M3IKIJ
         flwg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV3lOJNWOJ2qyNCCFaYiDat5ncXZH+LynTQplMzWimIBwWDtuOt
	mc7DY3jROI6SH1IBGpli+TJPG3grcMTgvT/nnvQkWXrXKZPIkunVaXRxN0aPAjwChUbJxU639FS
	Q39XzWeK9faGW4CGG36feYSlkkI0di0E9tfv9ZdZ/1YgNNTBnD0zOiBELpV/5lSrBkA==
X-Received: by 2002:ad4:5291:: with SMTP id v17mr5775246qvr.76.1555968983982;
        Mon, 22 Apr 2019 14:36:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz9vRfqHsj+C63lraYbHd1hthXXKjJ1Lv8vWxZz8Lq8UZn0Ey3wXbPbEoBXhxPh7N6If2T+
X-Received: by 2002:ad4:5291:: with SMTP id v17mr5775198qvr.76.1555968983097;
        Mon, 22 Apr 2019 14:36:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555968983; cv=none;
        d=google.com; s=arc-20160816;
        b=HU/BmlmTvBFsUvslpE0y9TfxAnOxio1cSprU+DhkFYEgpzpf/jvQ+ZtHgPkSXKY0pS
         M+CBe/VamWvdfYwp9kesNfdLqSprzlVgFQbqX9m0t3Wx4kdD2sxJOkt3ZqgBrL61LSEI
         b1iFLJ6MFOKUGISIigcFYbw/SVzXyJkJYjfsm1+yqycWxJnPsdcoVcdaklUeWlSoUbKy
         lz9A1mXiPMe/f37k0UyLracU5JIruzW3iI19uP2INukblDl4qA08fIBJJrHDcpICterj
         5XuTWigt/rpaT36RbMoycGLOGABmYujQJGexm0xCzwthO2c8KBuaokH/ozzDdtkLgdfQ
         pW3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=8Ec0BDC3SDr2CWg/mc5y7+eafRA+gLLv0ir1dY0Kvfg=;
        b=qK5THwh2Dmh1I6DR7DPPJo6EZVo2naAsCAH6wVsTv/VlCR8iWgKRNT+wpJQCwElMFH
         k54Bo/bVsj2Mro1F5kUTtkGSU5HtoZV2VIwmjbpspLvkC8FY/CaqCekd/eStAYBKezOe
         ZYq0EVeraaBc94mgJpnQzqUXVgsN452hAAjNQLCErhKJChSmKhleS37b1PNk27/hGFee
         Hnz5p0CUY85J28I0O6O2lQviYeiKQy2IC5j0BZvoNgpb1S4Z8vJ0VcBiuibroyh1GHlE
         TGWKVPSSRX5qea2ErmrR1BttSgkvQ778cx0R+BvNmfhRQyvWovHBQWyCeCRL9b4dHVIr
         qrsw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u51si5292900qtj.25.2019.04.22.14.36.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 14:36:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5F1213092650;
	Mon, 22 Apr 2019 21:36:21 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 94B225D9D4;
	Mon, 22 Apr 2019 21:36:13 +0000 (UTC)
Date: Mon, 22 Apr 2019 17:36:11 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Laurent Dufour <ldufour@linux.ibm.com>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org,
	kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net,
	jack@suse.cz, Matthew Wilcox <willy@infradead.org>,
	aneesh.kumar@linux.ibm.com, benh@kernel.crashing.org,
	mpe@ellerman.id.au, paulus@samba.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, hpa@zytor.com,
	Will Deacon <will.deacon@arm.com>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	sergey.senozhatsky.work@gmail.com,
	Andrea Arcangeli <aarcange@redhat.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	kemi.wang@intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>,
	David Rientjes <rientjes@google.com>,
	Ganesh Mahendran <opensource.ganesh@gmail.com>,
	Minchan Kim <minchan@kernel.org>,
	Punit Agrawal <punitagrawal@gmail.com>,
	vinayak menon <vinayakm.list@gmail.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	zhong jiang <zhongjiang@huawei.com>,
	Haiyan Song <haiyanx.song@intel.com>,
	Balbir Singh <bsingharora@gmail.com>, sj38.park@gmail.com,
	Michel Lespinasse <walken@google.com>,
	Mike Rapoport <rppt@linux.ibm.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com,
	paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>,
	linuxppc-dev@lists.ozlabs.org, x86@kernel.org,
	Vinayak Menon <vinmenon@codeaurora.org>
Subject: Re: [PATCH v12 23/31] mm: don't do swap readahead during speculative
 page fault
Message-ID: <20190422213611.GN14666@redhat.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <20190416134522.17540-24-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190416134522.17540-24-ldufour@linux.ibm.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Mon, 22 Apr 2019 21:36:22 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 03:45:14PM +0200, Laurent Dufour wrote:
> Vinayak Menon faced a panic because one thread was page faulting a page in
> swap, while another one was mprotecting a part of the VMA leading to a VMA
> split.
> This raise a panic in swap_vma_readahead() because the VMA's boundaries
> were not more matching the faulting address.
> 
> To avoid this, if the page is not found in the swap, the speculative page
> fault is aborted to retry a regular page fault.
> 
> Reported-by: Vinayak Menon <vinmenon@codeaurora.org>
> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

Note that you should also skip non swap entry in do_swap_page() when doing
speculative page fault at very least you need to is_device_private_entry()
case.

But this should either be part of patch 22 or another patch to fix swap
case.

> ---
>  mm/memory.c | 11 +++++++++++
>  1 file changed, 11 insertions(+)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 6e6bf61c0e5c..1991da97e2db 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2900,6 +2900,17 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
>  				lru_cache_add_anon(page);
>  				swap_readpage(page, true);
>  			}
> +		} else if (vmf->flags & FAULT_FLAG_SPECULATIVE) {
> +			/*
> +			 * Don't try readahead during a speculative page fault
> +			 * as the VMA's boundaries may change in our back.
> +			 * If the page is not in the swap cache and synchronous
> +			 * read is disabled, fall back to the regular page
> +			 * fault mechanism.
> +			 */
> +			delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
> +			ret = VM_FAULT_RETRY;
> +			goto out;
>  		} else {
>  			page = swapin_readahead(entry, GFP_HIGHUSER_MOVABLE,
>  						vmf);
> -- 
> 2.21.0
> 

