Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 3CA966B0035
	for <linux-mm@kvack.org>; Sat, 23 Nov 2013 15:35:56 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id x12so2387722wgg.4
        for <linux-mm@kvack.org>; Sat, 23 Nov 2013 12:35:55 -0800 (PST)
Received: from mail-wi0-x231.google.com (mail-wi0-x231.google.com [2a00:1450:400c:c05::231])
        by mx.google.com with ESMTPS id y12si4715803wiv.74.2013.11.23.12.35.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 23 Nov 2013 12:35:55 -0800 (PST)
Received: by mail-wi0-f177.google.com with SMTP id cc10so2577214wib.4
        for <linux-mm@kvack.org>; Sat, 23 Nov 2013 12:35:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAL1ERfNWXFmKFbVf2H1G7A=rVfxh+0ScN_yn_YcH=VsUr3bVjg@mail.gmail.com>
References: <1384976973-32722-1-git-send-email-ddstreet@ieee.org>
 <1385158216-6247-1-git-send-email-ddstreet@ieee.org> <CAL1ERfNWXFmKFbVf2H1G7A=rVfxh+0ScN_yn_YcH=VsUr3bVjg@mail.gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Sat, 23 Nov 2013 15:35:35 -0500
Message-ID: <CALZtONByDcL+yd3rMfFmrW_a2dV3ZV8XKiWcxba-oWTWeGNVVQ@mail.gmail.com>
Subject: Re: [PATCH v3] mm/zswap: change zswap to writethrough cache
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang.kh@gmail.com>
Cc: Seth Jennings <sjennings@variantweb.net>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Bob Liu <bob.liu@oracle.com>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>

On Fri, Nov 22, 2013 at 9:37 PM, Weijie Yang <weijie.yang.kh@gmail.com> wrote:
> Hello Dan,
>
> On Sat, Nov 23, 2013 at 6:10 AM, Dan Streetman <ddstreet@ieee.org> wrote:
>> Currently, zswap is writeback cache; stored pages are not sent
>> to swap disk, and when zswap wants to evict old pages it must
>> first write them back to swap cache/disk manually.  This avoids
>> swap out disk I/O up front, but only moves that disk I/O to
>> the writeback case (for pages that are evicted), and adds the
>> overhead of having to uncompress the evicted pages, and adds the
>> need for an additional free page (to store the uncompressed page)
>> at a time of likely high memory pressure.  Additionally, being
>> writeback adds complexity to zswap by having to perform the
>> writeback on page eviction.
>>
>> This changes zswap to writethrough cache by enabling
>> frontswap_writethrough() before registering, so that any
>> successful page store will also be written to swap disk.  All the
>> writeback code is removed since it is no longer needed, and the
>> only operation during a page eviction is now to remove the entry
>> from the tree and free it.
>
> I agree with Seth, It is not good to embedded device.
> May be we can find its place in others like server.
> I guess it is good to medium workload when swap io is not frequent.
>
> My suggestion is would you please make it configurable so that user
> can choice to use writethrough or writeback mode?
>

Having to support both significantly increases complexity and I think
would make further improvements more difficult.  My opinion is the
writeback code should be removed.  Is there anyone else who thinks
both should be available by a param?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
