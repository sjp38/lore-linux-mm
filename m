Received: by wr-out-0506.google.com with SMTP id 67so808552wri
        for <linux-mm@kvack.org>; Fri, 08 Jun 2007 12:47:47 -0700 (PDT)
Message-ID: <4669B25A.6010404@googlemail.com>
Date: Fri, 08 Jun 2007 21:47:38 +0200
MIME-Version: 1.0
Subject: Re: [patch 00/12] Slab defragmentation V3
References: <20070607215529.147027769@sgi.com>  <466999A2.8020608@googlemail.com>  <Pine.LNX.4.64.0706081110580.1464@schroedinger.engr.sgi.com> <6bffcb0e0706081156u4ad0cc9dkf6d55ebcbd79def2@mail.gmail.com> <Pine.LNX.4.64.0706081207400.2082@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0706081239340.2447@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0706081239340.2447@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

Christoph Lameter pisze:
> On Fri, 8 Jun 2007, Christoph Lameter wrote:
> 
>> On Fri, 8 Jun 2007, Michal Piotrowski wrote:
>>
>>> Yes, it does. Thanks!
>> Ahhh... That leds to the discovery more sysfs problems. I need to make 
>> sure not to be holding locks while calling into sysfs. More cleanup...
> 
> Could you remove the trylock patch and see how this one fares? We may need 
> both but this should avoid taking the slub_lock around any possible alloc 
> of sysfs.
> 
> 

It's a bit tricky

cat ../sd2.patch | patch -p1
patching file mm/slub.c
Hunk #1 succeeded at 2194 (offset 15 lines).
Hunk #2 FAILED at 2653.
1 out of 2 hunks FAILED -- saving rejects to file mm/slub.c.rej
[michal@bitis-gabonica linux-work3]$ cat mm/slub.c.rej
***************
*** 2652,2677 ****
                 */
                s->objsize = max(s->objsize, (int)size);
                s->inuse = max_t(int, s->inuse, ALIGN(size, sizeof(void *)));
                if (sysfs_slab_alias(s, name))
                        goto err;
-       } else {
-               s = kmalloc(kmem_size, GFP_KERNEL);
-               if (s && kmem_cache_open(s, GFP_KERNEL, name,
                                size, align, flags, ctor)) {
-                       if (sysfs_slab_add(s)) {
-                               kfree(s);
-                               goto err;
-                       }
                        list_add(&s->list, &slab_caches);
                        raise_kswapd_order(s->order);
-               } else
-                       kfree(s);
        }
        up_write(&slub_lock);
-       return s;

  err:
-       up_write(&slub_lock);
        if (flags & SLAB_PANIC)
                panic("Cannot create slabcache %s\n", name);
        else
--- 2653,2685 ----
                 */
                s->objsize = max(s->objsize, (int)size);
                s->inuse = max_t(int, s->inuse, ALIGN(size, sizeof(void *)));
+               up_write(&slub_lock);
+
                if (sysfs_slab_alias(s, name))
                        goto err;
+
+               return s;
+       }
+
+       s = kmalloc(kmem_size, GFP_KERNEL);
+       if (s) {
+               if (kmem_cache_open(s, GFP_KERNEL, name,
                                size, align, flags, ctor)) {
                        list_add(&s->list, &slab_caches);
+                       up_write(&slub_lock);
                        raise_kswapd_order(s->order);
+
+                       if (sysfs_slab_add(s))
+                               goto err;
+
+                       return s;
+
+               }
+               kfree(s);
        }
        up_write(&slub_lock);

  err:
        if (flags & SLAB_PANIC)
                panic("Cannot create slabcache %s\n", name);
        else

Regards,
Michal

-- 
"Najbardziej brakowaA?o mi twojego milczenia."
-- Andrzej Sapkowski "CoA? wiA?cej"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
