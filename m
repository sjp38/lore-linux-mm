Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id A56046B0062
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 03:33:54 -0500 (EST)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 10 Dec 2012 18:29:46 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 2C1033578023
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 19:33:46 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qBA8Mp3i66977914
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 19:22:52 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qBA8XiAm026318
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 19:33:45 +1100
Date: Mon, 10 Dec 2012 16:33:42 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH V2] MCE: fix an error of mce_bad_pages statistics
Message-ID: <20121210083342.GA31670@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <50C1AD6D.7010709@huawei.com>
 <20121207141102.4fda582d.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121207141102.4fda582d.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Xishi Qiu <qiuxishi@huawei.com>
Cc: WuJianguo <wujianguo@huawei.com>, Liujiang <jiang.liu@huawei.com>, Vyacheslav.Dubeyko@huawei.com, Borislav Petkov <bp@alien8.de>, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Dec 07, 2012 at 02:11:02PM -0800, Andrew Morton wrote:
>On Fri, 7 Dec 2012 16:48:45 +0800
>Xishi Qiu <qiuxishi@huawei.com> wrote:
>
>> On x86 platform, if we use "/sys/devices/system/memory/soft_offline_page" to offline a
>> free page twice, the value of mce_bad_pages will be added twice. So this is an error,
>> since the page was already marked HWPoison, we should skip the page and don't add the
>> value of mce_bad_pages.
>> 
>> $ cat /proc/meminfo | grep HardwareCorrupted
>> 
>> soft_offline_page()
>> 	get_any_page()
>> 		atomic_long_add(1, &mce_bad_pages)
>> 
>> ...
>>
>> --- a/mm/memory-failure.c
>> +++ b/mm/memory-failure.c
>> @@ -1582,8 +1582,11 @@ int soft_offline_page(struct page *page, int flags)
>>  		return ret;
>> 
>>  done:
>> -	atomic_long_add(1, &mce_bad_pages);
>> -	SetPageHWPoison(page);
>>  	/* keep elevated page count for bad page */
>> +	if (!PageHWPoison(page)) {
>> +		atomic_long_add(1, &mce_bad_pages);
>> +		SetPageHWPoison(page);
>> +	}
>> +
>>  	return ret;
>>  }
>
>A few things:
>
>- soft_offline_page() already checks for this case:
>
>	if (PageHWPoison(page)) {
>		unlock_page(page);
>		put_page(page);
>		pr_info("soft offline: %#lx page already poisoned\n", pfn);
>		return -EBUSY;
>	}
>
>  so why didn't this check work for you?
>
>  Presumably because one of the earlier "goto done" branches was
>  taken.  Which one, any why?
>
>  This function is an utter mess.  It contains six return points
>  randomly intermingled with three "goto done" return points.
>
>  This mess is probably the cause of the bug you have observed.  Can
>  we please fix it up somehow?  It *seems* that the design (lol) of
>  this function is "for errors, return immediately.  For success, goto
>  done".  In which case "done" should have been called "success".  But
>  if you just look at the function you'll see that this approach didn't
>  work.  I suggest it be converted to have two return points - one for
>  the success path, one for the failure path.  Or something.
>
>- soft_offline_huge_page() is a miniature copy of soft_offline_page()
>  and might suffer the same bug.
>
>- A cleaner, shorter and possibly faster implementation is
>
>	if (!TestSetPageHWPoison(page))
>		atomic_long_add(1, &mce_bad_pages);
>

Hi Andrew,

Since hwpoison bit for free buddy page has already be set in get_any_page, 
!TestSetPageHWPoison(page) will not increase mce_bad_pages count even for 
the first time.

Regards,
Wanpeng Li

>- We have atomic_long_inc().  Use it?
>
>- Why do we have a variable called "mce_bad_pages"?  MCE is an x86
>  concept, and this code is in mm/.  Lights are flashing, bells are
>  ringing and a loudspeaker is blaring "layering violation" at us!
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
