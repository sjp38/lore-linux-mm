Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 52ECF6B005A
	for <linux-mm@kvack.org>; Sun,  9 Dec 2012 23:39:53 -0500 (EST)
Message-ID: <50C5660D.4050805@huawei.com>
Date: Mon, 10 Dec 2012 12:33:17 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2] MCE: fix an error of mce_bad_pages statistics
References: <50C1AD6D.7010709@huawei.com> <20121207141102.4fda582d.akpm@linux-foundation.org>
In-Reply-To: <20121207141102.4fda582d.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: WuJianguo <wujianguo@huawei.com>, Liujiang <jiang.liu@huawei.com>, Vyacheslav.Dubeyko@huawei.com, Borislav Petkov <bp@alien8.de>, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2012/12/8 6:11, Andrew Morton wrote:

> On Fri, 7 Dec 2012 16:48:45 +0800
> Xishi Qiu <qiuxishi@huawei.com> wrote:
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
> A few things:
> 
> - soft_offline_page() already checks for this case:
> 
> 	if (PageHWPoison(page)) {
> 		unlock_page(page);
> 		put_page(page);
> 		pr_info("soft offline: %#lx page already poisoned\n", pfn);
> 		return -EBUSY;
> 	}
> 
>   so why didn't this check work for you?
> 
>   Presumably because one of the earlier "goto done" branches was
>   taken.  Which one, any why?
> 
>   This function is an utter mess.  It contains six return points
>   randomly intermingled with three "goto done" return points.
> 
>   This mess is probably the cause of the bug you have observed.  Can
>   we please fix it up somehow?  It *seems* that the design (lol) of
>   this function is "for errors, return immediately.  For success, goto
>   done".  In which case "done" should have been called "success".  But
>   if you just look at the function you'll see that this approach didn't
>   work.  I suggest it be converted to have two return points - one for
>   the success path, one for the failure path.  Or something.
> 
> - soft_offline_huge_page() is a miniature copy of soft_offline_page()
>   and might suffer the same bug.
> 
> - A cleaner, shorter and possibly faster implementation is
> 
> 	if (!TestSetPageHWPoison(page))
> 		atomic_long_add(1, &mce_bad_pages);
> 
> - We have atomic_long_inc().  Use it?
> 
> - Why do we have a variable called "mce_bad_pages"?  MCE is an x86
>   concept, and this code is in mm/.  Lights are flashing, bells are
>   ringing and a loudspeaker is blaring "layering violation" at us!
> 

Hi Andrew, thank you for your advice, I will send V3 soon.

Thanks
Xishi Qiu

> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
