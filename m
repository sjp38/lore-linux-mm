Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id BFAE26B05D7
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 16:07:21 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id v11so10516204ply.4
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 13:07:21 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id x32si27751835pgk.309.2018.11.15.13.07.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 13:07:20 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH v2] iomap: get/put the page in iomap_page_create/release()
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20181115184140.1388751-1-pjaroszynski@nvidia.com>
Date: Thu, 15 Nov 2018 14:07:11 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <96C997D3-DE5F-4553-9D35-C517EC4AF510@oracle.com>
References: <20181115184140.1388751-1-pjaroszynski@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: p.jaroszynski@gmail.com
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@lst.de>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Piotr Jaroszynski <pjaroszynski@nvidia.com>

The V2 fixes look good to me.

    William Kucharski

> On Nov 15, 2018, at 11:41 AM, p.jaroszynski@gmail.com wrote:
>=20
> Fixes: 82cb14175e7d ("xfs: add support for sub-pagesize writeback =
without buffer_heads")
> Signed-off-by: Piotr Jaroszynski <pjaroszynski@nvidia.com>
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> ---
> fs/iomap.c | 7 +++++++
> 1 file changed, 7 insertions(+)
>=20
> diff --git a/fs/iomap.c b/fs/iomap.c
> index 90c2febc93ac..7c369faea1dc 100644
> --- a/fs/iomap.c
> +++ b/fs/iomap.c
> @@ -117,6 +117,12 @@ iomap_page_create(struct inode *inode, struct =
page *page)
> 	atomic_set(&iop->read_count, 0);
> 	atomic_set(&iop->write_count, 0);
> 	bitmap_zero(iop->uptodate, PAGE_SIZE / SECTOR_SIZE);
> +
> +	/*
> +	 * migrate_page_move_mapping() assumes that pages with private =
data have
> +	 * their count elevated by 1.
> +	 */
> +	get_page(page);
> 	set_page_private(page, (unsigned long)iop);
> 	SetPagePrivate(page);
> 	return iop;
> @@ -133,6 +139,7 @@ iomap_page_release(struct page *page)
> 	WARN_ON_ONCE(atomic_read(&iop->write_count));
> 	ClearPagePrivate(page);
> 	set_page_private(page, 0);
> +	put_page(page);
> 	kfree(iop);
> }
>=20
> --=20
> 2.11.0.262.g4b0a5b2.dirty
>=20
