Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e34.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id mAEGfUeV019642
	for <linux-mm@kvack.org>; Fri, 14 Nov 2008 09:41:30 -0700
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAEGfika127280
	for <linux-mm@kvack.org>; Fri, 14 Nov 2008 09:41:47 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mAEGfUdE032430
	for <linux-mm@kvack.org>; Fri, 14 Nov 2008 09:41:31 -0700
Date: Fri, 14 Nov 2008 08:41:25 -0800
From: Gary Hade <garyhade@us.ibm.com>
Subject: Re: [PATCH] [REPOST #2] mm: show node to memory section
	relationship with symlinks in sysfs
Message-ID: <20081114164125.GA7108@us.ibm.com>
References: <20081103234808.GA13716@us.ibm.com> <1226528175.4835.18.camel@badari-desktop> <20081113165402.GA7084@us.ibm.com> <1226678717.16616.2.camel@badari-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1226678717.16616.2.camel@badari-desktop>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Gary Hade <garyhade@us.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Nish Aravamudan <nish.aravamudan@gmail.com>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 14, 2008 at 08:05:17AM -0800, Badari Pulavarty wrote:
> On Thu, 2008-11-13 at 08:54 -0800, Gary Hade wrote:
> > On Wed, Nov 12, 2008 at 02:16:15PM -0800, Badari Pulavarty wrote:
> > > On Mon, 2008-11-03 at 15:48 -0800, Gary Hade wrote:
> > > > Show node to memory section relationship with symlinks in sysfs
> > > > 
> > > > Add /sys/devices/system/node/nodeX/memoryY symlinks for all
> > > > the memory sections located on nodeX.  For example:
> > > > /sys/devices/system/node/node1/memory135 -> ../../memory/memory135
> > > > indicates that memory section 135 resides on node1.
> > > > 
> > > > Also revises documentation to cover this change as well as updating
> > > > Documentation/ABI/testing/sysfs-devices-memory to include descriptions
> > > > of memory hotremove files 'phys_device', 'phys_index', and 'state'
> > > > that were previously not described there.
> > > > 
> > > > In addition to it always being a good policy to provide users with
> > > > the maximum possible amount of physical location information for
> > > > resources that can be hot-added and/or hot-removed, the following
> > > > are some (but likely not all) of the user benefits provided by
> > > > this change.
> > > > Immediate:
> > > >   - Provides information needed to determine the specific node
> > > >     on which a defective DIMM is located.  This will reduce system
> > > >     downtime when the node or defective DIMM is swapped out.
> > > >   - Prevents unintended onlining of a memory section that was 
> > > >     previously offlined due to a defective DIMM.  This could happen
> > > >     during node hot-add when the user or node hot-add assist script
> > > >     onlines _all_ offlined sections due to user or script inability
> > > >     to identify the specific memory sections located on the hot-added
> > > >     node.  The consequences of reintroducing the defective memory
> > > >     could be ugly.
> > > >   - Provides information needed to vary the amount and distribution
> > > >     of memory on specific nodes for testing or debugging purposes.
> > > > Future:
> > > >   - Will provide information needed to identify the memory
> > > >     sections that need to be offlined prior to physical removal
> > > >     of a specific node.
> > > > 
> > > > Symlink creation during boot was tested on 2-node x86_64, 2-node
> > > > ppc64, and 2-node ia64 systems.  Symlink creation during physical
> > > > memory hot-add tested on a 2-node x86_64 system.
> > > > 
> > > > Supersedes the "mm: show memory section to node relationship in sysfs"
> > > > patch posted on 05 Sept 2008 which created node ID containing 'node'
> > > > files in /sys/devices/system/memory/memoryX instead of symlinks.
> > > > Changed from files to symlinks due to feedback that symlinks were
> > > > more consistent with the sysfs way.
> > > > 
> > > > Supersedes the "mm: show node to memory section relationship with
> > > > symlinks in sysfs" patch posted on 29 Sept 2008 to address a Yasunori
> > > > Goto reported problem where an incorrect symlink was created due to
> > > > a range of uninitialized pages at the beginning of a section.  This
> > > > problem which produced a symlink in /sys/devices/system/node/node0
> > > > that incorrectly referenced a mem section located on node1 is corrected
> > > > in this version.  This version also covers the case were a mem section
> > > > could span multiple nodes.
> > > > 
> > > > Supersedes the "mm: show node to memory section relationship with
> > > > symlinks in sysfs" patch posted on 09 Oct 2008 to add the Andrew
> > > > Morton requested usefulness information and update to apply cleanly
> > > > to 2.6.28-rc3 and 2.6-git.  Code is unchanged.
> > > > 
> > > > Signed-off-by: Gary Hade <garyhade@us.ibm.com>
> > > > Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>
> > > > 
> > > 
> > > Hi Gary,
> > > 
> > > While testing latest mmtom (which has this patch) ran into an issue
> > > with sysfs files. What I noticed was, with this patch "memoryXX"
> > > directories in /sys/devices/system/memory/ are not getting cleaned up.
> > > Backing out the patch seems to fix the problem. 
> > > 
> > > When I tried to remove 64 blocks of memory, empty  directories are
> > > stayed around. (look at memory151 - memory215). This is causing OOPS
> > > while trying to add memory block again. I think this could be because 
> > > of the symlink added from node directory.  Can you look ?
> > 
> > Badari, The call to unregister_mem_sect_under_nodes() in
> > remove_memory_block() preceding the removal of the files in
> > the memory section directory _should have_ removed all the
> > symlinks referencing the memory section directory.  Did you
> > happen to check to see if the symlinks to memory151-memory215
> > were still present?
> > 
> > Gary
> > 
> 
> Hi Gary,
> 
> As discussed earlier, patch is leaving an extra reference on the
> memoryX directory. Needs a kobject_put() to match the reference
> you get in find_memory_block().

Badari, Thanks again for finding that!

> 
> Could you update the patch and resend it ?

Will do.

Gary

-- 
Gary Hade
System x Enablement
IBM Linux Technology Center
503-578-4503  IBM T/L: 775-4503
garyhade@us.ibm.com
http://www.ibm.com/linux/ltc

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
