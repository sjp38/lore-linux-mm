Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4EC2AC282DA
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 14:27:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 177EA2192C
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 14:27:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 177EA2192C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B9E536B02A2; Tue, 16 Apr 2019 10:27:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B23DB6B02A4; Tue, 16 Apr 2019 10:27:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9EC9A6B02A5; Tue, 16 Apr 2019 10:27:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4C9086B02A2
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 10:27:26 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id g1so11024568edm.16
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 07:27:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=znezo8poQ7QP48JM1koeEJOw/qPByyMkEOJy/hxeCGI=;
        b=imTy+dY3SvYdzzqglxLk4WMg1fo+MbQK73hJ1iR8nWdoP8q98XlKrgU4ZU/31O12HZ
         +WoiuoWZGkf88igqjFYoA+Gj3cwb+au9k6achx41FTAq5VZt7d10CZ0DcybmR2dtJrd2
         IVP21nU8/3tfqoNj3uFKisEo8kMwsQFRHm5eODHDgLNaVw03e16fMOBkQywlwODyeoY1
         JRbuTzxwD7Gmu5pSxdTebJjYepuHLq4gacQG3nYCtywkoddm/BHcgEC2q7lJ74UJONeK
         Is0tKjFoz2oHFxNlNJ6/jR1EjUGNkvbb4Xq2Vx9VC47825ueGmtXZdJbpAzgDIaklLNQ
         60IA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAVc7UaL+BH147v7+7VYThMwABPreVcuQ0vsb1+z/YgjU9FT3Dc/
	2eaUA6MIijYmUwqVOL4gInTILg3VZ/3mKl78cqoRpIngwOpFK2OFNZZ9VDiv6VXkRJtMVXGaSdD
	rysHi/KHYsSBIS89xxCvc/nfu5t3XqcGHMlhdWyba5WzqEY+v3rOurzP3UoUIgBPldw==
X-Received: by 2002:a50:cb0a:: with SMTP id g10mr36256135edi.41.1555424845857;
        Tue, 16 Apr 2019 07:27:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzWVmGekfyz2JrKM2B73vPckgbPnHyFLS1p2gqZg9lpuNCU8arZa6Kv8dkizHW9qLWwJXGz
X-Received: by 2002:a50:cb0a:: with SMTP id g10mr36256091edi.41.1555424845019;
        Tue, 16 Apr 2019 07:27:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555424845; cv=none;
        d=google.com; s=arc-20160816;
        b=a6tgX1iv4lM8AwPxHErK0uqy5MBzbNGFDQN/T6ZtX/Pfd/Wf6Mxk+5NsbTvDo2lUqk
         Lyvl8Ew00COVAlh1wsn0IuB5kSovVK1o2uK613VScJbJl1bhiIYiIR9xq5idyftPa0zr
         vwjB1NpnSmpd4eaFtCtky4dReul4cFXEDQHNxIbCTTO8xQ0B5qpmJmqSOi7IS+8BPzRq
         ZoXhjIT2+xD1fViz4hsRsteyRVmUM4SYQCf4IK9RnA6fihNhb5Xt3VCrKBeZXIarKM2n
         BGdoOK2M38Zt+bCmjS/D42QiS5surCTFCYgRWYonY6q+cKusIYAtEUgpD77Gjub4oMY6
         AjbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=znezo8poQ7QP48JM1koeEJOw/qPByyMkEOJy/hxeCGI=;
        b=NjdLzZLC+2pr/z8Phdwg6pz1jLCxHgN7mMMOalfuA5kUcepyHHU3l6VTA63oxkXse9
         hZblK8IYkakuTCQnrrbXZgO4/oXYl4jZLiQB1Nl/WUDAMUWbsbO10yY3U9uB97IJ3plr
         Ti67WWi79CSAdLMZ+UvSOoaW0eOh6jBozb8vFhmp5vxyPlj8+y+5UDj4h+eCOghgYAAX
         f4Tl4cNgJzffUsK5L86tilgcql4iOYYHzJTK83I5SzYKliR/SanN/41v9suKhwzXNFUT
         771pJV+f4hRCQF119Ot28aiuh+J9Nv86zQNngjj5xLRXlMfm2y4gJgfhmCF6DzHAUQx1
         Z5Jg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r16si5715073edp.298.2019.04.16.07.27.24
        for <linux-mm@kvack.org>;
        Tue, 16 Apr 2019 07:27:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D695EEBD;
	Tue, 16 Apr 2019 07:27:23 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 24F113F59C;
	Tue, 16 Apr 2019 07:27:17 -0700 (PDT)
Date: Tue, 16 Apr 2019 15:27:10 +0100
From: Mark Rutland <mark.rutland@arm.com>
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
	Jerome Glisse <jglisse@redhat.com>,
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
Subject: Re: [PATCH v12 04/31] arm64/mm: define
 ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
Message-ID: <20190416142710.GA54515@lakrids.cambridge.arm.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <20190416134522.17540-5-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190416134522.17540-5-ldufour@linux.ibm.com>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 03:44:55PM +0200, Laurent Dufour wrote:
> From: Mahendran Ganesh <opensource.ganesh@gmail.com>
> 
> Set ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT for arm64. This
> enables Speculative Page Fault handler.
> 
> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>

This is missing your S-o-B.

The first patch noted that the ARCH_SUPPORTS_* option was there because
the arch code had to make an explicit call to try to handle the fault
speculatively, but that isn't addeed until patch 30.

Why is this separate from that code?

Thanks,
Mark.

> ---
>  arch/arm64/Kconfig | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index 870ef86a64ed..8e86934d598b 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -174,6 +174,7 @@ config ARM64
>  	select SWIOTLB
>  	select SYSCTL_EXCEPTION_TRACE
>  	select THREAD_INFO_IN_TASK
> +	select ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
>  	help
>  	  ARM 64-bit (AArch64) Linux support.
>  
> -- 
> 2.21.0
> 

