Date: Wed, 18 Jun 2008 11:59:25 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH][RFC] fix kernel BUG at mm/migrate.c:719! in
 2.6.26-rc5-mm3
Message-Id: <20080618115925.9580aef0.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <1213724798.8707.41.camel@lts-notebook>
References: <20080611225945.4da7bb7f.akpm@linux-foundation.org>
	<20080617163501.7cf411ee.nishimura@mxp.nes.nec.co.jp>
	<1213724798.8707.41.camel@lts-notebook>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> > @@ -232,6 +232,7 @@ void migration_entry_wait(struct mm_stru
> >  	swp_entry_t entry;
> >  	struct page *page;
> >  
> > +retry:
> >  	ptep = pte_offset_map_lock(mm, pmd, address, &ptl);
> >  	pte = *ptep;
> >  	if (!is_swap_pte(pte))
> > @@ -243,11 +244,20 @@ void migration_entry_wait(struct mm_stru
> >  
> >  	page = migration_entry_to_page(entry);
> >  
> > -	get_page(page);
> > -	pte_unmap_unlock(ptep, ptl);
> > -	wait_on_page_locked(page);
> > -	put_page(page);
> > -	return;
> > +	/*
> > +	 * page count might be set to zero by page_freeze_refs()
> > +	 * in migrate_page_move_mapping().
> > +	 */
> > +	if (get_page_unless_zero(page)) {
> > +		pte_unmap_unlock(ptep, ptl);
> > +		wait_on_page_locked(page);
> > +		put_page(page);
> > +		return;
> > +	} else {
> > +		pte_unmap_unlock(ptep, ptl);
> > +		goto retry;
> > +	}
> > +
> 
> I'm not sure about this part.  If it IS needed, I think it would be
> needed independently of the unevictable/putback_lru_page() changes, as
> this race must have already existed.
> 
> However, unmap_and_move() replaced the migration entries with bona fide
> pte's referencing the new page before freeing the old page, so I think
> we're OK without this change.
> 

Without this part, I can easily get VM_BUG_ON in get_page,
even when processes in cpusets are only bash.

---
kernel BUG at include/linux/mm.h:297!
 :
Call Trace:
 [<ffffffff80280d82>] ? handle_mm_fault+0x3e5/0x782
 [<ffffffff8048c8bf>] ? do_page_fault+0x3d0/0x7a7
 [<ffffffff80263ed0>] ? audit_syscall_exit+0x2e4/0x303
 [<ffffffff8048a989>] ? error_exit+0x0/0x51
 Code: b8 00 00 00 00 00 e2 ff ff 48 8d 1c 02 48 8b 13 f6 c
2 01 75 04 0f 0b eb fe 80 e6 40 48 89 d8 74 04 48 8b 43 10 83 78 08 00 75 04 <0f> 0b eb fe
 f0 ff 40 08 fe 45 00 f6 03 01 74 0a 31 f6 48 89 df
 RIP  [<ffffffff8029c309>] migration_entry_wait+0xcb/0xfa
 RSP <ffff81062cc6fe58>
---

I agree that this part should be fixed independently, and
Kamezawa-san has already posted a patch for this.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
