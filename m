Date: Tue, 11 Apr 2000 18:40:06 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: zap_page_range(): TLB flush race
In-Reply-To: <38F339A2.FB3F1699@colorfullife.com>
Message-ID: <Pine.LNX.4.21.0004111824090.19969-100000@maclaurin.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfreds@colorfullife.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "David S. Miller" <davem@redhat.com>, alan@lxorguk.ukuu.org.uk, kanoj@google.engr.sgi.com, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

On Tue, 11 Apr 2000, Manfred Spraul wrote:

>* They need the old pte value and the virtual address for their flush
>ipi.

Why can't they flush all the address space unconditionally on the other
cpus? I can't find a valid reason for which they do need the old pte
value. The tlb should be a virtual->physical mapping only, the pte isn't
relevant at all with the TLB. however if they really need both old pte
address and the virtual address of the page, they can trivially pass the
parameters to the other CPUs acquring a spinlock and using some global
variable exactly as IA32 does to avoid flushing the whole TLB on the other
CPUs in the flush_tlb_page case.

>Obviously their work-around
>	flush_tlb_page()
>	set_pte()
>is wrong as well, and it breaks all other architectures :-/

I bet it breaks s390 too.

The other filemap_sync race with threads that Kanoj was talking about is
very less severe since it can't make the machine unstable, but it can only
forgot to write some bit using strange userspace app design (only _data_
corruption can happen to the shared mmaping of the patological app).

Andrea


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
