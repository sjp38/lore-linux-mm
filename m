Received: by fk-out-0910.google.com with SMTP id 22so730735fkq.6
        for <linux-mm@kvack.org>; Fri, 11 Apr 2008 12:57:26 -0700 (PDT)
Message-ID: <29495f1d0804111257w787de80ew3c2c2be54d34685f@mail.gmail.com>
Date: Fri, 11 Apr 2008 12:57:25 -0700
From: "Nish Aravamudan" <nish.aravamudan@gmail.com>
Subject: Re: [patch 00/17] multi size, and giant hugetlb page support, 1GB hugetlb for x86
In-Reply-To: <20080411082858.GB20253@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080410170232.015351000@nick.local0.net>
	 <29495f1d0804101659r44f4a8c2wa1ec05a84e7876fe@mail.gmail.com>
	 <20080411082858.GB20253@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pj@sgi.com, andi@firstfloor.org, kniht@linux.vnet.ibm.com, Adam Litke <agl@us.ibm.com>, Greg KH <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

[Trimming Andi's SUSE address, as it gave me permanent failures on my
last message]

On 4/11/08, Nick Piggin <npiggin@suse.de> wrote:
> On Thu, Apr 10, 2008 at 04:59:15PM -0700, Nish Aravamudan wrote:
>  > Hi Nick,
>  >
>  > On 4/10/08, npiggin@suse.de <npiggin@suse.de> wrote:
>  > > Hi,
>  > >
>  > >  I'm taking care of Andi's hugetlb patchset now. I've taken a while to appear
>  > >  to do anything with it because I have had other things to do and also needed
>  > >  some time to get up to speed on it.
>  > >
>  > >  Anyway, from my reviewing of the patchset, I didn't find a great deal
>  > >  wrong with it in the technical aspects. Taking hstate out of the hugetlbfs
>  > >  inode and vma is really the main thing I did.
>  >
>  > Have you tested with the libhugetlbfs test suite? We're gearing up for
>  > libhugetlbfs 1.3, so most of the test are uptodate and expected to run
>  > cleanly, even with giant hugetlb page support (Jon has been working
>  > diligently to test with his 16G page support for power). I'm planning
>  > on pushing the last bits out today for Adam to pick up before we start
>  > stabilizing for 1.3, so I'm hoping if you grab tomorrow's development
>  > snapshot from libhugetlbfs.ozlabs.org, things should run ok. Probably
>  > only with just 1G hugepages, though, we haven't yet taught
>  > libhugetlbfs about multiple hugepage size availability at run-time,
>  > but that shouldn't be hard.
>
>
> Yeah, it should be easy to disable the 2MB default and just make it
>  look exactly the same but with 1G pages.

Exactly.

>  Thanks a lot for your suggestion, I'll pull the snapshot over the
>  weekend and try to make it pass on x86 and work with Jon to ensure it
>  is working with powerpc...

Just FYI, we tagged 1.3-pre1 today and it's out now:
http://libhugetlbfs.ozlabs.org/releases/libhugetlbfs-1.3-pre1.tar.gz.

The kernel tests should work fine on x86 as is, even with 1G pages. I
expect some of the linker script testcases to fail, though, as they
will require alignment changes, I think (Adam is actually reworking
the segment remapping code for libhugetlbfs 2.0, which will release
shortly after 1.3, under our current plans).

>  > >  However on the less technical side, I think a few things could be improved,
>  > >  eg. to do with the configuring and reporting, as well as the "administrative"
>  > >  type of code. I tried to make improvements to things in the last patch of
>  > >  the series. I will end up folding this properly into the rest of the patchset
>  > >  where possible.
>  >
>  > I've got a few ideas here. Are we sure that
>  > /proc/sys/vm/nr_{,overcommit}_hugepages is the pool allocation
>  > interface we want going forward? I'm fairly sure we don't. I think
>  > we're best off moving to a sysfs-based allocator scheme, while keeping
>  > /proc/sys/vm/nr_{,overcommit}_hugepages around for the default
>  > hugepage size (which may be the only for many folks for now).
>  >
>  > I'm thinking something like:
>  >
>  > /sys/devices/system/[DIRNAME]/nr_hugepages ->
>  > nr_hugepages_{default_hugepagesize}
>  > /sys/devices/system/[DIRNAME]/nr_hugepages_default_hugepagesize
>  > /sys/devices/system/[DIRNAME]/nr_hugepages_other_hugepagesize1
>  > /sys/devices/system/[DIRNAME]/nr_hugepages_other_hugepagesize2
>  > /sys/devices/system/[DIRNAME]/nr_overcommit_hugepages ->
>  > nr_overcommit_hugepages_{default_hugepagesize}
>  > /sys/devices/system/[DIRNAME]/nr_overcommit_hugepages_default_hugepagesize
>  > /sys/devices/system/[DIRNAME]/nr_overcommit_hugepages_other_hugepagesize1
>  > /sys/devices/system/[DIRNAME]/nr_overcommit_hugepages_other_hugepagesize2
>  >
>  > That is, nr_hugepages in the directory (should it be called vm?
>  > memory? hugepages specifically? I'm looking for ideas!) will just be a
>  > symlink to the underlying default hugepagesize allocator. The files
>  > themselves would probably be named along the lines of:
>  >
>  > nr_hugepages_2M
>  > nr_hugepages_1G
>  > nr_hugepages_64K
>  >
>  > etc?
>
>
> Yes I don't like the proc interface, nor the way it has been extended
>  (although that's not Andi's fault it is just a limitation of the old
>  API).

Agreed, I wasn't trying to blame you or Andi for the choice. Just
suggesting we nip the extension in the bud :)

>  I think actually we should have individual directories for each hstate
>  size, and we can put all other stuff (reservations and per-node stuff
>  etc) under those directories. Leave the proc stuff just for the default
>  page size.
>
>  I think it should go in /sys/kernel/, because I think /sys/devices is
>  more of the hardware side of the system (so it makes sense for
>  reporting eg the actual supported TLB sizes, but for configuring your
>  page reserves, I think it makes more sense under /sys/kernel/). But
>  we'll ask the sysfs folk for guidance there.

That's a good point. I've added Greg explicitly to the Cc, to see if
he has any input. Greg, for something like an allocator interface for
hugepages, where would you expect to see that put in the sysfs
hierarchy? /sys/devices/system or /sys/kernel ?

The reason I was suggesting /sys/devices/system is that we already
have the NUMA topology laid out there (and is where I currently have
the per-node nr_hugepages). If we put per-node allocations in
/sys/kernel, we would have to duplicate some of that information (or
have really long filenames), and I'm not sure which is better.

Also, for reference, can we not use "reservations" for the pool
allocators? Reserved huge pages have a special meaning (are used to
satisfy MAP_SHARED mmap()s -- see
http://linux-mm.org/DynamicHugetlbPool). I'm not sure of a better
terminology, beyond perhaps "hugetlb pool interfaces" or something. I
know what you mean, but it got me confused for a second or two :)

>  > We'd want to have a similar layout on a per-node basis, I think (see
>  > my patchsets to add a per-node interface).
>  >
>  > >  The other thing I did was try to shuffle the patches around a bit. There
>  > >  were one or two (pretty trivial) points where it wasn't bisectable, and also
>  > >  merge a couple of patches.
>  > >
>  > >  I will try to get this patchset merged in -mm soon if feedback is positive.
>  > >  I would also like to take patches for other architectures or any other
>  > >  patches or suggestions for improvements.
>  >
>  > There are definitely going to be conflicts between my per-node stack
>  > and your set, but if you agree the interface should be cleaned up for
>  > multiple hugepage size support, then I'd like to get my sysfs bits
>  > into -mm and work on putting the global allocator into sysfs properly
>  > for you to base off. I think there's enough room for discussion that
>  > -mm may be a bit premature, but that's just my opinion.
>  >
>  > Thanks for keeping the patchset uptodate, I hope to do a more careful
>  > review next week of the individual patches.
>
>
> Sure, I haven't seen your work but it shouldn't be terribly hard to merge
>  either way. It should be easy if we work together ;)

I'll make sure to Cc you on the patches that will conflict. If we
decide that /sys/kernel is the right place for the per-node interface
to live, too, then I will need to respin them anyways.

As a side note, I don't think I saw any patches for Documentation in
the last posted set :) Could you update that, it might help with
understanding the changes a bit, although most are pretty
straightforward. It would also be great to update
http://linux-mm.org/PageTableStructure for the 1G case (and eventually
the power 16G case, Jon).

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
