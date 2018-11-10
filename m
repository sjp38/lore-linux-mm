Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id A9A0F6B076A
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 21:50:49 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id i1-v6so3166508wrr.18
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 18:50:49 -0800 (PST)
Received: from mout.gmx.net (mout.gmx.net. [212.227.17.21])
        by mx.google.com with ESMTPS id h15-v6si2454047wmb.31.2018.11.09.18.50.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Nov 2018 18:50:48 -0800 (PST)
MIME-Version: 1.0
Message-ID: <trinity-d366cf7f-4a38-4193-a636-b695d34d6c47-1541817914119@msvc-mesg-gmx024>
From: "Qian Cai" <cai@gmx.us>
Subject: Re: [PATCH] efi: permit calling efi_mem_reserve_persistent from
 atomic context
Content-Type: text/plain; charset=UTF-8
Date: Sat, 10 Nov 2018 03:45:14 +0100
In-Reply-To: <20181108180511.30239-1-ard.biesheuvel@linaro.org>
References: <20181108180511.30239-1-ard.biesheuvel@linaro.org>
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-mm@kvack.org, linux-efi@vger.kernel.org, will.deacon@arm.com, linux-kernel@vger.kernel.org, marc.zyngier@arm.com, linux-arm-kernel@lists.infradead.org


On 11/8/18 at 1:05 PM, Ard Biesheuvel wrote:

> Currently, efi_mem_reserve_persistent() may not be called from atomic
> context, since both the kmalloc() call and the memremap() call may
> sleep=2E
>=20
> The kmalloc() call is easy enough to fix, but the memremap() call
> needs to be moved into an init hook since we cannot control the
> memory allocation behavior of memremap() at the call site=2E
>=20
> Signed-off-by: Ard Biesheuvel <ard=2Ebiesheuvel@linaro=2Eorg>
> ---
>  drivers/firmware/efi/efi=2Ec | 31 +++++++++++++++++++------------
>  1 file changed, 19 insertions(+), 12 deletions(-)
>=20
> diff --git a/drivers/firmware/efi/efi=2Ec b/drivers/firmware/efi/efi=2Ec
> index 249eb70691b0=2E=2Ecfc876e0b67b 100644
> --- a/drivers/firmware/efi/efi=2Ec
> +++ b/drivers/firmware/efi/efi=2Ec
> @@ -963,36 +963,43 @@ bool efi_is_table_address(unsigned long phys_addr)
>  }
> =20
>  static DEFINE_SPINLOCK(efi_mem_reserve_persistent_lock);
> +static struct linux_efi_memreserve *efi_memreserve_root __ro_after_init=
;
> =20
>  int efi_mem_reserve_persistent(phys_addr_t addr, u64 size)
>  {
> -	struct linux_efi_memreserve *rsv, *parent;
> +	struct linux_efi_memreserve *rsv;
> =20
> -	if (efi=2Emem_reserve =3D=3D EFI_INVALID_TABLE_ADDR)
> +	if (!efi_memreserve_root)
>  		return -ENODEV;
> =20
> -	rsv =3D kmalloc(sizeof(*rsv), GFP_KERNEL);
> +	rsv =3D kmalloc(sizeof(*rsv), GFP_ATOMIC);
>  	if (!rsv)
>  		return -ENOMEM;
> =20
> -	parent =3D memremap(efi=2Emem_reserve, sizeof(*rsv), MEMREMAP_WB);
> -	if (!parent) {
> -		kfree(rsv);
> -		return -ENOMEM;
> -	}
> -
>  	rsv->base =3D addr;
>  	rsv->size =3D size;
> =20
>  	spin_lock(&efi_mem_reserve_persistent_lock);
> -	rsv->next =3D parent->next;
> -	parent->next =3D __pa(rsv);
> +	rsv->next =3D efi_memreserve_root->next;
> +	efi_memreserve_root->next =3D __pa(rsv);
>  	spin_unlock(&efi_mem_reserve_persistent_lock);
> =20
> -	memunmap(parent);
> +	return 0;
> +}
> =20
> +static int __init efi_memreserve_root_init(void)
> +{
> +	if (efi=2Emem_reserve =3D=3D EFI_INVALID_TABLE_ADDR)
> +		return -ENODEV;
> +
> +	efi_memreserve_root =3D memremap(efi=2Emem_reserve,
> +				       sizeof(*efi_memreserve_root),
> +				       MEMREMAP_WB);
> +	if (!efi_memreserve_root)
> +		return -ENOMEM;
>  	return 0;
>  }
> +early_initcall(efi_memreserve_root_init);
> =20
>  #ifdef CONFIG_KEXEC
>  static int update_efi_random_seed(struct notifier_block *nb,
> --=20
> 2=2E19=2E1
BTW, I won=E2=80=99t be able to apply this patch on top of this series [1]=
=2E After applied that series, the original BUG sleep from atomic is gone a=
s well as two other GIC warnings=2E Do you think a new patch is needed here=
?

[1] https://www=2Espinics=2Enet/lists/arm-kernel/msg685751=2Ehtml
