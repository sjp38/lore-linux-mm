Date: Wed, 3 May 2000 21:05:48 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long) (backtrace)
In-Reply-To: <3910E40B.25FBEED4@sgi.com>
Message-ID: <Pine.LNX.4.10.10005032104090.765-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rajagopal Ananthanarayanan <ananth@sgi.com>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>


On Wed, 3 May 2000, Rajagopal Ananthanarayanan wrote:
> 
> One quick comment: Looking at this part of the diff to mm/vmscan.c:
> 
> ----------
> @@ -138,6 +139,7 @@
>                 flush_tlb_page(vma, address);
>                 vmlist_access_unlock(vma->vm_mm);
>                 error = swapout(page, file);
> +               UnlockPage(page);
>                 if (file) fput(file);
>                 if (!error)
>                         goto out_free_success;
> -----------------
> 
> Didn't you mean the UnlockPage() to go before swapout(...)?
> For example, one of the swapout routines, filemap_write_page()
> expects the page to be unlocked. If called with page locked,
> I'd expect a "double-trip" dead-lock. Right?

Nope. I changed swap_out() so that it gets called with the page locked
(which is much more like the other VM routines work too). Otherwise the
first thing swap_out() would do would be to just re-lock the page,and then
you'd have a window between the caller and the callee when neither the
page lock nor the page table lock were held.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
