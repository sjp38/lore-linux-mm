Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 7B2706B0068
	for <linux-mm@kvack.org>; Wed,  5 Dec 2012 04:54:25 -0500 (EST)
Message-ID: <50BF198D.3030509@parallels.com>
Date: Wed, 05 Dec 2012 13:53:17 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/2] mm: Add ability to monitor task's memory changes
References: <50B8F2F4.6000508@parallels.com>  <20121203144310.7ccdbeb4.akpm@linux-foundation.org>  <50BD86DE.6050700@parallels.com>  <20121204152121.e5c33938.akpm@linux-foundation.org>  <1354666628.6733.227.camel@calx>  <20121204162411.700d4954.akpm@linux-foundation.org> <1354667937.6733.233.camel@calx>
In-Reply-To: <1354667937.6733.233.camel@calx>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>

On 12/05/2012 04:38 AM, Matt Mackall wrote:
> On Tue, 2012-12-04 at 16:24 -0800, Andrew Morton wrote:
>> On Tue, 04 Dec 2012 18:17:08 -0600
>> Matt Mackall <mpm@selenic.com> wrote:
>>
>>> On Tue, 2012-12-04 at 15:21 -0800, Andrew Morton wrote:
>>>> On Tue, 04 Dec 2012 09:15:10 +0400
>>>> Pavel Emelyanov <xemul@parallels.com> wrote:
>>>>
>>>>>
>>>>>> Two alternatives come to mind:
>>>>>>
>>>>>> 1)  Use /proc/pid/pagemap (Documentation/vm/pagemap.txt) in some
>>>>>>     fashion to determine which pages have been touched.
>>>
>>> [momentarily coming out of kernel retirement for old man rant]
>>>
>>> This is a popular interface anti-pattern.
>>>
>>> You shouldn't use an interface that gives you huge amount of STATE to
>>> detect small amounts of CHANGE via manual differentiation.
>>
>> I'm not sure that's what checkpoint-restart will be doing.  If we want
>> to determine "which pages have been touched since the last checkpoint
>> ten minutes ago" then that set of touched pages *is* state.  And it's
>> not "small"!
> 
> Yeah, there is definitely a middle-ground here between "I want
> high-frequency updates" and "I want to see the whole picture". 
> The filesystem analogy is backups: we don't have any good way to say
> "find me all files changed since yesterday" short of "find all files".
> The closest thing is explicit snapshotting.

For what is required for checkpoint-restore is -- we want to query the kernel
for "what pages has been written to since moment X". But this "moment X" is
a little bit more tricky than just "mark all pages r/o". Consider we're doing
this periodically. So when defining the moment X for the 2nd time we should
query the "changed" state and remap the respective page r/o atomically. Full
snapshot is actually not required, since we don't need to keep the old copy
of a page that is written to. Just a sign, that this page was modified is OK.


Thanks,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
