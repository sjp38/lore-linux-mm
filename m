Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 975176B0031
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 02:08:02 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so1870338pad.2
        for <linux-mm@kvack.org>; Sun, 22 Sep 2013 23:08:02 -0700 (PDT)
Received: by mail-ie0-f172.google.com with SMTP id x13so5675875ief.31
        for <linux-mm@kvack.org>; Sun, 22 Sep 2013 23:08:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <523FA230.3020902@oracle.com>
References: <000701ceaac0$71c43590$554ca0b0$%yang@samsung.com>
	<20130909162909.GB4701@variantweb.net>
	<523FA230.3020902@oracle.com>
Date: Mon, 23 Sep 2013 14:07:59 +0800
Message-ID: <CAL1ERfM7Xzbi5UNqwNnMtg=aeeTABL8ad9h7XL4VVSR_iVRxTA@mail.gmail.com>
Subject: Re: [PATCH v2 3/4] mm/zswap: avoid unnecessary page scanning
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Weijie Yang <weijie.yang@samsung.com>, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Sep 23, 2013 at 10:06 AM, Bob Liu <bob.liu@oracle.com> wrote:
>
> On 09/10/2013 12:29 AM, Seth Jennings wrote:
>> On Fri, Sep 06, 2013 at 01:16:45PM +0800, Weijie Yang wrote:
>>> add SetPageReclaim before __swap_writepage so that page can be moved to the
>>> tail of the inactive list, which can avoid unnecessary page scanning as this
>>> page was reclaimed by swap subsystem before.
>>>
>>> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
>>
>> Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
>>
>
> Below is a reply from Mel in original thread "[PATCHv11 3/4] zswap: add
> to mm/"
> ------------------
>> +     /* start writeback */
>> +     SetPageReclaim(page);
>> +     __swap_writepage(page, &wbc, end_swap_bio_write);
>> +     page_cache_release(page);
>> +     zswap_written_back_pages++;
>> +
>
> SetPageReclaim? Why?. If the page is under writeback then why do you not
> mark it as that? Do not free pages that are currently under writeback
> obviously. It's likely that it was PageWriteback you wanted in zbud.c too.
> --------------------

Thanks for reminding this.

The purpose of using this flag in PATCHv11 and this patch is different.

In PATCHv11, it was repurposed to protect zbud page against free,
and now it is replaced with zhdr->under_reclaim.

In this patch, this flag is for its original purpose(to be reclaimed asap)

> --
> Regards,
> -Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
