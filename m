Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 7B75D6B005C
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 14:40:57 -0400 (EDT)
Received: by obhx4 with SMTP id x4so12343261obh.14
        for <linux-mm@kvack.org>; Mon, 16 Jul 2012 11:40:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <871ukbr4d3.fsf@erwin.mina86.com>
References: <1342455272-32703-1-git-send-email-js1304@gmail.com>
	<1342455272-32703-3-git-send-email-js1304@gmail.com>
	<871ukbr4d3.fsf@erwin.mina86.com>
Date: Tue, 17 Jul 2012 03:40:56 +0900
Message-ID: <CAAmzW4MpWsxd2nG-xsdw_D89-Prx7PPuWSEbuS7Nw0rTmcChig@mail.gmail.com>
Subject: Re: [PATCH 3/3] mm: fix return value in __alloc_contig_migrate_range()
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>

2012/7/17 Michal Nazarewicz <mina86@mina86.com>:
> Joonsoo Kim <js1304@gmail.com> writes:
>
>> migrate_pages() would return positive value in some failure case,
>> so 'ret > 0 ? 0 : ret' may be wrong.
>> This fix it and remove one dead statement.
>>
>> Signed-off-by: Joonsoo Kim <js1304@gmail.com>
>> Cc: Michal Nazarewicz <mina86@mina86.com>
>> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
>> Cc: Minchan Kim <minchan@kernel.org>
>> Cc: Christoph Lameter <cl@linux.com>
>
> Have you actually encountered this problem?  If migrate_pages() fails
> with a positive value, the code that you are removing kicks in and
> -EBUSY is assigned to ret (now that I look at it, I think that in the
> current code the "return ret > 0 ? 0 : ret;" statement could be reduced
> to "return ret;").  Your code seems to be cleaner, but the commit
> message does not look accurate to me.
>

I don't encounter this problem yet.

If migrate_pages() with offlining false meets KSM page, then migration failed.
In this case, failed page is removed from cc.migratepage list and
return failed count.
So it can be possible exiting loop without testing ++tries == 5 and
ret is over the zero.
Is there any point which I missing?
Is there any possible scenario "migrate_pages return  > 0 and
cc.migratepages is empty"?

I'm not expert for MM, so please comment my humble opinion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
