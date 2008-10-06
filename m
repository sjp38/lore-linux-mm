Date: Mon, 6 Oct 2008 10:42:46 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] x86_64: Implement personality ADDR_LIMIT_32BIT
Message-ID: <20081006084246.GC3180@one.firstfloor.org>
References: <1223017469-5158-1-git-send-email-kirill@shutemov.name> <20081003080244.GC25408@elte.hu> <20081003092550.GA8669@localhost.localdomain> <87abdintds.fsf@basil.nowhere.org> <20081006081717.GA20072@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081006081717.GA20072@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 06, 2008 at 11:17:23AM +0300, Kirill A. Shutemov wrote:
> On Mon, Oct 06, 2008 at 08:13:19AM +0200, Andi Kleen wrote:
> > "Kirill A. Shutemov" <kirill@shutemov.name> writes:
> > >
> > >> 
> > >> but more generally, we already have ADDR_LIMIT_3GB support on x86.
> > >
> > > Does ADDR_LIMIT_3GB really work?
> > 
> > As Arjan pointed out it only takes effect on exec()
> > 
> > andi@basil:~/tsrc> cat tstack2.c
> > #include <stdio.h>
> > int main(void)
> > {
> >         void *p = &p;
> >         printf("%p\n", &p);
> >         return 0;
> > }
> > andi@basil:~/tsrc> gcc -m32 tstack2.c  -o tstack2
> > andi@basil:~/tsrc> ./tstack2 
> > 0xff807d70
> > andi@basil:~/tsrc> linux32 --3gb ./tstack2 
> > 0xbfae2840
> 
> Which kernel do you use?

This was 2.6.26 (+ some irrelevant patches)

> Does it work only when compiled with -m32?

Yes. For 64bit processes you use the method described below for mmap.

> mmap() has MAP_32BIT flag on x86_64.

MAP_32BIT is just a short form for this, it's internally the same.
But it's actually MAP_31BIT. If you want the full 4GB you should not use it.

> 
> > Unfortunately that doesn't work for shmat() because the address argument
> > is not a search hint, but a fixed address. 
> > 
> > I presume you need this for the qemu syscall emulation. For a standard
> > application I would just recommend to use mmap with tmpfs instead
> > (sysv shm is kind of obsolete). For shmat() emulation the cleanest way
> > would be probably to add a new flag to shmat() that says that address
> > is a search hint, not a fixed address. Then implement it the way recommended
> > above.
> 
> I prefer one handle to switch application to 32-bit address mode. Why is it
> wrong?

"32 bit mode" really has to be set at exec time, otherwise it is not
(e.g. the stack will be beyond).

And personality() is not thread local/safe, so it's not a particularly
good interface to use later. Per system call switches are preferable
and more flexible.

-Andi
-- 
ak@linux.intel.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
