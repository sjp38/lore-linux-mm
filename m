Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 51702828DE
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 20:23:05 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id yy13so180038986pab.3
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 17:23:05 -0800 (PST)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id jh7si12675186pac.115.2016.01.07.17.23.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jan 2016 17:23:04 -0800 (PST)
Received: by mail-pa0-x22b.google.com with SMTP id cy9so272591632pac.0
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 17:23:04 -0800 (PST)
Subject: Re: [RFC][PATCH 0/7] Sanitization of slabs based on grsecurity/PaX
References: <1450755641-7856-1-git-send-email-laura@labbott.name>
 <alpine.DEB.2.20.1512220952350.2114@east.gentwo.org>
 <5679ACE9.70701@labbott.name>
 <CAGXu5jJQKaA1qgLEV9vXEVH4QBC__Vg141BX22ZsZzW6p9yk4Q@mail.gmail.com>
 <568C8741.4040709@labbott.name>
 <alpine.DEB.2.20.1601071020570.28979@east.gentwo.org>
From: Laura Abbott <laura@labbott.name>
Message-ID: <568F0F75.4090101@labbott.name>
Date: Thu, 7 Jan 2016 17:23:01 -0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1601071020570.28979@east.gentwo.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Kees Cook <keescook@chromium.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On 1/7/16 8:26 AM, Christoph Lameter wrote:
> On Tue, 5 Jan 2016, Laura Abbott wrote:
>
>> It's not the poisoning per se that's incompatible, it's how the poisoning is
>> set up. At least for slub, the current poisoning is part of SLUB_DEBUG which
>> enables other consistency checks on the allocator. Trying to pull out just
>> the poisoning for use when SLUB_DEBUG isn't on would result in roughly what
>> would be here anyway. I looked at trying to reuse some of the existing
>> poisoning
>> and came to the conclusion it was less intrusive to the allocator to keep it
>> separate.
>
> SLUB_DEBUG does *not* enable any debugging features. It builds the logic
> for debugging into the kernel but does not activate it. CONFIG_SLUB_DEBUG
> is set for production kernels. The poisoning is build in by default into
> any recent linux kernel out there. You can enable poisoning selectively
> (and no other debug feature) by specifying slub_debug=P on the Linux
> kernel command line right now.
>
> There is a SLAB_POISON flag for each kmem_cache that can be set to
> *only* enable poisoning and nothing else from code.
>
>

The slub_debug=P not only poisons it enables other consistency checks on the
slab as well, assuming my understanding of what check_object does is correct.
My hope was to have the poison part only and none of the consistency checks in
an attempt to mitigate performance issues. I misunderstood when the checks
actually run and how SLUB_DEBUG was used.

Another option would be to have a flag like SLAB_NO_SANITY_CHECK.
sanitization enablement would just be that and SLAB_POISON
in the debug options. The disadvantage to this approach would be losing
the sanitization for ->ctor caches (the grsecurity version works around this
by re-initializing with ->ctor, I haven't heard any feedback if this actually
acceptable) and not having some of the fast paths enabled
(assuming I'm understanding the code path correctly.) which would also
be a performance penalty

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
