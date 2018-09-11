Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 25D198E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 05:03:29 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id 57-v6so8396162edt.15
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 02:03:29 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y15-v6si1913010edc.338.2018.09.11.02.03.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Sep 2018 02:03:27 -0700 (PDT)
Subject: Re: [PATCH] mm, thp: relax __GFP_THISNODE for MADV_HUGEPAGE mappings
References: <20180907130550.11885-1-mhocko@kernel.org>
 <f7ed71c1-d599-5257-fd8f-041eb24d9f29@profihost.ag>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <186d4fd2-546b-d193-448f-52662931a0b9@suse.cz>
Date: Tue, 11 Sep 2018 11:03:26 +0200
MIME-Version: 1.0
In-Reply-To: <f7ed71c1-d599-5257-fd8f-041eb24d9f29@profihost.ag>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Zi Yan <zi.yan@cs.rutgers.edu>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 09/08/2018 08:52 PM, Stefan Priebe - Profihost AG wrote:
> Hello,
> 
> whlie using this path i got another stall - which i never saw under
> kernel 4.4. Here is the trace:
> [305111.932698] INFO: task ksmtuned:1399 blocked for more than 120 seconds.
> [305111.933612]       Tainted: G                   4.12.0+105-ph #1
> [305111.934456] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
> disables this message.
> [305111.935323] ksmtuned        D    0  1399      1 0x00080000
> [305111.936207] Call Trace:
> [305111.937118]  ? __schedule+0x3bc/0x830
> [305111.937991]  schedule+0x32/0x80
> [305111.938837]  schedule_preempt_disabled+0xa/0x10
> [305111.939687]  __mutex_lock.isra.4+0x287/0x4c0

Hmm so is this waiting on mutex_lock(&ksm_thread_mutex)? Who's holding it?

Looking at your original report [1] I see more tasks waiting on a semaphore:

[245654.463746] INFO: task pvestatd:3175 blocked for more than 120 seconds.
[245654.464730] Tainted: G W 4.12.0+98-ph <a
href="/view.php?id=1" title="[geschlossen] Integration Ramdisk"
class="resolved">0000001</a>
[245654.465666] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[245654.466591] pvestatd D 0 3175 1 0x00080000
[245654.467495] Call Trace:
[245654.468413] ? __schedule+0x3bc/0x830
[245654.469283] schedule+0x32/0x80
[245654.470108] rwsem_down_read_failed+0x121/0x170
[245654.470918] ? call_rwsem_down_read_failed+0x14/0x30
[245654.471729] ? alloc_pages_current+0x91/0x140
[245654.472530] call_rwsem_down_read_failed+0x14/0x30
[245654.473316] down_read+0x13/0x30
[245654.474064] proc_pid_cmdline_read+0xae/0x3f0

- probably down_read(&mm->mmap_sem);

[245654.485537] INFO: task service:86643 blocked for more than 120 seconds.
[245654.486015] Tainted: G W 4.12.0+98-ph <a
href="/view.php?id=1" title="[geschlossen] Integration Ramdisk"
class="resolved">0000001</a>
[245654.486502] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[245654.486960] service D 0 86643 1 0x00080000
[245654.487423] Call Trace:
[245654.487865] ? __schedule+0x3bc/0x830
[245654.488286] schedule+0x32/0x80
[245654.488763] rwsem_down_read_failed+0x121/0x170
[245654.489200] ? __handle_mm_fault+0xd67/0x1060
[245654.489668] ? call_rwsem_down_read_failed+0x14/0x30
[245654.490088] call_rwsem_down_read_failed+0x14/0x30
[245654.490538] down_read+0x13/0x30
[245654.490964] __do_page_fault+0x32b/0x430
[245654.491389] ? get_vtime_delta+0x13/0xb0
[245654.491835] do_page_fault+0x2a/0x70
[245654.492253] ? page_fault+0x65/0x80
[245654.492703] page_fault+0x7b/0x80

- page fault, so another mmap_sem for read

[245654.496050] INFO: task safe_timer:86651 blocked for more than 120
seconds.
[245654.496466] Tainted: G W 4.12.0+98-ph <a
href="/view.php?id=1" title="[geschlossen] Integration Ramdisk"
class="resolved">0000001</a>
[245654.496916] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[245654.497336] safe_timer D 0 86651 1 0x00080000
[245654.497790] Call Trace:
[245654.498211] ? __schedule+0x3bc/0x830
[245654.498646] schedule+0x32/0x80
[245654.499074] rwsem_down_read_failed+0x121/0x170
[245654.499501] ? call_rwsem_down_read_failed+0x14/0x30
[245654.499959] call_rwsem_down_read_failed+0x14/0x30
[245654.500381] down_read+0x13/0x30
[245654.500851] __do_page_fault+0x32b/0x430
[245654.501285] ? get_vtime_delta+0x13/0xb0
[245654.501722] do_page_fault+0x2a/0x70
[245654.502163] ? page_fault+0x65/0x80
[245654.502600] page_fault+0x7b/0x80

- ditto

But those are different tasks that the one that was stalling allocation
while holding mmap_sem for write.

So I'm not sure what's going on, but maybe the reclaim is also stalled
due to waiting on some locks, and is thus victim of something else?

[1] https://lists.opensuse.org/opensuse-kernel/2018-08/msg00012.html
