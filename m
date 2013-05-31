Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 9F0636B0033
	for <linux-mm@kvack.org>; Fri, 31 May 2013 15:46:41 -0400 (EDT)
Date: Fri, 31 May 2013 15:46:24 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1370029584-qjpvbow1-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20130531123003.1baf00c89bb25514de63c4f6@linux-foundation.org>
References: <1369770771-8447-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1369770771-8447-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20130531123003.1baf00c89bb25514de63c4f6@linux-foundation.org>
Subject: Re: [PATCH v3 2/2] migrate: add migrate_entry_wait_huge()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org

> That changelog is not suitable for a -stable patch.  People who
> maintain and utilize the stable trees need to know in some detail what
> is the end-user impact of the patch (or, equivalently, of the bug
> which the patch fixes).

OK. So, could you insert the following sentence?

On Fri, May 31, 2013 at 12:30:03PM -0700, Andrew Morton wrote:
> On Tue, 28 May 2013 15:52:51 -0400 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> 
> > When we have a page fault for the address which is backed by a hugepage
> > under migration, the kernel can't wait correctly and do busy looping on
> > hugepage fault until the migration finishes.

As a result, users who try to kick hugepage migration (via soft offlining,
for example) occasionally experience long delay or soft lockup.

Thanks,
Naoya

> > This is because pte_offset_map_lock() can't get a correct migration entry
> > or a correct page table lock for hugepage.
> > This patch introduces migration_entry_wait_huge() to solve this.
> > 
> > Note that the caller, hugetlb_fault(), gets the pointer to the "leaf"
> > entry with huge_pte_offset() inside which all the arch-dependency of
> > the page table structure are. So migration_entry_wait_huge() and
> > __migration_entry_wait() are free from arch-dependency.
> > 
> > ChangeLog v3:
> >  - use huge_pte_lockptr
> > 
> > ChangeLog v2:
> >  - remove dup in migrate_entry_wait_huge()
> > 
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Reviewed-by: Rik van Riel <riel@redhat.com>
> > Cc: stable@vger.kernel.org # 2.6.35
> 
> That changelog is not suitable for a -stable patch.  People who
> maintain and utilize the stable trees need to know in some detail what
> is the end-user impact of the patch (or, equivalently, of the bug
> which the patch fixes).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
