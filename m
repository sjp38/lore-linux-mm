Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id C13DD8E0001
	for <linux-mm@kvack.org>; Mon, 17 Sep 2018 06:48:44 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 186-v6so6205610pgc.12
        for <linux-mm@kvack.org>; Mon, 17 Sep 2018 03:48:44 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 3-v6si15274476plz.351.2018.09.17.03.48.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Sep 2018 03:48:43 -0700 (PDT)
From: "Huang, Kai" <kai.huang@intel.com>
Subject: RE: [RFC 11/12] keys/mktme: Add a new key service type for memory
 encryption keys
Date: Mon, 17 Sep 2018 10:48:33 +0000
Message-ID: <105F7BF4D0229846AF094488D65A098935432E09@PGSMSX112.gar.corp.intel.com>
References: <cover.1536356108.git.alison.schofield@intel.com>
 <1a14a6feb02f968c5e6b98360f6f16106b633b58.1536356108.git.alison.schofield@intel.com>
 <105F7BF4D0229846AF094488D65A098935424C2D@PGSMSX112.gar.corp.intel.com>
 <20180915000639.GA28666@alison-desk.jf.intel.com>
In-Reply-To: <20180915000639.GA28666@alison-desk.jf.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Schofield, Alison" <alison.schofield@intel.com>
Cc: "dhowells@redhat.com" <dhowells@redhat.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "Nakajima, Jun" <jun.nakajima@intel.com>, "Shutemov,
 Kirill" <kirill.shutemov@intel.com>, "Hansen, Dave" <dave.hansen@intel.com>, "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>, "jmorris@namei.org" <jmorris@namei.org>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

> -----Original Message-----
> From: Schofield, Alison
> Sent: Saturday, September 15, 2018 12:07 PM
> To: Huang, Kai <kai.huang@intel.com>
> Cc: dhowells@redhat.com; tglx@linutronix.de; Nakajima, Jun
> <jun.nakajima@intel.com>; Shutemov, Kirill <kirill.shutemov@intel.com>;
> Hansen, Dave <dave.hansen@intel.com>; Sakkinen, Jarkko
> <jarkko.sakkinen@intel.com>; jmorris@namei.org; keyrings@vger.kernel.org;
> linux-security-module@vger.kernel.org; mingo@redhat.com; hpa@zytor.com;
> x86@kernel.org; linux-mm@kvack.org
> Subject: Re: [RFC 11/12] keys/mktme: Add a new key service type for memor=
y
> encryption keys
>=20
> On Sun, Sep 09, 2018 at 08:29:29PM -0700, Huang, Kai wrote:
> > > + */
> > > +static int mktme_build_cpumask(void) {
> > > +	int online_cpu, mktme_cpu;
> > > +	int online_pkgid, mktme_pkgid =3D -1;
> > > +
> > > +	if (!zalloc_cpumask_var(&mktme_cpumask, GFP_KERNEL))
> > > +		return -ENOMEM;
> > > +
> > > +	for_each_online_cpu(online_cpu) {
> > > +		online_pkgid =3D topology_physical_package_id(online_cpu);
> > > +
> > > +		for_each_cpu(mktme_cpu, mktme_cpumask) {
> > > +			mktme_pkgid =3D
> > > topology_physical_package_id(mktme_cpu);
> > > +			if (mktme_pkgid =3D=3D online_pkgid)
> > > +				break;
> > > +		}
> > > +		if (mktme_pkgid !=3D online_pkgid)
> > > +			cpumask_set_cpu(online_cpu, mktme_cpumask);
> > > +	}
> >
> > Could we use 'for_each_online_node', 'cpumask_first/next', etc to simpl=
ify the
> logic?
>=20
> Kai,
>=20
> I tried to simplify it and came up with code that looked like this:
>=20
> 	int lead_cpu, node;
> 	for_each_online_node(node) {
> 		lead_cpu =3D cpumask_first(cpumask_of_node(node));
> 		if (lead_cpu < nr_cpu_ids)
> 			cpumask_set_cpu(lead_cpu, mktme_cpumask_NEW);
> 	}
> When I test it on an SNC (Sub Numa Cluster) system it gives me too many C=
PU's.
> I get a CPU per Node (just like i asked for;) instead of per Socket.
> It has 2 sockets and 4 NUMA nodes.
>=20
> I kind of remember this when I originally coded it, hence the bottoms up
> approach using topology_physical_package_id()
>=20
> Any ideas?

Hmm.. I forgot the SNC case, sorry :(

So in case of SNC, is PCONFIG per-package, or per-node? I am not quite sure=
 about this.

If PCONFIG is per-package, I don't have better idea than your original one.=
 :)

Thanks,
-Kai
>=20
> Alison
>=20
