Message-ID: <3D387702.6010306@us.ibm.com>
Date: Fri, 19 Jul 2002 13:30:58 -0700
From: Matthew Dobson <colpatch@us.ibm.com>
Reply-To: colpatch@us.ibm.com
MIME-Version: 1.0
Subject: Re: [patch] Useless locking in mm/numa.c
References: <20020719183646.32486.qmail@web14310.mail.yahoo.com>
Content-Type: multipart/mixed;
 boundary="------------020705020401080207040403"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanojsarcar@yahoo.com>
Cc: Andrew Morton <akpm@zip.com.au>, Martin Bligh <mjbligh@us.ibm.com>, linux-mm@kvack.org, Michael Hohnbaum <hohnbaum@us.ibm.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------020705020401080207040403
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Kanoj Sarcar wrote:
> I think I put in the locks in the initial version of
> the file becase the idea was that 
> show_free_areas_node() could be invoked from any cpu
> in a multinode system (via the sysrq keys or other
> intr sources), and the spin lock would provide 
> sanity in the print out. 
As Bill mentioned, a grep through the source shows that show_free_areas_node() 
is never called, and since it boils down to *just* a call to 
show_free_areas_core() w/out the locking, the revised patch pulls it out entirely.

> For nonnuma discontig machines, isn't the spin lock
> providing protection in the pgdat list chain walking
> in _alloc_pages()?
Uhh...  kinda?  Since *next is static, it means that at best case, 2 processes 
walking the pgdat_list chain will hip-hop over nodes...  If it is racy code, 
the *best* that lock is currently doing is making it mildy less racy, and at 
worst, hiding the fact that there is a race there.

I'm sure the lock was useful at some point, but it no longer is...  Attatched 
is the new version, please apply..

Cheers!

-Matt

> 
> Kanoj
> 
> --- Matthew Dobson <colpatch@us.ibm.com> wrote:
> 
>>There is a lock that is apparently protecting
>>nothing.  The node_lock spinlock 
>>in mm/numa.c is protecting read-only accesses to
>>pgdat_list.  Here is a patch 
>>to get rid of it.
>>
>>Cheers!
>>
>>-Matt
>>
>>>--- linux-2.5.26-vanilla/mm/numa.c	Tue Jul 16
>>
>>16:49:30 2002
>>+++ linux-2.5.26-vanilla/mm/numa.c.fixed	Thu Jul 18
>>17:59:35 2002
>>@@ -44,15 +44,11 @@
>> 
>> #define LONG_ALIGN(x)
>>(((x)+(sizeof(long))-1)&~((sizeof(long))-1))
>> 
>>-static spinlock_t node_lock = SPIN_LOCK_UNLOCKED;
>>-
>> void show_free_areas_node(pg_data_t *pgdat)
>> {
>> 	unsigned long flags;
>> 
>>-	spin_lock_irqsave(&node_lock, flags);
>> 	show_free_areas_core(pgdat);
>>-	spin_unlock_irqrestore(&node_lock, flags);
>> }
>> 
>> /*
>>@@ -106,11 +102,9 @@
>> #ifdef CONFIG_NUMA
>> 	temp = NODE_DATA(numa_node_id());
>> #else
>>-	spin_lock_irqsave(&node_lock, flags);
>> 	if (!next) next = pgdat_list;
>> 	temp = next;
>> 	next = next->node_next;
>>-	spin_unlock_irqrestore(&node_lock, flags);
>> #endif
>> 	start = temp;
>> 	while (temp) {
>>
> 
> 
> 
> __________________________________________________
> Do You Yahoo!?
> Yahoo! Autos - Get free new car price quotes
> http://autos.yahoo.com
> 


--------------020705020401080207040403
Content-Type: text/plain;
 name="node_lock.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="node_lock.patch"

--- linux-2.5.26-vanilla/mm/numa.c	Tue Jul 16 16:49:30 2002
+++ linux-2.5.26-vanilla/mm/numa.c.fixed	Thu Jul 18 17:59:35 2002
@@ -43,17 +43,6 @@
 #ifdef CONFIG_DISCONTIGMEM
 
 #define LONG_ALIGN(x) (((x)+(sizeof(long))-1)&~((sizeof(long))-1))
-
-static spinlock_t node_lock = SPIN_LOCK_UNLOCKED;
-
-void show_free_areas_node(pg_data_t *pgdat)
-{
-	unsigned long flags;
-
-	spin_lock_irqsave(&node_lock, flags);
-	show_free_areas_core(pgdat);
-	spin_unlock_irqrestore(&node_lock, flags);
-}
 
 /*
  * Nodes can be initialized parallely, in no particular order.
@@ -106,11 +103,9 @@
 #ifdef CONFIG_NUMA
 	temp = NODE_DATA(numa_node_id());
 #else
-	spin_lock_irqsave(&node_lock, flags);
 	if (!next) next = pgdat_list;
 	temp = next;
 	next = next->node_next;
-	spin_unlock_irqrestore(&node_lock, flags);
 #endif
 	start = temp;
 	while (temp) {

--------------020705020401080207040403--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
