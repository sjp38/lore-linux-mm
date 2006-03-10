Received: from m7.gw.fujitsu.co.jp ([10.0.50.77])
        by fgwmail6.fujitsu.co.jp (Fujitsu Gateway)
        with ESMTP id k2A7KfJ2007333 for <linux-mm@kvack.org>; Fri, 10 Mar 2006 16:20:41 +0900
        (envelope-from y-goto@jp.fujitsu.com)
Received: from s11.gw.fujitsu.co.jp by m7.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id k2A7KeWg007911 for <linux-mm@kvack.org>; Fri, 10 Mar 2006 16:20:40 +0900
	(envelope-from y-goto@jp.fujitsu.com)
Received: from s11.gw.fujitsu.co.jp (s11 [127.0.0.1])
	by s11.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FE3D119C66
	for <linux-mm@kvack.org>; Fri, 10 Mar 2006 16:20:40 +0900 (JST)
Received: from ml6.s.css.fujitsu.com (ml6.s.css.fujitsu.com [10.23.4.196])
	by s11.gw.fujitsu.co.jp (Postfix) with ESMTP id 9BF5E119C02
	for <linux-mm@kvack.org>; Fri, 10 Mar 2006 16:20:39 +0900 (JST)
Date: Fri, 10 Mar 2006 16:20:37 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [PATCH: 010/017](RFC) Memory hotplug for new nodes v.3. (allocate wait table)
In-Reply-To: <200603090556.06226.ak@suse.de>
References: <20060309040055.21f3ec2d.akpm@osdl.org> <200603090556.06226.ak@suse.de>
Message-Id: <20060310154910.CA79.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>, Andrew Morton <akpm@osdl.org>
Cc: tony.luck@intel.com, jschopp@austin.ibm.com, haveblue@us.ibm.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Thursday 09 March 2006 13:00, Andrew Morton wrote:
> > Yasunori Goto <y-goto@jp.fujitsu.com> wrote:
> > >
> > >  +		/* we can use kmalloc() in run time */
> > >  +		do {
> > >  +			table_size = zone->wait_table_size
> > >  +					* sizeof(wait_queue_head_t);
> > >  +			zone->wait_table = kmalloc(table_size, GFP_ATOMIC);
> > 
> > Again, GFP_KERNEL would be better is possible.

Oops.
This was inside of spin_lock in old my patch.
But, it is moved out from spin_lock as a result of refactoring 
and I didn't notice that.
Yes. GFP_KERNEL is better.

> > 
> > Won't this place the node's wait_table into a different node's memory?
> 
> Yes, kmalloc_node would be better.

Kmalloc_node() will not work well at here, 
because this patch is to initialize structures for new node -itself-.
It will work after that completion of initalize pgdat and wait_table.

To use new node's memory at here, other consideration will be necessary. 
But, I would like to use kmalloc() to simplify my patch at this time.

Thanks.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
