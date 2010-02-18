Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 33E8A6B0082
	for <linux-mm@kvack.org>; Thu, 18 Feb 2010 10:46:04 -0500 (EST)
Message-ID: <4B7D5F35.7060700@nortel.com>
Date: Thu, 18 Feb 2010 09:39:33 -0600
From: "Chris Friesen" <cfriesen@nortel.com>
MIME-Version: 1.0
Subject: Re: tracking memory usage/leak in "inactive" field in /proc/meminfo?
 -- solved
References: <4B71927D.6030607@nortel.com>	 <20100210093140.12D9.A69D9226@jp.fujitsu.com>	 <4B72E74C.9040001@nortel.com>	 <28c262361002101645g3fd08cc7t6a72d27b1f94db62@mail.gmail.com>	 <4B74524D.8080804@nortel.com> <28c262361002111838q7db763feh851a9bea4fdd9096@mail.gmail.com> <4B7504D2.1040903@nortel.com> <4B796D31.7030006@nortel.com> <4B797D93.5090307@redhat.com> <4B7ACD4A.10101@nortel.com> <4B7AD207.20604@redhat.com> <4B7B0D75.50808@nortel.com> <4B7B1AA9.9040609@redhat.com>
In-Reply-To: <4B7B1AA9.9040609@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On 02/16/2010 04:22 PM, Rik van Riel wrote:
> On 02/16/2010 04:26 PM, Chris Friesen wrote:
> 
>> For the backtrace scenario I posted it seems like it might actually be
>> release_pages().  There seems to be a plausible call chain:
>>
>> __ClearPageLRU
>> release_pages
>> free_pages_and_swap_cache
>> tlb_flush_mmu
>> tlb_remove_page
>> zap_pte_range
>>
>> Does that seem right?  In this case, tlb_remove_page() is called right
>> after page_remove_rmap() which ultimately results in clearing the
>> PageAnon bit.
> 
> That is right - and pinpoints the fault for the memory leak
> on some third party code that fails to release a refcount on
> memory pages.

I think I've tracked down the source of the problem.  Turns out one of
our vendors had misapplied a patch which ended up bumping the page count
an extra time.

Thanks to everyone that helped out.

Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
