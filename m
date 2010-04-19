Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 412706B01EF
	for <linux-mm@kvack.org>; Mon, 19 Apr 2010 10:09:53 -0400 (EDT)
Received: by pvg11 with SMTP id 11so2889238pvg.14
        for <linux-mm@kvack.org>; Mon, 19 Apr 2010 07:09:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100419133843.GP5683@laptop>
References: <1271089672.7196.63.camel@localhost.localdomain>
	 <1271249354.7196.66.camel@localhost.localdomain>
	 <m2g28c262361004140813j5d70a80fy1882d01436d136a6@mail.gmail.com>
	 <1271262948.2233.14.camel@barrios-desktop>
	 <1271320388.2537.30.camel@localhost>
	 <1271350270.2013.29.camel@barrios-desktop>
	 <1271427056.7196.163.camel@localhost.localdomain>
	 <1271603649.2100.122.camel@barrios-desktop>
	 <20100419133843.GP5683@laptop>
Date: Mon, 19 Apr 2010 23:09:50 +0900
Message-ID: <x2w28c262361004190709za445a55el8a888af1c7254169@mail.gmail.com>
Subject: Re: vmalloc performance
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Steven Whitehouse <swhiteho@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 19, 2010 at 10:38 PM, Nick Piggin <npiggin@suse.de> wrote:
> On Mon, Apr 19, 2010 at 12:14:09AM +0900, Minchan Kim wrote:
>> On Fri, 2010-04-16 at 15:10 +0100, Steven Whitehouse wrote:
>> Nick, What do you think about "free area cache" approach?
>
> Thanks, yep something like this is what I had in mind. Looks like you
> have some really nice speed improvements which is great.
>
>
>> In this version, I don't consider last hole and backward cache movement =
which is
>> like mmap's cached_hole_size
>> That's because I want to flush vmap_areas freed intentionally if we meet=
 vend.
>> It makes flush frequent than old but it's trade-off. In addition, vmallo=
c isn't
>> critical compared to mmap about performance. So I think that's enough.
>>
>> If you don't opposed, I will repost formal patch without code related to=
 debug.
>
> I think I would prefer to be a little smarter about using lower
> addresses first. I know the lazy TLB flushing works against this, but
> that is an important speed tradeoff, wheras there is not really any
> downside to trying hard to allocate low areas first. Keeping virtual
> addresses dense helps with locality of reference of page tables, for
> one.
>
> So I would like to see:
> - invalidating the cache in the case of vstart being decreased.
> - Don't unconditionally reset the cache to the last vm area freed,
> =C2=A0because you might have a higher area freed after a lower area. Only
> =C2=A0reset if the freed area is lower.
> - Do keep a cached hole size, so smaller lookups can restart a full
> =C2=A0search.

Firstly, I considered it which is used by mmap.
But I thought it might be overkill since vmalloc space isn't large
compared to mmaped addresses.
I should have thought about locality of reference of page tables. ;-)

> Probably also at this point, moving some of the rbtree code (like the
> search code) into functions would manage the alloc_vmap_area complexity.
> Maybe do this one first if you're going to write a patchset.
>
> What do you think? Care to have a go? :)

Good. I will add your requirements to TODO list.
But don't wait me. If you care to have a go, RUN!!!
I am looking forward to seeing your awesome patches. :)

Thanks for careful review, Nick.
--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
