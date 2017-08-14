Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id A288A6B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 09:31:31 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id l132so34026694vke.0
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 06:31:31 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 52si3571966ual.60.2017.08.14.06.31.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 06:31:30 -0700 (PDT)
Subject: Re: [v6 01/15] x86/mm: reserve only exiting low pages
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
 <1502138329-123460-2-git-send-email-pasha.tatashin@oracle.com>
 <20170811080706.GC30811@dhcp22.suse.cz>
 <47ebf53b-ea8b-1822-a63a-3682ed2f4753@oracle.com>
 <20170814114011.GG19063@dhcp22.suse.cz>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <8da779a0-ade4-e43e-3b14-2686e347f8ab@oracle.com>
Date: Mon, 14 Aug 2017 09:30:35 -0400
MIME-Version: 1.0
In-Reply-To: <20170814114011.GG19063@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org

>> Correct, the pgflags asserts were triggered when we were setting reserved
>> flags to struct page for PFN 0 in which was never initialized through
>> __init_single_page(). The reason they were triggered is because we set all
>> uninitialized memory to ones in one of the debug patches.
> 
> And why don't we need the same treatment for other architectures?
> 

I have not seen similar issues on other architectures. At least this low 
memory reserve is x86 specific for BIOS purposes:

Documentation/admin-guide/kernel-parameters.txt
3624	reservelow=	[X86]
3625			Format: nn[K]
3626			Set the amount of memory to reserve for BIOS at
3627			the bottom of the address space.

If there are similar cases with other architectures, they will be caught 
by the last patch in this series, where all allocated memory is set to 
ones, and page flags asserts will be triggered. I have boot-tested on 
SPARC, ARM, and x86.

Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
