Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D77036B0078
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 16:24:50 -0500 (EST)
Message-ID: <4B859900.6060504@redhat.com>
Date: Wed, 24 Feb 2010 16:24:16 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 36/36] khugepaged
References: <20100221141009.581909647@redhat.com>	<20100221141758.658303189@redhat.com>	<20100224121111.232602ba.akpm@linux-foundation.org>	<4B858BFC.8020801@redhat.com>	<20100224125253.2edb4571.akpm@linux-foundation.org>	<4B8592BB.1040007@redhat.com> <20100224131220.396216af.akpm@linux-foundation.org>
In-Reply-To: <20100224131220.396216af.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: aarcange@redhat.com, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On 02/24/2010 04:12 PM, Andrew Morton wrote:
> On Wed, 24 Feb 2010 15:57:31 -0500 Rik van Riel<riel@redhat.com>  wrote:
>> On 02/24/2010 03:52 PM, Andrew Morton wrote:
>>> On Wed, 24 Feb 2010 15:28:44 -0500 Rik van Riel<riel@redhat.com>   wrote:

>>> If this work could be done synchronously then runtimes become more
>>> consistent, which is a good thing.
>>
>> Only if it means run times become shorter...
>
> That of course would be a problem to be traded off against the
> advantage.  One would need to quantify these things to make that call.
>
> I asked a question and all I'm getting in reply is flippancy and
> unsubstantiated assertions.  It may have been a bad question, but
> they're certainly bad answers :(

The hugepage patchset as it stands tries to allocate huge
pages synchronously, but will fall back to normal 4kB pages
if they are not.

Similarly, khugepaged only compacts anonymous memory into
hugepages if/when hugepages become available.

Trying to always allocate hugepages synchronously would
mean potentially having to defragment memory synchronously,
before we can allocate memory for a page fault.

While I have no numbers, I have the strong suspicion that
the performance impact of potentially defragmenting 2MB
of memory before each page fault could lead to more
performance inconsistency than allocating small pages at
first and having them collapsed into large pages later...

The amount of work involved in making a 2MB page available
could be fairly big, which is why I suspect we will be
better off doing it asynchronously - preferably on otherwise
idle CPU core.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
