Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id C960C6B0062
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 03:03:41 -0500 (EST)
References: <1353433362.85184.YahooMailNeo@web141101.mail.bf1.yahoo.com> <20121120182500.GH1408@quack.suse.cz>
Message-ID: <1353485020.53500.YahooMailNeo@web141104.mail.bf1.yahoo.com>
Date: Wed, 21 Nov 2012 00:03:40 -0800 (PST)
From: metin d <metdos@yahoo.com>
Reply-To: metin d <metdos@yahoo.com>
Subject: Re: Problem in Page Cache Replacement
In-Reply-To: <20121120182500.GH1408@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

=0A=0A> =A0Curious. Added linux-mm list to CC to catch more attention. If y=
ou run=0A> echo 1 >/proc/sys/vm/drop_caches=A0does it evict data-1 pages fr=
om memory?=0A=0A=0AI'm guessing it'd evict the entries, but am wondering if=
 we could run any more diagnostics before trying this.=0A=0AWe regularly us=
e a setup where we have two databases; one gets used frequently and the oth=
er one about once a month. It seems like the memory manager keeps unused pa=
ges in memory at the expense of frequently used database's performance.=0A=
=0AMy understanding was that under memory pressure from heavily accessed pa=
ges, unused pages would eventually get evicted. Is there anything else we c=
an try on this host to understand why this is happening?=0A=0AThank you,=0A=
=0AMetin=0A=0A=0A----- Original Message -----=0AFrom: Jan Kara <jack@suse.c=
z>=0ATo: metin d <metdos@yahoo.com>=0ACc: "linux-kernel@vger.kernel.org" <l=
inux-kernel@vger.kernel.org>; linux-mm@kvack.org=0ASent: Tuesday, November =
20, 2012 8:25 PM=0ASubject: Re: Problem in Page Cache Replacement=0A=0AOn T=
ue 20-11-12 09:42:42, metin d wrote:=0A> I have two PostgreSQL databases na=
med data-1 and data-2 that sit on the=0A> same machine. Both databases keep=
 40 GB of data, and the total memory=0A> available on the machine is 68GB.=
=0A> =0A> I started data-1 and data-2, and ran several queries to go over a=
ll their=0A> data. Then, I shut down data-1 and kept issuing queries agains=
t data-2.=0A> For some reason, the OS still holds on to large parts of data=
-1's pages=0A> in its page cache, and reserves about 35 GB of RAM to data-2=
's files. As=0A> a result, my queries on data-2 keep hitting disk.=0A> =0A>=
 I'm checking page cache usage with fincore. When I run a table scan query=
=0A> against data-2, I see that data-2's pages get evicted and put back int=
o=0A> the cache in a round-robin manner. Nothing happens to data-1's pages,=
=0A> although they haven't been touched for days.=0A> =0A> Does anybody kno=
w why data-1's pages aren't evicted from the page cache?=0A> I'm open to al=
l kind of suggestions you think it might relate to problem.=0A=A0 Curious. =
Added linux-mm list to CC to catch more attention. If you run=0Aecho 1 >/pr=
oc/sys/vm/drop_caches=0A=A0 does it evict data-1 pages from memory?=0A=0A> =
This is an EC2 m2.4xlarge instance on Amazon with 68 GB of RAM and no=0A> s=
wap space. The kernel version is:=0A> =0A> $ uname -r=0A> 3.2.28-45.62.amzn=
1.x86_64=0A> Edit:=0A> =0A> and it seems that I use one NUMA instance, if =
=A0you think that it can a problem.=0A> =0A> $ numactl --hardware=0A> avail=
able: 1 nodes (0)=0A> node 0 cpus: 0 1 2 3 4 5 6 7=0A> node 0 size: 70007 M=
B=0A> node 0 free: 360 MB=0A> node distances:=0A> node =A0 0=0A> =A0 0: =A0=
10=0A=0A=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=
=A0 =A0=A0=A0 Honza=0A-- =0AJan Kara <jack@suse.cz>=0ASUSE Labs, CR=0A

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
