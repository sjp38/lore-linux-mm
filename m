Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 6A6016B0032
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 10:34:59 -0400 (EDT)
Date: Mon, 03 Jun 2013 10:34:41 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1370270081-pv4wkd99-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20130603132641.GB18588@dhcp22.suse.cz>
References: <1369770771-8447-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1369770771-8447-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20130603132641.GB18588@dhcp22.suse.cz>
Subject: Re: [PATCH v3 2/2] migrate: add migrate_entry_wait_huge()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andi Kleen <andi@firstfloor.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org

On Mon, Jun 03, 2013 at 03:26:41PM +0200, Michal Hocko wrote:
> On Tue 28-05-13 15:52:51, Naoya Horiguchi wrote:
> > When we have a page fault for the address which is backed by a hugepage
> > under migration, the kernel can't wait correctly and do busy looping on
> > hugepage fault until the migration finishes.
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
> OK, this looks good to me and I guess you can safely replace
> huge_pte_lockptr by &(mm)->page_table_lock so you can implement this
> even without risky 1/2 of this series. The patch should be as simple as
> possible especially when it goes to the stable.

Yes, I agree.

> > Without 1/2 dependency
> Reviewed-by: Michal Hocko <mhocko@suse.cz>

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
