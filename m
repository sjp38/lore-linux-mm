Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A9A796B003D
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 09:52:21 -0500 (EST)
Message-ID: <4B265119.6090901@redhat.com>
Date: Mon, 14 Dec 2009 09:52:09 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan: limit concurrent reclaimers in shrink_zone
References: <20091210185626.26f9828a@cuia.bos.redhat.com> <20091214131444.GA8990@infradead.org>
In-Reply-To: <20091214131444.GA8990@infradead.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: lwoodman@redhat.com, kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

On 12/14/2009 08:14 AM, Christoph Hellwig wrote:
> On Thu, Dec 10, 2009 at 06:56:26PM -0500, Rik van Riel wrote:

>> It should be possible to avoid both of those issues at once, by
>> simply limiting how many processes are active in the page reclaim
>> code simultaneously.
>>
>
> This sounds like a very good argument against using direct reclaim at
> all.

Not completely possible.  Processes that call try_to_free_pages
without __GFP_FS or __GFP_IO in their gfp_flags may be holding
some kind of lock that kswapd could end up waiting on.

That means those tasks cannot wait on kswapd, because a deadlock
could happen.

Having said that, maybe we can get away with making direct
reclaim a limited subset of what it does today.  Kswapd could
be the only process scanning and unmapping ptes, submitting
IOs and scanning the active list.  Direct reclaim could limit
itself to reclaiming clean inactive pages and sleeping in
congestion_wait().

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
