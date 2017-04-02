Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0C39E6B039F
	for <linux-mm@kvack.org>; Sun,  2 Apr 2017 09:57:02 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 197so26611877pfv.13
        for <linux-mm@kvack.org>; Sun, 02 Apr 2017 06:57:02 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id m9si11197671plk.225.2017.04.02.06.57.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Apr 2017 06:57:00 -0700 (PDT)
Date: Sun, 2 Apr 2017 06:56:59 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC] mm/crypto: add tunable compression algorithm for zswap
Message-ID: <20170402135659.GA10812@bombadil.infradead.org>
References: <20170401211813.15146-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170401211813.15146-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, Apr 01, 2017 at 11:18:13PM +0200, Vlastimil Babka wrote:
> In this prototype patch, it offers three predefined ratios, but nothing
> prevents more fine-grained settings, except the current crypto API (or my
> limited knowledge of it, but I'm guessing nobody really expected the
> compression ratio to be tunable). So by doing
> 
> echo tco50 > /sys/module/zswap/parameters/compressor
> 
> you get 50% compression ratio, guaranteed! This setting and zbud are just the
> perfect buddies, if you prefer the nice and simple allocator. Zero internal
> fragmentation!

[...]

> +struct tco_ctx {
> +	char ratio;
> +};

You say this is a ratio, but it's a plain char.  Clearly it should be
a floating point number; what if I want to achieve 2/3 compression?
Or if I'm a disgruntled sysadmin wanting to show how much more Linux
suxks than BSD, I might want to expand memory when it goes to swap,
perhaps taking up an extra 25%.

Maybe we could get away with char numerator; char denominator to allow
for the most common rationals, but a floating point ratio would be easier
to program with and allow for maximum flexibility.  I don't think we
need to have as much precision as a double; a plain float should suffice.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
