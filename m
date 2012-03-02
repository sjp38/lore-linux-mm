Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id C06C86B002C
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 16:25:35 -0500 (EST)
Message-ID: <1330723529.11248.237.camel@twins>
Subject: Re: [PATCH] cpuset: mm: Remove memory barrier damage from the page
 allocator
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Fri, 02 Mar 2012 22:25:29 +0100
In-Reply-To: <20120302174349.GB3481@suse.de>
References: <20120302112358.GA3481@suse.de>
	 <alpine.DEB.2.00.1203021018130.15125@router.home>
	 <20120302174349.GB3481@suse.de>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Miao Xie <miaox@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 2012-03-02 at 17:43 +0000, Mel Gorman wrote:
>=20
> I considered using a seqlock but it isn't cheap. The read side is heavy
> with the possibility that it starts spinning and incurs a read barrier
> (looking at read_seqbegin()) here. The retry block incurs another read
> barrier so basically it would not be no better than what is there current=
ly
> (which at a 4% performance hit, sucks)=20

Use seqcount.

Also, for the write side it doesn't really matter, changing mems_allowed
should be rare and is an 'expensive' operation anyway.

For the read side you can do:

again:
  seq =3D read_seqcount_begin(&current->mems_seq);

  page =3D do_your_allocator_muck();

  if (!page && read_seqcount_retry(&current->mems_seq, seq))
    goto again;

  oom();

That way, you only have one smp_rmb() in your fath path,
read_seqcount_begin() doesn't spin, and you only incur the second
smp_rmb() when you've completely failed to allocate anything.

smp_rmb() is basicaly free on x86, other archs will incur some overhead,
but you need a barrier as Christoph pointed out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
