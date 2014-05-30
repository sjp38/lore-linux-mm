Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f171.google.com (mail-vc0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id 3F6AE6B003A
	for <linux-mm@kvack.org>; Fri, 30 May 2014 00:37:04 -0400 (EDT)
Received: by mail-vc0-f171.google.com with SMTP id lc6so1495999vcb.30
        for <linux-mm@kvack.org>; Thu, 29 May 2014 21:37:03 -0700 (PDT)
Received: from mail-vc0-x22d.google.com (mail-vc0-x22d.google.com [2607:f8b0:400c:c03::22d])
        by mx.google.com with ESMTPS id t10si2243639ven.41.2014.05.29.21.37.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 May 2014 21:37:03 -0700 (PDT)
Received: by mail-vc0-f173.google.com with SMTP id il7so1486081vcb.4
        for <linux-mm@kvack.org>; Thu, 29 May 2014 21:37:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140530021247.GR10092@bbox>
References: <1401260039-18189-1-git-send-email-minchan@kernel.org>
	<1401260039-18189-2-git-send-email-minchan@kernel.org>
	<CA+55aFxXdc22dirnE49UbQP_2s2vLQpjQFL+NptuyK7Xry6c=g@mail.gmail.com>
	<20140528223142.GO8554@dastard>
	<CA+55aFyRk6_v6COPGVvu6hvt=i2A8-dPcs1X3Ydn1g24AxbPkg@mail.gmail.com>
	<20140529013007.GF6677@dastard>
	<20140529015830.GG6677@dastard>
	<20140529233638.GJ10092@bbox>
	<20140530001558.GB14410@dastard>
	<20140530021247.GR10092@bbox>
Date: Thu, 29 May 2014 21:37:02 -0700
Message-ID: <CA+55aFzzHS9YSzZpxMoF1vwoBh+NxLE26Tr2OC38=PsB8Mjwig@mail.gmail.com>
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Dave Chinner <david@fromorbit.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>

On Thu, May 29, 2014 at 7:12 PM, Minchan Kim <minchan@kernel.org> wrote:
>
> Interim report,
>
> And result is as follows, It reduce about 800-byte compared to
> my first report but still stack usage seems to be high.
> Really needs diet of VM functions.

Yes. And in this case uninlining things might actually help, because
the it's not actually performing reclaim in the second case, so
inlining the reclaim code into that huge __alloc_pages_nodemask()
function means that it has the stack frame for all those cases even if
they don't actually get used.

That said, the way those functions are set up (with lots of arguments
passed from one to the other), not inlining will cause huge costs too
for the argument setup.

It really might be very good to create a "struct alloc_info" that
contains those shared arguments, and just pass a (const) pointer to
that around. Gcc would likely tend to be *much* better at generating
code for that, because it avoids a tons of temporaries being created
by function calls. Even when it's inlined, the argument itself ends up
being a new temporary internally, and I suspect one reason gcc
(especially your 4.6.3 version, apparently) generates those big spill
frames is because there's tons of these duplicate temporaries that
apparently don't get merged properly.

Ugh. I think I'll try looking at that tomorrow.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
