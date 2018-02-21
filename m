Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 23C456B0003
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 02:06:18 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id z14so594756wrh.1
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 23:06:18 -0800 (PST)
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id a5si8709184wra.143.2018.02.20.23.06.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Feb 2018 23:06:16 -0800 (PST)
Subject: Re: [PATCH 0/6] DISCONTIGMEM support for PPC32
References: <20180220161424.5421-1-j.neuschaefer@gmx.net>
From: Christophe LEROY <christophe.leroy@c-s.fr>
Message-ID: <193a407d-e6b8-9e29-af47-3d401b6414a0@c-s.fr>
Date: Wed, 21 Feb 2018 08:06:10 +0100
MIME-Version: 1.0
In-Reply-To: <20180220161424.5421-1-j.neuschaefer@gmx.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Jonathan_Neusch=c3=a4fer?= <j.neuschaefer@gmx.net>, linuxppc-dev@lists.ozlabs.org
Cc: Joel Stanley <joel@jms.id.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org



Le 20/02/2018 A  17:14, Jonathan NeuschA?fer a A(C)critA :
> This patchset adds support for DISCONTIGMEM on 32-bit PowerPC. This is
> required to properly support the Nintendo Wii's memory layout, in which
> there are two blocks of RAM and MMIO in the middle.
> 
> Previously, this memory layout was handled by code that joins the two
> RAM blocks into one, reserves the MMIO hole, and permits allocations of
> reserved memory in ioremap. This hack didn't work with resource-based
> allocation (as used for example in the GPIO driver for Wii[1]), however.
> 
> After this patchset, users of the Wii can either select CONFIG_FLATMEM
> to get the old behaviour, or CONFIG_DISCONTIGMEM to get the new
> behaviour.

My question might me stupid, as I don't know PCC64 in deep, but when 
looking at page_is_ram() in arch/powerpc/mm/mem.c, I have the feeling 
the PPC64 implements ram by blocks. Isn't it what you are trying to 
achieve ? Wouldn't it be feasible to map to what's done in PPC64 for PPC32 ?

Christophe

> 
> Some parts of this patchset are probably not ideal (I'm thinking of my
> implementation of pfn_to_nid here), and will require some discussion/
> changes.
> 
> [1]: https://www.spinics.net/lists/devicetree/msg213956.html
> 
> Jonathan NeuschA?fer (6):
>    powerpc/mm/32: Use pfn_valid to check if pointer is in RAM
>    powerpc: numa: Fix overshift on PPC32
>    powerpc: numa: Use the right #ifdef guards around functions
>    powerpc: numa: Restrict fake NUMA enulation to CONFIG_NUMA systems
>    powerpc: Implement DISCONTIGMEM and allow selection on PPC32
>    powerpc: wii: Don't rely on reserved memory hack if DISCONTIGMEM is
>      set
> 
>   arch/powerpc/Kconfig                     |  5 ++++-
>   arch/powerpc/include/asm/mmzone.h        | 21 +++++++++++++++++++++
>   arch/powerpc/mm/numa.c                   | 18 +++++++++++++++---
>   arch/powerpc/mm/pgtable_32.c             |  2 +-
>   arch/powerpc/platforms/embedded6xx/wii.c | 10 +++++++---
>   5 files changed, 48 insertions(+), 8 deletions(-)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
