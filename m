Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id 993CE6B0253
	for <linux-mm@kvack.org>; Fri, 21 Aug 2015 16:21:26 -0400 (EDT)
Received: by lbbsx3 with SMTP id sx3so50426416lbb.0
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 13:21:26 -0700 (PDT)
Received: from forward-corp1f.mail.yandex.net (forward-corp1f.mail.yandex.net. [2a02:6b8:0:801::10])
        by mx.google.com with ESMTPS id xi9si7139053lbb.4.2015.08.21.13.21.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Aug 2015 13:21:25 -0700 (PDT)
From: Roman Gushchin <klamm@yandex-team.ru>
In-Reply-To: <CA+55aFyc8bb=ASmQbhk72cFOOmGpNhowdWGtSn+biog69_f+LA@mail.gmail.com>
References: <CA+55aFz64=vB5vRDj0N0jukWBNnVDd5vf27GL4is6vbYrM17LQ@mail.gmail.com>
	<1440177121-12741-1-git-send-email-klamm@yandex-team.ru> <CA+55aFyc8bb=ASmQbhk72cFOOmGpNhowdWGtSn+biog69_f+LA@mail.gmail.com>
Subject: Re: [PATCH] mm: use only per-device readahead limit
MIME-Version: 1.0
Message-Id: <197171440188481@webcorp01e.yandex-team.ru>
Date: Fri, 21 Aug 2015 23:21:21 +0300
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=koi8-r
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>

21.08.2015, 21:17, "Linus Torvalds" <torvalds@linux-foundation.org>:
> On Fri, Aug 21, 2015 at 10:12 AM, Roman Gushchin <klamm@yandex-team.ru> wrote:
>> ?There are devices, which require custom readahead limit.
>> ?For instance, for RAIDs it's calculated as number of devices
>> ?multiplied by chunk size times 2.
>
> So afaik, the default read-ahead size is 128kB, which is actually
> smaller than the old 512-page limit.
>
> Which means that you probably changed "ra_pages" somehow. Is it some
> system tool that does that automatically, and if so based on what,
> exactly?

It's just a raid driver. For instance, drivers/ms/raid5.c:6898 .

On my setup I got unexpectedly even slight perfomance increase 
over O_DIRECT case and over old memory-based readahead limit, 
as you can see from numbers in the commit message (1.2GB/s vs 1.1 GB/s).

So, I like an idea to delegate the readahead limit calculation to the underlying i/o level.

> I'm also slightly worried about the fact that now the max read-ahead
> may actually be zero, 

For "normal" readahead nothing changes. Only readahead syscall and 
madvise(MADV_WILL_NEED) cases are affected.
I think, it's ok to do nothing, if readahead was deliberately disabled.

> and/or basically infinite (there's a ioctl to
> set it that only tests that it's not negative). Does everything react
> ok to that?

It's an open question, if we have to add some checks to avoid miss-configuration.
In any case, we can check the limit on setting rather then adjust them dynamically.

--
Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
