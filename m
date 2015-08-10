Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f176.google.com (mail-yk0-f176.google.com [209.85.160.176])
	by kanga.kvack.org (Postfix) with ESMTP id 219D76B0038
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 12:36:41 -0400 (EDT)
Received: by ykaz130 with SMTP id z130so36670949yka.0
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 09:36:40 -0700 (PDT)
Received: from mail-yk0-x231.google.com (mail-yk0-x231.google.com. [2607:f8b0:4002:c07::231])
        by mx.google.com with ESMTPS id w5si11578950ykd.51.2015.08.10.09.36.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Aug 2015 09:36:40 -0700 (PDT)
Received: by ykaz130 with SMTP id z130so36670681yka.0
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 09:36:40 -0700 (PDT)
Date: Mon, 10 Aug 2015 12:36:38 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH] percpu: Prevent endless loop if there is no
 unallocated region
Message-ID: <20150810163638.GC23408@mtj.duckdns.org>
References: <1439122659-31442-1-git-send-email-linux@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1439122659-31442-1-git-send-email-linux@roeck-us.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

On Sun, Aug 09, 2015 at 05:17:39AM -0700, Guenter Roeck wrote:
> Qemu tests with unicore32 show memory management code entering an endless
> loop in pcpu_alloc(). Bisect points to commit a93ace487a33 ("percpu: move
> region iterations out of pcpu_[de]populate_chunk()"). Code analysis
> identifies the following relevant changes.
> 
> -       rs = page_start;
> -       pcpu_next_pop(chunk, &rs, &re, page_end);
> -
> -       if (rs != page_start || re != page_end) {
> +       pcpu_for_each_unpop_region(chunk, rs, re, page_start, page_end) {
> 
> For unicore32, values were page_start==0, page_end==1, rs==0, re==1.
> This worked fine with the old code. With the new code, however, the loop
> is always entered. Debugging information added into the loop shows
> an endless repetition of
> 
> in loop chunk c5c53100 populated 0xff rs 1 re 2 page start 0 page end 1
> in loop chunk c5c53100 populated 0xff rs 1 re 2 page start 0 page end 1
> in loop chunk c5c53100 populated 0xff rs 1 re 2 page start 0 page end 1
> in loop chunk c5c53100 populated 0xff rs 1 re 2 page start 0 page end 1

That's a bug in the find bit functions in unicore32.  If @offset >=
@end, it should return @end, not @offset.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
