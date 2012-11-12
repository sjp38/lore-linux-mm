Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id B49156B006C
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 16:38:16 -0500 (EST)
Received: from mail199-ch1 (localhost [127.0.0.1])	by
 mail199-ch1-R.bigfish.com (Postfix) with ESMTP id 704993402A9	for
 <linux-mm@kvack.org.FOPE.CONNECTOR.OVERRIDE>; Mon, 12 Nov 2012 21:36:14 +0000
 (UTC)
From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH 1/1] mm: Export a function to read vm_committed_as
Date: Mon, 12 Nov 2012 21:36:10 +0000
Message-ID: <426367E2313C2449837CD2DE46E7EAF930E39F5B@SN2PRD0310MB382.namprd03.prod.outlook.com>
References: <1352600728-17766-1-git-send-email-kys@microsoft.com>
 <alpine.DEB.2.00.1211101830250.18494@chino.kir.corp.google.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kamezawa.hiroyuki@gmail.com" <kamezawa.hiroyuki@gmail.com>, "mhocko@suse.cz" <mhocko@suse.cz>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "yinghan@google.com" <yinghan@google.com>



> -----Original Message-----
> From: KY Srinivasan
> Sent: Sunday, November 11, 2012 4:24 AM
> To: 'David Rientjes'
> Cc: gregkh@linuxfoundation.org; linux-kernel@vger.kernel.org;
> devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
> andi@firstfloor.org; akpm@linux-foundation.org; linux-mm@kvack.org;
> kamezawa.hiroyuki@gmail.com; mhocko@suse.cz; hannes@cmpxchg.org;
> yinghan@google.com
> Subject: RE: [PATCH 1/1] mm: Export a function to read vm_committed_as
>=20
>=20
>=20
> > -----Original Message-----
> > From: David Rientjes [mailto:rientjes@google.com]
> > Sent: Saturday, November 10, 2012 9:35 PM
> > To: KY Srinivasan
> > Cc: gregkh@linuxfoundation.org; linux-kernel@vger.kernel.org;
> > devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
> > andi@firstfloor.org; akpm@linux-foundation.org; linux-mm@kvack.org;
> > kamezawa.hiroyuki@gmail.com; mhocko@suse.cz; hannes@cmpxchg.org;
> > yinghan@google.com
> > Subject: Re: [PATCH 1/1] mm: Export a function to read vm_committed_as
> >
> > On Sat, 10 Nov 2012, K. Y. Srinivasan wrote:
> >
> > > diff --git a/mm/mmap.c b/mm/mmap.c
> > > index 2d94235..e527239 100644
> > > --- a/mm/mmap.c
> > > +++ b/mm/mmap.c
> > > @@ -89,6 +89,17 @@ int sysctl_max_map_count __read_mostly =3D
> > DEFAULT_MAX_MAP_COUNT;
> > >  struct percpu_counter vm_committed_as ____cacheline_aligned_in_smp;
> > >
> > >  /*
> > > + * A wrapper to read vm_committed_as that can be used by external
> > modules.
> > > + */
> > > +
> > > +unsigned long read_vm_committed_as(void)
> > > +{
> > > +	return percpu_counter_read_positive(&vm_committed_as);
> > > +}
> > > +
> > > +EXPORT_SYMBOL_GPL(read_vm_committed_as);
> > > +
> > > +/*
> > >   * Check that a process has enough memory to allocate a new virtual
> > >   * mapping. 0 means there is enough memory for the allocation to
> > >   * succeed and -ENOMEM implies there is not.
> >
> > This is precisely what I didn't want to see; I was expecting that this
> > function was going to have some name that would describe what a hypervi=
sor
> > would use it for, regardless of its implementation and current use of
> > vm_committed_as.  read_vm_committed_as() misses the entire point of the
> > suggestion and a few people have mentioned that they think this
> > implementation will evolve over time.
> >
> > Please think of what you're trying to determine in the code that will
> > depend on this and then convert the existing user in
> > drivers/xen/xen-selfballoon.c.
>=20
> David,
>=20
> Thanks for the prompt response. For the Linux balloon driver for Hyper-V,=
 I need
> access
> to the metric that reflects the system wide memory commitment made by the
> guest kernel.
> In the Hyper-V case, this information is one of the many metrics used to =
drive the
> policy engine
> on the host. Granted, the interface name I have chosen here could be more
> generic; how about
> read_mem_commit_info(void). I am open to suggestions here.
>=20
> With regards to making changes to the Xen self ballooning code, I would l=
ike to
> separate that patch
> from the patch that implements the exported mechanism to access the memor=
y
> commitment information.
> Once we settle on this patch, I can submit the patch to fix the Xen self =
ballooning
> driver to use this new
> interface along with the Hyper-V balloon driver that is currently blocked=
 on
> resolving this issue.

David,

I want to finalize this ASAP. Please give me your feedback so I can move th=
is forward.

Regards,

K. Y


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
