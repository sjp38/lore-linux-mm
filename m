From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200003081751.JAA42578@google.engr.sgi.com>
Subject: Re: [RFC] [RFT] Shared /dev/zero mmaping feature
Date: Wed, 8 Mar 2000 09:51:46 -0800 (PST)
In-Reply-To: <qww7lfdr7o4.fsf@sap.com> from "Christoph Rohland" at Mar 08, 2000 01:02:51 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <hans-christoph.rohland@sap.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, Ingo Molnar <mingo@chiara.csoma.elte.hu>
List-ID: <linux-mm.kvack.org>

> 
> Hi Kanoj,
> 
> kanoj@google.engr.sgi.com (Kanoj Sarcar) writes:
> > > To make this work for shared anonymous pages, we need two changes
> > > to the swap cache.  We need to teach the swap cache about writable
> > > anonymous pages, and we need to be able to defer the physical
> > > writing of the page to swap until the last reference to the swap
> > > cache frees up the page.  Do that, and shared /dev/zero maps will
> > > Just Work.
> > 
> > The current implementation of /dev/zero shared memory is to treat
> > the mapping as similarly as possible to a shared memory segment. The
> > common code handles the swap cache interactions, and both cases
> > qualify as shared anonymous mappings. While its not well tested, in
> > theory it should work. We are currently agonizing over how to
> > integrate the /dev/zero code with shmfs patch.
>   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> 
> Since this is not as easy as you thought, wouldn't it be better to do 
> the /dev/zero shared maps in the swap cache instead of this workaround
> over shm? Thus we would get the mechanisms to redo all shm stuff wrt
> swap cache.
> 
> At the same time we would not hinder the development of normal shm
> code to use file semantics (aka shm fs) which will give us posix shm.
> 
> Greetings
> 		Christoph
> 

I am not sure why you think the /dev/zero code is a workaround on top
of shm. A lot of code and mechanisms are easily sharable between shm  
and /dev/zero, since they are, as I pointed out, anonymous shared
pages. The only differences are when the data structures are torn 
down, and which processes may attach to the segments. 

Btw, implementing /dev/zero using shm code mostly is _quite_ easy,
that's how the code has been since 2.3.48. Even integrating with
shmfs has been pretty easy, as you have seen in the patches I have
CCed you on. The harder part is to look towards the future and do
what Linus suggested, namely associate each mapping with an inode
so in the future the inodecache might possibly be used to manage
the shm pages. As you know, I sent out a patch for that yesterday.

Its completely okay by me to take in a dev-zero/shmfs integration
patch that is not perfect wrt /dev/zero, as I have indicated to 
you and Linus, just so that the shmfs work gets in. I can fix
minor problems with the /dev/zero code as they come up.

What sct suggests is quite involved, as he himself mentions. Just
implementing /dev/zero is probably not a good reason to undertake
it.

Hope this makes sense.

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
