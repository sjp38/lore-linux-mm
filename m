Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 936D18D0039
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 14:25:50 -0500 (EST)
Message-ID: <4D39DDA6.1080604@oracle.com>
Date: Fri, 21 Jan 2011 11:25:26 -0800
From: Andy Grover <andy.grover@oracle.com>
MIME-Version: 1.0
Subject: Re: [RESEND PATCH] mm: Use spin_lock_irqsave in __set_page_dirty_nobuffers
References: <1294726534-16438-1-git-send-email-andy.grover@oracle.com> <20110121001804.413b3f6d.akpm@linux-foundation.org>
In-Reply-To: <20110121001804.413b3f6d.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, rds-devel@oss.oracle.com
List-ID: <linux-mm.kvack.org>

On 01/21/2011 12:18 AM, Andrew Morton wrote:
> On Mon, 10 Jan 2011 22:15:34 -0800 Andy Grover<andy.grover@oracle.com>  wrote:
>
>> RDS is calling set_page_dirty from interrupt context,
>
> yikes.  Whatever possessed you to try that?

When doing an RDMA read into pinned pages, we get notified the operation 
is complete in a tasklet, and would like to mark the pages dirty and 
unpin in the same context.

The issue was __set_page_dirty_buffers (via calling set_page_dirty) was 
unconditionally re-enabling irqs as a side-effect because it was using 
*_irq instead of *_irqsave/restore.

How would you recommend we proceed? My understanding was calling 
set_page_dirty prior to issuing the operation isn't an option since it 
might get cleaned too early.

Thanks -- Regards -- Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
