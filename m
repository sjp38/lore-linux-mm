From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199911022124.NAA93231@google.engr.sgi.com>
Subject: Re: [PATCH] kanoj-mm21-2.3.23 alow larger sizes to shmget()
Date: Tue, 2 Nov 1999 13:24:54 -0800 (PST)
In-Reply-To: <qwwwvs1i5h1.fsf@sap.com> from "Christoph Rohland" at Nov 2, 99 10:54:18 am
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <hans-christoph.rohland@sap.com>
Cc: torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> Since glibc is encapsulating these calls and headers, we could perhaps
> work with compatibility version. E.g. making shmget and shmctl a real
> system call and converting the structures in sys_ipc to the old ones
> for old libraries?
> 
> BTW I did some work to make the clean up the shm coding and make the
> limites sysctleable. It also avoids vmalloc for the page tables. The
> latter is really important for big servers. We run out of vm-space on
> some benchmarks. I appended the patch against 2.3.24. I could not
> finally test this patch since shm swapping has apparently a race
> condition on segment deletion introduced with the smp version. I am
> still investigating on that. But perhaps we could incorporate this
> patch anyways. It did survive stress testing shm-swapping as long as I
> do not remove segments.
>

The clean up code is similar to what I posted at

	http://humbolt.geo.uu.nl/lists/linux-mm/1999-06/msg00071.html 

previously. Although, I would point out that SHMMAX probably belongs
to the asm/* header file (specially, with the size_t size parameter
to shmget()).

The sysctl idea is good, although you need to clean up the code, and
make 2 new nodes /proc/sys/kernel/* for ease of use.

The removal of struct shmid_kernel from shm.h to a private header
file, or to shm.c is a very good idea. This has no business being
user visible. Cleanups like this go a long way in creating a clean
ddi/dki ...

The removal of vmalloc() from the shm.c sounds good in principle,
although I haven't really reviewed your code in any detail ...

Thanks.

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
