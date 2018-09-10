Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0A6E48E0001
	for <linux-mm@kvack.org>; Sun,  9 Sep 2018 21:46:26 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 186-v6so9834770pgc.12
        for <linux-mm@kvack.org>; Sun, 09 Sep 2018 18:46:25 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 21-v6si15602418pfy.169.2018.09.09.18.46.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Sep 2018 18:46:24 -0700 (PDT)
From: "Huang, Kai" <kai.huang@intel.com>
Subject: RE: [RFC 10/12] x86/pconfig: Program memory encryption keys on a
 system-wide basis
Date: Mon, 10 Sep 2018 01:46:20 +0000
Message-ID: <105F7BF4D0229846AF094488D65A0989354249D2@PGSMSX112.gar.corp.intel.com>
References: <cover.1536356108.git.alison.schofield@intel.com>
 <0947e4ad711e8b7c1f581a446e808f514620b49b.1536356108.git.alison.schofield@intel.com>
In-Reply-To: <0947e4ad711e8b7c1f581a446e808f514620b49b.1536356108.git.alison.schofield@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Schofield, Alison" <alison.schofield@intel.com>, "dhowells@redhat.com" <dhowells@redhat.com>, "tglx@linutronix.de" <tglx@linutronix.de>
Cc: "Nakajima, Jun" <jun.nakajima@intel.com>, "Shutemov, Kirill" <kirill.shutemov@intel.com>, "Hansen, Dave" <dave.hansen@intel.com>, "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>, "jmorris@namei.org" <jmorris@namei.org>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>


> -----Original Message-----
> From: Schofield, Alison
> Sent: Saturday, September 8, 2018 10:38 AM
> To: dhowells@redhat.com; tglx@linutronix.de
> Cc: Huang, Kai <kai.huang@intel.com>; Nakajima, Jun
> <jun.nakajima@intel.com>; Shutemov, Kirill <kirill.shutemov@intel.com>;
> Hansen, Dave <dave.hansen@intel.com>; Sakkinen, Jarkko
> <jarkko.sakkinen@intel.com>; jmorris@namei.org; keyrings@vger.kernel.org;
> linux-security-module@vger.kernel.org; mingo@redhat.com; hpa@zytor.com;
> x86@kernel.org; linux-mm@kvack.org
> Subject: [RFC 10/12] x86/pconfig: Program memory encryption keys on a
> system-wide basis
>=20
> The kernel manages the MKTME (Multi-Key Total Memory Encryption) Keys as =
a
> system wide single pool of keys. The hardware, however, manages the keys =
on a
> per physical package basis. Each physical package maintains a key table t=
hat all
> CPU's in that package share.
>=20
> In order to maintain the consistent, system wide view that the kernel req=
uires,
> program all physical packages during a key program request.
>=20
> Signed-off-by: Alison Schofield <alison.schofield@intel.com>
> ---
>  arch/x86/include/asm/intel_pconfig.h | 42
> ++++++++++++++++++++++++++++++------
>  1 file changed, 36 insertions(+), 6 deletions(-)
>=20
> diff --git a/arch/x86/include/asm/intel_pconfig.h
> b/arch/x86/include/asm/intel_pconfig.h
> index 3cb002b1d0f9..d3bf0a297e89 100644
> --- a/arch/x86/include/asm/intel_pconfig.h
> +++ b/arch/x86/include/asm/intel_pconfig.h
> @@ -3,6 +3,7 @@
>=20
>  #include <asm/asm.h>
>  #include <asm/processor.h>
> +#include <linux/cpu.h>
>=20
>  enum pconfig_target {
>  	INVALID_TARGET	=3D 0,
> @@ -47,19 +48,48 @@ struct mktme_key_program {
>  	u8 key_field_2[64];
>  } __packed __aligned(256);
>=20
> -static inline int mktme_key_program(struct mktme_key_program
> *key_program)
> +struct mktme_key_program_info {
> +	struct mktme_key_program *key_program;
> +	unsigned long status;
> +};
> +
> +static void mktme_package_program(void *key_program_info)
>  {
> +	struct mktme_key_program_info *info =3D key_program_info;
>  	unsigned long rax =3D MKTME_KEY_PROGRAM;
>=20
> +	asm volatile(PCONFIG
> +		: "=3Da" (rax), "=3Db" (info->key_program)

Why do we need "=3Db" (info->key_program)? To me PCONFIG only reads from rb=
x, but won't write to it.

> +		: "0" (rax), "1" (info->key_program)
> +		: "memory", "cc");
> +
> +	if (rax !=3D MKTME_PROG_SUCCESS)
> +		WRITE_ONCE(info->status, rax);
> +}
> +
> +/*
> + * MKTME keys are managed as a system-wide single pool of keys.
> + * In the hardware, each physical package maintains a separate key
> + * table. Program all physical packages with the same key info to
> + * maintain that system-wide kernel view.
> + */
> +static inline int mktme_key_program(struct mktme_key_program
> *key_program,
> +				    cpumask_var_t mktme_cpumask)
> +{
> +	struct mktme_key_program_info info =3D {
> +		.key_program =3D key_program,
> +		.status =3D MKTME_PROG_SUCCESS,
> +	};
> +
>  	if (!pconfig_target_supported(MKTME_TARGET))
>  		return -ENXIO;
>=20
> -	asm volatile(PCONFIG
> -		: "=3Da" (rax), "=3Db" (key_program)
> -		: "0" (rax), "1" (key_program)
> -		: "memory", "cc");
> +	get_online_cpus();
> +	on_each_cpu_mask(mktme_cpumask, mktme_package_program,
> +			 &info, 1);
> +	put_online_cpus();

What is the value of 'mktme_cpumask'? Does it only contain one core for eac=
h package?=20

Since we are using 'on_each_cpu_mask', I think  we should make sure only on=
e core is set for each node in 'mktme_cpumask'. Otherwise we have to deal w=
ith 'DEVICE_BUSY' case, since if one core is already in middle of PCONFIG, =
the other PCONFIGs on the same node would get 'DEVICE_BUSY' error, but this=
 doesn't mean PCONFIG has failed on that node.

Thanks,
-Kai
>=20
> -	return rax;
> +	return info.status;
>  }
>=20
>  #endif	/* _ASM_X86_INTEL_PCONFIG_H */
> --
> 2.14.1
