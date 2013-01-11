Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 96F916B0072
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 07:07:39 -0500 (EST)
Message-ID: <50F00051.4070509@cn.fujitsu.com>
Date: Fri, 11 Jan 2013 20:06:41 +0800
From: Lin Feng <linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: mmots: memory-hotplug-remove-memmap-of-sparse-vmemmap.patch compile
 fix
References: <20130111095348.GB7286@dhcp22.suse.cz>
In-Reply-To: <20130111095348.GB7286@dhcp22.suse.cz>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Jianguo Wu <wujianguo@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

It looks fine to me.
Tested-by: Lin Feng <linfeng@cn.fujitsu.com>

On 01/11/2013 05:53 PM, Michal Hocko wrote:
> Defconfig for x86=5F64 complains:
> arch/x86/mm/init=5F64.c: In function =E2=80=98vmemmap=5Ffree=E2=80=99:
> arch/x86/mm/init=5F64.c:1317: error: implicit declaration of function =E2=
=80=98remove=5Fpagetable=E2=80=99
>=20
> vmemmap=5Ffree is only used for CONFIG=5FMEMORY=5FHOTPLUG so let's move it
> inside ifdef
>=20
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  arch/x86/mm/init=5F64.c |   16 ++++++++--------
>  include/linux/mm.h    |    2 ++
>  2 files changed, 10 insertions(+), 8 deletions(-)
>=20
> diff --git a/arch/x86/mm/init=5F64.c b/arch/x86/mm/init=5F64.c
> index 9920ffc..ddd3b58 100644
> --- a/arch/x86/mm/init=5F64.c
> +++ b/arch/x86/mm/init=5F64.c
> @@ -981,6 +981,14 @@ remove=5Fpagetable(unsigned long start, unsigned lon=
g end, bool direct)
>  	flush=5Ftlb=5Fall();
>  }
> =20
> +void =5F=5Fref vmemmap=5Ffree(struct page *memmap, unsigned long nr=5Fpa=
ges)
> +{
> +	unsigned long start =3D (unsigned long)memmap;
> +	unsigned long end =3D (unsigned long)(memmap + nr=5Fpages);
> +
> +	remove=5Fpagetable(start, end, false);
> +}
> +
>  static void =5F=5Fmeminit
>  kernel=5Fphysical=5Fmapping=5Fremove(unsigned long start, unsigned long =
end)
>  {
> @@ -1309,14 +1317,6 @@ vmemmap=5Fpopulate(struct page *start=5Fpage, unsi=
gned long size, int node)
>  	return 0;
>  }
> =20
> -void =5F=5Fref vmemmap=5Ffree(struct page *memmap, unsigned long nr=5Fpa=
ges)
> -{
> -	unsigned long start =3D (unsigned long)memmap;
> -	unsigned long end =3D (unsigned long)(memmap + nr=5Fpages);
> -
> -	remove=5Fpagetable(start, end, false);
> -}
> -
>  void register=5Fpage=5Fbootmem=5Fmemmap(unsigned long section=5Fnr,
>  				  struct page *start=5Fpage, unsigned long size)
>  {
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 0d880df..7c57bd0 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1721,7 +1721,9 @@ int vmemmap=5Fpopulate=5Fbasepages(struct page *sta=
rt=5Fpage,
>  						unsigned long pages, int node);
>  int vmemmap=5Fpopulate(struct page *start=5Fpage, unsigned long pages, i=
nt node);
>  void vmemmap=5Fpopulate=5Fprint=5Flast(void);
> +#ifdef CONFIG=5FMEMORY=5FHOTPLUG
>  void vmemmap=5Ffree(struct page *memmap, unsigned long nr=5Fpages);
> +#endif
>  void register=5Fpage=5Fbootmem=5Fmemmap(unsigned long section=5Fnr, stru=
ct page *map,
>  				  unsigned long size);
> =20
>=20
=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
