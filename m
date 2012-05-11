Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 696518D0001
	for <linux-mm@kvack.org>; Fri, 11 May 2012 10:42:40 -0400 (EDT)
Message-ID: <1336747350.1017.22.camel@twins>
Subject: Re: [PATCH 10/17] netvm: Allow skb allocation to use PFMEMALLOC
 reserves
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Fri, 11 May 2012 16:42:30 +0200
In-Reply-To: <20120511143218.GS11435@suse.de>
References: <1336657510-24378-1-git-send-email-mgorman@suse.de>
	 <1336657510-24378-11-git-send-email-mgorman@suse.de>
	 <20120511.005740.210437168371869566.davem@davemloft.net>
	 <20120511143218.GS11435@suse.de>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org, linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, neilb@suse.de, michaelc@cs.wisc.edu, emunson@mgebm.net

On Fri, 2012-05-11 at 15:32 +0100, Mel Gorman wrote:
> > > +extern atomic_t memalloc_socks;
> > > +static inline int sk_memalloc_socks(void)
> > > +{
> > > +   return atomic_read(&memalloc_socks);
> > > +}
> >=20
> > Please change this to be a static branch.
> >=20
>=20
> Will do. I renamed memalloc_socks to sk_memalloc_socks, made it a int as
> atomics are unnecessary and I check it directly in a branch instead of a
> static inline. It should be relatively easy for the branch predictor.=20

David means you to use include/linux/jump_label.h.

static struct static_key sk_memalloc_socks =3D STATIC_KEY_INIT_FALSE;

and have your function read:

static inline bool sk_memalloc_socks(void)
{
	return static_key_false(&sk_memalloc_socks);
}

which can be modified using:

  static_key_slow_inc(&sk_memalloc_socks);

or

  static_key_slow_dec(&sk_memalloc_socks);

This magic goo turns the branch into self-modifying code such that the
branch is an unconditional jump at runtime.

 =20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
