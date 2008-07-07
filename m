Message-ID: <48725480.1060808@linux-foundation.org>
Date: Mon, 07 Jul 2008 12:38:08 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [PATCH] Make CONFIG_MIGRATION available for s390
References: <1215354957.9842.19.camel@localhost.localdomain>	 <4872319B.9040809@linux-foundation.org> <1215451689.8431.80.camel@localhost.localdomain>
In-Reply-To: <1215451689.8431.80.camel@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasunori Goto <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

Gerald Schaefer wrote:
> On Mon, 2008-07-07 at 10:09 -0500, Christoph Lameter wrote:
>> This will extend the number of pages that are migratable and lead to strange
>> semantics in the NUMA case. There suddenly vma_is migratable will forbid hotplug
>> to migrate certain pages. 
>>
>> I think we need two functions:
>>
>> vma_migratable()	General migratability
>>
>> vma_policy_migratable()	Migratable under NUMA policies.
> 
> Nothing will change here for the NUMA case, this is all about making it
> compile w/o NUMA and with MIGRATION. What new strange semantics do you mean?
> BTW, the latest patch in this thread will not touch vma_migratable() anymore,
> I haven't read your mail before, sorry.

Ahh. Okay. However, we may still want a function that tells us if the pages in a vma
are migratable in general (independent of policies). The current vma_migratable function
tell you if the pages in a vma were placed according to a NUMA memory policy and should be migrated for NUMA locality optimizations.

>> That wont work since the migrate function takes a nodemask! The point of
>> the function is to move memory from node to node which is something that you
>> *cannot* do in a non NUMA configuration. So leave this chunk out.
> 
> Right, but I noticed that this function definition was needed to make it
> compile with MIGRATION and w/o NUMA, although it would never be called in
> non-NUMA config.

How does the compile break? It may be better to fix this where the function
is used.

> A better solution would probably be to put migrate_vmas(), the only caller
> of vm_ops->migrate(), inside '#ifdef CONFIG_NUMA', because it will only be
> called from NUMA-only mm/mempolicy.c. Does that sound reasonable?

That sounds right.
 
>> Hmmm... Okay. I tried to make MIGRATION as independent of CONFIG_NUMA as possible so hopefully this will work.
> 
> Umm, it doesn't compile with MIGRATION and w/o NUMA, which was the reason
> for this patch, because of the policy_zone reference in vma_migratable()
> and the missing vm_ops->migrate() function.

Right. I did not have a use case for !NUMA when I wrote the code. So you now need to
fix the minor bits that break.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
