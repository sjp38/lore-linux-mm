Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D8B3E6B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 11:05:36 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 54so8895541wrz.3
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 08:05:36 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 28si4339806edv.243.2017.10.03.08.05.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Oct 2017 08:05:35 -0700 (PDT)
Subject: Re: [PATCH v9 09/12] mm/kasan: kasan specific map populate function
References: <20170920201714.19817-1-pasha.tatashin@oracle.com>
 <20170920201714.19817-10-pasha.tatashin@oracle.com>
 <20171003144845.GD4931@leverpostej>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <1e2dc0da-5eb8-3160-803a-262a3c506baf@oracle.com>
Date: Tue, 3 Oct 2017 11:04:26 -0400
MIME-Version: 1.0
In-Reply-To: <20171003144845.GD4931@leverpostej>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>, will.deacon@arm.com, catalin.marinas@arm.com
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

Hi Mark,

I considered using a new  *populate() function for shadow without using 
vmemmap_populate(), but that makes things unnecessary complicated: 
vmemmap_populate() has builtin:

1. large page support
2. device memory support
3. node locality support
4. several config based variants on different platforms

All of that  will cause the code simply be duplicated on each platform 
if we want to support that in kasan.

We could limit ourselves to only supporting base pages in memory by 
using something like vmemmap_populate_basepages(), but that is a step 
backward.  Kasan benefits from using large pages now, why remove it?

So, the solution I provide is walking page table right after memory is 
mapped. Since, we are using the actual page table, it is guaranteed that 
we are not going to miss any mapped memory, and also it is in common 
code, which makes things smaller and nicer.

Thank you,
Pasha

On 10/03/2017 10:48 AM, Mark Rutland wrote:
> 
> I've given this a spin on arm64, and can confirm that it works.
> 
> Given that this involes redundant walking of page tables, I still think
> it'd be preferable to have some common *_populate() helper that took a
> gfp argument, but I guess it's not the end of the world.
> 
> I'll leave it to Will and Catalin to say whether they're happy with the
> page table walking and the new p{u,m}d_large() helpers added to arm64.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
