Message-ID: <41DADFB9.2090607@sgi.com>
Date: Tue, 04 Jan 2005 12:26:01 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: process page migration
References: <41D99743.5000601@sgi.com>	<1104781061.25994.19.camel@localhost>	 <41D9A7DB.2020306@sgi.com> <20050104.234207.74734492.taka@valinux.co.jp>	 <41DAD2AF.80604@sgi.com> <1104860456.7581.21.camel@localhost>
In-Reply-To: <1104860456.7581.21.camel@localhost>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, linux-mm <linux-mm@kvack.org>, Rick Lindsley <ricklind@us.ibm.com>, "Matthew C. Dobson [imap]" <colpatch@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> On Tue, 2005-01-04 at 11:30 -0600, Ray Bryant wrote:
> 
>
> 
> 
> We already have scheduler code which has some knowledge of when a
> process is dragged from one node to another.  Combined with the per-node
> RSS, could we make a decision about when a process needs to have
> migration performed on its pages on a more automatic basis, without the
> syscalls?
> 

The only time I am proposing to do process and memory migration is in
response to requests issued from userspace.  This is not an automatic
process (see below for more details.)

> We could have a tunable for how aggressive this mechanism is, so that
> the process wouldn't start running again on the more strict SGI machines
> until a very large number of the pages are pulled over.  However, on
> machines where process latency is more of an issue, the tunable could be
> set to a much less aggressive value.
> 
> This would give normal, somewhat less exotic, NUMA machines the benefits
> of page migration without the need for the process owner to do anything
> manually to them, while also making sure that we keep the number of
> interfaces to the migration code to a relative minimum.  
> 
> -- Dave
> 
>

What I am working on is indeed manual process and page migration in a NUMA
system.  Specifically, we are running with cpusets, and the idea is to
support moving a job from one cpuset to another in response to batch scheduler
related decisions.  (The basic scenario is that a bunch of jobs are running,
each in its own cpuset, when a new high priority job arrives at the batch
scheduler.  The batch scheduler will pick some job to suspend, and start
the new job in that cpuset.  At some later point, one of the other jobs
finishes, and the scheduler now decides to move the suspended job to the
newly free cpuset.)  However, I don't want to tie the migration code I
am working on into cpusets, since the future of that is still uncertain.

Hence the migration system call I am proposing is something like:

     migrate_process_pages(pid, numnodes, old_node_list, new_node_list)

where the node lists are one dimensional arrays of size numnodes.
Pages on old_node_list[i] are moved to new_node_list[i].

(If cpusets exist on the underlying system, we will use the cpuset
infrastructure to tell us which pid's need to be moved.)

The only other new system call needed is something to update the memory
policy of the process to correspond to the new set of nodes.

Existing interfaces can be used to do the rest of the migration
functionality.

SGI's experience with automatically detecting when to pull pages from one
node to another based on program usage patterns has not been good.  IRIX
supported this kind of functionality, and all it ever seemed to do was to
move the wrong page at the wrong time (so I am told; it was before my time
with SGI...)

-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
