Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7D0696B0279
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 01:05:27 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id s64so40462015pfa.1
        for <linux-mm@kvack.org>; Tue, 18 Jul 2017 22:05:27 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id r27si3351999pfl.0.2017.07.18.22.05.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jul 2017 22:05:26 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id d193so5449101pgc.2
        for <linux-mm@kvack.org>; Tue, 18 Jul 2017 22:05:26 -0700 (PDT)
From: Nadav Amit <nadav.amit@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: TLB batching breaks MADV_DONTNEED
Message-Id: <B672524C-1D52-4215-89CB-9FF3477600C9@gmail.com>
Date: Tue, 18 Jul 2017 22:05:23 -0700
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>
Cc: Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@kernel.org>

Something seems to be really wrong with all these TLB flush batching
mechanisms that are all around kernel. Here is another example, which =
was
not addressed by the recently submitted patches.

Consider what happens when two MADV_DONTNEED run concurrently. According =
to
the man page "After a successful MADV_DONTNEED operation =E2=80=A6 =
subsequent
accesses of pages in the range will succeed, but will result in =E2=80=A6
zero-fill-on-demand pages for anonymous private mappings.=E2=80=9D

However, the test below, which does MADV_DONTNEED in two threads, reads =
=E2=80=9C8=E2=80=9D
and not =E2=80=9C0=E2=80=9D when reading the memory following =
MADV_DONTNEED. It happens
since one of the threads clears the PTE, but defers the TLB flush for =
some
time (until it finishes changing 16k PTEs). The main thread sees the PTE
already non-present and does not flush the TLB.

I think there is a need for a batching scheme that considers whether
mmap_sem is taken for write/read/nothing and the change to the PTE.
Unfortunately, I do not have the time to do it right now.

Am I missing something? Thoughts?


---


#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <pthread.h>
#include <string.h>

#define PAGE_SIZE	(4096)
#define N_PAGES		(65536)

volatile int sync_step =3D 0;
volatile char *p;

static inline unsigned long rdtsc()
{
	unsigned long hi, lo;
	__asm__ __volatile__ ("rdtsc" : "=3Da"(lo), "=3Dd"(hi));
	 return lo | (hi << 32);
}

static inline void wait_rdtsc(unsigned long cycles)
{
	unsigned long tsc =3D rdtsc();

	while (rdtsc() - tsc < cycles);
}

void *big_madvise_thread(void *ign)
{
	sync_step =3D 1;
	while (sync_step !=3D 2);
	madvise((void*)p, PAGE_SIZE * N_PAGES, MADV_DONTNEED);
}

void main(void)
{
	pthread_t aux_thread;

	p =3D mmap(0, PAGE_SIZE * N_PAGES, PROT_READ|PROT_WRITE,
		 MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);

	memset((void*)p, 8, PAGE_SIZE * N_PAGES);

	pthread_create(&aux_thread, NULL, big_madvise_thread, NULL);
	while (sync_step !=3D 1);

	*p =3D 8;		// Cache in TLB
	sync_step =3D 2;
	wait_rdtsc(100000);
	madvise((void*)p, PAGE_SIZE, MADV_DONTNEED);
	printf("Result : %d\n", *p);
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
