Date: Fri, 27 Feb 1998 00:21:44 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: Fairness in love and swapping
In-Reply-To: <199802262241.WAA03911@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.91.980226235834.5141B-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: Rogier Wolff <R.E.Wolff@BitWizard.nl>, torvalds@transmeta.com, blah@kvack.org, nahshon@actcom.co.il, alan@lxorguk.ukuu.org.uk, paubert@iram.es, linux-kernel@vger.rutgers.edu, mingo@chiara.csoma.elte.hu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 26 Feb 1998, Stephen C. Tweedie wrote:

> > We could:
> > - force-swap out processes which have slept for some time
> > - suspend & force-swap out the largest process
> > - wake it up again when there are two proceses waiting on
> >   it (to prevent X from being swapped out)
> 
> Define the number of processes waiting on a given process?
> 
> Another way of making the distinction between batch and interactive
> processes might be to observe that interactive processes spend some of
> their time in "S" (interruptible sleep) state, whereas we expect
> compute-bound jobs to be in "R" or "D" state most of the time.
> However, that breaks down too when you consider batch jobs involving
> pipelines, such as gcc -pipe.

I think we should give programs points based on several
things:
time_in + how long has it been in-core in seconds (300 max)
data_sz + RSS + DSIZE (#pages)
fil_dsc - number of file descriptors (if it has loads of
          file descriptors, it communicates a lot with the environment
          and is less likely a batch process)
slp_tim + how long has it been sleeping (to force-swap, but not
          suspend sleeping processes) in seconds (300 max)
run_tim + how long has it been running/blocking without 'interactive'
          syscalls or state changes in seconds (300 max)
is_root - euid = 0 (500 points)

The more (+) points a process has, the more likely it is
going to be selected for swapout. Now we got to make some
nice formula to select the processes and the swapout time.

Maybe:

points= time_in + (data_sz / fil_dsc) + slp_tim + run_tim - is_root4~

or:

points= (time_in / fil_dsc) + data_sz + slp_tim + run_tim - is_root
         ^^^^^max 300pt total

When swapping is needed, we simply walk the process table
and swap out the process with the most points...
But we _need_ to be sure that we don't pick X for a 30 second
break ... How do we do that?

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
