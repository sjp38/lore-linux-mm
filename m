Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9904B8D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 17:17:56 -0400 (EDT)
Received: by ewy9 with SMTP id 9so1143810ewy.14
        for <linux-mm@kvack.org>; Thu, 31 Mar 2011 14:17:53 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 05/12] mm: alloc_contig_range() added
References: <1301577368-16095-1-git-send-email-m.szyprowski@samsung.com>
 <1301577368-16095-6-git-send-email-m.szyprowski@samsung.com>
 <1301587361.31087.1040.camel@nimitz> <op.vs7umufd3l0zgt@mnazarewicz-glaptop>
 <1301603322.31087.1196.camel@nimitz>
Date: Thu, 31 Mar 2011 23:17:51 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.vs7731po3l0zgt@mnazarewicz-glaptop>
In-Reply-To: <1301603322.31087.1196.camel@nimitz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-samsung-soc@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Andrew
 Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel
 Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, Mel Gorman <mel@csn.ul.ie>, Pawel
 Osciak <pawel@osciak.com>

On Thu, 31 Mar 2011 22:28:42 +0200, Dave Hansen <dave@linux.vnet.ibm.com>  
wrote:

> On Thu, 2011-03-31 at 18:26 +0200, Michal Nazarewicz wrote:
>> > On Thu, 2011-03-31 at 15:16 +0200, Marek Szyprowski wrote:
>> >> +       ret = 0;
>> >> +       while (!PageBuddy(pfn_to_page(start & (~0UL << ret))))
>> >> +               if (WARN_ON(++ret >= MAX_ORDER))
>> >> +                       return -EINVAL;
>>
>> On Thu, 31 Mar 2011 18:02:41 +0200, Dave Hansen wrote:
>> > Holy cow, that's dense.  Is there really no more straightforward way  
>> to
>> > do that?
>>
>> Which part exactly is dense?  What would be qualify as a more
>> straightforward way?
>
> I'm still not 100% sure what it's trying to do.  It looks like it
> attempts to check all of "start"'s buddy pages.

No.  I'm going up through parents.  This is because even though start
falls in a free block (ie. one that page allocator tracks), the actual
page that is in buddy system is larger then start and this loop looks
for beginning of that page.

> int order;
> for (order = 0; order <= MAX_ORDER; order++) {
> 	unsigned long buddy_pfn = find_buddy(start, order);
> 	struct page *buddy = pfn_to_page(buddy_pfn);
> 	if (PageBuddy(buddy)
> 		break;
> 	WARN();
> 	return -EINVAL;
> }

The WARN() and return would have to be outside of the loop and, as I
described, instead of find_buddy() something like find_parent() would
have to be used.

> I'm wondering also if you can share some code with __rmqueue().

Doubtful since start does not (have to) point to a page that is tracked
by page allocator but a page inside such a page.

-- 
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=./ `o
..o | Computer Science,  Michal "mina86" Nazarewicz    (o o)
ooo +-----<email/xmpp: mnazarewicz@google.com>-----ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
