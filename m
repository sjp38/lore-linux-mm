Date: Tue, 9 Apr 2002 10:08:38 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Fwd: Re: How CPU(x86) resolve kernel address
Message-ID: <20020409100838.C2807@redhat.com>
References: <20020407025738.90777.qmail@web12307.mail.yahoo.com> <Pine.GSO.4.10.10204091052060.13298-100000@mailhub.cdac.ernet.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.10.10204091052060.13298-100000@mailhub.cdac.ernet.in>; from sanket.rathi@cdac.ernet.in on Tue, Apr 09, 2002 at 10:59:12AM +0530
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Sanket Rathi <sanket.rathi@cdac.ernet.in>
Cc: Ravi <kravi26@yahoo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Apr 09, 2002 at 10:59:12AM +0530, Sanket Rathi wrote:

> but i tried. i allocate memory buffers in application and pass their
> address to driver. there i use the following 
> 
>  if (pgd_none(*(pgd = pgd_offset(current->mm,virtAddress))) ||
> 
>                 pmd_none(*(pmd = pmd_offset(pgd, virtAddress))) ||
> 
>                 pte_none(*(pte = pte_offset(pmd, virtAddress))) )
>                 {
>                         printk("\nphysical address failed\n") ;
>                         return (-1) ;
>                 }
>                 phyAddress = pte_page(*pte) ;
>                 printk("\nphysical address is %x",(unsigned
> long)phyAddress) ;

You cannot do that.  The physical memory used by the application can
get swapped out, and if you malloc() a page, all you get initially is
a copy-on-write instance of the zero page.  You *must* use something
like map_user_kiobuf() or the ptrace address-poking code to access the
user buffer safely.  Even safer is to allocate the buffer inside your
driver instead and then mmap that into user space.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
