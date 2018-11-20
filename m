Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id E61526B1F29
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 03:49:52 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id 80so2311342qkd.0
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 00:49:52 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f20si1261669qto.316.2018.11.20.00.49.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 00:49:52 -0800 (PST)
Subject: Re: [PATCH v1 5/8] hv_balloon: mark inflated pages PG_offline
References: <20181119101616.8901-1-david@redhat.com>
 <20181119101616.8901-6-david@redhat.com>
 <1747228.35250472.1542703532881.JavaMail.zimbra@redhat.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <6258a58b-28c7-c055-0752-e8bd085b835f@redhat.com>
Date: Tue, 20 Nov 2018 09:49:42 +0100
MIME-Version: 1.0
In-Reply-To: <1747228.35250472.1542703532881.JavaMail.zimbra@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pankaj Gupta <pagupta@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, devel@linuxdriverproject.org, linux-fsdevel@vger.kernel.org, linux-pm@vger.kernel.org, xen-devel@lists.xenproject.org, kexec-ml <kexec@lists.infradead.org>, pv-drivers@vmware.com, "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Stephen Hemminger <sthemmin@microsoft.com>, Kairui Song <kasong@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, "Michael S. Tsirkin" <mst@redhat.com>

On 20.11.18 09:45, Pankaj Gupta wrote:
> 
> Hi David,
> 
>>
>> Mark inflated and never onlined pages PG_offline, to tell the world that
>> the content is stale and should not be dumped.
>>
>> Cc: "K. Y. Srinivasan" <kys@microsoft.com>
>> Cc: Haiyang Zhang <haiyangz@microsoft.com>
>> Cc: Stephen Hemminger <sthemmin@microsoft.com>
>> Cc: Kairui Song <kasong@redhat.com>
>> Cc: Vitaly Kuznetsov <vkuznets@redhat.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Matthew Wilcox <willy@infradead.org>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: "Michael S. Tsirkin" <mst@redhat.com>
>> Signed-off-by: David Hildenbrand <david@redhat.com>
>> ---
>>  drivers/hv/hv_balloon.c | 14 ++++++++++++--
>>  1 file changed, 12 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/hv/hv_balloon.c b/drivers/hv/hv_balloon.c
>> index 211f3fe3a038..47719862e57f 100644
>> --- a/drivers/hv/hv_balloon.c
>> +++ b/drivers/hv/hv_balloon.c
>> @@ -681,8 +681,13 @@ static struct notifier_block hv_memory_nb = {
>>  /* Check if the particular page is backed and can be onlined and online it.
>>  */
>>  static void hv_page_online_one(struct hv_hotadd_state *has, struct page *pg)
>>  {
>> -	if (!has_pfn_is_backed(has, page_to_pfn(pg)))
>> +	if (!has_pfn_is_backed(has, page_to_pfn(pg))) {
>> +		if (!PageOffline(pg))
>> +			__SetPageOffline(pg);
>>  		return;
>> +	}
>> +	if (PageOffline(pg))
>> +		__ClearPageOffline(pg);
>>  
>>  	/* This frame is currently backed; online the page. */
>>  	__online_page_set_limits(pg);
>> @@ -1201,6 +1206,7 @@ static void free_balloon_pages(struct hv_dynmem_device
>> *dm,
>>  
>>  	for (i = 0; i < num_pages; i++) {
>>  		pg = pfn_to_page(i + start_frame);
>> +		__ClearPageOffline(pg);
> 
> Just thinking, do we need to care for clearing PageOffline flag before freeing
> a balloon'd page?

Yes we have to otherwise the code will crash when trying to set PageBuddy.

(only one page type at a time may be set right now, and it makes sense.
A page that is offline cannot e.g. be a buddy page)

So PageOffline is completely managed by the page owner.

> 
> Thanks,
> Pankaj


-- 

Thanks,

David / dhildenb
