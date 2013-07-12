Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 2C3E46B0031
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 12:31:49 -0400 (EDT)
Message-ID: <51E02F6E.1060303@sr71.net>
Date: Fri, 12 Jul 2013 09:31:42 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 1/5] mm, page_alloc: support multiple pages allocation
References: <1372840460-5571-1-git-send-email-iamjoonsoo.kim@lge.com> <1372840460-5571-2-git-send-email-iamjoonsoo.kim@lge.com> <51DDE5BA.9020800@intel.com> <20130711010248.GB7756@lge.com> <51DE44CC.2070700@sr71.net> <20130711061201.GA2400@lge.com>
In-Reply-To: <20130711061201.GA2400@lge.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/10/2013 11:12 PM, Joonsoo Kim wrote:
> On Wed, Jul 10, 2013 at 10:38:20PM -0700, Dave Hansen wrote:
>> You're probably right for small numbers of pages.  But, if we're talking
>> about things that are more than, say, 100 pages (isn't the pcp batch
>> size clamped to 128 4k pages?) you surely don't want to be doing
>> buffered_rmqueue().
> 
> Yes, you are right.
> Firstly, I thought that I can use this for readahead. On my machine,
> readahead reads (maximum) 32 pages in advance if faulted. And batch size
> of percpu pages list is close to or larger than 32 pages
> on today's machine. So I didn't consider more than 32 pages before.
> But to cope with a request for more pages, using rmqueue_bulk() is
> a right way. How about using rmqueue_bulk() conditionally?

How about you test it both ways and see what is faster?

> Hmm, rmqueue_bulk() doesn't stop until all requested pages are allocated.
> If we request too many pages (1024 pages or more), interrupt latency can
> be a problem.

OK, so only call it for the number of pages you believe allows it to
have acceptable interrupt latency.  If you want 200 pages, and you can
only disable interrupts for 100 pages, then just do it in two batches.

The point is that you want to avoid messing with the buffering by the
percpu structures.  They're just overhead in your case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
