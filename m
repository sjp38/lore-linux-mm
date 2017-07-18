Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2E0D96B0292
	for <linux-mm@kvack.org>; Tue, 18 Jul 2017 16:04:44 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id v193so26643354itc.10
        for <linux-mm@kvack.org>; Tue, 18 Jul 2017 13:04:44 -0700 (PDT)
Received: from mail-io0-x22d.google.com (mail-io0-x22d.google.com. [2607:f8b0:4001:c06::22d])
        by mx.google.com with ESMTPS id h184si3054587iof.166.2017.07.18.13.04.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jul 2017 13:04:43 -0700 (PDT)
Received: by mail-io0-x22d.google.com with SMTP id e93so2128167ioi.3
        for <linux-mm@kvack.org>; Tue, 18 Jul 2017 13:04:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1edb137c-356f-81d6-4592-f5dfc68e8ea9@linux.com>
References: <1500309907-9357-1-git-send-email-alex.popov@linux.com>
 <20170717175459.GC14983@bombadil.infradead.org> <alpine.DEB.2.20.1707171303230.12109@nuc-kabylake>
 <c86c66c3-29d8-0b04-b4d1-f9f8192d8c4a@linux.com> <CAGXu5jK5j2pSVca9XGJhJ6pnF04p7S=K1Z432nzG2y4LfKhYjg@mail.gmail.com>
 <1edb137c-356f-81d6-4592-f5dfc68e8ea9@linux.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 18 Jul 2017 13:04:42 -0700
Message-ID: <CAGXu5jL0bFpWqUm9d2X7zpTO_CwPp94ywcLYoFyNcLuiwX8qAQ@mail.gmail.com>
Subject: Re: [PATCH 1/1] mm/slub.c: add a naive detection of double free or corruption
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Popov <alex.popov@linux.com>
Cc: Christopher Lameter <cl@linux.com>, Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Tue, Jul 18, 2017 at 12:56 PM, Alexander Popov <alex.popov@linux.com> wrote:
> On 17.07.2017 22:11, Kees Cook wrote:
>> On Mon, Jul 17, 2017 at 12:01 PM, Alexander Popov <alex.popov@linux.com> wrote:
>>> Hello Christopher,
>>>
>>> Thanks for your reply.
>>>
>>> On 17.07.2017 21:04, Christopher Lameter wrote:
>>>> On Mon, 17 Jul 2017, Matthew Wilcox wrote:
>>>>
>>>>> On Mon, Jul 17, 2017 at 07:45:07PM +0300, Alexander Popov wrote:
>>>>>> Add an assertion similar to "fasttop" check in GNU C Library allocator:
>>>>>> an object added to a singly linked freelist should not point to itself.
>>>>>> That helps to detect some double free errors (e.g. CVE-2017-2636) without
>>>>>> slub_debug and KASAN. Testing with hackbench doesn't show any noticeable
>>>>>> performance penalty.
>>>>>
>>>>>>  {
>>>>>> +   BUG_ON(object == fp); /* naive detection of double free or corruption */
>>>>>>     *(void **)(object + s->offset) = fp;
>>>>>>  }
>>>>>
>>>>> Is BUG() the best response to this situation?  If it's a corruption, then
>>>>> yes, but if we spot a double-free, then surely we should WARN() and return
>>>>> without doing anything?
>>>>
>>>> The double free debug checking already does the same thing in a more
>>>> thourough way (this one only checks if the last free was the same
>>>> address). So its duplicating a check that already exists.
>>>
>>> Yes, absolutely. Enabled slub_debug (or KASAN with its quarantine) can detect
>>> more double-free errors. But it introduces much bigger performance penalty and
>>> it's disabled by default.
>>>
>>>> However, this one is always on.
>>>
>>> Yes, I would propose to have this relatively cheap check enabled by default. I
>>> think it will block a good share of double-free errors. Currently it's really
>>> easy to turn such a double-free into use-after-free and exploit it, since, as I
>>> wrote, next two kmalloc() calls return the same address. So we could make
>>> exploiting harder for a relatively low price.
>>>
>>> Christopher, if I change BUG_ON() to VM_BUG_ON(), it will be disabled by default
>>> again, right?
>>
>> Let's merge this with the proposed CONFIG_FREELIST_HARDENED, then the
>> performance change is behind a config, and we gain the rest of the
>> freelist protections at the same time:
>>
>> http://www.openwall.com/lists/kernel-hardening/2017/07/06/1
>
> Hello Kees,
>
> If I change BUG_ON() to VM_BUG_ON(), this check will work at least on Fedora
> since it has CONFIG_DEBUG_VM enabled. Debian based distros have this option
> disabled. Do you like that more than having this check under
> CONFIG_FREELIST_HARDENED?

I think there are two issues: first, this should likely be under
CONFIG_FREELIST_HARDENED since Christoph hasn't wanted to make these
changes enabled by default (if I'm understanding his earlier review
comments to me). The second issue is what to DO when a double-free is
discovered. Is there any way to make it safe/survivable? If not, I
think it should just be BUG_ON(). If it can be made safe, then likely
a WARN_ONCE and do whatever is needed to prevent the double-free.

> If you insist on putting this check under CONFIG_FREELIST_HARDENED, should I
> rebase onto your patch and send again?

That would be preferred for me -- I'd like to have both checks. :)

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
