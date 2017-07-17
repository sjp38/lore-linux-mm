Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id A65496B0292
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 15:01:27 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id h63so35595380lfg.4
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 12:01:27 -0700 (PDT)
Received: from mail-lf0-f65.google.com (mail-lf0-f65.google.com. [209.85.215.65])
        by mx.google.com with ESMTPS id 26si7694783ljt.143.2017.07.17.12.01.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jul 2017 12:01:26 -0700 (PDT)
Received: by mail-lf0-f65.google.com with SMTP id t72so13888380lff.0
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 12:01:26 -0700 (PDT)
Reply-To: alex.popov@linux.com
Subject: Re: [PATCH 1/1] mm/slub.c: add a naive detection of double free or
 corruption
References: <1500309907-9357-1-git-send-email-alex.popov@linux.com>
 <20170717175459.GC14983@bombadil.infradead.org>
 <alpine.DEB.2.20.1707171303230.12109@nuc-kabylake>
From: Alexander Popov <alex.popov@linux.com>
Message-ID: <c86c66c3-29d8-0b04-b4d1-f9f8192d8c4a@linux.com>
Date: Mon, 17 Jul 2017 22:01:15 +0300
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1707171303230.12109@nuc-kabylake>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>, Matthew Wilcox <willy@infradead.org>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, keescook@chromium.org

Hello Christopher,

Thanks for your reply.

On 17.07.2017 21:04, Christopher Lameter wrote:
> On Mon, 17 Jul 2017, Matthew Wilcox wrote:
> 
>> On Mon, Jul 17, 2017 at 07:45:07PM +0300, Alexander Popov wrote:
>>> Add an assertion similar to "fasttop" check in GNU C Library allocator:
>>> an object added to a singly linked freelist should not point to itself.
>>> That helps to detect some double free errors (e.g. CVE-2017-2636) without
>>> slub_debug and KASAN. Testing with hackbench doesn't show any noticeable
>>> performance penalty.
>>
>>>  {
>>> +	BUG_ON(object == fp); /* naive detection of double free or corruption */
>>>  	*(void **)(object + s->offset) = fp;
>>>  }
>>
>> Is BUG() the best response to this situation?  If it's a corruption, then
>> yes, but if we spot a double-free, then surely we should WARN() and return
>> without doing anything?
> 
> The double free debug checking already does the same thing in a more
> thourough way (this one only checks if the last free was the same
> address). So its duplicating a check that already exists.

Yes, absolutely. Enabled slub_debug (or KASAN with its quarantine) can detect
more double-free errors. But it introduces much bigger performance penalty and
it's disabled by default.

> However, this one is always on.

Yes, I would propose to have this relatively cheap check enabled by default. I
think it will block a good share of double-free errors. Currently it's really
easy to turn such a double-free into use-after-free and exploit it, since, as I
wrote, next two kmalloc() calls return the same address. So we could make
exploiting harder for a relatively low price.

Christopher, if I change BUG_ON() to VM_BUG_ON(), it will be disabled by default
again, right?

Best regards,
Alexander

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
