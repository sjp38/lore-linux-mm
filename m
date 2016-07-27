Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2A0E36B025F
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 10:28:44 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id n69so3894324ion.0
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 07:28:44 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m77si7606623iod.118.2016.07.27.07.28.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jul 2016 07:28:43 -0700 (PDT)
Date: Wed, 27 Jul 2016 10:28:40 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [dm-devel] [RFC PATCH 2/2] mm, mempool: do not throttle
 PF_LESS_THROTTLE tasks
In-Reply-To: <87invr4tjm.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LRH.2.02.1607270948040.1779@file01.intranet.prod.int.rdu2.redhat.com>
References: <1468831164-26621-1-git-send-email-mhocko@kernel.org> <1468831285-27242-1-git-send-email-mhocko@kernel.org> <1468831285-27242-2-git-send-email-mhocko@kernel.org> <87oa5q5abi.fsf@notabene.neil.brown.name> <20160722091558.GF794@dhcp22.suse.cz>
 <878twt5i1j.fsf@notabene.neil.brown.name> <alpine.LRH.2.02.1607251730280.11852@file01.intranet.prod.int.rdu2.redhat.com> <87invr4tjm.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Ondrej Kozina <okozina@redhat.com>, Andrew Morton <akpm@linux-foundation.org>



On Wed, 27 Jul 2016, NeilBrown wrote:

> On Tue, Jul 26 2016, Mikulas Patocka wrote:
> 
> > On Sat, 23 Jul 2016, NeilBrown wrote:
> >
> >> "dirtying ... from the reclaim context" ??? What does that mean?
> >> According to
> >>   Commit: 26eecbf3543b ("[PATCH] vm: pageout throttling")
> >> From the history tree, the purpose of throttle_vm_writeout() is to
> >> limit the amount of memory that is concurrently under I/O.
> >> That seems strange to me because I thought it was the responsibility of
> >> each backing device to impose a limit - a maximum queue size of some
> >> sort.
> >
> > Device mapper doesn't impose any limit for in-flight bios.
> 
> I would suggest that it probably should. At least it should
> "set_wb_congested()" when the number of in-flight bios reaches some
> arbitrary threshold.

If we set the device mapper device as congested, it can again trigger that 
mempool alloc throttling bug.

I.e. suppose that we swap to a dm-crypt device. The dm-crypt device 
becomes clogged and sets its state as congested. The underlying block 
device is not congested.

The mempool_alloc function in the dm-crypt workqueue sets the 
PF_LESS_THROTTLE flag, and tries to allocate memory, but according to 
Michal's patches, processes with PF_LESS_THROTTLE may still get throttled.

So if we set the dm-crypt device as congested, it can incorrectly throttle 
the dm-crypt workqueue that does allocations of temporary pages and 
encryption.

I think that approach with PF_LESS_THROTTLE in mempool_alloc is incorrect 
and that mempool allocations should never be throttled.

> > I've made some patches that limit in-flight bios for device mapper in
> > the past, but there were not integrated into upstream.
> 
> I second the motion to resurrect these.

I uploaded those patches here:

http://people.redhat.com/~mpatocka/patches/kernel/dm-limit-outstanding-bios/

Mikulas

> Thanks,
> NeilBrown
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
