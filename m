Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 840FD8E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 12:23:15 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id f22-v6so900549lja.7
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 09:23:15 -0800 (PST)
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id w24-v6si3669116ljj.69.2019.01.15.09.23.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 09:23:13 -0800 (PST)
Subject: Re: [PATCH v3 3/3] powerpc/32: Add KASAN support
References: <cover.1547289808.git.christophe.leroy@c-s.fr>
 <935f9f83393affb5d55323b126468ecb90373b88.1547289808.git.christophe.leroy@c-s.fr>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <e4b343fa-702b-294f-7741-bb85ed877cdf@virtuozzo.com>
Date: Tue, 15 Jan 2019 20:23:35 +0300
MIME-Version: 1.0
In-Reply-To: <935f9f83393affb5d55323b126468ecb90373b88.1547289808.git.christophe.leroy@c-s.fr>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christophe Leroy <christophe.leroy@c-s.fr>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org



On 1/12/19 2:16 PM, Christophe Leroy wrote:

> +KASAN_SANITIZE_early_32.o := n
> +KASAN_SANITIZE_cputable.o := n
> +KASAN_SANITIZE_prom_init.o := n
> +

Usually it's also good idea to disable branch profiling - define DISABLE_BRANCH_PROFILING
either in top of these files or via Makefile. Branch profiling redefines if() statement and calls
instrumented ftrace_likely_update in every if().



> diff --git a/arch/powerpc/mm/kasan_init.c b/arch/powerpc/mm/kasan_init.c
> new file mode 100644
> index 000000000000..3edc9c2d2f3e

> +void __init kasan_init(void)
> +{
> +	struct memblock_region *reg;
> +
> +	for_each_memblock(memory, reg)
> +		kasan_init_region(reg);
> +
> +	pr_info("KASAN init done\n");

Without "init_task.kasan_depth = 0;" kasan will not repot bugs.

There is test_kasan module. Make sure that it produce reports.
