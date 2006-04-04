Date: Mon, 3 Apr 2006 23:57:39 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060404065739.24532.95451.sendpatchset@schroedinger.engr.sgi.com>
Subject: [RFC 0/6] Swapless Page Migration V1: Overview
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <clameter@sgi.com>, lhms-devel@lists.sourceforge.net, Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Swapless Page migration

Currently page migration is depending on the ability to assign swap entries
to pages. This means that page migration will not work without swap although
that swap space is never used.

This patchset removes that dependency by introducing a special type of
swap entry that encodes a pfn number of the page being migrated. If that
swap pte is encountered then do_swap_page() will simply wait for the page
to become unlocked again (meaning page migration is complete) and then refetch
the pte. The special type of swap entry is only in use while the page to be
migrated is locked and therefore we can hopefully get away with just a few
supporting functions.

To some extend this covers the same ground as Lee's and Marcelo's migration
cache. However, I hope that this approach simplifies things without opening
up any holes. Please check.

The patchset is also a prerequisite for later patches that enable
migration of VM_LOCKED vmas and add the ability to exempt vmas from
page migration.

The patchset consists of six patches:

1. try_to_unmap(): Rename ignrefs to "migration"

   We will be using that try_to_unmap flag in the next patch to
   mean that page migration has called try_to_unmap().

2. Add SWP_TYPE_MIGRATION

   Add the SWP_TYPE_MIGRATION and a few necessary handlers for this
   type of entry.

3. try_to_unmap(): Create migration entries if migration calls
   try_to_unmap for pages without PageSwapCache() set.

4. Remove migration ptes

   This is a similar logic to remove_from_swap(). We walk through
   the reverse maps and replace all SWP_TYPE_MIGRATION entries with
   the correct pte. Since we only do that to SWP_TYPE_MIGRATION entries
   we can simplify the function.

5. Rip out old swap migration code

   Remove all the old swap based code. Note that this also removes the fallback
   to swap if all other attempts to migrate fail and also the ability to
   migrate to swap (which was never used)

6. Revise main migration code

   Revise the migration logic to use the new SWP_TYPE_MIGRATION. This means
   that anonymous pages without a mapping may be migrated. Therefore we have
   to deal with page counts differently.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
