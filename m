Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 1E0146B006C
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 03:13:52 -0500 (EST)
References: <1353433362.85184.YahooMailNeo@web141101.mail.bf1.yahoo.com> <20121120182500.GH1408@quack.suse.cz> <1353485020.53500.YahooMailNeo@web141104.mail.bf1.yahoo.com>
Message-ID: <1353485630.17455.YahooMailNeo@web141106.mail.bf1.yahoo.com>
Date: Wed, 21 Nov 2012 00:13:50 -0800 (PST)
From: metin d <metdos@yahoo.com>
Reply-To: metin d <metdos@yahoo.com>
Subject: Re: Problem in Page Cache Replacement
In-Reply-To: <1353485020.53500.YahooMailNeo@web141104.mail.bf1.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

>=A0 Curious. Added linux-mm list to CC to catch more attention. If you run=
=0A> echo 1 >/proc/sys/vm/drop_caches does it evict data-1 pages from memor=
y?=0A=0AI'm guessing it'd evict the entries, but am wondering if we could r=
un any more diagnostics before trying this.=0A=0AWe regularly use a setup w=
here we have two databases; one gets used frequently and the other one abou=
t once a month. It seems like the memory manager keeps unused pages in memo=
ry at the expense of frequently used database's performance.=0A=0AMy unders=
tanding was that under memory pressure from heavily accessed pages, unused =
pages would eventually get evicted. Is there anything else we can try on th=
is host to understand why this is happening?=0A=0AThank you,=0A=0AMetin=0A=
=0AOn Tue 20-11-12 09:42:42, metin d wrote:=0A> I have two PostgreSQL datab=
ases named data-1 and data-2 that sit on the=0A> same machine. Both databas=
es keep 40 GB of data, and the total memory=0A> available on the machine is=
 68GB.=0A> =0A> I started data-1 and data-2, and ran several queries to go =
over all their=0A> data. Then, I shut down data-1 and kept issuing queries =
against data-2.=0A> For some reason, the OS still holds on to large parts o=
f data-1's pages=0A> in its page cache, and reserves about 35 GB of RAM to =
data-2's files. As=0A> a result, my queries on data-2 keep hitting disk.=0A=
> =0A> I'm checking page cache usage with fincore. When I run a table scan =
query=0A> against data-2, I see that data-2's pages get evicted and put bac=
k into=0A> the cache in a round-robin manner. Nothing happens to data-1's p=
ages,=0A> although they haven't been touched for days.=0A> =0A> Does anybod=
y know why data-1's pages aren't evicted from the page cache?=0A> I'm open =
to all kind of suggestions you think it might relate to problem.=0A=A0 Curi=
ous. Added linux-mm list to CC to catch more attention. If you run=0Aecho 1=
 >/proc/sys/vm/drop_caches=0A=A0 does it evict data-1 pages from memory?=0A=
=0A> This is an EC2 m2.4xlarge instance on Amazon with 68 GB of RAM and no=
=0A> swap space. The kernel version is:=0A> =0A> $ uname -r=0A> 3.2.28-45.6=
2.amzn1.x86_64=0A> Edit:=0A> =0A> and it seems that I use one NUMA instance=
, if=A0 you think that it can a problem.=0A> =0A> $ numactl --hardware=0A> =
available: 1 nodes (0)=0A> node 0 cpus: 0 1 2 3 4 5 6 7=0A> node 0 size: 70=
007 MB=0A> node 0 free: 360 MB=0A> node distances:=0A> node=A0=A0 0=0A>=A0=
=A0 0:=A0 10=0A=0A-- =0AJan Kara <jack@suse.cz>=0ASUSE Labs, CR=0A

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
