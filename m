Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DC4966B01E5
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 10:01:00 -0400 (EDT)
Subject: Re: [PATCH RFC] mm: Implement balance_dirty_pages() through
 waiting for flusher thread
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100622135234.GA11561@localhost>
References: <1276797878-28893-1-git-send-email-jack@suse.cz>
	 <20100618060901.GA6590@dastard> <20100621233628.GL3828@quack.suse.cz>
	 <20100622054409.GP7869@dastard>
	 <20100621231416.904c50c7.akpm@linux-foundation.org>
	 <20100622100924.GQ7869@dastard> <20100622131745.GB3338@quack.suse.cz>
	 <20100622135234.GA11561@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 22 Jun 2010 16:00:54 +0200
Message-ID: <1277215254.1875.706.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hch@infradead.org
List-ID: <linux-mm.kvack.org>

On Tue, 2010-06-22 at 21:52 +0800, Wu Fengguang wrote:
> #include <stdio.h>=20
>=20
> typedef struct {
>         int counter;
> } atomic_t;
>=20
> static inline int atomic_dec_and_test(atomic_t *v)
> {     =20
>         unsigned char c;
>=20
>         asm volatile("lock; decl %0; sete %1"
>                      : "+m" (v->counter), "=3Dqm" (c)
>                      : : "memory");
>         return c !=3D 0;
> }
>=20
> int main(void)
> {=20
>         atomic_t i;
>=20
>         i.counter =3D 100000000;
>=20
>         for (; !atomic_dec_and_test(&i);)
>                 ;
>=20
>         return 0;
> }=20

This test utterly fails to stress the concurrency, you want to create
nr_cpus threads and then pound the global variable. Then compare it
against the per-cpu-counter variant.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
