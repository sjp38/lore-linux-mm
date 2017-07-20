Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8B9DB6B025F
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 18:11:55 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id y3so26625130pgo.7
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 15:11:55 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id q2si2226219pgd.227.2017.07.20.15.11.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jul 2017 15:11:54 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6KM9MMH015890
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 18:11:54 -0400
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2bu1megg81-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 18:11:54 -0400
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Thu, 20 Jul 2017 16:11:53 -0600
Date: Thu, 20 Jul 2017 15:11:36 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [RFC v6 11/62] powerpc: initial pkey plumbing
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
 <1500177424-13695-12-git-send-email-linuxram@us.ibm.com>
 <87shhrprtx.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87shhrprtx.fsf@skywalker.in.ibm.com>
Message-Id: <20170720221136.GI5487@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, mhocko@kernel.org

On Thu, Jul 20, 2017 at 11:34:10AM +0530, Aneesh Kumar K.V wrote:
> Ram Pai <linuxram@us.ibm.com> writes:
> 
> > basic setup to initialize the pkey system. Only 64K kernel in HPT
> > mode, enables the pkey system.
> >
> > Signed-off-by: Ram Pai <linuxram@us.ibm.com>
> > ---
> >  arch/powerpc/Kconfig                   |   16 ++++++++++
> >  arch/powerpc/include/asm/mmu_context.h |    5 +++
> >  arch/powerpc/include/asm/pkeys.h       |   51 ++++++++++++++++++++++++++++++++
> >  arch/powerpc/kernel/setup_64.c         |    4 ++
> >  arch/powerpc/mm/Makefile               |    1 +
> >  arch/powerpc/mm/hash_utils_64.c        |    1 +
> >  arch/powerpc/mm/pkeys.c                |   18 +++++++++++
> >  7 files changed, 96 insertions(+), 0 deletions(-)
> >  create mode 100644 arch/powerpc/include/asm/pkeys.h
> >  create mode 100644 arch/powerpc/mm/pkeys.c
> >
> > diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
> > index bf4391d..5c60fd6 100644
> > --- a/arch/powerpc/Kconfig
> > +++ b/arch/powerpc/Kconfig
> > @@ -855,6 +855,22 @@ config SECCOMP
> >
> >  	  If unsure, say Y. Only embedded should say N here.
> >
> > +config PPC64_MEMORY_PROTECTION_KEYS
> > +	prompt "PowerPC Memory Protection Keys"
> > +	def_bool y
> > +	# Note: only available in 64-bit mode
> > +	depends on PPC64 && PPC_64K_PAGES
> > +	select ARCH_USES_HIGH_VMA_FLAGS
> > +	select ARCH_HAS_PKEYS
> > +	---help---
> > +	  Memory Protection Keys provides a mechanism for enforcing
> > +	  page-based protections, but without requiring modification of the
> > +	  page tables when an application changes protection domains.
> > +
> > +	  For details, see Documentation/vm/protection-keys.txt
> > +
> > +	  If unsure, say y.
> > +
> >  endmenu
> 
> 
> Shouldn't this come as the last patch ? Or can we enable this config by
> this patch ? If so what does it do ? Did you test boot each of this
> patch to make sure we don't break git bisect ?

it partially enables the key subsystem. The code is there, but it does
not do much. Essentially the behavior is the same as without the code.

Yes. it is test booted but not extensively on all
platforms/configurations.

However this code is blindly enabling pkey subsystem without referring
to the device tree. I have fixed this patch series to add that additional
patch. In that patch series, I place all the code without
enabling the subsystem.  The last patch actually fires it up, 
depending on availability of the feature as told by the device-tree.
RP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
