Date: Mon, 28 Jan 2008 01:27:18 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Only print kernel debug information for OOMs caused by
 kernel allocations
Message-Id: <20080128012718.65b7889a.akpm@linux-foundation.org>
In-Reply-To: <200801281011.57839.ak@suse.de>
References: <20080116222421.GA7953@wotan.suse.de>
	<200801280710.08204.ak@suse.de>
	<20080128005657.24236df5.akpm@linux-foundation.org>
	<200801281011.57839.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jan 2008 10:11:57 +0100 Andi Kleen <ak@suse.de> wrote:

> On Monday 28 January 2008 09:56, Andrew Morton wrote:
> > On Mon, 28 Jan 2008 07:10:07 +0100 Andi Kleen <ak@suse.de> wrote:
> > > On Monday 28 January 2008 06:52, Andrew Morton wrote:
> > > > On Wed, 16 Jan 2008 23:24:21 +0100 Andi Kleen <ak@suse.de> wrote:
> > > > > I recently suffered an 20+ minutes oom thrash disk to death and
> > > > > computer completely unresponsive situation on my desktop when some
> > > > > user program decided to grab all memory. It eventually recovered, but
> > > > > left lots of ugly and imho misleading messages in the kernel log.
> > > > > here's a minor improvement
> > >
> > > As a followup this was with swap over dm crypt. I've recently heard
> > > about other people having trouble with this too so this setup seems to
> > > trigger something bad in the VM.
> >
> > Where's the backtrace and show_mem() output? :)
> 
> I don't have it anymore. You want me to reproduce it? I don't think
> I saw messages from the other people either; just heard complaints.

May as well - it doesn't sound like it'll fix itself...

> > > > That information is useful for working out why a userspace allocation
> > > > attempt failed.  If we don't print it, and the application gets killed
> > > > and thus frees a lot of memory, we will just never know why the
> > > > allocation failed.
> > >
> > > But it's basically only either page fault (direct or indirect) or write
> > > et.al. who do these page cache allocations. Do you really think it is
> > > that important to distingush these cases individually? In 95+% of all
> > > cases it should be a standard user page fault which always has the same
> > > backtrace.
> >
> > Sure, the backtrace isn't very important.  The show_mem() output is vital.
> 
> I see. So would the patch be acceptable if it only disabled the backtrace? 

Spose so.  The show_mem() spew is probably larger than the backtrace
though.

Are you sure we aren't doing dump_stack()/show_mem() mutiple times for a
single process?  If we are, that would mena the TIF_MEMDIE thing broke.

It must have been one heck of an oomkilling slaughter.

> > Plus an additional function call.  On the already-deep page allocation
> > path, I might add.
> 
> The function call is already there if the kernel has CPUSETs enabled.

s/CPUSETS/NUMA/, which makes rather a difference.

> And that is what distribution kernels usually do. And most users
> use distribution kernels or distribution .config.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
