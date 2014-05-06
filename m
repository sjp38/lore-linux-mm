Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id F35526B0035
	for <linux-mm@kvack.org>; Tue,  6 May 2014 16:34:53 -0400 (EDT)
Received: by mail-qg0-f48.google.com with SMTP id i50so28521qgf.7
        for <linux-mm@kvack.org>; Tue, 06 May 2014 13:34:53 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id l5si5736136qai.77.2014.05.06.13.34.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 May 2014 13:34:53 -0700 (PDT)
Date: Tue, 6 May 2014 22:34:49 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 08/17] mm: page_alloc: Use word-based accesses for
 get/set pageblock bitmaps
Message-ID: <20140506203449.GG1429@laptop.programming.kicks-ass.net>
References: <1398933888-4940-1-git-send-email-mgorman@suse.de>
 <1398933888-4940-9-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <1398933888-4940-9-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Linux Kernel <linux-kernel@vger.kernel.org>

On Thu, May 01, 2014 at 09:44:39AM +0100, Mel Gorman wrote:
> +void set_pfnblock_flags_group(struct page *page, unsigned long flags,
> +					unsigned long end_bitidx,
> +					unsigned long nr_flag_bits,
> +					unsigned long mask)
>  {
>  	struct zone *zone;
>  	unsigned long *bitmap;
> +	unsigned long pfn, bitidx, word_bitidx;
> +	unsigned long old_word, new_word;
> +
> +	BUILD_BUG_ON(NR_PAGEBLOCK_BITS !=3D 4);
> =20
>  	zone =3D page_zone(page);
>  	pfn =3D page_to_pfn(page);
>  	bitmap =3D get_pageblock_bitmap(zone, pfn);
>  	bitidx =3D pfn_to_bitidx(zone, pfn);
> +	word_bitidx =3D bitidx / BITS_PER_LONG;
> +	bitidx &=3D (BITS_PER_LONG-1);
> +
>  	VM_BUG_ON_PAGE(!zone_spans_pfn(zone, pfn), page);
> =20
> +	bitidx +=3D end_bitidx;
> +	mask <<=3D (BITS_PER_LONG - bitidx - 1);
> +	flags <<=3D (BITS_PER_LONG - bitidx - 1);
> +
> +	do {
> +		old_word =3D ACCESS_ONCE(bitmap[word_bitidx]);
> +		new_word =3D (old_word & ~mask) | flags;
> +	} while (cmpxchg(&bitmap[word_bitidx], old_word, new_word) !=3D old_wor=
d);
>  }

You could write it like:

	word =3D ACCESS_ONCE(bitmap[word_bitidx]);
	for (;;) {
		old_word =3D cmpxchg(&bitmap[word_bitidx], word, (word & ~mask) | flags);
		if (word =3D=3D old_word);
			break;
		word =3D old_word;
	}

It has a slightly tighter loop by avoiding the read being included.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
