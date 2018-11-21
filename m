Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4719D6B2612
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 06:36:11 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id x199-v6so2799577ybg.20
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 03:36:11 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id v85-v6si8693292ybv.449.2018.11.21.03.36.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Nov 2018 03:36:10 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH v1 8/8] PM / Hibernate: exclude all PageOffline() pages
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20181119101616.8901-9-david@redhat.com>
Date: Wed, 21 Nov 2018 04:35:46 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <11E3C0B0-AEED-42C6-A21C-1820F4B47A68@oracle.com>
References: <20181119101616.8901-1-david@redhat.com>
 <20181119101616.8901-9-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, devel@linuxdriverproject.org, linux-fsdevel@vger.kernel.org, linux-pm@vger.kernel.org, xen-devel@lists.xenproject.org, kexec-ml <kexec@lists.infradead.org>, pv-drivers@vmware.com, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, "Michael S. Tsirkin" <mst@redhat.com>

If you are adding PageOffline(page) to the condition list of the already =
existing if in
saveable_highmem_page(), why explicitly add it as a separate statement =
in saveable_page()?

It would seem more consistent to make the second check:

-	if (swsusp_page_is_forbidden(page) || swsusp_page_is_free(page))
+	if (swsusp_page_is_forbidden(page) || swsusp_page_is_free(page) =
||
+		PageOffline(page))

instead.

It's admittedly a nit but it just seems cleaner to either do that or, if =
your intention
was to separate the Page checks from the swsusp checks, to break the =
calls to
PageReserved() and PageOffline() into their own check in =
saveable_highmem_page().

Thanks!
    -- Bill
    =20

> On Nov 19, 2018, at 3:16 AM, David Hildenbrand <david@redhat.com> =
wrote:
>=20
> --- a/kernel/power/snapshot.c
> +++ b/kernel/power/snapshot.c
> @@ -1222,7 +1222,7 @@ static struct page *saveable_highmem_page(struct =
zone *zone, unsigned long pfn)
> 	BUG_ON(!PageHighMem(page));
>=20
> 	if (swsusp_page_is_forbidden(page) ||  swsusp_page_is_free(page) =
||
> -	    PageReserved(page))
> +	    PageReserved(page) || PageOffline(page))
> 		return NULL;
>=20
> 	if (page_is_guard(page))
> @@ -1286,6 +1286,9 @@ static struct page *saveable_page(struct zone =
*zone, unsigned long pfn)
> 	if (swsusp_page_is_forbidden(page) || swsusp_page_is_free(page))
> 		return NULL;
>=20
> +	if (PageOffline(page))
> +		return NULL;
> +
> 	if (PageReserved(page)
> 	    && (!kernel_page_present(page) || pfn_is_nosave(pfn)))
> 		return NULL;
> --=20
> 2.17.2
>=20
