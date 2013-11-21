Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id E9A226B0036
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 17:39:09 -0500 (EST)
Received: by mail-wg0-f42.google.com with SMTP id k14so670813wgh.3
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 14:39:09 -0800 (PST)
Received: from mail-wi0-x236.google.com (mail-wi0-x236.google.com [2a00:1450:400c:c05::236])
        by mx.google.com with ESMTPS id hi12si1601703wib.1.2013.11.21.14.39.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 21 Nov 2013 14:39:09 -0800 (PST)
Received: by mail-wi0-f182.google.com with SMTP id en1so1809046wid.3
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 14:39:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <528D570D.3020006@oracle.com>
References: <1384976973-32722-1-git-send-email-ddstreet@ieee.org> <528D570D.3020006@oracle.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Thu, 21 Nov 2013 17:38:49 -0500
Message-ID: <CALZtONDyXdmzF_K7X+GNA0wY1yDn7k3t1FmQq4J=8=smX9XSoA@mail.gmail.com>
Subject: Re: [PATCH v2] mm/zswap: change zswap to writethrough cache
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>
Cc: Seth Jennings <sjennings@variantweb.net>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>

On Wed, Nov 20, 2013 at 7:42 PM, Bob Liu <bob.liu@oracle.com> wrote:
> Hi Dan,
>
> On 11/21/2013 03:49 AM, Dan Streetman wrote:
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
>
> Good work!
>
>> This changes zswap to writethrough cache by enabling
>> frontswap_writethrough() before registering, so that any
>> successful page store will also be written to swap disk.  All the
>> writeback code is removed since it is no longer needed, and the
>> only operation during a page eviction is now to remove the entry
>> from the tree and free it.
>>
>
> Could you do some testing using eg. SPECjbb? And compare the result with
> original zswap.

Sure, I have a small test program that I used for performance
comparisions, which I'll send and include some results, and I'll also
try to find a copy of SPECjbb to get results with.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
