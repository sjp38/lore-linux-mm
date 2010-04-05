Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9E6366B021A
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 02:22:09 -0400 (EDT)
Received: by pwi2 with SMTP id 2so2585398pwi.14
        for <linux-mm@kvack.org>; Sun, 04 Apr 2010 23:22:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <x2w28c262361004042320x52dda2d1l30789cac28fbef6@mail.gmail.com>
References: <alpine.LFD.2.00.1004041125350.5617@localhost>
	 <1270396784.1814.92.camel@barrios-desktop>
	 <20100404160328.GA30540@ioremap.net>
	 <1270398112.1814.114.camel@barrios-desktop>
	 <20100404195533.GA8836@logfs.org>
	 <p2g28c262361004041759n52f5063dhb182663321d918bb@mail.gmail.com>
	 <20100405053026.GA23515@logfs.org>
	 <x2w28c262361004042320x52dda2d1l30789cac28fbef6@mail.gmail.com>
Date: Mon, 5 Apr 2010 15:22:08 +0900
Message-ID: <v2u28c262361004042322q7004032o9f7b0f76987f8493@mail.gmail.com>
Subject: Re: why are some low-level MM routines being exported?
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: =?UTF-8?Q?J=C3=B6rn_Engel?= <joern@logfs.org>
Cc: Evgeniy Polyakov <zbr@ioremap.net>, "Robert P. J. Day" <rpjday@crashcourse.ca>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Cced mm guys.

On Mon, Apr 5, 2010 at 3:20 PM, Minchan Kim <minchan.kim@gmail.com> wrote:
> On Mon, Apr 5, 2010 at 2:30 PM, J=C3=B6rn Engel <joern@logfs.org> wrote:
>> On Mon, 5 April 2010 09:59:18 +0900, Minchan Kim wrote:
>>> On Mon, Apr 5, 2010 at 4:55 AM, J=C3=B6rn Engel <joern@logfs.org> wrote=
:
>>> > On Mon, 5 April 2010 01:21:52 +0900, Minchan Kim wrote:
>>> >> >
>>> >> Until now, other file system don't need it.
>>> >> Why do you need?
>>> >
>>> > To avoid deadlocks. =C2=A0You tell logfs to write out some locked pag=
e, logfs
>>> > determines that it needs to run garbage collection first. =C2=A0Garba=
ge
>>> > collection can read any page. =C2=A0If it called find_or_create_page(=
) for
>>> > the locked page, you have a deadlock.
>>>
>>> Could you do it with add_to_page_cache and pagevec_lru_add_file?
>>
>> Maybe. =C2=A0But how would that be an improvement?
>>
>> As I see it, logfs needs a variant of find_or_create_page() that does
>> not block on any pages waiting for logfs GC. =C2=A0Currently that varian=
t
>> lives under fs/logfs/ and uses add_to_page_cache_lru(). =C2=A0If there a=
re
>> valid reasons against exporting add_to_page_cache_lru(), the right
>> solution is to move the logfs variant to mm/, not to rewrite it.
>>
>> If you want to change the implementation from using
>> add_to_page_cache_lru() to using add_to_page_cache() and
>> pagevec_lru_add_file(), then you should have a better reason than not
>> exporting add_to_page_cache_lru(). =C2=A0If the new implementation was a=
ny
>> better, I would gladly take it.
>
> Previously I said, what I have a concern is that if file systems or
> some modules abuses
> add_to_page_cache_lru, it might system LRU list wrong so then system
> go to hell.
> Of course, if we use it carefully, it can be good but how do you make sur=
e it?
>
> I am not a file system expert but as I read comment of read_cache_pages
> "Hides the details of the LRU cache etc from the filesystem", I
> thought it is not good that
> file system handle LRU list directly. At least, we have been trying for y=
ears.
>
> If we can do it with current functions without big cost, I think it's
> rather good than exporting
> new function. Until 18bc0bbd162e3, we didn't export that but all file
> systems works well.
> In addition, when the patch is merged, any mm guys seem to be not
> reviewed it, too.
>
> I hope just ring at the bell to remain record to justify why we need
> exporting new function
> although we can do it with existing functions.
>
> If any other mm guys don't oppose it, I would be not against that, either=
.
>
> --
> Kind regards,
> Minchan Kim
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
