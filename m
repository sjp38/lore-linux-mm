Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 4B3D46B0032
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 12:51:38 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id fa1so54981978pad.8
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 09:51:38 -0800 (PST)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id rq5si14604207pab.43.2015.01.30.09.51.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Fri, 30 Jan 2015 09:51:37 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NJ000GMS4GK6JB0@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 30 Jan 2015 17:55:32 +0000 (GMT)
Message-id: <54CBC49C.5080503@samsung.com>
Date: Fri, 30 Jan 2015 20:51:24 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v10 13/17] mm: vmalloc: add flag preventing guard hole
 allocation
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1422544321-24232-1-git-send-email-a.ryabinin@samsung.com>
 <1422544321-24232-14-git-send-email-a.ryabinin@samsung.com>
 <20150129151254.edc75e5ae20c3cafb55d88b1@linux-foundation.org>
In-reply-to: <20150129151254.edc75e5ae20c3cafb55d88b1@linux-foundation.org>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org

On 01/30/2015 02:12 AM, Andrew Morton wrote:
> On Thu, 29 Jan 2015 18:11:57 +0300 Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
> 
>> For instrumenting global variables KASan will shadow memory
>> backing memory for modules. So on module loading we will need
>> to allocate shadow memory and map it at exact virtual address.
> 
> I don't understand.  What does "map it at exact virtual address" mean?
> 

I mean that if module_alloc() returned address x, than
shadow memory should be mapped exactly at address kasan_mem_to_shadow(x).

>> __vmalloc_node_range() seems like the best fit for that purpose,
>> except it puts a guard hole after allocated area.
> 
> Why is the guard hole a problem?
> 

Because of guard hole in shadow some future allocations of shadow memory
will fail. Requested address ( kasan_mem_to_shadow(x) ) will be already occupied
by guard hole of previous allocation.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
