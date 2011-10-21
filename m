Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 45FAF6B002D
	for <linux-mm@kvack.org>; Fri, 21 Oct 2011 13:21:28 -0400 (EDT)
Received: by vcbfk1 with SMTP id fk1so5217941vcb.14
        for <linux-mm@kvack.org>; Fri, 21 Oct 2011 10:21:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20111021155632.GD4082@suse.de>
References: <201110122012.33767.pluto@agmk.net>
	<alpine.LSU.2.00.1110131547550.1346@sister.anvils>
	<alpine.LSU.2.00.1110131629530.1410@sister.anvils>
	<20111016235442.GB25266@redhat.com>
	<CAPQyPG69WePwar+k0nhwfdW7vv7FjqJBYwKfYm7n5qaPwS-WgQ@mail.gmail.com>
	<20111021155632.GD4082@suse.de>
Date: Sat, 22 Oct 2011 01:21:25 +0800
Message-ID: <CAPQyPG5TWEP+M5PELztKuKXHunipu=MmRTnMsJpyyXvkE32j3Q@mail.gmail.com>
Subject: Re: kernel 3.0: BUG: soft lockup: find_get_pages+0x51/0x110
From: Nai Xia <nai.xia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Pawel Sikora <pluto@agmk.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org

On Fri, Oct 21, 2011 at 11:56 PM, Mel Gorman <mgorman@suse.de> wrote:
> On Thu, Oct 20, 2011 at 05:11:28PM +0800, Nai Xia wrote:
>> On Mon, Oct 17, 2011 at 7:54 AM, Andrea Arcangeli <aarcange@redhat.com> =
wrote:
>> > On Thu, Oct 13, 2011 at 04:30:09PM -0700, Hugh Dickins wrote:
>> >> mremap's down_write of mmap_sem, together with i_mmap_mutex/lock,
>> >> and pagetable locks, were good enough before page migration (with its
>> >> requirement that every migration entry be found) came in; and enough
>> >> while migration always held mmap_sem. =A0But not enough nowadays, whe=
n
>> >> there's memory hotremove and compaction: anon_vma lock is also needed=
,
>> >> to make sure a migration entry is not dodging around behind our back.
>> >
>> > For things like migrate and split_huge_page, the anon_vma layer must
>> > guarantee the page is reachable by rmap walk at all times regardless
>> > if it's at the old or new address.
>> >
>> > This shall be guaranteed by the copy_vma called by move_vma well
>> > before move_page_tables/move_ptes can run.
>> >
>> > copy_vma obviously takes the anon_vma lock to insert the new "dst" vma
>> > into the anon_vma chains structures (vma_link does that). That before
>> > any pte can be moved.
>> >
>> > Because we keep two vmas mapped on both src and dst range, with
>> > different vma->vm_pgoff that is valid for the page (the page doesn't
>> > change its page->index) the page should always find _all_ its pte at
>> > any given time.
>> >
>> > There may be other variables at play like the order of insertion in
>> > the anon_vma chain matches our direction of copy and removal of the
>> > old pte. But I think the double locking of the PT lock should make the
>> > order in the anon_vma chain absolutely irrelevant (the rmap_walk
>> > obviously takes the PT lock too), and furthermore likely the
>> > anon_vma_chain insertion is favorable (the dst vma is inserted last
>> > and checked last). But it shouldn't matter.
>>
>> I happened to be reading these code last week.
>>
>> And I do think this order matters, the reason is just quite similar why =
we
>> need i_mmap_lock in move_ptes():
>> If rmap_walk goes dst--->src, then when it first look into dst, ok, the
>
> You might be right in that the ordering matters. We do link new VMAs at
> the end of the list in anon_vma_chain_list so remove_migrate_ptes should
> be walking from src->dst.
>
> If remove_migrate_pte finds src first, it will remove the pte and the
> correct version will get copied. If move_ptes runs between when
> remove_migrate_ptes moves from src to dst, then the PTE at dst will
> still be correct.
>
>> pte is not there, and it happily skip it and release the PTL.
>> Then just before it look into src, move_ptes() comes in, takes the locks
>> and moves the pte from src to dst. And then when rmap_walk() look
>> into src, =A0it will find an empty pte again. The pte is still there,
>> but rmap_walk() missed it !
>>
>
> I believe the ordering is correct though and protects us in this case.
>
>> IMO, this can really happen in case of vma_merge() succeeding.
>> Imagine that src vma is lately faulted and in anon_vma_prepare()
>> it got a same anon_vma with an existing vma ( named evil_vma )through
>> find_mergeable_anon_vma(). =A0This can potentially make the vma_merge() =
in
>> copy_vma() return with evil_vma on some new relocation request. But src_=
vma
>> is really linked _after_ =A0evil_vma/new_vma/dst_vma.
>> In this way, the ordering protocol =A0of anon_vma chain is broken.
>> This should be a rare case because I think in most cases
>> if two VMAs can reusable_anon_vma() they were already merged.
>>
>> How do you think =A0?
>>
>
> Despite the comments in anon_vma_compatible(), I would expect that VMAs
> that can share an anon_vma from find_mergeable_anon_vma() will also get
> merged. When the new VMA is created, it will be linked in the usual
> manner and the oldest->newest ordering is what is required. That's not
> that important though.
>
> What is important is if mremap is moving src to a dst that is adjacent
> to another anon_vma. If src has never been faulted, it's not an issue
> because there are also no migration PTEs. If src has been faulted, then
> is_mergeable_anon_vma() should fail as anon_vma1 !=3D anon_vma2 and they
> are not compatible. The ordering is preserved and we are still ok.

Hi Mel,

Thanks for input. I agree on _almost_ all your reasoning above.

But there is a tricky series of events I mentioned in
https://lkml.org/lkml/2011/10/21/14

, which, I think, can really lead to anon_vma1 =3D=3D anon_vma2 in this cas=
e.
These events is led by a failure when do_brk() fails on vma_merge() due to
ENOMEM, rare it maybe though, And I am still not sure if there exists
any other corner cases when a "should be merged" VMAs just sit there
side by side
for sth reason -- normally, that does not trigger BUGs, so maybe hard to
 detect in real workload.

Please refer to my link and I think the construction was very clear if I ha=
d not
missed sth subtle.

Thanks,

Nai Xia
>
> All that said, while I don't think there is a problem, I can't convince
> myself 100% of it. Andrea, can you spot a flaw?
>
> --
> Mel Gorman
> SUSE Labs
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
