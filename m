Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id E6E646B0005
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 17:52:21 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id u25so475291828ioi.1
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 14:52:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j6si19022412itg.111.2016.07.25.14.52.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jul 2016 14:52:21 -0700 (PDT)
Date: Mon, 25 Jul 2016 17:52:17 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [RFC PATCH 2/2] mm, mempool: do not throttle PF_LESS_THROTTLE
 tasks
In-Reply-To: <878twt5i1j.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LRH.2.02.1607251730280.11852@file01.intranet.prod.int.rdu2.redhat.com>
References: <1468831164-26621-1-git-send-email-mhocko@kernel.org> <1468831285-27242-1-git-send-email-mhocko@kernel.org> <1468831285-27242-2-git-send-email-mhocko@kernel.org> <87oa5q5abi.fsf@notabene.neil.brown.name> <20160722091558.GF794@dhcp22.suse.cz>
 <878twt5i1j.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Ondrej Kozina <okozina@redhat.com>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, dm-devel@redhat.com



On Sat, 23 Jul 2016, NeilBrown wrote:

> "dirtying ... from the reclaim context" ??? What does that mean?
> According to
>   Commit: 26eecbf3543b ("[PATCH] vm: pageout throttling")
> From the history tree, the purpose of throttle_vm_writeout() is to
> limit the amount of memory that is concurrently under I/O.
> That seems strange to me because I thought it was the responsibility of
> each backing device to impose a limit - a maximum queue size of some
> sort.

Device mapper doesn't impose any limit for in-flight bios.

Some simple device mapper targets (such as linear or stripe) pass bio 
directly to the underlying device with generic_make_request, so if the 
underlying device's request limit is reached, the target's request routine 
waits.

However, complex dm targets (such as dm-crypt, dm-mirror, dm-thin) pass 
bios to a workqueue that processes them. And since there is no limit on 
the number of workqueue entries, there is no limit on the number of 
in-flight bios.

I've seen a case when I had a HPFS filesystem on dm-crypt. I wrote to the 
filesystem, there was about 2GB dirty data. The HPFS filesystem used 
512-byte bios. dm-crypt allocates one temporary page for each incoming 
bio. So, there were 4M bios in flight, each bio allocated 4k temporary 
page - that is attempted 16GB allocation. It didn't trigger OOM condition 
(because mempool allocations don't ever trigger it), but it temporarily 
exhausted all computer's memory.

I've made some patches that limit in-flight bios for device mapper in the 
past, but there were not integrated into upstream.

> If a thread is only making transient allocations, ones which will be
> freed shortly afterwards (not, for example, put in a cache), then I
> don't think it needs to be throttled at all.  I think this universally
> applies to mempools.
> In the case of dm_crypt, if it is writing too fast it will eventually be
> throttled in generic_make_request when the underlying device has a full
> queue and so blocks waiting for requests to be completed, and thus parts
> of them returned to the mempool.

No, it won't be throttled.

dm-crypt does:
1. pass the bio to the encryption workqueue
2. allocate the outgoing bio and allocate temporary pages for the 
   encrypted data
3. do the encryption
4. pass the bio to the writer thread
5. submit the write request with generic_make_request

So, if the underlying block device is throttled, it stalls the writer 
thread, but it doesn't stall the encryption threads and it doesn't stall 
the caller that submits the bios to dm-crypt.

There can be really high number of in-flight bios for dm-crypt.

Mikulas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
