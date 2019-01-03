Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id EFBF58E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 03:36:58 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id l45so33459580edb.1
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 00:36:58 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o4-v6si4553554eje.73.2019.01.03.00.36.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 00:36:57 -0800 (PST)
Subject: Re: KMSAN: uninit-value in mpol_rebind_mm
References: <000000000000c06550057e4cac7c@google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a71997c3-e8ae-a787-d5ce-3db05768b27c@suse.cz>
Date: Thu, 3 Jan 2019 09:36:55 +0100
MIME-Version: 1.0
In-Reply-To: <000000000000c06550057e4cac7c@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+b19c2dc2c990ea657a71@syzkaller.appspotmail.com>, aarcange@redhat.com, akpm@linux-foundation.org, glider@google.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@dominikbrodowski.net, mhocko@suse.com, rientjes@google.com, syzkaller-bugs@googlegroups.com, xieyisheng1@huawei.com, zhongjiang@huawei.com


On 12/31/18 8:51 AM, syzbot wrote:
> Hello,
> 
> syzbot found the following crash on:
> 
> HEAD commit:    79fc24ff6184 kmsan: highmem: use kmsan_clear_page() in cop..
> git tree:       kmsan
> console output: https://syzkaller.appspot.com/x/log.txt?x=13c48b67400000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=901dd030b2cc57e7
> dashboard link: https://syzkaller.appspot.com/bug?extid=b19c2dc2c990ea657a71
> compiler:       clang version 8.0.0 (trunk 349734)
> 
> Unfortunately, I don't have any reproducer for this crash yet.
> 
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+b19c2dc2c990ea657a71@syzkaller.appspotmail.com
> 
> ==================================================================
> BUG: KMSAN: uninit-value in mpol_rebind_policy mm/mempolicy.c:353 [inline]
> BUG: KMSAN: uninit-value in mpol_rebind_mm+0x249/0x370 mm/mempolicy.c:384

The report doesn't seem to indicate where the uninit value resides in
the mempolicy object. I'll have to guess. mm/mempolicy.c:353 contains:

        if (!mpol_store_user_nodemask(pol) &&
            nodes_equal(pol->w.cpuset_mems_allowed, *newmask))

"mpol_store_user_nodemask(pol)" is testing pol->flags, which I couldn't
see being uninitialized after leaving mpol_new(). So I'll guess it's
actually about accessing pol->w.cpuset_mems_allowed on line 354.

For w.cpuset_mems_allowed to be not initialized and the nodes_equal()
reachable for a mempolicy where mpol_set_nodemask() is called in
do_mbind(), it seems the only possibility is a MPOL_PREFERRED policy
with empty set of nodes, i.e. MPOL_LOCAL equivalent. Let's see if the
patch below helps. This code is a maze to me. Note the uninit access
should be benign, rebinding this kind of policy is always a no-op.

----8<----
>From ff0ca29da6bc2572d7b267daa77ced6083e3f02d Mon Sep 17 00:00:00 2001
From: Vlastimil Babka <vbabka@suse.cz>
Date: Thu, 3 Jan 2019 09:31:59 +0100
Subject: [PATCH] mm, mempolicy: fix uninit memory access

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
2.19.2
