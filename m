Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 905B26B0032
	for <linux-mm@kvack.org>; Wed, 24 Jun 2015 04:27:40 -0400 (EDT)
Received: by wgbhy7 with SMTP id hy7so29580681wgb.2
        for <linux-mm@kvack.org>; Wed, 24 Jun 2015 01:27:40 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dh9si1589428wib.8.2015.06.24.01.27.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 24 Jun 2015 01:27:38 -0700 (PDT)
Subject: Re: Write throughput impaired by touching dirty_ratio
References: <1506191513210.2879@stax.localdomain>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <558A69F8.2080304@suse.cz>
Date: Wed, 24 Jun 2015 10:27:36 +0200
MIME-Version: 1.0
In-Reply-To: <1506191513210.2879@stax.localdomain>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Hills <mark@xwax.org>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

[add some CC's]

On 06/19/2015 05:16 PM, Mark Hills wrote:
> I noticed that any change to vm.dirty_ratio causes write throuput to 
> plummet -- to around 5Mbyte/sec.
> 
>   <system bootup, kernel 4.0.5>
> 
>   # dd if=/dev/zero of=/path/to/file bs=1M
> 
>   # sysctl vm.dirty_ratio
>   vm.dirty_ratio = 20
>   <all ok; writes at ~150Mbyte/sec>
> 
>   # sysctl vm.dirty_ratio=20
>   <all continues to be ok>
> 
>   # sysctl vm.dirty_ratio=21
>   <writes drop to ~5Mbyte/sec>
> 
>   # sysctl vm.dirty_ratio=20
>   <writes continue to be slow at ~5Mbyte/sec>
> 
> The test shows that return to the previous value does not restore the old 
> behaviour. I return the system to usable state with a reboot.
> 
> Reads continue to be fast and are not affected.
> 
> A quick look at the code suggests differing behaviour from 
> writeback_set_ratelimit on startup. And that some of the calculations (eg. 
> global_dirty_limit) is badly behaved once the system has booted.

Hmm, so the only thing that dirty_ratio_handler() changes except the
vm_dirty_ratio itself, is ratelimit_pages through writeback_set_ratelimit(). So
I assume the problem is with ratelimit_pages. There's num_online_cpus() used in
the calculation, which I think would differ between the initial system state
(where we are called by page_writeback_init()) and later when all CPU's are
onlined. But I don't see CPU onlining code updating the limit (unlike memory
hotplug which does that), so that's suspicious.

Another suspicious thing is that global_dirty_limits() looks at current
process's flag. It seems odd to me that the process calling the sysctl would
determine a value global to the system.

If you are brave enough (and have kernel configured properly and with
debuginfo), you can verify how value of ratelimit_pages variable changes on the
live system, using the crash tool. Just start it, and if everything works, you
can inspect the live system. It's a bit complicated since there are two static
variables called "ratelimit_pages" in the kernel so we can't print them easily
(or I don't know how). First we have to get the variable address:

crash> sym ratelimit_pages
ffffffff81e67200 (d) ratelimit_pages
ffffffff81ef4638 (d) ratelimit_pages

One will be absurdly high (probably less on your 32bit) so it's not the one we want:

crash> rd -d ffffffff81ef4638 1
ffffffff81ef4638:    4294967328768

The second will have a smaller value:
(my system after boot with dirty ratio = 20)
crash> rd -d ffffffff81e67200 1
ffffffff81e67200:             1577

(after changing to 21)
crash> rd -d ffffffff81e67200 1
ffffffff81e67200:             1570

(after changing back to 20)
crash> rd -d ffffffff81e67200 1
ffffffff81e67200:             1496

So yes, it does differ but not drastically. A difference between 1 and 8 online
CPU's would look differently I think. So my theory above is questionable. But
you might try what it looks like on your system...

> 
> The system is an HP xw6600, running i686 kernel. This happens whether 
> internal SATA HDD, SSD or external USB drive is used. I first saw this on 
> kernel 4.0.4, and 4.0.5 is also affected.

So what was the last version where you did change the dirty ratio and it worked
fine?

> 
> It would suprise me if I'm the only person who was setting dirty_ratio.
> 
> Have others seen this behaviour? Thanks
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
