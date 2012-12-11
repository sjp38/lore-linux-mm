Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 90AEB6B007D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 03:02:47 -0500 (EST)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 11 Dec 2012 17:56:35 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id AD04E2BB004E
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 19:02:40 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qBB82dOA57934000
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 19:02:40 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qBB82cGD025098
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 19:02:39 +1100
Date: Tue, 11 Dec 2012 16:02:37 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH V2] MCE: fix an error of mce_bad_pages statistics
Message-ID: <20121211080236.GA29541@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <20121207141102.4fda582d.akpm@linux-foundation.org>
 <20121210083342.GA31670@hacker.(null)>
 <50C5A62A.6030401@huawei.com>
 <1355136423.1700.2.camel@kernel.cn.ibm.com>
 <50C5C4A2.2070002@huawei.com>
 <1355140561.1821.5.camel@kernel.cn.ibm.com>
 <50C5D844.8050707@huawei.com>
 <1355143664.1821.8.camel@kernel.cn.ibm.com>
 <20121211011643.GA15754@hacker.(null)>
 <50C6D762.4030507@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50C6D762.4030507@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Simon Jeons <simon.jeons@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, WuJianguo <wujianguo@huawei.com>, Liujiang <jiang.liu@huawei.com>, Vyacheslav.Dubeyko@huawei.com, Borislav Petkov <bp@alien8.de>, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, wency@cn.fujitsu.com

On Tue, Dec 11, 2012 at 02:49:06PM +0800, Xishi Qiu wrote:
>>>> Hi Simon,
>
>>>>
>>>> If we use "/sys/devices/system/memory/soft_offline_page" to offline a
>>>> free page, the value of mce_bad_pages will be added. Then the page is marked
>>>> HWPoison, but it is still managed by page buddy alocator.
>>>>
>>>> So if we offline it again, the value of mce_bad_pages will be added again.
>>>> Assume the page is not allocated during this short time.
>>>>
>>>> soft_offline_page()
>>>> 	get_any_page()
>>>> 		"else if (is_free_buddy_page(p))" branch return 0
>>>> 			"goto done";
>>>> 				"atomic_long_add(1, &mce_bad_pages);"
>>>>
>>>> I think it would be better to move "if(PageHWPoison(page))" at the beginning of
>>>> soft_offline_page(). However I don't know what do these words mean,
>>>> "Synchronized using the page lock with memory_failure()"
>> 
>> Hi Xishi,
>> 
>> Unpoison will clear PG_hwpoison flag after hold page lock, memory_failure() and 
>> soft_offline_page() take the lock to avoid unpoison clear the flag behind them.
>> 
>> Regards,
>> Wanpeng Li 
>> 
>
>Hi Wanpeng,
>
>As you mean, it is the necessary to get the page lock first when we check the
>HWPoison flag every time, this is in order to avoid conflict, right?
>

Hi Xishi,

Avoid race.

>So why not use a globe lock here? For example lock_memory_hotplug() is used in
>online_pages() and offline_pages()?

Just for a single page, a global lock maybe more contend.

Regards,
Wanpeng Li

>
>Thanks,
>Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
