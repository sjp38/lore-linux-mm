Date: Fri, 3 Nov 2000 23:27:21 +0100
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: PATCH [2.4.0test10]: Kiobuf#02, fault-in fix
Message-ID: <20001103232721.D27034@athlon.random>
References: <20001102134021.B1876@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20001102134021.B1876@redhat.com>; from sct@redhat.com on Thu, Nov 02, 2000 at 01:40:21PM +0000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@nl.linux.org>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 02, 2000 at 01:40:21PM +0000, Stephen C. Tweedie wrote:
> +			if (!write || pte_write(*pte))

You should check pte is dirty, not only writeable.

>  		if (handle_mm_fault(current->mm, vma, ptr, datain) <= 0) 
>  			goto out_unlock;
>  		spin_lock(&mm->page_table_lock);
> -		map = follow_page(ptr);
> +		map = follow_page(ptr, datain);

Here you should _first_ follow_page and do handle_mm_fault _only_ if the pte is
not ok. This way only during first pagein we'll walk the pagetables two times,
all the other times we'll walk pagetables only once just to check that the
mapping is still there.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
