Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f43.google.com (mail-oi0-f43.google.com [209.85.218.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1044F6B0032
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 03:12:56 -0400 (EDT)
Received: by oign205 with SMTP id n205so14847926oig.2
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 00:12:55 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id g8si17297604oep.106.2015.04.29.00.12.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 29 Apr 2015 00:12:55 -0700 (PDT)
Message-ID: <55408462.6010703@huawei.com>
Date: Wed, 29 Apr 2015 15:12:34 +0800
From: Zhang Zhen <zhenzhang.zhang@huawei.com>
MIME-Version: 1.0
Subject: Why task_struct slab can't be released back to buddy system?
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, dave.hansen@linux.intel.com
Cc: Linux MM <linux-mm@kvack.org>, qiuxishi@huawei.com

Hi,

Our x86 system has crashed because oom.
We found task_struct slabs ate much memory.
And we analyzed the core file just as follows.

Why the page's inuse is 0 but the slab can't be released back to buddy system ?
The memory allocator is slub.

crash> kmem -s task_struct
CACHE    	  NAME                 OBJSIZE  ALLOCATED     TOTAL  SLABS  SSIZE          //**Slabs is much larger than alloctated object counts**
ffff88081e007500 task_struct             6528       4639    229775  45955    32k

crash> p *(struct kmem_cache *)0xffff88081e007500
$54 = {
  cpu_slab = 0x14e10,
  flags = 1074003968,
  min_partial = 6,
  size = 6528,
  objsize = 6528,
  offset = 0,
  cpu_partial = 2,
  oo = {
    x = 196613
  },
  max = {
    x = 196613
  },
  min = {
    x = 65537
  },
  allocflags = 16384,
  refcount = 1,
  ctor = 0x0,
  inuse = 6528,
  align = 16,
  reserved = 0,
  name = 0xffff88081e000920 "task_struct",
  list = {
    next = 0xffff88081e007468,
    prev = 0xffff88081e007668
  },
  kobj = {
    name = 0xffff880810faf9b0 ":t-0006528",
    entry = {
      next = 0xffff88081e007480,
      prev = 0xffff88081e007680
    },
    parent = 0xffff880810fc0258,
    kset = 0xffff880810fc0240,
    ktype = 0xffffffff81847040 <slab_ktype>,
    sd = 0xffff880c2542c3f0,
    kref = {
      refcount = {
        counter = 1
      }
    },
    state_initialized = 1,
    state_in_sysfs = 1,
    state_add_uevent_sent = 1,
    state_remove_uevent_sent = 0,
    uevent_suppress = 0
  },
  remote_node_defrag_ratio = 1000,
  node = {0xffff88081e001440, 0xffff880c2e800440, 0x0, 0x0, 0x0, 0x0,

crash> p *(struct kmem_cache_node *)0xffff88081e001440
$55 = {
  list_lock = {
    {
      rlock = {
        raw_lock = {
          {
            head_tail = 254283560,
            tickets = {
              head = 3880,
              tail = 3880
            }
          }
        }
      }
    }
  },
  nr_partial = 45287,
  partial = {
    next = 0xffffea0001396c20,
    prev = 0xffffea00202a8220
  },
  nr_slabs = {
    counter = 45829
  },
  total_objects = {
    counter = 229125
  },
  full = {
    next = 0xffff88081e001470,
    prev = 0xffff88081e001470
  }
}

crash> p *((struct page *)((char *)0xffffea0001396c20-32))
$57 = {
  flags = 9007199254757504,
  mapping = 0x0,
  {
    {
      index = 18446612136879672448,
      freelist = 0xffff8801101f4c80
    },
    {
      counters = 4295294976,
      {
        {
          _mapcount = {
            counter = 327680
          },
          {
            inuse = 0,                         //##Here we found the slab page's inuse is 0.##
            objects = 5,
            frozen = 0
          }
        },
        _count = {
          counter = 1
        }
      }
    }
  },
  {
    lru = {
      next = 0xffffea00055dde20,
      prev = 0xffffea0002e0be20
    },
    {
      next = 0xffffea00055dde20,
      pages = 48283168,
      pobjects = -5632
    }
  },
  {
    private = 18446612167177303296,
    ptl = {
      {
        rlock = {
          raw_lock = {
            {
              head_tail = 503346432,
              tickets = {
                head = 29952,
                tail = 7680
              }
            }
          }
        }
      }
    },
    slab = 0xffff88081e007500,
    first_page = 0xffff88081e007500
  }
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
