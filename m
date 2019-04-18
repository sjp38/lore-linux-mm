Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC82EC282DD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 21:47:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6BCB520652
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 21:47:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6BCB520652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 084D36B0005; Thu, 18 Apr 2019 17:47:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 034AD6B0006; Thu, 18 Apr 2019 17:47:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E3F2D6B0007; Thu, 18 Apr 2019 17:47:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id C2EBC6B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 17:47:30 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id n1so3230985qte.12
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 14:47:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=LPJ2NCPPdrZe8rPHVGpcy7e3s7cuKGwQ//HzPWb0JRE=;
        b=BgVi6LKlV0pjS1nw5evE8Ybw6VkJfV0NFjk4Qca+ao+nSI5rtxsDRv0Qu40/3Ymaqy
         OoYud6VhaeM7q36buTxqCg7fTy1OCCCL+g9l4h7RRrrATPpR/Xx/K5FHtwPMxsxhrIkv
         Zf6miNJ9V/7ST6077NO8ccVCYpcQejUI6Zv2HIGifhwRPLiqHT347P7MUPu4ygzX49zs
         0FWnNHjV1Neq7Ohwn6T0Ov3rCLZJ/XclasTCu5H13h3OWAh0+VSQs4/pn8fDcVVyIlrp
         3MGEI1QtarA6YIN1BFt+z1HVfpUp4i0NBr71zsk6uBd+PXjFbeRYLww0f3TkdLt2ur2s
         xj4w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUrSpy0YhdMf4r5b26iT7JO+2n9I8l/2ekCQ2Smu/NvslN30j+7
	rdhD8lrc6A55nVCHC9m+Ljt5ijXuAsiw42HdtqQC5NVVPWm9k1LA8BQc5SQC+7r+B3ifiLJCmPL
	eHewpNPLKPS2gzm8ggLyFCSqkrypedNiyfoZ7oDCVyyn8FdqHfrLMjSWeAnYsyZ1EOw==
X-Received: by 2002:a37:a457:: with SMTP id n84mr291106qke.85.1555624050531;
        Thu, 18 Apr 2019 14:47:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwUgBIxb48O44vPR9x5qRSConqBQVAVHxAmKZ4cQL0IjHHcTVUJG5Qwny9BAqzt5EG/Zfgb
X-Received: by 2002:a37:a457:: with SMTP id n84mr291069qke.85.1555624049894;
        Thu, 18 Apr 2019 14:47:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555624049; cv=none;
        d=google.com; s=arc-20160816;
        b=ZrSYmBdticvO4/WKU0ZxunZBYTtuH9QJerojG0Ekhpz/Ozx1pOzMXtcrOnfumk1IsQ
         qUK+rLEZ4RDQm+u60PTtbB92PfnQu2kVUA2pDLJVZejim6C1hDZkT4qJQ0ylmsAJHlCZ
         zzfGF/RNaA+d/l1Kzj7T/gj1spKsHnBheuisviJclrhP8jkQjtrvjuFA+mQU9PP/QJWq
         oCIXWdUr/ApBJLwT804Y8W205n9iRXbtXqw04qOD4gfwjZbcwUoVfxUyORMlSCTC9yZd
         RCrSbSFP9OXgX6ZRrRiNBlRt1KEKw8Icc+/PPe31Cr6lGj0a+KuxxEj2sGHwJJG6n+EC
         blzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=LPJ2NCPPdrZe8rPHVGpcy7e3s7cuKGwQ//HzPWb0JRE=;
        b=XbrQB140OnVyyP8joWXqoX45pCdmNUi2/V/q0pyXE/B5ULImJ1uoe1lYXMvtW0tHkL
         qlMzUaTlLMOGAyYugu9F19jEc5Ztxtyw4XqbO3R0ZP7fIy3QnWre3pMiEVsdgh+9IcA3
         zOoLYmQ4fGFVgXgehx/96g+tsWmP70SuzpnVeGyXu6oe30iU5YOxFJyVSePYf90pJWBG
         Xfwqg50N+6slThjMCRbizEaVuMmyH9tSVxzyYQGMFaaBRw484RB3vK9WxI/61XJL6jBV
         drlHsvn3uZexeQRcyheok1FHZ59wIAxqoIXujXpPFXeQkuy82UrHhVkBo0BOzc5o18Qx
         9iSA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u35si2107134qtk.325.2019.04.18.14.47.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 14:47:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 051B03082B44;
	Thu, 18 Apr 2019 21:47:28 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 20A455D70A;
	Thu, 18 Apr 2019 21:47:23 +0000 (UTC)
Date: Thu, 18 Apr 2019 17:47:21 -0400
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
	linuxppc-dev@lists.ozlabs.org, x86@kernel.org
Subject: Re: [PATCH v12 01/31] mm: introduce CONFIG_SPECULATIVE_PAGE_FAULT
Message-ID: <20190418214721.GA11645@redhat.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <20190416134522.17540-2-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190416134522.17540-2-ldufour@linux.ibm.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Thu, 18 Apr 2019 21:47:29 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 03:44:52PM +0200, Laurent Dufour wrote:
> This configuration variable will be used to build the code needed to
> handle speculative page fault.
> 
> By default it is turned off, and activated depending on architecture
> support, ARCH_HAS_PTE_SPECIAL, SMP and MMU.
> 
> The architecture support is needed since the speculative page fault handler
> is called from the architecture's page faulting code, and some code has to
> be added there to handle the speculative handler.
> 
> The dependency on ARCH_HAS_PTE_SPECIAL is required because vm_normal_page()
> does processing that is not compatible with the speculative handling in the
> case ARCH_HAS_PTE_SPECIAL is not set.
> 
> Suggested-by: Thomas Gleixner <tglx@linutronix.de>
> Suggested-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

Small question below

> ---
>  mm/Kconfig | 22 ++++++++++++++++++++++
>  1 file changed, 22 insertions(+)
> 
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 0eada3f818fa..ff278ac9978a 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -761,4 +761,26 @@ config GUP_BENCHMARK
>  config ARCH_HAS_PTE_SPECIAL
>  	bool
>  
> +config ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
> +       def_bool n
> +
> +config SPECULATIVE_PAGE_FAULT
> +	bool "Speculative page faults"
> +	default y
> +	depends on ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
> +	depends on ARCH_HAS_PTE_SPECIAL && MMU && SMP
> +	help
> +	  Try to handle user space page faults without holding the mmap_sem.
> +
> +	  This should allow better concurrency for massively threaded processes

Is there any case where it does not provide better concurrency ? The
should make me wonder :)

> +	  since the page fault handler will not wait for other thread's memory
> +	  layout change to be done, assuming that this change is done in
> +	  another part of the process's memory space. This type of page fault
> +	  is named speculative page fault.
> +
> +	  If the speculative page fault fails because a concurrent modification
> +	  is detected or because underlying PMD or PTE tables are not yet
> +	  allocated, the speculative page fault fails and a classic page fault
> +	  is then tried.
> +
>  endmenu
> -- 
> 2.21.0
> 

