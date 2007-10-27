From: Daniel Phillips <phillips@phunq.net>
Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
Date: Sat, 27 Oct 2007 15:58:36 -0700
References: <Pine.LNX.4.64.0709101220001.24735@schroedinger.engr.sgi.com> <20071026174409.GA1573@elf.ucw.cz> <Pine.LNX.4.64.0710261052530.15895@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0710261052530.15895@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710271558.37514.phillips@phunq.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Friday 26 October 2007 10:55, Christoph Lameter wrote:
> On Fri, 26 Oct 2007, Pavel Machek wrote:
> > > And, _no_, it does not necessarily mean global serialisation. By
> > > simply saying there must be N pages available I say nothing about
> > > on which node they should be available, and the way the
> > > watermarks work they will be evenly distributed over the
> > > appropriate zones.
> >
> > Agreed. Scalability of emergency swapping reserved is simply
> > unimportant. Please, lets get swapping to _work_ first, then we can
> > make it faster.
>
> Global reserve means that any cpuset that runs out of memory may
> exhaust the global reserve and thereby impact the rest of the system.
> The emergencies that are currently localized to a subset of the
> system and may lead to the failure of a job may now become global and
> lead to the failure of all jobs running on it.

If it does, it is a bug in the reserve accounting.  That said, I still 
agree with you that per-node reserve is a desirable goal for numa.  I 
would just like to be clear that it is not necessary, even for numa, 
just nice.  By all means somebody should be hacking on a numa feature 
for per-node emergency reserves, but as far as fixing the immediate, 
serious kernel block IO deadlocks goes, it does not matter.

Pavel, I do not agree that efficiency is unimportant on the 
under-pressure path.  I do not even like to call that the "emergency" 
path, because under heavy load it is normal for a machine to spend a 
significant fraction of its time in that state.  However, the 
efficiency goal there does not need to be quite the same as normal 
mode.

To illustrate, I would expect to see something like 95% of normal block 
IO performance on a numa machine in the case that "emergency" (aka 
memalloc memory) is allocated globally instead of locally, thus paying 
a (modest compared to the disk transfer itself) penalty for transfer of 
disk data over the numa interconnect.  95% of normal throughput on the 
block IO path is not a problem: if the machine spends 5% of its time on 
the "emergency" (aka memalloc) path, then overall efficiency will be 
95% * 95% = 99.75%.

Moral of this story: let's get the memory recursion fixes done in the 
most obviously correct way and not get distracted by illusory 
efficiency requirements for numa, that do not have a big bottom line 
impact.

I'm glad to see everybody still interested in these problems.  Though we 
have been a little quiet on this issue over here for a while, it does 
not mean that progress has stopped.  In fact, we are testing our 
solutions more heavily than ever, and getting closer to a solution that 
not only works solidly, but that should enable mass deletion of the 
whole creaky notion of dirty page limits in favor of nice, tight 
per-device control of in flight write traffic as I have described 
previously.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
