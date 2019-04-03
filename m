Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7ED3FC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:46:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0CD7A20882
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:46:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="BvcS37mE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0CD7A20882
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9908A6B0292; Wed,  3 Apr 2019 00:46:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 941A66B0294; Wed,  3 Apr 2019 00:46:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7BAD56B0295; Wed,  3 Apr 2019 00:46:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 15AC56B0292
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 00:46:14 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id x9so12214553wrw.20
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 21:46:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=ZS/m1TLRoOU3v0QbBfiJP1QciAlJwQtv1c47Wk5XYOU=;
        b=oKsukQUK9/1O/Iig7/l60qNimm0iWxbCeX7xaFJvrEl6RvhLQiphTL9KGAh6Idcw7q
         yOjP3PNRVCTEfVLbdTDG5tjEVD7I6ANnzO2Mu6jorYR5kCQHume/YfQY7Yw4iEqvUjt1
         BVLFrAJyXWs25mfM/AHME2NAXt/+f6gUQL9/MDcrRArcyrLdUUYTJP7RYTxNXqOBUhfd
         j2oKYxeCKmFM3tfu0OAZAGGdkRBd66+GwUwUQu4jbZf4sCfsaHMggpLoghR6TYQGji8f
         yZv+GF5ye2l3i+FJ8QZXTRGWvUT6wIiqG5mOzCLsSNRC8nbActGA5TTqNoO9XzYeH2eB
         dkvg==
X-Gm-Message-State: APjAAAW7poovwL06CMnJsmXMCTdD52i9YX5GQ8psCNnRTOplgZUc3pTr
	pFRv3ip3BBYy3axkelgJvLc/EUNrnKe+ZuwONDcP4t4tyUA8o2Xn5zZiYur7ELhwkZ6oe/mlzL1
	Yqv7/Mm9vY5BuaGqAsk9uTe5d5H6uXU4ZZZxxY3ZzAaLTzsonzPO1Y/12oluWGqRn6A==
X-Received: by 2002:a7b:c92f:: with SMTP id h15mr399620wml.115.1554266773451;
        Tue, 02 Apr 2019 21:46:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxGN0KyJKSVkV3YyKjC8s6cpRwubJIbOppDLZcjvZ02U8I6KlvBbs9ajEVucA+DrSZRXLfr
X-Received: by 2002:a7b:c92f:: with SMTP id h15mr399571wml.115.1554266772296;
        Tue, 02 Apr 2019 21:46:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554266772; cv=none;
        d=google.com; s=arc-20160816;
        b=Ai1WCd9ioYZxmF9LevtMoXhxUzFF7s3k3k9F/EDXpJwTpx7LcX4JpWRQX9C3ZSfeWy
         er9WmVJ/ejZddquAodadNjpu3l53PfWUbpusD2u89UHKa3zWmUS59tYUwKNWQUF13JKs
         ccb/QUDHsFTu74RFKFQBz6h5THoK0smbmM+0aCabZro2bqdZ/piyurKZ4JDwoUlch+3U
         QSwr5ez5qRO50qY3EHi/JUSB4fCnNOD2/kIQNxC/9ZT1x3D2W0lWt4GyfbKfDC/Vvdvd
         DYAd02mmw2L7xICfq+uGxQM9N3VDulfyLfbGzR08oCUlVLLlQvA5KopvZA/okeG5UTKs
         LiMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=ZS/m1TLRoOU3v0QbBfiJP1QciAlJwQtv1c47Wk5XYOU=;
        b=bWP1dhCKFK2jptPf28V8ntiLsjD/xGTHjWv/wai4+l/V2JVfEOuy8crm4cwVBLTZ8b
         s8rfCcOpsU49wW1TCAJNnAoJDTosvVlMuufybnE9y3Qod5nEwLqANqfCxVEYAXaD1ubi
         uMDafFXgXhFz4XFiUq2LCn9FJTXORo9D19zjBXmrHIn69R3b6E/30niEqm8FWK5CHTwC
         4uNoJg2aSPakbodgtEGBlxY4gNasz+JiphPgyEpRjfMBVrTgiIrEKkil8R7UACVJmBjz
         8aYMPgureXj4xuObVX1Zbcf4avU9QRYf3pny3Yd8ICidWgb/tYTdbBTo2wb1KivXFJoU
         34VA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=BvcS37mE;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id x184si8813921wmg.6.2019.04.02.21.46.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 21:46:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=BvcS37mE;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44YtnZ60d7z9v10F;
	Wed,  3 Apr 2019 06:46:10 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=BvcS37mE; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id F04Yrm2VTFyM; Wed,  3 Apr 2019 06:46:10 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44YtnZ4ffzz9v102;
	Wed,  3 Apr 2019 06:46:10 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1554266770; bh=ZS/m1TLRoOU3v0QbBfiJP1QciAlJwQtv1c47Wk5XYOU=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=BvcS37mEHC9n4WnnJnf18+51ghJ9DXMfyZirYHCNuX6EpddMpO89gv7gl7qUK6pTJ
	 XEa0rOBPsz+pA2X7ZfU9jpYuUpr0ENZHrejqQnK/ZyfJErmygInd7yX5OB6yUdGATH
	 AeYLIMq0g5qshOdiNyCQAUE5QPQC0UzXe5OBzUAE=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 3FF1C8B77E;
	Wed,  3 Apr 2019 06:46:11 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id lcqMMegW4RMD; Wed,  3 Apr 2019 06:46:11 +0200 (CEST)
Received: from PO15451 (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id C6E5F8B754;
	Wed,  3 Apr 2019 06:46:08 +0200 (CEST)
Subject: Re: [PATCH 1/6] mm: change locked_vm's type from unsigned long to
 atomic64_t
To: Daniel Jordan <daniel.m.jordan@oracle.com>, akpm@linux-foundation.org
Cc: Davidlohr Bueso <dave@stgolabs.net>, kvm@vger.kernel.org,
 Alan Tull <atull@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>,
 linux-fpga@vger.kernel.org, linux-kernel@vger.kernel.org,
 kvm-ppc@vger.kernel.org, linux-mm@kvack.org,
 Alex Williamson <alex.williamson@redhat.com>, Moritz Fischer
 <mdf@kernel.org>, Christoph Lameter <cl@linux.com>,
 linuxppc-dev@lists.ozlabs.org, Wu Hao <hao.wu@intel.com>
References: <20190402204158.27582-1-daniel.m.jordan@oracle.com>
 <20190402204158.27582-2-daniel.m.jordan@oracle.com>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Message-ID: <4140911c-8193-010b-e8fc-c8b24ffdf423@c-s.fr>
Date: Wed, 3 Apr 2019 06:46:07 +0200
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190402204158.27582-2-daniel.m.jordan@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



Le 02/04/2019 à 22:41, Daniel Jordan a écrit :
> Taking and dropping mmap_sem to modify a single counter, locked_vm, is
> overkill when the counter could be synchronized separately.
> 
> Make mmap_sem a little less coarse by changing locked_vm to an atomic,
> the 64-bit variety to avoid issues with overflow on 32-bit systems.

Can you elaborate on the above ? Previously it was 'unsigned long', what 
were the issues ? If there was such issues, shouldn't there be a first 
patch moving it from unsigned long to u64 before this atomic64_t change 
? Or at least it should be clearly explain here what the issues are and 
how switching to a 64 bit counter fixes them.

Christophe

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
>   arch/powerpc/kvm/book3s_64_vio.c    | 14 ++++++++------
>   arch/powerpc/mm/mmu_context_iommu.c | 15 ++++++++-------
>   drivers/fpga/dfl-afu-dma-region.c   | 18 ++++++++++--------
>   drivers/vfio/vfio_iommu_spapr_tce.c | 17 +++++++++--------
>   drivers/vfio/vfio_iommu_type1.c     | 10 ++++++----
>   fs/proc/task_mmu.c                  |  2 +-
>   include/linux/mm_types.h            |  2 +-
>   kernel/fork.c                       |  2 +-
>   mm/debug.c                          |  5 +++--
>   mm/mlock.c                          |  4 ++--
>   mm/mmap.c                           | 18 +++++++++---------
>   mm/mremap.c                         |  6 +++---
>   12 files changed, 61 insertions(+), 52 deletions(-)
> 
> diff --git a/arch/powerpc/kvm/book3s_64_vio.c b/arch/powerpc/kvm/book3s_64_vio.c
> index f02b04973710..e7fdb6d10eeb 100644
> --- a/arch/powerpc/kvm/book3s_64_vio.c
> +++ b/arch/powerpc/kvm/book3s_64_vio.c
> @@ -59,32 +59,34 @@ static unsigned long kvmppc_stt_pages(unsigned long tce_pages)
>   static long kvmppc_account_memlimit(unsigned long stt_pages, bool inc)
>   {
>   	long ret = 0;
> +	s64 locked_vm;
>   
>   	if (!current || !current->mm)
>   		return ret; /* process exited */
>   
>   	down_write(&current->mm->mmap_sem);
>   
> +	locked_vm = atomic64_read(&current->mm->locked_vm);
>   	if (inc) {
>   		unsigned long locked, lock_limit;
>   
> -		locked = current->mm->locked_vm + stt_pages;
> +		locked = locked_vm + stt_pages;
>   		lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
>   		if (locked > lock_limit && !capable(CAP_IPC_LOCK))
>   			ret = -ENOMEM;
>   		else
> -			current->mm->locked_vm += stt_pages;
> +			atomic64_add(stt_pages, &current->mm->locked_vm);
>   	} else {
> -		if (WARN_ON_ONCE(stt_pages > current->mm->locked_vm))
> -			stt_pages = current->mm->locked_vm;
> +		if (WARN_ON_ONCE(stt_pages > locked_vm))
> +			stt_pages = locked_vm;
>   
> -		current->mm->locked_vm -= stt_pages;
> +		atomic64_sub(stt_pages, &current->mm->locked_vm);
>   	}
>   
>   	pr_debug("[%d] RLIMIT_MEMLOCK KVM %c%ld %ld/%ld%s\n", current->pid,
>   			inc ? '+' : '-',
>   			stt_pages << PAGE_SHIFT,
> -			current->mm->locked_vm << PAGE_SHIFT,
> +			atomic64_read(&current->mm->locked_vm) << PAGE_SHIFT,
>   			rlimit(RLIMIT_MEMLOCK),
>   			ret ? " - exceeded" : "");
>   
> diff --git a/arch/powerpc/mm/mmu_context_iommu.c b/arch/powerpc/mm/mmu_context_iommu.c
> index e7a9c4f6bfca..8038ac24a312 100644
> --- a/arch/powerpc/mm/mmu_context_iommu.c
> +++ b/arch/powerpc/mm/mmu_context_iommu.c
> @@ -55,30 +55,31 @@ static long mm_iommu_adjust_locked_vm(struct mm_struct *mm,
>   		unsigned long npages, bool incr)
>   {
>   	long ret = 0, locked, lock_limit;
> +	s64 locked_vm;
>   
>   	if (!npages)
>   		return 0;
>   
>   	down_write(&mm->mmap_sem);
> -
> +	locked_vm = atomic64_read(&mm->locked_vm);
>   	if (incr) {
> -		locked = mm->locked_vm + npages;
> +		locked = locked_vm + npages;
>   		lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
>   		if (locked > lock_limit && !capable(CAP_IPC_LOCK))
>   			ret = -ENOMEM;
>   		else
> -			mm->locked_vm += npages;
> +			atomic64_add(npages, &mm->locked_vm);
>   	} else {
> -		if (WARN_ON_ONCE(npages > mm->locked_vm))
> -			npages = mm->locked_vm;
> -		mm->locked_vm -= npages;
> +		if (WARN_ON_ONCE(npages > locked_vm))
> +			npages = locked_vm;
> +		atomic64_sub(npages, &mm->locked_vm);
>   	}
>   
>   	pr_debug("[%d] RLIMIT_MEMLOCK HASH64 %c%ld %ld/%ld\n",
>   			current ? current->pid : 0,
>   			incr ? '+' : '-',
>   			npages << PAGE_SHIFT,
> -			mm->locked_vm << PAGE_SHIFT,
> +			atomic64_read(&mm->locked_vm) << PAGE_SHIFT,
>   			rlimit(RLIMIT_MEMLOCK));
>   	up_write(&mm->mmap_sem);
>   
> diff --git a/drivers/fpga/dfl-afu-dma-region.c b/drivers/fpga/dfl-afu-dma-region.c
> index e18a786fc943..08132fd9b6b7 100644
> --- a/drivers/fpga/dfl-afu-dma-region.c
> +++ b/drivers/fpga/dfl-afu-dma-region.c
> @@ -45,6 +45,7 @@ void afu_dma_region_init(struct dfl_feature_platform_data *pdata)
>   static int afu_dma_adjust_locked_vm(struct device *dev, long npages, bool incr)
>   {
>   	unsigned long locked, lock_limit;
> +	s64 locked_vm;
>   	int ret = 0;
>   
>   	/* the task is exiting. */
> @@ -53,24 +54,25 @@ static int afu_dma_adjust_locked_vm(struct device *dev, long npages, bool incr)
>   
>   	down_write(&current->mm->mmap_sem);
>   
> +	locked_vm = atomic64_read(&current->mm->locked_vm);
>   	if (incr) {
> -		locked = current->mm->locked_vm + npages;
> +		locked = locked_vm + npages;
>   		lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
>   
>   		if (locked > lock_limit && !capable(CAP_IPC_LOCK))
>   			ret = -ENOMEM;
>   		else
> -			current->mm->locked_vm += npages;
> +			atomic64_add(npages, &current->mm->locked_vm);
>   	} else {
> -		if (WARN_ON_ONCE(npages > current->mm->locked_vm))
> -			npages = current->mm->locked_vm;
> -		current->mm->locked_vm -= npages;
> +		if (WARN_ON_ONCE(npages > locked_vm))
> +			npages = locked_vm;
> +		atomic64_sub(npages, &current->mm->locked_vm);
>   	}
>   
> -	dev_dbg(dev, "[%d] RLIMIT_MEMLOCK %c%ld %ld/%ld%s\n", current->pid,
> +	dev_dbg(dev, "[%d] RLIMIT_MEMLOCK %c%ld %lld/%lu%s\n", current->pid,
>   		incr ? '+' : '-', npages << PAGE_SHIFT,
> -		current->mm->locked_vm << PAGE_SHIFT, rlimit(RLIMIT_MEMLOCK),
> -		ret ? "- exceeded" : "");
> +		(s64)atomic64_read(&current->mm->locked_vm) << PAGE_SHIFT,
> +		rlimit(RLIMIT_MEMLOCK), ret ? "- exceeded" : "");
>   
>   	up_write(&current->mm->mmap_sem);
>   
> diff --git a/drivers/vfio/vfio_iommu_spapr_tce.c b/drivers/vfio/vfio_iommu_spapr_tce.c
> index 8dbb270998f4..e7d787e5d839 100644
> --- a/drivers/vfio/vfio_iommu_spapr_tce.c
> +++ b/drivers/vfio/vfio_iommu_spapr_tce.c
> @@ -36,7 +36,8 @@ static void tce_iommu_detach_group(void *iommu_data,
>   
>   static long try_increment_locked_vm(struct mm_struct *mm, long npages)
>   {
> -	long ret = 0, locked, lock_limit;
> +	long ret = 0, lock_limit;
> +	s64 locked;
>   
>   	if (WARN_ON_ONCE(!mm))
>   		return -EPERM;
> @@ -45,16 +46,16 @@ static long try_increment_locked_vm(struct mm_struct *mm, long npages)
>   		return 0;
>   
>   	down_write(&mm->mmap_sem);
> -	locked = mm->locked_vm + npages;
> +	locked = atomic64_read(&mm->locked_vm) + npages;
>   	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
>   	if (locked > lock_limit && !capable(CAP_IPC_LOCK))
>   		ret = -ENOMEM;
>   	else
> -		mm->locked_vm += npages;
> +		atomic64_add(npages, &mm->locked_vm);
>   
>   	pr_debug("[%d] RLIMIT_MEMLOCK +%ld %ld/%ld%s\n", current->pid,
>   			npages << PAGE_SHIFT,
> -			mm->locked_vm << PAGE_SHIFT,
> +			atomic64_read(&mm->locked_vm) << PAGE_SHIFT,
>   			rlimit(RLIMIT_MEMLOCK),
>   			ret ? " - exceeded" : "");
>   
> @@ -69,12 +70,12 @@ static void decrement_locked_vm(struct mm_struct *mm, long npages)
>   		return;
>   
>   	down_write(&mm->mmap_sem);
> -	if (WARN_ON_ONCE(npages > mm->locked_vm))
> -		npages = mm->locked_vm;
> -	mm->locked_vm -= npages;
> +	if (WARN_ON_ONCE(npages > atomic64_read(&mm->locked_vm)))
> +		npages = atomic64_read(&mm->locked_vm);
> +	atomic64_sub(npages, &mm->locked_vm);
>   	pr_debug("[%d] RLIMIT_MEMLOCK -%ld %ld/%ld\n", current->pid,
>   			npages << PAGE_SHIFT,
> -			mm->locked_vm << PAGE_SHIFT,
> +			atomic64_read(&mm->locked_vm) << PAGE_SHIFT,
>   			rlimit(RLIMIT_MEMLOCK));
>   	up_write(&mm->mmap_sem);
>   }
> diff --git a/drivers/vfio/vfio_iommu_type1.c b/drivers/vfio/vfio_iommu_type1.c
> index 73652e21efec..5b2878697286 100644
> --- a/drivers/vfio/vfio_iommu_type1.c
> +++ b/drivers/vfio/vfio_iommu_type1.c
> @@ -270,18 +270,19 @@ static int vfio_lock_acct(struct vfio_dma *dma, long npage, bool async)
>   	if (!ret) {
>   		if (npage > 0) {
>   			if (!dma->lock_cap) {
> +				s64 locked_vm = atomic64_read(&mm->locked_vm);
>   				unsigned long limit;
>   
>   				limit = task_rlimit(dma->task,
>   						RLIMIT_MEMLOCK) >> PAGE_SHIFT;
>   
> -				if (mm->locked_vm + npage > limit)
> +				if (locked_vm + npage > limit)
>   					ret = -ENOMEM;
>   			}
>   		}
>   
>   		if (!ret)
> -			mm->locked_vm += npage;
> +			atomic64_add(npage, &mm->locked_vm);
>   
>   		up_write(&mm->mmap_sem);
>   	}
> @@ -401,6 +402,7 @@ static long vfio_pin_pages_remote(struct vfio_dma *dma, unsigned long vaddr,
>   	long ret, pinned = 0, lock_acct = 0;
>   	bool rsvd;
>   	dma_addr_t iova = vaddr - dma->vaddr + dma->iova;
> +	atomic64_t *locked_vm = &current->mm->locked_vm;
>   
>   	/* This code path is only user initiated */
>   	if (!current->mm)
> @@ -418,7 +420,7 @@ static long vfio_pin_pages_remote(struct vfio_dma *dma, unsigned long vaddr,
>   	 * pages are already counted against the user.
>   	 */
>   	if (!rsvd && !vfio_find_vpfn(dma, iova)) {
> -		if (!dma->lock_cap && current->mm->locked_vm + 1 > limit) {
> +		if (!dma->lock_cap && atomic64_read(locked_vm) + 1 > limit) {
>   			put_pfn(*pfn_base, dma->prot);
>   			pr_warn("%s: RLIMIT_MEMLOCK (%ld) exceeded\n", __func__,
>   					limit << PAGE_SHIFT);
> @@ -445,7 +447,7 @@ static long vfio_pin_pages_remote(struct vfio_dma *dma, unsigned long vaddr,
>   
>   		if (!rsvd && !vfio_find_vpfn(dma, iova)) {
>   			if (!dma->lock_cap &&
> -			    current->mm->locked_vm + lock_acct + 1 > limit) {
> +			    atomic64_read(locked_vm) + lock_acct + 1 > limit) {
>   				put_pfn(pfn, dma->prot);
>   				pr_warn("%s: RLIMIT_MEMLOCK (%ld) exceeded\n",
>   					__func__, limit << PAGE_SHIFT);
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 92a91e7816d8..61da4b24d0e0 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -58,7 +58,7 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
>   	swap = get_mm_counter(mm, MM_SWAPENTS);
>   	SEQ_PUT_DEC("VmPeak:\t", hiwater_vm);
>   	SEQ_PUT_DEC(" kB\nVmSize:\t", total_vm);
> -	SEQ_PUT_DEC(" kB\nVmLck:\t", mm->locked_vm);
> +	SEQ_PUT_DEC(" kB\nVmLck:\t", atomic64_read(&mm->locked_vm));
>   	SEQ_PUT_DEC(" kB\nVmPin:\t", atomic64_read(&mm->pinned_vm));
>   	SEQ_PUT_DEC(" kB\nVmHWM:\t", hiwater_rss);
>   	SEQ_PUT_DEC(" kB\nVmRSS:\t", total_rss);
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 7eade9132f02..5059b99a0827 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -410,7 +410,7 @@ struct mm_struct {
>   		unsigned long hiwater_vm;  /* High-water virtual memory usage */
>   
>   		unsigned long total_vm;	   /* Total pages mapped */
> -		unsigned long locked_vm;   /* Pages that have PG_mlocked set */
> +		atomic64_t    locked_vm;   /* Pages that have PG_mlocked set */
>   		atomic64_t    pinned_vm;   /* Refcount permanently increased */
>   		unsigned long data_vm;	   /* VM_WRITE & ~VM_SHARED & ~VM_STACK */
>   		unsigned long exec_vm;	   /* VM_EXEC & ~VM_WRITE & ~VM_STACK */
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 9dcd18aa210b..56be8cdc7b4a 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -979,7 +979,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
>   	mm->core_state = NULL;
>   	mm_pgtables_bytes_init(mm);
>   	mm->map_count = 0;
> -	mm->locked_vm = 0;
> +	atomic64_set(&mm->locked_vm, 0);
>   	atomic64_set(&mm->pinned_vm, 0);
>   	memset(&mm->rss_stat, 0, sizeof(mm->rss_stat));
>   	spin_lock_init(&mm->page_table_lock);
> diff --git a/mm/debug.c b/mm/debug.c
> index eee9c221280c..b9cd71927d3c 100644
> --- a/mm/debug.c
> +++ b/mm/debug.c
> @@ -136,7 +136,7 @@ void dump_mm(const struct mm_struct *mm)
>   #endif
>   		"mmap_base %lu mmap_legacy_base %lu highest_vm_end %lu\n"
>   		"pgd %px mm_users %d mm_count %d pgtables_bytes %lu map_count %d\n"
> -		"hiwater_rss %lx hiwater_vm %lx total_vm %lx locked_vm %lx\n"
> +		"hiwater_rss %lx hiwater_vm %lx total_vm %lx locked_vm %llx\n"
>   		"pinned_vm %llx data_vm %lx exec_vm %lx stack_vm %lx\n"
>   		"start_code %lx end_code %lx start_data %lx end_data %lx\n"
>   		"start_brk %lx brk %lx start_stack %lx\n"
> @@ -167,7 +167,8 @@ void dump_mm(const struct mm_struct *mm)
>   		atomic_read(&mm->mm_count),
>   		mm_pgtables_bytes(mm),
>   		mm->map_count,
> -		mm->hiwater_rss, mm->hiwater_vm, mm->total_vm, mm->locked_vm,
> +		mm->hiwater_rss, mm->hiwater_vm, mm->total_vm,
> +		(u64)atomic64_read(&mm->locked_vm),
>   		(u64)atomic64_read(&mm->pinned_vm),
>   		mm->data_vm, mm->exec_vm, mm->stack_vm,
>   		mm->start_code, mm->end_code, mm->start_data, mm->end_data,
> diff --git a/mm/mlock.c b/mm/mlock.c
> index 080f3b36415b..e492a155c51a 100644
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -562,7 +562,7 @@ static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
>   		nr_pages = -nr_pages;
>   	else if (old_flags & VM_LOCKED)
>   		nr_pages = 0;
> -	mm->locked_vm += nr_pages;
> +	atomic64_add(nr_pages, &mm->locked_vm);
>   
>   	/*
>   	 * vm_flags is protected by the mmap_sem held in write mode.
> @@ -687,7 +687,7 @@ static __must_check int do_mlock(unsigned long start, size_t len, vm_flags_t fla
>   	if (down_write_killable(&current->mm->mmap_sem))
>   		return -EINTR;
>   
> -	locked += current->mm->locked_vm;
> +	locked += atomic64_read(&current->mm->locked_vm);
>   	if ((locked > lock_limit) && (!capable(CAP_IPC_LOCK))) {
>   		/*
>   		 * It is possible that the regions requested intersect with
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 41eb48d9b527..03576c1d530c 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1339,7 +1339,7 @@ static inline int mlock_future_check(struct mm_struct *mm,
>   	/*  mlock MCL_FUTURE? */
>   	if (flags & VM_LOCKED) {
>   		locked = len >> PAGE_SHIFT;
> -		locked += mm->locked_vm;
> +		locked += atomic64_read(&mm->locked_vm);
>   		lock_limit = rlimit(RLIMIT_MEMLOCK);
>   		lock_limit >>= PAGE_SHIFT;
>   		if (locked > lock_limit && !capable(CAP_IPC_LOCK))
> @@ -1825,7 +1825,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
>   					vma == get_gate_vma(current->mm))
>   			vma->vm_flags &= VM_LOCKED_CLEAR_MASK;
>   		else
> -			mm->locked_vm += (len >> PAGE_SHIFT);
> +			atomic64_add(len >> PAGE_SHIFT, &mm->locked_vm);
>   	}
>   
>   	if (file)
> @@ -2301,7 +2301,7 @@ static int acct_stack_growth(struct vm_area_struct *vma,
>   	if (vma->vm_flags & VM_LOCKED) {
>   		unsigned long locked;
>   		unsigned long limit;
> -		locked = mm->locked_vm + grow;
> +		locked = atomic64_read(&mm->locked_vm) + grow;
>   		limit = rlimit(RLIMIT_MEMLOCK);
>   		limit >>= PAGE_SHIFT;
>   		if (locked > limit && !capable(CAP_IPC_LOCK))
> @@ -2395,7 +2395,7 @@ int expand_upwards(struct vm_area_struct *vma, unsigned long address)
>   				 */
>   				spin_lock(&mm->page_table_lock);
>   				if (vma->vm_flags & VM_LOCKED)
> -					mm->locked_vm += grow;
> +					atomic64_add(grow, &mm->locked_vm);
>   				vm_stat_account(mm, vma->vm_flags, grow);
>   				anon_vma_interval_tree_pre_update_vma(vma);
>   				vma->vm_end = address;
> @@ -2475,7 +2475,7 @@ int expand_downwards(struct vm_area_struct *vma,
>   				 */
>   				spin_lock(&mm->page_table_lock);
>   				if (vma->vm_flags & VM_LOCKED)
> -					mm->locked_vm += grow;
> +					atomic64_add(grow, &mm->locked_vm);
>   				vm_stat_account(mm, vma->vm_flags, grow);
>   				anon_vma_interval_tree_pre_update_vma(vma);
>   				vma->vm_start = address;
> @@ -2796,11 +2796,11 @@ int __do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
>   	/*
>   	 * unlock any mlock()ed ranges before detaching vmas
>   	 */
> -	if (mm->locked_vm) {
> +	if (atomic64_read(&mm->locked_vm)) {
>   		struct vm_area_struct *tmp = vma;
>   		while (tmp && tmp->vm_start < end) {
>   			if (tmp->vm_flags & VM_LOCKED) {
> -				mm->locked_vm -= vma_pages(tmp);
> +				atomic64_sub(vma_pages(tmp), &mm->locked_vm);
>   				munlock_vma_pages_all(tmp);
>   			}
>   
> @@ -3043,7 +3043,7 @@ static int do_brk_flags(unsigned long addr, unsigned long len, unsigned long fla
>   	mm->total_vm += len >> PAGE_SHIFT;
>   	mm->data_vm += len >> PAGE_SHIFT;
>   	if (flags & VM_LOCKED)
> -		mm->locked_vm += (len >> PAGE_SHIFT);
> +		atomic64_add(len >> PAGE_SHIFT, &mm->locked_vm);
>   	vma->vm_flags |= VM_SOFTDIRTY;
>   	return 0;
>   }
> @@ -3115,7 +3115,7 @@ void exit_mmap(struct mm_struct *mm)
>   		up_write(&mm->mmap_sem);
>   	}
>   
> -	if (mm->locked_vm) {
> +	if (atomic64_read(&mm->locked_vm)) {
>   		vma = mm->mmap;
>   		while (vma) {
>   			if (vma->vm_flags & VM_LOCKED)
> diff --git a/mm/mremap.c b/mm/mremap.c
> index e3edef6b7a12..9a4046bb2875 100644
> --- a/mm/mremap.c
> +++ b/mm/mremap.c
> @@ -422,7 +422,7 @@ static unsigned long move_vma(struct vm_area_struct *vma,
>   	}
>   
>   	if (vm_flags & VM_LOCKED) {
> -		mm->locked_vm += new_len >> PAGE_SHIFT;
> +		atomic64_add(new_len >> PAGE_SHIFT, &mm->locked_vm);
>   		*locked = true;
>   	}
>   
> @@ -473,7 +473,7 @@ static struct vm_area_struct *vma_to_resize(unsigned long addr,
>   
>   	if (vma->vm_flags & VM_LOCKED) {
>   		unsigned long locked, lock_limit;
> -		locked = mm->locked_vm << PAGE_SHIFT;
> +		locked = atomic64_read(&mm->locked_vm) << PAGE_SHIFT;
>   		lock_limit = rlimit(RLIMIT_MEMLOCK);
>   		locked += new_len - old_len;
>   		if (locked > lock_limit && !capable(CAP_IPC_LOCK))
> @@ -679,7 +679,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
>   
>   			vm_stat_account(mm, vma->vm_flags, pages);
>   			if (vma->vm_flags & VM_LOCKED) {
> -				mm->locked_vm += pages;
> +				atomic64_add(pages, &mm->locked_vm);
>   				locked = true;
>   				new_addr = addr;
>   			}
> 

