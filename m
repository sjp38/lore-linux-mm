Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1E5656B0031
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 16:44:33 -0500 (EST)
Received: by mail-wg0-f51.google.com with SMTP id l18so358845wgh.30
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 13:44:32 -0800 (PST)
Received: from mail-wg0-x22a.google.com (mail-wg0-x22a.google.com [2a00:1450:400c:c00::22a])
        by mx.google.com with ESMTPS id hi12si1519602wib.1.2013.11.21.13.44.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 21 Nov 2013 13:44:31 -0800 (PST)
Received: by mail-wg0-f42.google.com with SMTP id k14so622357wgh.5
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 13:44:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAL1ERfPcAbNyt9hTYKMj9OGK2=ynLrTVm9udEn=hF+bFptC16Q@mail.gmail.com>
References: <1384976909-32671-1-git-send-email-ddstreet@ieee.org> <CAL1ERfPcAbNyt9hTYKMj9OGK2=ynLrTVm9udEn=hF+bFptC16Q@mail.gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Thu, 21 Nov 2013 16:44:11 -0500
Message-ID: <CALZtONByWEv-vyx8+HMn+o53hPO4L_UY-+BbLRrBoWx-u2UejA@mail.gmail.com>
Subject: Re: [PATCH] mm/zswap: don't allow entry eviction if in use by load
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang.kh@gmail.com>
Cc: Seth Jennings <sjennings@variantweb.net>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Bob Liu <bob.liu@oracle.com>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>

On Wed, Nov 20, 2013 at 8:59 PM, Weijie Yang <weijie.yang.kh@gmail.com> wrote:
> Hello Dan
>
> On Thu, Nov 21, 2013 at 3:48 AM, Dan Streetman <ddstreet@ieee.org> wrote:
>> The changes in commit 0ab0abcf511545d1fddbe72a36b3ca73388ac937
>> introduce a bug in writeback, if an entry is in use by load
>> it will be evicted anyway, which isn't correct (technically,
>> the code currently in zbud doesn't actually care much what the
>> zswap evict function returns, but that could change).
>
> Thanks for your work. Howerver it is not a bug.
>
> I have thought about this situation, and it will never happen.
> If entry is being loaded, its corresponding page must be in swapcache
> so zswap_get_swap_cache_page() will return ZSWAP_SWAPCACHE_EXIST

ah, ok.

While you do imply that with the fail: comment, I personally think it
should also be stated in the refcount check comment; a comment
indicating failure can happen due to concurrent load does not make
clear that it will *always* fail in cases of concurrent load and so
that case doesn't need to be checked for in the success path.
Additionally, the lack of a check here is assuming that zswap won't be
updated to ever inc the refcount anywhere besides the load function,
which might cause unexpected breakage later; i.e., this is coding to
the current implementation, not to the entry->refcount api.

Can I also ask why you do a rb_search instead of just checking the
entry->refcount?  Doing the search is going to take longer than just
checking the refcount; is there some case where the entry will not be
in the rb but will have a nonzero refcount?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
