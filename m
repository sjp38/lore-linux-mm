Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 55D586B0038
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 19:33:28 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 17so49633256pfy.2
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 16:33:28 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id we6si5734119pab.81.2016.11.14.16.33.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Nov 2016 16:33:27 -0800 (PST)
Date: Mon, 14 Nov 2016 16:33:26 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] z3fold: discourage use of pages that weren't compacted
Message-Id: <20161114163326.b5e991b77745bed6db221bfe@linux-foundation.org>
In-Reply-To: <20161111140207.1a5d89af4e0b37e9d23dcd36@gmail.com>
References: <20161111140207.1a5d89af4e0b37e9d23dcd36@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Dan Streetman <ddstreet@ieee.org>

On Fri, 11 Nov 2016 14:02:07 +0100 Vitaly Wool <vitalywool@gmail.com> wrote:

> If a z3fold page couldn't be compacted, we don't want it to be
> used for next object allocation in the first place. It makes more
> sense to add it to the end of the relevant unbuddied list. If that
> page gets compacted later, it will be added to the beginning of
> the list then.
> 
> This simple idea gives 5-7% improvement in randrw fio tests and
> about 10% improvement in fio sequential read/write.

This patch appears to require "z3fold: use per-page spinlock", and
"z3fold: use per-page spinlock" doesn't apply properly.

So things are in a bit of a mess.

I presently have

z3fold-limit-first_num-to-the-actual-range-of-possible-buddy-indexes.patch
z3fold-make-pages_nr-atomic.patch
z3fold-extend-compaction-function.patch

Please take a look, figure out what we should do.  Perhaps do it all as
a coherent series rather than an interdependent dribble?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
