Date: Mon, 11 Sep 2000 22:56:43 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] workaround for lost dirty bits on x86 SMP
In-Reply-To: <Pine.LNX.3.96.1000911210010.7937B-100000@kanga.kvack.org>
Message-ID: <Pine.LNX.4.21.0009112253490.1323-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: bcrl@redhat.com
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

On Mon, 11 Sep 2000 bcrl@redhat.com wrote:
> On Mon, 11 Sep 2000, Kanoj Sarcar wrote:
> 
> > One of the worst races is in the page stealing path, when the stealer
> > thread checks whether the page is dirty, decides to pte_clear(), and
> > right then, the user dirties the pte, before the stealer thread has done
> > the flush_tlb. Are you trying to handle this situation?
> 
> That's the one.  It also crops up in msync, munmap and such.

And (IMHO the worst one) in try_to_swap_out...

     55         if (pte_young(pte)) {
     56                 /*
     57                  * Transfer the "accessed" bit from the page
     58                  * tables to the global page map.
     59                  */
     60                 set_pte(page_table, pte_mkold(pte));

Imagine what would happen if the CPU would mark a page
dirty while we are here...

CPU#0:			CPU#1:
(kswapd)		(user process)

read pte
...
			replace TLB entry / write dirty bit
set_pte()


And we've lost the dirty bit ...

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
