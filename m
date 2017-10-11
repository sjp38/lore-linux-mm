Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2A8B96B0253
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 09:32:13 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id r129so870818lff.7
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 06:32:13 -0700 (PDT)
Received: from forwardcorp1j.cmail.yandex.net (forwardcorp1j.cmail.yandex.net. [2a02:6b8:0:1630::180])
        by mx.google.com with ESMTPS id u67si222819lja.465.2017.10.11.06.32.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Oct 2017 06:32:11 -0700 (PDT)
Subject: Re: [PATCH] vmalloc: add __alloc_vm_area() for optimizing vmap stack
References: <150728974697.743944.5376694940133890044.stgit@buzz>
 <20171008091654.GA29939@infradead.org>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <a7dd5f4e-5a63-3129-4b42-924ae2166d36@yandex-team.ru>
Date: Wed, 11 Oct 2017 16:32:10 +0300
MIME-Version: 1.0
In-Reply-To: <20171008091654.GA29939@infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@kernel.org>

On 08.10.2017 12:16, Christoph Hellwig wrote:
> This looks fine in general, but a few comments:
> 
>   - can you split adding the new function from switching over the fork
>     codeok

>   - at least kasan and vmalloc_user/vmalloc_32_user use very similar
>     patterns, can you switch them over as well?

I don't see why VM_USERMAP cannot be set right at allocation.

I'll add vm_flags argument to __vmalloc_node() and
pass here VM_USERMAP from vmalloc_user/vmalloc_32_user
in separate patch.

KASAN is different: it allocates shadow area for area allocated for module.
Pointer to module area must be pushed from module_alloc().
This isn't worth optimization.

>   - the new __alloc_vm_area looks very different from alloc_vm_area,
>     maybe it needs a better name?  vmalloc_range_area for example?

__vmalloc_area() is vacant - this most low-level, so I'll keep "__".

>   - when you split an existing function please keep the more low-level
>     function on top of the higher level one that calls it.ok

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
