Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 224A66B0113
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 12:06:08 -0400 (EDT)
Received: by mail-ob0-f173.google.com with SMTP id wn14so5006183obc.32
        for <linux-mm@kvack.org>; Mon, 08 Apr 2013 09:06:07 -0700 (PDT)
Message-ID: <5162EAE2.6010306@gmail.com>
Date: Tue, 09 Apr 2013 00:05:54 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4, part3 11/15] mm: use a dedicated lock to protect totalram_pages
 and zone->managed_pages
References: <1365256509-29024-1-git-send-email-jiang.liu@huawei.com> <1365256509-29024-12-git-send-email-jiang.liu@huawei.com> <5162C887.5070900@redhat.com>
In-Reply-To: <5162C887.5070900@redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Michel Lespinasse <walken@google.com>

On 04/08/2013 09:39 PM, Rik van Riel wrote:
> On 04/06/2013 09:55 AM, Jiang Liu wrote:
> 
>> @@ -5186,6 +5189,22 @@ early_param("movablecore", cmdline_parse_movablecore);
>>
>>   #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
>>
>> +void adjust_managed_page_count(struct page *page, long count)
>> +{
>> +    bool lock = (system_state != SYSTEM_BOOTING);
>> +
>> +    /* No need to acquire the lock during boot */
>> +    if (lock)
>> +        spin_lock(&managed_page_count_lock);
>> +
>> +    page_zone(page)->managed_pages += count;
>> +    totalram_pages += count;
>> +
>> +    if (lock)
>> +        spin_unlock(&managed_page_count_lock);
>> +}
> 
> While I agree the boot code currently does not need the lock, is
> there any harm to removing that conditional?
> 
> That would simplify the code, and protect against possible future
> cleverness of initializing multiple memory things simultaneously.
> 
Hi Rik,
	Thanks for you comments.
	I'm OK with that. Acquiring/releasing the lock should be lightweight
because there shouldn't be contention during boot. Will remove the logic in
next version.
	Regards!
	Gerry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
