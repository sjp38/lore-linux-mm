Date: Fri, 6 Oct 2000 17:31:11 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <Pine.LNX.4.21.0010061611540.2191-100000@winds.org>
Message-ID: <Pine.LNX.4.21.0010061721520.13585-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Byron Stanoszek <gandalf@winds.org>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 6 Oct 2000, Byron Stanoszek wrote:
> On Fri, 6 Oct 2000, Rik van Riel wrote:
> 
> > 3. add the out of memory killer, which has been tuned with
> >    -test9 to be ran at exactly the right moment; process
> >    selection: "principle of least surprise"  <== OOM handling
> 
> In the OOM killer, shouldn't there be a check for PID 1 just to
> enforce that INIT will not be the victim? Sure its total_vm
> might be small, but if there was a memory leak in the kernel
> somewhere, it might eventually become the target. I suppose, if
> it ever were to become the victim, your system wouldn't be too
> usable anyway...

Indeed, if init is chosen for some reason, something really
strange is going on and there's not much hope for rescueing
it ;)

> Can you give me your rationale for selecting 'nice' processes as
> being badder?

They are niced because the user thinks them a bit less
important. This includes stuff like cron jobs that _just_
push a system over the edge ...

> Do you think it would be a good idea to scale the amount of
> badness according to how nice the process is (a nice value of 20
> could get the full *2, otherwise a smaller multiplier)?

I've thought about this, but the algorithms used are so
coarse that this makes little sense. Also, a nice+20
process is often more "important" than the nice+4 cron
job ... ;)

> How about using the current process priority level instead of
> nicety. If a process was deprioritized (or auto-niced) because
> it was starting to eat up CPU time, AND its memory is abnormally
> high, then should that be our #1 victim?

Not really. In the first place, the dynamic priority changes
so fast that it means almost nothing. Furthermore, once a process
has used a lot of CPU time, killing it means you're potentially
throwing away a lot of useful work that's been done.

(same for a process which has been running a long time)

> We also don't want to kill things like benchmarks either, but
> hopefully they wouldn't start eating up more than the available
> system memory.

*grin*

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
