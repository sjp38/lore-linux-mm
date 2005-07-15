Date: Fri, 15 Jul 2005 15:30:40 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [NUMA] Display and modify the memory policy of a process through
 /proc/<pid>/numa_policy
In-Reply-To: <20050715220753.GK15783@wotan.suse.de>
Message-ID: <Pine.LNX.4.62.0507151518580.12160@schroedinger.engr.sgi.com>
References: <200507150452.j6F4q9g10274@unix-os.sc.intel.com>
 <Pine.LNX.4.62.0507142152400.2139@schroedinger.engr.sgi.com>
 <20050714230501.4a9df11e.pj@sgi.com> <Pine.LNX.4.62.0507150901500.8556@schroedinger.engr.sgi.com>
 <20050715140437.7399921f.pj@sgi.com> <20050715211210.GI15783@wotan.suse.de>
 <Pine.LNX.4.62.0507151413360.11563@schroedinger.engr.sgi.com>
 <20050715214700.GJ15783@wotan.suse.de> <Pine.LNX.4.62.0507151450570.11656@schroedinger.engr.sgi.com>
 <20050715220753.GK15783@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Paul Jackson <pj@sgi.com>, kenneth.w.chen@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 16 Jul 2005, Andi Kleen wrote:

> > > I don't believe any admin will mess with virtual addresses.
> > 
> > No but they will mess with vma's which are only identifiable by the 
> > starting virtual address.
> 
> What for? 

For page migration.

> > Look at the existing patches and you see a huge complexity and heuristics 
> > because the kernel guesses which vma's to migrate. If the vma are 
> They kernel doesn't guess, it knows exactly.

Maybe you need to reread the discussion on page migration that ended up 
with filesystem modifications?

> > > Now I can see some people being interested in more fine grained
> > > policy, but the only sane way to do that is to change the source
> > > code and use libnuma.
> > 
> > Can libnuma change the memory policy and move pages of existing processes?
> 
> If someone hooks it into mbind() sure. But most likely 
> such changes would be handled by migrate_pages()

I cannot imagine that migrate pages make it into the kernel in its 
current form. It combines multiple functionalities that need to be 
separate (it does update the memory policy, clears the page cache, deals 
with memory policy translations and then does heuristics to guess which 
vma's to transfer) and then provides a complex function moving of pages 
between groups of nodes.

Therefore:

1. Updating the memory policy is something that can be useful in other 
   settings as well so it need to be separate. The patch we are discussing
   does exactly that. The batch scheduler or the sysadmin can invoke this
   functionality before migrating pages if necessary.

2. Clearing the page cache is some work pursued by someone else. The batch
   scheduler or the sysadmin can invoke this function if necessary before
   migrating pages.

3. Memory policy translations better be done in user space. The batch
   scheduler /sysadmin knows which node has what pages so it can easily 
   develop page movement scheme that is optimal for the process.

4. Moving pages should be a simple function like

   migrate_pages(vma, from-node, nr-pages, to-node)

   The batch scheduler / sysadmin can invoke this function multiple times
   to move groups of nodes or only move parts of memory from a node (which
   was not really supported by Ray's migrate pages instead another 
   heuristics guessed how much to move and there was no option of 
   partial moves).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
