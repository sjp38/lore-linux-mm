Subject: Re: [RFC] mapping parts of shared memory
References: <199911251914.LAA27659@google.engr.sgi.com>
From: Christoph Rohland <hans-christoph.rohland@sap.com>
Date: 26 Nov 1999 16:33:17 +0100
In-Reply-To: kanoj@google.engr.sgi.com's message of "Thu, 25 Nov 1999 11:14:31 -0800 (PST)"
Message-ID: <qww7lj5s1xe.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: linux-mm@kvack.org, dledford@redhat.com, ebiederm+eric@ccr.net
List-ID: <linux-mm.kvack.org>

kanoj@google.engr.sgi.com (Kanoj Sarcar) writes:

> > 
> > Hi,
> > 
> > I was investigating for some time about the possibility to create some
> > object which allows me to map and unmap parts of it it in different
> > processes. This would help to take advantage of the high memory
> > systems with applications like SAP R/3 which uses a small number of
> > processes to server many clients. It is now limited by the available
> > address space for one process.
> >
> 
> Lets see if I am understanding the problem right. Currently, you may
> have an ia32 box with 8G memory, unfortunately, your server can make
> use of at most (say) 3G worth of shared memory. Hence, you are worried
> about how to be able to use the other 5G, lets say with more server 
> processes.

Yes that's right.

> What prevents your app from creating say 2 shm segments, each around
> 2.5G or so? That will let you attach in and use about 5G between 2
> server processes. What have you lost with this approach that you will
> get with the kernel approach?

I explain a little bit the different approaches of SAP R/3 with
respect to user context memory:

1) All user requests are handled in a relatively small number of
   processes.
2) One user transaction can consist of more than one request and
   subsequent requests from one transaction do not need to be
   processed by the same workprocess.
3) So the workprocesses need a way to share the user contexts. To
   acomplish this we have three different implementations:
   a) The classic Unix model: We map one really big area with
      mmap(ANON|SHARED) and use mprotect to 'attach' the actual user
      context. So all user data has to fit into the address space
      together (and we have easily more than 100 users on one server)
      This works fine on 64 bit architectures, but is very restricted
      on 32 bit.
   b) The shm segments model (only used on AIX so far): We use big shm
      segments which cannot be shared between different user
      contexts. They have to be big because this implementation cannot
      merge multiple segments together. So the biggest single
      allocation is limited by the segment size. This implementation
      works basically under Linux but has two drawbacks:
      1) For good performance we need a disclaim system call, which is
         not available on Linux. Imagine the following (really usual)
         situation: Every user first allocates on small variable and a
         big chunk of memory for some internal table. Then this
         internal table is freed but the transaction still persists
         (which is normal for readonly transactions) So we do not have
         a chance to free this memory against the OS since we only can
         free the complete segment and there is still a small item in
         this segment.
      2) We do not want to support this model any longer since AIX is
         now 64 bit and can use model a. Also many administrators know
         the mapping model c. So it would be more training effort if
         we would focus on this implementation.
   c) The mapping model (the standard model NT and implemented for
      Unix using shm_open) works by reserving some unnamed file and
      mmaping the user context from this file descriptor. This can
      also handle more than one file. To be able to do this we need
      something like posix shm which gives you a fd with shm_open,
      which we then can use to mmmap parts of it into the
      process. This model does work with small blocks (normally 1MB)
      and can concatenate arbitrary blocks on the file to one
      contiguous memory area. So we are able to reuse freed memory
      from one context in another one and the problems described in b
      are not as bad as there. But probably disclaim does help here
      also.

I would like be able to use c) under Linux.

Greetings
                Christoph
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
