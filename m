Date: Thu, 14 Jul 2005 22:07:42 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: RE: [NUMA] Display and modify the memory policy of a process through
 /proc/<pid>/numa_policy
In-Reply-To: <200507150452.j6F4q9g10274@unix-os.sc.intel.com>
Message-ID: <Pine.LNX.4.62.0507142152400.2139@schroedinger.engr.sgi.com>
References: <200507150452.j6F4q9g10274@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: linux-mm@kvack.org, linux-ia64@vger.kernel.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, 14 Jul 2005, Chen, Kenneth W wrote:

> > Additionally the patch also adds write capability to the "numa_maps". One
> > can write a VMA address followed by the policy to that file to change the
> > mempolicy of an individual virtual memory area. i.e.
> 
> This looks a lot like a back door access to libnuma and numactl capability.
> Are you sure libnuma and numactl won't suite your needs?

The functionality offered here is different. numactl's main concern is 
starting processes. libnuma is mostly concerned with a process 
controlling its own memory allocation.

This is an implementation that deals with monitoring and managing running 
processes. For an effective batch scheduler we need outside control 
over memory policy. It needs to be easy to see what is going on in the 
system (numa_maps) and easy to manipulate (numa_policy).

These two control files allow the monitor and control of the memory policy 
of an existing process down to the vma level.

I plan to add another patch soon that will then also tie page migration 
into this. Basically this will be implemented by allowing to do

echo "<vma-address> N<sourcenode>(<nr-pages) <targetnode>" 
>/proc/<pid>/numa_maps

(echoing the output format of numa maps)

Doing page migration at the vma level avoids the necessity to analyze the 
vma's of a process in kernel space and simplifies the implementation of 
page migration significantly. A batch scheduler or a system 
administrator can control individual vma's. They can make their own 
decisions if a shared library should be migrated or not etc.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
