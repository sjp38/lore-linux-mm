Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f172.google.com (mail-vc0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id 75B086B0037
	for <linux-mm@kvack.org>; Wed, 28 May 2014 18:41:12 -0400 (EDT)
Received: by mail-vc0-f172.google.com with SMTP id ik5so9888102vcb.3
        for <linux-mm@kvack.org>; Wed, 28 May 2014 15:41:12 -0700 (PDT)
Received: from mail-vc0-x236.google.com (mail-vc0-x236.google.com [2607:f8b0:400c:c03::236])
        by mx.google.com with ESMTPS id lx4si11910895veb.29.2014.05.28.15.41.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 28 May 2014 15:41:11 -0700 (PDT)
Received: by mail-vc0-f182.google.com with SMTP id id10so1119759vcb.27
        for <linux-mm@kvack.org>; Wed, 28 May 2014 15:41:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140528223142.GO8554@dastard>
References: <1401260039-18189-1-git-send-email-minchan@kernel.org>
	<1401260039-18189-2-git-send-email-minchan@kernel.org>
	<CA+55aFxXdc22dirnE49UbQP_2s2vLQpjQFL+NptuyK7Xry6c=g@mail.gmail.com>
	<20140528223142.GO8554@dastard>
Date: Wed, 28 May 2014 15:41:11 -0700
Message-ID: <CA+55aFyRk6_v6COPGVvu6hvt=i2A8-dPcs1X3Ydn1g24AxbPkg@mail.gmail.com>
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Minchan Kim <minchan@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>

On Wed, May 28, 2014 at 3:31 PM, Dave Chinner <david@fromorbit.com> wrote:
>
> Indeed, the call chain reported here is not caused by swap issuing
> IO.

Well, that's one way of reading that callchain.

I think it's the *wrong* way of reading it, though. Almost dishonestly
so. Because very clearly, the swapout _is_ what causes the unplugging
of the IO queue, and does so because it is allocating the BIO for its
own IO. The fact that that then fails (because of other IO's in
flight), and causes *other* IO to be flushed, doesn't really change
anything fundamental. It's still very much swap that causes that
"let's start IO".

IOW, swap-out directly caused that extra 3kB of stack use in what was
a deep call chain (due to memory allocation). I really don't
understand why you are arguing anything else on a pure technicality.

I thought you had some other argument for why swap was different, and
against removing that "page_is_file_cache()" special case in
shrink_page_list().

                         Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
