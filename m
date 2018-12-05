Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4787D6B7387
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 04:10:39 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id l22so9997489pfb.2
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 01:10:39 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k11si17688675pgf.213.2018.12.05.01.10.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 05 Dec 2018 01:10:38 -0800 (PST)
Date: Wed, 5 Dec 2018 10:10:29 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC v2 11/13] keys/mktme: Program memory encryption keys on a
 system wide basis
Message-ID: <20181205091029.GB4234@hirez.programming.kicks-ass.net>
References: <cover.1543903910.git.alison.schofield@intel.com>
 <72dd5f38c1fdbc4c532f8caf2d2010f1ddfa8439.1543903910.git.alison.schofield@intel.com>
 <20181204092145.GR11614@hirez.programming.kicks-ass.net>
 <20181205054353.GE18596@alison-desk.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181205054353.GE18596@alison-desk.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alison Schofield <alison.schofield@intel.com>
Cc: dhowells@redhat.com, tglx@linutronix.de, jmorris@namei.org, mingo@redhat.com, hpa@zytor.com, bp@alien8.de, luto@kernel.org, kirill.shutemov@linux.intel.com, dave.hansen@intel.com, kai.huang@intel.com, jun.nakajima@intel.com, dan.j.williams@intel.com, jarkko.sakkinen@intel.com, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

On Tue, Dec 04, 2018 at 09:43:53PM -0800, Alison Schofield wrote:
> On Tue, Dec 04, 2018 at 10:21:45AM +0100, Peter Zijlstra wrote:
> > On Mon, Dec 03, 2018 at 11:39:58PM -0800, Alison Schofield wrote:
> > 
> > > +static int mktme_build_leadcpus_mask(void)
> > > +{
> > > +	int online_cpu, mktme_cpu;
> > > +	int online_pkgid, mktme_pkgid = -1;
> > > +
> > > +	if (!zalloc_cpumask_var(&mktme_leadcpus, GFP_KERNEL))
> > > +		return -ENOMEM;
> > > +
> > > +	for_each_online_cpu(online_cpu) {
> > > +		online_pkgid = topology_physical_package_id(online_cpu);
> > > +
> > > +		for_each_cpu(mktme_cpu, mktme_leadcpus) {
> > > +			mktme_pkgid = topology_physical_package_id(mktme_cpu);
> > > +			if (mktme_pkgid == online_pkgid)
> > > +				break;
> > > +		}
> > > +		if (mktme_pkgid != online_pkgid)
> > > +			cpumask_set_cpu(online_cpu, mktme_leadcpus);
> > 
> > Do you really need LOCK prefixed bit set here?
> No. Changed to __cpumask_set_cpu(). Will check for other instances
> where I can skip LOCK prefix.
> 
> > How is that serialized and kept relevant in the face of hotplug?
> mktme_leadcpus is updated on hotplug startup and teardowns.

Not in this patch it is not. That is added in a subsequent patch, which
means that during bisection hotplug is utterly wrecked if you happen to
land between these patches, that is bad.

> > Also, do you really need O(n^2) to find the first occurence of a value
> > in an array?

> How about this O(n)?
> 	
> 	unsigned long *pkg_map;
> 	int cpu, pkgid;
> 
> 	if (!zalloc_cpumask_var(&mktme_leadcpus, GFP_KERNEL))
> 		return -ENOMEM;
> 
> 	pkg_map = bitmap_zalloc(topology_max_packages(), GFP_KERNEL);
> 	if (!pkg_map) {
> 		free_cpumask_var(mktme_leadcpus);
> 		return -ENOMEM;
> 	}
> 	for_each_online_cpu(cpu) {
> 		pkgid = topology_physical_package_id(cpu);
> 		if (!test_and_set_bit(pkgid, pkg_map))

You again don't need that LOCK prefix here.

	__test_and_set_bit() :-)

> 			__cpumask_set_cpu(cpu, mktme_leadcpus);
> 	}

Right.
