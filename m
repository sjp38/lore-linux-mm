Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9F7AD6B0033
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 08:27:08 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id d185so271427020pgc.2
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 05:27:08 -0800 (PST)
Received: from smtpbgsg2.qq.com (smtpbgsg2.qq.com. [54.254.200.128])
        by mx.google.com with ESMTPS id h9si1565841pli.37.2017.01.25.05.27.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Jan 2017 05:27:07 -0800 (PST)
Subject: Re: [PATCH] mm/migration: make isolate_movable_page always defined
References: <1485340563-60785-1-git-send-email-xieyisheng1@huawei.com>
 <20170125120115.GL32377@dhcp22.suse.cz>
From: Yisheng Xie <ysxie@foxmail.com>
Message-ID: <5888A7A2.9060907@foxmail.com>
Date: Wed, 25 Jan 2017 21:26:58 +0800
MIME-Version: 1.0
In-Reply-To: <20170125120115.GL32377@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Yisheng Xie <xieyisheng1@huawei.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, guohanjun@huawei.com, qiuxishi@huawei.com


Hi, Michal,
Thanks for reviewing.
On 01/25/2017 08:01 PM, Michal Hocko wrote:
> On Wed 25-01-17 18:36:03, Yisheng Xie wrote:
>> Define isolate_movable_page as a static inline function when
>> CONFIG_MIGRATION is not enable. It should return false
>> here which means failed to isolate movable pages.
>>
>> This patch do not have any functional change but to resolve compile
>> error caused by former commit "HWPOISON: soft offlining for non-lru
>> movable page" with CONFIG_MIGRATION disabled.
>>
>> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
>> ---
>>  include/linux/migrate.h | 2 ++
>>  1 file changed, 2 insertions(+)
>>
>> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
>> index ae8d475..631a8c8 100644
>> --- a/include/linux/migrate.h
>> +++ b/include/linux/migrate.h
>> @@ -56,6 +56,8 @@ static inline int migrate_pages(struct list_head *l, new_page_t new,
>>  		free_page_t free, unsigned long private, enum migrate_mode mode,
>>  		int reason)
>>  	{ return -ENOSYS; }
>> +static inline bool isolate_movable_page(struct page *page, isolate_mode_t mode)
>> +	{ return false; }
> OK, so we return false here which will make __soft_offline_page return
> true all the way up. Is this really what we want? Don't we want to
> return EBUSY in that case? The error code propagation here is just
> one big mess.
That's right, my stupid coding really make a big mess here.
I will make another version for patch  "HWPOISON:
soft offlining for non-lru movable page" to avoid that.

Thanks
Yisheng Xie.
>>  
>>  static inline int migrate_prep(void) { return -ENOSYS; }
>>  static inline int migrate_prep_local(void) { return -ENOSYS; }
>> -- 
>> 1.7.12.4
>>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
