Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id EC0ED8E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 14:02:40 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id p127-v6so2899908ywg.1
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 11:02:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j186-v6sor2348729ybj.169.2018.09.19.11.02.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Sep 2018 11:02:35 -0700 (PDT)
Date: Wed, 19 Sep 2018 14:02:32 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v7 1/6] mm: split SWP_FILE into SWP_ACTIVATED and SWP_FS
Message-ID: <20180919180232.GB18068@cmpxchg.org>
References: <cover.1536704650.git.osandov@fb.com>
 <6d63d8668c4287a4f6d203d65696e96f80abdfc7.1536704650.git.osandov@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6d63d8668c4287a4f6d203d65696e96f80abdfc7.1536704650.git.osandov@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Omar Sandoval <osandov@osandov.com>
Cc: linux-btrfs@vger.kernel.org, kernel-team@fb.com, linux-mm@kvack.org

On Tue, Sep 11, 2018 at 03:34:44PM -0700, Omar Sandoval wrote:
> @@ -2411,8 +2412,10 @@ static int setup_swap_extents(struct swap_info_struct *sis, sector_t *span)
>  
>  	if (mapping->a_ops->swap_activate) {
>  		ret = mapping->a_ops->swap_activate(sis, swap_file, span);
> +		if (ret >= 0)
> +			sis->flags |= SWP_ACTIVATED;
>  		if (!ret) {
> -			sis->flags |= SWP_FILE;
> +			sis->flags |= SWP_FS;
>  			ret = add_swap_extent(sis, 0, sis->max, 0);

Won't this single, linear extent be in conflict with the discontiguous
extents you set up in your swap_activate callback in the last patch?
