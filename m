Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8575F6B02EE
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 04:01:43 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id d26so115113744oic.4
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 01:01:43 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id o52si9779216oto.146.2017.04.25.01.01.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 01:01:42 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC 2/2] mm: skip HWPoisoned pages when onlining pages
Date: Tue, 25 Apr 2017 08:00:53 +0000
Message-ID: <20170425080052.GB18194@hori1.linux.bs1.fc.nec.co.jp>
References: <1492680362-24941-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1492680362-24941-3-git-send-email-ldufour@linux.vnet.ibm.com>
In-Reply-To: <1492680362-24941-3-git-send-email-ldufour@linux.vnet.ibm.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <88B6E6BE5867D4419027A1B7F223473C@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Thu, Apr 20, 2017 at 11:26:02AM +0200, Laurent Dufour wrote:
> The commit b023f46813cd ("memory-hotplug: skip HWPoisoned page when
> offlining pages") skip the HWPoisoned pages when offlining pages, but
> this should be skipped when onlining the pages too.
>
> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> ---
>  mm/memory_hotplug.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 6fa7208bcd56..20e1fadc2369 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -942,6 +942,8 @@ static int online_pages_range(unsigned long start_pfn=
, unsigned long nr_pages,
>  	if (PageReserved(pfn_to_page(start_pfn)))
>  		for (i =3D 0; i < nr_pages; i++) {
>  			page =3D pfn_to_page(start_pfn + i);
> +			if (PageHWPoison(page))
> +				continue;

Is it OK that PageReserved (set by __offline_isolated_pages for non-buddy
hwpoisoned pages) still remains in this path?
If online_pages_range() is the reverse operation of __offline_isolated_page=
s(),
ClearPageReserved seems needed here.

Thanks,
Naoya Horiguchi

>  			(*online_page_callback)(page);
>  			onlined_pages++;
>  		}
> --
> 2.7.4
>
>=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
