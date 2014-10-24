Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 020336B0069
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 12:31:28 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id pv20so2907911lab.6
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 09:31:28 -0700 (PDT)
Received: from mail-lb0-x232.google.com (mail-lb0-x232.google.com. [2a00:1450:4010:c04::232])
        by mx.google.com with ESMTPS id s6si7729749laj.90.2014.10.24.09.31.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 24 Oct 2014 09:31:27 -0700 (PDT)
Received: by mail-lb0-f178.google.com with SMTP id w7so2909616lbi.9
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 09:31:26 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH v2 2/2] fs: proc: Include cma info in proc/meminfo
In-Reply-To: <1413986796-19732-2-git-send-email-pintu.k@samsung.com>
References: <1413790391-31686-1-git-send-email-pintu.k@samsung.com> <1413986796-19732-1-git-send-email-pintu.k@samsung.com> <1413986796-19732-2-git-send-email-pintu.k@samsung.com>
Date: Fri, 24 Oct 2014 18:31:21 +0200
Message-ID: <xa1tk33p2zvq.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pintu Kumar <pintu.k@samsung.com>, akpm@linux-foundation.org, riel@redhat.compintu.k@samsung.com, aquini@redhat.com, paul.gortmaker@windriver.com, jmarchan@redhat.com, lcapitulino@redhat.com, kirill.shutemov@linux.intel.com, m.szyprowski@samsung.com, aneesh.kumar@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, lauraa@codeaurora.org, gioh.kim@lge.com, mgorman@suse.de, rientjes@google.com, hannes@cmpxchg.org, vbabka@suse.cz, sasha.levin@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: pintu_agarwal@yahoo.com, cpgs@samsung.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, ed.savinay@samsung.com

On Wed, Oct 22 2014, Pintu Kumar <pintu.k@samsung.com> wrote:
> This patch include CMA info (CMATotal, CMAFree) in /proc/meminfo.
> Currently, in a CMA enabled system, if somebody wants to know the
> total CMA size declared, there is no way to tell, other than the dmesg
> or /var/log/messages logs.
> With this patch we are showing the CMA info as part of meminfo, so that
> it can be determined at any point of time.
> This will be populated only when CMA is enabled.
>
> Below is the sample output from a ARM based device with RAM:512MB and CMA=
:16MB.
>
> MemTotal:         471172 kB
> MemFree:          111712 kB
> MemAvailable:     271172 kB
> .
> .
> .
> CmaTotal:          16384 kB
> CmaFree:            6144 kB
>
> This patch also fix below checkpatch errors that were found during these =
changes.

As already mentioned, this should be in separate patch.

>
> ERROR: space required after that ',' (ctx:ExV)
> 199: FILE: fs/proc/meminfo.c:199:
> +       ,atomic_long_read(&num_poisoned_pages) << (PAGE_SHIFT - 10)
>         ^
>
> ERROR: space required after that ',' (ctx:ExV)
> 202: FILE: fs/proc/meminfo.c:202:
> +       ,K(global_page_state(NR_ANON_TRANSPARENT_HUGEPAGES) *
>         ^
>
> ERROR: space required after that ',' (ctx:ExV)
> 206: FILE: fs/proc/meminfo.c:206:
> +       ,K(totalcma_pages)
>         ^
>
> total: 3 errors, 0 warnings, 2 checks, 236 lines checked
>
> Signed-off-by: Pintu Kumar <pintu.k@samsung.com>
> Signed-off-by: Vishnu Pratap Singh <vishnu.ps@samsung.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> ---
>  fs/proc/meminfo.c |   15 +++++++++++++--
>  1 file changed, 13 insertions(+), 2 deletions(-)
>
> diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
> index aa1eee0..d3ebf2e 100644
> --- a/fs/proc/meminfo.c
> +++ b/fs/proc/meminfo.c
> @@ -12,6 +12,9 @@
>  #include <linux/vmstat.h>
>  #include <linux/atomic.h>
>  #include <linux/vmalloc.h>
> +#ifdef CONFIG_CMA
> +#include <linux/cma.h>
> +#endif
>  #include <asm/page.h>
>  #include <asm/pgtable.h>
>  #include "internal.h"
> @@ -138,6 +141,10 @@ static int meminfo_proc_show(struct seq_file *m, voi=
d *v)
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  		"AnonHugePages:  %8lu kB\n"
>  #endif
> +#ifdef CONFIG_CMA
> +		"CmaTotal:       %8lu kB\n"
> +		"CmaFree:        %8lu kB\n"
> +#endif
>  		,
>  		K(i.totalram),
>  		K(i.freeram),
> @@ -187,12 +194,16 @@ static int meminfo_proc_show(struct seq_file *m, vo=
id *v)
>  		vmi.used >> 10,
>  		vmi.largest_chunk >> 10
>  #ifdef CONFIG_MEMORY_FAILURE
> -		,atomic_long_read(&num_poisoned_pages) << (PAGE_SHIFT - 10)
> +		, atomic_long_read(&num_poisoned_pages) << (PAGE_SHIFT - 10)
>  #endif
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
> -		,K(global_page_state(NR_ANON_TRANSPARENT_HUGEPAGES) *
> +		, K(global_page_state(NR_ANON_TRANSPARENT_HUGEPAGES) *
>  		   HPAGE_PMD_NR)
>  #endif
> +#ifdef CONFIG_CMA
> +		, K(totalcma_pages)
> +		, K(global_page_state(NR_FREE_CMA_PAGES))
> +#endif
>  		);
>=20=20
>  	hugetlb_report_meminfo(m);
> --=20
> 1.7.9.5
>

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
