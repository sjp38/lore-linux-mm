From: James A. Sutherland <jas88@cam.ac.uk>
Subject: Re: [PATCH] a simple OOM killer to save me from Netscape
Date: Mon, 16 Apr 2001 23:21:21 +0100
Message-ID: <3ormdto78qla1qir8c62i2tuope82bt1u0@4ax.com>
References: <20010414022048.B10405@redhat.com> <m1wv8pti0o.fsf@frodo.biederman.org> <Pine.LNX.4.21.0104131317110.12164-100000@imladris.rielhome.conectiva> <20010414022048.B10405@redhat.com> <ehnmdtcljeb1bttp3r6o6o85b6agda0mdt@4ax.com> <l03130300b701154d843c@[192.168.239.105]>
In-Reply-To: <l03130300b701154d843c@[192.168.239.105]>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Morton <chromi@cyberspace.org>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <riel@conectiva.com.br>, "Eric W. Biederman" <ebiederm@xmission.com>, Slats Grobnik <kannzas@excite.com>, linux-mm@kvack.org, Andrew Morton <andrewm@uow.edu.au>
List-ID: <linux-mm.kvack.org>

On Mon, 16 Apr 2001 22:40:31 +0100, you wrote:

>>Ideally, I'd SIGSTOP each thrashing process. That way, enough
>>processes can be swapped out and KEPT swapped out to allow others to
>>complete their task, freeing up physical memory. Then you can SIGCONT
>>the processes you suspended, and make progress that way. There are
>>risks of "deadlocks", of course - suspend X, and all your graphical
>>apps will lock up waiting for it. This should lower VM pressure enough
>>to cause X to be restarted, though...
>
>Strongly agree.  Two points that need defining for this:
>
>- When does a process become "thrashing"?  Clearly paging-in in itself is
>not a good measure, since all processes do this at startup - paging-in
>which forces other memory out, OTOH, is a prime target.

Yes... I think the best metric is how long the process is able to run
for between page faults. In short, "is it making progress?"

>- How long do we suspend it for?  Does this depend on how many times it's
>been suspended recently?

Probably, yes - in my example above, if we suspend X (blocking other
memory hogs), then unsuspend it again, we need to be sure we'll
suspend something else next cycle!

>A major point I've noticed is that a relatively small number of thrashing
>processes can force small interactive applications out of physical memory,
>too - this needs fixing urgently.
>
>Example: running 3 active memory hogs on my 256Mb physical + 256Mb swap
>machine causes XMMS to stutter and crackle; increasing the load to 4 memory
>hogs causes it to stop working completely for extended periods of time.
>The same effect can be seen on the (graphical) system monitors and on an
>SSH session in progress from outside.

Yep. Ideally, here, we'd suspend all but two of those memory hogs at
any one time. Probably suspending and restoring them in rotation, a
few seconds at a time, as a very coarse-grain scheduler? This way, all
these processes get similar amounts of CPU time, without forcing
thrashing or interactive performance degradation.

It's a very black art, this; "clever" page replacement algorithms will
probably go some way towards helping, but there will always be a point
when you really are thrashing - at which point, I think the best
solution is to suspend processes alternately until the problem is
resolved.


James.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
