Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 25E106B006C
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 15:58:16 -0500 (EST)
Received: by mail-wg0-f50.google.com with SMTP id k14so15332531wgh.9
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 12:58:15 -0800 (PST)
Received: from mellanox.co.il ([193.47.165.129])
        by mx.google.com with ESMTP id j7si26678615wiz.40.2014.12.01.12.58.14
        for <linux-mm@kvack.org>;
        Mon, 01 Dec 2014 12:58:15 -0800 (PST)
From: Shachar Raindel <raindel@mellanox.com>
Subject: [PATCH v2 0/4]  Refactor do_wp_page, no functional change
Date: Mon,  1 Dec 2014 22:58:07 +0200
Message-Id: <1417467491-20071-1-git-send-email-raindel@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: kirill.shutemov@linux.intel.com, mgorman@suse.de, riel@redhat.com, ak@linux.intel.com, matthew.r.wilcox@intel.com, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, haggaie@mellanox.com, aarcange@redhat.com, pfeiner@google.com, hannes@cmpxchg.org, sagig@mellanox.com, walken@google.com, raindel@mellanox.com

Currently do_wp_page contains 265 code lines. It also contains 9 goto
statements, of which 5 are targeting labels which are not cleanup
related. This makes the function extremely difficult to
understand. The following patches are an attempt at breaking the
function to its basic components, and making it easier to understand.

The patches are straight forward function extractions from
do_wp_page. As we extract functions, we remove unneeded parameters and
simplify the code as much as possible. However, the functionality is
supposed to remain completely unchanged. The patches also attempt to
document the functionality of each extracted function. In patch 2, we
split the unlock logic to the contain logic relevant to specific needs
of each use case, instead of having huge number of conditional
decisions in a single unlock flow.


Change log:

v0 -> v1:
- Minor renaming of argument in patch 1
- Instead of having a complex unlock function, unlock the needed parts
  in the relevant call sites. Simplify code accordingly.
- Avoid calling wp_page_copy with the ptl held.
- Rename wp_page_shared_vma to wp_page_shared, flip the logic of a
  check there to goto the end of the function if no function, instead
  of having a large conditional block.

v1 -> v2:
- Cosmetical white space changes in patch 4

Many thanks to Kirill for reviewing the patches.

Shachar Raindel (4):
  mm: Refactor do_wp_page, extract the reuse case
  mm: Refactor do_wp_page - rewrite the unlock flow
  mm: refactor do_wp_page, extract the page copy flow
  mm: Refactor do_wp_page handling of shared vma into a function

 mm/memory.c | 393 +++++++++++++++++++++++++++++++++++-------------------------
 1 file changed, 227 insertions(+), 166 deletions(-)

-- 
1.7.11.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
