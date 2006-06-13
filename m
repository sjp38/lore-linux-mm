From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Tue, 13 Jun 2006 13:21:20 +0200
Message-Id: <20060613112120.27913.71986.sendpatchset@lappy>
Subject: [PATCH 0/6] mm: tracking dirty pages -v8
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, David Howells <dhowells@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <christoph@lameter.com>, Martin Bligh <mbligh@google.com>, Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

The latest version of the tracking dirty pages patch-set.

This version handles VM_PFNMAP vmas and the COW case of shared RO mappings.

follow_page() got a comment for being weird, but in the light of the 
set_page_dirty() call that can not yet be removed does something sane.

copy_one_pte() also does the right thing, although I wonder why it clears
the dirty bit for children?

f_op->open() - sets a backing_dev_info
f_op->mmap() - modifies both vma->vm_flags and vma->vm_page_prot

Since our condition depends on both the backing_dev_info and vma->vm_flags
it cannot set vma->vm_page_prot before f_op->mmap().

However this means that !VM_PFNMAP vmas that are shared writable but do not
provide a f_op->nopage() and whos backing_dev_info does not have 
BDI_CAP_NO_ACCT_DIRTY, are left writable.

Peter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
