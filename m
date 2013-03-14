From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/4] zcache: add pageframes count once compress
 zero-filled pages twice
Date: Fri, 15 Mar 2013 07:41:52 +0800
Message-ID: <41886.4388055683$1363304551@news.gmane.org>
References: <1363158321-20790-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1363158321-20790-5-git-send-email-liwanp@linux.vnet.ibm.com>
 <634487ea-fbbd-4eb9-9a18-9206edc4e0d2@default>
 <20130314002056.GA10062@hacker.(null)>
 <d02b5afd-bcb0-47df-9960-8e2122a04ad8@default>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UGHn2-0008P6-C1
	for glkm-linux-mm-2@m.gmane.org; Fri, 15 Mar 2013 00:42:28 +0100
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 5FE236B0027
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 19:42:03 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 15 Mar 2013 05:09:26 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id E0E6C3940055
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 05:11:55 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2ENfoL99437586
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 05:11:50 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2ENfrnB017833
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 10:41:54 +1100
Content-Disposition: inline
In-Reply-To: <d02b5afd-bcb0-47df-9960-8e2122a04ad8@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Mar 14, 2013 at 09:10:48AM -0700, Dan Magenheimer wrote:
>> From: Wanpeng Li [mailto:liwanp@linux.vnet.ibm.com]
>> Sent: Wednesday, March 13, 2013 6:21 PM
>> To: Dan Magenheimer
>> Cc: Andrew Morton; Greg Kroah-Hartman; Dan Magenheimer; Seth Jennings; Konrad Rzeszutek Wilk; Minchan
>> Kim; linux-mm@kvack.org; linux-kernel@vger.kernel.org
>> Subject: Re: [PATCH 4/4] zcache: add pageframes count once compress zero-filled pages twice
>> 
>> On Wed, Mar 13, 2013 at 09:42:16AM -0700, Dan Magenheimer wrote:
>> >> From: Wanpeng Li [mailto:liwanp@linux.vnet.ibm.com]
>> >> Sent: Wednesday, March 13, 2013 1:05 AM
>> >> To: Andrew Morton
>> >> Cc: Greg Kroah-Hartman; Dan Magenheimer; Seth Jennings; Konrad Rzeszutek Wilk; Minchan Kim; linux-
>> >> mm@kvack.org; linux-kernel@vger.kernel.org; Wanpeng Li
>> >> Subject: [PATCH 4/4] zcache: add pageframes count once compress zero-filled pages twice
>> >
>> >Hi Wanpeng --
>> >
>> >Thanks for taking on this task from the drivers/staging/zcache TODO list!
>> >
>> >> Since zbudpage consist of two zpages, two zero-filled pages compression
>> >> contribute to one [eph|pers]pageframe count accumulated.
>> >
>> 
>> Hi Dan,
>> 
>> >I'm not sure why this is necessary.  The [eph|pers]pageframe count
>> >is supposed to be counting actual pageframes used by zcache.  Since
>> >your patch eliminates the need to store zero pages, no pageframes
>> >are needed at all to store zero pages, so it's not necessary
>> >to increment zcache_[eph|pers]_pageframes when storing zero
>> >pages.
>> >
>> 
>> Great point! It seems that we also don't need to caculate
>> zcache_[eph|pers]_zpages for zero-filled pages. I will fix
>> it in next version. :-)
>
>Hi Wanpeng --
>

Hi Dan,

>I think we DO need to increment/decrement zcache_[eph|pers]_zpages
>for zero-filled pages.
>
>The main point of the counters for zpages and pageframes
>is to be able to calculate density == zpages/pageframes.
>A zero-filled page becomes a zpage that "compresses" to zero bytes
>and, as a result, requires zero pageframes for storage.
>So the zpages counter should be increased but the pageframes
>counter should not.

It is reasonable to me, I will increment/decrement zcache_[eph|pers]_zpages
in next version.

>
>If you are changing the patch anyway, I do like better the use
>of "zero_filled_page" rather than just "zero" or "zero page".
>So it might be good to change:
>
>handle_zero_page -> handle_zero_filled_page
>pages_zero -> zero_filled_pages
>zcache_pages_zero -> zcache_zero_filled_pages
>
>and maybe
>
>page_zero_filled -> page_is_zero_filled

Great rename! :-)

Regards,
Wanpeng Li 

>
>Thanks,
>Dan
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
