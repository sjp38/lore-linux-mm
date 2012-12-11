Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 1CBB16B0071
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 00:55:48 -0500 (EST)
Message-ID: <50C6CAC3.1090809@huawei.com>
Date: Tue, 11 Dec 2012 13:55:15 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2] MCE: fix an error of mce_bad_pages statistics
References: <20121210083342.GA31670@hacker.(null)>  <50C5A62A.6030401@huawei.com> <1355136423.1700.2.camel@kernel.cn.ibm.com>  <50C5C4A2.2070002@huawei.com> <20121210153805.GS16230@one.firstfloor.org>  <1355190540.1933.4.camel@kernel.cn.ibm.com>  <20121211020313.GV16230@one.firstfloor.org>  <1355192071.1933.7.camel@kernel.cn.ibm.com>  <20121211030125.GY16230@one.firstfloor.org>  <1355195591.1933.18.camel@kernel.cn.ibm.com>  <20121211031907.GZ16230@one.firstfloor.org> <1355197690.1933.20.camel@kernel.cn.ibm.com>
In-Reply-To: <1355197690.1933.20.camel@kernel.cn.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Andi Kleen <andi@firstfloor.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, WuJianguo <wujianguo@huawei.com>, Liujiang <jiang.liu@huawei.com>, Vyacheslav.Dubeyko@huawei.com, Borislav Petkov <bp@alien8.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, wency@cn.fujitsu.com

On 2012/12/11 11:48, Simon Jeons wrote:

> On Tue, 2012-12-11 at 04:19 +0100, Andi Kleen wrote:
>> On Mon, Dec 10, 2012 at 09:13:11PM -0600, Simon Jeons wrote:
>>> On Tue, 2012-12-11 at 04:01 +0100, Andi Kleen wrote:
>>>>> Oh, it will be putback to lru list during migration. So does your "some
>>>>> time" mean before call check_new_page?
>>>>
>>>> Yes until the next check_new_page() whenever that is. If the migration
>>>> works it will be earlier, otherwise later.
>>>
>>> But I can't figure out any page reclaim path check if the page is set
>>> PG_hwpoison, can poisoned pages be rclaimed?
>>
>> The only way to reclaim a page is to free and reallocate it.
> 
> Then why there doesn't have check in reclaim path to avoid relcaim
> poisoned page?
> 
> 			-Simon

Hi Simon,

If the page is free, it will be set PG_hwpoison, and soft_offline_page() is done.
When the page is alocated later, check_new_page() will find the poisoned page and
isolate the whole buddy block(just drop the block).

If the page is not free, soft_offline_page() try to free it first, if this is
failed, it will migrate the page, but the page is still in LRU list after migration,
migrate_pages()
	unmap_and_move()
		if (rc != -EAGAIN) {
			...
			putback_lru_page(page);
		}
We can use lru_add_drain_all() to drain lru pagevec, at last free_hot_cold_page()
will be called, and free_pages_prepare() check the poisoned pages.
free_pages_prepare()
	free_pages_check()
		bad_page()

Is this right, Andi?

Thanks
Xishi Qiu

>>
>> -Andi
> 
> 
> 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
