Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4724D6B02C3
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 14:23:51 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id o132so8574749lfe.7
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 11:23:51 -0700 (PDT)
Received: from mail-lf0-f65.google.com (mail-lf0-f65.google.com. [209.85.215.65])
        by mx.google.com with ESMTPS id m140si8166790lfe.208.2017.07.17.11.23.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jul 2017 11:23:49 -0700 (PDT)
Received: by mail-lf0-f65.google.com with SMTP id z78so13809456lff.2
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 11:23:49 -0700 (PDT)
Reply-To: alex.popov@linux.com
Subject: Re: [PATCH 1/1] mm/slub.c: add a naive detection of double free or
 corruption
References: <1500309907-9357-1-git-send-email-alex.popov@linux.com>
 <20170717175459.GC14983@bombadil.infradead.org>
From: Alexander Popov <alex.popov@linux.com>
Message-ID: <46e2d4b9-94a4-76e3-be25-144f26f74fb6@linux.com>
Date: Mon, 17 Jul 2017 21:23:44 +0300
MIME-Version: 1.0
In-Reply-To: <20170717175459.GC14983@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, keescook@chromium.org

On 17.07.2017 20:54, Matthew Wilcox wrote:
> On Mon, Jul 17, 2017 at 07:45:07PM +0300, Alexander Popov wrote:
>> Add an assertion similar to "fasttop" check in GNU C Library allocator:
>> an object added to a singly linked freelist should not point to itself.
>> That helps to detect some double free errors (e.g. CVE-2017-2636) without
>> slub_debug and KASAN. Testing with hackbench doesn't show any noticeable
>> performance penalty.
> 
>>  {
>> +	BUG_ON(object == fp); /* naive detection of double free or corruption */
>>  	*(void **)(object + s->offset) = fp;
>>  }
> 
> Is BUG() the best response to this situation?  If it's a corruption, then
> yes, but if we spot a double-free, then surely we should WARN() and return
> without doing anything?

Hello Matthew,

Double-free leads to the memory corruption too, since the next two kmalloc()
calls return the same address to their callers. And we can spot it early here.

--
Alexander

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
