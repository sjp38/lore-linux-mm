Date: Mon, 14 May 2001 19:29:28 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: [PATCH] v2.4.4-ac9 highmem deadlock
In-Reply-To: <Pine.LNX.4.33.0105141930270.11830-100000@toomuch.toronto.redhat.com>
Message-ID: <Pine.LNX.4.21.0105141925580.32493-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: alan@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Mon, 14 May 2001, Ben LaHaise wrote:

> Hey folks,

Hi. 

> 
> The patch below consists of 3 seperate fixes for helping remove the
> deadlocks present in current kernels with respect to highmem systems.
> Each fix is to a seperate file, so please accept/reject as such.

<snip>

> The third patch (to vmscan.c) adds a SCHED_YIELD to the page launder code
> before starting a launder loop.  This one needs discussion, but what I'm
> attempting to accomplish is that when kswapd is cycling through
> page_launder repeatedly, bdflush or some other task submitting io via the
> bounce buffers needs to be given a chance to run and complete their io
> again.  Failure to do so limits the rate of progress under extremely high
> load when the vast majority of io will be transferred via bounce buffers.

Your patch may allow bdflush or some other task to submit IO if kswapd is
looping mad --- but it will not avoid kswapd from eating all the CPU
time, which is the _main_ problem. 

If we avoid kswapd from doing such a thing (which is what we should try to
fix in the first place), there is no need for your patch.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
