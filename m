Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DB0D56B002D
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 04:14:53 -0500 (EST)
Received: by vws16 with SMTP id 16so4370453vws.14
        for <linux-mm@kvack.org>; Fri, 11 Nov 2011 01:14:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111109012542.GC5075@redhat.com>
References: <20111031171441.GD3466@redhat.com>
	<1320082040-1190-1-git-send-email-aarcange@redhat.com>
	<alpine.LSU.2.00.1111032318290.2058@sister.anvils>
	<20111104235603.GT18879@redhat.com>
	<CAPQyPG5i87VcnwU5UoKiT6_=tzqO_NOPXFvyEooA1Orbe_ztGQ@mail.gmail.com>
	<20111105013317.GU18879@redhat.com>
	<CAPQyPG5Y1e2dac38OLwZAinWb6xpPMWCya2vTaWLPi9+vp1JXQ@mail.gmail.com>
	<20111107131413.GA18279@suse.de>
	<20111107154235.GE3249@redhat.com>
	<20111107162808.GA3083@suse.de>
	<20111109012542.GC5075@redhat.com>
Date: Fri, 11 Nov 2011 17:14:51 +0800
Message-ID: <CAPQyPG67ZFS8ZV_+HjFyXzN9oPpgWc=MWiw=J5xjKo2iApw_+w@mail.gmail.com>
Subject: Re: [PATCH] mremap: enforce rmap src/dst vma ordering in case of
 vma_merge succeeding in copy_vma
From: Nai Xia <nai.xia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Pawel Sikora <pluto@agmk.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org

On Wed, Nov 9, 2011 at 9:25 AM, Andrea Arcangeli <aarcange@redhat.com> wrot=
e:
> On Mon, Nov 07, 2011 at 04:28:08PM +0000, Mel Gorman wrote:
>> Note that I didn't suddenly turn that ack into a nack although
>
> :)
>
>> =A0 1) A small comment on why we need to call anon_vma_moveto_tail in th=
e
>> =A0 =A0 =A0error path would be nice
>
> I can add that.
>
>> =A0 2) It is unfortunate that we need the faulted_in_anon_vma just
>> =A0 =A0 =A0for a VM_BUG_ON check that only exists for CONFIG_DEBUG_VM
>> =A0 =A0 =A0but not earth shatting
>
> It should be optimized away at build time. It thought it was better
> not to leave that path without a VM_BUG_ON. It should be a slow path
> in the first place (probably we should even mark it unlikely). And
> it's obscure enough that I think a check will clarify things. In the
> common case (i.e. some pte faulted in) that vma_merge on self if it
> succeeds, it couldn't possibly be safe because the vma->vm_pgoff vs
> page->index linearity couldn't be valid for the same vma and the same
> page on two different virtual addresses. So checking for it I think is
> sane. Especially given at some point it was mentioned we could
> optimize away the check all together, so it's a bit of an obscure path
> that the VM_BUG_ON I think will help document (and verify).
>
>> What I said was taking the anon_vma lock may be slower but it was
>> generally easier to understand. I'm happy with the new patch too
>> particularly as it keeps the "ordering game" consistent for fork
>> and mremap but I previously missed move_page_tables in the error
>> path so was worried if there was something else I managed to miss
>> particularly in light of the "Allocating a new vma, copy first and
>> merge later" direction.
>
> I liked that direction a lot. I thought with that we could stick to
> the exact same behavior of fork and not need to reorder stuff. But the
> error path is still in the way, and we've to undo the move in place
> without tearing down the vmas. Plus it would have required to write
> mode code, and the allocation path wouldn't have necessarily been
> faster than a reordering if the list is not huge.
>
>> I'm also prefectly happy with my human meat brain and do not expect
>> to replace it with an aliens.
>
> 8-)
>
> On a totally different but related topic, unmap_mapping_range_tree
> walks the prio tree the same way try_to_unmap_file walks it and if
> truncate can truncate "dst" before "src" then supposedly the
> try_to_unmap_file could miss a migration entry copied into the "child"
> ptep while fork runs too... But I think there is no risk there because
> we don't establish migration ptes there, and we just unmap the
> pagecache, so worst case we'll abort migration if the race trigger and
> we'll retry later. But I wonder what happens if truncate runs against
> fork, if truncate can drop ptes from dst before src (like mremap
> comment says), we could still end up with some pte mapped to the file
> in the ptes of the child, even if the pte was correctly truncated in
> the parent...
>
> Overall I think fork/mremap vs fully_reliable_rmap_walk/truncate
> aren't fundamentally different in relation. If we relay on ordering
> for anon pages in fork it's not adding too much mess to also relay on
> ordering for mremap. If we take the i_mmap_mutex in mremap because we
> can't enforce a order in the prio tree, then we need the i_mmap_mutex
> in fork too (and that's missing). But nothing prevents us to use a
> lock in mreamp and ordering in fork. I think the decision should be
> based more on performance expectations.
>
> So we could add the ordering to mremap (patch posted), and add the
> i_mmap_mutex to fork, or we add the anon_vma lock in both mremap and
> fork, and the i_mmap_lock to fork.
>
> Also note, if we find a way to enforce orderings in the prio tree (not
> sure if it's possible, apparently it's already using list_add_tail
> so..), then we could also remove the i_mmap_lock from mremap and fork.
>

Oh, well, I had thought that for partial remap the src and dst VMA are
inserted as
different prio tree nodes, instead of being list_add_tail linked,
which means they
can not be reordered back and force at all...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
