Date: Fri, 15 Jul 2005 14:20:12 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [NUMA] Display and modify the memory policy of a process through
 /proc/<pid>/numa_policy
In-Reply-To: <20050715211210.GI15783@wotan.suse.de>
Message-ID: <Pine.LNX.4.62.0507151413360.11563@schroedinger.engr.sgi.com>
References: <200507150452.j6F4q9g10274@unix-os.sc.intel.com>
 <Pine.LNX.4.62.0507142152400.2139@schroedinger.engr.sgi.com>
 <20050714230501.4a9df11e.pj@sgi.com> <Pine.LNX.4.62.0507150901500.8556@schroedinger.engr.sgi.com>
 <20050715140437.7399921f.pj@sgi.com> <20050715211210.GI15783@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Paul Jackson <pj@sgi.com>, kenneth.w.chen@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 15 Jul 2005, Andi Kleen wrote:

> > These questions of interface style (filesys or syscall) probably don't
> > matter, however. at least not yet.  First we need to make sense of
> > the larger issues that Ken and Andi raise, of whether this is a good
> > thing to do.
> 
> In my opinion detailed reporting of node affinity to external
> processes of specific memory areas is a mistake. It's too finegrained and 
> not useful outside the process itself (external users don't or shouldn't
> know anything about process virtual addresses). The information
> is too volatile and can change every time without nice 
> ways to lock (no SIGSTOP is not a acceptable way) 

It is very useful to a batch scheduler that can dynamically move memory 
between nodes. It needs to know exactly where the pages are including the 
vma information. It is also of utmost importance to a sysadmin that wants 
to control the memory placement of an important application to have 
information about the process and be able to influence future allocations 
as well as to move existing pages.

The volatility has to be taken into account by the batch scheduler or by 
the sysadmin manipulating the program. Typically both know much more about 
the expected and future behavior of the application than the kernel.

And yes SIGSTOP is acceptable if the application behavior on STOP -> 
Continue is know by the administrator or the batch scheduler. I do not 
think that this is required though.

Image an important batch data run that has been running for 2 days and 
will run 3 more days. Now some nodes are running out of memory and the 
performance suffers. The batch scheduler / or sysadmin will be able to 
inspect the situation and improve the performance by changing memory 
policies and/or moving pages. The batch scheduler / admin knows about 
which processes are important and may stop other processes in order for 
the critical process to finish in time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
