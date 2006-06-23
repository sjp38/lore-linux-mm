Message-ID: <449BA94A.4030603@yahoo.com.au>
Date: Fri, 23 Jun 2006 18:41:46 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 3/3] radix-tree: RCU lockless readside
References: <20060408134635.22479.79269.sendpatchset@linux.site>	<20060408134707.22479.33814.sendpatchset@linux.site>	<20060622014949.GA2202@us.ibm.com>	<20060622154518.GA23109@wotan.suse.de>	<20060622163032.GC1295@us.ibm.com>	<20060622165551.GB23109@wotan.suse.de>	<20060622174057.GF1295@us.ibm.com>	<20060622181111.GD23109@wotan.suse.de> <20060623000901.bf8b46c5.akpm@osdl.org> <449BA8BB.3070402@yahoo.com.au>
In-Reply-To: <449BA8BB.3070402@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------060302010002000807020202"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <npiggin@suse.de>, paulmck@us.ibm.com, benh@kernel.crashing.org, Paul.McKenney@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------060302010002000807020202
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Nick Piggin wrote:

>>          shift -= RADIX_TREE_MAP_SHIFT;
>> -        slot = slot->slots[i];
>> +        slot = rcu_dereference(slot->slots[i]);
>> +        if (slot == NULL);
>> +            break;
>>      }
> 
> 
>                          ^^^^^^^^
> 
> Up there.
> 

And here's the patch.

-- 
SUSE Labs, Novell Inc.

--------------060302010002000807020202
Content-Type: text/plain;
 name="radix-tree-paul-review-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="radix-tree-paul-review-fix.patch"

Index: linux-2.6/lib/radix-tree.c
===================================================================
--- linux-2.6.orig/lib/radix-tree.c
+++ linux-2.6/lib/radix-tree.c
@@ -752,7 +752,7 @@ __lookup_tag(struct radix_tree_node *slo
 		}
 		shift -= RADIX_TREE_MAP_SHIFT;
 		slot = rcu_dereference(slot->slots[i]);
-		if (slot == NULL);
+		if (slot == NULL)
 			break;
 	}
 out:

--------------060302010002000807020202--
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
