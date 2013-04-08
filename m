Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 679F56B0039
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 15:26:58 -0400 (EDT)
Received: by mail-qc0-f177.google.com with SMTP id u28so2667006qcs.22
        for <linux-mm@kvack.org>; Mon, 08 Apr 2013 12:26:57 -0700 (PDT)
Message-ID: <516319FF.6030104@gmail.com>
Date: Mon, 08 Apr 2013 15:26:55 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mm/page_alloc: convert zone_pcp_update() to use on_each_cpu()
 instead of stop_machine()
References: <1365194030-28939-1-git-send-email-cody@linux.vnet.ibm.com> <1365194030-28939-3-git-send-email-cody@linux.vnet.ibm.com> <5161931A.8060501@gmail.com> <5162FF18.8010802@linux.vnet.ibm.com>
In-Reply-To: <5162FF18.8010802@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

(4/8/13 1:32 PM), Cody P Schafer wrote:
> On 04/07/2013 08:39 AM, KOSAKI Motohiro wrote:
>> (4/5/13 4:33 PM), Cody P Schafer wrote:
>>> No off-cpu users of the percpu pagesets exist.
>>>
>>> zone_pcp_update()'s goal is to adjust the ->high and ->mark members of a
>>> percpu pageset based on a zone's ->managed_pages. We don't need to drain
>>> the entire percpu pageset just to modify these fields. Avoid calling
>>> setup_pageset() (and the draining required to call it) and instead just
>>> set the fields' values.
>>>
>>> This does change the behavior of zone_pcp_update() as the percpu
>>> pagesets will not be drained when zone_pcp_update() is called (they will
>>> end up being shrunk, not completely drained, later when a 0-order page
>>> is freed in free_hot_cold_page()).
>>>
>>> Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
>>
>> NAK.
>>
>> 1) zone_pcp_update() is only used from memory hotplug and it require page drain.
> 
> I'm looking at this code because I'm currently working on a patchset
> which adds another interface which modifies zone sizes, so "only used
> from memory hotplug" is a temporary thing (unless I discover that
> zone_pcp_update() is not intended to do what I want it to do).

maybe yes, maybe no. I don't know temporary or not. However the fact is, 
you must not break anywhere. You need to look all caller always.


>> 2) stop_machin is used for avoiding race. just removing it is insane.
> 
> What race? Is there a cross cpu access to ->high & ->batch that makes
> using on_each_cpu() instead of stop_machine() inappropriate? It is
> absolutely not just being removed.

OK, I missed that. however your code is still wrong.
However you can't call free_pcppages_bulk() from interrupt context and
then you can't use on_each_cpu() anyway.






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
