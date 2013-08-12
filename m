Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id BB5346B0032
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 09:23:32 -0400 (EDT)
Date: Mon, 12 Aug 2013 09:23:10 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH v2 0/4] zcache: a compressed file page cache
Message-ID: <20130812132310.GB3318@phenom.dumpdata.com>
References: <1375788977-12105-1-git-send-email-bob.liu@oracle.com>
 <20130806135800.GC1048@kroah.com>
 <52010714.2090707@oracle.com>
 <20130812121908.GA3196@phenom.dumpdata.com>
 <20130812123002.GA23773@hacker.(null)>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20130812123002.GA23773@hacker.(null)>
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Bob Liu <bob.liu@oracle.com>, Greg KH <gregkh@linuxfoundation.org>, Bob Liu <lliubbo@gmail.com>, linux-mm@kvack.org, ngupta@vflare.org, akpm@linux-foundation.org, sjenning@linux.vnet.ibm.com, riel@redhat.com, mgorman@suse.de, kyungmin.park@samsung.com, p.sarna@partner.samsung.com, barry.song@csr.com, penberg@kernel.org

On Mon, Aug 12, 2013 at 08:30:02PM +0800, Wanpeng Li wrote:
> On Mon, Aug 12, 2013 at 08:19:08AM -0400, Konrad Rzeszutek Wilk wrote:
> >On Tue, Aug 06, 2013 at 10:24:20PM +0800, Bob Liu wrote:
> >> Hi Greg,
> >>=20
> >> On 08/06/2013 09:58 PM, Greg KH wrote:
> >> > On Tue, Aug 06, 2013 at 07:36:13PM +0800, Bob Liu wrote:
> >> >> Dan Magenheimer extended zcache supporting both file pages and an=
onymous pages.
> >> >> It's located in drivers/staging/zcache now. But the current versi=
on of zcache is
> >> >> too complicated to be merged into upstream.
> >> >=20
> >> > Really?  If this is so, I'll just go delete zcache now, I don't wa=
nt to
> >> > lug around dead code that will never be merged.
> >> >=20
> >>=20
> >> Zcache in staging have a zbud allocation which is almost the same as
> >> mm/zbud.c but with different API and have a frontswap backend like
> >> mm/zswap.c.
> >> So I'd prefer reuse mm/zbud.c and mm/zswap.c for a generic memory
> >> compression solution.
> >> Which means in that case, zcache in staging =3D mm/zswap.c + mm/zcac=
he.c +
> >> mm/zbud.c.
> >>=20
> >> But I'm not sure if there are any existing users of zcache in stagin=
g,
> >> if not I can delete zcache from staging in my next version of this
> >> mm/zcache.c series.
> >
> >I think the Samsung folks are using it (zcache).
> >
>=20
> Hi Konrad,
>=20
> If there are real users using ramster? And if Xen project using zcache
> and ramster in staging tree?=20

The Xen Project has an tmem API implementation which allows the 'tmem'
driver (drivers/xen/tmem.c) to use it. The Linux tmem driver implements
both frontswap and cleancache APIs. That means if a guest is running unde=
r
Xen it has the same benefits as if it was running baremetal and using
zswap + zcache3 (what Bob posted, which is the cleancache backend) or
the old zcache2 (staging/zcache).

One way to think about is that the compression, deduplication, etc are
all hoisted in the hypervisor while each of the guests pipes the
pages up/down using hypercalls.

Xen Project does not need to use zcache2 (staging/zcache) as it can
get the same benefits from using tmem. Thought if the user wanted they
can certainly use it and bypass tmem and either load zcache2 or zswap
and zcache3 (the one Bob posted).

In regards to "real users using RAMster"  - I am surmising you are
wondering whether Oracle is offering this as a supported product to
customers?  The answer to that is no at this time as it is still in
development and we would want it to be out of that before Oracle
supports it in its distributions.

Now "would want" and the reality of what can be done right now
is a bit disjoint.

I think that the next step is concentrating on making zswap awesome
and also make the zcache3 (the patches that Bob posted) in shape to
be merged in mm.

It would be fantastic if folks took a look at the patches and gave
comments.

Thanks!

P.S.
Greg, since the Samsung folks are not using it, and we (Oracle) can
patch our distro kernel to provide sm=F6rg=E5sbord of zcache2, zswap
and zcache3, even zcache1 if needed. I think it is safe to
delete staging/zcache and focus on getting the zcache3 (Bob's
patchset) upstream.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
