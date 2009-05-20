Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 6F6D16B0062
	for <linux-mm@kvack.org>; Wed, 20 May 2009 10:29:20 -0400 (EDT)
Date: Wed, 20 May 2009 15:29:42 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bugme-new] [Bug 13302] New: "bad pmd" on fork() of process
	with hugepage shared memory segments attached
Message-ID: <20090520142942.GB4409@csn.ul.ie>
References: <6.2.5.6.2.20090515145151.03a55298@binnacle.cx> <20090520113525.GA4409@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090520113525.GA4409@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: starlight@binnacle.cx
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Adam Litke <agl@us.ibm.com>, Eric B Munson <ebmunson@us.ibm.com>, riel@redhat.com, lee.schermerhorn@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Wed, May 20, 2009 at 12:35:25PM +0100, Mel Gorman wrote:
> On Fri, May 15, 2009 at 02:53:27PM -0400, starlight@binnacle.cx wrote:
> > Here's another possible clue:
> > 
> > I tried the first 'tcbm' testcase on a 2.6.27.7
> > kernel that was hanging around from a few months
> > ago and it breaks it 100% of the time.
> > 
> > Completely hoses huge memory.  Enough "bad pmd"
> > errors to fill the kernel log.
> > 
> 
> So I investigated what's wrong with 2.6.27.7. The problem is a race between
> exec() and the handling of mlock()ed VMAs but I can't see where. The normal
> teardown of pages is applied to a shared memory segment as if VM_HUGETLB
> was not set.
> 
> This was fixed between 2.6.27 and 2.6.28 but apparently by accident during the
> introduction of CONFIG_UNEVITABLE_LRU. This patchset made a number of changes
> to how mlock()ed are handled but I didn't spot which was the relevant change
> that fixed the problem and reverse bisecting didn't help. I've added two people
> that were working on the unevictable LRU patches to see if they spot something.
> 
> For context, the two attached files are used to reproduce a problem
> where bad pmd messages are scribbled all over the console on 2.6.27.7.
> Do something like
> 
> echo 64 > /proc/sys/vm/nr_hugepages
> mount -t hugetlbfs none /mnt
> sh ./test-tcbm.sh
> 
> I did confirm that it didn't matter to 2.6.29.1 if CONFIG_UNEVITABLE_LRU is
> set or not.  It's possible the race it still there but I don't know where
> it is.
> 
> Any ideas where the race might be?
> 

With all the grace of a drunken elephant in a china shop, I gave up on being
clever as it wasn't working and brute-force attacked this to make a list of the
commits needed for CONFIG_UNEVICTABLE_LRU on top of 2.6.27.7. This is the list

# Prereq commits for UNEVICT patches to apply
b69408e88bd86b98feb7b9a38fd865e1ddb29827 vmscan: Use an indexed array for LRU variabl
62695a84eb8f2e718bf4dfb21700afaa7a08e0ea vmscan: move isolate_lru_page() to vmscan.c
f04e9ebbe4909f9a41efd55149bc353299f4e83b swap: use an array for the LRU pagevecs
68a22394c286a2daf06ee8d65d8835f738faefa5 vmscan: free swap space on swap-in/activation
b2e185384f534781fd22f5ce170b2ad26f97df70 define page_file_cache() function
4f98a2fee8acdb4ac84545df98cccecfd130f8db vmscan: split LRU lists into anon & file sets
556adecba110bf5f1db6c6b56416cfab5bcab698 vmscan: second chance replacement
7e9cd484204f9e5b316ed35b241abf088d76e0af vmscan: fix pagecache reclaim referenced
33c120ed2843090e2bd316de1588b8bf8b96cbde more aggressively use lumpy reclaim

# Part 1: Initial patches for UNEVICTABLE_LRU
8a7a8544a4f6554ec2d8048ac9f9672f442db5a2 pageflag helpers for configed-out flags
894bc310419ac95f4fa4142dc364401a7e607f65 Unevictable LRU Infrastructure
bbfd28eee9fbd73e780b19beb3dc562befbb94fa unevictable lru: add event counting with stat
7b854121eb3e5ba0241882ff939e2c485228c9c5 Unevictable LRU Page Statistics
ba9ddf49391645e6bb93219131a40446538a5e76 Ramfs and Ram Disk pages are unevictable
89e004ea55abe201b29e2d6e35124101f1288ef7 SHM_LOCKED pages are unevictable

# Part 2: Critical patch that makes the problem go away
b291f000393f5a0b679012b39d79fbc85c018233 mlock: mlocked pages are unevictable

# Part 3: Rest of UNEVICTABLE_LRU
fa07e787733416c42938a310a8e717295934e33c doc: unevictable LRU and mlocked pages doc
8edb08caf68184fb170f4f69c7445929e199eaea mlock: downgrade mmap sem while pop mlock
ba470de43188cdbff795b5da43a1474523c6c2fb mmap: handle mlocked pages during map, remap
5344b7e648980cc2ca613ec03a56a8222ff48820 vmstat: mlocked pages statistics
64d6519dda3905dfb94d3f93c07c5f263f41813f swap: cull unevictable pages in fault path
af936a1606246a10c145feac3770f6287f483f02 vmscan: unevictable LRU scan sysctl
985737cf2ea096ea946aed82c7484d40defc71a8 mlock: count attempts to free mlocked page
902d2e8ae0de29f483840ba1134af27343b9564d vmscan: kill unused lru functions
e0f79b8f1f3394bb344b7b83d6f121ac2af327de vmscan: don't accumulate scan pressure on un
c11d69d8c830e09a0e7b3935c952afb26c48bba8 mlock: revert mainline handling of mlock erro
9978ad583e100945b74e4f33e73317983ea32df9 mlock: make mlock error return Posixly Correct

I won't get the chance to start picking apart
b291f000393f5a0b679012b39d79fbc85c018233 to see what's so special in there
until Friday but maybe someone else will spot the magic before I do.  Again,
it does not matter if UNEVICTABLE_LRU is set or not once that critical patch
is applied.

For what it's worth, this bug affects the SLES 11 kernel which is based on
2.6.27. I imagine they'd like to have this fixed but may not be so keen on
applying so many patches.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
