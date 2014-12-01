Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id D1F656B006C
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 07:05:06 -0500 (EST)
Received: by mail-wg0-f53.google.com with SMTP id l18so13906794wgh.40
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 04:05:06 -0800 (PST)
Received: from mellanox.co.il ([193.47.165.129])
        by mx.google.com with ESMTP id k4si13717850wiw.82.2014.12.01.04.05.05
        for <linux-mm@kvack.org>;
        Mon, 01 Dec 2014 04:05:06 -0800 (PST)
From: Shachar Raindel <raindel@mellanox.com>
Subject: [PATCH 0/5] Refactor do_wp_page, no functional change
Date: Mon,  1 Dec 2014 14:04:40 +0200
Message-Id: <1417435485-24629-1-git-send-email-raindel@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: kirill.shutemov@linux.intel.com, mgorman@suse.de, riel@redhat.com, ak@linux.intel.com, matthew.r.wilcox@intel.com, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, haggaie@mellanox.com, aarcange@redhat.com, pfeiner@google.com, hannes@cmpxchg.org, sagig@mellanox.com, walken@google.com, raindel@mellanox.com

Currently do_wp_page contains 265 code lines. It also contains 9 goto
statements, of which 5 are targeting labels which are not cleanup
related. This makes the function extremely difficult to
understand. The following patches are an attempt at breaking the
function to its basic components, and making it easier to understand.

The first 4 patches are straight forward function extractions from
do_wp_page. As we extract functions, we remove unneeded parameters and
simplify the code as much as possible. However, the functionality is
supposed to remain completely unchanged. The patches also attempt to
document the functionality of each extracted function.

The last patch moves the MMU notifier call. Originally, it was
conditionally called from the unlock step. The patch moves it to the
only call site which sets the conditions to call the notifier. This
results in a minor functional change - the notifier for the end of the
invalidation is called after we release the page cache of the old
page, and not before. Given that the notifier is for the end of the
invalidation period, this is supposed to be OK for all users of the
MMU notifiers, who should not be touching the relevant page anyway.

The patches have been tested using trinity on a KVM machine with 4
vCPU, with all possible kernel debugging options enabled. So far, we
have not seen any regressions. We have also tested the patches with
internal tests we have that stress the MMU notifiers, again without
seeing any issues.

Shachar Raindel (5):
  mm: Refactor do_wp_page, extract the reuse case
  mm: Refactor do_wp_page - extract the unlock flow
  mm: refactor do_wp_page, extract the page copy flow
  mm: Refactor do_wp_page handling of shared vma into a function
  mm: Move the MMU-notifier code from wp_page_unlock to wp_page_copy

 mm/memory.c | 418 +++++++++++++++++++++++++++++++++++-------------------------
 1 file changed, 247 insertions(+), 171 deletions(-)

-- 
1.7.11.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
