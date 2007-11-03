Date: Sat, 3 Nov 2007 18:42:29 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [RFC PATCH 0/10] split anon and file LRUs
Message-ID: <20071103184229.3f20e2f0@bree.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The current page replacement scheme in Linux has a number of problems,
which can be boiled down to:
- Sometimes the kernel evicts the wrong pages, which can result in
  bad performance.
- The kernel scans over pages that should not be evicted.  On systems
  with a few GB of RAM, this can result in the VM using an annoying
  amount of CPU.  On systems with >128GB of RAM, this can knock the
  system out for hours since excess CPU use is compounded with lock
  contention and other issues.

This patch series tries to address the issues by splitting the LRU
lists into two sets, one for swap/ram backed pages ("anon") and
one for filesystem backed pages ("file").

The current version only has the infrastructure.  Large changes to
the page replacement policy will follow later.

More details can be found on this page:

	http://linux-mm.org/PageReplacementDesign

TODO:
- have any mlocked and ramfs pages live off of the LRU list,
  so we do not need to scan these pages
- switch to SEQ replacement for the anon LRU lists, so the
  worst case number of pages to scan is reduced greatly.
- figure out if the file LRU lists need page replacement
  changes to help with worst case scenarios
- implement and benchmark a scalable non-resident page
  tracking implementation in the radix tree, this may make
  the anon/file balancing algorithm more stable and could
  allow for further simplifications in the balancing algorithm

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
