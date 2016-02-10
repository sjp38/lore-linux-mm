Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 7F7FB6B0259
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 15:50:41 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id p63so46656753wmp.1
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 12:50:41 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [78.46.96.112])
        by mx.google.com with ESMTP id b188si7776148wme.79.2016.02.10.12.50.40
        for <linux-mm@kvack.org>;
        Wed, 10 Feb 2016 12:50:40 -0800 (PST)
Date: Wed, 10 Feb 2016 21:50:35 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v10 3/4] x86, mce: Add __mcsafe_copy()
Message-ID: <20160210205035.GB11832@pd.tnic>
References: <cover.1454618190.git.tony.luck@intel.com>
 <6b63a88e925bbc821dc87f209909c3c1166b3261.1454618190.git.tony.luck@intel.com>
 <20160207164933.GE5862@pd.tnic>
 <20160209231557.GA23207@agluck-desk.sc.intel.com>
 <20160210105843.GD23914@pd.tnic>
 <20160210193905.GB29493@agluck-desk.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20160210193905.GB29493@agluck-desk.sc.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, elliott@hpe.com, Brian Gerst <brgerst@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org

On Wed, Feb 10, 2016 at 11:39:05AM -0800, Luck, Tony wrote:
> On Wed, Feb 10, 2016 at 11:58:43AM +0100, Borislav Petkov wrote:
> > But one could take out that function do some microbenchmarking with
> > different sizes and once with the current version and once with the
> > pushes and pops of r1[2-5] to see where the breakeven is.
> 
> On a 4K page copy from a source address that isn't in the
> cache I see all sorts of answers.
> 
> On my desktop (i7-3960X) it is ~50 cycles slower to push and pop the four
> registers.
> 
> On my latest Xeon - I can't post benchmarks ... but also a bit slower.
> 
> On an older Xeon it is a few cycles faster (but even though I'm
> looking at the median of 10,000 runs I see more run-to-run variation
> that I see difference between register choices.

Hmm, strange. Can you check whether perf doesn't show any significant
differences too. Something like:

perf stat --repeat 100 --sync --pre 'echo 3 > /proc/sys/vm/drop_caches' -- ./mcsafe_copy_1

and then

perf stat --repeat 100 --sync --pre 'echo 3 > /proc/sys/vm/drop_caches' -- ./mcsafe_copy_2

That'll be interesting...

Thanks.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
