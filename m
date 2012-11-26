Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 9FD746B0062
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 10:58:15 -0500 (EST)
Received: by mail-ie0-f169.google.com with SMTP id c14so3682885ieb.14
        for <linux-mm@kvack.org>; Mon, 26 Nov 2012 07:58:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121122151028.GA1834@t510.redhat.com>
References: <cover.1352656285.git.aquini@redhat.com> <6602296b38c073a5c6faa13ddbc74ceb1eceb2dd.1352656285.git.aquini@redhat.com>
 <50A7D0FA.2080709@gmail.com> <20121117215434.GA23879@x61.redhat.com>
 <CA+1xoqfbxL-mL3XRDXxnuv0R6b9w6qxU7t+8U3FwS2eK5Sf0OA@mail.gmail.com>
 <20121120141438.GA21672@x61.redhat.com> <50AC2BCC.6050507@gmail.com>
 <20121122000114.GB1815@t510.redhat.com> <50AE3463.1040107@gmail.com> <20121122151028.GA1834@t510.redhat.com>
From: Sasha Levin <levinsasha928@gmail.com>
Date: Mon, 26 Nov 2012 10:57:54 -0500
Message-ID: <CA+1xoqe_-bN929UF79w3hB-8+jQhmfbr0v8Xt9yEWE7QBEsV2w@mail.gmail.com>
Subject: Re: [PATCH v12 4/7] mm: introduce compaction and migration for
 ballooned pages
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, "Michael S. Tsirkin" <mst@redhat.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Rusty Russell <rusty@rustcorp.com.au>

On Thu, Nov 22, 2012 at 10:10 AM, Rafael Aquini <aquini@redhat.com> wrote:
> On Thu, Nov 22, 2012 at 09:19:15AM -0500, Sasha Levin wrote:
>> And managed to reproduce it only once through last night, here is the dump I got
>> before the oops:
>>
>> [ 2760.356820] page:ffffea0000d00e00 count:1 mapcount:-2147287036 mapping:00000000000004f4 index:0xd00e00000003
>> [ 2760.362354] page flags: 0x350000000001800(private|private_2)
>>
>
> Thanks alot for following up this one Sasha.
>
>
> We're stumbling across a private page -- seems something in your setup is doing
> this particular usage, and that's probably why I'm not seeing the same here.
>
> Regardless being a particular case or not, we shouldn't be poking at that
> private page, so I figured the tests I'm doing at balloon_page_movable() are
> incomplete and dumb.
>
> Perhaps, a better way to proceed here would be assuring the NR_PAGEFLAGS
> rightmost bits from page->flags are all cleared, as this is the state a page
> coming from buddy to the balloon list will be, and this is the state the balloon
> page flags will be kept as long as it lives as such (we don't play with any flag
> at balloon level).
>
>
> Here goes what I'll propose after you confirm it doesn't trigger your crash
> anymore, as it simplifies the code and reduces the testing battery @
> balloon_page_movable() -- ballooned pages have no flags set, 1 refcount and 0
> mapcount, always.
>
>
> Could you give this a try?
>
> Thank you!

Ran it for a while, no more BUGs, yay :)


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
