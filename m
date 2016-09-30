Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 86E246B0260
	for <linux-mm@kvack.org>; Fri, 30 Sep 2016 05:32:44 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id o68so136871686qkf.2
        for <linux-mm@kvack.org>; Fri, 30 Sep 2016 02:32:44 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id f90si11382438qtb.57.2016.09.30.02.32.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 30 Sep 2016 02:32:44 -0700 (PDT)
Subject: Re: [RFC PATCH 1/1] mm/percpu.c: fix potential memory leakage for
 pcpu_embed_first_chunk()
References: <d6742bae-1b32-10d8-1857-9993a2d06117@zoho.com>
 <20160929164422.GA3773@mtj.duckdns.org>
 <b88da9b0-0964-8b42-7054-81605fe7eb85@zoho.com>
 <20160930084323.GC29207@mtj.duckdns.org>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <cfeaa6dc-16b8-f090-bb2f-531441be4341@zoho.com>
Date: Fri, 30 Sep 2016 17:32:36 +0800
MIME-Version: 1.0
In-Reply-To: <20160930084323.GC29207@mtj.duckdns.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: zijun_hu@htc.com, Andrew Morton <akpm@linux-foundation.org>, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2016/9/30 16:43, Tejun Heo wrote:
> Hello,
> 
> On Fri, Sep 30, 2016 at 01:38:35AM +0800, zijun_hu wrote:
>> 1) the simpler way don't work because it maybe free many memory block twice
> 
> Right, the punched holes.  Forgot about them.  Yeah, that's why the
> later failure just leaks memory.
> 
>> 2) as we seen, pcpu_setup_first_chunk() doesn't cause a failure, it  return 0
>>    always or panic by BUG_ON(), even if it fails, we can conclude the allocated
>>    memory based on information recorded by it, such as pcpu_base_addr and many of
>>    static variable, we can complete the free operations; but we can't if we
>>    fail in the case pointed by this patch
> 
> So, being strictly correct doesn't matter that much here.  These
> things failing indicates that something is very wrong with either the
> code or configuration and we might as well trigger BUG.  That said,
> yeah, it's nicer to recover without leaking anything.
> 
>> 3) my test way is simple, i force "if (max_distance > VMALLOC_TOTAL * 3 / 4)"
>>    to if (1) and print which memory i allocate before the jumping, then print which memory
>>    i free after the jumping and before returning, then check whether i free the memory i 
>>    allocate in this function, the result is okay
> 
> Can you please include what has been discussed into the patch
> description?
> 
> Thanks.
> 
okayi 1/4 ? no problem

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
