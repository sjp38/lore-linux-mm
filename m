Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C41CE6B0005
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 03:25:32 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id o80so1446889wme.1
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 00:25:32 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id io7si18500521wjb.172.2016.07.26.00.25.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jul 2016 00:25:31 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id x83so243704wma.3
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 00:25:31 -0700 (PDT)
Date: Tue, 26 Jul 2016 09:25:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/2] mm, mempool: do not throttle PF_LESS_THROTTLE
 tasks
Message-ID: <20160726072530.GC32462@dhcp22.suse.cz>
References: <1468831164-26621-1-git-send-email-mhocko@kernel.org>
 <1468831285-27242-1-git-send-email-mhocko@kernel.org>
 <1468831285-27242-2-git-send-email-mhocko@kernel.org>
 <87oa5q5abi.fsf@notabene.neil.brown.name>
 <20160722091558.GF794@dhcp22.suse.cz>
 <878twt5i1j.fsf@notabene.neil.brown.name>
 <alpine.LRH.2.02.1607251730280.11852@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1607251730280.11852@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: NeilBrown <neilb@suse.com>, linux-mm@kvack.org, Ondrej Kozina <okozina@redhat.com>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, dm-devel@redhat.com

On Mon 25-07-16 17:52:17, Mikulas Patocka wrote:
> 
> 
> On Sat, 23 Jul 2016, NeilBrown wrote:
> 
> > "dirtying ... from the reclaim context" ??? What does that mean?
> > According to
> >   Commit: 26eecbf3543b ("[PATCH] vm: pageout throttling")
> > From the history tree, the purpose of throttle_vm_writeout() is to
> > limit the amount of memory that is concurrently under I/O.
> > That seems strange to me because I thought it was the responsibility of
> > each backing device to impose a limit - a maximum queue size of some
> > sort.
> 
> Device mapper doesn't impose any limit for in-flight bios.
> 
> Some simple device mapper targets (such as linear or stripe) pass bio 
> directly to the underlying device with generic_make_request, so if the 
> underlying device's request limit is reached, the target's request routine 
> waits.
> 
> However, complex dm targets (such as dm-crypt, dm-mirror, dm-thin) pass 
> bios to a workqueue that processes them. And since there is no limit on 
> the number of workqueue entries, there is no limit on the number of 
> in-flight bios.
> 
> I've seen a case when I had a HPFS filesystem on dm-crypt. I wrote to the 
> filesystem, there was about 2GB dirty data. The HPFS filesystem used 
> 512-byte bios. dm-crypt allocates one temporary page for each incoming 
> bio. So, there were 4M bios in flight, each bio allocated 4k temporary 
> page - that is attempted 16GB allocation. It didn't trigger OOM condition 
> (because mempool allocations don't ever trigger it), but it temporarily 
> exhausted all computer's memory.

OK, that is certainly not good and something that throttle_vm_writeout
aimed at protecting from. It is a little bit poor protection because
it might fire much more earlier than necessary. Shouldn't those workers
simply backoff when the underlying bdi is congested? It wouldn't help
to queue more IO when the bdi is hammered already.
 
> I've made some patches that limit in-flight bios for device mapper in the 
> past, but there were not integrated into upstream.

Care to revive them? I am not an expert in dm but unbounded amount of
inflight IO doesn't really sound good.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
