Date: Thu, 27 Apr 2000 16:56:11 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: [patch] 2.3.99-pre6-3 VM fixed
In-Reply-To: <20000427172832.D3792@redhat.com>
Message-ID: <Pine.LNX.4.21.0004271647461.3919-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

On Thu, 27 Apr 2000, Stephen C. Tweedie wrote:
> On Wed, Apr 26, 2000 at 10:36:10AM -0300, Rik van Riel wrote:
> > 
> > The patch runs great in a variety of workloads I've tested here,
> > but of course I'm not sure if it works as good as it should in
> > *your* workload, so testing is wanted/needed/appreciated...
> 
> Well, on an 8GB box doing a "mtest -m1000 -r0 -w12" (ie. create
> 1GB heap and fork off 12 writer sub-processes touching the heap
> at random), I get a complete lockup just after the system goes
> into swap.  At one point I was able to capture an EIP trace
> showing the kernel looping in stext_lock and try_to_swap_out.

After half a day of heavy abuse, I've gotten my machine into
a state where it's hanging in stext_lock and swap_out...

Both cpus are spinning in a very tight loop, suggesting a
deadlock. (/me points finger at other code, I didn't change
any locking stuff :))

This suggests a locking issue. Is there any place in the kernel
where we take a write lock on tasklist_lock and do a lock_kernel()
afterwards?

Alternatively, the mm->lock, kernel_lock and/or tasklist_lock could
be in play all three... Could the changes to ptrace.c be involved
here?

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
