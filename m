Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 496516B004F
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 13:16:29 -0500 (EST)
Message-ID: <4F0F2375.3060602@fb.com>
Date: Thu, 12 Jan 2012 10:16:21 -0800
From: Arun Sharma <asharma@fb.com>
MIME-Version: 1.0
Subject: Re: MAP_UNINITIALIZED (Was Re: MAP_NOZERO revisited)
References: <4F04F0B9.5040401@fb.com> <20120105162311.09dac4b7.kamezawa.hiroyu@jp.fujitsu.com> <20120111185009.GA26693@dev3310.snc6.facebook.com> <CAKTCnz=Fg8DiTYUzmTiVm_bd-P9Ww9N5+T+LRGjoG2=ONL_MGA@mail.gmail.com>
In-Reply-To: <CAKTCnz=Fg8DiTYUzmTiVm_bd-P9Ww9N5+T+LRGjoG2=ONL_MGA@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, Davide Libenzi <davidel@xmailserver.org>, Johannes Weiner <hannes@cmpxchg.org>

On 1/11/12 9:10 PM, Balbir Singh wrote:

>
> Define MAP_UNINITIALIZED - are you referring to not zeroing out pages
> before handing them down? Is this safe even between threads.
>

If it doesn't work for an app, it shouldn't be asking for this behavior 
via an mmap flag?

Only calloc() specifies that the returned memory will be zero'ed. There 
is no such guarantee for malloc().

>> +#define VM_UNINITIALIZED VM_SAO                /* Steal a powerpc bit for now, since we're out
>> +                                          bits for 32 bit archs */
>
> Without proper checks if it can be re-used?

Yeah - this is a complete hack. I'm trying to convince people that this 
is a viable idea, before asking for a vm_flags bit.

Microbenchmark data:

# time -p ./test2
real 7.60
user 0.78
sys 6.81

# time -p ./test2 xx
real 4.40
user 0.78
sys 3.62

# cat test2.c
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <stdint.h>

#define MMAP_SIZE (20 * 1024 * 1024)
#define PAGE_SIZE 4096
#define MAP_UNINITIALIZED 0x4000000

main(int argc, char *argv[])
{
         void *addr, *naddr;
         char *p, *end, val;
         int flag = 0;
         int i;

         if (argc > 1) {
                 flag = MAP_UNINITIALIZED;
         }

         addr = mmap(NULL, MMAP_SIZE, PROT_READ|PROT_WRITE,
                     flag | MAP_ANONYMOUS | MAP_PRIVATE, -1, 0);
         if (addr == MAP_FAILED) {
                 perror("mmap");
                 exit(-1);
         }
         end = (char *) addr + MMAP_SIZE;

         for (i = 0; i < 1000; i++) {
                 int ret;

                 ret = madvise(addr, MMAP_SIZE, MADV_DONTNEED);
                 if (ret == -1)
                         perror("madvise");

                 for (p = (char *) addr; p < end; p += PAGE_SIZE) {
                         *p = 0xAB;
                 }
         }
}


  -Arun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
