Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id E85436B0038
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 12:52:06 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id k69so5366596ioi.13
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 09:52:06 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50118.outbound.protection.outlook.com. [40.107.5.118])
        by mx.google.com with ESMTPS id 1si9043075iov.315.2017.10.18.09.52.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 18 Oct 2017 09:52:04 -0700 (PDT)
Subject: Re: [PATCH v12 08/11] arm64/kasan: add and use kasan_map_populate()
References: <20171013173214.27300-1-pasha.tatashin@oracle.com>
 <20171013173214.27300-9-pasha.tatashin@oracle.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <0ae84532-8dcb-10aa-9d69-79d7025b089e@virtuozzo.com>
Date: Wed, 18 Oct 2017 19:55:02 +0300
MIME-Version: 1.0
In-Reply-To: <20171013173214.27300-9-pasha.tatashin@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, akpm@linux-foundation.org, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

On 10/13/2017 08:32 PM, Pavel Tatashin wrote:
> During early boot, kasan uses vmemmap_populate() to establish its shadow
> memory. But, that interface is intended for struct pages use.
> 
> Because of the current project, vmemmap won't be zeroed during allocation,
> but kasan expects that memory to be zeroed. We are adding a new
> kasan_map_populate() function to resolve this difference.
> 
> Therefore, we must use a new interface to allocate and map kasan shadow
> memory, that also zeroes memory for us.
> 

What's the point of this patch? We have "arm64: kasan: Avoid using vmemmap_populate to initialise shadow"
which does the right thing and basically reverts this patch.
This patch as intermediate step looks absolutely useless. We can just avoid vemmap_populate() right away.

> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> ---
>  arch/arm64/mm/kasan_init.c | 72 ++++++++++++++++++++++++++++++++++++++++++----
>  1 file changed, 66 insertions(+), 6 deletions(-)
> 
> diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
> index 81f03959a4ab..cb4af2951c90 100644
> --- a/arch/arm64/mm/kasan_init.c
> +++ b/arch/arm64/mm/kasan_init.c
> @@ -28,6 +28,66 @@
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
