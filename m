From: Andi Kleen <ak@suse.de>
Subject: Re: Kernel tempory memory alloc
Date: Sun, 20 Nov 2005 00:54:35 +0100
References: <437F1E7F.40504@superbug.demon.co.uk> <1e62d1370511191057i5ab0b4b3ve3c8a2a3dcabe6fe@mail.gmail.com>
In-Reply-To: <1e62d1370511191057i5ab0b4b3ve3c8a2a3dcabe6fe@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200511200054.35906.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Fawad Lateef <fawadlateef@gmail.com>
Cc: James Courtier-Dutton <James@superbug.demon.co.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Saturday 19 November 2005 19:57, Fawad Lateef wrote:
> On 11/19/05, James Courtier-Dutton <James@superbug.demon.co.uk> wrote:
> > The IOCTL will be a simple request/response type, so the memory
> > allocation will be for a very short time. Which is the correct memory
> > api to use when allocating short term temporary memory in the kernel.
>
> I mostly/vastly used and saw memory allocation API "kmalloc" for small
> memory allocations. And for short-term and fast memory allocation use
> GFP_ATOMIC flag with memory allocation functions!

No, that's not what GFP_ATOMIC is good for. Please don't spread misinformation 
like that which google will keep forever. GFP_ATOMIC is for allocating
for interrupt context or other contexts where you cannot sleep,
and is much less reliable than normal GFP_KERNEL.

> > Alternatively, is there a way to handle this by simply moving a page
> > from user space to kernel space and then back to user space again?
> > Thus reducing the amount of memcpy.
>
> I think memcpy is not a big-overhead as compare to temporary mapping a
> page from user space to kernel space and then unmapping it each time
> an ioctl is called, so you might try to constantly share a buffer
> between user/kernel space through which you can access data directly
> from both spaces (for mapping user page in kernel you can see
> get_user_pages) !

I don't think that's good advice. It depends on the exact circumstances
and the size of the data, but for reasonably sized data (> one page)
normally the copy should be more expensive.

Also there is no memcpy from user space of course.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
