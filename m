From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200003011818.KAA17369@google.engr.sgi.com>
Subject: Re: [RFC] [RFT] Shared /dev/zero mmaping feature
Date: Wed, 1 Mar 2000 10:18:05 -0800 (PST)
In-Reply-To: <qww66v6mv7j.fsf@sap.com> from "Christoph Rohland" at Mar 01, 2000 06:55:12 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <hans-christoph.rohland@sap.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

> 
> kanoj@google.engr.sgi.com (Kanoj Sarcar) writes:
> 
> > What you have sent is what I used as a first draft for the implementation.
> > The good part of it is that it reduces code duplication. The _really_ bad
> > part is that it penalizes users in terms of numbers of shared memory 
> > segments, max size of /dev/zero mappings, and limitations imposed by
> > shm_ctlmax/shm_ctlall/shm_ctlmni etc. I do not think taking up a 
> > shmid for each /dev/zero mapping is a good idea ...
> 
> We can tune all these parameters at runtime. This should not be a
> reason.

Show me the patch ... by the time you are done, you _probably_ would
have complicated the code more than the current /dev/zero tweaks.

> 
> > Furthermore, I did not want to change behavior of information returned
> > by ipc* and various procfs commands, as well as swapout behavior, thus
> > the creation of the zmap_list. I decided a few lines of special case
> > checking in a handful of places was a much better option.
> 
> IMHO all this SYSV ipc stuff is a totally broken API and many agree
> with me. I do not care to clutter up the output of it a little bit for
> this feature.

In reality, /dev/zero should have nothing to do with SYSV. Currently,
its that way because I wanted to minimize code duplication. Most of
the *_core() routines can be taken into ipc/shm_core.c, and together 
with util.c, will let /dev/zero be decoupled from SYSV.

> 
> Nobody can know who is creating private IPC segments. So nobody should
> be irritated by some more segments displayed/used.

The problem is more with the limits, much less with the output ...

> 
> In the contrary: I like the ability to restrict the usage of these
> segments with the ipc parameters. Keep in mind you can stack a lot of
> segments for a DOS attack. and all the segments will use the whole
> memory.

Not sure what you are talking about here ... /dev/zero mmaps are subject
to the same vm-resource checking as other mmaps, and this checking is
a little different for "real" shm creation.

> 
> > If the current /dev/zero stuff hampers any plans you have with shm code 
> > (eg page cachification), I would be willing to talk about it ...
> 
> It makes shm fs a lot more work. And the special handling slows down
> shm handling.

The shm handling slow down is minimal. Most of this is an extra check in 
shm_nopage(), but that _only_ happens for /dev/zero segments, not for
"real" shm segments.

As to why shm fs is a lot more work, we can talk. Linus/Ingo did bring this
up, at a general level, we think that adding an extra inode or other
data structure in map_zero_setup() would be able to handle this.

If a small amount of special case code is the problem, I would suggest 
keep the code as it is for now. Once you have the shm fs work done for 
"real" shm segments, I can look at how to handle /dev/zero segments.

Kanoj

> 
> Greetings
> 		Christoph
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
