Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id AE7426B0032
	for <linux-mm@kvack.org>; Fri, 12 Jun 2015 04:11:03 -0400 (EDT)
Received: by padev16 with SMTP id ev16so18604977pad.0
        for <linux-mm@kvack.org>; Fri, 12 Jun 2015 01:11:03 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id ct15si4284024pac.193.2015.06.12.01.11.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 12 Jun 2015 01:11:02 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC PATCH 08/12] mm: use mirrorable to switch allocate
 mirrored memory
Date: Fri, 12 Jun 2015 08:05:18 +0000
Message-ID: <20150612080518.GA19075@hori1.linux.bs1.fc.nec.co.jp>
References: <55704A7E.5030507@huawei.com> <55704C79.5060608@huawei.com>
In-Reply-To: <55704C79.5060608@huawei.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <B23D6155B26463448713088DB573C28D@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "nao.horiguchi@gmail.com" <nao.horiguchi@gmail.com>, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, "mingo@elte.hu" <mingo@elte.hu>, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, "Luck, Tony" <tony.luck@intel.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jun 04, 2015 at 09:02:49PM +0800, Xishi Qiu wrote:
> Add a new interface in path /proc/sys/vm/mirrorable. When set to 1, it me=
ans
> we should allocate mirrored memory for both user and kernel processes.

As Dave and Kamezawa-san commented, documentation is not enough, so please
add a section in Documentation/sysctl/vm.txt for this new tuning parameter.

Thanks,
Naoya Horiguchi

>=20
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> ---
>  include/linux/mmzone.h | 1 +
>  kernel/sysctl.c        | 9 +++++++++
>  mm/page_alloc.c        | 1 +
>  3 files changed, 11 insertions(+)
>=20
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index f82e3ae..20888dd 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -85,6 +85,7 @@ struct mirror_info {
>  };
> =20
>  extern struct mirror_info mirror_info;
> +extern int sysctl_mirrorable;
>  #  define is_migrate_mirror(migratetype) unlikely((migratetype) =3D=3D M=
IGRATE_MIRROR)
>  #else
>  #  define is_migrate_mirror(migratetype) false
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index 2082b1a..dc2625e 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -1514,6 +1514,15 @@ static struct ctl_table vm_table[] =3D {
>  		.extra2		=3D &one,
>  	},
>  #endif
> +#ifdef CONFIG_MEMORY_MIRROR
> +	{
> +		.procname	=3D "mirrorable",
> +		.data		=3D &sysctl_mirrorable,
> +		.maxlen		=3D sizeof(sysctl_mirrorable),
> +		.mode		=3D 0644,
> +		.proc_handler	=3D proc_dointvec_minmax,
> +	},
> +#endif
>  	{
>  		.procname	=3D "user_reserve_kbytes",
>  		.data		=3D &sysctl_user_reserve_kbytes,
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 249a8f6..63b90ca 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -212,6 +212,7 @@ int user_min_free_kbytes =3D -1;
> =20
>  #ifdef CONFIG_MEMORY_MIRROR
>  struct mirror_info mirror_info;
> +int sysctl_mirrorable =3D 0;
>  #endif
> =20
>  static unsigned long __meminitdata nr_kernel_pages;
> --=20
> 2.0.0
>=20
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
