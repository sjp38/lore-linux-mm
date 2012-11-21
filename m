Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id B0BCF6B005D
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 17:01:30 -0500 (EST)
References: <1353433362.85184.YahooMailNeo@web141101.mail.bf1.yahoo.com> <20121120182500.GH1408@quack.suse.cz> <20121121213417.GC24381@cmpxchg.org>
Message-ID: <1353535288.94916.YahooMailNeo@web141101.mail.bf1.yahoo.com>
Date: Wed, 21 Nov 2012 14:01:28 -0800 (PST)
From: metin d <metdos@yahoo.com>
Reply-To: metin d <metdos@yahoo.com>
Subject: Re: Problem in Page Cache Replacement
In-Reply-To: <20121121213417.GC24381@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, =?utf-8?B?TWV0aW4gRMO2xZ9sw7w=?= <metindoslu@gmail.com>

Hi,=0A=0AYes data-2 is bigger than half of memory. I'm willing to try those=
 patches. =0A=0AThis is the version of this machine:=0A=0A$ uname -r=0A3.2.=
28-45.62.amzn1.x86_64=0A=0A=0A=0A----- Original Message -----=0AFrom: Johan=
nes Weiner <hannes@cmpxchg.org>=0ATo: Jan Kara <jack@suse.cz>=0ACc: metin d=
 <metdos@yahoo.com>; "linux-kernel@vger.kernel.org" <linux-kernel@vger.kern=
el.org>; linux-mm@kvack.org=0ASent: Wednesday, November 21, 2012 11:34 PM=
=0ASubject: Re: Problem in Page Cache Replacement=0A=0AHi,=0A=0AOn Tue, Nov=
 20, 2012 at 07:25:00PM +0100, Jan Kara wrote:=0A> On Tue 20-11-12 09:42:42=
, metin d wrote:=0A> > I have two PostgreSQL databases named data-1 and dat=
a-2 that sit on the=0A> > same machine. Both databases keep 40 GB of data, =
and the total memory=0A> > available on the machine is 68GB.=0A> > =0A> > I=
 started data-1 and data-2, and ran several queries to go over all their=0A=
> > data. Then, I shut down data-1 and kept issuing queries against data-2.=
=0A> > For some reason, the OS still holds on to large parts of data-1's pa=
ges=0A> > in its page cache, and reserves about 35 GB of RAM to data-2's fi=
les. As=0A> > a result, my queries on data-2 keep hitting disk.=0A> > =0A> =
> I'm checking page cache usage with fincore. When I run a table scan query=
=0A> > against data-2, I see that data-2's pages get evicted and put back i=
nto=0A> > the cache in a round-robin manner. Nothing happens to data-1's pa=
ges,=0A> > although they haven't been touched for days.=0A> > =0A> > Does a=
nybody know why data-1's pages aren't evicted from the page cache?=0A> > I'=
m open to all kind of suggestions you think it might relate to problem.=0A=
=0AThis might be because we do not deactive pages as long as there is=0Acac=
he on the inactive list.=C2=A0 I'm guessing that the inter-reference=0Adist=
ance of data-2 is bigger than half of memory, so it's never=0Agetting activ=
ated and data-1 is never challenged.=0A=0AI have a series of patches that d=
etects a thrashing inactive list and=0Ahandles working set changes up to th=
e size of memory.=C2=A0 Would you be=0Awilling to test them?=C2=A0 They are=
 currently based on 3.4, let me know=0Awhat version works best for you.=0A

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
