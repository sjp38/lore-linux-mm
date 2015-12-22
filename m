Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 49E1682F64
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 14:13:19 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id u7so64122706pfb.1
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 11:13:19 -0800 (PST)
Received: from mail-pf0-x230.google.com (mail-pf0-x230.google.com. [2607:f8b0:400e:c00::230])
        by mx.google.com with ESMTPS id f24si20421495pff.196.2015.12.22.11.13.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Dec 2015 11:13:18 -0800 (PST)
Received: by mail-pf0-x230.google.com with SMTP id u7so64122539pfb.1
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 11:13:18 -0800 (PST)
Subject: Re: [kernel-hardening] [RFC][PATCH 6/7] mm: Add Kconfig option for
 slab sanitization
References: <1450755641-7856-1-git-send-email-laura@labbott.name>
 <1450755641-7856-7-git-send-email-laura@labbott.name>
 <567964F3.2020402@intel.com>
 <alpine.DEB.2.20.1512221023550.2748@east.gentwo.org>
 <567986E7.50107@intel.com>
 <alpine.DEB.2.20.1512221124230.14335@east.gentwo.org>
 <56798851.60906@intel.com>
 <alpine.DEB.2.20.1512221207230.14406@east.gentwo.org>
 <5679943C.1050604@intel.com>
From: Laura Abbott <laura@labbott.name>
Message-ID: <5679A0CB.3060707@labbott.name>
Date: Tue, 22 Dec 2015 11:13:15 -0800
MIME-Version: 1.0
In-Reply-To: <5679943C.1050604@intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Christoph Lameter <cl@linux.com>
Cc: kernel-hardening@lists.openwall.com, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>

On 12/22/15 10:19 AM, Dave Hansen wrote:
> On 12/22/2015 10:08 AM, Christoph Lameter wrote:
>> On Tue, 22 Dec 2015, Dave Hansen wrote:
>>>> Why would you use zeros? The point is just to clear the information right?
>>>> The regular poisoning does that.
>>>
>>> It then allows you to avoid the zeroing at allocation time.
>>
>> Well much of the code is expecting a zeroed object from the allocator and
>> its zeroed at that time. Zeroing makes the object cache hot which is an
>> important performance aspect.
>
> Yes, modifying this behavior has a performance impact.  It absolutely
> needs to be evaluated, and I wouldn't want to speculate too much on how
> good or bad any of the choices are.
>
> Just to reiterate, I think we have 3 real choices here:
>
> 1. Zero at alloc, only when __GFP_ZERO
>     (behavior today)
> 2. Poison at free, also Zero at alloc (when __GFP_ZERO)
>     (this patch's proposed behavior, also what current poisoning does,
>      doubles writes)
> 3. Zero at free, *don't* Zero at alloc (when __GFP_ZERO)
>     (what I'm suggesting, possibly less perf impact vs. #2)
>
>

poisoning with non-zero memory makes it easier to determine that the error
came from accessing the sanitized memory vs. some other case. I don't think
the feature would be as strong if the memory was only zeroed vs. some other
data value.

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
