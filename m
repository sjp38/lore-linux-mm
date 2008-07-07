Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m67HSBtQ267200
	for <linux-mm@kvack.org>; Mon, 7 Jul 2008 17:28:11 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m67HSBKi2412780
	for <linux-mm@kvack.org>; Mon, 7 Jul 2008 18:28:11 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m67HSA7V000822
	for <linux-mm@kvack.org>; Mon, 7 Jul 2008 18:28:11 +0100
Subject: Re: [PATCH] Make CONFIG_MIGRATION available for s390
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
In-Reply-To: <4872319B.9040809@linux-foundation.org>
References: <1215354957.9842.19.camel@localhost.localdomain>
	 <4872319B.9040809@linux-foundation.org>
Content-Type: text/plain
Date: Mon, 07 Jul 2008 19:28:09 +0200
Message-Id: <1215451689.8431.80.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasunori Goto <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-07-07 at 10:09 -0500, Christoph Lameter wrote:
> This will extend the number of pages that are migratable and lead to strange
> semantics in the NUMA case. There suddenly vma_is migratable will forbid hotplug
> to migrate certain pages. 
> 
> I think we need two functions:
> 
> vma_migratable()	General migratability
> 
> vma_policy_migratable()	Migratable under NUMA policies.

Nothing will change here for the NUMA case, this is all about making it
compile w/o NUMA and with MIGRATION. What new strange semantics do you mean?
BTW, the latest patch in this thread will not touch vma_migratable() anymore,
I haven't read your mail before, sorry.

> That wont work since the migrate function takes a nodemask! The point of
> the function is to move memory from node to node which is something that you
> *cannot* do in a non NUMA configuration. So leave this chunk out.

Right, but I noticed that this function definition was needed to make it
compile with MIGRATION and w/o NUMA, although it would never be called in
non-NUMA config.
A better solution would probably be to put migrate_vmas(), the only caller
of vm_ops->migrate(), inside '#ifdef CONFIG_NUMA', because it will only be
called from NUMA-only mm/mempolicy.c. Does that sound reasonable?

> Hmmm... Okay. I tried to make MIGRATION as independent of CONFIG_NUMA as possible so hopefully this will work.

Umm, it doesn't compile with MIGRATION and w/o NUMA, which was the reason
for this patch, because of the policy_zone reference in vma_migratable()
and the missing vm_ops->migrate() function.

Thanks,
Gerald

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
