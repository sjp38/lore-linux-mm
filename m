Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5549B6B05A1
	for <linux-mm@kvack.org>; Sat, 29 Jul 2017 20:38:33 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id r63so149647824pfb.7
        for <linux-mm@kvack.org>; Sat, 29 Jul 2017 17:38:33 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 63si14634007pld.380.2017.07.29.17.38.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Jul 2017 17:38:32 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6U0cVs6014399
	for <linux-mm@kvack.org>; Sat, 29 Jul 2017 20:38:31 -0400
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2c0mpmtfw9-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 29 Jul 2017 20:38:31 -0400
Received: from localhost
	by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Sat, 29 Jul 2017 20:38:30 -0400
Date: Sat, 29 Jul 2017 17:38:19 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [RFC v6 15/62] powerpc: helper functions to initialize AMR, IAMR
 and UMOR registers
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
 <1500177424-13695-16-git-send-email-linuxram@us.ibm.com>
 <877eyt4nqr.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <877eyt4nqr.fsf@linux.vnet.ibm.com>
Message-Id: <20170730003819.GI5664@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, arnd@arndb.de, corbet@lwn.net, mhocko@kernel.org, dave.hansen@intel.com, mingo@redhat.com, paulus@samba.org, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com

On Thu, Jul 27, 2017 at 05:40:44PM -0300, Thiago Jung Bauermann wrote:
> 
> Ram Pai <linuxram@us.ibm.com> writes:
> 
> > Introduce helper functions that can initialize the bits in the AMR,
> > IAMR and UMOR register; the bits that correspond to the given pkey.
> >
> > Signed-off-by: Ram Pai <linuxram@us.ibm.com>
> 
> s/UMOR/UAMOR/ here and in the subject as well.

yes. fixed it.

> 
> > --- a/arch/powerpc/mm/pkeys.c
> > +++ b/arch/powerpc/mm/pkeys.c
> > @@ -16,3 +16,47 @@
> >  #include <linux/pkeys.h>                /* PKEY_*                       */
> >
> >  bool pkey_inited;
> > +#define pkeyshift(pkey) ((arch_max_pkey()-pkey-1) * AMR_BITS_PER_PKEY)
> > +
> > +static inline void init_amr(int pkey, u8 init_bits)
> > +{
> > +	u64 new_amr_bits = (((u64)init_bits & 0x3UL) << pkeyshift(pkey));
> > +	u64 old_amr = read_amr() & ~((u64)(0x3ul) << pkeyshift(pkey));
> > +
> > +	write_amr(old_amr | new_amr_bits);
> > +}
> > +
> > +static inline void init_iamr(int pkey, u8 init_bits)
> > +{
> > +	u64 new_iamr_bits = (((u64)init_bits & 0x3UL) << pkeyshift(pkey));
> > +	u64 old_iamr = read_iamr() & ~((u64)(0x3ul) << pkeyshift(pkey));
> > +
> > +	write_amr(old_iamr | new_iamr_bits);
> > +}
> 
> init_iamr should call write_iamr, not write_amr.

excellent catch. thanks.
RP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
