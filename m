Message-ID: <51039.193.133.92.239.1021542563.squirrel@lbbrown.homeip.net>
Date: Thu, 16 May 2002 10:49:23 +0100 (BST)
Subject: Re: [RFC][PATCH] iowait statistics
From: "Leigh Brown" <leigh@solinno.co.uk>
In-Reply-To: <Pine.LNX.4.44L.0205151310130.9490-100000@duckman.distro.conectiva>
References: <Pine.LNX.4.44L.0205151310130.9490-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@conectiva.com.br
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Yesterday, Rik van Riel wrote:
> On Wed, 15 May 2002, Denis Vlasenko wrote:
>
>> I think two patches for same kernel piece at the same time is
>> too many. Go ahead and code this if you want.
>
> OK, here it is.   Changes against yesterday's patch:
>
> 1) make sure idle time can never go backwards by incrementing
>   the idle time in the timer interrupt too (surely we can
>   take this overhead if we're idle anyway ;))
>
> 2) get_request_wait also raises nr_iowait_tasks (thanks akpm)
>
> This patch is against the latest 2.5 kernel from bk and
> pretty much untested. If you have the time, please test
> it and let me know if it works.

First off, let me say that I've wanted this functionality for a long
time.  I do quite a lot of AIX Systems Admin and it's one of those
metrics that doesn't really give you any concrete data but does help
to get an idea on what the system's doing.

I've tried this patch against Red Hat's 2.4.18 kernel on my laptop, and
patched top to display the results.  It certainly seems to be working
correctly running a few little contrived tests.

The only little issue I have is that I tried the previous patch and it
accounted raw I/O (using /dev/raw/raw*) as system time rather than wait
time.  The new version seems better in this regard but I'm not sure if
it is 100% correct.  If I run a "dd if=/dev/hdc of=/dev/null bs=2048"
a typical result would be:

CPU states: 0.5% user,  3.5% system,  0.0% nice,  0.0% idle, 95.8% wait

which is what I'd expect based on my experience.    However, Doing a
"raw /dev/raw/raw1 /dev/hdc" followed by a "dd if=/dev/raw/raw1 ..."
gives this sort of result:

CPU states: 0.3% user,  8.9% system,  0.0% nice, 77.2% idle, 13.3% wait

I'm not sure if that can be explained by the way the raw I/O stuff works,
or because I'm running it against 2.4.  Anyway, overall it's looking good.

Cheers,

Leigh.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
