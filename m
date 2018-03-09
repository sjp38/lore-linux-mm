Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 78D506B0005
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 15:09:45 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id y9so7658922qti.3
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 12:09:45 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id z33si1475691qtc.156.2018.03.09.12.09.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Mar 2018 12:09:44 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w29K7tCg052940
	for <linux-mm@kvack.org>; Fri, 9 Mar 2018 15:09:43 -0500
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2gkyv8akxj-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 09 Mar 2018 15:09:43 -0500
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Fri, 9 Mar 2018 20:09:32 -0000
Date: Fri, 9 Mar 2018 12:09:17 -0800
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH] x86, powerpc : pkey-mprotect must allow pkey-0
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1520583161-11741-1-git-send-email-linuxram@us.ibm.com>
 <20180309084332.hk6xt6obghoqokbc@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180309084332.hk6xt6obghoqokbc@gmail.com>
Message-Id: <20180309200917.GT1060@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, corbet@lwn.net, arnd@arndb.de, fweimer@redhat.com, msuchanek@suse.com, Ulrich.Weigand@de.ibm.com

On Fri, Mar 09, 2018 at 09:43:32AM +0100, Ingo Molnar wrote:
> 
> * Ram Pai <linuxram@us.ibm.com> wrote:
> 
> > Once an address range is associated with an allocated pkey, it cannot be
> > reverted back to key-0. There is no valid reason for the above behavior.  On
> > the contrary applications need the ability to do so.
> > 
> > The patch relaxes the restriction.
> > 
> > Tested on powerpc and x86_64.
> > 
> > cc: Dave Hansen <dave.hansen@intel.com>
> > cc: Michael Ellermen <mpe@ellerman.id.au>
> > cc: Ingo Molnar <mingo@kernel.org>
> > Signed-off-by: Ram Pai <linuxram@us.ibm.com>
> > ---
> >  arch/powerpc/include/asm/pkeys.h | 19 ++++++++++++++-----
> >  arch/x86/include/asm/pkeys.h     |  5 +++--
> >  2 files changed, 17 insertions(+), 7 deletions(-)
> > 
> > diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
> > index 0409c80..3e8abe4 100644
> > --- a/arch/powerpc/include/asm/pkeys.h
> > +++ b/arch/powerpc/include/asm/pkeys.h
> > @@ -101,10 +101,18 @@ static inline u16 pte_to_pkey_bits(u64 pteflags)
> >  
> >  static inline bool mm_pkey_is_allocated(struct mm_struct *mm, int pkey)
> >  {
> > -	/* A reserved key is never considered as 'explicitly allocated' */
> > -	return ((pkey < arch_max_pkey()) &&
> > -		!__mm_pkey_is_reserved(pkey) &&
> > -		__mm_pkey_is_allocated(mm, pkey));
> > +	/* pkey 0 is allocated by default. */
> > +	if (!pkey)
> > +	       return true;
> > +
> > +	if (pkey < 0 || pkey >= arch_max_pkey())
> > +	       return false;
> > +
> > +	/* reserved keys are never allocated. */
> > +	if (__mm_pkey_is_reserved(pkey))
> > +	       return false;
> 
> Please capitalize in comments consistently, i.e.:

ok.

> 
> 	/* Reserved keys are never allocated: */
> 
> > +
> > +	return(__mm_pkey_is_allocated(mm, pkey));
> 
> 'return' is not a function.

right. will fix.

Thanks,
RP
