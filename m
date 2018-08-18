Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id F300A6B0B31
	for <linux-mm@kvack.org>; Fri, 17 Aug 2018 21:22:18 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id q2-v6so5781939plh.12
        for <linux-mm@kvack.org>; Fri, 17 Aug 2018 18:22:18 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l6-v6si3612816plt.497.2018.08.17.18.22.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 17 Aug 2018 18:22:17 -0700 (PDT)
Date: Fri, 17 Aug 2018 18:22:13 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH RFC] mm: don't miss the last page because of round-off
 error
Message-ID: <20180818012213.GA14115@bombadil.infradead.org>
References: <20180817231834.15959-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180817231834.15959-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Rik van Riel <riel@surriel.com>, Konstantin Khlebnikov <koct9i@gmail.com>

On Fri, Aug 17, 2018 at 04:18:34PM -0700, Roman Gushchin wrote:
> -			scan = div64_u64(scan * fraction[file],
> -					 denominator);
> +			if (scan > 1)
> +				scan = div64_u64(scan * fraction[file],
> +						 denominator);

Wouldn't we be better off doing a div_round_up?  ie:

	scan = div64_u64(scan * fraction[file] + denominator - 1, denominator);

although i'd rather hide that in a new macro in math64.h than opencode it
here.
