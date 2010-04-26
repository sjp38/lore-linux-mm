Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1C0516B01EE
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 10:20:48 -0400 (EDT)
Message-ID: <4BD5A121.8060206@redhat.com>
Date: Mon, 26 Apr 2010 10:20:17 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: Subject: [PATCH][RFC] mm: make working set portion that is protected
 tunable v2
References: <20100322235053.GD9590@csn.ul.ie> <20100419214412.GB5336@cmpxchg.org>	 <4BCD55DA.2020000@linux.vnet.ibm.com> <20100420153202.GC5336@cmpxchg.org> <4BCDE2F0.3010009@redhat.com> <4BCE7DD1.70900@linux.vnet.ibm.com>	 <4BCEAAC6.7070602@linux.vnet.ibm.com> <4BCEFB4C.1070206@redhat.com>	 <4BCFEAD0.4010708@linux.vnet.ibm.com> <4BD57213.7060207@linux.vnet.ibm.com> <p2y2f11576a1004260459jcaf79962p50e4d29f990019ee@mail.gmail.com> <4BD58A6C.6040104@linux.vnet.ibm.com>
In-Reply-To: <4BD58A6C.6040104@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, gregkh@novell.com, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org, Corrado Zoccolo <czoccolo@gmail.com>
List-ID: <linux-mm.kvack.org>

On 04/26/2010 08:43 AM, Christian Ehrhardt wrote:

>>> This patch creates a knob to help users that have workloads suffering
>>> from the
>>> fix 1:1 active inactive ratio brought into the kernel by "56e49d21
>>> vmscan:
>>> evict use-once pages first".
>>> It also provides the tuning mechanisms for other users that want an
>>> even bigger
>>> working set to be protected.
>>
>> We certainly need no knob. because typical desktop users use various
>> application,
>> various workload. then, the knob doesn't help them.
>
> Briefly - We had discussed non desktop scenarios where like a day load
> that builds up the working set to 50% and a nightly backup job which
> then is unable to use that protected 50% when sequentially reading a lot
> of disks and due to that doesn't finish before morning.

This is a red herring.  A backup touches all of the
data once, so it does not need a lot of page cache
and will not "not finish before morning" due to the
working set being protected.

You're going to have to come up with a more realistic
scenario than that.

> I personally just don't feel too good knowing that 50% of my memory
> might hang around unused for many hours while they could be of some use.
> I absolutely agree with the old intention and see how the patch helped
> with the latency issue Elladan brought up in the past - but it just
> looks way too aggressive to protect it "forever" for some server use cases.

So far we have seen exactly one workload where it helps
to reduce the size of the active file list, and that is
not due to any need for caching more inactive pages.

On the contrary, it is because ALL OF THE INACTIVE PAGES
are in flight to disk, all under IO at the same time.

Caching has absolutely nothing to do with the regression
you ran into.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
