From: KUROSAWA Takahiro <kurosawa@valinux.co.jp>
Message-Id: <20060119080408.24736.13148.sendpatchset@debian>
Subject: [PATCH 0/2] Pzone based CKRM memory resource controller
Date: Thu, 19 Jan 2006 17:04:33 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ckrm-tech@lists.sourceforge.net
Cc: linux-mm@kvack.org, KUROSAWA Takahiro <kurosawa@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

(Changed the mail format into LKML-style and added linux-mm list to Cc:.
 These patches are almost the same as what I sent to ckrm-tech@lists.sf.net
 this week.)

The pzone (pseudo zone) based memory resource controller is yet
another implementation of the CKRM memory resource controller.
The existing CKRM memory resource controller counts the number of
pages that are allocated for tasks in a class in order to guarantee
and limit memory resources.  This requires changes to the existing
code for page allocation and page reclaim.

This memory resource controller takes a different approach aiming at
less impact to the existing Linux kernel code.  The pzone is
introduced to reserve the specified number of pages from the existing
zone.  The pzone uses the existing zone structure but adds several
members.  This enables us smaller impact to the memory management
code; our memory resource controller doesn't require special LRU lists
of pages or addition of a member to the page structure.  Also, it
doesn't require any changes for the algorithms in the memory
management system.

Tasks in a class allocate pages using the zonelist that consists of
pzones.  The memory resource guarantee is achieved by preventing tasks
in other classes from allocating pages from the pzones.  The number of
pages that a class holds can be achieved by limiting page allocations
only from the pzones and disabling page allocations from conventional
zones.

Thus, pages are accounted for the class of tasks that call
__alloc_pages().  Resource guarantee and limit are handled as the
same value.  User-space daemons could be introduced in order to
separate guarantee and limit.

The current implementation doesn't move resource account when the
class of a task is changed.  Moving resource account could be
implemented by using Christoph Lameter's page migration patches.

The patches are against linux-2.6.15, the first patch is for
introducing pzones and the second is for implementing memory resource
controller using pzones.  These patches are not adequately tested yet.
They are still under development and need further work.


Regards,

KUROSAWA, Takahiro

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
