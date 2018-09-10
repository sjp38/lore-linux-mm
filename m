Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D68B88E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 17:47:00 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id u13-v6so11686904pfm.8
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 14:47:00 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id i184-v6si19521396pfb.98.2018.09.10.14.46.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 14:46:59 -0700 (PDT)
Date: Mon, 10 Sep 2018 14:47:32 -0700
From: Alison Schofield <alison.schofield@intel.com>
Subject: Re: [RFC 11/12] keys/mktme: Add a new key service type for memory
 encryption keys
Message-ID: <20180910214731.GA29337@alison-desk.jf.intel.com>
References: <cover.1536356108.git.alison.schofield@intel.com>
 <1a14a6feb02f968c5e6b98360f6f16106b633b58.1536356108.git.alison.schofield@intel.com>
 <105F7BF4D0229846AF094488D65A098935424C2D@PGSMSX112.gar.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <105F7BF4D0229846AF094488D65A098935424C2D@PGSMSX112.gar.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Kai" <kai.huang@intel.com>
Cc: "dhowells@redhat.com" <dhowells@redhat.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "Nakajima, Jun" <jun.nakajima@intel.com>, "Shutemov, Kirill" <kirill.shutemov@intel.com>, "Hansen, Dave" <dave.hansen@intel.com>, "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>, "jmorris@namei.org" <jmorris@namei.org>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sun, Sep 09, 2018 at 08:29:29PM -0700, Huang, Kai wrote:
> > -----Original Message-----
> > From: keyrings-owner@vger.kernel.org [mailto:keyrings-
> > owner@vger.kernel.org] On Behalf Of Alison Schofield
> > Sent: Saturday, September 8, 2018 10:39 AM
> > To: dhowells@redhat.com; tglx@linutronix.de
> > Cc: Huang, Kai <kai.huang@intel.com>; Nakajima, Jun
> > <jun.nakajima@intel.com>; Shutemov, Kirill <kirill.shutemov@intel.com>;
> > Hansen, Dave <dave.hansen@intel.com>; Sakkinen, Jarkko
> > <jarkko.sakkinen@intel.com>; jmorris@namei.org; keyrings@vger.kernel.org;
> > linux-security-module@vger.kernel.org; mingo@redhat.com; hpa@zytor.com;
> > x86@kernel.org; linux-mm@kvack.org
> > Subject: [RFC 11/12] keys/mktme: Add a new key service type for memory
> > encryption keys
> > 
> > MKTME (Multi-Key Total Memory Encryption) is a technology that allows
> > transparent memory encryption in upcoming Intel platforms. MKTME will
> > support mulitple encryption domains, each having their own key. The main use
> > case for the feature is virtual machine isolation. The API needs the flexibility to
> > work for a wide range of uses.
> > 
> > The MKTME key service type manages the addition and removal of the memory
> > encryption keys. It maps software keys to hardware keyids and programs the
> > hardware with the user requested encryption options.
> > 
> > The only supported encryption algorithm is AES-XTS 128.
> > 
> > The MKTME key service is half of the MKTME API level solution. It pairs with a
> > new memory encryption system call: encrypt_mprotect() that uses the keys to
> > encrypt memory.
> > 


Kai -
Splitting out responses by subject...

> > +cpumask_var_t mktme_cpumask;		/* one cpu per pkg to program
> > keys */
> 
> Oh the 'mktme_cpumask' is here. Sorry I didn't notice when replying to your patch 10. :)
> 
> But I think you can just move what you did in patch 10 here and leave intel_pconfig.h unchanged. It's much clearer. 

I'll try that out and see how it works.

> > +
> > +	for_each_online_cpu(online_cpu) {
> > +		online_pkgid = topology_physical_package_id(online_cpu);
> > +
> > +		for_each_cpu(mktme_cpu, mktme_cpumask) {
> > +			mktme_pkgid =
> > topology_physical_package_id(mktme_cpu);
> > +			if (mktme_pkgid == online_pkgid)
> > +				break;
> > +		}
> > +		if (mktme_pkgid != online_pkgid)
> > +			cpumask_set_cpu(online_cpu, mktme_cpumask);
> > +	}
> 
> Could we use 'for_each_online_node', 'cpumask_first/next', etc to simplify the logic?

Sure - I'll look at those. 

Thanks!
Alison
