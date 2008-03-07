Subject: Re: [BUG] 2.6.25-rc4 hang/softlockups after freeing hugepages
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20080307114849.GC26229@csn.ul.ie>
References: <1204824183.5294.62.camel@localhost>
	 <20080307114849.GC26229@csn.ul.ie>
Content-Type: text/plain
Date: Fri, 07 Mar 2008 09:36:56 -0500
Message-Id: <1204900617.5340.2.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Adam Litke <agl@us.ibm.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2008-03-07 at 11:48 +0000, Mel Gorman wrote:
> On (06/03/08 12:23), Lee Schermerhorn didst pronounce:
> > Test platform:  HP Proliant DL585 server - 4 socket, dual core AMD with
> > 32GB memory.
> > 
> > I first saw this on 25-rc2-mm1 with Mel's zonelist patches, while
> > investigating the interaction of hugepages and cpusets.  Thinking that
> > it might be caused by the zonelist patches, I went back to 25-rc2-mm1
> > w/o the patches and saw the same thing.  It sometimes takes a while for
> > the softlockups to start appearing, and I wanted to find a fairly
> > minimal duplicator.  Meanwhile 25-rc3 and rc4 have come out, so I tried
> > the latest upstream kernel and see the same thing.
> > 
> > To duplicate the problem, I need only:
> > 
> > + log into the platform as root in one window and:
> > 
> > 	echo N >/proc/sys/vm/nr_hugepages
> > 	echo 0 >proc/sys/vm/nr_hugepages
> > 
> 
> Uncool, I am going to try and find a machine to reproduce this one but
> in case I have no luck, can you try setting the following in your
> .config which may rattle out something please?
> 
> CONFIG_DEBUG_SPINLOCK=y
> CONFIG_DEBUG_MUTEXES=y
> CONFIG_DEBUG_LOCK_ALLOC=y
> CONFIG_PROVE_LOCKING=y
> CONFIG_DEBUG_SPINLOCK_SLEEP=y
> CONFIG_DEBUG_VM=y
> 
> and as you have DEBUG_INFO, can you say what line is ffffffff8027b693 ?

Will test and get back to you with info.  Slightly backed up here...

> 
> > In my case, N=64.  If I look, before echoing 0, I see 16 hugepages
> > allocated on each of the 4 nodes, as expected.
> > 
> > + then in another window, log in again.  
> > 
> > Sometimes it will hang during the 2nd login and I'll never see a shell
> > prompt. 
> 
> My initial guess was that is is something to do with page_table_lock but as
> you didn't get to fault in huge pages, it doesn't make much sense.

Yeah.  Most of my previous tests involved creating a hugetlb segment
[shm or mmap'd hugetlbfs file] and faulting in the pages.  On a whim, I
tried just allocating and freeing huge pages to/from the free list and
see the same behavior...  I'm really hoping this isn't another dumb
operator error :-(.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
