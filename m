Date: Wed, 11 Oct 2000 18:12:44 +0100
From: Stephen Tweedie <sct@redhat.com>
Subject: Re: map_user_kiobuf and 1 Gb (2.4-test8)
Message-ID: <20001011181244.E1353@redhat.com>
References: <39DCEAE9.BDEA23BD@edt.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <39DCEAE9.BDEA23BD@edt.com>; from steve@edt.com on Thu, Oct 05, 2000 at 01:56:09PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steve Case <steve@edt.com>
Cc: linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Oct 05, 2000 at 01:56:09PM -0700, Steve Case wrote:
> I'm working on a device driver module for our PCI interface cards which
> attempts to map user memory for DMA. I was pleased to find the
> map_user_kiobuf function and its allies, since this appears to do
> exactly what I need. Everything worked fine, until I sent it to a
> customer who has a system w/  1 Gb of memory - it locked up real good as
> soon as he tried DMA

>       sg.addr = virt_to_bus(page_address(iobuf.maplist[entrys]));

>From include/asm-i386/pgtable.h:

  /*
   * Permanent address of a page. Obviously must never be
   * called on a highmem page.
   */
  #define page_address(page) ((page)->virtual)

The 2.4 kernel is able to deal with >=1GB physical memory in its VM,
but the IO subsystem on i386 architectures is still not ready for such
memory.  What happens today is that network IO is restricted to low
memory (roughly speaking, below the 900MB mark) by simply ensuring
that skbuff packet buffers are always allocated from low memory in the
first place, and that disk IO is restricted to low memory by doing
"bounce buffer" operations --- if you attempt disk IO to a high memory
page, the kernel will allocate a temporary low-memory page for the IO
and will copy the IO results to/from high memory as required.

The easiest way to deal with this for now will be to special-case high
memory pages with "if (PageHighMem(page)) {}" in a similar manner.
You'll probably see much better support for IO to high mem pages in
2.5, but in 2.4 doing a copy is the safest way to go.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
