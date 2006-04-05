Date: Tue, 4 Apr 2006 19:45:49 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 5/6] Swapless V1: Rip out swap migration code
In-Reply-To: <20060405100614.97d2e422.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0604041940390.28908@schroedinger.engr.sgi.com>
References: <20060404065739.24532.95451.sendpatchset@schroedinger.engr.sgi.com>
 <20060404065805.24532.65008.sendpatchset@schroedinger.engr.sgi.com>
 <20060404193714.2dfafa79.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0604040804560.26787@schroedinger.engr.sgi.com>
 <20060405100614.97d2e422.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, lee.schermerhorn@hp.com, lhms-devel@lists.sourceforge.net, taka@valinux.co.jp, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

On Wed, 5 Apr 2006, KAMEZAWA Hiroyuki wrote:

> I think adding SWP_TYPE_MIGRATION consideration to free_swap_and_cache() is
> enough against anon_vma vanishing. Because remove_migration_ptes() compares 
> old pte entry with old page's pfn, a page cannot be remapped into old place
> when anon_vma has gone. This is my first impression.

However, the last process containing the page may terminate and free the 
page, while we migrate. The SWAP_TYPE_MIGRATION pte will be rewoved 
together with the anonvma if no lock is held on mmap_sem. Then 
remove_migration_ptes() cannot obtain a anon_vma. So it would break 
without holding mmap_sem. We could fix this if we could somehow know that 
the last process mapping the page vanished and skip 
remove_migration_ptes().

> My concern is refcnt handling of SWP_TYPE_MIGRATION pages, but maybe no problem.

What are the exact concerns?


> Note: unuse_vma() doesn't check what pte entry contains.

unuse_vma() relies on the mapping via swap space that will no longer exist 
with the new code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
