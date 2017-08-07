Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7BE9E6B025F
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 18:23:17 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id v11so1383298oif.2
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 15:23:17 -0700 (PDT)
Received: from mail-io0-x22a.google.com (mail-io0-x22a.google.com. [2607:f8b0:4001:c06::22a])
        by mx.google.com with ESMTPS id s66si5013184oib.468.2017.08.07.15.23.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 15:23:16 -0700 (PDT)
Received: by mail-io0-x22a.google.com with SMTP id g35so7509710ioi.3
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 15:23:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <e0fc8a0a-fa52-e644-1fc2-4e96082858e0@redhat.com>
References: <20170804231002.20362-1-labbott@redhat.com> <alpine.DEB.2.20.1708070936400.17268@nuc-kabylake>
 <559096f0-bf1b-eff1-f0ce-33f53a4df255@redhat.com> <alpine.DEB.2.20.1708071302310.18681@nuc-kabylake>
 <e0fc8a0a-fa52-e644-1fc2-4e96082858e0@redhat.com>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 7 Aug 2017 15:23:15 -0700
Message-ID: <CAGXu5jKsb+7NyKLemdkS4ENtxuQzbaDY2h2DnMEr+=qBqJAJqw@mail.gmail.com>
Subject: Re: [RFC][PATCH] mm/slub.c: Allow poisoning to use the fast path
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Christopher Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>

On Mon, Aug 7, 2017 at 3:00 PM, Laura Abbott <labbott@redhat.com> wrote:
> On 08/07/2017 11:03 AM, Christopher Lameter wrote:
>> On Mon, 7 Aug 2017, Laura Abbott wrote:
>>
>>>> Ok I see that the objects are initialized with poisoning and redzoning but
>>>> I do not see that there is fastpath code to actually check the values
>>>> before the object is reinitialized. Is that intentional or am
>>>> I missing something?
>>>
>>> Yes, that's intentional here. I see the validation as a separate more
>>> expensive feature. I had a crude patch to do some checks for testing
>>> and I know Daniel Micay had an out of tree patch to do some checks
>>> as well.
>>
>> Ok then this patch does nothing? How does this help?
>
> The purpose of this patch is to ensure the poisoning can happen without
> too much penalty. Even if there aren't checks to abort/warn when there
> is a problem, there's still value in ensuring objects are always poisoned.

To clarify, this is desirable to kill exploitation of
exposure-after-free flaws and some classes of use-after-free flaws,
since the contents will have be wiped out after a free. (Verification
of poison is nice, but is expensive compared to the benefit against
these exploits -- and notably doesn't protect against the other
use-after-free attacks where the contents are changed after the next
allocation, which would have passed the poison verification.)

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
