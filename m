From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199908162328.QAA24338@google.engr.sgi.com>
Subject: Re: [bigmem-patch] 4GB with Linux on IA32
Date: Mon, 16 Aug 1999 16:28:58 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.10.9908162235570.4139-100000@laser.random> from "Andrea Arcangeli" at Aug 16, 99 10:54:45 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: alan@lxorguk.ukuu.org.uk, torvalds@transmeta.com, sct@redhat.com, Gerhard.Wichert@pdb.siemens.de, Winfried.Gerhard@pdb.siemens.de, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> On Mon, 16 Aug 1999, Alan Cox wrote:
> 
> >> a range of user pages that were in bigmem area? Also, debuggers
> >> want to look at user memory, so they would also need to map the
> >> pages. Are there any other cases where a driver might want to 
> >
> >That is the tricky one. What occurs if I mmap a high memory page of
> >another process via /proc/pid/mem ? then write it
> 
> IMO Kanoj was talking about another thing (ptrace).
>

Andrea, 

I was also talking about drivers which assume that all of memory is
direct mapped. For example, __va and __pa assume this. There might be 
other macros/procedures which have the same assumption built in. 
Basically, anything that is dependent on PAGE_OFFSET needs to be
checked. 

For example, on a 2.2.10 kernel:
[kanoj@entity kern]$ gid __va | grep drivers
drivers/char/mem.c:124: if (copy_to_user(buf, __va(p), count))
drivers/char/mem.c:142: return do_write_mem(file, __va(p), p, buf, count, ppos);
drivers/scsi/sym53c8xx.c:572:#define remap_pci_mem(base, size)  ((u_long) __va(base))
drivers/video/creatorfb.c:684:  disp->screen_base = (char *)__va(regs[0].phys_addr) + FFB_DFB24_POFF + 8192 * fb->y_margin + 4 * fb->x_margin;
drivers/video/creatorfb.c:687:  fb->s.ffb.fbc = (struct ffb_fbc *)((char *)__va(regs[0].phys_addr) + FFB_FBC_REGS_POFF);
drivers/video/creatorfb.c:688:  fb->s.ffb.dac = (struct ffb_dac *)((char *)__va(regs[0].phys_addr) + FFB_DAC_POFF);
drivers/sbus/char/zs.c:1934:                                            __va((((unsigned long)zsregs[0].which_io)<<32) |

For all such macros, a decision needs to be made whether such usage 
will create problems if the underlying page happens to be a bigmem page.
If so, the proper mapping (and unmapping) calls need to be made around
the kernel code that accesses the page contents.

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
