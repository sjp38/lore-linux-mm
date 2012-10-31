Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 6EB8B6B006C
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 05:57:49 -0400 (EDT)
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 08502-03 for <linux-mm@kvack.org>; Wed, 31 Oct 2012 09:57:46 +0000 (GMT)
Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="ISO-8859-15"
Content-Transfer-Encoding: quoted-printable
Subject: RE: [PATCH v8 01/16] hashtable: introduce a small and naive hashtable
Date: Wed, 31 Oct 2012 09:46:20 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7080@saturn3.aculab.com>
In-Reply-To: <1351646186.4004.41.camel@gandalf.local.home>
References: <1351622772-16400-1-git-send-email-levinsasha928@gmail.com> <20121030214257.GB2681@htj.dyndns.org> <CA+1xoqeCKS2E4TWCUCELjDqV2pWS4v6EyV6K-=w-GRi_K6quiQ@mail.gmail.com> <1351646186.4004.41.camel@gandalf.local.home>
From: "David Laight" <David.Laight@ACULAB.COM>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>, Sasha Levin <levinsasha928@gmail.com>
Cc: Tejun Heo <tj@kernel.org>, torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

> > > On Tue, Oct 30, 2012 at 02:45:57PM -0400, Sasha Levin wrote:
> > >> +/* Use hash_32 when possible to allow for fast 32bit hashing in =
64bit kernels. */
> > >> +#define hash_min(val, bits)                                      =
            \
> > >> +({                                                               =
            \
> > >> +     sizeof(val) <=3D 4 ?                                        =
              \
> > >> +     hash_32(val, bits) :                                        =
            \
> > >> +     hash_long(val, bits);                                       =
            \
> > >> +})
> > >
> > > Doesn't the above fit in 80 column.  Why is it broken into =
multiple
> > > lines?  Also, you probably want () around at least @val.  In =
general,
> > > it's a good idea to add () around any macro argument to avoid =
nasty
> > > surprises.
> >
> > It was broken to multiple lines because it looks nicer that way =
(IMO).
> >
> > If we wrap it with () it's going to go over 80, so it's going to =
stay
> > broken down either way :)
>=20
> ({								      \
> 	sizeof(val) <=3D 4 ? hash_32(val, bits) : hash_long(val, bits); \
> })
>=20
> Is the better way to go. We are C programmers, we like to see the ?: =
on
> a single line if possible. The way you have it, looks like three
> statements run consecutively.

To add some more colour (not color):

In any case, this is a normal C #define, it doesn't need the {}.
So it can just be:
# define hash_min(val, bits) \
	(sizeof(val) <=3D 4 ? hash_32(val, bits) : hash_long(val, bits))

I don't think that s/val/(val)/g and s/bits/(bits)/g are needed
because the tokens are already ',' separated.

I do actually wonder how many of these hash lists should be replaced
with some kind of tree structure in order to get O(log(n)) searches.
After all hashing is still O(n).
(apologies if I mean o(n) not O(n) - it's a long time since I did
my maths degree!)

	David



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
