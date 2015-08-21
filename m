Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 08F0D6B0253
	for <linux-mm@kvack.org>; Fri, 21 Aug 2015 16:44:24 -0400 (EDT)
Received: by igfj19 with SMTP id j19so26347844igf.0
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 13:44:23 -0700 (PDT)
Received: from mail-io0-x236.google.com (mail-io0-x236.google.com. [2607:f8b0:4001:c06::236])
        by mx.google.com with ESMTPS id x3si2283820igl.101.2015.08.21.13.44.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Aug 2015 13:44:23 -0700 (PDT)
Received: by iods203 with SMTP id s203so94634593iod.0
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 13:44:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <197171440188481@webcorp01e.yandex-team.ru>
References: <CA+55aFz64=vB5vRDj0N0jukWBNnVDd5vf27GL4is6vbYrM17LQ@mail.gmail.com>
	<1440177121-12741-1-git-send-email-klamm@yandex-team.ru>
	<CA+55aFyc8bb=ASmQbhk72cFOOmGpNhowdWGtSn+biog69_f+LA@mail.gmail.com>
	<197171440188481@webcorp01e.yandex-team.ru>
Date: Fri, 21 Aug 2015 13:44:23 -0700
Message-ID: <CA+55aFy8kOomnL-C5GwSpHTn+g5R7dY78C9=h-J_Rb_u=iASpg@mail.gmail.com>
Subject: Re: [PATCH] mm: use only per-device readahead limit
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <klamm@yandex-team.ru>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Aug 21, 2015 at 1:21 PM, Roman Gushchin <klamm@yandex-team.ru> wrote:
>
> It's just a raid driver. For instance, drivers/md/raid5.c:6898 .

Ok. That makes me a bit less nervous. I was worried there was some
admin program out there that just ups the readahead on peoples
devices, which would mean that ra_pages is some random value chosen by
crazy user space people.

> So, I like an idea to delegate the readahead limit calculation to the underlying i/o level.

Yeah, I'm not against it either. It's just that historically we've had
some issues with people over-doing readahead (because it often helps
some made-up microbenchmark), and then we end up with latency issues
when somebody does a multi-gigabyte readahead... Iirc, we had exactly
that problem with the readahead() system call at some point (long
ago).

But if it's just the default ra_pages, then that should be ok. I think
the kernel defaults are generally sane, and I hope there isn't some
crazy distro that ends up mucking with this.

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
