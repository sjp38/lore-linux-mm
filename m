Date: Sat, 5 Apr 2003 21:01:53 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: objrmap and vmtruncate
Message-ID: <20030405190153.GF1326@dualathlon.random>
References: <20030404163154.77f19d9e.akpm@digeo.com> <12880000.1049508832@flay> <20030405024414.GP16293@dualathlon.random> <20030404192401.03292293.akpm@digeo.com> <20030405040614.66511e1e.akpm@digeo.com> <20030405163003.GD1326@dualathlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030405163003.GD1326@dualathlon.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: mbligh@aracnet.com, mingo@elte.hu, hugh@veritas.com, dmccr@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Apr 05, 2003 at 06:30:03PM +0200, Andrea Arcangeli wrote:
> On Sat, Apr 05, 2003 at 04:06:14AM -0800, Andrew Morton wrote:
> > The -aa VM failed in this test.
> > 
> > 	__alloc_pages: 0-order allocation failed (gfp=0x1d2/0)
> > 	VM: killing process rmap-test
> 
> I'll work on it. Many thanks. I wonder if it could be related to the
> mixture of the access bit with the overcomplexity of the algorithm that
> makes the passes over so many vmas useless. Certainly this workload
> isn't common. I guess what I will try to do first is to simply ignore
> the accessed bitflag after half of the passes failed. What do you think?

unfortunately I can't reproduce. Booted with mem=256m on a 4-way xeon 2.5ghz:

jupiter:~ # ./rmap-test -vv -V 2 -r -i 1 -n 100 -s 600 -t 100 foo
[..]
vma 1/100 done
0/1
vma 1/100 done
0/1
vma 1/100 done
0/1
vma 1/100 done
0/1
vma 1/100 done
0/1
vma 1/100 done
0/1
vma 1/100 done
0/1
vma 1/100 done
0/1
vma 1/100 done
0/1
vma 1/100 done
0/1
vma 1/100 done
0/1
vma 1/100 done
0/1
vma 1/100 done
0/1
jupiter:~ # free
             total       used       free     shared    buffers     cached
Mem:        245804     236272       9532          0        688     216620
-/+ buffers/cache:      18964     226840
Swap:       265032       3732     261300
jupiter:~ # 

maybe it's a timing issue because I've an extremely fast storage? Or
maybe it's ext3 related, you're flushing on the filesystem and you need
to journal the inode updates at least. So maybe it's an ext3 bug not a
vm bug. I can't say it's an obvious vm bug at least, since I can't
reproduce in any way with such command line and such amount of ram (and
you see I've almost no swap and it's not even swapping heavily, it's a
server box without the 100mbyte of GUI).

could you try to run it on ext2?  I'm running it on top of ext2 at the
moment and it works flawlessy so far in this 256m configuration 4-way
(more cpus should not make differences but I can try again with 1 cpu if
you can reproduce on ext2 too).

Not a single failure, I started now an infinite loop now.

btw, I'm not running exactly 2.4.21pre5aa2, but there is not a single vm
difference between the kernel I'm testing on and 2.4.21pre5aa2, so it
shouldn't really matter.

I will try later with ext3, but now I'll leave it running for a while
with ext2 to make sure it never happens with ext2 in my hardware at
least.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
