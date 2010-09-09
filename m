Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 14ADE6B004A
	for <linux-mm@kvack.org>; Thu,  9 Sep 2010 12:16:06 -0400 (EDT)
Received: by qyk8 with SMTP id 8so544910qyk.14
        for <linux-mm@kvack.org>; Thu, 09 Sep 2010 09:16:05 -0700 (PDT)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
In-Reply-To: <20100909082331.7278e76b.randy.dunlap@oracle.com>
References: <AANLkTi=uzLJxDbd+uJAww-b5aP10gd8gbGVG19HS46ue@mail.gmail.com>
	<20100909082331.7278e76b.randy.dunlap@oracle.com>
Date: Thu, 9 Sep 2010 18:16:04 +0200
Message-ID: <AANLkTi=KQ1HJ8s7NcTGHRKsj+wriH4uqWUi43LZnqUFv@mail.gmail.com>
Subject: Re: mm/Kconfig: warning: (COMPACTION && EXPERIMENTAL && HUGETLB_PAGE
 && MMU) selects MIGRATION which has unmet direct dependencies (NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE)
From: Sedat Dilek <sedat.dilek@googlemail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 9, 2010 at 5:23 PM, Randy Dunlap <randy.dunlap@oracle.com> wrot=
e:
> On Thu, 9 Sep 2010 17:10:34 +0200 Sedat Dilek wrote:
>
>> Hi,
>>
>> while build latest 2.6.36-rc3 I get this warning:
>>
>> [ build.log]
>> ...
>> warning: (COMPACTION && EXPERIMENTAL && HUGETLB_PAGE && MMU) selects
>> MIGRATION which has unmet direct dependencies (NUMA ||
>> ARCH_ENABLE_MEMORY_HOTREMOVE)
>> ...
>>
>> Here the excerpt of...
>>
>> [ mm/Kconfig ]
>> ...
>> # support for memory compaction
>> config COMPACTION
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 bool "Allow for memory compaction"
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 select MIGRATION
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 depends on EXPERIMENTAL && HUGETLB_PAGE && M=
MU
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 help
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Allows the compaction of memory for t=
he allocation of huge pages.
>> ...
>>
>> I have set the following kernel-config parameters:
>>
>> $ egrep 'COMPACTION|HUGETLB_PAGE|MMU|MIGRATION|NUMA|ARCH_ENABLE_MEMORY_H=
OTREMOVE'
>> linux-2.6.36-rc3/debian/build/build_i386_none_686/.config
>> CONFIG_MMU=3Dy
>> # CONFIG_IOMMU_HELPER is not set
>> CONFIG_IOMMU_API=3Dy
>> CONFIG_COMPACTION=3Dy
>> CONFIG_MIGRATION=3Dy
>> CONFIG_MMU_NOTIFIER=3Dy
>> CONFIG_HUGETLB_PAGE=3Dy
>> # CONFIG_IOMMU_STRESS is not set
>>
>> Looks like I have no NUMA or ARCH_ENABLE_MEMORY_HOTREMOVE set.
>>
>> Ok, it is a *warning*...
>
>
> Andrea Arcangeli posted a patch for this on linux-mm on 2010-SEP-03.
> (below)
>
> ---
> From: Andrea Arcangeli <aarcange@redhat.com>
>
> COMPACTION enables MIGRATION, but MIGRATION spawns a warning if numa
> or memhotplug aren't selected. However MIGRATION doesn't depend on
> them. I guess it's just trying to be strict doing a double check on
> who's enabling it, but it doesn't know that compaction also enables
> MIGRATION.
>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>
> diff --git a/mm/Kconfig b/mm/Kconfig
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -189,7 +189,7 @@ config COMPACTION
> =C2=A0config MIGRATION
> =C2=A0 =C2=A0 =C2=A0 =C2=A0bool "Page migration"
> =C2=A0 =C2=A0 =C2=A0 =C2=A0def_bool y
> - =C2=A0 =C2=A0 =C2=A0 depends on NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE
> + =C2=A0 =C2=A0 =C2=A0 depends on NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE ||=
 COMPACTION
> =C2=A0 =C2=A0 =C2=A0 =C2=A0help
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Allows the migration of the physical lo=
cation of pages of processes
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0while the virtual addresses are not cha=
nged. This is useful in
>

Below is the URL for...

"[PATCH] avoid warning when COMPACTION is selected"

- Sedat -

[1] http://marc.info/?l=3Dlinux-mm&m=3D128352833826498&w=3D2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
