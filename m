Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 47B096B0002
	for <linux-mm@kvack.org>; Tue, 21 May 2013 15:17:59 -0400 (EDT)
Message-ID: <519BC864.1010602@sr71.net>
Date: Tue, 21 May 2013 12:17:56 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv4 06/39] thp, mm: avoid PageUnevictable on active/inactive
 lru lists
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com> <1368321816-17719-7-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1368321816-17719-7-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 05/11/2013 06:23 PM, Kirill A. Shutemov wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> 
> active/inactive lru lists can contain unevicable pages (i.e. ramfs pages
> that have been placed on the LRU lists when first allocated), but these
> pages must not have PageUnevictable set - otherwise shrink_active_list
> goes crazy:
> 
> kernel BUG at /home/space/kas/git/public/linux-next/mm/vmscan.c:1122!
> invalid opcode: 0000 [#1] SMP
> CPU 0
> Pid: 293, comm: kswapd0 Not tainted 3.8.0-rc6-next-20130202+ #531
> RIP: 0010:[<ffffffff81110478>]  [<ffffffff81110478>] isolate_lru_pages.isra.61+0x138/0x260
> RSP: 0000:ffff8800796d9b28  EFLAGS: 00010082'
...

I'd much rather see a code snippet and description the BUG_ON() than a
register and stack dump.  That line number is wrong already. ;)

> For lru_add_page_tail(), it means we should not set PageUnevictable()
> for tail pages unless we're sure that it will go to LRU_UNEVICTABLE.
> Let's just copy PG_active and PG_unevictable from head page in
> __split_huge_page_refcount(), it will simplify lru_add_page_tail().
> 
> This will fix one more bug in lru_add_page_tail():
> if page_evictable(page_tail) is false and PageLRU(page) is true, page_tail
> will go to the same lru as page, but nobody cares to sync page_tail
> active/inactive state with page. So we can end up with inactive page on
> active lru.
> The patch will fix it as well since we copy PG_active from head page.

This all seems good, and if it fixes a bug, it should really get merged
as it stands.  Have you been actually able to trigger that bug in any
way in practice?

Acked-by: Dave Hansen <dave.hansen@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
