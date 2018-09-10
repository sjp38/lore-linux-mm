Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0A8128E0001
	for <linux-mm@kvack.org>; Sun,  9 Sep 2018 23:18:22 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id o27-v6so10505424pfj.6
        for <linux-mm@kvack.org>; Sun, 09 Sep 2018 20:18:22 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id r20-v6si8119102pgk.207.2018.09.09.20.18.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Sep 2018 20:18:20 -0700 (PDT)
From: "Huang, Kai" <kai.huang@intel.com>
Subject: RE: [RFC 07/12] x86/mm: Add helper functions to track encrypted
 VMA's
Date: Mon, 10 Sep 2018 03:17:52 +0000
Message-ID: <105F7BF4D0229846AF094488D65A098935424BDA@PGSMSX112.gar.corp.intel.com>
References: <cover.1536356108.git.alison.schofield@intel.com>
 <d98252fe105f2e948e2f585914a61b32c1902889.1536356108.git.alison.schofield@intel.com>
In-Reply-To: <d98252fe105f2e948e2f585914a61b32c1902889.1536356108.git.alison.schofield@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Schofield, Alison" <alison.schofield@intel.com>, "dhowells@redhat.com" <dhowells@redhat.com>, "tglx@linutronix.de" <tglx@linutronix.de>
Cc: "Nakajima, Jun" <jun.nakajima@intel.com>, "Shutemov, Kirill" <kirill.shutemov@intel.com>, "Hansen, Dave" <dave.hansen@intel.com>, "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>, "jmorris@namei.org" <jmorris@namei.org>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

> -----Original Message-----
> From: keyrings-owner@vger.kernel.org [mailto:keyrings-
> owner@vger.kernel.org] On Behalf Of Alison Schofield
> Sent: Saturday, September 8, 2018 10:37 AM
> To: dhowells@redhat.com; tglx@linutronix.de
> Cc: Huang, Kai <kai.huang@intel.com>; Nakajima, Jun
> <jun.nakajima@intel.com>; Shutemov, Kirill <kirill.shutemov@intel.com>;
> Hansen, Dave <dave.hansen@intel.com>; Sakkinen, Jarkko
> <jarkko.sakkinen@intel.com>; jmorris@namei.org; keyrings@vger.kernel.org;
> linux-security-module@vger.kernel.org; mingo@redhat.com; hpa@zytor.com;
> x86@kernel.org; linux-mm@kvack.org
> Subject: [RFC 07/12] x86/mm: Add helper functions to track encrypted VMA'=
s
>=20
> In order to safely manage the usage of memory encryption keys, VMA's usin=
g
> each keyid need to be tracked. This tracking allows the Kernel Key Servic=
e to
> know when the keyid resource is actually in use, or when it is idle and m=
ay be
> considered for reuse.
>=20
> Define a global atomic encrypt_count array to track the number of VMA's
> oustanding for each encryption keyid.
>=20
> Implement helper functions to manipulate this encrypt_count array.
>=20
> Signed-off-by: Alison Schofield <alison.schofield@intel.com>
> ---
>  arch/x86/include/asm/mktme.h |  7 +++++++
>  arch/x86/mm/mktme.c          | 39
> +++++++++++++++++++++++++++++++++++++++
>  include/linux/mm.h           |  2 ++
>  3 files changed, 48 insertions(+)
>=20
> diff --git a/arch/x86/include/asm/mktme.h b/arch/x86/include/asm/mktme.h
> index b707f800b68f..5f3fa0c39c1c 100644
> --- a/arch/x86/include/asm/mktme.h
> +++ b/arch/x86/include/asm/mktme.h
> @@ -16,6 +16,13 @@ extern int mktme_keyid_shift;
>  /* Set the encryption keyid bits in a VMA */  extern void
> mprotect_set_encrypt(struct vm_area_struct *vma, int newkeyid);
>=20
> +/* Manage the references to outstanding VMA's per encryption key */
> +extern int vma_alloc_encrypt_array(void); extern void
> +vma_free_encrypt_array(void); extern int vma_read_encrypt_ref(int
> +keyid); extern void vma_get_encrypt_ref(struct vm_area_struct *vma);
> +extern void vma_put_encrypt_ref(struct vm_area_struct *vma);
> +
>  /* Manage mappings between hardware keyids and userspace keys */  extern
> int mktme_map_alloc(void);  extern void mktme_map_free(void); diff --git
> a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c index
> 5ee7f37e9cd0..5690ef51a79a 100644
> --- a/arch/x86/mm/mktme.c
> +++ b/arch/x86/mm/mktme.c
> @@ -163,6 +163,45 @@ int mktme_map_get_free_keyid(void)
>  	return 0;
>  }
>=20
> +/*
> + *  Helper functions manage the encrypt_count[] array that tracks the
> + *  VMA's outstanding for each encryption keyid. The gets & puts are
> + *  used in core mm code that allocates and free's VMA's. The alloc,
> + *  free, and read functions are used by the MKTME key service to
> + *  manage key allocation and programming.
> + */
> +atomic_t *encrypt_count;
> +
> +int vma_alloc_encrypt_array(void)
> +{
> +	encrypt_count =3D kcalloc(mktme_nr_keyids, sizeof(atomic_t),
> GFP_KERNEL);
> +	if (!encrypt_count)
> +		return -ENOMEM;
> +	return 0;
> +}
> +
> +void vma_free_encrypt_array(void)
> +{
> +	kfree(encrypt_count);
> +}
> +
> +int vma_read_encrypt_ref(int keyid)
> +{
> +	return atomic_read(&encrypt_count[keyid]);
> +}

I think it's better to move above to security/keys/mktme_keys.c w/ appropri=
ate renaming. =20

Thanks,
-Kai
> +
> +void vma_get_encrypt_ref(struct vm_area_struct *vma) {
> +	if (vma_keyid(vma))
> +		atomic_inc(&encrypt_count[vma_keyid(vma)]);
> +}
> +
> +void vma_put_encrypt_ref(struct vm_area_struct *vma) {
> +	if (vma_keyid(vma))
> +		atomic_dec(&encrypt_count[vma_keyid(vma)]);
> +}
> +
>  void prep_encrypted_page(struct page *page, int order, int keyid, bool z=
ero)  {
>  	int i;
> diff --git a/include/linux/mm.h b/include/linux/mm.h index
> 0f9422c7841e..b217c699dbab 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2803,6 +2803,8 @@ static inline void setup_nr_node_ids(void) {}  #ifn=
def
> CONFIG_X86_INTEL_MKTME  static inline void mprotect_set_encrypt(struct
> vm_area_struct *vma,
>  					int newkeyid) {}
> +static inline void vma_get_encrypt_ref(struct vm_area_struct *vma) {}
> +static inline void vma_put_encrypt_ref(struct vm_area_struct *vma) {}
>  #endif /* CONFIG_X86_INTEL_MKTME */
>  #endif /* __KERNEL__ */
>  #endif /* _LINUX_MM_H */
> --
> 2.14.1
