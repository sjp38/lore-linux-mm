Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 026926B004F
	for <linux-mm@kvack.org>; Fri, 27 Jan 2012 04:44:26 -0500 (EST)
Received: by wibhj13 with SMTP id hj13so1444024wib.14
        for <linux-mm@kvack.org>; Fri, 27 Jan 2012 01:44:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1327568457-27734-13-git-send-email-m.szyprowski@samsung.com>
References: <1327568457-27734-1-git-send-email-m.szyprowski@samsung.com> <1327568457-27734-13-git-send-email-m.szyprowski@samsung.com>
From: Ohad Ben-Cohen <ohad@wizery.com>
Date: Fri, 27 Jan 2012 11:44:05 +0200
Message-ID: <CADMYwHw1B4RNV_9BqAg_M70da=g69Z3kyo5Cr6izCMwJ9LAtvA@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [PATCH 12/15] drivers: add Contiguous Memory Allocator
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mel@csn.ul.ie>, Michal Nazarewicz <mina86@mina86.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Jesse Barker <jesse.barker@linaro.org>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Hi Marek,

With v19, I can't seem to allocate big regions anymore (e.g. 101MiB).
In particular, this seems to fail:

On Thu, Jan 26, 2012 at 11:00 AM, Marek Szyprowski
<m.szyprowski@samsung.com> wrote:
> +static int cma_activate_area(unsigned long base_pfn, unsigned long count=
)
> +{
> + =A0 =A0 =A0 unsigned long pfn =3D base_pfn;
> + =A0 =A0 =A0 unsigned i =3D count >> pageblock_order;
> + =A0 =A0 =A0 struct zone *zone;
> +
> + =A0 =A0 =A0 WARN_ON_ONCE(!pfn_valid(pfn));
> + =A0 =A0 =A0 zone =3D page_zone(pfn_to_page(pfn));
> +
> + =A0 =A0 =A0 do {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned j;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 base_pfn =3D pfn;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (j =3D pageblock_nr_pages; j; --j, pfn+=
+) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 WARN_ON_ONCE(!pfn_valid(pfn=
));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (page_zone(pfn_to_page(p=
fn)) !=3D zone)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EIN=
VAL;

The above WARN_ON_ONCE is triggered, and then the conditional is
asserted (page_zone() retuns a "Movable" zone, whereas zone is
"Normal") and the function fails.

This happens to me on OMAP4 with your 3.3-rc1-cma-v19 branch (and a
bunch of remoteproc/rpmsg patches).

Do big allocations work for you ?

Thanks,
Ohad.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
