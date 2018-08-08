Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 65DC06B0003
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 09:16:50 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id t10-v6so905095eds.7
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 06:16:50 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i2-v6si330651edt.286.2018.08.08.06.16.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Aug 2018 06:16:48 -0700 (PDT)
Subject: Re: general protection fault with prefetch_freepointer
From: Vlastimil Babka <vbabka@suse.cz>
References: <333cfb75-1769-c67f-c56f-c9458368751a@molgen.mpg.de>
 <4fcc1694-6c29-8c49-1183-fbfb832bf513@suse.cz>
Message-ID: <cc93080f-2d22-71fe-a1fb-d55d1fcc2441@suse.cz>
Date: Wed, 8 Aug 2018 15:16:46 +0200
MIME-Version: 1.0
In-Reply-To: <4fcc1694-6c29-8c49-1183-fbfb832bf513@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Menzel <pmenzel+linux-mm@molgen.mpg.de>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>, Alex Deucher <alexander.deucher@amd.com>

On 08/08/2018 01:54 PM, Vlastimil Babka wrote:
> Hmm I have looked at the splats in all the bugs you referenced and the
> Code part always has the de-obfuscation XORs. Then in comment 36 of
> [1] jian-hong says the problem disappeared, and in comment 40 posts
> a config that has CONFIG_SLAB_FREELIST_HARDENED disabled. Earlier
> posting of his config has it enabled and confirms the disassembly.
> Very suspicious, huh.

So I'm looking at 2482ddec670f ("mm: add SLUB free list pointer
obfuscation") from Kees, and one suspicious thing is:

before, prefetch_freepointer() was just:

	prefetch(object + s->offset);

after, it is

	if (object)
		prefetch(freelist_dereference(s, object + s->offset));

Where freelist_dereference() is either a simple dereference of address,
when FREELIST_HARDENED is disabled, or adds those XORs when enabled.
However, this had changed the prefetch intention! Previously it just
prefetched the address (object + s->offset), now it *dereferences it*,
optionally changes the value read with those XORs, and then prefetches
the result.

This unintentionally adds a non-prefetching read from (object +
s->offset), which may fault, and wasn't there before. It's safe from
NULL pointers, but not from bogus pointers, and faults that
get_freepointer_safe() prevents. Note that alone doesn't explain why
disabling SLAB_FREELIST_HARDENED would help, as the dereference is there
unconditionally. But IMHO it's a bug in the commit and minimally it
likely has some performance impact.
