Date: Wed, 5 Nov 2008 12:36:09 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] [REPOST #2] mm: show node to memory section
 relationship with symlinks in sysfs
Message-Id: <20081105123609.878085be.akpm@linux-foundation.org>
In-Reply-To: <20081103234808.GA13716@us.ibm.com>
References: <20081103234808.GA13716@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gary Hade <garyhade@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, y-goto@jp.fujitsu.com, pbadari@us.ibm.com, mel@csn.ul.ie, lcm@us.ibm.com, mingo@elte.hu, greg@kroah.com, dave@linux.vnet.ibm.com, nish.aravamudan@gmail.com
List-ID: <linux-mm.kvack.org>

On Mon, 3 Nov 2008 15:48:08 -0800
Gary Hade <garyhade@us.ibm.com> wrote:

> 
> Show node to memory section relationship with symlinks in sysfs
> 
> Add /sys/devices/system/node/nodeX/memoryY symlinks for all
> the memory sections located on nodeX.  For example:
> /sys/devices/system/node/node1/memory135 -> ../../memory/memory135
> indicates that memory section 135 resides on node1.
> 
> Also revises documentation to cover this change as well as updating
> Documentation/ABI/testing/sysfs-devices-memory to include descriptions
> of memory hotremove files 'phys_device', 'phys_index', and 'state'
> that were previously not described there.
> 
> In addition to it always being a good policy to provide users with
> the maximum possible amount of physical location information for
> resources that can be hot-added and/or hot-removed, the following
> are some (but likely not all) of the user benefits provided by
> this change.
> Immediate:
>   - Provides information needed to determine the specific node
>     on which a defective DIMM is located.  This will reduce system
>     downtime when the node or defective DIMM is swapped out.
>   - Prevents unintended onlining of a memory section that was 
>     previously offlined due to a defective DIMM.  This could happen
>     during node hot-add when the user or node hot-add assist script
>     onlines _all_ offlined sections due to user or script inability
>     to identify the specific memory sections located on the hot-added
>     node.  The consequences of reintroducing the defective memory
>     could be ugly.
>   - Provides information needed to vary the amount and distribution
>     of memory on specific nodes for testing or debugging purposes.
> Future:
>   - Will provide information needed to identify the memory
>     sections that need to be offlined prior to physical removal
>     of a specific node.
> 
> Symlink creation during boot was tested on 2-node x86_64, 2-node
> ppc64, and 2-node ia64 systems.  Symlink creation during physical
> memory hot-add tested on a 2-node x86_64 system.
> 
> Supersedes the "mm: show memory section to node relationship in sysfs"
> patch posted on 05 Sept 2008 which created node ID containing 'node'
> files in /sys/devices/system/memory/memoryX instead of symlinks.
> Changed from files to symlinks due to feedback that symlinks were
> more consistent with the sysfs way.
> 
> ...
>
>  Documentation/ABI/testing/sysfs-devices-memory |   51 +++++++
>  Documentation/memory-hotplug.txt               |   16 +-
>  arch/ia64/mm/init.c                            |    2 
>  arch/powerpc/mm/mem.c                          |    2 
>  arch/s390/mm/init.c                            |    2 
>  arch/sh/mm/init.c                              |    3 
>  arch/x86/mm/init_32.c                          |    2 
>  arch/x86/mm/init_64.c                          |    2 
>  drivers/base/memory.c                          |   19 +-
>  drivers/base/node.c                            |  100 +++++++++++++++
>  include/linux/memory.h                         |    6 
>  include/linux/memory_hotplug.h                 |    2 
>  include/linux/node.h                           |   13 +
>  mm/memory_hotplug.c                            |    9 -
>  14 files changed, 205 insertions(+), 24 deletions(-)

Dumb question: why do this with a symlink forest instead of, say, cat
/proc/sys/vm/mem-sections?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
