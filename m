Date: Sat, 13 May 2000 12:57:01 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [patch] balanced highmem subsystem under pre7-9
Message-ID: <20000513125701.E14984@redhat.com>
References: <Pine.LNX.4.10.10005122149120.6188-100000@elte.hu> <Pine.LNX.4.21.0005121944580.28943-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0005121944580.28943-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Fri, May 12, 2000 at 07:48:45PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Andrea Arcangeli <andrea@suse.de>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.rutgers.edu, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, May 12, 2000 at 07:48:45PM -0300, Rik van Riel wrote:

> >  				if (tsk->need_resched)
> > -					schedule();
> > +					goto sleep;
> 
> This is wrong. It will make it much much easier for processes to
> get killed (as demonstrated by quintela's VM test suite).

It shouldn't.  If tasks are getting killed, then the fix should be
in alloc_pages, not in kswapd.  Tasks _should_ be quite able to wait
for memory, and if necessary, drop into try_to_free_pages themselves.

Linus, the fix above seems to be necessary.  Without it, even a simple
playing of mp3 audio on 2.3 fails once memory is full on a 256MB box,
with kswapd consuming between 5% and 25% of CPU and locking things up
sufficiently to cause dropouts in the playback every second or more.
With that one-liner fix, mp3 is smooth even in the presence of other
background file activity.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
