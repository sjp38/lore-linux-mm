Date: Fri, 3 Nov 2000 20:36:08 -0500 (EST)
From: Eric Lowe <elowe@myrile.madriver.k12.oh.us>
Subject: Re: PATCH [2.4.0test10]: Kiobuf#02, fault-in fix
In-Reply-To: <20001103232721.D27034@athlon.random>
Message-ID: <Pine.BSF.4.10.10011032029190.1962-100000@myrile.madriver.k12.oh.us>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@nl.linux.org>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

> On Thu, Nov 02, 2000 at 01:40:21PM +0000, Stephen C. Tweedie wrote:
> > +			if (!write || pte_write(*pte))
>s
> You should check pte is dirty, not only writeable.
> 
> >  		if (handle_mm_fault(current->mm, vma, ptr, datain) <= 0) 
> >  			goto out_unlock;
> >  		spin_lock(&mm->page_table_lock);
> > -		map = follow_page(ptr);
> > +		map = follow_page(ptr, datain);
> 
> Here you should _first_ follow_page and do handle_mm_fault _only_ if the pte is
> not ok. This way only during first pagein we'll walk the pagetables two times,
> all the other times we'll walk pagetables only once just to check that the
> mapping is still there.
> 

Andrea,
I agree with you on this one, and in fact, my 2.2 patches already
do both these things.

Keep in mind this is for 2.2, not 2.4, need to merge my fixes
with what we have so far.  Do you agree this algorithm is correct?
(or at least closer):
+static inline int fault_page_in(struct vm_area_struct * vma,
+	unsigned long address, int write_access, pte_t *pte)
+{
+	int ret;
+
+	if (pte_present(*pte)) {
+		if (write_access && pte_write(*pte))
+			return 1;
+	}
+
+	ret = handle_pte_fault(current, vma, address, write_access, pte);
+	if (ret > 0)
+		update_mmu_cache(vma, address, *pte);
+	return (ret > 0);
+}
+

[...]

+	/*
+	 * First of all, try to fault in all of the necessary pages
+	 */
+	while (ptr < end) {
+		if (!vma || ptr >= vma->vm_end) {
+			vma = find_vma(current->mm, ptr);
+			if (!vma)
+				goto out_unlock;
+		}
+		pte = get_pte(vma, ptr);
+		if (!pte)
+			goto out_unlock;
+
+		if (!fault_page_in(vma, ptr, write_access, pte))
+			goto out_unlock;
+
+		page = pte_page(*pte);
+		if (!page) {
+			err = -EAGAIN;
+			goto out_unlock;
+		}
+		map = get_page_map(page);
+		if (map) {
+			if (TryLockPage(map))
+				goto retry;
+			atomic_inc(&map->count);
+			set_bit(PG_dirty, &map->flags);
+		}
+
+		if (!pte_present(*pte) || (write_access && !pte_write(*pte))) {
+			err = -EAGAIN;
+			goto out_unlock;
+		}
+		if (write_access && !pte_dirty(*pte))
+			panic("map_user_kiobuf: writable page w/o dirty pte\n");
+
+		dprintk ("Installing page %p %p: %d\n", (void *)page, map, i);
+		iobuf->pagelist[i] = page;
+		iobuf->maplist[i] = map;
+		iobuf->nr_pages = ++i;
+
+		ptr += PAGE_SIZE;
+	}
+

In my tests, the if (write_access && !pte_dirty(*pte)) never tripped,
but I don't know enough to know if this is valid or if we need
to do something else to guarantee the pte is dirty if it's writable?

--
Eric Lowe
Software Engineer, Systran Corporation
elowe@systran.com


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
