From: Andreas Dilger <adilger@turbolinux.com>
Message-Id: <200010100422.e9A4Mg722840@webber.adilger.net>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <39E22E80.75819894@kalifornia.com> "from David Ford at Oct 9, 2000
 01:45:53 pm"
Date: Mon, 9 Oct 2000 22:22:42 -0600 (MDT)
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: david+validemail@kalifornia.com
Cc: Rik van Riel <riel@conectiva.com.br>, mingo@elte.hu, Andrea Arcangeli <andrea@suse.de>, Byron Stanoszek <gandalf@winds.org>, Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, jg@pa.dec.com, alan@lxorguk.ukuu.org.uk, acahalan@cs.uml.edu, Gerrit.Huizenga@us.ibm.com
List-ID: <linux-mm.kvack.org>

> Rik van Riel wrote:
> > > How about SIGTERM a bit before SIGKILL then re-evaluate the OOM
> > > N usecs later?
> >
> > And run the risk of having to kill /another/ process as well ?
> >
> > I really don't know if that would be a wise thing to do
> > (but feel free to do some tests to see if your idea would
> > work ... I'd love to hear some test results with your idea).

David Ford writes:
> I was thinking (dangerous) about an urgent v.s. critical OOM.  urgent could
> trigger a SIGTERM which would give advance notice to the offending process.
> I don't think we have a signal method of notifying processes when resources
> are critically low, feel free to correct me.
> 
> Is there a signal that -might- be used for this?

Albert D. Cahalan wrote:
> X, and any other big friendly processes, could participate in
> memory balancing operations. X could be made to clean out a
> font cache when the kernel signals that memory is low. When
> the situation becomes serious, X could just mmap /dev/zero over
> top of the background image.
>
> Netscape could even be hacked to dump old junk... or if it is
> just too leaky, it could exec itself to fix the problem.

Gerrit Huizenga wrote:
> Anyway, there is/was an API in PTX to say (either from in-kernel or through
> some user machinations) "I Am a System Process".  Turns on a bit in the
> proc struct (task struct) that made it exempt from death from a variety
> of sources, e.g. OOM, generic user signals, portions of system shutdown,
> etc.
> 
> Then, the code looking for things to kill simply skips those that are
> intelligently marked, taking most of the decision making/policy making
> out of the scheduler/memory manager.

On AIX there is a signal called SIGDANGER, which is basically what you
are looking for.  By default it is ignored, but for processes that care
(e.g. init, X, whatever) they can register a SIGDANGER handler.  At an
"urgent" (as oposed to "critical") OOM situation, all processes get a
SIGDANGER sent to them.  Most will ignore it, but ones with handlers
can free caches, try to do a clean shutdown, whatever.  Any process with
a SIGDANGER handler get a reduction of "badness" (as the OOM killer calls
it) when looking for processes to kill.

Having a SIGDANGER handler is good for 2 reasons:
1) Lets processes know when memory is short so they can free needless cache.
2) Mark process with a SIGDANGER handler as "more important" than those
   without.  Most people won't care about this, but init, and X, and
   long-running simulations might.

Cheers, Andreas
-- 
Andreas Dilger  \ "If a man ate a pound of pasta and a pound of antipasto,
                 \  would they cancel out, leaving him still hungry?"
http://www-mddsp.enel.ucalgary.ca/People/adilger/               -- Dogbert
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
