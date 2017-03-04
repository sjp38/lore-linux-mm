Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3CC956B0038
	for <linux-mm@kvack.org>; Sat,  4 Mar 2017 06:53:12 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id a189so174011851qkc.4
        for <linux-mm@kvack.org>; Sat, 04 Mar 2017 03:53:12 -0800 (PST)
Received: from mail-qk0-x230.google.com (mail-qk0-x230.google.com. [2607:f8b0:400d:c09::230])
        by mx.google.com with ESMTPS id f129si11466017qkc.42.2017.03.04.03.53.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 04 Mar 2017 03:53:11 -0800 (PST)
Received: by mail-qk0-x230.google.com with SMTP id n127so214112826qkf.0
        for <linux-mm@kvack.org>; Sat, 04 Mar 2017 03:53:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170303144329.94d47b1015ba2f18f64c5893@linux-foundation.org>
References: <20170301143905.12846-1-ying.huang@intel.com> <20170303144329.94d47b1015ba2f18f64c5893@linux-foundation.org>
From: huang ying <huang.ying.caritas@gmail.com>
Date: Sat, 4 Mar 2017 19:53:10 +0800
Message-ID: <CAC=cRTPFDNpCKvjqMj+ggMoQND9tme4w+AGX31Yu2B4uzzPWZg@mail.gmail.com>
Subject: Re: [PATCH] mm, swap: Fix a race in free_swap_and_cache()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Tim Chen <tim.c.chen@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi, Andrew,

Sorry, I clicked the wrong button in my mail client, so forgot Ccing
mailing list.  Sorry for duplicated mail.

On Sat, Mar 4, 2017 at 6:43 AM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Wed,  1 Mar 2017 22:38:09 +0800 "Huang, Ying" <ying.huang@intel.com> wrote:
>
>> Before using cluster lock in free_swap_and_cache(), the
>> swap_info_struct->lock will be held during freeing the swap entry and
>> acquiring page lock, so the page swap count will not change when
>> testing page information later.  But after using cluster lock, the
>> cluster lock (or swap_info_struct->lock) will be held only during
>> freeing the swap entry.  So before acquiring the page lock, the page
>> swap count may be changed in another thread.  If the page swap count
>> is not 0, we should not delete the page from the swap cache.  This is
>> fixed via checking page swap count again after acquiring the page
>> lock.
>
> What are the user-visible runtime effects of this bug?  Please always
> include this info when fixing things, thanks.

Sure.  I find the race when I review the code, so I didn't trigger the
race via a test program.  If the race occurs for an anonymous page
shared by multiple processes via fork, multiple pages will be
allocated and swapped in from the swap device for the previously
shared one page.  That is, the user-visible runtime effect is more
memory will be used and the access latency for the page will be
higher, that is, the performance regression.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
