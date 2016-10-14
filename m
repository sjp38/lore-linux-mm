Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id E3BD86B0253
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 20:24:46 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id f128so61526431qkb.1
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 17:24:46 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id x64si8122601qkb.136.2016.10.13.17.24.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 13 Oct 2016 17:24:46 -0700 (PDT)
Subject: Re: [RFC PATCH 1/1] mm/percpu.c: fix memory leakage issue when
 allocate a odd alignment area
References: <bc3126cd-226d-91c7-d323-48881095accf@zoho.com>
 <20161013233139.GE32534@mtj.duckdns.org>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <b1b3d53c-b6d9-f888-e123-1b6afe9b2e98@zoho.com>
Date: Fri, 14 Oct 2016 08:23:06 +0800
MIME-Version: 1.0
In-Reply-To: <20161013233139.GE32534@mtj.duckdns.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: zijun_hu@htc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, cl@linux.com

On 2016/10/14 7:31, Tejun Heo wrote:
> On Tue, Oct 11, 2016 at 09:24:50PM +0800, zijun_hu wrote:
>> From: zijun_hu <zijun_hu@htc.com>
>>
>> the LSB of a chunk->map element is used for free/in-use flag of a area
>> and the other bits for offset, the sufficient and necessary condition of
>> this usage is that both size and alignment of a area must be even numbers
>> however, pcpu_alloc() doesn't force its @align parameter a even number
>> explicitly, so a odd @align maybe causes a series of errors, see below
>> example for concrete descriptions.
>>
>> lets assume area [16, 36) is free but its previous one is in-use, we want
>> to allocate a @size == 8 and @align == 7 area. the larger area [16, 36) is
>> split to three areas [16, 21), [21, 29), [29, 36) eventually. however, due
>> to the usage for a chunk->map element, the actual offset of the aim area
>> [21, 29) is 21 but is recorded in relevant element as 20; moreover the
>> residual tail free area [29, 36) is mistook as in-use and is lost silently
>>
>> as explained above, inaccurate either offset or free/in-use state of
>> a area is recorded into relevant chunk->map element if request a odd
>> alignment area, and so causes memory leakage issue
>>
>> fix it by forcing the @align of a area to allocate a even number
>> as do for @size.
>>
>> BTW, macro ALIGN() within pcpu_fit_in_area() is replaced by roundup() too
>> due to back reason. in order to align a value @v up to @a boundary, macro
>> roundup(v, a) is more generic than ALIGN(x, a); the latter doesn't work
>> well when @a isn't a power of 2 value. for example, roundup(10, 6) == 12
>> but ALIGN(10, 6) == 10, the former result is desired obviously
>>
>> Signed-off-by: zijun_hu <zijun_hu@htc.com>
> 
> Nacked-by: Tejun Heo <tj@kernel.org>
> 
> This is a fix for an imaginary problem.  The most we should do about
> odd alignment is triggering a WARN_ON.
> 
for the current code, only power of 2 alignment value can works well

is it acceptable to performing a power of 2 checking and returning error code
if fail?





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
