Message-ID: <38F339A2.FB3F1699@colorfullife.com>
Date: Tue, 11 Apr 2000 16:41:38 +0200
From: Manfred Spraul <manfreds@colorfullife.com>
MIME-Version: 1.0
Subject: Re: zap_page_range(): TLB flush race
References: <200004082331.QAA78522@google.engr.sgi.com> <E12e4mo-0003Pn-00@the-village.bc.nu> <20000410232149.M17648@redhat.com> <200004102312.QAA05115@pizda.ninka.net> <20000411101418.E2740@redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "David S. Miller" <davem@redhat.com>, alan@lxorguk.ukuu.org.uk, kanoj@google.engr.sgi.com, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" wrote:
> 
> 
> OK, I'm sure there are optimisation issues, but I was worried about
> correctness problems from what Alan said.
> 

They are correctness problems:
[I'm only reading the asm source, I might be wrong]

* s390 has hardware support for tlb flush ipis.
* it doesn't support hardware contexts (address space numbers, region
id,...)
* They need the old pte value and the virtual address for their flush
ipi.

-->
	set_pte()
	flush_tlb_page()
doesn't work.

Obviously their work-around
	flush_tlb_page()
	set_pte()
is wrong as well, and it breaks all other architectures :-/

They need an atomic set_and_flush_pte() macro.
OTHO on i386 a tlb flush during set_pte() would cause a dramatic
slowdown.

--
	Manfred
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
