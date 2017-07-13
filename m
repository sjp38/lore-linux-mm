Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9D15F4408E5
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 19:29:29 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id p15so74948394pgs.7
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 16:29:29 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l3si5337720pld.259.2017.07.13.16.29.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jul 2017 16:29:28 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6DNSaV5000671
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 19:29:28 -0400
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2bpda0kcsh-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 19:29:27 -0400
Received: from localhost
	by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Thu, 13 Jul 2017 19:29:26 -0400
Date: Thu, 13 Jul 2017 16:29:16 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [RFC v5 15/38] powerpc: helper function to read,write
 AMR,IAMR,UAMOR registers
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
 <1499289735-14220-16-git-send-email-linuxram@us.ibm.com>
 <20170712152601.3b2f52ed@firefly.ozlabs.ibm.com>
 <20170713075502.GG5525@ram.oc3035372033.ibm.com>
 <CAKTCnzmDd2K0gc=0gvNn7Q_QBPqmQdwppnpU-J9B1AMva7w8sA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKTCnzmDd2K0gc=0gvNn7Q_QBPqmQdwppnpU-J9B1AMva7w8sA@mail.gmail.com>
Message-Id: <20170713232916.GK5525@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, linux-kselftest@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Aneesh Kumar KV <aneesh.kumar@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@intel.com>, Haren Myneni/Beaverton/IBM <hbabu@us.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Ingo Molnar <mingo@redhat.com>

On Thu, Jul 13, 2017 at 07:49:05PM +1000, Balbir Singh wrote:
> On Thu, Jul 13, 2017 at 5:55 PM, Ram Pai <linuxram@us.ibm.com> wrote:
> > On Wed, Jul 12, 2017 at 03:26:01PM +1000, Balbir Singh wrote:
> >> On Wed,  5 Jul 2017 14:21:52 -0700
> >> Ram Pai <linuxram@us.ibm.com> wrote:
> >>
> >> > Implements helper functions to read and write the key related
> >> > registers; AMR, IAMR, UAMOR.
> >> >
> >> > AMR register tracks the read,write permission of a key
> >> > IAMR register tracks the execute permission of a key
> >> > UAMOR register enables and disables a key
> >> >
> >> > Signed-off-by: Ram Pai <linuxram@us.ibm.com>
> >> > ---
> >> >  arch/powerpc/include/asm/book3s/64/pgtable.h |   60 ++++++++++++++++++++++++++
> >> >  1 files changed, 60 insertions(+), 0 deletions(-)
> >> >
> >> > diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
> >> > index 85bc987..435d6a7 100644
> >> > --- a/arch/powerpc/include/asm/book3s/64/pgtable.h
> >> > +++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
> >> > @@ -428,6 +428,66 @@ static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
> >> >             pte_update(mm, addr, ptep, 0, _PAGE_PRIVILEGED, 1);
> >> >  }
> >> >
> >> > +#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
> >> > +
> >> > +#include <asm/reg.h>
> >> > +static inline u64 read_amr(void)
> >> > +{
> >> > +   return mfspr(SPRN_AMR);
> >> > +}
> >> > +static inline void write_amr(u64 value)
> >> > +{
> >> > +   mtspr(SPRN_AMR, value);
> >> > +}
> >> > +static inline u64 read_iamr(void)
> >> > +{
> >> > +   return mfspr(SPRN_IAMR);
> >> > +}
> >> > +static inline void write_iamr(u64 value)
> >> > +{
> >> > +   mtspr(SPRN_IAMR, value);
> >> > +}
> >> > +static inline u64 read_uamor(void)
> >> > +{
> >> > +   return mfspr(SPRN_UAMOR);
> >> > +}
> >> > +static inline void write_uamor(u64 value)
> >> > +{
> >> > +   mtspr(SPRN_UAMOR, value);
> >> > +}
> >> > +
> >> > +#else /* CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
> >> > +
> >> > +static inline u64 read_amr(void)
> >> > +{
> >> > +   WARN(1, "%s called with MEMORY PROTECTION KEYS disabled\n", __func__);
> >> > +   return -1;
> >> > +}
> >>
> >> Why do we need to have a version here if we are going to WARN(), why not
> >> let the compilation fail if called from outside of CONFIG_PPC64_MEMORY_PROTECTION_KEYS?
> >> Is that the intention?
> >
> > I did not want to stop someone; kernel module for example, from calling
> > these interfaces from outside the pkey domain.
> >
> > Either way can be argued to be correct, I suppose.
> 
> Nope, build failures are better than run time failures, otherwise the
> kernel will split its guts warning and warning here.
> 

Well these are helper functions that can be called by anyone under
any situation. I will rather have them defined unconditionally; under
no ifdefs.  No spewing of warnings anymore. The registers will
be read or written as told. It just makes sense that way.

RP

-- 
Ram Pai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
