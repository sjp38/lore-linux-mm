Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 27D078E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 19:40:50 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id bg5-v6so10627140plb.20
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 16:40:50 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id i2-v6si18577435pgh.565.2018.09.10.16.40.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 16:40:49 -0700 (PDT)
Date: Mon, 10 Sep 2018 16:41:13 -0700
From: Alison Schofield <alison.schofield@intel.com>
Subject: Re: [RFC 04/12] x86/mm: Add helper functions to manage memory
 encryption keys
Message-ID: <20180910234112.GA31868@alison-desk.jf.intel.com>
References: <cover.1536356108.git.alison.schofield@intel.com>
 <28a55df5da1ecfea28bac588d3ac429cf1419b42.1536356108.git.alison.schofield@intel.com>
 <105F7BF4D0229846AF094488D65A098935424B67@PGSMSX112.gar.corp.intel.com>
 <105F7BF4D0229846AF094488D65A098935426CD1@PGSMSX112.gar.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <105F7BF4D0229846AF094488D65A098935426CD1@PGSMSX112.gar.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Kai" <kai.huang@intel.com>
Cc: "dhowells@redhat.com" <dhowells@redhat.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "Nakajima, Jun" <jun.nakajima@intel.com>, "Shutemov, Kirill" <kirill.shutemov@intel.com>, "Hansen, Dave" <dave.hansen@intel.com>, "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>, "jmorris@namei.org" <jmorris@namei.org>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Sep 10, 2018 at 04:37:01PM -0700, Huang, Kai wrote:
> > -----Original Message-----
> > From: owner-linux-security-module@vger.kernel.org [mailto:owner-linux-
> > security-module@vger.kernel.org] On Behalf Of Huang, Kai
> > Sent: Monday, September 10, 2018 2:57 PM
> > To: Schofield, Alison <alison.schofield@intel.com>; dhowells@redhat.com;
> > tglx@linutronix.de
> > Cc: Nakajima, Jun <jun.nakajima@intel.com>; Shutemov, Kirill
> > <kirill.shutemov@intel.com>; Hansen, Dave <dave.hansen@intel.com>;
> > Sakkinen, Jarkko <jarkko.sakkinen@intel.com>; jmorris@namei.org;
> > keyrings@vger.kernel.org; linux-security-module@vger.kernel.org;
> > mingo@redhat.com; hpa@zytor.com; x86@kernel.org; linux-mm@kvack.org
> > Subject: RE: [RFC 04/12] x86/mm: Add helper functions to manage memory
> > encryption keys
> > 
> > 
> > > -----Original Message-----
> > > From: owner-linux-security-module@vger.kernel.org [mailto:owner-linux-
> > > security-module@vger.kernel.org] On Behalf Of Alison Schofield
> > > Sent: Saturday, September 8, 2018 10:36 AM
> > > To: dhowells@redhat.com; tglx@linutronix.de
> > > Cc: Huang, Kai <kai.huang@intel.com>; Nakajima, Jun
> > > <jun.nakajima@intel.com>; Shutemov, Kirill
> > > <kirill.shutemov@intel.com>; Hansen, Dave <dave.hansen@intel.com>;
> > > Sakkinen, Jarkko <jarkko.sakkinen@intel.com>; jmorris@namei.org;
> > > keyrings@vger.kernel.org; linux-security-module@vger.kernel.org;
> > > mingo@redhat.com; hpa@zytor.com; x86@kernel.org; linux-mm@kvack.org
> > > Subject: [RFC 04/12] x86/mm: Add helper functions to manage memory
> > > encryption keys
> > >
> > > Define a global mapping structure to track the mapping of userspace
> > > keys to hardware keyids in MKTME (Multi-Key Total Memory Encryption).
> > > This data will be used for the memory encryption system call and the
> > > kernel key service API.
> > >
> > > Implement helper functions to access this mapping structure and make
> > > them visible to the MKTME Kernel Key Service: security/keys/mktme_keys
> > >
> > > Signed-off-by: Alison Schofield <alison.schofield@intel.com>
> > > ---
> > >  arch/x86/include/asm/mktme.h | 11 ++++++
> > >  arch/x86/mm/mktme.c          | 85
> > > ++++++++++++++++++++++++++++++++++++++++++++
> > >  2 files changed, 96 insertions(+)
> > 
> > Maybe it's better to put those changes to include/keys/mktme-type.h, and
> > security/keys/mktme_key.c? It seems you don't have to involve linux-mm and
> > x86 guys by doing so?
> > 
> > Thanks,
> > -Kai
> > >
> > > diff --git a/arch/x86/include/asm/mktme.h
> > > b/arch/x86/include/asm/mktme.h index dbfbd955da98..f6acd551457f 100644
> > > --- a/arch/x86/include/asm/mktme.h
> > > +++ b/arch/x86/include/asm/mktme.h
> > > @@ -13,6 +13,17 @@ extern phys_addr_t mktme_keyid_mask;  extern int
> > > mktme_nr_keyids;  extern int mktme_keyid_shift;
> > >
> > > +/* Manage mappings between hardware keyids and userspace keys */
> > > +extern int mktme_map_alloc(void); extern void mktme_map_free(void);
> > > +extern void mktme_map_lock(void); extern void mktme_map_unlock(void);
> > > +extern int mktme_map_get_free_keyid(void); extern void
> > > +mktme_map_clear_keyid(int keyid); extern void mktme_map_set_keyid(int
> > > +keyid, unsigned int serial); extern int
> > > +mktme_map_keyid_from_serial(unsigned int serial); extern unsigned int
> > > +mktme_map_serial_from_keyid(int keyid);
> > > +
> > >  extern struct page_ext_operations page_mktme_ops;
> > >
> > >  #define page_keyid page_keyid
> > > diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c index
> > > 660caf6a5ce1..5246d8323359 100644
> > > --- a/arch/x86/mm/mktme.c
> > > +++ b/arch/x86/mm/mktme.c
> > > @@ -63,6 +63,91 @@ int vma_keyid(struct vm_area_struct *vma)
> > >  	return (prot & mktme_keyid_mask) >> mktme_keyid_shift;  }
> > >
> > > +/*
> > > + * struct mktme_mapping and the mktme_map_* functions manage the
> > > +mapping
> > > + * of userspace keys to hardware keyids in MKTME. They are used by
> > > +the
> > > + * the encrypt_mprotect system call and the MKTME Key Service API.
> > > + */
> > > +struct mktme_mapping {
> > > +	struct mutex	lock;		/* protect this map & HW state */
> > > +	unsigned int	mapped_keyids;
> > > +	unsigned int	serial[];
> > > +};
> 
> Sorry one more comment that I missed yesterday:
> 
> I think 'key_serial_t' should be used  as type of serial throughout this patch, but not 'unsigned int'. 
> 
> Thanks,
> -Kai

I agree! It's not an oversight, but rather a header file include nightmare.
I can look at it again.
