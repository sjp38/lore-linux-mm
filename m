Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0E5366B003D
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 07:30:09 -0400 (EDT)
Received: by wf-out-1314.google.com with SMTP id 25so2776562wfa.11
        for <linux-mm@kvack.org>; Tue, 31 Mar 2009 04:30:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.64.0903311154570.19028@blonde.anvils>
References: <28c262360903310338k20b8eebbncb86baac9b09e54@mail.gmail.com>
	 <Pine.LNX.4.64.0903311154570.19028@blonde.anvils>
Date: Tue, 31 Mar 2009 20:30:35 +0900
Message-ID: <28c262360903310430jc0411fdm5de88476f39bae4c@mail.gmail.com>
Subject: Re: add_to_swap_cache with GFP_ATOMIC ?
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Thanks for quick reply.

On Tue, Mar 31, 2009 at 8:17 PM, Hugh Dickins <hugh@veritas.com> wrote:
> On Tue, 31 Mar 2009, Minchan Kim wrote:
>>
>> I don't know why we should call add_to_swap_cache with GFP_ATOMIC ?
>> Is there a special something for avoiding blocking?
>
> add_to_swap_cache itself does not need to be called with GFP_ATOMIC.
>
> There are three places from which it is called:
>
> read_swap_cache_async (typically used when faulting) masks the
> gfp_mask coming in (typically GFP_HIGHUSER_MOVABLE for the pages
> themselves) to call add_to_swap_cache typically with GFP_KERNEL.
>
> shmem_writepage does call it with GFP_ATOMIC: that's because it's
> holding the shmem_inode's spin_lock while it switches the page between
> file cache and swap cache - IIRC holding page lock isn't quite enough
> for that, because of other cases; but I've not thought that through
> in a long time, we could re-examine if it troubles you.

Yes. My point was that. but I am not sure what are other cases. :(
Now, It don't hurt me but not sure in future.

> The questionable one is add_to_swap (when vmscanning), which calls
> it with __GFP_HIGH|__GFP_NOMEMALLOC|__GFP_NOWARN, i.e. GFP_ATOMIC
> plus __GFP_NOMEMALLOC|__GFP_NOWARN. =C2=A0That one I have wondered
> about from time to time: GFP_NOIO would be the obvious choice,
> that's what swap_writepage will use to allocate bio soon after.
>
> I've been tempted to change it, but afraid to touch that house
> of cards, and afraid of long testing and justification required.
> Would it be safe to drop that __GFP_HIGH? =C2=A0What's the effect of the
> __GFP_NOMEMALLOC (we've layer on layer of tweak this one way because
> we're in the reclaim path so let it eat more, then tweak it the other
> way because we don't want it to eat up _too_ much). =C2=A0I just let it s=
tay.

Sigh.
What a complex thing to change one line.
Thanks for kind explanation.

> Hugh
>



--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
