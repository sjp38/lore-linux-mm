Message-ID: <4181EF2D.5000407@yahoo.com.au>
Date: Fri, 29 Oct 2004 17:20:13 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [PATCH 0/7] abstract pagetable locking and pte updates
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hello,

Following are patches that abstract page table operations to
allow lockless implementations by using cmpxchg or per-pte locks.

The work is inspired by and uses parts of Christoph Lameter's
pte cmpxchg work. It is not a clearly superior approach, but
an alternative way to tackle the problem.

It is a lot more intrusive, but it has also gone a bit further
in reducing page_table_lock usage. It is also designed with pte
locking in mind, which may be needed for PPC64, and will allow
100% removal of the page table lock.

The API is a transactional one, which fitted the problem quite
well in my mind. Please read comments for patch 4/7 for a more
detailed overview.

It is stable so far on i386 and x86-64. Page fault performance
on a quad opteron is up maybe 150%. Oh and it also rids
page_referenced_one of the page_table_lock, which could be a
win in some situations.

Known issues: Hugepages, nonlinear pages haven't been looked at
and are quite surely broken. TLB flushing (gather/finish) runs
without the page table lock, which will break at least SPARC64.
Additional atomic ops in copy_page_range slow down lmbench fork
by 7%.

Comments and discussion about this and/or Christoph's patches
welcome. They apply to 2.6.10-rc1-bk7

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
