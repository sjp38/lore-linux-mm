Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97328C282CE
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 04:22:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B66520850
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 04:22:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ozlabs-ru.20150623.gappssmtp.com header.i=@ozlabs-ru.20150623.gappssmtp.com header.b="HTcFkVg3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B66520850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ozlabs.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CCF2F6B0005; Thu, 11 Apr 2019 00:22:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C7F816B0006; Thu, 11 Apr 2019 00:22:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B46E36B0007; Thu, 11 Apr 2019 00:22:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 76A616B0005
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 00:22:34 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id x5so3282039pll.2
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 21:22:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :openpgp:autocrypt:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=HSLvlisSEjMVI0TWIDGbvhFmw9CUylYqc/pMmCcKknE=;
        b=CUArlh4TCgKQWlA2z6ROmL1YSMrtBrsfkYvuKhifEb9H+XLeCQjGDZTNs40hyz2mMu
         tbADKgRudn9JueUuTx6GebFNnRRhm6EODuQltf1wiR57PcvWvbXWiUR0yHdQkI8sLvuz
         18L477EOfyOisy6Y9sPuAt3sEF5qBc7Rss8dv/x4wyjJTrG7rzO3SeejVRrk7EKT5GWx
         XJT3EQHHzIGiO5jZvq2Y67ZS15992h+bsKC90ZkezlMXP9DNVhWGnTCyrnXyIo9pTFBR
         APOcSif6f7hvgriYApOnE+10lNAq9VRlgJRMslvORc6JcUNnnZFocwjmRIh7jw1chx8a
         ggPw==
X-Gm-Message-State: APjAAAWUqYS1s1Oxu3wP29xZKLSrjsURN2xDN8YHaA0ihBN62IqVbEKO
	1mJ0/n4aQbpTQ4ToCiylv/Idi3NkzfjAaDNGwRJSMPaf+hThMdmAPQm+AeniOxpVr3mWWd2McXC
	1gctUWW316XVGvO/GWba5dB4DbQbDiAWJWPuBDOyIygAMoutsE91FG7qRnnCz35+llg==
X-Received: by 2002:a62:ab14:: with SMTP id p20mr47436919pff.23.1554956553793;
        Wed, 10 Apr 2019 21:22:33 -0700 (PDT)
X-Received: by 2002:a62:ab14:: with SMTP id p20mr47436874pff.23.1554956552914;
        Wed, 10 Apr 2019 21:22:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554956552; cv=none;
        d=google.com; s=arc-20160816;
        b=w8HEV3eg7EnwivLtJiAfbGzb82dqZp4g1kgQkVnjFhfUsT6zzppVGcO/OQ5wxjdQ7d
         8DJ5IlF4V9DNxzEdPAja3FpDa1BParlYtrxR7NaA2otBBM7eFA9KvWgToIqSt/aJHqrU
         /qdA6qCJRLp7RO0tkvNL59BQ+DmyPuBEN7drrWJ9M3RiFBE4HSELWBvsbaVohAFhqVrb
         USLmWaYeo12COMUl8WWfwfD0+2dMKi6P/tKJq/jVGkn+fq+1DOM6NoJjTJTMOiKbr0OB
         JUdv9OsdkpXMP8qQ11FZxgd3lB3ilt37lKVj7lARA9LJ2jJAmtF6PcpWE2RuApvQ2hYb
         5kRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject:dkim-signature;
        bh=HSLvlisSEjMVI0TWIDGbvhFmw9CUylYqc/pMmCcKknE=;
        b=dJalmy4lcZT9M99n/rMo6pzZXZzgLM1Bopt4e64RjBecYajHP6zYthNQOMRihu96pI
         H/8L+Yd6zFHcX+vpUcGmBvt5V/n+iYqYYK2iIgEr0Nq7EbvF/ymvAOxMieDWvaDKLWP3
         ihtUpkXraB0IiPfVG+6SOToXwJ/TWUy6w5euHDMXyxZoXP/mZR9gQ36VzaxGq0N8YOXg
         KucCYwKozWPIvSlMGes2YvIoD7DfVaF+jxnn6rwvROka18/k8ikuC2iBw+UKRffXEVHz
         8o5wobjulxFPtrFoNDVqE45sNxaKjHjeqOEawBpjbeMJKy+T8AEbIng7l3JW099yU+n9
         L4Sw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ozlabs-ru.20150623.gappssmtp.com header.s=20150623 header.b=HTcFkVg3;
       spf=pass (google.com: domain of aik@ozlabs.ru designates 209.85.220.65 as permitted sender) smtp.mailfrom=aik@ozlabs.ru
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u6sor46715101pld.46.2019.04.10.21.22.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Apr 2019 21:22:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of aik@ozlabs.ru designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ozlabs-ru.20150623.gappssmtp.com header.s=20150623 header.b=HTcFkVg3;
       spf=pass (google.com: domain of aik@ozlabs.ru designates 209.85.220.65 as permitted sender) smtp.mailfrom=aik@ozlabs.ru
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ozlabs-ru.20150623.gappssmtp.com; s=20150623;
        h=subject:to:cc:references:from:openpgp:autocrypt:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=HSLvlisSEjMVI0TWIDGbvhFmw9CUylYqc/pMmCcKknE=;
        b=HTcFkVg3K7kmY6O6qox46/sY5gPPi8i12muuthVqt3UedzuPE4Owz/5OVeZVU3vrp6
         0hcOTUBI7gRWaEEX+D5HrLjcytjaLoqTdrSvmBP/iQvd48JHEP9M3eXbh073Wpf1Y70F
         iOi5Qg1Yjf15JUmmLU1A92mqI8INnmuhitpFNlvRMG4Ope+BqpGr/rkTX3fThmsS3D2s
         RuQ5pxQGJDEJAWAou0vEysYjT06427y3zr2wTwjdpJ4tGgaJie+10fdRr0SIBJzqldh1
         jxHReYmV1ofo8pwHb9/CRSf90tLolokdsiIM40zqjwZKTKp5aQ8k84TawT9Ai0+kmL3s
         fzhw==
X-Google-Smtp-Source: APXvYqyVVmFeaU11fKHraPnclXmWQrnDP73emlH/hS/iiUnoLohSQsMUd+tohG1KYkBOyP4wwnZM/A==
X-Received: by 2002:a17:902:9a03:: with SMTP id v3mr23558373plp.27.1554956551126;
        Wed, 10 Apr 2019 21:22:31 -0700 (PDT)
Received: from [10.61.2.175] ([122.99.82.10])
        by smtp.gmail.com with ESMTPSA id n3sm64976997pfa.99.2019.04.10.21.22.25
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 21:22:30 -0700 (PDT)
Subject: Re: [PATCH 1/6] mm: change locked_vm's type from unsigned long to
 atomic64_t
To: Daniel Jordan <daniel.m.jordan@oracle.com>, akpm@linux-foundation.org
Cc: Alan Tull <atull@kernel.org>, Alex Williamson
 <alex.williamson@redhat.com>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Christoph Lameter <cl@linux.com>, Davidlohr Bueso <dave@stgolabs.net>,
 Michael Ellerman <mpe@ellerman.id.au>, Moritz Fischer <mdf@kernel.org>,
 Paul Mackerras <paulus@ozlabs.org>, Wu Hao <hao.wu@intel.com>,
 linux-mm@kvack.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-fpga@vger.kernel.org,
 linux-kernel@vger.kernel.org
References: <20190402204158.27582-1-daniel.m.jordan@oracle.com>
 <20190402204158.27582-2-daniel.m.jordan@oracle.com>
From: Alexey Kardashevskiy <aik@ozlabs.ru>
Openpgp: preference=signencrypt
Autocrypt: addr=aik@ozlabs.ru; keydata=
 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
Message-ID: <614ea07a-dd1e-2561-b6f4-2d698bf55f5b@ozlabs.ru>
Date: Thu, 11 Apr 2019 14:22:23 +1000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190402204158.27582-2-daniel.m.jordan@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 03/04/2019 07:41, Daniel Jordan wrote:
> Taking and dropping mmap_sem to modify a single counter, locked_vm, is
> overkill when the counter could be synchronized separately.
> 
> Make mmap_sem a little less coarse by changing locked_vm to an atomic,
> the 64-bit variety to avoid issues with overflow on 32-bit systems.
> 
> Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
> Cc: Alan Tull <atull@kernel.org>
> Cc: Alexey Kardashevskiy <aik@ozlabs.ru>
> Cc: Alex Williamson <alex.williamson@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Davidlohr Bueso <dave@stgolabs.net>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Cc: Moritz Fischer <mdf@kernel.org>
> Cc: Paul Mackerras <paulus@ozlabs.org>
> Cc: Wu Hao <hao.wu@intel.com>
> Cc: <linux-mm@kvack.org>
> Cc: <kvm@vger.kernel.org>
> Cc: <kvm-ppc@vger.kernel.org>
> Cc: <linuxppc-dev@lists.ozlabs.org>
> Cc: <linux-fpga@vger.kernel.org>
> Cc: <linux-kernel@vger.kernel.org>
> ---
>  arch/powerpc/kvm/book3s_64_vio.c    | 14 ++++++++------
>  arch/powerpc/mm/mmu_context_iommu.c | 15 ++++++++-------
>  drivers/fpga/dfl-afu-dma-region.c   | 18 ++++++++++--------
>  drivers/vfio/vfio_iommu_spapr_tce.c | 17 +++++++++--------
>  drivers/vfio/vfio_iommu_type1.c     | 10 ++++++----
>  fs/proc/task_mmu.c                  |  2 +-
>  include/linux/mm_types.h            |  2 +-
>  kernel/fork.c                       |  2 +-
>  mm/debug.c                          |  5 +++--
>  mm/mlock.c                          |  4 ++--
>  mm/mmap.c                           | 18 +++++++++---------
>  mm/mremap.c                         |  6 +++---
>  12 files changed, 61 insertions(+), 52 deletions(-)
> 
> diff --git a/arch/powerpc/kvm/book3s_64_vio.c b/arch/powerpc/kvm/book3s_64_vio.c
> index f02b04973710..e7fdb6d10eeb 100644
> --- a/arch/powerpc/kvm/book3s_64_vio.c
> +++ b/arch/powerpc/kvm/book3s_64_vio.c
> @@ -59,32 +59,34 @@ static unsigned long kvmppc_stt_pages(unsigned long tce_pages)
>  static long kvmppc_account_memlimit(unsigned long stt_pages, bool inc)
>  {
>  	long ret = 0;
> +	s64 locked_vm;
>  
>  	if (!current || !current->mm)
>  		return ret; /* process exited */
>  
>  	down_write(&current->mm->mmap_sem);
>  
> +	locked_vm = atomic64_read(&current->mm->locked_vm);
>  	if (inc) {
>  		unsigned long locked, lock_limit;
>  
> -		locked = current->mm->locked_vm + stt_pages;
> +		locked = locked_vm + stt_pages;
>  		lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
>  		if (locked > lock_limit && !capable(CAP_IPC_LOCK))
>  			ret = -ENOMEM;
>  		else
> -			current->mm->locked_vm += stt_pages;
> +			atomic64_add(stt_pages, &current->mm->locked_vm);
>  	} else {
> -		if (WARN_ON_ONCE(stt_pages > current->mm->locked_vm))
> -			stt_pages = current->mm->locked_vm;
> +		if (WARN_ON_ONCE(stt_pages > locked_vm))
> +			stt_pages = locked_vm;
>  
> -		current->mm->locked_vm -= stt_pages;
> +		atomic64_sub(stt_pages, &current->mm->locked_vm);
>  	}
>  
>  	pr_debug("[%d] RLIMIT_MEMLOCK KVM %c%ld %ld/%ld%s\n", current->pid,
>  			inc ? '+' : '-',
>  			stt_pages << PAGE_SHIFT,
> -			current->mm->locked_vm << PAGE_SHIFT,
> +			atomic64_read(&current->mm->locked_vm) << PAGE_SHIFT,
>  			rlimit(RLIMIT_MEMLOCK),
>  			ret ? " - exceeded" : "");
>  
> diff --git a/arch/powerpc/mm/mmu_context_iommu.c b/arch/powerpc/mm/mmu_context_iommu.c
> index e7a9c4f6bfca..8038ac24a312 100644
> --- a/arch/powerpc/mm/mmu_context_iommu.c
> +++ b/arch/powerpc/mm/mmu_context_iommu.c
> @@ -55,30 +55,31 @@ static long mm_iommu_adjust_locked_vm(struct mm_struct *mm,
>  		unsigned long npages, bool incr)
>  {
>  	long ret = 0, locked, lock_limit;
> +	s64 locked_vm;
>  
>  	if (!npages)
>  		return 0;
>  
>  	down_write(&mm->mmap_sem);
> -
> +	locked_vm = atomic64_read(&mm->locked_vm);
>  	if (incr) {
> -		locked = mm->locked_vm + npages;
> +		locked = locked_vm + npages;
>  		lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
>  		if (locked > lock_limit && !capable(CAP_IPC_LOCK))
>  			ret = -ENOMEM;
>  		else
> -			mm->locked_vm += npages;
> +			atomic64_add(npages, &mm->locked_vm);
>  	} else {
> -		if (WARN_ON_ONCE(npages > mm->locked_vm))
> -			npages = mm->locked_vm;
> -		mm->locked_vm -= npages;
> +		if (WARN_ON_ONCE(npages > locked_vm))
> +			npages = locked_vm;
> +		atomic64_sub(npages, &mm->locked_vm);
>  	}
>  
>  	pr_debug("[%d] RLIMIT_MEMLOCK HASH64 %c%ld %ld/%ld\n",
>  			current ? current->pid : 0,
>  			incr ? '+' : '-',
>  			npages << PAGE_SHIFT,
> -			mm->locked_vm << PAGE_SHIFT,
> +			atomic64_read(&mm->locked_vm) << PAGE_SHIFT,
>  			rlimit(RLIMIT_MEMLOCK));
>  	up_write(&mm->mmap_sem);
>  
> diff --git a/drivers/fpga/dfl-afu-dma-region.c b/drivers/fpga/dfl-afu-dma-region.c
> index e18a786fc943..08132fd9b6b7 100644
> --- a/drivers/fpga/dfl-afu-dma-region.c
> +++ b/drivers/fpga/dfl-afu-dma-region.c
> @@ -45,6 +45,7 @@ void afu_dma_region_init(struct dfl_feature_platform_data *pdata)
>  static int afu_dma_adjust_locked_vm(struct device *dev, long npages, bool incr)
>  {
>  	unsigned long locked, lock_limit;
> +	s64 locked_vm;
>  	int ret = 0;
>  
>  	/* the task is exiting. */
> @@ -53,24 +54,25 @@ static int afu_dma_adjust_locked_vm(struct device *dev, long npages, bool incr)
>  
>  	down_write(&current->mm->mmap_sem);
>  
> +	locked_vm = atomic64_read(&current->mm->locked_vm);
>  	if (incr) {
> -		locked = current->mm->locked_vm + npages;
> +		locked = locked_vm + npages;
>  		lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
>  
>  		if (locked > lock_limit && !capable(CAP_IPC_LOCK))
>  			ret = -ENOMEM;
>  		else
> -			current->mm->locked_vm += npages;
> +			atomic64_add(npages, &current->mm->locked_vm);
>  	} else {
> -		if (WARN_ON_ONCE(npages > current->mm->locked_vm))
> -			npages = current->mm->locked_vm;
> -		current->mm->locked_vm -= npages;
> +		if (WARN_ON_ONCE(npages > locked_vm))
> +			npages = locked_vm;
> +		atomic64_sub(npages, &current->mm->locked_vm);
>  	}
>  
> -	dev_dbg(dev, "[%d] RLIMIT_MEMLOCK %c%ld %ld/%ld%s\n", current->pid,
> +	dev_dbg(dev, "[%d] RLIMIT_MEMLOCK %c%ld %lld/%lu%s\n", current->pid,
>  		incr ? '+' : '-', npages << PAGE_SHIFT,
> -		current->mm->locked_vm << PAGE_SHIFT, rlimit(RLIMIT_MEMLOCK),
> -		ret ? "- exceeded" : "");
> +		(s64)atomic64_read(&current->mm->locked_vm) << PAGE_SHIFT,
> +		rlimit(RLIMIT_MEMLOCK), ret ? "- exceeded" : "");



atomic64_read() returns "long" which matches "%ld", why this change (and
similar below)? You did not do this in the two pr_debug()s above anyway.


-- 
Alexey

