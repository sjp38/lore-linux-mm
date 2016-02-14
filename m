Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0DFEF6B0009
	for <linux-mm@kvack.org>; Sun, 14 Feb 2016 03:51:12 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id g62so71547087wme.0
        for <linux-mm@kvack.org>; Sun, 14 Feb 2016 00:51:12 -0800 (PST)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id cd8si32129208wjc.91.2016.02.14.00.51.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Feb 2016 00:51:10 -0800 (PST)
Received: by mail-wm0-x22f.google.com with SMTP id g62so112997528wme.0
        for <linux-mm@kvack.org>; Sun, 14 Feb 2016 00:51:10 -0800 (PST)
Message-ID: <56C03FFB.1040401@gmail.com>
Date: Sun, 14 Feb 2016 10:51:07 +0200
From: Boaz Harrosh <openosd@gmail.com>
MIME-Version: 1.0
Subject: Re: Another proposal for DAX fault locking
References: <20160209172416.GB12245@quack.suse.cz> <56BB758D.1000704@plexistor.com> <20160211103856.GE21760@quack.suse.cz>
In-Reply-To: <20160211103856.GE21760@quack.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, Boaz Harrosh <boaz@plexistor.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-nvdimm@lists.01.org, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@suse.de, linux-fsdevel@vger.kernel.org

On 02/11/2016 12:38 PM, Jan Kara wrote:
> On Wed 10-02-16 19:38:21, Boaz Harrosh wrote:
>> On 02/09/2016 07:24 PM, Jan Kara wrote:
>>> Hello,
>>>
<>
>>>
>>> DAX will have an array of mutexes (the array can be made per device but
>>> initially a global one should be OK). We will use mutexes in the array as a
>>> replacement for page lock - we will use hashfn(mapping, index) to get
>>> particular mutex protecting our offset in the mapping. On fault / page
>>> mkwrite, we'll grab the mutex similarly to page lock and release it once we
>>> are done updating page tables. This deals with races in [1]. When flushing
>>> caches we grab the mutex before clearing writeable bit in page tables
>>> and clearing dirty bit in the radix tree and drop it after we have flushed
>>> caches for the pfn. This deals with races in [2].
>>>
>>> Thoughts?
>>>
>>
>> You could also use one of the radix-tree's special-bits as a bit lock.
>> So no need for any extra allocations.
> 
> Yes and I've suggested that once as well. But since we need sleeping
> locks, you need some wait queues somewhere as well. So some allocations are
> going to be needed anyway. 

They are already sleeping locks and there are all the proper "wait queues"
in place. I'm talking about
   lock:
	err = wait_on_bit_lock(&some_long, SOME_BIT_LOCK, ...);
and
   unlock:
	WARN_ON(!test_and_clear_bit(SOME_BIT_LOCK, &some_long));
	wake_up_bit(&some_long, SOME_BIT_LOCK);

> And mutexes have much better properties than

Just saying that page-locks are implemented just this way these days
so it is the performance and characteristics we already know.
(You are replacing page locks, no?)

> bit-locks so I prefer mutexes over cramming bit locks into radix tree. Plus
> you'd have to be careful so that someone doesn't remove the bit from the
> radix tree while you are working with it.
> 

Sure! need to be careful, is our middle name.

That said. Is your call. Thank you for working on this. Your plan sounds
very good as well, and is very much needed, because DAX's mmap performance
success right now.
[Maybe one small enhancement perhaps allocate an array of mutexes per NUMA
 node and access the proper array through numa_node_id()]

> 								Honza
> 

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
