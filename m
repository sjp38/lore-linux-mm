Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3OH600w010960
	for <linux-mm@kvack.org>; Thu, 24 Apr 2008 13:06:00 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3OH8SUd135576
	for <linux-mm@kvack.org>; Thu, 24 Apr 2008 11:08:28 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3OH8SJa008494
	for <linux-mm@kvack.org>; Thu, 24 Apr 2008 11:08:28 -0600
Date: Thu, 24 Apr 2008 10:08:04 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 00/18] multi size, and giant hugetlb page support, 1GB
	hugetlb for x86
Message-ID: <20080424170804.GB8451@us.ibm.com>
References: <20080423015302.745723000@nick.local0.net> <480EEDD9.2010601@firstfloor.org> <20080423153404.GB16769@wotan.suse.de> <20080423154652.GB29087@one.firstfloor.org> <20080423155338.GF16769@wotan.suse.de> <20080423185223.GE10548@us.ibm.com> <20080424020828.GA7101@wotan.suse.de> <20080424064350.GA17886@us.ibm.com> <20080424070624.GA14543@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080424070624.GA14543@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-mm@kvack.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On 24.04.2008 [09:06:24 +0200], Nick Piggin wrote:
> On Wed, Apr 23, 2008 at 11:43:50PM -0700, Nishanth Aravamudan wrote:
> > On 24.04.2008 [04:08:28 +0200], Nick Piggin wrote:
> > > On Wed, Apr 23, 2008 at 11:52:23AM -0700, Nishanth Aravamudan wrote:
> > > > On 23.04.2008 [17:53:38 +0200], Nick Piggin wrote:
> > > > > > It's not fully compatible. And that is bad.
> > > > > 
> > > > > It is fully compatible because if you don't actually ask for
> > > > > any new option then you don't get it. What you see will be
> > > > > exactly unchanged.  If you ask for _only_ 1G pages, then this
> > > > > new scheme is very likely to work with well written
> > > > > applications wheras if you also print out the 2MB legacy
> > > > > values first, then they have little to no chance of working.
> > > > > 
> > > > > Then if you want legacy apps to use 2MB pages, and new ones to
> > > > > use 1G, then you ask for both and get the 2MB column printed
> > > > > in /proc/meminfo (actually it can probably get printed 2nd if
> > > > > you ask for 2MB pages after asking for 1G pages -- that is
> > > > > something I'll fix).
> > > > 
> > > > Yep, the "default hugepagesz" was something I was going to ask
> > > > about. I believe hugepagesz= should function kind of like
> > > > console= where the order matters if specified multiple times for
> > > > where /dev/console points.  I agree with you that hugepagesz=XX
> > > > hugepagesz=YY implies XX is the
> > > > default, and YY is the "other", regardless of their values, and that is
> > > > how they should be presented in meminfo.
> > > 
> > > OK, that would be fine. I was going to do it the other way and
> > > make 2M always come first. However so long as we document as such
> > > the command line parameters, I don't see why we couldn't have this
> > > extra flexibility (and that means I shouldn't have to write any
> > > more code ;))
> > 
> > Keep in mind, I did retract this to some extent in my other
> > reply...After thinking about Andi's points a bit more, I believe the
> > most flexible (not too-x86_64-centric, either) option is to have all
> > potential hugepage sizes be "available" at run-time. What hugepages
> > are allocated at boot-time is all that is specified on the kernel
> > command-line, in that case (and is only truly necessary for the
> > ginormous hugepages, and needs to be heavily documented as such).
> > 
> > Realistically, yes, we could have it either way (hugepagesz=
> > determines the order), but it shouldn't matter to well-written
> > applications, so keeping things reflecting current reality as much
> > as possible does make sense -- that is, 2M would always come first
> > meminfo on x86_64.
> > 
> > If you want, I can send you a patch to do that, as I start the sysfs
> > patches.
> 
> Honestly, I don't really care about the exact behaviour and user APIs.
> 
> I agree with the point Andi stresses that backwards compatibility is
> #1 priority; and with unchanged kernel command line / config options,
> I think we need to have /proc/meminfo give *unchanged* (ie. single
> column) output.

Ok -- so meminfo will have one format (single column) if the command
line is unchanged, and a different one if, say "hugepagesz=1G" is
specified?

Should we just leave the default hugepage size info in /proc/meminfo
(always single column) and use sysfs for everything else? Including
hugepage meminfo's on a page-size basis? I guess that would violate
sysfs rules, but might be fine for a proof-of-concept?

> Second, future apps obviously should use some more appropriate sysfs
> tunables and be aware of multiple hstates.

Indeed.

> Finally, I would have thought people would be interested in *trying*
> to get legacy apps to work with 1G hugepages (eg. oracle/db2 or HPC
> stuff could probably make use of them quite nicely). However this 3rd
> consideration is obviously the least important of the 3. I wouldn't
> lose any sleep if my option doesn't get in.

Well, there are two interfaces, right?

1) SHM_HUGETLB
  I'm not sure how to extend this best. iirc, SHM_HUGETLB uses an
  internal (invisible) hugetlbfs mount. And I don't think it specifies a
  size or anything to said mount...so unless *only* 1G hugepages are
  available (which we've decided will not be the case?), I believe
  SHM_HUGETLB as currently used will never use them.

2) hugetlbfs
  By mounting hugetlbfs with size= (I believe), we can specify which
  pool should be accessed by files in the mount. This is what
  libhugetlbfs would leverage to use different hugepage sizes. There has
  been some discussion on that list and among some of us working on
  libhugetlbfs on how best to allow applications to specify the size
  they'd prefer. Eric Munson has been working on a binary (hugectl) to
  demonstrate hugepage-backed stacks in-kernel, which might be
  extended to include a --preferred-size flag (it's essentially an
  exec() wrapper, in the same vein as numactl). In any case,
  libhugetlbfs could be used (by only mounting the 1G sized hugetlbfs)
  for legacy apps without modification (well segment remapping may not
  work due to alignments, but should be easy to fix, and will probably
  be fixed in 2.0, which will change our remapping algorithm).

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
