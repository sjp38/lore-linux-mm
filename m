Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6BDA16B0593
	for <linux-mm@kvack.org>; Sat, 29 Jul 2017 18:43:18 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id y129so244201631pgy.1
        for <linux-mm@kvack.org>; Sat, 29 Jul 2017 15:43:18 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id h77si4761137pfj.267.2017.07.29.15.43.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Jul 2017 15:43:17 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6TMeDc9127222
	for <linux-mm@kvack.org>; Sat, 29 Jul 2017 18:43:16 -0400
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2c0mpmr20q-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 29 Jul 2017 18:43:16 -0400
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Sat, 29 Jul 2017 16:43:15 -0600
Date: Sat, 29 Jul 2017 15:43:05 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [RFC v6 13/62] powerpc: track allocation status of all pkeys
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
 <1500177424-13695-14-git-send-email-linuxram@us.ibm.com>
 <87eft23rnb.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <87eft23rnb.fsf@linux.vnet.ibm.com>
Message-Id: <20170729224305.GE5664@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, arnd@arndb.de, corbet@lwn.net, mhocko@kernel.org, dave.hansen@intel.com, mingo@redhat.com, paulus@samba.org, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com

On Thu, Jul 27, 2017 at 11:01:44AM -0300, Thiago Jung Bauermann wrote:
>=20
> Hello Ram,
>=20
> I'm still going through the patches and haven't formed a full picture of
> the feature in my mind yet, so my comments today won't be particularly
> insightful...
>=20
> But hopefully the comments that I currently have will be helpful anyway.

sure. thanx for taking the time to look through the patches.

>=20
> Ram Pai <linuxram@us.ibm.com> writes:
> > diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/as=
m/pkeys.h
> > index 203d7de..09b268e 100644
> > --- a/arch/powerpc/include/asm/pkeys.h
> > +++ b/arch/powerpc/include/asm/pkeys.h
> > @@ -2,21 +2,87 @@
> >  #define _ASM_PPC64_PKEYS_H
> >
> >  extern bool pkey_inited;
> > -#define ARCH_VM_PKEY_FLAGS 0
> > +#define arch_max_pkey()  32
> > +#define ARCH_VM_PKEY_FLAGS (VM_PKEY_BIT0 | VM_PKEY_BIT1 | VM_PKEY_BIT2=
 | \
> > +				VM_PKEY_BIT3 | VM_PKEY_BIT4)
> > +/*
> > + * Bits are in BE format.
> > + * NOTE: key 31, 1, 0 are not used.
> > + * key 0 is used by default. It give read/write/execute permission.
> > + * key 31 is reserved by the hypervisor.
> > + * key 1 is recommended to be not used.
> > + * PowerISA(3.0) page 1015, programming note.
> > + */
> > +#define PKEY_INITIAL_ALLOCAION  0xc0000001
>=20
> There's a typo in the macro name, should be "ALLOCATION".

Thanks fixed it. The new version of the code, calculates the
allocation_mask at runtime, depending on the number of keys specified by
the device tree as well as other factors.  So the above macro is
replaced by a variable 'initial_allocation_mask'.

RP

>=20
> --=20
> Thiago Jung Bauermann
> IBM Linux Technology Center

--=20
Ram Pai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
