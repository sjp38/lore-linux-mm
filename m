Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 51CD86B207B
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 09:34:53 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id q3so131260qtq.15
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 06:34:53 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e97si4619952qtb.180.2018.11.20.06.34.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 06:34:52 -0800 (PST)
Subject: Re: [RFC PATCH 2/3] mm, memory_hotplug: deobfuscate migration part of
 offlining
References: <20181120134323.13007-1-mhocko@kernel.org>
 <20181120134323.13007-3-mhocko@kernel.org>
 <f25bfa30-96cf-799c-6885-86a3a537a977@redhat.com>
 <20181120143422.GN22247@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <bcd55324-1dc9-904e-d457-ebce7684712f@redhat.com>
Date: Tue, 20 Nov 2018 15:34:49 +0100
MIME-Version: 1.0
In-Reply-To: <20181120143422.GN22247@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <OSalvador@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, LKML <linux-kernel@vger.kernel.org>

On 20.11.18 15:34, Michal Hocko wrote:
> On Tue 20-11-18 15:26:43, David Hildenbrand wrote:
> [...]
>>> +	do {
>>> +		for (pfn = start_pfn; pfn;)
>>> +		{
>>
>> { on a new line looks weird.
>>
>>> +			/* start memory hot removal */
>>> +			ret = -EINTR;
>>
>> I think we can move that into the "if (signal_pending(current))"
>>
>> (if my eyes are not wrong, this will not be touched otherwise)
> 
> Better?
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 9cd161db3061..6bc3aee30f5e 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1592,11 +1592,10 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  	}
>  
>  	do {
> -		for (pfn = start_pfn; pfn;)
> -		{
> +		for (pfn = start_pfn; pfn;) {
>  			/* start memory hot removal */
> -			ret = -EINTR;
>  			if (signal_pending(current)) {
> +				ret = -EINTR;
>  				reason = "signal backoff";
>  				goto failed_removal_isolated;
>  			}
> 

Reviewed-by: David Hildenbrand <david@redhat.com>

:)

-- 

Thanks,

David / dhildenb
