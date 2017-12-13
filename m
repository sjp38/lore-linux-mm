Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 939106B0033
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 07:51:00 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id f8so1507759pgs.9
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 04:51:00 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id y2si1327963pli.150.2017.12.13.04.50.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 04:50:59 -0800 (PST)
Date: Wed, 13 Dec 2017 04:50:53 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 1/2] mm: introduce MAP_FIXED_SAFE
Message-ID: <20171213125053.GB2384@bombadil.infradead.org>
References: <20171213092550.2774-1-mhocko@kernel.org>
 <20171213092550.2774-2-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171213092550.2774-2-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-api@vger.kernel.org, Khalid Aziz <khalid.aziz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Michal Hocko <mhocko@suse.com>

On Wed, Dec 13, 2017 at 10:25:49AM +0100, Michal Hocko wrote:
> +++ b/mm/mmap.c
> @@ -1342,6 +1342,10 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
>  		if (!(file && path_noexec(&file->f_path)))
>  			prot |= PROT_EXEC;
>  
> +	/* force arch specific MAP_FIXED handling in get_unmapped_area */
> +	if (flags & MAP_FIXED_SAFE)
> +		flags |= MAP_FIXED;
> +
>  	if (!(flags & MAP_FIXED))
>  		addr = round_hint_to_min(addr);
>  

We're up to 22 MAP_ flags now.  We'll run out soon.  Let's preserve half
of a flag by giving userspace the definition:

#define MAP_FIXED_SAFE	(MAP_FIXED | _MAP_NOT_HINT)

then in here:

	if ((flags & _MAP_NOT_HINT) && !(flags & MAP_FIXED))
		return -EINVAL;

Now we can use _MAP_NOT_HINT all by itself in the future to mean
something else.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
