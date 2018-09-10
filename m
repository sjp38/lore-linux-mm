Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 565128E0001
	for <linux-mm@kvack.org>; Sun,  9 Sep 2018 22:57:07 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 3-v6so9401333plq.6
        for <linux-mm@kvack.org>; Sun, 09 Sep 2018 19:57:07 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id l5-v6si16320017pgb.234.2018.09.09.19.57.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Sep 2018 19:57:05 -0700 (PDT)
From: "Huang, Kai" <kai.huang@intel.com>
Subject: RE: [RFC 04/12] x86/mm: Add helper functions to manage memory
 encryption keys
Date: Mon, 10 Sep 2018 02:56:34 +0000
Message-ID: <105F7BF4D0229846AF094488D65A098935424B67@PGSMSX112.gar.corp.intel.com>
References: <cover.1536356108.git.alison.schofield@intel.com>
 <28a55df5da1ecfea28bac588d3ac429cf1419b42.1536356108.git.alison.schofield@intel.com>
In-Reply-To: <28a55df5da1ecfea28bac588d3ac429cf1419b42.1536356108.git.alison.schofield@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Schofield, Alison" <alison.schofield@intel.com>, "dhowells@redhat.com" <dhowells@redhat.com>, "tglx@linutronix.de" <tglx@linutronix.de>
Cc: "Nakajima, Jun" <jun.nakajima@intel.com>, "Shutemov, Kirill" <kirill.shutemov@intel.com>, "Hansen, Dave" <dave.hansen@intel.com>, "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>, "jmorris@namei.org" <jmorris@namei.org>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>


> -----Original Message-----
> From: owner-linux-security-module@vger.kernel.org [mailto:owner-linux-
> security-module@vger.kernel.org] On Behalf Of Alison Schofield
> Sent: Saturday, September 8, 2018 10:36 AM
> To: dhowells@redhat.com; tglx@linutronix.de
> Cc: Huang, Kai <kai.huang@intel.com>; Nakajima, Jun
> <jun.nakajima@intel.com>; Shutemov, Kirill <kirill.shutemov@intel.com>;
> Hansen, Dave <dave.hansen@intel.com>; Sakkinen, Jarkko
> <jarkko.sakkinen@intel.com>; jmorris@namei.org; keyrings@vger.kernel.org;
> linux-security-module@vger.kernel.org; mingo@redhat.com; hpa@zytor.com;
> x86@kernel.org; linux-mm@kvack.org
> Subject: [RFC 04/12] x86/mm: Add helper functions to manage memory
> encryption keys
>=20
> Define a global mapping structure to track the mapping of userspace keys =
to
> hardware keyids in MKTME (Multi-Key Total Memory Encryption).
> This data will be used for the memory encryption system call and the kern=
el key
> service API.
>=20
> Implement helper functions to access this mapping structure and make them
> visible to the MKTME Kernel Key Service: security/keys/mktme_keys
>=20
> Signed-off-by: Alison Schofield <alison.schofield@intel.com>
> ---
>  arch/x86/include/asm/mktme.h | 11 ++++++
>  arch/x86/mm/mktme.c          | 85
> ++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 96 insertions(+)

Maybe it's better to put those changes to include/keys/mktme-type.h, and se=
curity/keys/mktme_key.c? It seems you don't have to involve linux-mm and x8=
6 guys by doing so?

Thanks,
-Kai
>=20
> diff --git a/arch/x86/include/asm/mktme.h b/arch/x86/include/asm/mktme.h
> index dbfbd955da98..f6acd551457f 100644
> --- a/arch/x86/include/asm/mktme.h
> +++ b/arch/x86/include/asm/mktme.h
> @@ -13,6 +13,17 @@ extern phys_addr_t mktme_keyid_mask;  extern int
> mktme_nr_keyids;  extern int mktme_keyid_shift;
>=20
> +/* Manage mappings between hardware keyids and userspace keys */ extern
> +int mktme_map_alloc(void); extern void mktme_map_free(void); extern
> +void mktme_map_lock(void); extern void mktme_map_unlock(void); extern
> +int mktme_map_get_free_keyid(void); extern void
> +mktme_map_clear_keyid(int keyid); extern void mktme_map_set_keyid(int
> +keyid, unsigned int serial); extern int
> +mktme_map_keyid_from_serial(unsigned int serial); extern unsigned int
> +mktme_map_serial_from_keyid(int keyid);
> +
>  extern struct page_ext_operations page_mktme_ops;
>=20
>  #define page_keyid page_keyid
> diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c index
> 660caf6a5ce1..5246d8323359 100644
> --- a/arch/x86/mm/mktme.c
> +++ b/arch/x86/mm/mktme.c
> @@ -63,6 +63,91 @@ int vma_keyid(struct vm_area_struct *vma)
>  	return (prot & mktme_keyid_mask) >> mktme_keyid_shift;  }
>=20
> +/*
> + * struct mktme_mapping and the mktme_map_* functions manage the
> +mapping
> + * of userspace keys to hardware keyids in MKTME. They are used by the
> + * the encrypt_mprotect system call and the MKTME Key Service API.
> + */
> +struct mktme_mapping {
> +	struct mutex	lock;		/* protect this map & HW state */
> +	unsigned int	mapped_keyids;
> +	unsigned int	serial[];
> +};
> +
> +struct mktme_mapping *mktme_map;
> +
> +static inline long mktme_map_size(void) {
> +	long size =3D 0;
> +
> +	size +=3D sizeof(mktme_map);
> +	size +=3D sizeof(mktme_map->serial[0]) * mktme_nr_keyids;
> +	return size;
> +}
> +
> +int mktme_map_alloc(void)
> +{
> +	mktme_map =3D kzalloc(mktme_map_size(), GFP_KERNEL);
> +	if (!mktme_map)
> +		return 0;
> +	mutex_init(&mktme_map->lock);
> +	return 1;
> +}
> +
> +void mktme_map_free(void)
> +{
> +	kfree(mktme_map);
> +}
> +
> +void mktme_map_lock(void)
> +{
> +	mutex_lock(&mktme_map->lock);
> +}
> +
> +void mktme_map_unlock(void)
> +{
> +	mutex_unlock(&mktme_map->lock);
> +}
> +
> +void mktme_map_set_keyid(int keyid, unsigned int serial) {
> +	mktme_map->serial[keyid] =3D serial;
> +	mktme_map->mapped_keyids++;
> +}
> +
> +void mktme_map_clear_keyid(int keyid)
> +{
> +	mktme_map->serial[keyid] =3D 0;
> +	mktme_map->mapped_keyids--;
> +}
> +
> +unsigned int mktme_map_serial_from_keyid(int keyid) {
> +	return mktme_map->serial[keyid];
> +}
> +
> +int mktme_map_keyid_from_serial(unsigned int serial) {
> +	int i;
> +
> +	for (i =3D 1; i < mktme_nr_keyids; i++)
> +		if (mktme_map->serial[i] =3D=3D serial)
> +			return i;
> +	return 0;
> +}
> +
> +int mktme_map_get_free_keyid(void)
> +{
> +	int i;
> +
> +	if (mktme_map->mapped_keyids < mktme_nr_keyids) {
> +		for (i =3D 1; i < mktme_nr_keyids; i++)
> +			if (mktme_map->serial[i] =3D=3D 0)
> +				return i;
> +	}
> +	return 0;
> +}
> +
>  void prep_encrypted_page(struct page *page, int order, int keyid, bool z=
ero)  {
>  	int i;
> --
> 2.14.1
