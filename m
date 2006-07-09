Date: Sun, 9 Jul 2006 14:01:38 +0200
From: Willy Tarreau <w@1wt.eu>
Subject: Re: Commenting out out_of_memory() function in __alloc_pages()
Message-ID: <20060709120138.GC2037@1wt.eu>
References: <1152446107.27368.45.camel@localhost.localdomain> <BKEKJNIHLJDCFGDBOHGMAEFDDCAA.abum@aftek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BKEKJNIHLJDCFGDBOHGMAEFDDCAA.abum@aftek.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Abu M. Muttalib" <abum@aftek.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Robert Hancock <hancockr@shaw.ca>, chase.venters@clientec.com, kernelnewbies@nl.linux.org, linux-newbie@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, Jul 09, 2006 at 05:18:06PM +0530, Abu M. Muttalib wrote:
> >It will refuse to load the program if that would use enough memory that
> >the system cannot be sure it will not run out of memory having done so.
> >You probably need a lot more swap.
> 
> thanks for ur reply..
> 
> but I am running the application on an embedded device and have no swap..
> 
> what do I need to do in this case??

Then try to increase the overcommit_ratio in /proc/sys/vm. Maybe the default
is not enough for your application. My web server has 32 MB and was regularly
crashing when too many apache processes were sollicitated, so I have set the
overcommit_memory to 2 and overcommit_ratio to 95 (huge but stable in this
particular workload). Now it works reasonably well.

Also, you should be aware of the side effects of overcommit. When you're
close to the limits, the system will refuse to fork processes, and various
applications might suddenly get NULL pointers in return from malloc(). And
I can tell you that this behaviour has become rare for so long a time that
rare are the programs which do not segfault when malloc() returns NULL !

If you develop all your programs, you should preallocate memory as much as
possible in order to ensure that once started, they will always work. Also
be careful about libc's function which allocate memory upon first call.
I've had problems with localtime() in the past.

> Regards,
> Abu.

Regards,
Willy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
