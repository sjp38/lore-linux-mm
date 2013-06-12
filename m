Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 2A3146B0034
	for <linux-mm@kvack.org>; Tue, 11 Jun 2013 22:18:02 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kl14so2795957pab.6
        for <linux-mm@kvack.org>; Tue, 11 Jun 2013 19:18:01 -0700 (PDT)
Message-ID: <51B7DA51.1000304@gmail.com>
Date: Wed, 12 Jun 2013 10:17:53 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v8, part3 10/14] mm: use a dedicated lock to protect totalram_pages
 and zone->managed_pages
References: <1369575522-26405-1-git-send-email-jiang.liu@huawei.com> <1369575522-26405-11-git-send-email-jiang.liu@huawei.com> <20130611130042.3dec2cc6737f21180bc09bb1@linux-foundation.org>
In-Reply-To: <20130611130042.3dec2cc6737f21180bc09bb1@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <james.bottomley@hansenpartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>

On Wed 12 Jun 2013 04:00:42 AM CST, Andrew Morton wrote:
> On Sun, 26 May 2013 21:38:38 +0800 Jiang Liu <liuj97@gmail.com> wrote:
>
>> Currently lock_memory_hotplug()/unlock_memory_hotplug() are used to
>> protect totalram_pages and zone->managed_pages. Other than the memory
>> hotplug driver, totalram_pages and zone->managed_pages may also be
>> modified at runtime by other drivers, such as Xen balloon,
>> virtio_balloon etc. For those cases, memory hotplug lock is a little
>> too heavy, so introduce a dedicated lock to protect totalram_pages
>> and zone->managed_pages.
>>
>> Now we have a simplified locking rules totalram_pages and
>> zone->managed_pages as:
>> 1) no locking for read accesses because they are unsigned long.
>> 2) no locking for write accesses at boot time in single-threaded context.
>> 3) serialize write accesses at runtime by acquiring the dedicated
>>    managed_page_count_lock.
>>
>> Also adjust zone->managed_pages when freeing reserved pages into the
>> buddy system, to keep totalram_pages and zone->managed_pages in
>> consistence.
>>
>> ...
>>
>> +void adjust_managed_page_count(struct page *page, long count)
>> +{
>> +	spin_lock(&managed_page_count_lock);
>> +	page_zone(page)->managed_pages += count;
>> +	totalram_pages += count;
>> +	spin_unlock(&managed_page_count_lock);
>> +}
>> +EXPORT_SYMBOL(adjust_managed_page_count);
>
> This is exported to modules but there are no modular callers at this
> time.
>
> I assume this was done for some forthcoming xen/virtio_balloon/etc
> patches?  If so, it would be better to avoid adding the export until it
> is actually needed.
Hi Andrew,
     adjust_managed_page_count() will be used by virtio_balloon and xen 
balloon
drivers. Grep mmots tree:
drivers/virtio/virtio_balloon.c:		adjust_managed_page_count(page, -1);
drivers/virtio/virtio_balloon.c:		adjust_managed_page_count(page, 1);
drivers/xen/balloon.c:	adjust_managed_page_count(page, -1);
drivers/xen/balloon.c:	adjust_managed_page_count(page, 1);

So if we un-export it in part3, we need to export in part4 again.
Regards!
Gerry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
