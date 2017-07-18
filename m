Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id EEAB76B0292
	for <linux-mm@kvack.org>; Tue, 18 Jul 2017 15:56:29 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id b127so6835241lfb.3
        for <linux-mm@kvack.org>; Tue, 18 Jul 2017 12:56:29 -0700 (PDT)
Received: from mail-lf0-f68.google.com (mail-lf0-f68.google.com. [209.85.215.68])
        by mx.google.com with ESMTPS id a17si1419087lfc.225.2017.07.18.12.56.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jul 2017 12:56:28 -0700 (PDT)
Received: by mail-lf0-f68.google.com with SMTP id w198so2244555lff.3
        for <linux-mm@kvack.org>; Tue, 18 Jul 2017 12:56:28 -0700 (PDT)
Reply-To: alex.popov@linux.com
Subject: Re: [PATCH 1/1] mm/slub.c: add a naive detection of double free or
 corruption
References: <1500309907-9357-1-git-send-email-alex.popov@linux.com>
 <20170717175459.GC14983@bombadil.infradead.org>
 <alpine.DEB.2.20.1707171303230.12109@nuc-kabylake>
 <c86c66c3-29d8-0b04-b4d1-f9f8192d8c4a@linux.com>
 <CAGXu5jK5j2pSVca9XGJhJ6pnF04p7S=K1Z432nzG2y4LfKhYjg@mail.gmail.com>
From: Alexander Popov <alex.popov@linux.com>
Message-ID: <1edb137c-356f-81d6-4592-f5dfc68e8ea9@linux.com>
Date: Tue, 18 Jul 2017 22:56:23 +0300
MIME-Version: 1.0
In-Reply-To: <CAGXu5jK5j2pSVca9XGJhJ6pnF04p7S=K1Z432nzG2y4LfKhYjg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Christopher Lameter <cl@linux.com>, Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On 17.07.2017 22:11, Kees Cook wrote:
> On Mon, Jul 17, 2017 at 12:01 PM, Alexander Popov <alex.popov@linux.com> wrote:
>> Hello Christopher,
>>
>> Thanks for your reply.
>>
>> On 17.07.2017 21:04, Christopher Lameter wrote:
>>> On Mon, 17 Jul 2017, Matthew Wilcox wrote:
>>>
>>>> On Mon, Jul 17, 2017 at 07:45:07PM +0300, Alexander Popov wrote:
>>>>> Add an assertion similar to "fasttop" check in GNU C Library allocator:
>>>>> an object added to a singly linked freelist should not point to itself.
>>>>> That helps to detect some double free errors (e.g. CVE-2017-2636) without
>>>>> slub_debug and KASAN. Testing with hackbench doesn't show any noticeable
>>>>> performance penalty.
>>>>
>>>>>  {
>>>>> +   BUG_ON(object == fp); /* naive detection of double free or corruption */
>>>>>     *(void **)(object + s->offset) = fp;
>>>>>  }
>>>>
>>>> Is BUG() the best response to this situation?  If it's a corruption, then
>>>> yes, but if we spot a double-free, then surely we should WARN() and return
>>>> without doing anything?
>>>
>>> The double free debug checking already does the same thing in a more
>>> thourough way (this one only checks if the last free was the same
>>> address). So its duplicating a check that already exists.
>>
>> Yes, absolutely. Enabled slub_debug (or KASAN with its quarantine) can detect
>> more double-free errors. But it introduces much bigger performance penalty and
>> it's disabled by default.
>>
>>> However, this one is always on.
>>
>> Yes, I would propose to have this relatively cheap check enabled by default. I
>> think it will block a good share of double-free errors. Currently it's really
>> easy to turn such a double-free into use-after-free and exploit it, since, as I
>> wrote, next two kmalloc() calls return the same address. So we could make
>> exploiting harder for a relatively low price.
>>
>> Christopher, if I change BUG_ON() to VM_BUG_ON(), it will be disabled by default
>> again, right?
> 
> Let's merge this with the proposed CONFIG_FREELIST_HARDENED, then the
> performance change is behind a config, and we gain the rest of the
> freelist protections at the same time:
> 
> http://www.openwall.com/lists/kernel-hardening/2017/07/06/1

Hello Kees,

If I change BUG_ON() to VM_BUG_ON(), this check will work at least on Fedora
since it has CONFIG_DEBUG_VM enabled. Debian based distros have this option
disabled. Do you like that more than having this check under
CONFIG_FREELIST_HARDENED?

If you insist on putting this check under CONFIG_FREELIST_HARDENED, should I
rebase onto your patch and send again?

Best regards,
Alexander

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
