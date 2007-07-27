Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge
	plans for 2.6.23]
From: Mike Galbraith <efault@gmx.de>
In-Reply-To: <1185513177.6295.21.camel@Homer.simpson.net>
References: <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>
	 <46A57068.3070701@yahoo.com.au>
	 <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>
	 <46A58B49.3050508@yahoo.com.au>
	 <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>
	 <46A6CC56.6040307@yahoo.com.au> <p73abtkrz37.fsf@bingen.suse.de>
	 <46A85D95.509@kingswood-consulting.co.uk> <20070726092025.GA9157@elte.hu>
	 <20070726023401.f6a2fbdf.akpm@linux-foundation.org>
	 <20070726094024.GA15583@elte.hu>
	 <20070726030902.02f5eab0.akpm@linux-foundation.org>
	 <1185454019.6449.12.camel@Homer.simpson.net>
	 <20070726110549.da3a7a0d.akpm@linux-foundation.org>
	 <1185513177.6295.21.camel@Homer.simpson.net>
Content-Type: text/plain
Date: Fri, 27 Jul 2007 09:23:41 +0200
Message-Id: <1185521021.6295.50.camel@Homer.simpson.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Frank Kingswood <frank@kingswood-consulting.co.uk>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2007-07-27 at 07:13 +0200, Mike Galbraith wrote:
> On Thu, 2007-07-26 at 11:05 -0700, Andrew Morton wrote:
> > > drops caches prior to both updatedb runs.
> > 
> > I think that was the wrong thing to do.  That will leave gobs of free
> > memory for updatedb to populate with dentries and inodes.
> > 
> > Instead, fill all of memory up with pagecache, then do the updatedb.  See
> > how much pagecache is left behind and see how large the vfs caches end up.

I didn't _fill_ memory, but loaded it up a bit with some real workload
data...

I tried time sh -c 'git diff v2.6.11 HEAD > /dev/null' to populate the
cache, and tried different values for vfs_cache_pressure.  Nothing
prevented git's data from being trashed by updatedb.  Turning the knob
downward rapidly became very unpleasant due to swap, (with 0 not
surprisingly being a true horror) but turning it up didn't help git one
bit.  The amount of data that had to be re-read with stock 100 or 10000
was the same, or at least so close that you couldn't see a difference in
vmstat and wall-clock.  Cache sizes varied, but the bottom line didn't.
(wasn't surprised, seems quite reasonable that git's data looks old and
useless to the reclaim logic when updatedb runs in between git runs)

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
