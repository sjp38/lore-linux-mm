Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2D2C76B003D
	for <linux-mm@kvack.org>; Fri,  1 May 2009 15:44:27 -0400 (EDT)
Received: by wa-out-1112.google.com with SMTP id v27so969935wah.22
        for <linux-mm@kvack.org>; Fri, 01 May 2009 12:45:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <49FB4EBB.3030404@redhat.com>
References: <20090428044426.GA5035@eskimo.com> <20090430072057.GA4663@eskimo.com>
	<20090430174536.d0f438dd.akpm@linux-foundation.org> <20090430205936.0f8b29fc@riellaptop.surriel.com>
	<20090430181340.6f07421d.akpm@linux-foundation.org> <20090430215034.4748e615@riellaptop.surriel.com>
	<20090430195439.e02edc26.akpm@linux-foundation.org> <49FB01C1.6050204@redhat.com>
	<2c0942db0905011104u4e6df9ap9d95fa30b1284294@mail.gmail.com>
	<49FB4EBB.3030404@redhat.com>
From: Ray Lee <ray-lk@madrabbit.org>
Date: Fri, 1 May 2009 12:44:48 -0700
Message-ID: <2c0942db0905011244v331273dfr2bb34953e42bebdf@mail.gmail.com>
Subject: Re: [PATCH] vmscan: evict use-once pages first (v2)
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, elladan@eskimo.com, peterz@infradead.org, linux-kernel@vger.kernel.org, tytso@mit.edu, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 1, 2009 at 12:34 PM, Rik van Riel <riel@redhat.com> wrote:
> Ray Lee wrote:
>
>> Said way #3: We desktop users really want a way to say "Please don't
>> page my executables out when I'm running a system with 3gig of RAM." I
>> hate knobs, but I'm willing to beg for one in this case. 'cause
>> mlock()ing my entire working set into RAM seems pretty silly.
>>
>> Does any of that make sense, or am I talking out of an inappropriate
>> orifice?
>
> The "don't page my executables out" part makes sense.
>
> However, I believe that kind of behaviour should be the
> default. =C2=A0Desktops and servers alike have a few different
> kinds of data in the page cache:
> 1) pages that have been frequently accessed at some point
> =C2=A0 in the past and got promoted to the active list
> 2) streaming IO
>
> I believe that we want to give (1) absolute protection from
> (2), provided there are not too many pages on the active file
> list. =C2=A0That way we will provide executables, cached indirect
> and inode blocks, etc. from streaming IO.
>
> Pages that are new to the page cache start on the inactive
> list. =C2=A0Only if they get accessed twice while on that list,
> they get promoted to the active list.
>
> Streaming IO should normally be evicted from memory before
> it can get accessed again. =C2=A0This means those pages do not
> get promoted to the active list and the working set is
> protected.
>
> Does this make sense?

Streaming IO should always be at the bottom of the list as it's nearly
always use-once. That's not the interesting case. (I'm glad you're
protecting everything from steaming IO, it's a good thing. And if it's
a media server and serving the same stream to many clients, if I
understood you correctly those streams will no longer be use-once, and
therefore be a normal citizen with the rest of the cache. That's great
too.)

The interesting case is an updatedb running in the background, paging
out firefox, or worse, parts of X. That sucks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
