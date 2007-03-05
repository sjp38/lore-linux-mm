Date: Mon, 5 Mar 2007 10:54:43 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Merged Zone / Node in order to do containers etc easily?
Message-ID: <Pine.LNX.4.64.0703051046510.6913@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

We have talked a bit in the last days about eventually getting rid of 
either nodes or zones.

If one would merge the nodes and the zones struct this would be possible. 
Actually the current kernel supports something like it if the 
following config options are not set

CONFIG_ZONE_DMA
CONFIG_ZONE_DMA32
CONFIG_HIGHMEM

In that case we only have a single zone per node but no support anymore 
for DMA zones or highmem. We save the bits in the page->flags that are 
usually used to identify the zone. For simplicities sake lets just call 
these node / zone entities "zone".

Let say we have also CONFIG_NUMA set. Then

A. We could add more "zones" via node hotplug.
B. We can identify the zones via a node number from user space and direct 
   allocations to a specfic "zone".
C. We can migrate memory between "zones"
D. We have an indication how favorably these "zones" are to be used given
   their SLIT distance.

Lets call these "zones" that were generated during bootup "base zones".

Now we need some additional functionality. In particular we want to be 
able to put some memory dynamically into containers and we need to find a 
replacement for the DMA zones.

Lets create a new type of zones called "derived zones". These are based on 
base zone. An arbitrary number of MAX_ORDER blocks can be moved to these 
and then they function like a regular "zone". They can be dynamically 
created and deleted via the node hotplug interfaces.

So if we create a new container then we create a new zone and extract a 
number of MAX_ORDER blocks from a base zone. The zone functions like a 
base zone for the time that it exists and thus we have all the usual 
accounting for the zone and do not need to add them separately. Reclaim 
will work as for base zones etc etc. (this only works if we have MAX_ORDER 
blocks available, thus we would need Mel's defrag patches). Applications 
can be restricted to a container or containers by the cpuset 
functionality. The build in process migration in cpusets can move 
applications. Processes can be manually moved through page migration.

If we need some DMA zones for a particular device then we can also create 
a new zone and extract pages in a certain range from the base zone. This 
could occur dynamically (but early during boot so that the low end pages 
in a zone have not been used yet) if we discover that devices exist that 
need restricted memory pools. Moreover these zones could be custom sized 
for the devices that are challenged in a particular way. For example we 
could dynamically create a pool for a 2GB pool for the strange SCSI device 
that can only reliable do DMA using a 31 bit address.

That leaves the HIGHMEM out cold so far but HIGHMEM is not needed on 64 
bit platforms as far as I can tell. Maybe HIGHMEM could also be some sort 
of derived zone with memory taken from the base zone used as the memmap 
and as bounce buffers etc?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
