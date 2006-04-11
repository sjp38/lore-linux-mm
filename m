Date: Tue, 11 Apr 2006 11:46:30 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2.6.17-rc1-mm1 0/6] Migrate-on-fault - Overview
In-Reply-To: <1144441108.5198.36.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0604111134350.1027@schroedinger.engr.sgi.com>
References: <1144441108.5198.36.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>, ak@suse.com
List-ID: <linux-mm.kvack.org>

On Fri, 7 Apr 2006, Lee Schermerhorn wrote:

> Note that this mechanism can be used to migrate page cache pages that 
> were read in earlier, are no longer referenced, but are about to be
> used by a new task on another node from where the page resides.  The
> same mechanism can be used to pull anon pages along with a task when
> the load balancer decides to move it to another node.  However, that
> will require a bit more mechanism, and is the subject of another
> patch series.

The fundamental assumption in these patchsets is that memory policies are 
permanently used to control allocation. However, allocation policies may 
be temporarily set to various allocation methods in order to allocate 
certain memory structures in special ways. The policy may be reset later 
and not reflect the allocation wanted for a certain structure when the 
opportunistic or lazy migration takes place.

Maybe we can use the memory polices in the way you suggest (my 
MPOL_MF_MOVE_* flags certainly do the same but they are set by the coder 
of the user space application who is aware of what is going on !). 

But there are significant components missing to make this work the right 
way. In particular file backed pages are not allocated according to vma 
policy. Only anonymous pages are. So this would only work correctly for 
anonymous pages that are explicitly shifted onto swap. 

I think there will be mostly correct behavior for file backed pages. Most 
processes do not use policies at all and so this will move the file 
backed page to the node where the process is executing. If the process 
frequently refers to the page then the effort that was expended is 
justified. However, if the page is not frequently references then the 
effort required to migrate the page was not justified.

For some processes this has the potential to actually decreasing the 
performance, for other processes that are using memory policies to 
control the allocation of structures it may allocate the page in a way 
that the application tried to avoid because it may be using the wrong 
memory policy.

Then there is the known deficiency that memory policies do not work with 
file backed pages. I surely wish that this would be addressed first.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
