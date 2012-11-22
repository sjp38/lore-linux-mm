Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id CC4276B004D
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 04:37:49 -0500 (EST)
References: <1353433362.85184.YahooMailNeo@web141101.mail.bf1.yahoo.com> <20121120182500.GH1408@quack.suse.cz> <20121121213417.GC24381@cmpxchg.org> <50AD7647.7050200@gmail.com> <20121122010959.GF24381@cmpxchg.org>
Message-ID: <1353577068.19982.YahooMailNeo@web141101.mail.bf1.yahoo.com>
Date: Thu, 22 Nov 2012 01:37:48 -0800 (PST)
From: metin d <metdos@yahoo.com>
Reply-To: metin d <metdos@yahoo.com>
Subject: Re: Problem in Page Cache Replacement
In-Reply-To: <20121122010959.GF24381@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Jaegeuk Hanse <jaegeuk.hanse@gmail.com>
Cc: Jan Kara <jack@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, =?utf-8?B?TWV0aW4gRMO2xZ9sw7w=?= <metindoslu@gmail.com>

Hi Johannes,=0A=0AYes, problem was as you projected. I tried to make "activ=
e" data-2 pages by manually reading them twice, and finally data-1 are got =
out of page cache.=0A=0AWe have large files in PostgreSQL and Hadoop that w=
e sequentially scan over; and try to fit our working set into total memory.=
 So I hope your patches will take place in the soonest linux kernel version=
.=0A=0AThanks,=0AMetin=0A=0A=0A----- Original Message -----=0AFrom: Johanne=
s Weiner <hannes@cmpxchg.org>=0ATo: Jaegeuk Hanse <jaegeuk.hanse@gmail.com>=
=0ACc: Jan Kara <jack@suse.cz>; metin d <metdos@yahoo.com>; "linux-kernel@v=
ger.kernel.org" <linux-kernel@vger.kernel.org>; linux-mm@kvack.org=0ASent: =
Thursday, November 22, 2012 3:09 AM=0ASubject: Re: Problem in Page Cache Re=
placement=0A=0AOn Thu, Nov 22, 2012 at 08:48:07AM +0800, Jaegeuk Hanse wrot=
e:=0A> On 11/22/2012 05:34 AM, Johannes Weiner wrote:=0A> >Hi,=0A> >=0A> >O=
n Tue, Nov 20, 2012 at 07:25:00PM +0100, Jan Kara wrote:=0A> >>On Tue 20-11=
-12 09:42:42, metin d wrote:=0A> >>>I have two PostgreSQL databases named d=
ata-1 and data-2 that sit on the=0A> >>>same machine. Both databases keep 4=
0 GB of data, and the total memory=0A> >>>available on the machine is 68GB.=
=0A> >>>=0A> >>>I started data-1 and data-2, and ran several queries to go =
over all their=0A> >>>data. Then, I shut down data-1 and kept issuing queri=
es against data-2.=0A> >>>For some reason, the OS still holds on to large p=
arts of data-1's pages=0A> >>>in its page cache, and reserves about 35 GB o=
f RAM to data-2's files. As=0A> >>>a result, my queries on data-2 keep hitt=
ing disk.=0A> >>>=0A> >>>I'm checking page cache usage with fincore. When I=
 run a table scan query=0A> >>>against data-2, I see that data-2's pages ge=
t evicted and put back into=0A> >>>the cache in a round-robin manner. Nothi=
ng happens to data-1's pages,=0A> >>>although they haven't been touched for=
 days.=0A> >>>=0A> >>>Does anybody know why data-1's pages aren't evicted f=
rom the page cache?=0A> >>>I'm open to all kind of suggestions you think it=
 might relate to problem.=0A> >This might be because we do not deactive pag=
es as long as there is=0A> >cache on the inactive list.=C2=A0 I'm guessing =
that the inter-reference=0A> >distance of data-2 is bigger than half of mem=
ory, so it's never=0A> >getting activated and data-1 is never challenged.=
=0A> =0A> Hi Johannes,=0A> =0A> What's the meaning of "inter-reference dist=
ance"=0A=0AIt's the number of memory accesses between two accesses to the s=
ame=0Apage:=0A=0A=C2=A0 A B C D A B C E ...=0A=C2=A0 =C2=A0 |_______|=0A=C2=
=A0 =C2=A0 |=C2=A0 =C2=A0 =C2=A0  |=0A=0A> and why compare it with half of =
memoy, what's the trick?=0A=0AIf B gets accessed twice, it gets activated.=
=C2=A0 If it gets evicted in=0Abetween, the second access will be a fresh p=
age fault and B will not=0Abe recognized as frequently used.=0A=0AOur cutof=
f for scanning the active list is cache size / 2 right now=0A(inactive_file=
_is_low), leaving 50% of memory to the inactive list.=0AIf the inter-refere=
nce distance for pages on the inactive list is=0Abigger than that, they get=
 evicted before their second access.=0A

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
