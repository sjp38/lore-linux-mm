Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Subject: RE: [RFC] Avoiding fragmentation through different allocator
Date: Mon, 17 Jan 2005 08:48:18 -0800
Message-ID: <D36CE1FCEFD3524B81CA12C6FE5BCAB008D16A9E@fmsmsx406.amr.corp.intel.com>
From: "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

>I considered adding a new zone but I felt it would be a massive job for
>what I considered to be a simple problem. I think my approach is nice
>and isolated within the allocator itself and will be less likely to
>affect other code.

Just for clarity, I prefer this approach over adding zones, 
hence my pursuit of something akin to it.  

>On possibility is that we could say that the UserRclm and KernRclm pool
>are always eligible for hotplug and have hotplug banks only 
>satisy those
>allocations pushing KernNonRclm allocations to fixed banks. How is it
>currently known if a bank of memory is hotplug? Is there a 
>node for each
>hotplug bank? If yes, we could flag those nodes to only 
>satisify UserRclm
>and KernRclm allocations and force fallback to other nodes. 

The hardware/firmware has to tell the kernel in some way.  In 
my case it is ACPI that delineates between regions that may be 
removed.  No, there isn't a node for each bank of hot-plug 
memory.  The reason I was pursuing this was to be able to 
avoid coarse granularity distinctions like that.  Depending
on the platform, ACPI may provide only memory ranges (via
memory devices detailed in the namespace) for single node
systems or group memory ranges according to nodes via the 
ACPI abstraction called containers.  It's my understanding
that containers then have some mapping to nodes.  

>The danger is
>that allocations would fail because non-hotplug banks were already full
>and pageout would not happen because the watermarks were satisified.

Which implies a potential need for balancing between user/kernel
lists, no?    

>(Bear in mind I can't test hotplug-related issues due to lack 
>of suitable
>hardware)

Sure.  I can, although most of this has been done via emulation 
initially and then tested on real hardware soon afterwards.

>If you have already posted a version of the patch (you have 
>feedback so I
>guess it's there somewhere), can you send me a link to the thread where
>you introduced your approach? It's possible that we just need 
>to merge the
>ideas.

No, I hadn't posted it yet due to chasing a bug.  However, perhaps 
now I'll instead focus on adding the necessary hotplug support 
into your patch, hence merging the hotplug requirements/ideas?

>It's because I consider all 2^MAX_ORDER pages in a zone to be 
>equal where
>as I'm guessing you don't. Until they are split, there is 
>nothing special
>about them. It is only when it is split that I want it reserved for a
>purpose.
>
>However, if we knew there were blocks that were hot-pluggable, we could
>just have a hotplug-global and non-hotplug-global pool. If 
>it's a UserRclm
>or KernRclm allocation, split from hotplug-global, otherwise use
>non-hotplug-global. It'd increase the memory requirements of 
>the patch a
>bit though.

Exactly.  Perhaps this could just be isolated via the 
CONFIG_MEMORY_HOTPLUG build option, thus not increasing the memory
requirements in the common case...

matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
