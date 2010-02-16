Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 93CFF6B0087
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 11:59:08 -0500 (EST)
Message-ID: <4B7ACD4A.10101@nortel.com>
Date: Tue, 16 Feb 2010 10:52:26 -0600
From: "Chris Friesen" <cfriesen@nortel.com>
MIME-Version: 1.0
Subject: Re: tracking memory usage/leak in "inactive" field in /proc/meminfo?
References: <4B71927D.6030607@nortel.com>	 <20100210093140.12D9.A69D9226@jp.fujitsu.com>	 <4B72E74C.9040001@nortel.com>	 <28c262361002101645g3fd08cc7t6a72d27b1f94db62@mail.gmail.com>	 <4B74524D.8080804@nortel.com> <28c262361002111838q7db763feh851a9bea4fdd9096@mail.gmail.com> <4B7504D2.1040903@nortel.com> <4B796D31.7030006@nortel.com> <4B797D93.5090307@redhat.com>
In-Reply-To: <4B797D93.5090307@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On 02/15/2010 11:00 AM, Rik van Riel wrote:
> On 02/15/2010 10:50 AM, Chris Friesen wrote:
> 
>> Looking at the code, it looks like page_remove_rmap() clears the
>> Anonpage flag and removes it from NR_ANON_PAGES, and the caller is
>> responsible for removing it from the LRU.  Is that right?
> 
> Nope.
> 
>> I'll keep digging in the code, but does anyone know where the removal
>> from the LRU is supposed to happen in the above code paths?
> 
> Removal from the LRU is done from the page freeing code, on
> the final free of the page.
> 
> It appears you have code somewhere that increments the reference
> count on user pages and then forgets to lower it afterwards.

Okay, that makes sense.

I'm still trying to get a handle on the LRU removal though.  The code
path that I saw most which resulted in clearing the anon bit but leaving
the page on the LRU was the following:


    [<ffffffff8029c951>] kmemleak_clear_anon+0x7f/0xbe
    [<ffffffff802864c7>] page_remove_rmap+0x45/0x146
    [<ffffffff8027dc7e>] unmap_vmas+0x41c/0x948
    [<ffffffff80282405>] exit_mmap+0x7b/0x108
    [<ffffffff8022f441>] mmput+0x33/0x110
    [<ffffffff80233b05>] exit_mm+0x103/0x130
    [<ffffffff802355b5>] do_exit+0x17b/0x91f
    [<ffffffff80235d95>] do_group_exit+0x3c/0x9c
    [<ffffffff80235e07>] sys_exit+0x0/0x12
    [<ffffffff8021ddb5>] ia32_syscall_done+0x0/0xa

There are a bunch of inline functions involved, but I think the chain
from page_remove_rmap() back up to unmap_vmas() looks like this:

page_remove_rmap
zap_pte_range
zap_pmd_range
zap_pud_range
unmap_page_range
unmap_vmas

So in this scenario, where do the pages actually get removed from the
LRU list (assuming that they're not in use by anyone else)?

Thanks,

Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
