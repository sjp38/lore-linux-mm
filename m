Reply-To: <frey@cxau.zko.dec.com>
From: "Martin Frey" <frey@scs.ch>
Subject: Questions on mmap()
Date: Tue, 23 Jan 2001 14:45:12 -0500
Message-ID: <000201c08575$01127ab0$10401c10@SCHLEPPDOWN>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: baettig@scs.ch
List-ID: <linux-mm.kvack.org>

Dear all,

I'm trying to write an example on how to export kmalloc()
and vmalloc() allocated areas from a device driver into
user space. The example is running so far, but I want to
make sure to have all the details right.

So here I have couple of questions:
- for kmalloc, I just call remap_page_range() in my drivers
  mmap method. Do I have to grab any locks before doing
  so (kernel 2.4.x), e.g. big kernel lock?
- Do I have to set any flags in vm_area_struct->vm_flags?
  I see some drivers setting VM_LOCKED while others don't.
  As far as I understand the kernel will try to swap the
  area out starting in swp_out_mm, calling swp_out_vma.
  If VM_LOCKED I will return if VM_LOCKED is set. If not,
  I will fall into swap_out_pXX until I finally hit
  the reserve bit of the page that should go out.
  If I understand the code right, setting VM_LOCKED is
  not necessary, I will be safe without. But performancewise
  have VM_LOCKED set will make me fall out of the swap-out
  attempt earlier. Is this correct?
- To map a vmalloc() allocated area, I set up my own
  page fault handler (vm_ops). Again, are any flags
  needed in the vm_flags field?
- In my pagefault handler I parse the pagetables as e.g.
  done in uvirt_to_kva in the bttv-driver. Do I need
  to grab a lock before doing so? 
- What is the purpose and usage of the VMALLOC_VMADDR
  macro?

Any help is appreciated.

Thanks and best regards,

Martin Frey

-- 
Supercomputing Systems AG       email: frey@scs.ch
Martin Frey                     web:   http://www.scs.ch/~frey/
at Compaq Computer Corporation  phone: +1 603 884 4266
ZKO2-3N25, 110 Spit Brook Road, Nashua, NH 03062

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
