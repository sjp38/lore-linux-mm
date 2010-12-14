Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 24AA86B008A
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 04:10:40 -0500 (EST)
Subject: Re: kernel BUG at mm/truncate.c:475!
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <alpine.LSU.2.00.1012132246580.6071@sister.anvils>
References: <20101130194945.58962c44@xenia.leun.net>
	 <alpine.LSU.2.00.1011301453090.12516@tigran.mtv.corp.google.com>
	 <E1PNjsI-0005Bk-NB@pomaz-ex.szeredi.hu>
	 <20101201124528.6809c539@xenia.leun.net>
	 <E1PNqO1-0005px-9h@pomaz-ex.szeredi.hu>
	 <20101202084159.6bff7355@xenia.leun.net>
	 <20101202091552.4a63f717@xenia.leun.net>
	 <E1PO5gh-00079U-Ma@pomaz-ex.szeredi.hu>
	 <20101202115722.1c00afd5@xenia.leun.net>
	 <20101203085350.55f94057@xenia.leun.net>
	 <E1PPaIw-0004pW-Mk@pomaz-ex.szeredi.hu>
	 <20101206204303.1de6277b@xenia.leun.net>
	 <E1PRQDn-0007jZ-5S@pomaz-ex.szeredi.hu>
	 <20101213142059.643f8080.akpm@linux-foundation.org>
	 <alpine.LSU.2.00.1012132246580.6071@sister.anvils>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 14 Dec 2010 10:10:07 +0100
Message-ID: <1292317807.6803.1324.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Miklos Szeredi <miklos@szeredi.hu>, Michael Leun <lkml20101129@newton.leun.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2010-12-13 at 23:31 -0800, Hugh Dickins wrote:
> > then I suspect all the vm_truncate_count/restart_addr stuff can go away=
?
>=20
> That would be lovely, but in fact no: it's guarding against operations on
> vmas, things like munmap and mprotect, which can shuffle the prio_tree
> when i_mmap_lock is dropped, without i_mutex ever being taken.
>=20
> However, if we adopt Peter's preemptible mmu_gather patches, i_mmap_lock
> becomes a mutex, so there's then no need for any of this (I think Peter
> just did a straight conversion here, leaving it in, but it becomes
> pointless and would gladly be removed).=20

I'm still trying to sell that series, so if you see any value in it,
please reply with positive feedback ;-)

Also, the whole vm_truncate_count/restart_addr isn't entirely useless,
its still a lock break which might help with long held locks. Imagine
someone trying to unmap several TB worth of pages at once (not entirely
beyond the realm of possibility today, and we all know tomorrow will be
huge).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
