Subject: Re: [RFC] memory defragmentation to satisfy high order allocations
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20041003.131338.41636688.taka@valinux.co.jp>
References: <20041001234200.GA4635@logos.cnet>
	 <20041002.183015.41630389.taka@valinux.co.jp>
	 <20041002183349.GA7986@logos.cnet>
	 <20041003.131338.41636688.taka@valinux.co.jp>
Content-Type: text/plain
Message-Id: <1096856540.3684.7610.camel@localhost>
Mime-Version: 1.0
Date: Sun, 03 Oct 2004 19:22:20 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: marcelo.tosatti@cyclades.com, IWAMOTO Toshihiro <iwamoto@valinux.co.jp>, Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>, piggin@cyberone.com.au, Arjan van de Ven <arjanv@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sat, 2004-10-02 at 21:13, Hirokazu Takahashi wrote:
> > Questions: are there any documents on the memory hotplug userspace tools? 
> > Where can I find them?
> 
> IBM guys and Fujitsu guys are designing user interface independently.
> IBM team is implementing memory section hotplug while Fujitsu team
> try to implement NUMA node hotplug. But both of the designs use
> regular hot-plug mechanism, which kicks /sbin/hotplug script to control
> devices via sysfs.
> 
> Dave, would you explain about it?

First of all, we're still on the first set of these APIs.  So, either
we're really, really smart (unlikely) or we have a few revisions an
rewrites to go before everybody is happy.

ls /sys/devices/system/memory/ gives you each memory area, with
arbitrary numbers like this:
memory0
memory1
memory2
memory8953

We haven't decided whether to make each of those represent a constant
sized area, or let them be variable.  In any case, there will either be
a range inside of each or a global block size something like here:

	/sys/devices/system/memory/block_size

Each memory device would have a directory like this:

# ls /sys/devices/system/memory/memory8953/
node -> ../../node/node4 (for the NUMA case)
state
phys_start_addr

To take a memory section offline, you 
		
	echo offline > /sys/devices/system/memory/memory8953/state

For now, that takes the section offline by allocating all of its pages
and migrating the test.  It also removes the sysfs node, triggering a
/sbin/hotplug event for the device removal.  We might makes this 2
different states in the future (offline and removal).  This could also
potentially be triggered by hardware alone.

For now, you can also add memory, but it's hackish and will certainly
change:

	echo 0x8000000 > /sys/devices/system/memory/probe

will add SECTION_SIZE amount of memory at 2GB.  Yes, SECTION_SIZE is
hard-coded, but this is only for testing.  We'll eventually take ranges
and maybe NUMA information into there somehow.  Why can't the hardware
just do this?  It's a long story :)

-- 
Dave Hansen
haveblue@us.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
