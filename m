Date: Mon, 9 Oct 2000 19:57:42 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler 
In-Reply-To: <Pine.LNX.4.21.0010091829140.7807-100000@winds.org>
Message-ID: <Pine.LNX.4.21.0010091954230.1562-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Byron Stanoszek <gandalf@winds.org>
Cc: Gerrit.Huizenga@us.ibm.com, Linus Torvalds <torvalds@transmeta.com>, Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Oct 2000, Byron Stanoszek wrote:
> On Mon, 9 Oct 2000 Gerrit.Huizenga@us.ibm.com wrote:
> 
> > Anyway, there is/was an API in PTX to say (either from in-kernel or through
> > some user machinations) "I Am a System Process".  Turns on a bit in the
> > proc struct (task struct) that made it exempt from death from a variety
> > of sources, e.g. OOM, generic user signals, portions of system shutdown,
> > etc.
> 
> The current OOM killer does this, except for init. Checking to
> see if the process has a page table is equivalent to checking
> for the kernel threads that are integral to the system (PIDs
> 2-5). These will never be killed by the OOM. Init, however,
> still can be killed, and there should be an additional statement
> that doesn't kill if PID == 1.

Only if you can demonstrate any real-world scenario where 
init will be chosen with the current algorithm.

The "3 MB init on 4MB machine" kind of theoretical argument
just isn't convincing if nobody can show that there is a
problem in reality.

> I think we need to sit down and write a better OOM proposal,
> something that doesn't use CPU time and the NICE flag.

The nice flag has been removed from my current kernel tree.

The CPU time used, however, is a different matter. You really
don't want to have the OOM killer kill your 6-week-old running
simulation because a newly started netscape explodes ...

> How about we start by everyone in this discussion give their
> opinion on what the OOM selection process should do,

Quoting from mm/oom_kill.c:

/**
 * oom_badness - calculate a numeric value for how bad this task has been
 * @p: task struct of which task we should calculate
 *
 * The formula used is relatively simple and documented inline in the
 * function. The main rationale is that we want to select a good task
 * to kill when we run out of memory.
 *
 * Good in this context means that:
 * 1) we lose the minimum amount of work done
 * 2) we recover a large amount of memory
 * 3) we don't kill anything innocent of eating tons of memory
 * 4) we want to kill the minimum amount of processes (one)
 * 5) we try to kill the process the user expects us to kill, this
 *    algorithm has been meticulously tuned to meet the priniciple
 *    of least surprise ... (be careful when you change it)
 */

Do you have any additional requirements?

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
