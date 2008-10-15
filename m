Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9FAbuMf012305
	for <linux-mm@kvack.org> (envelope-from y-goto@jp.fujitsu.com);
	Wed, 15 Oct 2008 19:37:56 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 38E9D2AC026
	for <linux-mm@kvack.org>; Wed, 15 Oct 2008 19:37:56 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F3F8612C0AC
	for <linux-mm@kvack.org>; Wed, 15 Oct 2008 19:37:55 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id CCCEC1DB8043
	for <linux-mm@kvack.org>; Wed, 15 Oct 2008 19:37:55 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7AF801DB8041
	for <linux-mm@kvack.org>; Wed, 15 Oct 2008 19:37:55 +0900 (JST)
Date: Wed, 15 Oct 2008 19:37:54 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] [REPOST] mm: show node to memory section relationship with symlinks in sysfs
In-Reply-To: <20081014210621.GC7089@us.ibm.com>
References: <20081014201346.AD7D.E1E9C6FF@jp.fujitsu.com> <20081014210621.GC7089@us.ibm.com>
Message-Id: <20081015183846.C283.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gary Hade <garyhade@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, pbadari@us.ibm.com, mel@csn.ul.ie, lcm@us.ibm.com, mingo@elte.hu, greg@kroah.com, dave@linux.vnet.ibm.com, nish.aravamudan@gmail.com
List-ID: <linux-mm.kvack.org>

> On Tue, Oct 14, 2008 at 08:54:21PM +0900, Yasunori Goto wrote:
> > > On Fri, Oct 10, 2008 at 04:32:30PM -0700, Andrew Morton wrote:
> > > > On Fri, 10 Oct 2008 16:18:44 -0700
> > > > Gary Hade <garyhade@us.ibm.com> wrote:
> > > > 
> > > > > On Fri, Oct 10, 2008 at 02:59:50PM -0700, Andrew Morton wrote:
> > > > > > On Fri, 10 Oct 2008 14:33:57 -0700
> > > > > > Gary Hade <garyhade@us.ibm.com> wrote:
> > > > > > 
> > > > > > > On Fri, Oct 10, 2008 at 12:42:39PM -0700, Andrew Morton wrote:
> > > > > > > > On Thu, 9 Oct 2008 12:21:15 -0700
> > > > > > > > Gary Hade <garyhade@us.ibm.com> wrote:
> > > > > > > > 
> > > > > > > > > Show node to memory section relationship with symlinks in sysfs
> > > > > > > > > 
> > > > > > > > > Add /sys/devices/system/node/nodeX/memoryY symlinks for all
> > > > > > > > > the memory sections located on nodeX.  For example:
> > > > > > > > > /sys/devices/system/node/node1/memory135 -> ../../memory/memory135
> > > > > > > > > indicates that memory section 135 resides on node1.
> > > > > > > > 
> > > > > > > > I'm not seeing here a description of why the kernel needs this feature.
> > > > > > > > Why is it useful?  How will it be used?  What value does it have to
> > > > > > > > our users?
> > > > > > > 
> > > > > > > Sorry, I should have included that.  In our case, it is another
> > > > > > > small step towards eventual total node removal.  We will need to
> > > > > > > know which memory sections to offline for whatever node is targeted
> > > > > > > for removal.  However, I suspect that exposing the node to section
> > > > > > > information to user-level could be useful for other purposes.
> > > > > > > For example, I have been thinking that using memory hotremove
> > > > > > > functionality to modify the amount of available memory on specific
> > > > > > > nodes without having to physically add/remove DIMMs might be useful
> > > > > > > to those that test application or benchmark performance on a
> > > > > > > multi-node system in various memory configurations.
> > > > > > > 
> > > > > > 
> > > > > > hm, OK, thanks.  It does sound a bit thin, and if we merge this then
> > > > > > not only do we get a porkier kernel,
> > > > > 
> > > > > Would you feel the same about the size increase if patch 2/2 (include
> > > > > memory section subtree in sysfs with only sparsemem enabled) was
> > > > > withdrawn?
> > > > > 
> > > > > Without patch 2/2 the size increase for non-Sparsemem or Sparsemem
> > > > > wo/memory hotplug kernels is extremely small.  Even for memory hotplug
> > > > > enabled kernels there is only a little extra code in ./drivers/base/node.o
> > > > > which only gets linked into NUMA enabled kernels.  I can gather some numbers
> > > > > if necessary.
> > > > 
> > > > Size is probably a minor issue on memory-hotpluggable machines.
> > > > 
> > > > > > we also get a new userspace interface which we're then locked into.
> > > > > 
> > > > > True.
> > > > 
> > > > That's a bigger issue.  The later we leave this sort of thing, the more
> > > > information we have.
> > > 
> > > I understand your concerns about adding possibly frivolous interfaces
> > > but in this case we are simply eliminating a very obvious hole in the
> > > existing set of memory hot-add/remove interfaces.  In general, it
> > > makes absolutely no sense to provide a resource add/remove mechanism
> > > without telling the user where the resource is physically located.
> > > i.e. providing the _maximum_ possible amount of location information
> > > available for the add/remove controllable resource.  This is especially
> > > critical for large multi-node systems and for resources that can impact
> > > application or overall system performance.
> > > 
> > > The kernel already exports node location information for CPUs
> > > (e.g. /sys/devices/system/node/node0/cpu0 -> ../../cpu/cpu0) and
> > > PCI devices (e.g. ./devices/pci0000:00/0000:00:00.0/numa_node).
> > > Why should memory be treated any differently?
> > > 
> > > The memory hot-add/remove interfaces include physical device files
> > > (e.g. /sys/devices/system/memory/memory0/phys_device) which are not
> > > yet fully implemented.  When systems that support removable memory
> > > modules force this interface to mature, node location information
> > > will become even more critical.  This feature will not be very useful
> > > on multi-node systems if the user does not know what node a specific
> > > memory module is installed in.  It may be possible to encode the
> > > node ID into the string provided by the phys_device file but a
> > > more general node to memory section association as provided by this
> > > patch is better since it can be used for other purposes.
> > 
> > Sorry for late responce.
> > 
> > Our fujitsu box can hot-add a node. This means a user/script has to
> > find which memory sections and cpus belong to added node when node hot-add
> > is executed. 
> > 
> > Current my hotplug script is very poor. It onlines all offlined cpus and memories. 
> > However if user offlined one memory section intentionally due to
> > memory error message, the script can't understand it is intended, and hot-add
> > the error section. I think this is one of reason why this link is necessary.
> 
> When it comes time to replace that misbehaving memory I bet the
> user will be delighted to know which node it is in.

Even if user understand broken node, this case will happen.
(I may be paranoia...)

1) When a part of memory on a node is broken, user may execute just offline
   the broken section, because there may be no spare node at this time.

2) After new spare node comes to the user, he may intend to hot-add the
   new node at first, because he is afraid of temporary resouce reducing.
   (Our box's 1 node has 8 CPU cores and much memories now).
   And he will remove broken old node after hot-add new node.)

3) User kicks hot-add command to add new node.
   My script is executed automatically by "acpi container driver"
   vir udev when hot-add event occur. Then the script will online 
   the broken section.


> This sort of benefit will of course _not_ limited to the small community
> of node hot-add/remove capable systems.

I agree.

Bye.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
