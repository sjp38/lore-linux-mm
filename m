Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id DC34E8D003B
	for <linux-mm@kvack.org>; Mon,  4 Apr 2011 09:18:20 -0400 (EDT)
Received: by ewy9 with SMTP id 9so2184451ewy.14
        for <linux-mm@kvack.org>; Mon, 04 Apr 2011 06:15:10 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 04/12] mm: alloc_contig_freed_pages() added
References: <1301577368-16095-1-git-send-email-m.szyprowski@samsung.com>
 <1301577368-16095-5-git-send-email-m.szyprowski@samsung.com>
 <1301587083.31087.1032.camel@nimitz> <op.vs77qfx03l0zgt@mnazarewicz-glaptop>
 <1301606078.31087.1275.camel@nimitz> <op.vs8awkrx3l0zgt@mnazarewicz-glaptop>
 <1301610411.30870.29.camel@nimitz> <op.vs8cf5xd3l0zgt@mnazarewicz-glaptop>
 <1301666596.30870.176.camel@nimitz>
Date: Mon, 04 Apr 2011 15:15:07 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.vte0fgez3l0zgt@mnazarewicz-glaptop>
In-Reply-To: <1301666596.30870.176.camel@nimitz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-samsung-soc@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Andrew
 Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel
 Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, Mel Gorman <mel@csn.ul.ie>, Pawel
 Osciak <pawel@osciak.com>

> On Fri, 2011-04-01 at 00:51 +0200, Michal Nazarewicz wrote:
>> The function is called from alloc_contig_range() (see patch 05/12) which
>> makes sure that the PFN is valid.  Situation where there is not enough
>> space is caught earlier in alloc_contig_range().
>>
>> alloc_contig_freed_pages() must be given a valid PFN range such that all
>> the pages in that range are free (as in are within the region tracked by
>> page allocator) and of MIGRATE_ISOLATE so that page allocator won't
>> touch them.

On Fri, 01 Apr 2011 16:03:16 +0200, Dave Hansen wrote:
> OK, so it really is a low-level function only.  How about a comment that
> explicitly says this?  "Only called from $FOO with the area already
> isolated."  It probably also deserves an __ prefix.

Yes, it's not really for general use.  Comment may indeed be useful here.

>> That's why invalid PFN is a bug in the caller and not an exception that
>> has to be handled.
>>
>> Also, the function is not called during boot time.  It is called while
>> system is already running.

> What kind of success have you had running this in practice?  I'd be
> worried that some silly task or a sticky dentry would end up in the
> range that you want to allocate in.

I'm not sure what you are asking.

The function requires the range to be marked as MIGRATE_ISOLATE and all
pages being free, so nothing can be allocated there while the function
is running.

If you are asking about CMA in general, the range that CMA uses is marked
as MIGRATE_CMA (a new migrate type) which means that only MIGRATE_MOVABLE
pages can be allocated there.  This means, that in theory, if there is
enough memory the pages can always be moved out of the region.  At leasts
that's my understanding of the type.  If this is correct, the allocation
should always succeed provided enough memory for the pages within the
region to be moved to is available.

As of practice, I have run some simple test to see if the code works and
they succeeded.  Also, Marek has run some test with actual hardware and
those worked well as well (but I'll let Marek talk about any details).

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
