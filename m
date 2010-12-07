Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A62F76B0089
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 17:51:34 -0500 (EST)
Received: by qyk7 with SMTP id 7so5269435qyk.14
        for <linux-mm@kvack.org>; Tue, 07 Dec 2010 14:51:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101207155645.GG2356@cmpxchg.org>
References: <cover.1291568905.git.minchan.kim@gmail.com>
	<d57730effe4b48012d31ceca07938ed3eb401aba.1291568905.git.minchan.kim@gmail.com>
	<20101207144923.GB2356@cmpxchg.org>
	<20101207150710.GA26613@barrios-desktop>
	<20101207151939.GF2356@cmpxchg.org>
	<20101207152625.GB608@barrios-desktop>
	<20101207155645.GG2356@cmpxchg.org>
Date: Wed, 8 Dec 2010 07:51:25 +0900
Message-ID: <AANLkTi=iNGT_p_VfW9GxdaKXLt2xBHM2jdwmCbF_u8uh@mail.gmail.com>
Subject: Re: [PATCH v4 2/7] deactivate invalidated pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 8, 2010 at 12:56 AM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> On Wed, Dec 08, 2010 at 12:26:25AM +0900, Minchan Kim wrote:
>> On Tue, Dec 07, 2010 at 04:19:39PM +0100, Johannes Weiner wrote:
>> > On Wed, Dec 08, 2010 at 12:07:10AM +0900, Minchan Kim wrote:
>> > > On Tue, Dec 07, 2010 at 03:49:24PM +0100, Johannes Weiner wrote:
>> > > > On Mon, Dec 06, 2010 at 02:29:10AM +0900, Minchan Kim wrote:
>> > > > > Changelog since v3:
>> > > > > =A0- Change function comments - suggested by Johannes
>> > > > > =A0- Change function name - suggested by Johannes
>> > > > > =A0- add only dirty/writeback pages to deactive pagevec
>> > > >
>> > > > Why the extra check?
>> > > >
>> > > > > @@ -359,8 +360,16 @@ unsigned long invalidate_mapping_pages(stru=
ct address_space *mapping,
>> > > > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (lock_failed)
>> > > > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cont=
inue;
>> > > > >
>> > > > > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret +=3D invalidate_in=
ode_page(page);
>> > > > > -
>> > > > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D invalidate_ino=
de_page(page);
>> > > > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> > > > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If the page is di=
rty or under writeback, we can not
>> > > > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* invalidate it now=
. =A0But we assume that attempted
>> > > > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* invalidation is a=
 hint that the page is no longer
>> > > > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* of interest and t=
ry to speed up its reclaim.
>> > > > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> > > > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!ret && (PageDirty=
(page) || PageWriteback(page)))
>> > > > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 deacti=
vate_page(page);
>> > > >
>> > > > The writeback completion handler does not take the page lock, so y=
ou
>> > > > can still miss pages that finish writeback before this test, no?
>> > >
>> > > Yes. but I think it's rare and even though it happens, it's not crit=
ical.
>> > > >
>> > > > Can you explain why you felt the need to add these checks?
>> > >
>> > > invalidate_inode_page can return 0 although the pages is !{dirty|wri=
teback}.
>> > > Look invalidate_complete_page. As easiest example, if the page has b=
uffer and
>> > > try_to_release_page can't release the buffer, it could return 0.
>> >
>> > Ok, but somebody still tried to truncate the page, so why shouldn't we
>> > try to reclaim it? =A0The reason for deactivating at this location is
>> > that truncation is a strong hint for reclaim, not that it failed due
>> > to dirty/writeback pages.
>> >
>> > What's the problem with deactivating pages where try_to_release_page()
>> > failed?
>>
>> If try_to_release_page fails and the such pages stay long time in pageve=
c,
>> pagevec drain often happens.
>
> You mean because the pagevec becomes full more often? =A0These are not
> many pages you get extra without the checks, the race window is very
> small after all.

Right.
It was a totally bad answer. The work in midnight makes my mind to be hurt.=
 :)

Another point is that we can move such pages(!try_to_release_page,
someone else holding the ref) into tail of inactive.
We can't expect such pages will be freed sooner or later and it can
stir lru pages unnecessary.
On the other hand it's a _really_ rare so couldn't we move the pages into t=
ail?
If it can be justified, I will remove the check.
What do you think about it?

>
>> I think such pages are rare so skip such pages doesn't hurt goal of
>> this patch.
>
> Well, you add extra checks, extra detail to this mechanism. =A0Instead
> of just saying 'tried to truncate, failed, deactivate the page', you
> add more ifs and buts.
>
> There should be a real justification for it. =A0'It can not hurt' is not
> a good justification for extra code and making a simple model more
> complex.
>
> 'It will hurt without treating these pages differently' is a good
> justification. =A0Remember that we have to understand and maintain all
> this. =A0The less checks and operations we need to implement a certain
> idea, the better.
>
> Sorry for being so adamant about this, but I think these random checks
> are a really sore point of mm code already.

Never mind. I totally support your opinion.
It always make me confusing to review the mm codes.
Nowadays, many reviewers want detail comment and description. Given
that mm code changing are bigger, I believe it's a way to go

>
> [ For example, we tried discussing lumpy reclaim mode recently and
> =A0none of us could reliably remember how it actually behaved. =A0There
> =A0are so many special conditions in there that we already end up with
> =A0some of them being dead code and the checks even contradicting each
> =A0other. ]
>

Thanks for good comment, Hannes.




--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
