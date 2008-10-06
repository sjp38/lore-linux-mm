Subject: Re: [PATCH] x86_64: Implement personality ADDR_LIMIT_32BIT
From: Andi Kleen <andi@firstfloor.org>
References: <1223017469-5158-1-git-send-email-kirill@shutemov.name>
	<20081003080244.GC25408@elte.hu>
	<20081003092550.GA8669@localhost.localdomain>
Date: Mon, 06 Oct 2008 08:13:19 +0200
In-Reply-To: <20081003092550.GA8669@localhost.localdomain> (Kirill A. Shutemov's message of "Fri, 3 Oct 2008 12:25:52 +0300")
Message-ID: <87abdintds.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

"Kirill A. Shutemov" <kirill@shutemov.name> writes:
>
>> 
>> but more generally, we already have ADDR_LIMIT_3GB support on x86.
>
> Does ADDR_LIMIT_3GB really work?

As Arjan pointed out it only takes effect on exec()

andi@basil:~/tsrc> cat tstack2.c
#include <stdio.h>
int main(void)
{
        void *p = &p;
        printf("%p\n", &p);
        return 0;
}
andi@basil:~/tsrc> gcc -m32 tstack2.c  -o tstack2
andi@basil:~/tsrc> ./tstack2 
0xff807d70
andi@basil:~/tsrc> linux32 --3gb ./tstack2 
0xbfae2840

>> Why 
>> should support for ADDR_LIMIT_32BIT be added?
>
> It's useful for user mode qemu when you try emulate 32-bit target on 
> x86_64. For example, if shmat(2) return addres above 32-bit, target will
> get SIGSEGV on access to it.

The traditional way in mmap() to handle this is to give it a search
hint < 4GB and then free the memory again/fail if the result was >4GB.

Unfortunately that doesn't work for shmat() because the address argument
is not a search hint, but a fixed address. 

I presume you need this for the qemu syscall emulation. For a standard
application I would just recommend to use mmap with tmpfs instead
(sysv shm is kind of obsolete). For shmat() emulation the cleanest way
would be probably to add a new flag to shmat() that says that address
is a search hint, not a fixed address. Then implement it the way recommended
above.

-Andi

-- 
ak@linux.intel.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
