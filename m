Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id DDF4A6B0276
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 04:40:07 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id x17-v6so13068954pln.4
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 01:40:07 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e3-v6si17098505pga.369.2018.10.17.01.40.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Oct 2018 01:40:06 -0700 (PDT)
Date: Wed, 17 Oct 2018 01:40:02 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 25/26] xfs: support returning partial reflink results
Message-ID: <20181017084002.GI16896@infradead.org>
References: <153965939489.1256.7400115244528045860.stgit@magnolia>
 <153966005536.3607.787445581785795364.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153966005536.3607.787445581785795364.stgit@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: david@fromorbit.com, sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

> @@ -1415,11 +1419,17 @@ xfs_reflink_remap_range(
>  
>  	trace_xfs_reflink_remap_range(src, pos_in, len, dest, pos_out);
>  
> +	if (len == 0) {
> +		ret = 0;
> +		goto out_unlock;
> +	}
> +

As pointed out last time this check is superflous, right above we have
this check:

	if (ret < 0 || len == 0)
		return ret;

>  	ret = xfs_reflink_remap_blocks(src, sfsbno, dest, dfsbno, fsblen,
> -			pos_out + len);
> +			&remappedfsb, pos_out + len);
> +	remapped_bytes = min_t(loff_t, len, XFS_FSB_TO_B(mp, remappedfsb));

I still think returning the bytes from the function would be saner,
but maybe that's just me.
