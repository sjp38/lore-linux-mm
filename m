Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id D7B706B0006
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 02:49:30 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id r2-v6so19054pgp.3
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 23:49:30 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id s9-v6si201553plq.197.2018.07.16.23.49.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 23:49:29 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v6 05/13] mm, madvise_inject_error: Disable
 MADV_SOFT_OFFLINE for ZONE_DEVICE pages
Date: Tue, 17 Jul 2018 06:47:37 +0000
Message-ID: <20180717064736.GA27953@hori1.linux.bs1.fc.nec.co.jp>
References: <153154376846.34503.15480221419473501643.stgit@dwillia2-desk3.amr.corp.intel.com>
 <153154379606.34503.17311881160518829077.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <153154379606.34503.17311881160518829077.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <05DD4241F5D8DF4F92EBBCDB6A7040AD@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "hch@lst.de" <hch@lst.de>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Jul 13, 2018 at 09:49:56PM -0700, Dan Williams wrote:
> Given that dax / device-mapped pages are never subject to page
> allocations remove them from consideration by the soft-offline
> mechanism.
>=20
> Reported-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  mm/memory-failure.c |    8 ++++++++
>  1 file changed, 8 insertions(+)
>=20
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 9d142b9b86dc..988f977db3d2 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1751,6 +1751,14 @@ int soft_offline_page(struct page *page, int flags=
)
>  	int ret;
>  	unsigned long pfn =3D page_to_pfn(page);
> =20
> +	if (is_zone_device_page(page)) {
> +		pr_debug_ratelimited("soft_offline: %#lx page is device page\n",
> +				pfn);
> +		if (flags & MF_COUNT_INCREASED)
> +			put_page(page);

put_hwpoison_page(), which is just an alias of put_page(), is better
for consistency.
With this adjustment, feel free to add my ack.

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thanks,
Naoya Horiguchi

> +		return -EIO;
> +	}
> +
>  	if (PageHWPoison(page)) {
>  		pr_info("soft offline: %#lx page already poisoned\n", pfn);
>  		if (flags & MF_COUNT_INCREASED)
>=20
> =
