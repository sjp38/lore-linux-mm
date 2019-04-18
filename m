Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49C9AC10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 21:49:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B2E720693
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 21:49:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B2E720693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B092C6B0007; Thu, 18 Apr 2019 17:49:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB9306B0008; Thu, 18 Apr 2019 17:49:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9CF0D6B000A; Thu, 18 Apr 2019 17:49:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7D06E6B0007
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 17:49:45 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id g48so3245275qtk.19
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 14:49:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=p/ULSQpug3K1kdeblVYgTEJi2mDluzHcQqmYvQa7HvM=;
        b=Mw21T3mF73pXwcIqi7AwSIeBWhKHLJgAPm4HQmi05ZoFHZdx8DitUGDv16ocJikjeq
         6xzISwMcf9zVEz4g1bRQSqpcvhyxGBuq9762W7avHvE9CPKT8s7ZIm92Gb1d6BPDCz/r
         jNkHX6F+9f7DpQ+2M6+O9uXIGK6F/M9yVP3Zy/kLZ9v2+HsH7tAHTa9exZzA3asyn7T/
         74SxcNHhyGjzF1zsBLKTpEzXGV4yQM+RdwNucILJU4qVMIVRQ3A9GVyFRcsxEoLE9I0F
         OWF8lOdseuI3Jpbga3PhVGrGLc/fVWAbcapil8yiandQUYa2SGh29zAhoWvzpUJTWOlH
         4ehA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUyA9wK/nO0hwqQ/5kAkYu6VNRMrynwRFjXfDB4MtHSXqzfwKUH
	BtnZwxr44ScoGV/8k3uw4qAUURQbLxWMH2sNgKAuM5ZmJuPpAsAIiOS2+MH9sBkxdAN4ur5yE94
	Czqa5RdPJWkWEqnS+5LlM/BjiK6XlDcupKgossIEjp3Ca4bbT4hCh+W4RSOxBvmdU6w==
X-Received: by 2002:a0c:9e0a:: with SMTP id p10mr400923qve.175.1555624185289;
        Thu, 18 Apr 2019 14:49:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxU4Wf5fox0RIORctIWpzQ1pEQVNKfvQE/Rl5ERNZfIxcUSHHlCMBQbWf6VlMSwwFHprRoI
X-Received: by 2002:a0c:9e0a:: with SMTP id p10mr400880qve.175.1555624184755;
        Thu, 18 Apr 2019 14:49:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555624184; cv=none;
        d=google.com; s=arc-20160816;
        b=kSIOJfgjM8sDz+KuBHxrGgNYCUS0NNE41QbB5nVpKPgYYWjIY2XQ/EvqZzYUy9kwdc
         DO1r6bRjhtGjmSVmborqlwjamZVO/TT8SWF7+LGpTY5bSIgId0wIBEnkDS2uoSciZSKT
         zFOdsNYnGGWrXbTtzPa4j5rtJ9W16lf4NM8fSSViWsqH6jW7q5Gj+eFouUvsRc5wGcco
         CPNslrJfhTfv0igt930pIs+auUEd/LzYGtk9mrmLZCGCq9lKIDdxnl88ebjwtchx/ztG
         OgHsbxWb9uirXpp5bqg+oEQonGvtwPY5+fXpNrR/UtM9Lsh6KZBDjhYlAl/syz5uIfQM
         TVbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=p/ULSQpug3K1kdeblVYgTEJi2mDluzHcQqmYvQa7HvM=;
        b=Uu5TVbCi+okFaNHVB0LNov6zw4AWIVK6Agm8jhp4W7HSGwVVqjdypTRRvizMOm81s2
         vn3QYx+2HqwXWh2Q5HnPrjopNVdLy92SJ0joHiEeCEifWwa+9jQI5V06ls6Of4bDzgmj
         rQqjUTGgim3GbBsmaoLHH73fWW2LxaEhJ8rgDo7ww3H+AOUFCowmU30jKCVVlq9pPVsP
         DCS/0vPfvmsvYVibuEBENYh2BjudKFQCxixUwzmIgjI0VQ6hVeMsI8AdDwBRRqitv+zT
         rf+EvJJLtCoGrV+KgkwAPcdsv+v4c/JfONwV3QA1QIUwafr4z8aDf6kHXtDHougHE5jx
         tv+w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a67si1446903qkb.173.2019.04.18.14.49.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 14:49:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6E6B0300414C;
	Thu, 18 Apr 2019 21:49:43 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id F0AC25D70A;
	Thu, 18 Apr 2019 21:49:37 +0000 (UTC)
Date: Thu, 18 Apr 2019 17:49:36 -0400
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
Subject: Re: [PATCH v12 03/31] powerpc/mm: set
 ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
Message-ID: <20190418214936.GC11645@redhat.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <20190416134522.17540-4-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190416134522.17540-4-ldufour@linux.ibm.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Thu, 18 Apr 2019 21:49:44 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 03:44:54PM +0200, Laurent Dufour wrote:
> Set ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT for BOOK3S_64. This enables
> the Speculative Page Fault handler.
> 
> Support is only provide for BOOK3S_64 currently because:
> - require CONFIG_PPC_STD_MMU because checks done in
>   set_access_flags_filter()
> - require BOOK3S because we can't support for book3e_hugetlb_preload()
>   called by update_mmu_cache()
> 
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>

Same comment as for x86.

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

> ---
>  arch/powerpc/Kconfig | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
> index 2d0be82c3061..a29887ea5383 100644
> --- a/arch/powerpc/Kconfig
> +++ b/arch/powerpc/Kconfig
> @@ -238,6 +238,7 @@ config PPC
>  	select PCI_SYSCALL			if PCI
>  	select RTC_LIB
>  	select SPARSE_IRQ
> +	select ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT if PPC_BOOK3S_64
>  	select SYSCTL_EXCEPTION_TRACE
>  	select THREAD_INFO_IN_TASK
>  	select VIRT_TO_BUS			if !PPC64
> -- 
> 2.21.0
> 

