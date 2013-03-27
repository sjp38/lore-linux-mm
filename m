Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 0702F6B0005
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 17:20:39 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <2912c0c3-e95f-4b2b-8aeb-2a2ba2df54dd@default>
Date: Wed, 27 Mar 2013 14:20:11 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [RFC] mm: remove swapcache page early
References: <<1364350932-12853-1-git-send-email-minchan@kernel.org>>
In-Reply-To: <<1364350932-12853-1-git-send-email-minchan@kernel.org>>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Shaohua Li <shli@kernel.org>

> From: Minchan Kim [mailto:minchan@kernel.org]
> Subject: [RFC] mm: remove swapcache page early
>=20
> Swap subsystem does lazy swap slot free with expecting the page
> would be swapped out again so we can't avoid unnecessary write.
>=20
> But the problem in in-memory swap is that it consumes memory space
> until vm_swap_full(ie, used half of all of swap device) condition
> meet. It could be bad if we use multiple swap device, small in-memory swa=
p
> and big storage swap or in-memory swap alone.
>=20
> This patch changes vm_swap_full logic slightly so it could free
> swap slot early if the backed device is really fast.
> For it, I used SWP_SOLIDSTATE but It might be controversial.
> So let's add Ccing Shaohua and Hugh.
> If it's a problem for SSD, I'd like to create new type SWP_INMEMORY
> or something for z* family.
>=20
> Other problem is zram is block device so that it can set SWP_INMEMORY
> or SWP_SOLIDSTATE easily(ie, actually, zram is already done) but
> I have no idea to use it for frontswap.
>=20
> Any idea?
>=20
> Other optimize point is we remove it unconditionally when we
> found it's exclusive when swap in happen.
> It could help frontswap family, too.

By passing a struct page * to vm_swap_full() you can then call
frontswap_test()... if it returns true, then vm_swap_full
can return true.  Note that this precisely checks whether
the page is in zcache/zswap or not, so Seth's concern that
some pages may be in-memory and some may be in rotating
storage is no longer an issue.

> What do you think about it?

By removing the page from swapcache, you are now increasing
the risk that pages will "thrash" between uncompressed state
(in swapcache) and compressed state (in z*).  I think this is
a better tradeoff though than keeping a copy of both the
compressed page AND the uncompressed page in memory.

You should probably rename vm_swap_full() because you are
now overloading it with other meanings.  Maybe
vm_swap_reclaimable()?

Do you have any measurements?  I think you are correct
that it may help a LOT.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
