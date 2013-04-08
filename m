Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id ED71C6B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 18:18:50 -0400 (EDT)
Received: by mail-qc0-f178.google.com with SMTP id d10so2715313qca.23
        for <linux-mm@kvack.org>; Mon, 08 Apr 2013 15:18:50 -0700 (PDT)
Message-ID: <5163424A.4000106@gmail.com>
Date: Mon, 08 Apr 2013 18:18:50 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mm/page_alloc: convert zone_pcp_update() to use on_each_cpu()
 instead of stop_machine()
References: <1365194030-28939-1-git-send-email-cody@linux.vnet.ibm.com> <1365194030-28939-3-git-send-email-cody@linux.vnet.ibm.com> <5161931A.8060501@gmail.com> <5162FF18.8010802@linux.vnet.ibm.com> <516319FF.6030104@gmail.com> <51631F4D.7050504@linux.vnet.ibm.com>
In-Reply-To: <51631F4D.7050504@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

(4/8/13 3:49 PM), Cody P Schafer wrote:
> On 04/08/2013 12:26 PM, KOSAKI Motohiro wrote:
>> (4/8/13 1:32 PM), Cody P Schafer wrote:
>>> On 04/07/2013 08:39 AM, KOSAKI Motohiro wrote:
>>>> (4/5/13 4:33 PM), Cody P Schafer wrote:
>>>>> No off-cpu users of the percpu pagesets exist.
>>>>>
>>>>> zone_pcp_update()'s goal is to adjust the ->high and ->mark members of a
>>>>> percpu pageset based on a zone's ->managed_pages. We don't need to drain
>>>>> the entire percpu pageset just to modify these fields. Avoid calling
>>>>> setup_pageset() (and the draining required to call it) and instead just
>>>>> set the fields' values.
>>>>>
>>>>> This does change the behavior of zone_pcp_update() as the percpu
>>>>> pagesets will not be drained when zone_pcp_update() is called (they will
>>>>> end up being shrunk, not completely drained, later when a 0-order page
>>>>> is freed in free_hot_cold_page()).
>>>>>
>>>>> Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
>>>>
>>>> NAK.
>>>>
>>>> 1) zone_pcp_update() is only used from memory hotplug and it require page drain.
>>>
>>> I'm looking at this code because I'm currently working on a patchset
>>> which adds another interface which modifies zone sizes, so "only used
>>> from memory hotplug" is a temporary thing (unless I discover that
>>> zone_pcp_update() is not intended to do what I want it to do).
>>
>> maybe yes, maybe no. I don't know temporary or not. However the fact is,
>> you must not break anywhere. You need to look all caller always.
> 
> Right, which is why I want to understand memory hotplug's actual 
> requirements.
> 
>>>> 2) stop_machin is used for avoiding race. just removing it is insane.
>>>
>>> What race? Is there a cross cpu access to ->high & ->batch that makes
>>> using on_each_cpu() instead of stop_machine() inappropriate? It is
>>> absolutely not just being removed.
>>
>> OK, I missed that. however your code is still wrong.
>> However you can't call free_pcppages_bulk() from interrupt context and
>> then you can't use on_each_cpu() anyway.
> 
> Given drain_pages() implementation, I find that hard to believe (It uses 
> on_each_cpu_mask() and eventually calls free_pcppages_bulk()).
> 
> Can you provide a reference backing up your statement?

Grr. I missed again. OK you are right. go ahead.



> If this turns out to be an issue, schedule_on_each_cpu() could be an 
> alternative.

no way. schedule_on_each_cpu() is more problematic and it should be removed
in the future.
schedule_on_each_cpu() can only be used when caller task don't have any lock.
otherwise it may make deadlock.







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
