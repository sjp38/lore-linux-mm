From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: page_alloc: Avoid marking zones full prematurely
 after zone_reclaim()
Date: Thu, 21 Mar 2013 16:59:24 +0800
Message-ID: <43796.6837700971$1363856408@news.gmane.org>
References: <20130320181957.GA1878@suse.de>
 <514A7163.5070700@gmail.com>
 <20130321081902.GD6094@dhcp22.suse.cz>
 <514AC583.2090909@gmail.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UIbLr-0008W0-ST
	for glkm-linux-mm-2@m.gmane.org; Thu, 21 Mar 2013 10:00:00 +0100
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id D5D0E6B0002
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 04:59:33 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 21 Mar 2013 14:26:47 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id CB06EE0053
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 14:30:55 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2L8xOxm5177850
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 14:29:24 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2L8xQYa016900
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 19:59:26 +1100
Content-Disposition: inline
In-Reply-To: <514AC583.2090909@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Hedi Berriche <hedi@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Mar 21, 2013 at 04:32:03PM +0800, Simon Jeons wrote:
>Hi Michal,
>On 03/21/2013 04:19 PM, Michal Hocko wrote:
>>On Thu 21-03-13 10:33:07, Simon Jeons wrote:
>>>Hi Mel,
>>>On 03/21/2013 02:19 AM, Mel Gorman wrote:
>>>>The following problem was reported against a distribution kernel when
>>>>zone_reclaim was enabled but the same problem applies to the mainline
>>>>kernel. The reproduction case was as follows
>>>>
>>>>1. Run numactl -m +0 dd if=largefile of=/dev/null
>>>>    This allocates a large number of clean pages in node 0
>>>I confuse why this need allocate a large number of clean pages?
>>It reads from file and puts pages into the page cache. The pages are not
>>modified so they are clean. Output file is /dev/null so no pages are
>>written. dd doesn't call fadvise(POSIX_FADV_DONTNEED) on the input file
>>by default so pages from the file stay in the page cache
>
>Thanks for your clarify Michal.
>dd will use page cache instead of direct IO? Where can I got dd
>source codes?
>One offline question, when should use page cache and when should use
>direct IO?

who prefer direct IO:
- the users believe they can manage caching of file contents better than 
  the kernel can. 
- the users want to avoid overflowing the page cache with data which is 
  unlikely to be of use in the near future.

Regards,
Wanpeng Li 

>
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
