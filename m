Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id k2LI1qtK000638
	for <linux-mm@kvack.org>; Tue, 21 Mar 2006 13:01:52 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k2LI1erQ246416
	for <linux-mm@kvack.org>; Tue, 21 Mar 2006 13:01:42 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k2LI1enT009830
	for <linux-mm@kvack.org>; Tue, 21 Mar 2006 13:01:40 -0500
Subject: Re: [PATCH: 002/017]Memory hotplug for new nodes v.4.(change name
	old add_memory() to arch_add_memory())
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20060318102653.57c6a2af.kamezawa.hiroyu@jp.fujitsu.com>
References: <20060317162757.C63B.Y-GOTO@jp.fujitsu.com>
	 <1142615538.10906.67.camel@localhost.localdomain>
	 <20060318102653.57c6a2af.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Tue, 21 Mar 2006 10:00:12 -0800
Message-Id: <1142964013.10906.158.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: y-goto@jp.fujitsu.com, akpm@osdl.org, tony.luck@intel.com, ak@suse.de, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 2006-03-18 at 10:26 +0900, KAMEZAWA Hiroyuki wrote:
> If *determine node* function is moved to arch specific parts,
> memory hot add need more and more codes to determine  paddr -> nid in arch
> specific codes. Then, we have to add new paddr->nid function even if new nid is
> passed by firmware. We *lose* useful information of nid from firmware if 
> add_memory() has just 2 args, (start, end).  

What I'm saying is that I'd like add_memory() to be just that, for
adding memory.

At some point in the process, you need to export the NUMA node layout to
the rest of the system, to say which pages go in which node.  I'm just
saying that you should do that _before_ add_memory().

add_memory() should support adding memory to more than one node.  If any
hypervisor or hardware happens to have memory added in one contiguous
chunk, it can not simply call add_memory().  _That_ firmware would be
forced to do the NUMA parsing and figure out how many times to call
add_memory().  

Let me reiterate: the process of telling the system which pages are in
which node should be separate from telling the system that there *are*
currently pages there now.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
