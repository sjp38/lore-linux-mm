Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id C18626B0081
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 01:50:23 -0500 (EST)
Message-ID: <50C6D762.4030507@huawei.com>
Date: Tue, 11 Dec 2012 14:49:06 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2] MCE: fix an error of mce_bad_pages statistics
References: <50C1AD6D.7010709@huawei.com> <20121207141102.4fda582d.akpm@linux-foundation.org> <20121210083342.GA31670@hacker.(null)> <50C5A62A.6030401@huawei.com> <1355136423.1700.2.camel@kernel.cn.ibm.com> <50C5C4A2.2070002@huawei.com> <1355140561.1821.5.camel@kernel.cn.ibm.com> <50C5D844.8050707@huawei.com> <1355143664.1821.8.camel@kernel.cn.ibm.com> <20121211011643.GA15754@hacker.(null)>
In-Reply-To: <20121211011643.GA15754@hacker.(null)>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Simon Jeons <simon.jeons@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, WuJianguo <wujianguo@huawei.com>, Liujiang <jiang.liu@huawei.com>, Vyacheslav.Dubeyko@huawei.com, Borislav Petkov <bp@alien8.de>, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, wency@cn.fujitsu.com

>>> Hi Simon,

>>>
>>> If we use "/sys/devices/system/memory/soft_offline_page" to offline a
>>> free page, the value of mce_bad_pages will be added. Then the page is marked
>>> HWPoison, but it is still managed by page buddy alocator.
>>>
>>> So if we offline it again, the value of mce_bad_pages will be added again.
>>> Assume the page is not allocated during this short time.
>>>
>>> soft_offline_page()
>>> 	get_any_page()
>>> 		"else if (is_free_buddy_page(p))" branch return 0
>>> 			"goto done";
>>> 				"atomic_long_add(1, &mce_bad_pages);"
>>>
>>> I think it would be better to move "if(PageHWPoison(page))" at the beginning of
>>> soft_offline_page(). However I don't know what do these words mean,
>>> "Synchronized using the page lock with memory_failure()"
> 
> Hi Xishi,
> 
> Unpoison will clear PG_hwpoison flag after hold page lock, memory_failure() and 
> soft_offline_page() take the lock to avoid unpoison clear the flag behind them.
> 
> Regards,
> Wanpeng Li 
> 

Hi Wanpeng,

As you mean, it is the necessary to get the page lock first when we check the
HWPoison flag every time, this is in order to avoid conflict, right?

So why not use a globe lock here? For example lock_memory_hotplug() is used in
online_pages() and offline_pages()?

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
