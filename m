Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id F28C36B0265
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 09:01:18 -0500 (EST)
Received: by ioir85 with SMTP id r85so57204166ioi.1
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 06:01:18 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0065.hostedemail.com. [216.40.44.65])
        by mx.google.com with ESMTP id l8si5628628igv.76.2015.11.13.06.01.17
        for <linux-mm@kvack.org>;
        Fri, 13 Nov 2015 06:01:17 -0800 (PST)
Date: Fri, 13 Nov 2015 09:01:15 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH V4] mm: fix kernel crash in khugepaged thread
Message-ID: <20151113090115.1ad4235b@gandalf.local.home>
In-Reply-To: <D7E480F5-D879-4016-B530-5A4D7CB05675@gmail.com>
References: <1447316462-19645-1-git-send-email-yalin.wang2010@gmail.com>
	<20151112092923.19ee53dd@gandalf.local.home>
	<5645BFAA.1070004@suse.cz>
	<D7E480F5-D879-4016-B530-5A4D7CB05675@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yalin wang <yalin.wang2010@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Rik van Riel <riel@redhat.com>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, jmarchan@redhat.com, mgorman@techsingularity.net, willy@linux.intel.com, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Fri, 13 Nov 2015 19:54:11 +0800
yalin wang <yalin.wang2010@gmail.com> wrote:

> >>>  	TP_fast_assign(
> >>>  		__entry->mm = mm;
> >>> -		__entry->pfn = pfn;
> >>> +		__entry->pfn = page_to_pfn(page);  
> >> 
> >> Instead of the condition, we could have:
> >> 
> >> 	__entry->pfn = page ? page_to_pfn(page) : -1;  
> > 
> > I agree. Please do it like this.  

hmm, pfn is defined as an unsigned long, would -1 be the best.
Or should it be (-1UL).

Then we could also have:

        TP_printk("mm=%p, scan_pfn=0x%lx%s, writable=%d, referenced=%d, none_or_zero=%d, status=%s, unmapped=%d",
                __entry->mm,
                __entry->pfn == (-1UL) ? 0 : __entry->pfn,
		__entry->pfn == (-1UL) ? "(null)" : "",

Note the added %s after %lx I have in the print format.

-- Steve



> ok ,  i will send V5 patch .

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
