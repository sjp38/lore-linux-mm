Date: Tue, 29 Aug 2006 21:26:58 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: libnuma interleaving oddness
In-Reply-To: <20060830022621.GA5195@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0608292123230.23009@schroedinger.engr.sgi.com>
References: <20060829231545.GY5195@us.ibm.com>
 <Pine.LNX.4.64.0608291655160.22397@schroedinger.engr.sgi.com>
 <20060830002110.GZ5195@us.ibm.com> <20060830022621.GA5195@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: ak@suse.de, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, lnxninja@us.ibm.com, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Tue, 29 Aug 2006, Nishanth Aravamudan wrote:

> If I use the default hugepage-aligned hugepage-backed malloc
> replacement, I get the following in /proc/pid/numa_maps (excerpt):
> 
> 20000000 interleave=0-7 file=/libhugetlbfs/libhugetlbfs.tmp.3JbO7R\040(deleted) huge dirty=1 N0=1
> 21000000 interleave=0-7 file=/libhugetlbfs/libhugetlbfs.tmp.3JbO7R\040(deleted) huge dirty=1 N0=1
> ...
> 37000000 interleave=0-7 file=/libhugetlbfs/libhugetlbfs.tmp.3JbO7R\040(deleted) huge dirty=1 N0=1
> 38000000 interleave=0-7 file=/libhugetlbfs/libhugetlbfs.tmp.3JbO7R\040(deleted) huge dirty=1 N0=1

Is this with nodemask set to [0]?

> If I change the nodemask to 1-7, I get:
> 
> 20000000 interleave=1-7 file=/libhugetlbfs/libhugetlbfs.tmp.Eh9Bmp\040(deleted) huge dirty=1 N1=1
> 21000000 interleave=1-7 file=/libhugetlbfs/libhugetlbfs.tmp.Eh9Bmp\040(deleted) huge dirty=1 N2=1
> 22000000 interleave=1-7 file=/libhugetlbfs/libhugetlbfs.tmp.Eh9Bmp\040(deleted) huge dirty=1 N3=1
> 23000000 interleave=1-7 file=/libhugetlbfs/libhugetlbfs.tmp.Eh9Bmp\040(deleted) huge dirty=1 N4=1
> 24000000 interleave=1-7 file=/libhugetlbfs/libhugetlbfs.tmp.Eh9Bmp\040(deleted) huge dirty=1 N5=1
> 25000000 interleave=1-7 file=/libhugetlbfs/libhugetlbfs.tmp.Eh9Bmp\040(deleted) huge dirty=1 N6=1
> 26000000 interleave=1-7 file=/libhugetlbfs/libhugetlbfs.tmp.Eh9Bmp\040(deleted) huge dirty=1 N7=1
> ...
> 35000000 interleave=1-7 file=/libhugetlbfs/libhugetlbfs.tmp.Eh9Bmp\040(deleted) huge dirty=1 N1=1
> 36000000 interleave=1-7 file=/libhugetlbfs/libhugetlbfs.tmp.Eh9Bmp\040(deleted) huge dirty=1 N2=1
> 37000000 interleave=1-7 file=/libhugetlbfs/libhugetlbfs.tmp.Eh9Bmp\040(deleted) huge dirty=1 N3=1
> 38000000 interleave=1-7 file=/libhugetlbfs/libhugetlbfs.tmp.Eh9Bmp\040(deleted) huge dirty=1 N4=1

So interleave has an effect.

Are you using cpusets? Or are you only using memory policies? What is the 
default policy of the task you are running?

> If I then change our malloc implementation to (unnecessarily) mmap a
> size aligned to 4 hugepages, rather aligned to a single hugepage, but
> using a nodemask of 0-7, I get:
> 
> 20000000 interleave=0-7 file=/libhugetlbfs/libhugetlbfs.tmp.PFt0xt\040(deleted) huge dirty=4 N0=1 N1=1 N2=1 N3=1
> 24000000 interleave=0-7 file=/libhugetlbfs/libhugetlbfs.tmp.PFt0xt\040(deleted) huge dirty=4 N0=1 N1=1 N2=1 N3=1
> 28000000 interleave=0-7 file=/libhugetlbfs/libhugetlbfs.tmp.PFt0xt\040(deleted) huge dirty=4 N0=1 N1=1 N2=1 N3=1
> 2c000000 interleave=0-7 file=/libhugetlbfs/libhugetlbfs.tmp.PFt0xt\040(deleted) huge dirty=4 N0=1 N1=1 N2=1 N3=1
> 30000000 interleave=0-7 file=/libhugetlbfs/libhugetlbfs.tmp.PFt0xt\040(deleted) huge dirty=4 N0=1 N1=1 N2=1 N3=1
> 34000000 interleave=0-7 file=/libhugetlbfs/libhugetlbfs.tmp.PFt0xt\040(deleted) huge dirty=4 N0=1 N1=1 N2=1 N3=1
> 38000000 interleave=0-7 file=/libhugetlbfs/libhugetlbfs.tmp.PFt0xt\040(deleted) huge dirty=1 mapped=4 N0=1 N1=1 N2=1 N3=1

Hmm... Strange. Interleaving should continue after the last one....


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
