Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 33E2C6B0036
	for <linux-mm@kvack.org>; Tue, 26 Aug 2014 12:58:46 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id eu11so23768862pac.18
        for <linux-mm@kvack.org>; Tue, 26 Aug 2014 09:58:45 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id bx4si5008822pab.174.2014.08.26.09.58.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Aug 2014 09:58:44 -0700 (PDT)
Message-ID: <53FCBCC3.5040901@codeaurora.org>
Date: Tue, 26 Aug 2014 09:58:43 -0700
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCHv7 3/5] common: dma-mapping: Introduce common remapping
 functions
References: <1407800431-21566-1-git-send-email-lauraa@codeaurora.org>	<1407800431-21566-4-git-send-email-lauraa@codeaurora.org> <CAAG0J99=wrz4+c49HeDvL0W9rDZKk2HNLdVtHv4ZJxU4-OjewA@mail.gmail.com>
In-Reply-To: <CAAG0J99=wrz4+c49HeDvL0W9rDZKk2HNLdVtHv4ZJxU4-OjewA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Hogan <james.hogan@imgtec.com>, Catalin Marinas <catalin.marinas@arm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Will Deacon <will.deacon@arm.com>, Russell King <linux@arm.linux.org.uk>, David Riley <davidriley@chromium.org>, ARM Kernel List <linux-arm-kernel@lists.infradead.org>, Ritesh Harjain <ritesh.harjani@gmail.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thierry Reding <thierry.reding@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-next@vger.kernel.org

On 8/26/2014 3:05 AM, James Hogan wrote:
> On 12 August 2014 00:40, Laura Abbott <lauraa@codeaurora.org> wrote:
>>
>> For architectures without coherent DMA, memory for DMA may
>> need to be remapped with coherent attributes. Factor out
>> the the remapping code from arm and put it in a
>> common location to reduce code duplication.
>>
>> As part of this, the arm APIs are now migrated away from
>> ioremap_page_range to the common APIs which use map_vm_area for remapping.
>> This should be an equivalent change and using map_vm_area is more
>> correct as ioremap_page_range is intended to bring in io addresses
>> into the cpu space and not regular kernel managed memory.
>>
>> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
>> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
> 
> This commit in linux-next () breaks the build for metag:
> 
> drivers/base/dma-mapping.c: In function a??dma_common_contiguous_remapa??:
> drivers/base/dma-mapping.c:294: error: implicit declaration of
> function a??dma_common_pages_remapa??
> drivers/base/dma-mapping.c:294: warning: assignment makes pointer from
> integer without a cast
> drivers/base/dma-mapping.c: At top level:
> drivers/base/dma-mapping.c:308: error: conflicting types for
> a??dma_common_pages_remapa??
> drivers/base/dma-mapping.c:294: error: previous implicit declaration
> of a??dma_common_pages_remapa?? was here
> 
> Looks like metag isn't alone either:
> 
> $ git grep -L dma-mapping-common arch/*/include/asm/dma-mapping.h
> arch/arc/include/asm/dma-mapping.h
> arch/avr32/include/asm/dma-mapping.h
> arch/blackfin/include/asm/dma-mapping.h
> arch/c6x/include/asm/dma-mapping.h
> arch/cris/include/asm/dma-mapping.h
> arch/frv/include/asm/dma-mapping.h
> arch/m68k/include/asm/dma-mapping.h
> arch/metag/include/asm/dma-mapping.h
> arch/mn10300/include/asm/dma-mapping.h
> arch/parisc/include/asm/dma-mapping.h
> arch/xtensa/include/asm/dma-mapping.h
> 
> I've checked a couple of these arches (blackfin, xtensa) which don't
> include dma-mapping-common.h and their builds seem to be broken too.
> 
> Cheers
> James
> 

Thanks for the report. Would you mind giving the following patch
a test (this is theoretical only but I think it should work)

-----8<------
