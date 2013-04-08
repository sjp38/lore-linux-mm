Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id C85F76B003B
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 13:17:18 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Mon, 8 Apr 2013 11:17:17 -0600
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 21A6E38C8071
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 13:17:00 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r38HGxoF278670
	for <linux-mm@kvack.org>; Mon, 8 Apr 2013 13:16:59 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r38HGxWR027172
	for <linux-mm@kvack.org>; Mon, 8 Apr 2013 14:16:59 -0300
Message-ID: <5162FB82.5020607@linux.vnet.ibm.com>
Date: Mon, 08 Apr 2013 10:16:50 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] mm: fixup changers of per cpu pageset's ->high and
 ->batch
References: <1365194030-28939-1-git-send-email-cody@linux.vnet.ibm.com> <51618F5A.3060005@gmail.com>
In-Reply-To: <51618F5A.3060005@gmail.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/07/2013 08:23 AM, KOSAKI Motohiro wrote:
> (4/5/13 4:33 PM), Cody P Schafer wrote:
>> In one case while modifying the ->high and ->batch fields of per cpu pagesets
>> we're unneededly using stop_machine() (patches 1 & 2), and in another we don't have any
>> syncronization at all (patch 3).
>>
>> This patchset fixes both of them.
>>
>> Note that it results in a change to the behavior of zone_pcp_update(), which is
>> used by memory_hotplug. I _think_ that I've diserned (and preserved) the
>> essential behavior (changing ->high and ->batch), and only eliminated unneeded
>> actions (draining the per cpu pages), but this may not be the case.
> 
> at least, memory hotplug need to drain.

Could you explain why the drain is required here? From what I can tell,
after the stop_machine() completes, the per cpu page sets could be
repopulated at any point, making the combination of draining and
modifying ->batch & ->high uneeded.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
