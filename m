Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 46F9B6B0256
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 13:10:37 -0500 (EST)
Received: by qgea14 with SMTP id a14so92717620qge.0
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 10:10:37 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i20si9973150qhc.34.2015.12.09.10.10.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 10:10:36 -0800 (PST)
Date: Wed, 9 Dec 2015 19:10:33 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/1] ksm: introduce ksm_max_page_sharing per page
 deduplication limit
Message-ID: <20151209181033.GJ29105@redhat.com>
References: <1447181081-30056-1-git-send-email-aarcange@redhat.com>
 <1447181081-30056-2-git-send-email-aarcange@redhat.com>
 <20151209161959.GC3540@stainedmachine.brq.redhat.com>
 <20151209171508.GI29105@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151209171508.GI29105@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Holasek <pholasek@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@linux.intel.com>

On Wed, Dec 09, 2015 at 06:15:08PM +0100, Andrea Arcangeli wrote:
> Hello Petr,
> 
> On Wed, Dec 09, 2015 at 05:19:59PM +0100, Petr Holasek wrote:
> > Hi Andrea,
> > 
> > I've been running stress tests against this patchset for a couple of hours
> > and everything was ok. However, I've allocated ~1TB of memory and got
> > following lockup during disabling KSM with 'echo 2 > /sys/kernel/mm/ksm/run':
> > 
> > [13201.060601] INFO: task ksmd:351 blocked for more than 120 seconds.
> > [13201.066812]       Not tainted 4.4.0-rc4+ #5
> > [13201.070996] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables
> > this message.
> > [13201.078830] ksmd            D ffff883f65eb7dc8     0   351      2
> > 0x00000000
> > [13201.085903]  ffff883f65eb7dc8 ffff887f66e26400 ffff883f65d5e400
> > ffff883f65eb8000
> > [13201.093343]  ffffffff81a65144 ffff883f65d5e400 00000000ffffffff
> > ffffffff81a65148
> > [13201.100792]  ffff883f65eb7de0 ffffffff816907e5 ffffffff81a65140
> > ffff883f65eb7df0
> > [13201.108242] Call Trace:
> > [13201.110708]  [<ffffffff816907e5>] schedule+0x35/0x80
> > [13201.115676]  [<ffffffff81690ace>] schedule_preempt_disabled+0xe/0x10
> > [13201.122044]  [<ffffffff81692524>] __mutex_lock_slowpath+0xb4/0x130
> > [13201.128237]  [<ffffffff816925bf>] mutex_lock+0x1f/0x2f
> > [13201.133395]  [<ffffffff811debd2>] ksm_scan_thread+0x62/0x1f0
> > [13201.139068]  [<ffffffff810c8ac0>] ? wait_woken+0x80/0x80
> > [13201.144391]  [<ffffffff811deb70>] ? ksm_do_scan+0x1140/0x1140
> > [13201.150164]  [<ffffffff810a4378>] kthread+0xd8/0xf0
> > [13201.155056]  [<ffffffff810a42a0>] ? kthread_park+0x60/0x60
> > [13201.160551]  [<ffffffff8169460f>] ret_from_fork+0x3f/0x70
> > [13201.165961]  [<ffffffff810a42a0>] ? kthread_park+0x60/0x60
> > 
> > It seems this is not connected with the new code, but it would be nice to
> > also make unmerge_and_remove_all_rmap_items() more scheduler friendly.
> 
> Agreed. I run echo 2 many times here with big stable_node chains but
> this one never happened here, it likely shows easier on the 1TiB.

I thought the above was a problem with "scheduler friendliness" in
turn missing cond_resched() but the above is not a softlockup.

The above can't be solved by improving scheduler friendliness, we
didn't prevent the schedule for 120sec, just the mutex_lock was stuck
and a stuck was in D state for too long, which in the KSM case for
servers would be just a false positive. KSM would immediately stop
after it takes the mutex anyway so the above only informs that we
didn't run try_to_freeze() fast enough. The only trouble there could
be with suspend for non-server usage.

To hide the above (and reach try_to_freeze() quick) we could just do
trylock in ksm_scan_thread and mutex_lock_interruptible() in the other
places, but that still leaves the uninterruptible wait_on_bit to
solve.

Improving scheduler friendliness would have been more important than
avoiding the above. remove_node_from_stable_tree would also do a
cond_resched() if the rmap_item list is not empty so it was unlikely
it could generate a softlockup for 120sec even with an enormous
chain. However just like the &migrate_nodes list walk and like the
remove_stable_node_chain caller both do a cond_resched() after
remove_stable_node(), it sounds better to do it inside
remove_stable_node_chain too in case we run into a chain and we need
to free the dups. Just the previous patch won't help with the above.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
