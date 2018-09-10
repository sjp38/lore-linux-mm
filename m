Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7B9A98E0001
	for <linux-mm@kvack.org>; Sun,  9 Sep 2018 23:29:35 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id v195-v6so10058356pgb.0
        for <linux-mm@kvack.org>; Sun, 09 Sep 2018 20:29:35 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id t31-v6si15894278pga.167.2018.09.09.20.29.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Sep 2018 20:29:33 -0700 (PDT)
From: "Huang, Kai" <kai.huang@intel.com>
Subject: RE: [RFC 11/12] keys/mktme: Add a new key service type for memory
 encryption keys
Date: Mon, 10 Sep 2018 03:29:29 +0000
Message-ID: <105F7BF4D0229846AF094488D65A098935424C2D@PGSMSX112.gar.corp.intel.com>
References: <cover.1536356108.git.alison.schofield@intel.com>
 <1a14a6feb02f968c5e6b98360f6f16106b633b58.1536356108.git.alison.schofield@intel.com>
In-Reply-To: <1a14a6feb02f968c5e6b98360f6f16106b633b58.1536356108.git.alison.schofield@intel.com>
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
> Sent: Saturday, September 8, 2018 10:39 AM
> To: dhowells@redhat.com; tglx@linutronix.de
> Cc: Huang, Kai <kai.huang@intel.com>; Nakajima, Jun
> <jun.nakajima@intel.com>; Shutemov, Kirill <kirill.shutemov@intel.com>;
> Hansen, Dave <dave.hansen@intel.com>; Sakkinen, Jarkko
> <jarkko.sakkinen@intel.com>; jmorris@namei.org; keyrings@vger.kernel.org;
> linux-security-module@vger.kernel.org; mingo@redhat.com; hpa@zytor.com;
> x86@kernel.org; linux-mm@kvack.org
> Subject: [RFC 11/12] keys/mktme: Add a new key service type for memory
> encryption keys
>=20
> MKTME (Multi-Key Total Memory Encryption) is a technology that allows
> transparent memory encryption in upcoming Intel platforms. MKTME will
> support mulitple encryption domains, each having their own key. The main =
use
> case for the feature is virtual machine isolation. The API needs the flex=
ibility to
> work for a wide range of uses.
>=20
> The MKTME key service type manages the addition and removal of the memory
> encryption keys. It maps software keys to hardware keyids and programs th=
e
> hardware with the user requested encryption options.
>=20
> The only supported encryption algorithm is AES-XTS 128.
>=20
> The MKTME key service is half of the MKTME API level solution. It pairs w=
ith a
> new memory encryption system call: encrypt_mprotect() that uses the keys =
to
> encrypt memory.
>=20
> See Documentation/x86/mktme-keys.txt
>=20
> Signed-off-by: Alison Schofield <alison.schofield@intel.com>
> ---
>  arch/x86/Kconfig           |   1 +
>  include/keys/mktme-type.h  |  28 +++++
>  security/keys/Kconfig      |  11 ++
>  security/keys/Makefile     |   1 +
>  security/keys/mktme_keys.c | 278
> +++++++++++++++++++++++++++++++++++++++++++++
>  5 files changed, 319 insertions(+)
>  create mode 100644 include/keys/mktme-type.h  create mode 100644
> security/keys/mktme_keys.c
>=20
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig index
> 023a22568c06..50d8aa6a58e9 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -1527,6 +1527,7 @@ config X86_INTEL_MKTME
>  	bool "Intel Multi-Key Total Memory Encryption"
>  	select DYNAMIC_PHYSICAL_MASK
>  	select PAGE_EXTENSION
> +	select MKTME_KEYS
>  	depends on X86_64 && CPU_SUP_INTEL
>  	---help---
>  	  Say yes to enable support for Multi-Key Total Memory Encryption.
> diff --git a/include/keys/mktme-type.h b/include/keys/mktme-type.h new fi=
le
> mode 100644 index 000000000000..bebe74cb2b51
> --- /dev/null
> +++ b/include/keys/mktme-type.h
> @@ -0,0 +1,28 @@
> +/* SPDX-License-Identifier: GPL-2.0 */
> +
> +/*
> + * Key service for Multi-KEY Total Memory Encryption  */
> +
> +#ifndef _KEYS_MKTME_TYPE_H
> +#define _KEYS_MKTME_TYPE_H
> +
> +#include <linux/key.h>
> +
> +/*
> + * The AES-XTS 128 encryption algorithm requires 128 bits for each
> + * user supplied option: userkey=3D, tweak=3D, entropy=3D.
> + */
> +#define MKTME_AES_XTS_SIZE	16
> +
> +enum mktme_alg {
> +	MKTME_ALG_AES_XTS_128,
> +};
> +
> +const char *const mktme_alg_names[] =3D {
> +	[MKTME_ALG_AES_XTS_128]	=3D "aes_xts_128",
> +};
> +
> +extern struct key_type key_type_mktme;
> +
> +#endif /* _KEYS_MKTME_TYPE_H */
> diff --git a/security/keys/Kconfig b/security/keys/Kconfig index
> 6462e6654ccf..c36972113e67 100644
> --- a/security/keys/Kconfig
> +++ b/security/keys/Kconfig
> @@ -101,3 +101,14 @@ config KEY_DH_OPERATIONS
>  	 in the kernel.
>=20
>  	 If you are unsure as to whether this is required, answer N.
> +
> +config MKTME_KEYS
> +	bool "Multi-Key Total Memory Encryption Keys"
> +	depends on KEYS && X86_INTEL_MKTME
> +	help
> +	  This option provides support for Multi-Key Total Memory
> +	  Encryption (MKTME) on Intel platforms offering the feature.
> +	  MKTME allows userspace to manage the hardware encryption
> +	  keys through the kernel key services.
> +
> +	  If you are unsure as to whether this is required, answer N.
> diff --git a/security/keys/Makefile b/security/keys/Makefile index
> ef1581b337a3..2d9f9a82cb8a 100644
> --- a/security/keys/Makefile
> +++ b/security/keys/Makefile
> @@ -29,3 +29,4 @@ obj-$(CONFIG_KEY_DH_OPERATIONS) +=3D dh.o
>  obj-$(CONFIG_BIG_KEYS) +=3D big_key.o
>  obj-$(CONFIG_TRUSTED_KEYS) +=3D trusted.o
>  obj-$(CONFIG_ENCRYPTED_KEYS) +=3D encrypted-keys/
> +obj-$(CONFIG_MKTME_KEYS) +=3D mktme_keys.o
> diff --git a/security/keys/mktme_keys.c b/security/keys/mktme_keys.c new =
file
> mode 100644 index 000000000000..dcbce7194647
> --- /dev/null
> +++ b/security/keys/mktme_keys.c
> @@ -0,0 +1,278 @@
> +// SPDX-License-Identifier: GPL-3.0
> +
> +/* Documentation/x86/mktme-keys.txt */
> +
> +#include <linux/cred.h>
> +#include <linux/cpu.h>
> +#include <linux/err.h>
> +#include <linux/init.h>
> +#include <linux/key.h>
> +#include <linux/key-type.h>
> +#include <linux/init.h>
> +#include <linux/parser.h>
> +#include <linux/slab.h>
> +#include <linux/string.h>
> +#include <asm/intel_pconfig.h>
> +#include <asm/mktme.h>
> +#include <keys/mktme-type.h>
> +#include <keys/user-type.h>
> +
> +#include "internal.h"
> +
> +struct kmem_cache *mktme_prog_cache;	/* hardware programming
> struct */
> +cpumask_var_t mktme_cpumask;		/* one cpu per pkg to program
> keys */

Oh the 'mktme_cpumask' is here. Sorry I didn't notice when replying to your=
 patch 10. :)

But I think you can just move what you did in patch 10 here and leave intel=
_pconfig.h unchanged. It's much clearer.=20

> +
> +static const char * const mktme_program_err[] =3D {
> +	"KeyID was successfully programmed",	/* 0 */
> +	"Invalid KeyID programming command",	/* 1 */
> +	"Insufficient entropy",			/* 2 */
> +	"KeyID not valid",			/* 3 */
> +	"Invalid encryption algorithm chosen",	/* 4 */
> +	"Failure to access key table",		/* 5 */
> +};
> +
> +/* If a key is available, program and add the key to the software map.
> +*/ static int mktme_program_key(key_serial_t serial,
> +			     struct mktme_key_program *kprog) {
> +	int keyid, ret;
> +
> +	keyid =3D mktme_map_get_free_keyid();
> +	if (keyid =3D=3D 0)
> +		return -EDQUOT;
> +
> +	kprog->keyid =3D keyid;
> +	ret =3D mktme_key_program(kprog, mktme_cpumask);
> +	if (ret =3D=3D MKTME_PROG_SUCCESS)
> +		mktme_map_set_keyid(keyid, serial);
> +	else
> +		pr_debug("mktme: %s [%d]\n", mktme_program_err[ret], ret);
> +
> +	return ret;
> +}
> +
> +enum mktme_opt_id	{
> +	OPT_ERROR =3D -1,
> +	OPT_USERKEY,
> +	OPT_TWEAK,
> +	OPT_ENTROPY,
> +	OPT_ALGORITHM,
> +};
> +
> +static const match_table_t mktme_token =3D {
> +	{OPT_USERKEY, "userkey=3D%s"},
> +	{OPT_TWEAK, "tweak=3D%s"},
> +	{OPT_ENTROPY, "entropy=3D%s"},
> +	{OPT_ALGORITHM, "algorithm=3D%s"},
> +	{OPT_ERROR, NULL}
> +
> +};
> +
> +/*
> + * Algorithm AES-XTS 128 is the only supported encryption algorithm.
> + * CPU Generated Key: requires user supplied entropy and accepts no
> + *		      other options.
> + * User Supplied Key: requires user supplied tweak key and accepts
> + *		      no other options.
> + */
> +static int mktme_check_options(struct mktme_key_program *kprog,
> +			       unsigned long token_mask)
> +{
> +	if (!token_mask)
> +		return -EINVAL;
> +
> +	kprog->keyid_ctrl |=3D MKTME_AES_XTS_128;
> +
> +	if (!test_bit(OPT_USERKEY, &token_mask)) {
> +		if ((!test_bit(OPT_ENTROPY, &token_mask)) ||
> +		    (test_bit(OPT_TWEAK, &token_mask)))
> +			return -EINVAL;
> +
> +		kprog->keyid_ctrl |=3D MKTME_KEYID_SET_KEY_RANDOM;
> +	}
> +	if (test_bit(OPT_USERKEY, &token_mask)) {
> +		if ((test_bit(OPT_ENTROPY, &token_mask)) ||
> +		    (!test_bit(OPT_TWEAK, &token_mask)))
> +			return -EINVAL;
> +
> +		kprog->keyid_ctrl |=3D MKTME_KEYID_SET_KEY_DIRECT;
> +	}
> +	return 0;
> +}
> +
> +/*
> + * Parse the options and begin to fill in the key programming struct kpr=
og.
> + * Check the lengths of incoming data and push data directly into kprog =
fields.
> + */
> +static int mktme_get_options(char *options, struct mktme_key_program
> +*kprog) {
> +	int len =3D MKTME_AES_XTS_SIZE / 2;
> +	substring_t args[MAX_OPT_ARGS];
> +	unsigned long token_mask =3D 0;
> +	enum mktme_alg alg;
> +	char *p =3D options;
> +	int ret, token;
> +
> +	while ((p =3D strsep(&options, " \t"))) {
> +		if (*p =3D=3D '\0' || *p =3D=3D ' ' || *p =3D=3D '\t')
> +			continue;
> +		token =3D match_token(p, mktme_token, args);
> +		if (test_and_set_bit(token, &token_mask))
> +			return -EINVAL;
> +
> +		switch (token) {
> +		case OPT_USERKEY:
> +			if (strlen(args[0].from) !=3D MKTME_AES_XTS_SIZE)
> +				return -EINVAL;
> +			ret =3D hex2bin(kprog->key_field_1, args[0].from, len);
> +			if (ret < 0)
> +				return -EINVAL;
> +			break;
> +
> +		case OPT_TWEAK:
> +			if (strlen(args[0].from) !=3D MKTME_AES_XTS_SIZE)
> +				return -EINVAL;
> +			ret =3D hex2bin(kprog->key_field_2, args[0].from, len);
> +			if (ret < 0)
> +				return -EINVAL;
> +			break;
> +
> +		case OPT_ENTROPY:
> +			if (strlen(args[0].from) !=3D MKTME_AES_XTS_SIZE)
> +				return -EINVAL;
> +			/* Applied to both CPU-generated data and tweak keys
> */
> +			ret =3D hex2bin(kprog->key_field_1, args[0].from, len);
> +			ret =3D hex2bin(kprog->key_field_2, args[0].from, len);
> +			if (ret < 0)
> +				return -EINVAL;
> +			break;

I replied w/ some comments in patch 1 (Document part). Do you have any part=
icular reason to introduce OPT_ENTROPY, while we can simply use OPT_USERKEY=
 and OPT_TWEAK?

Actually I think it might be better that we disallow or ignore OPT_USERKEY,=
 OPT_TWEAK (or OPT_ENTROPY in your patch). Please see my reply to your patc=
h 1.

> +
> +		case OPT_ALGORITHM:
> +			alg =3D match_string(mktme_alg_names,
> +					   ARRAY_SIZE(mktme_alg_names),
> +					   args[0].from);
> +			if (alg !=3D MKTME_ALG_AES_XTS_128)
> +				return -EINVAL;
> +			break;
> +
> +		default:
> +			return -EINVAL;
> +		}
> +	}
> +	return mktme_check_options(kprog, token_mask); }
> +
> +/* Key Service Command: Creates a software key and programs hardware */
> +int mktme_instantiate(struct key *key, struct key_preparsed_payload
> +*prep) {
> +	struct mktme_key_program *kprog =3D NULL;
> +	size_t datalen =3D prep->datalen;
> +	char *options;
> +	int ret =3D 0;
> +
> +	if (!capable(CAP_SYS_RESOURCE) && !capable(CAP_SYS_ADMIN))
> +		return -EACCES;
> +
> +	if (datalen <=3D 0 || datalen > 1024 || !prep->data)
> +		return -EINVAL;
> +
> +	options =3D kmemdup(prep->data, datalen + 1, GFP_KERNEL);
> +	if (!options)
> +		return -ENOMEM;
> +
> +	options[datalen] =3D '\0';
> +
> +	kprog =3D kmem_cache_zalloc(mktme_prog_cache, GFP_KERNEL);
> +	if (!kprog) {
> +		kzfree(options);
> +		return -ENOMEM;
> +	}
> +	ret =3D mktme_get_options(options, kprog);
> +	if (ret < 0)
> +		goto out;
> +
> +	mktme_map_lock();
> +	ret =3D mktme_program_key(key->serial, kprog);
> +	mktme_map_unlock();
> +out:
> +	kzfree(options);
> +	kmem_cache_free(mktme_prog_cache, kprog);
> +	return ret;
> +}
> +
> +struct key_type key_type_mktme =3D {
> +	.name =3D "mktme",
> +	.instantiate =3D mktme_instantiate,
> +	.describe =3D user_describe,
> +};
> +
> +/*
> + * Build mktme_cpumask to include one cpu per physical package.
> + * The mask is used in mktme_key_program() when the hardware key
> + * table is programmed on a per package basis.
> + */
> +static int mktme_build_cpumask(void)
> +{
> +	int online_cpu, mktme_cpu;
> +	int online_pkgid, mktme_pkgid =3D -1;
> +
> +	if (!zalloc_cpumask_var(&mktme_cpumask, GFP_KERNEL))
> +		return -ENOMEM;
> +
> +	for_each_online_cpu(online_cpu) {
> +		online_pkgid =3D topology_physical_package_id(online_cpu);
> +
> +		for_each_cpu(mktme_cpu, mktme_cpumask) {
> +			mktme_pkgid =3D
> topology_physical_package_id(mktme_cpu);
> +			if (mktme_pkgid =3D=3D online_pkgid)
> +				break;
> +		}
> +		if (mktme_pkgid !=3D online_pkgid)
> +			cpumask_set_cpu(online_cpu, mktme_cpumask);
> +	}

Could we use 'for_each_online_node', 'cpumask_first/next', etc to simplify =
the logic?

> +	return 0;
> +}
> +
> +/*
> + * Allocate the global key map structure based on the available keyids
> + * at boot time. Create a cache and a cpu_mask to use for programming
> + * the hardware. Initialize the encrypt_count array to track VMA's per
> + * keyid. Once all that succeeds, register the 'mktme' key type.
> + */
> +static int __init init_mktme(void)
> +{
> +	int ret;
> +
> +	/* Verify keys are present */
> +	if (!(mktme_nr_keyids > 0))
> +		return -EINVAL;
> +
> +	if (!mktme_map_alloc())
> +		return -ENOMEM;
> +
> +	mktme_prog_cache =3D KMEM_CACHE(mktme_key_program,
> SLAB_PANIC);
> +	if (!mktme_prog_cache)
> +		goto free_map;
> +
> +	if (vma_alloc_encrypt_array() < 0)
> +		goto free_cache;

I think it's better to move 'vma_alloc_encrypt_array' part to this patch. P=
lease see my reply to your patch 7.

I also think we should avoid adding new staff to arch/x86/include/asm/mktme=
.h since it is included by some basic page table manipulation header files.=
 Adding mm related structure to asm/mktme.h sometimes may fail to compile k=
ernel in my experience.

Thanks,
-Kai
> +
> +	if (mktme_build_cpumask() < 0)
> +		goto free_array;
> +
> +	ret =3D register_key_type(&key_type_mktme);
> +	if (!ret)
> +		return ret;
> +
> +	free_cpumask_var(mktme_cpumask);
> +free_array:
> +	vma_free_encrypt_array();
> +free_cache:
> +	kmem_cache_destroy(mktme_prog_cache);
> +free_map:
> +	mktme_map_free();
> +
> +	return -ENOMEM;
> +}
> +
> +late_initcall(init_mktme);
> --
> 2.14.1
