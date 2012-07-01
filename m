Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id D77C06B00C7
	for <linux-mm@kvack.org>; Sun,  1 Jul 2012 09:41:28 -0400 (EDT)
Received: from /spool/local
	by e1.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Sun, 1 Jul 2012 09:41:27 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q61DfGoI374548
	for <linux-mm@kvack.org>; Sun, 1 Jul 2012 09:41:16 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q61DfFKF010885
	for <linux-mm@kvack.org>; Sun, 1 Jul 2012 09:41:16 -0400
Date: Sun, 1 Jul 2012 21:41:14 +0800
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2/3] mm/sparse: fix possible memory leak
Message-ID: <20120701134114.GA13042@shangw>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
References: <1340814968-2948-1-git-send-email-shangw@linux.vnet.ibm.com>
 <1340814968-2948-2-git-send-email-shangw@linux.vnet.ibm.com>
 <alpine.DEB.2.00.1206271501240.22985@chino.kir.corp.google.com>
 <20120628061658.GA27958@shangw>
 <alpine.DEB.2.00.1206281431510.1652@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1206281431510.1652@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, linux-mm@kvack.org, mhocko@suse.cz, dave@linux.vnet.ibm.com, hannes@cmpxchg.org, akpm@linux-foundation.org

On Thu, Jun 28, 2012 at 02:34:29PM -0700, David Rientjes wrote:
>On Thu, 28 Jun 2012, Gavin Shan wrote:
>
>> >> +{
>> >> +	unsigned long size = SECTIONS_PER_ROOT *
>> >> +			     sizeof(struct mem_section);
>> >> +
>> >> +	if (!section)
>> >> +		return;
>> >> +
>> >> +	if (slab_is_available())
>> >> +		kfree(section);
>> >> +	else
>> >> +		free_bootmem_node(NODE_DATA(nid),
>> >> +			virt_to_phys(section), size);
>> >
>> >Did you check what happens here if !node_state(nid, N_HIGH_MEMORY)?
>> >
>> 
>> I'm sorry that I'm not catching your point. Please explain for more
>> if necessary.
>> 
>
>I'm asking specifically about the free_bootmem_node(NODE_DATA(nid), ...).
>

Thanks for pointing it out, David.

>If this section was allocated in sparse_index_alloc() before 
>slab_is_available() with alloc_bootmem_node() and nid is not in 
>N_HIGH_MEMORY, will alloc_bootmem_node() fallback to any node or return 
>NULL?
>

Yes, you're right that bootmem allocator will try other nodes if the
specified node can't accomodate the memory allocation. So it's not
safe to free memory by free_bootmem_node().

>If it falls back to any node, is it safe to try to free that section by 
>passing NODE_DATA(nid) here when it wasn't allocated on that nid?
>

I think free_bootmem() should be used here :-)

Thanks,
Gavin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
