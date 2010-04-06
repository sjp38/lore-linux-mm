Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A145A6B01F2
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 23:40:58 -0400 (EDT)
Message-ID: <4BBAAD3F.3090900@redhat.com>
Date: Mon, 05 Apr 2010 23:40:47 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH]vmscan: handle underflow for get_scan_ratio
References: <20100406105324.7E30.A69D9226@jp.fujitsu.com> <20100406023043.GA12420@localhost> <20100406115543.7E39.A69D9226@jp.fujitsu.com> <20100406033114.GB13169@localhost>
In-Reply-To: <20100406033114.GB13169@localhost>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Li, Shaohua" <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 04/05/2010 11:31 PM, Wu Fengguang wrote:
> On Tue, Apr 06, 2010 at 10:58:43AM +0800, KOSAKI Motohiro wrote:
>> Again, I didn't said his patch is no worth. I only said we don't have to
>> ignore the downside.
>
> Right, we should document both the upside and downside.

The downside is obvious: streaming IO (used once data
that does not fit in the cache) can push out data that
is used more often - requiring that it be swapped in
at a later point in time.

I understand what Shaohua's patch does, but I do not
understand the upside.  What good does it do to increase
the size of the cache for streaming IO data, which is
generally touched only once?

What kind of performance benefits can we get by doing
that?

> The main difference happens when file:anon scan ratio>  100:1.
>
> For the current percent[] based computing, percent[0]=0 hence nr[0]=0
> which disables anon list scan unconditionally, for good or for bad.
>
> For the direct nr[] computing,
> - nr[0] will be 0 for typical file servers, because with priority=12
>    and anon lru size<  1.6GB, nr[0] = (anon_size/4096)/100<  0
> - nr[0] will be non-zero when priority=1 and anon_size>  100 pages,
>    this stops OOM for Shaohua's test case, however may not be enough to
>    guarantee safety (your previous reverting patch can provide this
>    guarantee).
>
> I liked Shaohua's patch a lot -- it adapts well to both the
> file-server case and the mostly-anon-pages case :)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
