Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 252B7C742C8
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 14:52:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C74562080A
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 14:52:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C74562080A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 474528E0155; Fri, 12 Jul 2019 10:52:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3D64F8E00DB; Fri, 12 Jul 2019 10:52:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 24FE08E0155; Fri, 12 Jul 2019 10:52:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C5BC88E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 10:52:26 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y24so8059158edb.1
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 07:52:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=Lz8/KFkjzGYulk50ryCD+r9zAoQjGclyVgJMik8OBWo=;
        b=hGjnb6Q3PgYaKWczEHZiaXcEoiSuSpbenepF8kjN/jMZz5B9q7cop180egyKZ+JChf
         Ie9ylmrrZLrXH5kKXRIlLJjYEA/RYWymroSPTsXhJtu/1LTpy4IJm12WHSIO+PLeZ4Zt
         TxQBSzLNVMNaFUJqG2LTuCUqoyNcEy49hq8G0gDwqfcjXK8Ef4QHjoEw9RtKWDw/x/Zl
         DALVPON2gAET0vzygdsjiRvAsAA3QbkZbSNoA1Lk/z37bnk2LcyP2RLwvEcgWn2FW3BG
         LCsHvA1qEnZIzS7Lr9clYxX7ICrebpgKDrhbdL1C+0UdfunqNqkWvNIzXavRHh3vSyYc
         nzFQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vladimir.murzin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vladimir.murzin@arm.com
X-Gm-Message-State: APjAAAVjiPVWJaLEZf9WLK/iQvNr3J/WiEaWde8n6S/V9qURPAVwDSA+
	XmAUV+UMXnRRic+rPUdC0tvrkOblDve7RMRfcFJeLqe4uywqYXhlVaiceHk4fu0jJ/DmBKsuJsw
	eeUjnB0SG0PIFJCqKHuzSRC3DaJ50BLJSRa9cV6o2nLcn6RgzCCXy1y0AGQcUO2vfsg==
X-Received: by 2002:a50:f5f5:: with SMTP id x50mr9537902edm.89.1562943146272;
        Fri, 12 Jul 2019 07:52:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxwpGnU/9ZUw2eQ6bjNS9vIeQh2z3nv1VVGXzdo5i7T8zqYcD8X8pCpFAjOlV4dU9P/L6AY
X-Received: by 2002:a50:f5f5:: with SMTP id x50mr9537841edm.89.1562943145573;
        Fri, 12 Jul 2019 07:52:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562943145; cv=none;
        d=google.com; s=arc-20160816;
        b=m+Vwv2X4nTJZQbVyTJw+vsuLpj0TK7WMu75EdG4BRTyJjqgVckmBcsOXLUg8pFvSGf
         UpFM3w44ZUd/GGhUALl16iq/0B5up+1UBXJi7ZqeXelbiZzeuZ+uApWhgPTb9E0at8QS
         ZIUnN1CoqdUrCG8/aCYGaxbu6bhgl1KXwlzE5IHXPmmCfiecJxnqyw9VTXFVWDDj1yTW
         BPTsbzcZEhhu1AFKBLs8omh2Rbn6+1UYKfQ62NAp0145LY4LBddD9ts8EwILJB8thQU5
         +LmcwMeQEulWGAyxFJNu40oJc/Jt9J8kfRNIa8bep3llybciuWeyLIanYmmPaTenQksw
         UjLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=Lz8/KFkjzGYulk50ryCD+r9zAoQjGclyVgJMik8OBWo=;
        b=wrKanVX2odYzgrF3UpROhcuoe3fjFG/YxWI15Si+Har4eHIFINJg4NRvPDGeY1jvY3
         +SYDEZPYGbaa1yavqFZ9JTIA1jXtp8TWwJuch27v53/yLQ7DYe4uk/bbHFENx8JxTQoJ
         o0cctRa3X+yhbCO/odEgNyaR9wYFkhj13ICeiqms0KkUwyCsh7Em772Bc/sjlVVdZNO2
         u9a40/T+QJhkir+NeNm7VvSrPtz+tzszPiFlBLcoWXuwTBOQEbLC+f3uYxbQeWe/6Ubn
         4BRJWrCFZPuyKY6QVdxi59C0n4JjHiHuZyygxiUOq4+nM1oSL7U9f01TetcpN/JcqJnV
         xI3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vladimir.murzin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vladimir.murzin@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id p11si4655134eju.328.2019.07.12.07.52.25
        for <linux-mm@kvack.org>;
        Fri, 12 Jul 2019 07:52:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of vladimir.murzin@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vladimir.murzin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vladimir.murzin@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 321FD2B;
	Fri, 12 Jul 2019 07:52:24 -0700 (PDT)
Received: from [10.1.34.155] (e110723.arm.com [10.1.34.155])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 306493F59C;
	Fri, 12 Jul 2019 07:52:23 -0700 (PDT)
Subject: Re: [PATCH 17/17] riscv: add nommu support
To: Christoph Hellwig <hch@lst.de>, Palmer Dabbelt <palmer@sifive.com>,
 Paul Walmsley <paul.walmsley@sifive.com>
Cc: Damien Le Moal <damien.lemoal@wdc.com>, linux-riscv@lists.infradead.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190624054311.30256-1-hch@lst.de>
 <20190624054311.30256-18-hch@lst.de>
From: Vladimir Murzin <vladimir.murzin@arm.com>
Message-ID: <7b382b7a-41b6-62a5-02ab-189b3da9df70@arm.com>
Date: Fri, 12 Jul 2019 15:52:21 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190624054311.30256-18-hch@lst.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Christoph,

On 6/24/19 6:43 AM, Christoph Hellwig wrote:
> The kernel runs in M-mode without using page tables, and thus can't run
> bare metal without help from additional firmware.
> 
> Most of the patch is just stubbing out code not needed without page
> tables, but there is an interesting detail in the signals implementation:
> 
>  - The normal RISC-V syscall ABI only implements rt_sigreturn as VDSO
>    entry point, but the ELF VDSO is not supported for nommu Linux.
>    We instead copy the code to call the syscall onto the stack.
> 
> In addition to enabling the nommu code a new defconfig for a small
> kernel image that can run in nommu mode on qemu is also provided, to run
> a kernel in qemu you can use the following command line:
> 
> qemu-system-riscv64 -smp 2 -m 64 -machine virt -nographic \
> 	-kernel arch/riscv/boot/loader \
> 	-drive file=rootfs.ext2,format=raw,id=hd0 \
> 	-device virtio-blk-device,drive=hd0
> 
> Contains contributions from Damien Le Moal <Damien.LeMoal@wdc.com>.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  arch/riscv/Kconfig                      | 24 +++++---
>  arch/riscv/configs/nommu_virt_defconfig | 78 +++++++++++++++++++++++++
>  arch/riscv/include/asm/elf.h            |  4 +-
>  arch/riscv/include/asm/futex.h          |  6 ++
>  arch/riscv/include/asm/io.h             |  4 ++
>  arch/riscv/include/asm/mmu.h            |  3 +
>  arch/riscv/include/asm/page.h           | 12 +++-
>  arch/riscv/include/asm/pgalloc.h        |  2 +
>  arch/riscv/include/asm/pgtable.h        | 38 ++++++++----
>  arch/riscv/include/asm/tlbflush.h       |  7 ++-
>  arch/riscv/include/asm/uaccess.h        |  4 ++
>  arch/riscv/kernel/Makefile              |  3 +-
>  arch/riscv/kernel/entry.S               | 11 ++++
>  arch/riscv/kernel/head.S                |  6 ++
>  arch/riscv/kernel/signal.c              | 17 +++++-
>  arch/riscv/lib/Makefile                 |  8 +--
>  arch/riscv/mm/Makefile                  |  3 +-
>  arch/riscv/mm/cacheflush.c              |  2 +
>  arch/riscv/mm/context.c                 |  2 +
>  arch/riscv/mm/init.c                    |  2 +
>  20 files changed, 200 insertions(+), 36 deletions(-)
>  create mode 100644 arch/riscv/configs/nommu_virt_defconfig
> 

snip...

>  
> diff --git a/arch/riscv/configs/nommu_virt_defconfig b/arch/riscv/configs/nommu_virt_defconfig
> new file mode 100644
> index 000000000000..cf74e179bf90
> --- /dev/null
> +++ b/arch/riscv/configs/nommu_virt_defconfig
> @@ -0,0 +1,78 @@
> +# CONFIG_CPU_ISOLATION is not set
> +CONFIG_LOG_BUF_SHIFT=16
> +CONFIG_PRINTK_SAFE_LOG_BUF_SHIFT=12
> +CONFIG_BLK_DEV_INITRD=y
> +# CONFIG_RD_BZIP2 is not set
> +# CONFIG_RD_LZMA is not set
> +# CONFIG_RD_XZ is not set
> +# CONFIG_RD_LZO is not set
> +# CONFIG_RD_LZ4 is not set
> +CONFIG_CC_OPTIMIZE_FOR_SIZE=y
> +CONFIG_EXPERT=y
> +# CONFIG_SYSFS_SYSCALL is not set
> +# CONFIG_FHANDLE is not set
> +# CONFIG_BASE_FULL is not set
> +# CONFIG_EPOLL is not set
> +# CONFIG_SIGNALFD is not set
> +# CONFIG_TIMERFD is not set
> +# CONFIG_EVENTFD is not set
> +# CONFIG_AIO is not set
> +# CONFIG_IO_URING is not set
> +# CONFIG_ADVISE_SYSCALLS is not set
> +# CONFIG_MEMBARRIER is not set
> +# CONFIG_KALLSYMS is not set
> +# CONFIG_VM_EVENT_COUNTERS is not set
> +# CONFIG_COMPAT_BRK is not set
> +CONFIG_SLOB=y
> +# CONFIG_SLAB_MERGE_DEFAULT is not set
> +# CONFIG_MMU is not set
> +CONFIG_MAXPHYSMEM_2GB=y
> +CONFIG_SMP=y
> +CONFIG_CMDLINE="root=/dev/vda rw earlycon=uart8250,mmio,0x10000000,115200n8 console=ttyS0"
> +CONFIG_CMDLINE_FORCE=y
> +# CONFIG_BLK_DEV_BSG is not set
> +CONFIG_PARTITION_ADVANCED=y
> +# CONFIG_MSDOS_PARTITION is not set
> +# CONFIG_EFI_PARTITION is not set
> +# CONFIG_MQ_IOSCHED_DEADLINE is not set
> +# CONFIG_MQ_IOSCHED_KYBER is not set
> +CONFIG_BINFMT_FLAT=y

IIUC, RISC-V requires stack pointer to be 16 byte aligned, but flat loader would
align stack pointer to max(sizeof(void *), ARCH_SLAB_MINALIGN). So, I think you
might want to define ARCH_SLAB_MINALIGN.

Cheers
Vladimir

