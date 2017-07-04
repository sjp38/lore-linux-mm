Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 40C5B6B02F4
	for <linux-mm@kvack.org>; Tue,  4 Jul 2017 11:42:19 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id g15so8421897wmi.11
        for <linux-mm@kvack.org>; Tue, 04 Jul 2017 08:42:19 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w3si13632203wmb.191.2017.07.04.08.42.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Jul 2017 08:42:18 -0700 (PDT)
Date: Tue, 4 Jul 2017 08:42:08 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [patch V2 2/2] mm/memory-hotplug: Switch locking to a percpu
 rwsem
Message-ID: <20170704154208.GC11168@linux-80c1.suse>
References: <20170704093232.995040438@linutronix.de>
 <20170704093421.506836322@linutronix.de>
 <20170704150106.GA11168@linux-80c1.suse>
 <20170704152206.GB11168@linux-80c1.suse>
 <alpine.DEB.2.20.1707041732030.9000@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1707041732030.9000@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vladimir Davydov <vdavydov.dev@gmail.com>, Peter Zijlstra <peterz@infradead.org>

On Tue, 04 Jul 2017, Thomas Gleixner wrote:

>On Tue, 4 Jul 2017, Davidlohr Bueso wrote:
>> On Tue, 04 Jul 2017, Davidlohr Bueso wrote:
>>
>> > As a side effect you end up optimizing get/put_online_mems() at the cost
>> > of more overhead for the actual hotplug operation, which is rare and of less
>> > performance importance.
>>
>> So nm this, the reader side actually gets _more_ expensive with pcpu-rwsems
>> due to at least two full barriers for each get/put operation.
>
>Compared to a mutex_lock/unlock() pair on a global mutex ....

Ah, right, I was thrown off the:

    if (mem_hotplug.active_writer == current)
       return;

checks, which is only true within hotplug_begin/end. So normally we'd take
the lock, which was my first impression. Sorry for the noise.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
