Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 76AE96B02AB
	for <linux-mm@kvack.org>; Sat, 31 Jul 2010 05:39:27 -0400 (EDT)
Message-ID: <4C53EF3D.4020403@cs.helsinki.fi>
Date: Sat, 31 Jul 2010 12:39:09 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [S+Q 09/16] [percpu] make allocpercpu usable during early boot
References: <20100625212026.810557229@quilx.com> <20100625212106.384650677@quilx.com> <AANLkTikSzWZme6kioKJ7DJbS0nhYqeDTPas1D9rb_LY-@mail.gmail.com> <alpine.DEB.2.00.1006291043070.16135@router.home> <AANLkTiklCoCe8k3CaYHNK0P86t76RLb2rMUYg2xiE1Rm@mail.gmail.com> <alpine.DEB.2.00.1007060926220.3627@router.home>
In-Reply-To: <alpine.DEB.2.00.1007060926220.3627@router.home>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org, tj@kernel.org, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>, David Rientjes <rientjes@google.com>, torvalds@linux-foundation.org, benh@kernel.crashing.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Thu, 1 Jul 2010, Pekka Enberg wrote:
> 
>>> On Mon, 28 Jun 2010, Pekka Enberg wrote:
>>>>> +               return kzalloc(size, GFP_KERNEL & gfp_allowed_mask);
>>>>>        else {
>>>>>                void *ptr = vmalloc(size);
>>>>>                if (ptr)
>>>> This looks wrong to me. All slab allocators should do gfp_allowed_mask
>>>> magic under the hood. Maybe it's triggering kmalloc_large() path that
>>>> needs the masking too?
>> On Tue, Jun 29, 2010 at 6:45 PM, Christoph Lameter
>> <cl@linux-foundation.org> wrote:
>>> They do gfp_allowed_mask magic. But the checks at function entry of the
>>> slabs do not mask the masks so we get false positives without this. All my
>>> protest against the checks doing it this IMHO broken way were ignored.
>> Which checks are those? Are they in SLUB proper or are they introduced
>> in one of the SLEB patches? We definitely don't want to expose
>> gfp_allowed_mask here.
> 
> Argh. The reason for the trouble here is because I moved the
> masking of the gfp flags out of the hot path.
> 
> The masking of the bits adds to the cache footprint of the hotpaths now in
> all slab allocators. Gosh. Why is there constant contamination of the hot
> paths with the stuff?

We should definitely move gfp_allowed_mask masking out of fast-paths. I 
think the ideal solution is to only do it deep in the page allocator.

> We only need this masking in the hot path if the debugging hooks need it.
> Otherwise its fine to defer this to the slow paths.
> 
> So how do I get that in there? Add "& gfp_allowed_mask" to the gfp mask
> passed to the debugging hooks?
> 
> Or add a debug_hooks_alloc() function and make it empty if no debugging
> functions are enabled?

I think it's best to have separate debugging hooks that are empty if 
debugging is disabled, yes.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
