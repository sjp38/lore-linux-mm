Date: Tue, 24 Apr 2007 13:06:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: 2.6.21-rc7-mm1 on test.kernel.org
Message-Id: <20070424130601.4ab89d54.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andy Whitcroft <apw@shadowen.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

An amd64 machine is crashing badly.

http://test.kernel.org/abat/84767/debug/console.log

VFS: Mounted root (ext3 filesystem) readonly.
Freeing unused kernel memory: 308k freed
INIT: version 2.86 booting
Bad page state in process 'init'
page:ffff81007e492628 flags:0x0100000000000000 mapping:0000000000000000 mapcount:0 count:1
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<ffffffff80250d3c>] bad_page+0x74/0x10d
 [<ffffffff80253090>] free_hot_cold_page+0x8d/0x172
 [<ffffffff802531cb>] free_hot_page+0xb/0xd
 [<ffffffff8025a9b7>] free_pgd_range+0x274/0x467
 [<ffffffff8025ac2a>] free_pgtables+0x80/0x8f
 [<ffffffff8026139c>] exit_mmap+0x90/0x11a
 [<ffffffff802270dd>] mmput+0x29/0x98
Bad page state in process 'hotplug'
page:ffff81017e458bb0 flags:0x0a00000000000000 mapping:0000000000000000 mapcount:0 count:1
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<ffffffff80250d3c>] bad_page+0x74/0x10d
 [<ffffffff80253090>] free_hot_cold_page+0x8d/0x172
 [<ffffffff802531cb>] free_hot_page+0xb/0xd
 [<ffffffff80227074>] __mmdrop+0x68/0xa8
 [<ffffffff80222911>] schedule_tail+0x48/0x86
 [<ffffffff8020960c>] ret_from_fork+0xc/0x25


So free_pgd_range() is freeing a refcount=1 page.  Can anyone see what
might be causing this?  The quicklist code impacts this area more than
anything else..

Naturally, I can't reproduce it (no amd64 boxen).  A bisection search would
be wonderful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
