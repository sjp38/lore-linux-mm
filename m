Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B7F1E8D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 09:56:58 -0400 (EDT)
Received: by pzk32 with SMTP id 32so783784pzk.14
        for <linux-mm@kvack.org>; Mon, 28 Mar 2011 06:56:57 -0700 (PDT)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [RFC/RFT 0/6] nommu: improve the vma list handling
Date: Mon, 28 Mar 2011 22:56:41 +0900
Message-Id: <1301320607-7259-1-git-send-email-namhyung@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Mundt <lethal@linux-sh.org>, David Howells <dhowells@redhat.com>, Greg Ungerer <gerg@snapgear.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

When I was reading nommu code, I found that it handles the vma list/tree in
an unusual way. IIUC, because there can be more than one identical/overrapped
vmas in the list/tree, it sorts the tree more strictly and does a linear
search on the tree. But it doesn't applied to the list (i.e. the list could
be constructed in a different order than the tree so that we can't use the
list when finding the first vma in that order).

Since inserting/sorting a vma in the tree and link is done at the same time,
we can easily construct both of them in the same order. And linear searching
on the tree could be more costly than doing it on the list, it can be
converted to use the list.

Also, after the commit 297c5eee3724 ("mm: make the vma list be doubly linked")
made the list be doubly linked, there were a couple of code need to be fixed
to construct the list properly.

Patch 1/6 is a preparation. It maintains the list sorted same as the tree and
construct doubly-linked list properly. Patch 2/6 is a simple optimization for
the vma deletion. Patch 3/6 and 4/6 convert tree traversal to list traversal
and the rest are simple fixes and cleanups.

Note that I don't have a system to test on, so these are *totally untested*
patches. There could be some basic errors in the code. In that case, please
kindly let me know. :)

Anyway, I just compiled them on my x86_64 desktop using this command:

  make mm/nommu.o

(Of course this required few of dirty-fixes to proceed)

Also note that these are on top of v2.6.38.

Any comments are welcome.

Thanks.


---
Namhyung Kim (6):
  nommu: sort mm->mmap list properly
  nommu: don't scan the vma list when deleting
  nommu: find vma using the sorted vma list
  nommu: check the vma list when unmapping file-mapped vma
  nommu: fix a potential memory leak in do_mmap_private()
  nommu: fix a compile warning in do_mmap_pgoff()

 mm/nommu.c |  103 +++++++++++++++++++++++++++++++++--------------------------
 1 files changed, 58 insertions(+), 45 deletions(-)

--
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
