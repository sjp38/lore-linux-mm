Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 837926B025E
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 12:15:13 -0500 (EST)
Received: by qgea14 with SMTP id a14so90001626qge.0
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 09:15:13 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a76si9711500qhc.94.2015.12.09.09.15.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 09:15:12 -0800 (PST)
Date: Wed, 9 Dec 2015 18:15:08 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/1] ksm: introduce ksm_max_page_sharing per page
 deduplication limit
Message-ID: <20151209171508.GI29105@redhat.com>
References: <1447181081-30056-1-git-send-email-aarcange@redhat.com>
 <1447181081-30056-2-git-send-email-aarcange@redhat.com>
 <20151209161959.GC3540@stainedmachine.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151209161959.GC3540@stainedmachine.brq.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Holasek <pholasek@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@linux.intel.com>

Hello Petr,

On Wed, Dec 09, 2015 at 05:19:59PM +0100, Petr Holasek wrote:
> Hi Andrea,
> 
> I've been running stress tests against this patchset for a couple of hours
> and everything was ok. However, I've allocated ~1TB of memory and got
> following lockup during disabling KSM with 'echo 2 > /sys/kernel/mm/ksm/run':
> 
> [13201.060601] INFO: task ksmd:351 blocked for more than 120 seconds.
> [13201.066812]       Not tainted 4.4.0-rc4+ #5
> [13201.070996] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables
> this message.
> [13201.078830] ksmd            D ffff883f65eb7dc8     0   351      2
> 0x00000000
> [13201.085903]  ffff883f65eb7dc8 ffff887f66e26400 ffff883f65d5e400
> ffff883f65eb8000
> [13201.093343]  ffffffff81a65144 ffff883f65d5e400 00000000ffffffff
> ffffffff81a65148
> [13201.100792]  ffff883f65eb7de0 ffffffff816907e5 ffffffff81a65140
> ffff883f65eb7df0
> [13201.108242] Call Trace:
> [13201.110708]  [<ffffffff816907e5>] schedule+0x35/0x80
> [13201.115676]  [<ffffffff81690ace>] schedule_preempt_disabled+0xe/0x10
> [13201.122044]  [<ffffffff81692524>] __mutex_lock_slowpath+0xb4/0x130
> [13201.128237]  [<ffffffff816925bf>] mutex_lock+0x1f/0x2f
> [13201.133395]  [<ffffffff811debd2>] ksm_scan_thread+0x62/0x1f0
> [13201.139068]  [<ffffffff810c8ac0>] ? wait_woken+0x80/0x80
> [13201.144391]  [<ffffffff811deb70>] ? ksm_do_scan+0x1140/0x1140
> [13201.150164]  [<ffffffff810a4378>] kthread+0xd8/0xf0
> [13201.155056]  [<ffffffff810a42a0>] ? kthread_park+0x60/0x60
> [13201.160551]  [<ffffffff8169460f>] ret_from_fork+0x3f/0x70
> [13201.165961]  [<ffffffff810a42a0>] ? kthread_park+0x60/0x60
> 
> It seems this is not connected with the new code, but it would be nice to
> also make unmerge_and_remove_all_rmap_items() more scheduler friendly.

Agreed. I run echo 2 many times here with big stable_node chains but
this one never happened here, it likely shows easier on the 1TiB.

It was most certainly the teardown of an enormous stable_node chain,
while at it I also added one more cond_resched() in the echo 2 slow
path to make the vma list walk more schedule friendly (even thought it
would never end in softlockup in practice, but max_map_count can be
increased via sysctl so it's safer and worth it considering how slow
is that path).
