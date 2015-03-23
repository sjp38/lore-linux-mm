Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f182.google.com (mail-yk0-f182.google.com [209.85.160.182])
	by kanga.kvack.org (Postfix) with ESMTP id D90EB6B006C
	for <linux-mm@kvack.org>; Sun, 22 Mar 2015 20:03:37 -0400 (EDT)
Received: by ykcn8 with SMTP id n8so64523168ykc.3
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 17:03:37 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id l69si5228745ykb.111.2015.03.22.17.03.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 22 Mar 2015 17:03:37 -0700 (PDT)
Message-ID: <550F5852.5020405@oracle.com>
Date: Sun, 22 Mar 2015 18:03:30 -0600
From: David Ahern <david.ahern@oracle.com>
MIME-Version: 1.0
Subject: Re: 4.0.0-rc4: panic in free_block
References: <CA+55aFwEq09vwnxPEYr67O7nuOEN9_n-uJKX11qSbuBNGJVghg@mail.gmail.com>	<20150322.182311.109269221031797359.davem@davemloft.net>	<550F51D5.2010804@oracle.com> <20150322.195403.1653355516554747742.davem@davemloft.net>
In-Reply-To: <20150322.195403.1653355516554747742.davem@davemloft.net>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: torvalds@linux-foundation.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bpicco@meloft.net

On 3/22/15 5:54 PM, David Miller wrote:
>> I just put it on 4.0.0-rc4 and ditto -- problem goes away, so it
>> clearly suggests the memcpy or memmove are the root cause.
>
> Thanks, didn't notice that.
>
> So, something is amuck.

to continue to refine the problem ... I modified only the memmove lines 
(not the memcpy) and it works fine. So its the memmove.

I'm sure this will get whitespaced damaged on the copy and paste but to 
be clear this is the patch I am currently running and system is stable. 
On Friday it failed on every single; with this patch I have allyesconfig 
builds with -j 128 in a loop (clean in between) and nothing -- no panics.

diff --git a/mm/slab.c b/mm/slab.c
index c4b89ea..f5e9716 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -802,6 +802,16 @@ static inline void ac_put_obj(struct kmem_cache 
*cachep, struct array_cache *ac,
         ac->entry[ac->avail++] = objp;
  }

+static void move_entries(void *dest, void *src, int nr)
+{
+       unsigned long *dp = dest;
+       unsigned long *sp = src;
+
+       for (; nr; nr--, dp++, sp++)
+               *dp = *sp;
+}
+
+
  /*
   * Transfer objects in one arraycache to another.
   * Locking must be handled by the caller.
@@ -3344,7 +3354,7 @@ free_done:
         spin_unlock(&n->list_lock);
         slabs_destroy(cachep, &list);
         ac->avail -= batchcount;
-       memmove(ac->entry, &(ac->entry[batchcount]), sizeof(void 
*)*ac->avail);
+       move_entries(ac->entry, &(ac->entry[batchcount]), ac->avail);
  }

  /*
@@ -3817,8 +3827,7 @@ static void drain_array(struct kmem_cache *cachep, 
struct kmem_cache_node *n,
                                 tofree = (ac->avail + 1) / 2;
                         free_block(cachep, ac->entry, tofree, node, &list);
                         ac->avail -= tofree;
-                       memmove(ac->entry, &(ac->entry[tofree]),
-                               sizeof(void *) * ac->avail);
+                       move_entries(ac->entry, &(ac->entry[tofree]), 
ac->avail);
                 }
                 spin_unlock_irq(&n->list_lock);
                 slabs_destroy(cachep, &list);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
