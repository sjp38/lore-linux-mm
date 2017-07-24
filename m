Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0F57C6B0292
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 07:25:36 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id x43so24410960wrb.9
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 04:25:36 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j189si5414427wmd.191.2017.07.24.04.25.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Jul 2017 04:25:35 -0700 (PDT)
Date: Mon, 24 Jul 2017 13:25:30 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v4 1/5] mm: add mkwrite param to vm_insert_mixed()
Message-ID: <20170724112530.GI652@quack2.suse.cz>
References: <20170721223956.29485-1-ross.zwisler@linux.intel.com>
 <20170721223956.29485-2-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170721223956.29485-2-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, David Airlie <airlied@linux.ie>, Ingo Molnar <mingo@redhat.com>, Inki Dae <inki.dae@samsung.com>, Jan Kara <jack@suse.cz>, Jonathan Corbet <corbet@lwn.net>, Joonyoung Shim <jy0922.shim@samsung.com>, Krzysztof Kozlowski <krzk@kernel.org>, Kukjin Kim <kgene@kernel.org>, Kyungmin Park <kyungmin.park@samsung.com>, Matthew Wilcox <mawilcox@microsoft.com>, Patrik Jakobsson <patrik.r.jakobsson@gmail.com>, Rob Clark <robdclark@gmail.com>, Seung-Woo Kim <sw0312.kim@samsung.com>, Steven Rostedt <rostedt@goodmis.org>, Tomi Valkeinen <tomi.valkeinen@ti.com>, dri-devel@lists.freedesktop.org, freedreno@lists.freedesktop.org, linux-arm-kernel@lists.infradead.org, linux-arm-msm@vger.kernel.org, linux-doc@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-samsung-soc@vger.kernel.org, linux-xfs@vger.kernel.org

> @@ -1658,14 +1658,28 @@ static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
>  	if (!pte)
>  		goto out;
>  	retval = -EBUSY;
> -	if (!pte_none(*pte))
> -		goto out_unlock;
> +	if (!pte_none(*pte)) {
> +		if (mkwrite) {
> +			if (WARN_ON_ONCE(pte_pfn(*pte) != pfn_t_to_pfn(pfn)))

Is the WARN_ON_ONCE() really appropriate here? Your testcase with private
mappings has triggered this situation if I'm right...

Otherwise the patch looks good to me.

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
