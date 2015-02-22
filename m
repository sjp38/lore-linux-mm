Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 98A1D6B0072
	for <linux-mm@kvack.org>; Sun, 22 Feb 2015 08:42:32 -0500 (EST)
Received: by mail-wi0-f173.google.com with SMTP id bs8so11683014wib.0
        for <linux-mm@kvack.org>; Sun, 22 Feb 2015 05:42:32 -0800 (PST)
Received: from mellanox.co.il ([193.47.165.129])
        by mx.google.com with ESMTP id da1si12590165wib.25.2015.02.22.05.42.30
        for <linux-mm@kvack.org>;
        Sun, 22 Feb 2015 05:42:31 -0800 (PST)
From: Shachar Raindel <raindel@mellanox.com>
Subject: [PATCH V5 0/4] Refactor do_wp_page, no functional change
Date: Sun, 22 Feb 2015 15:42:14 +0200
Message-Id: <1424612538-25889-1-git-send-email-raindel@mellanox.com>
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

v2 -> v3:
- Rebase to v3.19-rc3
- Add missing Acked-by and CC notations to the commit messages.

v3 -> v4:
- Rebase to next-20150219

v4 -> v5:
- Fix minor style issues found by Johannes Weiner <hannes@cmpxchg.org>
- Add Acked-by from Johannes Weiner <hannes@cmpxchg.org>

Shachar Raindel (4):
  mm: Refactor do_wp_page, extract the reuse case
  mm: Refactor do_wp_page - rewrite the unlock flow
  mm: refactor do_wp_page, extract the page copy flow
  mm: Refactor do_wp_page handling of shared vma into a function

 mm/memory.c | 371 +++++++++++++++++++++++++++++++++++-------------------------
 1 file changed, 216 insertions(+), 155 deletions(-)

-- 
1.7.11.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
