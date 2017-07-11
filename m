Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 82BEE6810BE
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 18:14:52 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id t75so6074071pgb.0
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 15:14:52 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id g1si401729pgc.11.2017.07.11.15.14.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 15:14:51 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6BM9Z7B075063
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 18:14:51 -0400
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com [32.97.110.159])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2bn0mw9k45-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 18:14:50 -0400
Received: from localhost
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Tue, 11 Jul 2017 16:14:50 -0600
Date: Tue, 11 Jul 2017 15:14:34 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [RFC v5 12/38] mm: ability to disable execute permission on a
 key at creation
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
 <1499289735-14220-13-git-send-email-linuxram@us.ibm.com>
 <3bd2ffd4-33ad-ce23-3db1-d1292e69ca9b@intel.com>
 <1499808577.2865.30.camel@kernel.crashing.org>
 <20170711215105.GA5542@ram.oc3035372033.ibm.com>
 <3bdd9083-ef2a-d1da-802c-c6822cf818b3@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3bdd9083-ef2a-d1da-802c-c6822cf818b3@intel.com>
Message-Id: <20170711221434.GB5542@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-arch@vger.kernel.org, corbet@lwn.net, arnd@arndb.de, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@redhat.com, paulus@samba.org, aneesh.kumar@linux.vnet.ibm.com, linux-kselftest@vger.kernel.org, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, khandual@linux.vnet.ibm.com

On Tue, Jul 11, 2017 at 02:57:30PM -0700, Dave Hansen wrote:
> On 07/11/2017 02:51 PM, Ram Pai wrote:
> > On Wed, Jul 12, 2017 at 07:29:37AM +1000, Benjamin Herrenschmidt wrote:
> >> On Tue, 2017-07-11 at 11:11 -0700, Dave Hansen wrote:
> >>> On 07/05/2017 02:21 PM, Ram Pai wrote:
> >>>> Currently sys_pkey_create() provides the ability to disable read
> >>>> and write permission on the key, at  creation. powerpc  has  the
> >>>> hardware support to disable execute on a pkey as well.This patch
> >>>> enhances the interface to let disable execute  at  key  creation
> >>>> time. x86 does  not  allow  this.  Hence the next patch will add
> >>>> ability  in  x86  to  return  error  if  PKEY_DISABLE_EXECUTE is
> >>>> specified.
> >>
> >> That leads to the question... How do you tell userspace.
> >>
> >> (apologies if I missed that in an existing patch in the series)
> >>
> >> How do we inform userspace of the key capabilities ? There are at least
> >> two things userspace may want to know already:
> >>
> >>  - What protection bits are supported for a key
> > 
> > the userspace is the one which allocates the keys and enables/disables the
> > protection bits on the key. the kernel is just a facilitator. Now if the
> > use space wants to know the current permissions on a given key, it can
> > just read the AMR/PKRU register on powerpc/intel respectively.
> 
> Let's say I want to execute-disable a region.  Can I use protection
> keys?  Do I do
> 
> 	pkey_mprotect(... PKEY_DISABLE_EXECUTE);
> 
> and assume that the -EINVAL is because PKEY_DISABLE_EXECUTE is
> unsupported, or do I do:
> 
> #ifdef __ppc__
> 	pkey = pkey_aloc();
> 	pkey_mprotect(... PKEY_DISABLE_EXECUTE);
> #else
> 	mprotect();
> #endif

on ppc you could do either
pkey = pkey_alloc(..,PKEY_DISABLE_EXECUTE);
pkey_mprotect(...,pkey);

or you can just do the x86 way
mprotect();

> 
> >>  - How many keys exist
> > 
> > There is no standard way of finding this other than trying to allocate
> > as many till you fail.  A procfs or sysfs file can be added to expose
> > this information.
> 
> It's also dynamic.  On x86, you lose a key if you've used the
> execute-only support.  We also reserve the right to steal more in the
> future if we want.

total number of key supported on the architecture is a constant.
How many are reserved by the architecture is also probably known in
advance.
Now how many does the kernel use to reserve for itself is something
the kernel knows too and hence can expose it, though the information
may change dynamically as the kernel reserves and releases the key
based on its internal needs. 

So i think we can expose this informaton through procfs/sysfs and let
the application decide how it wants to use the information.

> 
> >>  - Which keys are available for use by userspace. On PowerPC, the
> >> kernel can reserve some keys for itself, so can the hypervisor. In
> >> fact, they do.
> > 
> > this information can be exposed through /proc or /sysfs
> > 
> > I am sure there will be more demands and requirements as applications
> > start leveraging these feature.
> 
> For 5 bits, I think just having someone run pkey_alloc() in a loop is
> fine.  I don't think we really need to enumerate it in some other way.

-- 
Ram Pai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
