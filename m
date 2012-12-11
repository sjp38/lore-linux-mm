From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH V2] MCE: fix an error of mce_bad_pages statistics
Date: Tue, 11 Dec 2012 14:34:31 +0800
Message-ID: <46601.0803742849$1355207703@news.gmane.org>
References: <50C5C4A2.2070002@huawei.com>
 <20121210153805.GS16230@one.firstfloor.org>
 <1355190540.1933.4.camel@kernel.cn.ibm.com>
 <20121211020313.GV16230@one.firstfloor.org>
 <1355192071.1933.7.camel@kernel.cn.ibm.com>
 <20121211030125.GY16230@one.firstfloor.org>
 <1355195591.1933.18.camel@kernel.cn.ibm.com>
 <20121211031907.GZ16230@one.firstfloor.org>
 <1355197690.1933.20.camel@kernel.cn.ibm.com>
 <50C6CAC3.1090809@huawei.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1TiJQh-0008GB-W6
	for glkm-linux-mm-2@m.gmane.org; Tue, 11 Dec 2012 07:35:00 +0100
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 54DF86B0078
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 01:34:45 -0500 (EST)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 11 Dec 2012 16:30:36 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id C94AD3578023
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 17:34:35 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qBB6YYHV45154520
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 17:34:35 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qBB6YXp9014713
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 17:34:34 +1100
Content-Disposition: inline
In-Reply-To: <50C6CAC3.1090809@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Simon Jeons <simon.jeons@gmail.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, WuJianguo <wujianguo@huawei.com>, Liujiang <jiang.liu@huawei.com>, Vyacheslav.Dubeyko@huawei.com, Borislav Petkov <bp@alien8.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, wency@cn.fujitsu.com

On Tue, Dec 11, 2012 at 01:55:15PM +0800, Xishi Qiu wrote:
>On 2012/12/11 11:48, Simon Jeons wrote:
>
>> On Tue, 2012-12-11 at 04:19 +0100, Andi Kleen wrote:
>>> On Mon, Dec 10, 2012 at 09:13:11PM -0600, Simon Jeons wrote:
>>>> On Tue, 2012-12-11 at 04:01 +0100, Andi Kleen wrote:
>>>>>> Oh, it will be putback to lru list during migration. So does your "some
>>>>>> time" mean before call check_new_page?
>>>>>
>>>>> Yes until the next check_new_page() whenever that is. If the migration
>>>>> works it will be earlier, otherwise later.
>>>>
>>>> But I can't figure out any page reclaim path check if the page is set
>>>> PG_hwpoison, can poisoned pages be rclaimed?
>>>
>>> The only way to reclaim a page is to free and reallocate it.
>> 
>> Then why there doesn't have check in reclaim path to avoid relcaim
>> poisoned page?
>> 
>> 			-Simon
>
>Hi Simon,
>
>If the page is free, it will be set PG_hwpoison, and soft_offline_page() is done.
>When the page is alocated later, check_new_page() will find the poisoned page and
>isolate the whole buddy block(just drop the block).
>
>If the page is not free, soft_offline_page() try to free it first, if this is
>failed, it will migrate the page, but the page is still in LRU list after migration,
>migrate_pages()
>	unmap_and_move()
>		if (rc != -EAGAIN) {
>			...
>			putback_lru_page(page);
>		}
>We can use lru_add_drain_all() to drain lru pagevec, at last free_hot_cold_page()

Hi Xishi,

I don't understand why you need drain lru pagevec here, if the page has
been migrated has all references removed and then it will be freed. The 
putback_lru_page mentioned above will call put_page free to it. 

putback_lru_page
	->put_page
		->__put_single_page
			->free_hot_cold_page
				->free_page_check
					->free_pages_prepare
						->free_pages_check
							->bad_page

Regards,
Wanpeng Li 

>will be called, and free_pages_prepare() check the poisoned pages.
>free_pages_prepare()
>	free_pages_check()
>		bad_page()
>
>Is this right, Andi?
>
>Thanks
>Xishi Qiu
>
>>>
>>> -Andi
>> 
>> 
>> 
>> 
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
