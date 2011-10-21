Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7477F6B002D
	for <linux-mm@kvack.org>; Fri, 21 Oct 2011 02:22:40 -0400 (EDT)
Received: by vcbfk1 with SMTP id fk1so4552173vcb.14
        for <linux-mm@kvack.org>; Thu, 20 Oct 2011 23:22:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CANsGZ6a6_q8+88FRV2froBsVEq7GhtKd9fRnB-0M2MD3a7tnSw@mail.gmail.com>
References: <201110122012.33767.pluto@agmk.net>
	<CA+55aFwf75oJ3JJ2aCR8TJJm_oLireD6SDO+43GveVVb8vGw1w@mail.gmail.com>
	<alpine.LSU.2.00.1110191234570.6900@sister.anvils>
	<201110202051.33288.nai.xia@gmail.com>
	<CANsGZ6a6_q8+88FRV2froBsVEq7GhtKd9fRnB-0M2MD3a7tnSw@mail.gmail.com>
Date: Fri, 21 Oct 2011 14:22:37 +0800
Message-ID: <CAPQyPG6d3Sv26SiR6Xj4S5xOOy2DmrwQYO2wAwzrcg=2A0EcMQ@mail.gmail.com>
Subject: Re: kernel 3.0: BUG: soft lockup: find_get_pages+0x51/0x110
From: Nai Xia <nai.xia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: arekm@pld-linux.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, jpiszcz@lucidpixels.com, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Pawel Sikora <pluto@agmk.net>, Andrea Arcangeli <aarcange@redhat.com>

On Fri, Oct 21, 2011 at 2:36 AM, Hugh Dickins <hughd@google.com> wrote:
> I'm travelling at the moment, my brain is not in gear, the source is not =
in
> front of me, and I'm not used to typing on my phone much!=A0 Excuses, exc=
uses
>
> I flip between thinking you are right, and I'm a fool, and thinking you a=
re
> wrong, and I'm still a fool.

Ha, well, human brains are all weak in thoroughly searching racing state sp=
ace,
while automated model checking is still far from applicable to complex
real world
like kernel source. Maybe some day someone will give out a human guided
computer aided tool to help us search the combination of all involved code =
paths
to valid a specific high level logic assertion.


>
> Please work it out with Linus, Andrea and Mel: I may not be able to reply
> for a couple of days - thanks.

OK.

And as a side note. Since I notice that Pawel's workload may include OOM,
I'd like to give an imaginary series of events that may trigger such an bug=
.

1.  do_brk() want to expand a vma, but vma_merge  failed because of
transient  ENOMEM,  but succeeded in creating a new vmas at the boundary.

    vma_a           vma_b
|----------------|---------------------|

2.  page fault in vma_b, gives it a anon_vma, then page fault in vma_a,
it reuses the anon_vma of  vma_b.


3.   vma_a remaps to somewhere irrelevant, a new vma_c is created
and linked by anon_vma_clone(). In the anon_vma chain of vma_b,
vma_c is linked after  vma_b:

    vma_a           vma_b                   vma_c
|----------------|---------------------|   |=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D|

           vma_b                   vma_c
|---------------------|   |=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D|



4.  vma_c remaps back to its original place where vma_a was.
Ok,  vma_merge() in copy_vma() says that this request can be merged
to vma_b, and it returns with vma_b.

5. move_page_tables moves from vma_c to vma_b,  and races with rmap_walk.
The reverse ordering of vma_b and vma_c in anon_vma chain makes
rmap_walk miss an entry in the way I explained.

Well, it seems a very tricky construction, but also seems a possible
thing to me.

Will Linus, Andrea and Mel or any other one please look into my constructio=
n
and judge if it's valid?

Thanks

Nai Xia

>
> Hugh
>
> On Oct 20, 2011 5:51 AM, "Nai Xia" <nai.xia@gmail.com> wrote:
>>
>> On Thursday 20 October 2011 03:42:15 Hugh Dickins wrote:
>> > On Wed, 19 Oct 2011, Linus Torvalds wrote:
>> > > On Wed, Oct 19, 2011 at 12:43 AM, Mel Gorman <mgorman@suse.de> wrote=
:
>> > > >
>> > > > My vote is with the migration change. While there are occasionally
>> > > > patches to make migration go faster, I don't consider it a hot pat=
h.
>> > > > mremap may be used intensively by JVMs so I'd loathe to hurt it.
>> > >
>> > > Ok, everybody seems to like that more, and it removes code rather th=
an
>> > > adds it, so I certainly prefer it too. Pawel, can you test that othe=
r
>> > > patch (to mm/migrate.c) that Hugh posted? Instead of the mremap vma
>> > > locking patch that you already verified for your setup?
>> > >
>> > > Hugh - that one didn't have a changelog/sign-off, so if you could
>> > > write that up, and Pawel's testing is successful, I can apply it...
>> > > Looks like we have acks from both Andrea and Mel.
>> >
>> > Yes, I'm glad to have that input from Andrea and Mel, thank you.
>> >
>> > Here we go. =A0I can't add a Tested-by since Pawel was reporting on th=
e
>> > alternative patch, but perhaps you'll be able to add that in later.
>> >
>> > I may have read too much into Pawel's mail, but it sounded like he
>> > would have expected an eponymous find_get_pages() lockup by now,
>> > and was pleased that this patch appeared to have cured that.
>> >
>> > I've spent quite a while trying to explain find_get_pages() lockup by
>> > a missed migration entry, but I just don't see it: I don't expect this
>> > (or the alternative) patch to do anything to fix that problem. =A0I wo=
n't
>> > mind if it magically goes away, but I expect we'll need more info from
>> > the debug patch I sent Justin a couple of days ago.
>>
>> Hi Hugh,
>>
>> Will you please look into my explanation in my reply to Andrea in this
>> thread
>> and see if it's what you are seeking?
>>
>>
>> Thanks,
>>
>> Nai Xia
>>
>>
>> >
>> > Ah, I'd better send the patch separately as
>> > "[PATCH] mm: fix race between mremap and removing migration entry":
>> > Pawel's "l" makes my old alpine setup choose quoted printable when
>> > I reply to your mail.
>> >
>> > Hugh
>> >
>> > --
>> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> > the body to majordomo@kvack.org. =A0For more info on Linux MM,
>> > see: http://www.linux-mm.org/ .
>> > Fight unfair telecom internet charges in Canada: sign
>> > http://stopthemeter.ca/
>> > Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>> >
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
