Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4B92B6B0087
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 20:43:10 -0500 (EST)
Received: by iwn1 with SMTP id 1so783792iwn.37
        for <linux-mm@kvack.org>; Tue, 07 Dec 2010 17:43:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101208095642.8128ab33.kamezawa.hiroyu@jp.fujitsu.com>
References: <cover.1291568905.git.minchan.kim@gmail.com>
	<d57730effe4b48012d31ceca07938ed3eb401aba.1291568905.git.minchan.kim@gmail.com>
	<20101207144923.GB2356@cmpxchg.org>
	<20101207150710.GA26613@barrios-desktop>
	<20101207151939.GF2356@cmpxchg.org>
	<20101207152625.GB608@barrios-desktop>
	<20101207155645.GG2356@cmpxchg.org>
	<AANLkTi=iNGT_p_VfW9GxdaKXLt2xBHM2jdwmCbF_u8uh@mail.gmail.com>
	<20101208095642.8128ab33.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 8 Dec 2010 10:43:08 +0900
Message-ID: <AANLkTimtkb7Nczhads4u3r21RJauZvviLFkXjaL1ErDb@mail.gmail.com>
Subject: Re: [PATCH v4 2/7] deactivate invalidated pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Hi Kame,

On Wed, Dec 8, 2010 at 9:56 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Wed, 8 Dec 2010 07:51:25 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> On Wed, Dec 8, 2010 at 12:56 AM, Johannes Weiner <hannes@cmpxchg.org> wr=
ote:
>> > On Wed, Dec 08, 2010 at 12:26:25AM +0900, Minchan Kim wrote:
>> >> On Tue, Dec 07, 2010 at 04:19:39PM +0100, Johannes Weiner wrote:
>> >> > On Wed, Dec 08, 2010 at 12:07:10AM +0900, Minchan Kim wrote:
>> >> > > On Tue, Dec 07, 2010 at 03:49:24PM +0100, Johannes Weiner wrote:
>> >> > > > On Mon, Dec 06, 2010 at 02:29:10AM +0900, Minchan Kim wrote:
>> >> > > > > Changelog since v3:
>> >> > > > > =A0- Change function comments - suggested by Johannes
>> >> > > > > =A0- Change function name - suggested by Johannes
>> >> > > > > =A0- add only dirty/writeback pages to deactive pagevec
>> >> > > >
>> >> > > > Why the extra check?
>> >> > > >
>> >> > > > > @@ -359,8 +360,16 @@ unsigned long invalidate_mapping_pages(s=
truct address_space *mapping,
>> >> > > > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (lock_failed)
>> >> > > > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 c=
ontinue;
>> >> > > > >
>> >> > > > > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret +=3D invalidate=
_inode_page(page);
>> >> > > > > -
>> >> > > > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D invalidate_=
inode_page(page);
>> >> > > > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> >> > > > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If the page is=
 dirty or under writeback, we can not
>> >> > > > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* invalidate it =
now. =A0But we assume that attempted
>> >> > > > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* invalidation i=
s a hint that the page is no longer
>> >> > > > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* of interest an=
d try to speed up its reclaim.
>> >> > > > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> >> > > > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!ret && (PageDi=
rty(page) || PageWriteback(page)))
>> >> > > > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dea=
ctivate_page(page);
>> >> > > >
>> >> > > > The writeback completion handler does not take the page lock, s=
o you
>> >> > > > can still miss pages that finish writeback before this test, no=
?
>> >> > >
>> >> > > Yes. but I think it's rare and even though it happens, it's not c=
ritical.
>> >> > > >
>> >> > > > Can you explain why you felt the need to add these checks?
>> >> > >
>> >> > > invalidate_inode_page can return 0 although the pages is !{dirty|=
writeback}.
>> >> > > Look invalidate_complete_page. As easiest example, if the page ha=
s buffer and
>> >> > > try_to_release_page can't release the buffer, it could return 0.
>> >> >
>> >> > Ok, but somebody still tried to truncate the page, so why shouldn't=
 we
>> >> > try to reclaim it? =A0The reason for deactivating at this location =
is
>> >> > that truncation is a strong hint for reclaim, not that it failed du=
e
>> >> > to dirty/writeback pages.
>> >> >
>> >> > What's the problem with deactivating pages where try_to_release_pag=
e()
>> >> > failed?
>> >>
>> >> If try_to_release_page fails and the such pages stay long time in pag=
evec,
>> >> pagevec drain often happens.
>> >
>> > You mean because the pagevec becomes full more often? =A0These are not
>> > many pages you get extra without the checks, the race window is very
>> > small after all.
>>
>> Right.
>> It was a totally bad answer. The work in midnight makes my mind to be hu=
rt. :)
>>
>> Another point is that we can move such pages(!try_to_release_page,
>> someone else holding the ref) into tail of inactive.
>> We can't expect such pages will be freed sooner or later and it can
>> stir lru pages unnecessary.
>> On the other hand it's a _really_ rare so couldn't we move the pages int=
o tail?
>> If it can be justified, I will remove the check.
>> What do you think about it?
>>
>
> I wonder ...how about adding "victim" list for "Reclaim" pages ? Then, we=
 don't need
> extra LRU rotation.

It can make the code clean.
As far as I think, victim list does following as.

1. select victim pages by strong hint
2. move the page from LRU to victim
3. reclaimer always peeks victim list before diving into LRU list.
4-1. If the victim pages is used by others or dirty, it can be moved
into LRU, again or remain the page in victim list.
If the page is remained victim, when do we move it into LRU again if
the reclaimer continues to fail the page?
We have to put the new rule.
4-2. If the victim pages isn't used by others and clean, we can
reclaim the page asap.

AFAIK, strong hints are just two(invalidation, readahead max window heurist=
ic).
I am not sure it's valuable to add new hierarchy(ie, LRU, victim,
unevictable) for cleaning the minor codes.
In addition, we have to put the new rule so it would make the LRU code
complicated.
I remember how unevictable feature merge is hard.

But I am not against if we have more usecases. In this case, it's
valuable to implement it although it's not easy.

Thanks, Kame.

>
> Thanks,
> -Kame
>
>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
