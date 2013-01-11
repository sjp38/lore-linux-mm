Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 51AB26B006C
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 05:27:11 -0500 (EST)
Message-ID: <50EFE8CF.7010400@cn.fujitsu.com>
Date: Fri, 11 Jan 2013 18:26:23 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: mmots: memory-hotplug: implement register_page_bootmem_info_section
 of sparse-vmemmap fix
References: <20130111095658.GC7286@dhcp22.suse.cz>
In-Reply-To: <20130111095658.GC7286@dhcp22.suse.cz>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wen Congyang <wency@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Wu Jianguo <wujianguo@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi Michal,

Thank you very much for the nice catch. :)

On 01/11/2013 05:56 PM, Michal Hocko wrote:
> Defconfig for x86=5F64 complains
> arch/x86/mm/init=5F64.c: In function =E2=80=98register=5Fpage=5Fbootmem=
=5Fmemmap=E2=80=99:
> arch/x86/mm/init=5F64.c:1340: error: implicit declaration of function =E2=
=80=98get=5Fpage=5Fbootmem=E2=80=99
> arch/x86/mm/init=5F64.c:1340: error: =E2=80=98MIX=5FSECTION=5FINFO=E2=80=
=99 undeclared (first
> use in this function)
> arch/x86/mm/init=5F64.c:1340: error: (Each undeclared identifier is
> reported only once
> arch/x86/mm/init=5F64.c:1340: error: for each function it appears in.)
> arch/x86/mm/init=5F64.c:1361: error: =E2=80=98SECTION=5FINFO=E2=80=99 und=
eclared (first use in this function)
>
> move register=5Fpage=5Fbootmem=5Fmemmap to memory=5Fhotplug where it is u=
sed and
> where it has all required symbols
>
> Signed-off-by: Michal Hocko<mhocko@suse.cz>
> ---
>   arch/x86/mm/init=5F64.c |   58 ----------------------------------------=
-------
>   include/linux/mm.h    |    2 --
>   mm/memory=5Fhotplug.c   |   60 ++++++++++++++++++++++++++++++++++++++++=
++++++++-
>   3 files changed, 59 insertions(+), 61 deletions(-)
>
> diff --git a/arch/x86/mm/init=5F64.c b/arch/x86/mm/init=5F64.c
> index ddd3b58..a6a7494 100644
> --- a/arch/x86/mm/init=5F64.c
> +++ b/arch/x86/mm/init=5F64.c
> @@ -1317,64 +1317,6 @@ vmemmap=5Fpopulate(struct page *start=5Fpage, unsi=
gned long size, int node)
>   	return 0;
>   }
>
> -void register=5Fpage=5Fbootmem=5Fmemmap(unsigned long section=5Fnr,
> -				  struct page *start=5Fpage, unsigned long size)
> -{
> -	unsigned long addr =3D (unsigned long)start=5Fpage;
> -	unsigned long end =3D (unsigned long)(start=5Fpage + size);
> -	unsigned long next;
> -	pgd=5Ft *pgd;
> -	pud=5Ft *pud;
> -	pmd=5Ft *pmd;
> -	unsigned int nr=5Fpages;
> -	struct page *page;
> -
> -	for (; addr<  end; addr =3D next) {
> -		pte=5Ft *pte =3D NULL;
> -
> -		pgd =3D pgd=5Foffset=5Fk(addr);
> -		if (pgd=5Fnone(*pgd)) {
> -			next =3D (addr + PAGE=5FSIZE)&  PAGE=5FMASK;
> -			continue;
> -		}
> -		get=5Fpage=5Fbootmem(section=5Fnr, pgd=5Fpage(*pgd), MIX=5FSECTION=5FI=
NFO);
> -
> -		pud =3D pud=5Foffset(pgd, addr);
> -		if (pud=5Fnone(*pud)) {
> -			next =3D (addr + PAGE=5FSIZE)&  PAGE=5FMASK;
> -			continue;
> -		}
> -		get=5Fpage=5Fbootmem(section=5Fnr, pud=5Fpage(*pud), MIX=5FSECTION=5FI=
NFO);
> -
> -		if (!cpu=5Fhas=5Fpse) {
> -			next =3D (addr + PAGE=5FSIZE)&  PAGE=5FMASK;
> -			pmd =3D pmd=5Foffset(pud, addr);
> -			if (pmd=5Fnone(*pmd))
> -				continue;
> -			get=5Fpage=5Fbootmem(section=5Fnr, pmd=5Fpage(*pmd),
> -					 MIX=5FSECTION=5FINFO);
> -
> -			pte =3D pte=5Foffset=5Fkernel(pmd, addr);
> -			if (pte=5Fnone(*pte))
> -				continue;
> -			get=5Fpage=5Fbootmem(section=5Fnr, pte=5Fpage(*pte),
> -					 SECTION=5FINFO);
> -		} else {
> -			next =3D pmd=5Faddr=5Fend(addr, end);
> -
> -			pmd =3D pmd=5Foffset(pud, addr);
> -			if (pmd=5Fnone(*pmd))
> -				continue;
> -
> -			nr=5Fpages =3D 1<<  (get=5Forder(PMD=5FSIZE));
> -			page =3D pmd=5Fpage(*pmd);
> -			while (nr=5Fpages--)
> -				get=5Fpage=5Fbootmem(section=5Fnr, page++,
> -						 SECTION=5FINFO);
> -		}
> -	}
> -}
> -
>   void =5F=5Fmeminit vmemmap=5Fpopulate=5Fprint=5Flast(void)
>   {
>   	if (p=5Fstart) {
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 7c57bd0..1fea1b23 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1724,8 +1724,6 @@ void vmemmap=5Fpopulate=5Fprint=5Flast(void);
>   #ifdef CONFIG=5FMEMORY=5FHOTPLUG
>   void vmemmap=5Ffree(struct page *memmap, unsigned long nr=5Fpages);
>   #endif
> -void register=5Fpage=5Fbootmem=5Fmemmap(unsigned long section=5Fnr, stru=
ct page *map,
> -				  unsigned long size);
>
>   enum mf=5Fflags {
>   	MF=5FCOUNT=5FINCREASED =3D 1<<  0,
> diff --git a/mm/memory=5Fhotplug.c b/mm/memory=5Fhotplug.c
> index be2b90c..1501d25 100644
> --- a/mm/memory=5Fhotplug.c
> +++ b/mm/memory=5Fhotplug.c
> @@ -91,7 +91,6 @@ static void release=5Fmemory=5Fresource(struct resource=
 *res)
>   	return;
>   }
>
> -#ifdef CONFIG=5FMEMORY=5FHOTPLUG=5FSPARSE
>   void get=5Fpage=5Fbootmem(unsigned long info,  struct page *page,
>   		      unsigned long type)
>   {
> @@ -101,6 +100,7 @@ void get=5Fpage=5Fbootmem(unsigned long info,  struct=
 page *page,
>   	atomic=5Finc(&page->=5Fcount);
>   }
>
> +#ifdef CONFIG=5FMEMORY=5FHOTPLUG=5FSPARSE
>   /* reference to =5F=5Fmeminit =5F=5Ffree=5Fpages=5Fbootmem is valid
>    * so use =5F=5Fref to tell modpost not to generate a warning */
>   void =5F=5Fref put=5Fpage=5Fbootmem(struct page *page)
> @@ -128,6 +128,64 @@ void =5F=5Fref put=5Fpage=5Fbootmem(struct page *pag=
e)
>
>   }
>
> +void register=5Fpage=5Fbootmem=5Fmemmap(unsigned long section=5Fnr,
> +				  struct page *start=5Fpage, unsigned long size)
> +{
> +	unsigned long addr =3D (unsigned long)start=5Fpage;
> +	unsigned long end =3D (unsigned long)(start=5Fpage + size);
> +	unsigned long next;
> +	pgd=5Ft *pgd;
> +	pud=5Ft *pud;
> +	pmd=5Ft *pmd;
> +	unsigned int nr=5Fpages;
> +	struct page *page;
> +
> +	for (; addr<  end; addr =3D next) {
> +		pte=5Ft *pte =3D NULL;
> +
> +		pgd =3D pgd=5Foffset=5Fk(addr);
> +		if (pgd=5Fnone(*pgd)) {
> +			next =3D (addr + PAGE=5FSIZE)&  PAGE=5FMASK;
> +			continue;
> +		}
> +		get=5Fpage=5Fbootmem(section=5Fnr, pgd=5Fpage(*pgd), MIX=5FSECTION=5FI=
NFO);
> +
> +		pud =3D pud=5Foffset(pgd, addr);
> +		if (pud=5Fnone(*pud)) {
> +			next =3D (addr + PAGE=5FSIZE)&  PAGE=5FMASK;
> +			continue;
> +		}
> +		get=5Fpage=5Fbootmem(section=5Fnr, pud=5Fpage(*pud), MIX=5FSECTION=5FI=
NFO);
> +
> +		if (!cpu=5Fhas=5Fpse) {
> +			next =3D (addr + PAGE=5FSIZE)&  PAGE=5FMASK;
> +			pmd =3D pmd=5Foffset(pud, addr);
> +			if (pmd=5Fnone(*pmd))
> +				continue;
> +			get=5Fpage=5Fbootmem(section=5Fnr, pmd=5Fpage(*pmd),
> +					 MIX=5FSECTION=5FINFO);
> +
> +			pte =3D pte=5Foffset=5Fkernel(pmd, addr);
> +			if (pte=5Fnone(*pte))
> +				continue;
> +			get=5Fpage=5Fbootmem(section=5Fnr, pte=5Fpage(*pte),
> +					 SECTION=5FINFO);
> +		} else {
> +			next =3D pmd=5Faddr=5Fend(addr, end);
> +
> +			pmd =3D pmd=5Foffset(pud, addr);
> +			if (pmd=5Fnone(*pmd))
> +				continue;
> +
> +			nr=5Fpages =3D 1<<  (get=5Forder(PMD=5FSIZE));
> +			page =3D pmd=5Fpage(*pmd);
> +			while (nr=5Fpages--)
> +				get=5Fpage=5Fbootmem(section=5Fnr, page++,
> +						 SECTION=5FINFO);
> +		}
> +	}
> +}
> +
>   #ifndef CONFIG=5FSPARSEMEM=5FVMEMMAP
>   static void register=5Fpage=5Fbootmem=5Finfo=5Fsection(unsigned long st=
art=5Fpfn)
>   {

=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
