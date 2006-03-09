Subject: [PATCH/RFC] Migrate-on-fault prototype 0/5 V0.1 - Overview
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reply-To: lee.schermerhorn@hp.com
Content-Type: text/plain
Date: Thu, 09 Mar 2006 13:28:25 -0500
Message-Id: <1141928905.6393.10.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

For your entertainment:

Migrate-on-fault prototype 0/5 V0.1 - Overview

This series of patches, against 2.6.16-rc5-git11, implements page
migration
in the fault path.  Based on discussions with Christoph Lameter, this 
seems like the next logical step in page migration.

The basic idea is that when a fault handler [do_swap_page,
filemap_nopage,
...] finds a cached page with zero mappings that is otherwise "stable"--
i.e., no writebacks--this is a good opportunity to check whether the 
page resides on the node indicated by the policy in the current context.

We only want to check if there are zero mappings because 1) we can
easily
migrate the page--don't have to go through the effort of removing all
mappings and 2) default policy--a common case--can give different
answers
from different tasks running on different nodes.  Checking the policy
when there are zero mappings effectively implements a "first touch"
placement policy.

Note that this mechanism can be used to migrate page cache pages that 
were read in earlier, are no longer referenced, but are about to be
used by a new task on another node from where the page resides.  The
same mechanism can be used to pull anon pages along with a task when
the load balancer decides to move it to another node.  However, that
will require a bit more mechanism, and is the subject of another
patch series.

The current [2.6.16-rc5+] direct migration patches support most of the
mechanism that is required to implement this "migration on fault".  
Some of the necessary operations are combined in functions with other
code that isn't required [must not be executed] in the fault path,
so these have been separated out in a couple of cases.

Then we need to add the function[s] to test the current page in the
fault path for zero mapping, no writebacks, misplacement; and the
function[s] to acutally migrate the page contents to a newly
allocated page using the [modified] migratepage address space
operations of the direct migration mechanism.

The Patches:

The patches are broken out in the order I implemented them. Each
should build and boot on its own.  [at least they did at one time!]

migrate-on-fault-01-separate-unmap-replace.patch

Separates the mm/vmscan.c:migrate_page_remove_references()
function into its 2 distinct operations:  removing references
[try_to_unmap()], and replacing the old page in the radix 
tree of the page's "mapping".  Only the second part is 
needed in the fault path, as the page is already completely
unmapped.

A wrapper function that calls both operations is provided,
and the 2 places that call migrate_page_remove_references()
have been modified to call that wrapper.

migrate-on-fault-02-mpol_misplaced.patch

This patch implements the function mpol_misplaced() in
mm/mempolicy.c to check whether a page resides on the
node indicated by the vma and address arguments.  If
so, it returns 0 [!misplaced].  If not, it returns an
indication of whether the policy was interleaved or not
[for properly accounting later allocation] and passes the
node indicated by the policy through a pointer argument.

Because this will be called in the fault path, I don't 
want to go through the effort of actually allocating a
page--e.g., via alloc_page_vma()--only to find that the
current page in on the correct node.  However, I wanted
to come to the same answer that alloc_page_vma() would.
So, mpol_misplaced() mimics the node computation logic
of alloc_page_vma().

migrate-on-fault-03-migrate_misplaced_page.patch

This patch contains the main migrate on fault functions:

check_migrate_misplaced_page() is implemented as a static
inline function in mempolicy.h when MIGRATION is configured.
If the page has zero mappings, is stable and misplaced,
check_*() will call migrate_misplaced_page() in vmscan.c
to do the dirty work.  If for any reason the page can't
or shouldn't be migrated, these functions will return the
old page in the state it was found.

Note that when a page is NOT found in the cache, and the fault
handler has to allocate one and read it in, it will have zero
mappings, so check_migrate_misplaced_page() WILL call
mpol_misplaced() to see if it needs migration.  Of course, it
should have been allocated on the correct node, so no migration
should be necessary.  However, it's possible that the node 
indicated by the policy has no free pages so the newly 
allocated page may be on a different node.  In this case, I
guess check_migrate_misplaced_page() will attempt to migrate
it.  In either case, the "unnecessary" calls to mpol_misplaced()
and to migrate_misplaced_page(), if the original allocation
"overflowed", occur after an IO, so this is the slow path
anyway.  

When MIGRATION is NOT configured, check_migrate_misplaced_page()
becomes a macro that evaluates to its argument page.

More details with the patch.

migrate-on-fault-04.1-misplaced-anon-pages.patch

This is a simple one-liner [OK, 2, counting an empty line]
to call check_migrate_misplaced_page() from do_swap_page()
in memory.c.  

Patches to hook other fault paths [filemap_nopage(), etc.] 
are TBD, based on feedback to this series.  [Oh, I'll 
probably do them anyway, to measure the effects.]

migrate-on-fault-05-mbind-lazy-migrate.patch

This patch adds an MPOL_MF_LAZY [maybe should be '_DEFERRED?]
flag to modify the behavior of MPOL_MF_MOVE[_ALL].  When
the 'LAZY flag is specified, mbind() simply unmaps eligible
pages in the specified range, moving anon pages to the
swap cache, if not already there.  Then, when the task
touch the pages, or queries their location via 
get_mempolicy(..., MPOL_F_NODE|MPOL_F_ADDR), it will take
fault, find the page in the cache and migrate it, if the
policy so indicates.  Actually, this will only happen for
anon pages, until additional fault paths are hooked up.

This patch allows me to test the migrate on fault mechanism
by forcing pages to be unmapped.


Testing:

I have tested migrate-on-fault of anon pages using the MPOL_MF_LAZY 
extension to mbind() discussed in patch 5 above on 2.6.16-rc5-git11.
I have an ad hoc [odd hack?] test program, called memtoy, available at:

http://free.linux.hp.com/~lts/Tools/memtoy-latest.tar.gz

The Xpm-tests subdirectory in the tarball contains memtoy test
scripts for "manual page migration"--i.e., the migrate_pages()
syscall, "direct migration" using mbind(MPOL_MF_MOVE) and
migrate-on-fault using mbind(MPOL_MF_MOVE+MPOL_MF_LAZY).

---
Why are these patches NOT against the -mm tree?

I've been using some trace instrumentation that relies on relayfs.
I haven't been motivated to port it to the sysfs relay channels yet.
Soon come...

If you're interested in seeing an annotated trace log of direct
migration
and migrate-on-fault [lazy] in action, you can find one at:

http://free.linux.hp.com/~lts/Tools/mtrace-anon-8p-direct+lazy.log

This file contains the log for 2 memtoy runs, each migrating an 8 page
anon segment from one node to another.  


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
