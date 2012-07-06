Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 6DA136B0073
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 10:34:04 -0400 (EDT)
Date: Fri, 6 Jul 2012 09:34:01 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/3] slub: release a lock if freeing object with a lock
 is failed in __slab_free()
In-Reply-To: <CAAmzW4NJyX9e_dMyJBA5zDiVYVmL1vbUkaRHNoSbbhDZWW7iMg@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1207060928580.26790@router.home>
References: <1340389359-2407-1-git-send-email-js1304@gmail.com> <1340389359-2407-3-git-send-email-js1304@gmail.com> <alpine.DEB.2.00.1207050924330.4138@router.home> <CAAmzW4NJyX9e_dMyJBA5zDiVYVmL1vbUkaRHNoSbbhDZWW7iMg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 6 Jul 2012, JoonSoo Kim wrote:

> For example,
> When we try to free object A at cpu 1, another process try to free
> object B at cpu 2 at the same time.
> object A, B is in same slab, and this slab is in full list.
>
> CPU 1                           CPU 2
> prior = page->freelist;    prior = page->freelist
> ....                                  ...
> new.inuse--;                   new.inuse--;
> taking lock                      try to take the lock, but failed, so
> spinning...
> free success                   spinning...
> add_partial
> release lock                    taking lock
>                                        fail cmpxchg_double_slab
>                                        retry
>                                        currently, we don't need lock
>
> At CPU2, we don't need lock anymore, because this slab already in partial list.

For that scenario we could also simply do a trylock there and redo
the loop if we fail. But still what guarantees that another process will
not modify the page struct between fetching the data and a successful
trylock?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
