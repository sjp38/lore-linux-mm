Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7894B8E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 05:06:49 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id b3so935849edi.0
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 02:06:49 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e2-v6si503457ejc.189.2019.01.15.02.06.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 02:06:47 -0800 (PST)
Subject: Re: KMSAN: uninit-value in mpol_rebind_mm
References: <000000000000c06550057e4cac7c@google.com>
 <a71997c3-e8ae-a787-d5ce-3db05768b27c@suse.cz>
 <CACT4Y+bRvwxkdnyRosOujpf5-hkBwd2g0knyCQHob7p=0hC=Dw@mail.gmail.com>
 <52835ef5-6351-3852-d4ba-b6de285f96f5@suse.cz>
 <20190104172802.ce9c4b77577a9c2810f04171@linux-foundation.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <73da3e9c-cc84-509e-17d9-0c434bb9967d@suse.cz>
Date: Tue, 15 Jan 2019 11:06:44 +0100
MIME-Version: 1.0
In-Reply-To: <20190104172802.ce9c4b77577a9c2810f04171@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, syzbot <syzbot+b19c2dc2c990ea657a71@syzkaller.appspotmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexander Potapenko <glider@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux@dominikbrodowski.net, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, xieyisheng1@huawei.com, zhong jiang <zhongjiang@huawei.com>

On 1/5/19 2:28 AM, Andrew Morton wrote:
> On Fri, 4 Jan 2019 09:50:31 +0100 Vlastimil Babka <vbabka@suse.cz> wrote:
> 
>>> Yes, it doesn't and it's not trivial to do. The tool reports uses of
>>> unint _values_. Values don't necessary reside in memory. It can be a
>>> register, that come from another register that was calculated as a sum
>>> of two other values, which may come from a function argument, etc.
>>
>> I see. BTW, the patch I sent will be picked up for testing, or does it
>> have to be in mmotm/linux-next first?
> 
> I grabbed it.  To go further we'd need a changelog, a signoff,
> description of testing status, reviews, a Fixes: and perhaps a
> cc:stable ;)

Here's the full patch. Since there was no reproducer, there probably
won't be any conclusive testing, but we might interpret lack of further
KSMSAN reports as a success :)

----8<----

>From 81ad0c822cb022cacea9b69565e12aac96dfb3fc Mon Sep 17 00:00:00 2001
From: Vlastimil Babka <vbabka@suse.cz>
Date: Thu, 3 Jan 2019 09:31:59 +0100
Subject: [PATCH] mm, mempolicy: fix uninit memory access

Syzbot with KMSAN reports (excerpt):

==================================================================
BUG: KMSAN: uninit-value in mpol_rebind_policy mm/mempolicy.c:353 [inline]
BUG: KMSAN: uninit-value in mpol_rebind_mm+0x249/0x370 mm/mempolicy.c:384
CPU: 1 PID: 17420 Comm: syz-executor4 Not tainted 4.20.0-rc7+ #15
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x173/0x1d0 lib/dump_stack.c:113
  kmsan_report+0x12e/0x2a0 mm/kmsan/kmsan.c:613
  __msan_warning+0x82/0xf0 mm/kmsan/kmsan_instr.c:295
  mpol_rebind_policy mm/mempolicy.c:353 [inline]
  mpol_rebind_mm+0x249/0x370 mm/mempolicy.c:384
  update_tasks_nodemask+0x608/0xca0 kernel/cgroup/cpuset.c:1120
  update_nodemasks_hier kernel/cgroup/cpuset.c:1185 [inline]
  update_nodemask kernel/cgroup/cpuset.c:1253 [inline]
  cpuset_write_resmask+0x2a98/0x34b0 kernel/cgroup/cpuset.c:1728

...

Uninit was created at:
  kmsan_save_stack_with_flags mm/kmsan/kmsan.c:204 [inline]
  kmsan_internal_poison_shadow+0x92/0x150 mm/kmsan/kmsan.c:158
  kmsan_kmalloc+0xa6/0x130 mm/kmsan/kmsan_hooks.c:176
  kmem_cache_alloc+0x572/0xb90 mm/slub.c:2777
  mpol_new mm/mempolicy.c:276 [inline]
  do_mbind mm/mempolicy.c:1180 [inline]
  kernel_mbind+0x8a7/0x31a0 mm/mempolicy.c:1347
  __do_sys_mbind mm/mempolicy.c:1354 [inline]

As it's difficult to report where exactly the uninit value resides in the
mempolicy object, we have to guess a bit. mm/mempolicy.c:353 contains this
part of mpol_rebind_policy():

        if (!mpol_store_user_nodemask(pol) &&
            nodes_equal(pol->w.cpuset_mems_allowed, *newmask))

"mpol_store_user_nodemask(pol)" is testing pol->flags, which I couldn't ever
see being uninitialized after leaving mpol_new(). So I'll guess it's actually
about accessing pol->w.cpuset_mems_allowed on line 354, but still part of
statement starting on line 353.

For w.cpuset_mems_allowed to be not initialized, and the nodes_equal()
reachable for a mempolicy where mpol_set_nodemask() is called in do_mbind(), it
seems the only possibility is a MPOL_PREFERRED policy with empty set of nodes,
i.e. MPOL_LOCAL equivalent, with MPOL_F_LOCAL flag. Let's exclude such policies
from the nodes_equal() check. Note the uninit access should be benign anyway,
as rebinding this kind of policy is always a no-op. Therefore no actual need for
stable inclusion.

Link: http://lkml.kernel.org/r/a71997c3-e8ae-a787-d5ce-3db05768b27c@suse.cz
Reported-by: syzbot+b19c2dc2c990ea657a71@syzkaller.appspotmail.com
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Alexander Potapenko <glider@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Yisheng Xie <xieyisheng1@huawei.com>
Cc: zhong jiang <zhongjiang@huawei.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 mm/mempolicy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index d4496d9d34f5..a0b7487b9112 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -350,7 +350,7 @@ static void mpol_rebind_policy(struct mempolicy *pol, const nodemask_t *newmask)
 {
 	if (!pol)
 		return;
-	if (!mpol_store_user_nodemask(pol) &&
+	if (!mpol_store_user_nodemask(pol) && !(pol->flags & MPOL_F_LOCAL) &&
 	    nodes_equal(pol->w.cpuset_mems_allowed, *newmask))
 		return;
 
-- 
2.20.1
