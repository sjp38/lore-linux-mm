From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200002291830.KAA65568@google.engr.sgi.com>
Subject: Re: [RFC] [RFT] Shared /dev/zero mmaping feature
Date: Tue, 29 Feb 2000 10:30:12 -0800 (PST)
In-Reply-To: <qwwem9wnus3.fsf@sap.com> from "Christoph Rohland" at Feb 29, 2000 11:54:36 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <hans-christoph.rohland@sap.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, torvalds@transmeta.com, Kanoj Sarcar <kanoj@google.engr.sgi.com>
List-ID: <linux-mm.kvack.org>

> Why do you use this special zero_id stuff? It clutters up the whole
> code.

The zero_id stuff is required to differentiate between the struct 
shmid_kernel of a "real" shared memory segment and one that
represents a /dev/zero mapping. This is used in shm_swap_core(),
for accounting purposes, but that can be changed by adding a 
new flag to shm_swap_core. The more important use is in
shm_nopage().

> 
> If you would simply open a normal shm segment with key IPC_PRIVATE and
> directly remove it nobody can attach to it and it will be released on
> exit and everything. No special handling needed any more. BTW that's
> exectly what we do in user space to circumvent the missing MAP_ANON |
> MAP_SHARED.

Would this need to be done for each /dev/zero mapping? If so, then 
I prefer the way the code is right now, since the interference with
"real" shared memory is minimal. I was also trying to look for a way 
to prevent the zshmid_kernel hacks in shmat/shmctl (including setting
strict permissions), but couldn't come up with one ... Tell me in more
detail what you are suggesting here.

> 
> I would also prefer to be able to see the allocated segments with the
> ipc* commands.
>
I do not believe there is any good reason to expose the special shared
memory segment used as a place holder for all /dev/zero mappings to users
via ipc* commands. This special segment exists only because we 
want to reduce kernel code duplication, and all the zshmid_kernel/
zero_id checks just make sure that regular shared memory works
pretty much the way it did before. (One thing I am unhappy about
is that this special segment eats up a shm id, but that's probably
not too bad). 
 
Thanks.

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
