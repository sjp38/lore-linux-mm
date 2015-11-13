Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 633746B0038
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 05:24:33 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so96449871pac.3
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 02:24:33 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id tn5si26566531pbc.139.2015.11.13.02.24.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Nov 2015 02:24:32 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so96449638pac.3
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 02:24:32 -0800 (PST)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.0 \(3094\))
Subject: Re: [PATCH V4] mm: fix kernel crash in khugepaged thread
From: yalin wang <yalin.wang2010@gmail.com>
In-Reply-To: <0ab001d11def$081c80d0$18558270$@alibaba-inc.com>
Date: Fri, 13 Nov 2015 18:24:24 +0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <031A099B-6020-4946-896F-92D3CBE9443B@gmail.com>
References: <0ab001d11def$081c80d0$18558270$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org


> On Nov 13, 2015, at 16:41, Hillf Danton <hillf.zj@alibaba-inc.com> =
wrote:
>=20
>>=20
>> Instead of the condition, we could have:
>>=20
>> 	__entry->pfn =3D page ? page_to_pfn(page) : -1;
>>=20
>>=20
>> But if there's no reason to do the tracepoint if page is NULL, then
>> this patch is fine. I'm just throwing out this idea.
>>=20
> we trace only if page is valid
>=20
> --- linux-next/mm/huge_memory.c	Fri Nov 13 16:00:22 2015
> +++ b/mm/huge_memory.c	Fri Nov 13 16:26:19 2015
> @@ -1987,7 +1987,8 @@ static int __collapse_huge_page_isolate(
>=20
> out:
> 	release_pte_pages(pte, _pte);
> -	trace_mm_collapse_huge_page_isolate(page_to_pfn(page), =
none_or_zero,
> +	if (page)
> +		trace_mm_collapse_huge_page_isolate(page_to_pfn(page), =
none_or_zero,
> 					    referenced, writable, =
result);
> 	return 0;
> }
> =E2=80=94
>=20
my V4  patch move  if (!page)  into trace function,
so that we don=E2=80=99t need call page_to_fn()  if the trace if =
disabled .
more efficient  .
Thanks


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
