Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 4619B6B0005
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 22:35:11 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id n128so15615399pfn.3
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 19:35:11 -0800 (PST)
Received: from mail-pf0-x233.google.com (mail-pf0-x233.google.com. [2607:f8b0:400e:c00::233])
        by mx.google.com with ESMTPS id v25si59532411pfa.157.2016.01.20.19.35.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jan 2016 19:35:09 -0800 (PST)
Received: by mail-pf0-x233.google.com with SMTP id 65so15665663pff.2
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 19:35:08 -0800 (PST)
Subject: Re: [RFC][PATCH 0/7] Sanitization of slabs based on grsecurity/PaX
References: <1450755641-7856-1-git-send-email-laura@labbott.name>
 <alpine.DEB.2.20.1512220952350.2114@east.gentwo.org>
 <5679ACE9.70701@labbott.name>
 <CAGXu5jJQKaA1qgLEV9vXEVH4QBC__Vg141BX22ZsZzW6p9yk4Q@mail.gmail.com>
 <568C8741.4040709@labbott.name>
 <alpine.DEB.2.20.1601071020570.28979@east.gentwo.org>
 <568F0F75.4090101@labbott.name>
 <alpine.DEB.2.20.1601080806020.4128@east.gentwo.org>
 <56971AE1.1020706@labbott.name>
From: Laura Abbott <laura@labbott.name>
Message-ID: <56A051EA.8080003@labbott.name>
Date: Wed, 20 Jan 2016 19:35:06 -0800
MIME-Version: 1.0
In-Reply-To: <56971AE1.1020706@labbott.name>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Kees Cook <keescook@chromium.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On 1/13/16 7:49 PM, Laura Abbott wrote:
> On 1/8/16 6:07 AM, Christoph Lameter wrote:
>> On Thu, 7 Jan 2016, Laura Abbott wrote:
>>
>>> The slub_debug=P not only poisons it enables other consistency checks on the
>>> slab as well, assuming my understanding of what check_object does is correct.
>>> My hope was to have the poison part only and none of the consistency checks in
>>> an attempt to mitigate performance issues. I misunderstood when the checks
>>> actually run and how SLUB_DEBUG was used.
>>
>> Ok I see that there pointer check is done without checking the
>> corresponding debug flag. Patch attached thar fixes it.
>>
>>> Another option would be to have a flag like SLAB_NO_SANITY_CHECK.
>>> sanitization enablement would just be that and SLAB_POISON
>>> in the debug options. The disadvantage to this approach would be losing
>>> the sanitization for ->ctor caches (the grsecurity version works around this
>>> by re-initializing with ->ctor, I haven't heard any feedback if this actually
>>> acceptable) and not having some of the fast paths enabled
>>> (assuming I'm understanding the code path correctly.) which would also
>>> be a performance penalty
>>
>> I think we simply need to fix the missing check there. There is already a
>> flag SLAB_DEBUG_FREE for the pointer checks.
>>
>>
>
> The patch improves performance but the overall performance of these full
> sanitization patches is still significantly better than slub_debug=P. I'll
> put some effort into seeing if I can figure out where the slow down is
> coming from.
>

There are quite a few other checks which need to be skipped over as well,
but I don't think skipping those are going to be sufficient to give an
acceptable performance; a quick 'hackbench -g 20 -l 1000' shows at least
a 3.5 second difference between just skipping all the checks+slab_debug=P
and this series.

The SLAB_DEBUG flags force everything to skip the CPU caches which is
causing the slow down. I experimented with allowing the debugging to
happen with CPU caches but I'm not convinced it's possible to do the
checking on the fast path in a consistent manner without adding
locking. Is it worth refactoring the debugging to be able to be used
on cpu caches or should I take the approach here of having the clear
be separate from free_debug_processing?

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
