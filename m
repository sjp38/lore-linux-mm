Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 64D376B006C
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:52:02 -0500 (EST)
Received: by vcbfk26 with SMTP id fk26so5103409vcb.14
        for <linux-mm@kvack.org>; Mon, 12 Dec 2011 06:52:01 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 03/11] mm: mmzone: introduce zone_pfn_same_memmap()
References: <1321634598-16859-1-git-send-email-m.szyprowski@samsung.com>
 <1321634598-16859-4-git-send-email-m.szyprowski@samsung.com>
 <20111212141953.GD3277@csn.ul.ie> <op.v6dr4pj43l0zgt@mpn-glaptop>
 <20111212144030.GF3277@csn.ul.ie>
Date: Mon, 12 Dec 2011 15:51:55 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v6dswtfw3l0zgt@mpn-glaptop>
In-Reply-To: <20111212144030.GF3277@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel
 Walker <dwalker@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Jesse
 Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq
 Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>

> On Fri, Nov 18, 2011 at 05:43:10PM +0100, Marek Szyprowski wrote:
>> From: Michal Nazarewicz <mina86@mina86.com>
>> diff --git a/mm/compaction.c b/mm/compaction.c
>> index 6afae0e..09c9702 100644
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -111,7 +111,10 @@ skip:
>>
>>  next:
>>  		pfn +=3D isolated;
>> -		page +=3D isolated;
>> +		if (zone_pfn_same_memmap(pfn - isolated, pfn))
>> +			page +=3D isolated;
>> +		else
>> +			page =3D pfn_to_page(pfn);
>>  	}

On Mon, 12 Dec 2011 15:19:53 +0100, Mel Gorman <mel@csn.ul.ie> wrote:
> Is this necessary?
>
> We are isolating pages, the largest of which is a MAX_ORDER_NR_PAGES
> page.  [...]

On Mon, 12 Dec 2011 15:40:30 +0100, Mel Gorman <mel@csn.ul.ie> wrote:
> To be clear, I'm referring to a single page being isolated here. It ma=
y
> or may not be a high-order page but it's still going to be less then
> MAX_ORDER_NR_PAGES so you should be able check when a new block is
> entered and pfn_to_page is necessary.

Do you mean something like:

if (same pageblock)
	just do arithmetic;
else
	use pfn_to_page;

?

I've discussed it with Dave and he suggested that approach as an
optimisation since in some configurations zone_pfn_same_memmap()
is always true thus compiler will strip the else part, whereas
same pageblock test will be false on occasions regardless of kernel
configuration.

-- =

Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz=
    (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
