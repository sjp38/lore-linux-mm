Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9B1838E0001
	for <linux-mm@kvack.org>; Mon, 17 Sep 2018 18:34:26 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id x85-v6so9089572pfe.13
        for <linux-mm@kvack.org>; Mon, 17 Sep 2018 15:34:26 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id f185-v6si16061111pgc.625.2018.09.17.15.34.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Sep 2018 15:34:25 -0700 (PDT)
From: "Huang, Kai" <kai.huang@intel.com>
Subject: RE: [RFC 11/12] keys/mktme: Add a new key service type for memory
 encryption keys
Date: Mon, 17 Sep 2018 22:34:20 +0000
Message-ID: <105F7BF4D0229846AF094488D65A09893543401B@PGSMSX112.gar.corp.intel.com>
References: <cover.1536356108.git.alison.schofield@intel.com>
 <1a14a6feb02f968c5e6b98360f6f16106b633b58.1536356108.git.alison.schofield@intel.com>
 <105F7BF4D0229846AF094488D65A098935424C2D@PGSMSX112.gar.corp.intel.com>
 <20180915000639.GA28666@alison-desk.jf.intel.com>
 <105F7BF4D0229846AF094488D65A098935432E09@PGSMSX112.gar.corp.intel.com>
In-Reply-To: <105F7BF4D0229846AF094488D65A098935432E09@PGSMSX112.gar.corp.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Kai" <kai.huang@intel.com>, "Schofield, Alison" <alison.schofield@intel.com>
Cc: "dhowells@redhat.com" <dhowells@redhat.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "Nakajima, Jun" <jun.nakajima@intel.com>, "Shutemov,
 Kirill" <kirill.shutemov@intel.com>, "Hansen, Dave" <dave.hansen@intel.com>, "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>, "jmorris@namei.org" <jmorris@namei.org>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

> > On Sun, Sep 09, 2018 at 08:29:29PM -0700, Huang, Kai wrote:
> > > > + */
> > > > +static int mktme_build_cpumask(void) {
> > > > +	int online_cpu, mktme_cpu;
> > > > +	int online_pkgid, mktme_pkgid =3D -1;
> > > > +
> > > > +	if (!zalloc_cpumask_var(&mktme_cpumask, GFP_KERNEL))
> > > > +		return -ENOMEM;
> > > > +
> > > > +	for_each_online_cpu(online_cpu) {
> > > > +		online_pkgid =3D topology_physical_package_id(online_cpu);
> > > > +
> > > > +		for_each_cpu(mktme_cpu, mktme_cpumask) {
> > > > +			mktme_pkgid =3D
> > > > topology_physical_package_id(mktme_cpu);
> > > > +			if (mktme_pkgid =3D=3D online_pkgid)
> > > > +				break;
> > > > +		}
> > > > +		if (mktme_pkgid !=3D online_pkgid)
> > > > +			cpumask_set_cpu(online_cpu, mktme_cpumask);
> > > > +	}
> > >
> > > Could we use 'for_each_online_node', 'cpumask_first/next', etc to
> > > simplify the
> > logic?
> >
> > Kai,
> >
> > I tried to simplify it and came up with code that looked like this:
> >
> > 	int lead_cpu, node;
> > 	for_each_online_node(node) {
> > 		lead_cpu =3D cpumask_first(cpumask_of_node(node));
> > 		if (lead_cpu < nr_cpu_ids)
> > 			cpumask_set_cpu(lead_cpu, mktme_cpumask_NEW);
> > 	}
> > When I test it on an SNC (Sub Numa Cluster) system it gives me too many
> CPU's.
> > I get a CPU per Node (just like i asked for;) instead of per Socket.
> > It has 2 sockets and 4 NUMA nodes.
> >
> > I kind of remember this when I originally coded it, hence the bottoms
> > up approach using topology_physical_package_id()
> >
> > Any ideas?
>=20
> Hmm.. I forgot the SNC case, sorry :(
>=20
> So in case of SNC, is PCONFIG per-package, or per-node? I am not quite su=
re
> about this.

I have confirmed internally that PCONFIG is per-package even in SNC.

Thanks,
-Kai
>=20
> If PCONFIG is per-package, I don't have better idea than your original on=
e. :)
>=20
> Thanks,
> -Kai
> >
> > Alison
> >
