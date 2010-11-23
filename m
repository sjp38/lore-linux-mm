Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id DF5F06B0071
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 18:32:33 -0500 (EST)
Received: by gyg10 with SMTP id 10so448867gyg.14
        for <linux-mm@kvack.org>; Tue, 23 Nov 2010 15:32:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101123094355.GF19571@csn.ul.ie>
References: <bdd6628e81c06f6871983c971d91160fca3f8b5e.1290349672.git.minchan.kim@gmail.com>
	<20101122141449.9de58a2c.akpm@linux-foundation.org>
	<AANLkTimk4JL7hDvLWuHjiXGNYxz8GJ_TypWFC=74Xt1Q@mail.gmail.com>
	<20101122210132.be9962c7.akpm@linux-foundation.org>
	<AANLkTin62R1=2P+Sh0YKJ3=KAa6RfLQLKJcn2VEtoZfG@mail.gmail.com>
	<20101122212220.ae26d9a5.akpm@linux-foundation.org>
	<AANLkTinTp2N3_uLEm7nf0=Xu2f9Rjqg9Mjjxw-3YVCcw@mail.gmail.com>
	<20101122214814.36c209a6.akpm@linux-foundation.org>
	<20101123094355.GF19571@csn.ul.ie>
Date: Wed, 24 Nov 2010 08:32:27 +0900
Message-ID: <AANLkTi=3Y1sQBRYVzKMvtwxYCPXe7ST6BAQxfJB3EyoN@mail.gmail.com>
Subject: Re: [RFC 1/2] deactive invalidated pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 23, 2010 at 6:43 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Mon, Nov 22, 2010 at 09:48:14PM -0800, Andrew Morton wrote:
>> On Tue, 23 Nov 2010 14:45:15 +0900 Minchan Kim <minchan.kim@gmail.com> w=
rote:
>>
>> > On Tue, Nov 23, 2010 at 2:22 PM, Andrew Morton
>> > <akpm@linux-foundation.org> wrote:
>> > > On Tue, 23 Nov 2010 14:23:33 +0900 Minchan Kim <minchan.kim@gmail.co=
m> wrote:
>> > >
>> > >> On Tue, Nov 23, 2010 at 2:01 PM, Andrew Morton
>> > >> <akpm@linux-foundation.org> wrote:
>> > >> > On Tue, 23 Nov 2010 13:52:05 +0900 Minchan Kim <minchan.kim@gmail=
.com> wrote:
>> > >> >
>> > >> >> >> +/*
>> > >> >> >> + * Function used to forecefully demote a page to the head of=
 the inactive
>> > >> >> >> + * list.
>> > >> >> >> + */
>> > >> >> >
>> > >> >> > This comment is wrong? __The page gets moved to the _tail_ of =
the
>> > >> >> > inactive list?
>> > >> >>
>> > >> >> No. I add it in _head_ of the inactive list intentionally.
>> > >> >> Why I don't add it to _tail_ is that I don't want to be aggressi=
ve.
>> > >> >> The page might be real working set. So I want to give a chance t=
o
>> > >> >> activate it again.
>> > >> >
>> > >> > Well.. __why? __The user just tried to toss the page away altoget=
her. __If
>> > >> > the kernel wasn't able to do that immediately, the best it can do=
 is to
>> > >> > toss the page away asap?
>> > >> >
>> > >> >> If it's not working set, it can be reclaimed easily and it can p=
revent
>> > >> >> active page demotion since inactive list size would be big enoug=
h for
>> > >> >> not calling shrink_active_list.
>> > >> >
>> > >> > What is "working set"? __Mapped and unmapped pagecache, or are yo=
u
>> > >> > referring solely to mapped pagecache?
>> > >>
>> > >> I mean it's mapped by other processes.
>> > >>
>> > >> >
>> > >> > If it's mapped pagecache then the user was being a bit silly (or =
didn't
>> > >> > know that some other process had mapped the file). __In which cas=
e we
>> > >> > need to decide what to do - leave the page alone, deactivate it, =
or
>> > >> > half-deactivate it as this patch does.
>> > >>
>> > >>
>> > >> What I want is the half-deactivate.
>> > >>
>> > >> Okay. We will use the result of invalidate_inode_page.
>> > >> If fail happens by page_mapped, we can do half-deactivate.
>> > >> But if fail happens by dirty(ex, writeback), we can add it to tail.
>> > >> Does it make sense?
>> > >
>> > > Spose so. __It's unobvious.
>> > >
>> > > If the page is dirty or under writeback then reclaim will immediatel=
y
>> > > move it to the head of the LRU anyway. __But given that the user has
>> >
>> > Why does it move into head of LRU?
>> > If the page which isn't mapped doesn't have PG_referenced, it would be
>> > reclaimed.
>>
>> If it's dirty or under writeback it can't be reclaimed!
>>
>> > > just freed a bunch of pages with invalidate(), it's unlikely that
>> > > reclaim will be running soon.
>> >
>> > If reclaim doesn't start soon, it's good. That's because we have a
>> > time to activate it and
>> > when reclaim happens, reclaimer can reclaim pages easily.
>> >
>> > If I don't understand your point, could you elaborate on it?
>>
>> If reclaim doesn't happen soon and the page was dirty or under
>> writeback (and hence unreclaimable) then there's a better chance that
>> it _will_ be reclaimable by the time reclaim comes along and has a look
>> at it. =A0Yes, that's good.
>>
>> And a note to Mel: this is one way in which we can get significant
>> (perhaps tremendous) numbers of dirty pages coming off the tail of the
>> LRU, and hence eligible for pageout() treatment.
>>
>
> Agreed. This is why I'd be ok with the pages always being added to the he=
ad
> of the inactive list to take into consideration another process might be
> using the page (via read/write so it's not very obvious) and to give flus=
her
> threads a chance to clean the page. Ideally the pages being deactivated w=
ould
> be prioritised for cleaning but I don't think we have a mechanism for it =
at
> the moment.

In view point of reclaim, it's right. but might not for efficient write.
If we have a such mechanism, current pageout effect(random write)
could happen still.
I think what we can do is to prevent writeout by pageout.
For it, it's good to put the page head of inacitve and as soon as
write complete, we move the page to tail of inactive.

>
> --
> Mel Gorman
> Part-time Phd Student =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
Linux Technology Center
> University of Limerick =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 IB=
M Dublin Software Lab
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
