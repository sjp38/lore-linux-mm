Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 933986B02C3
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 02:24:28 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id i185so538415wmi.7
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 23:24:28 -0700 (PDT)
Received: from mail-wr0-x22f.google.com (mail-wr0-x22f.google.com. [2a00:1450:400c:c0c::22f])
        by mx.google.com with ESMTPS id u10si6878102wmg.100.2017.06.28.23.24.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Jun 2017 23:24:23 -0700 (PDT)
Received: by mail-wr0-x22f.google.com with SMTP id k67so183515286wrc.2
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 23:24:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170628170742.2895-1-opendmb@gmail.com>
References: <20170628170742.2895-1-opendmb@gmail.com>
From: Gregory Fong <gregory.0xf0@gmail.com>
Date: Wed, 28 Jun 2017 23:23:52 -0700
Message-ID: <CADtm3G6EWr6O5TEpXr_EUGA6_Fg7yBm12ttfXfC_EtQT7gyXFw@mail.gmail.com>
Subject: Re: [PATCH] cma: fix calculation of aligned offset
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Doug Berger <opendmb@gmail.com>
Cc: Angus Clark <angus@angusclark.org>, Andrew Morton <akpm@linux-foundation.org>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Lucas Stach <l.stach@pengutronix.de>, Catalin Marinas <catalin.marinas@arm.com>, Shiraz Hashim <shashim@codeaurora.org>, Jaewon Kim <jaewon31.kim@samsung.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, open list <linux-kernel@vger.kernel.org>, Danesh Petigara <dpetigara@broadcom.com>

On Wed, Jun 28, 2017 at 10:07 AM, Doug Berger <opendmb@gmail.com> wrote:
> The align_offset parameter is used by bitmap_find_next_zero_area_off()
> to represent the offset of map's base from the previous alignment
> boundary; the function ensures that the returned index, plus the
> align_offset, honors the specified align_mask.
>
> The logic introduced by commit b5be83e308f7 ("mm: cma: align to
> physical address, not CMA region position") has the cma driver
> calculate the offset to the *next* alignment boundary.

Wow, I had that completely backward, nice catch.

> In most cases,
> the base alignment is greater than that specified when making
> allocations, resulting in a zero offset whether we align up or down.
> In the example given with the commit, the base alignment (8MB) was
> half the requested alignment (16MB) so the math also happened to work
> since the offset is 8MB in both directions.  However, when requesting
> allocations with an alignment greater than twice that of the base,
> the returned index would not be correctly aligned.

It may be worth explaining what impact incorrect alignment has for an
end user, then considering for inclusion in stable.

>
> Also, the align_order arguments of cma_bitmap_aligned_mask() and
> cma_bitmap_aligned_offset() should not be negative so the argument
> type was made unsigned.
>
> Fixes: b5be83e308f7 ("mm: cma: align to physical address, not CMA region position")
> Signed-off-by: Angus Clark <angus@angusclark.org>
> Signed-off-by: Doug Berger <opendmb@gmail.com>

Acked-by: Gregory Fong <gregory.0xf0@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
