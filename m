Message-ID: <4642D751.4060103@yahoo.com.au>
Date: Thu, 10 May 2007 18:26:57 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch] slob: implement RCU freeing
References: <Pine.LNX.4.64.0705081746500.16914@schroedinger.engr.sgi.com>	 <20070509012725.GZ11115@waste.org>	 <Pine.LNX.4.64.0705081828300.17376@schroedinger.engr.sgi.com>	 <20070508.185141.85412154.davem@davemloft.net>	 <46412BB5.1060605@yahoo.com.au>	 <20070509174238.b4152887.akpm@linux-foundation.org>	 <46426EA1.4030408@yahoo.com.au> <20070510022707.GO11115@waste.org>	 <4642C6A2.1090809@yahoo.com.au> <1178785328.6810.19.camel@twins>
In-Reply-To: <1178785328.6810.19.camel@twins>
Content-Type: multipart/mixed;
 boundary="------------070601060000070009060503"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------070601060000070009060503
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Peter Zijlstra wrote:
> On Thu, 2007-05-10 at 17:15 +1000, Nick Piggin wrote:
> 
> 
>>@@ -283,6 +295,12 @@
>> 	if (c) {
>> 		c->name = name;
>> 		c->size = size;
>>+		if (flags & SLAB_DESTROY_BY_RCU) {
>>+			BUG_ON(c->dtor);
>>+			/* leave room for rcu footer at the end of object */
>>+			c->size += sizeof(struct slob_rcu);
>>+		}
>>+		c->flags = flags;
> 
> 
> might want to put this hunt below
> 
> 
>>		c->ctor = ctor;
>> 		c->dtor = dtor;
> 
> 
> here; for c->dtor is not initialised quite yet at the BUG_ON site.

Indeed, how's this?

-- 
SUSE Labs, Novell Inc.

--------------070601060000070009060503
Content-Type: text/plain;
 name="slob-add-rcu-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="slob-add-rcu-fix.patch"

Index: linux-2.6/mm/slob.c
===================================================================
--- linux-2.6.orig/mm/slob.c
+++ linux-2.6/mm/slob.c
@@ -296,7 +296,7 @@ struct kmem_cache *kmem_cache_create(con
 		c->name = name;
 		c->size = size;
 		if (flags & SLAB_DESTROY_BY_RCU) {
-			BUG_ON(c->dtor);
+			BUG_ON(dtor);
 			/* leave room for rcu footer at the end of object */
 			c->size += sizeof(struct slob_rcu);
 		}

--------------070601060000070009060503--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
