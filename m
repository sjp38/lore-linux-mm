Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FF42C282DA
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 09:25:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AFFE120883
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 09:25:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AFFE120883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1E6366B0008; Tue,  9 Apr 2019 05:25:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1BF4F6B000C; Tue,  9 Apr 2019 05:25:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0311A6B000D; Tue,  9 Apr 2019 05:25:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id D76C96B0008
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 05:25:55 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id n1so15198337qte.12
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 02:25:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=0eTgXgSaDbO3W5BfYIJl3f3+1B692rq1mbgqclOPyKg=;
        b=O6oW1pAaKM/yXn1Rcv0Z4UAeLTL6t05KTvpNVMYlNYYqGcVI3Nd7a6m2XR+ucSkpol
         c3+rJK1DfzzJdDVsDvHN3MI/vau4G0oG0ZRaHqVbFbd+7RkcD7svzbqdxZiFMiV7SZqE
         7kU2NciCMthGs4ij5AHZpHmck83b6bSEITH49d6UC1G1j3qetlntTrqOptfmLUN0oOrz
         AU30EUk4AaAgxhWAG1yVr3aDepbDq5bCmFwCucGhHDCt87RFAo4gKI/7Kl5/Fa46cbre
         X9v9UAKE2r+4wQqsEUyN3jTTo7g5Zzs2yBHgXtuUVCRcSFmU9GzlyxhDQ7b+SpBRHgoj
         VQUQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXZhHwWT9pAtrWyUD5wg7fR9qnV+M1s9CJF/NQbgXnUrFwIBDwE
	3EwhPC8l6U+SkL3bxePeotTkxl1UiH2WoEWydqYBOAcC8UQuEHwa3TOnb1XWH+8jKMLcxuXhKWL
	m44TqohvQ6/V6IrGKWSh1NZmIoUUU5usKdagoRRLIuW6n+wXZ6IE+2b4wv6owINcI5Q==
X-Received: by 2002:a0c:b99c:: with SMTP id v28mr27840168qvf.10.1554801955606;
        Tue, 09 Apr 2019 02:25:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqya+6F12pGbwPOVzwfgQ4CwtKgRHUotMtLo/ytSk7aNjUXOqtyTpptuBStozkS/tEhRjpbv
X-Received: by 2002:a0c:b99c:: with SMTP id v28mr27840133qvf.10.1554801954995;
        Tue, 09 Apr 2019 02:25:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554801954; cv=none;
        d=google.com; s=arc-20160816;
        b=Y3u7r2bhrjMlPvI3z53vzH8QCxs+fPGiKr1S+PQ61cWYyLRTTnNR8JSIuvt93NA5PZ
         R/7cqVrdUt+F//QwG7PFOdvDtP381A3JTXfn83M+lUrBBgfxLv2WMjZUpwvfjcKJZ1FW
         sLcFudn7dDNsoBCbDyQHrRuCMuKeTtWpfTgptx75Y3xILD2pqmy4oJlqyNHX5dwpgHwi
         /x7T94kFWPNHpzW5f05SjxzjC68vSErytYHed9s09I7TPCGQmOhw5JZWzENI0xyjMfaQ
         eeF0lWcqrUkzFbPtBcTq6UlobLcVVk43uDq7s821U9JXzHskZS2HfmPwpOEaf3r7vFHV
         iAwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=0eTgXgSaDbO3W5BfYIJl3f3+1B692rq1mbgqclOPyKg=;
        b=OcmqhCER/ecYW0Fp5oD1X7m0C/r09XI2a2MWbs5cZzuXKUdmEmB/LEdqvkjnF4QEf/
         mUj9UZKgHHLnYawrlcS9xi7DqVAsI8RaSo6LtNn+JHVCB8WSropqR4MDbBWADl39Fv5L
         FM/qiPPzcZFRwlsfUZT6VtoHUOB3RJfAKPM2zszwfeaW25AcooRYzXyN5+IC8ULLtYup
         /ar5XYlR5BVPGPOQfrZLp3V20wJLNmPkOxOc8StlE6EmPIGkrR4kc/F2c7M5wi8sCLkd
         gGaSx+GC82gGvBq6hWPNZUWJ1wNXMHlgQjZl/PECxwUqgT102DoKHqDfrvX2P5qOl9VH
         xuIA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i12si3605260qkg.73.2019.04.09.02.25.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 02:25:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id CB4FF81E0E;
	Tue,  9 Apr 2019 09:25:53 +0000 (UTC)
Received: from [10.36.117.49] (ovpn-117-49.ams2.redhat.com [10.36.117.49])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 69B7C5D9D3;
	Tue,  9 Apr 2019 09:25:50 +0000 (UTC)
Subject: Re: [PATCH RFC 3/3] mm/memory_hotplug: Remove memory block devices
 before arch_remove_memory()
To: Oscar Salvador <osalvador@suse.de>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J . Wysocki" <rafael@kernel.org>, Ingo Molnar <mingo@kernel.org>,
 Andrew Banman <andrew.banman@hpe.com>, mike.travis@hpe.com,
 Jonathan Cameron <Jonathan.Cameron@huawei.com>,
 Michal Hocko <mhocko@suse.com>, Pavel Tatashin
 <pavel.tatashin@microsoft.com>, Wei Yang <richard.weiyang@gmail.com>,
 Qian Cai <cai@lca.pw>, Arun KS <arunks@codeaurora.org>,
 Mathieu Malaterre <malat@debian.org>, linux-mm@kvack.org,
 dan.j.williams@intel.com
References: <20190408101226.20976-1-david@redhat.com>
 <20190408101226.20976-4-david@redhat.com>
 <20190409091844.yvjmglawf2fmiy3o@d104.suse.de>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <c3fb1f07-6e59-8e0b-6130-3830515b6df0@redhat.com>
Date: Tue, 9 Apr 2019 11:25:49 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190409091844.yvjmglawf2fmiy3o@d104.suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Tue, 09 Apr 2019 09:25:54 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 09.04.19 11:18, Oscar Salvador wrote:
> On Mon, Apr 08, 2019 at 12:12:26PM +0200, David Hildenbrand wrote:
>> Let's factor out removing of memory block devices, which is only
>> necessary for memory added via add_memory() and friends that created
>> memory block devices. Remove the devices before calling
>> arch_remove_memory().
>>
>> TODO: We should try to get rid of the errors that could be reported by
>> unregister_memory_block_under_nodes(). Ignoring failures is not that
>> nice.
> 
> Hi David,
> 
> I am sorry but I will not have to look into this until next week as I am
> up to my ears with work plus I am in the middle of a move.

No worries, I have plenty of other stuff to do as well and this is only
an RFC that will require other refactorings and maybe discussions first
- one of these, I will send out shortly so we can discuss.

Happy moving :)

> 
> I remember I was once trying to simplify unregister_mem_sect_under_nodes (your
> new unregister_memory_block_under_nodes), and I checked whether we could get
> rid of the NODEMASK_ALLOC there, something like:

Yeah, something like that makes perfect sense. Thanks!

> 
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 8598fcbd2a17..f4294a2928dd 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -805,16 +805,10 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, void *arg)
>  int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
>                                     unsigned long phys_index)
>  {
> -       NODEMASK_ALLOC(nodemask_t, unlinked_nodes, GFP_KERNEL);
> +       nodemask_t unlinked_nodes;
>         unsigned long pfn, sect_start_pfn, sect_end_pfn;
>  
> -       if (!mem_blk) {
> -               NODEMASK_FREE(unlinked_nodes);
> -               return -EFAULT;
> -       }
> -       if (!unlinked_nodes)
> -               return -ENOMEM;
> -       nodes_clear(*unlinked_nodes);
> +       nodes_clear(unlinked_nodes);
>  
>         sect_start_pfn = section_nr_to_pfn(phys_index);
>         sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
> @@ -826,14 +820,13 @@ int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
>                         continue;
>                 if (!node_online(nid))
>                         continue;
> -               if (node_test_and_set(nid, *unlinked_nodes))
> +               if (node_test_and_set(nid, unlinked_nodes))
>                         continue;
>                 sysfs_remove_link(&node_devices[nid]->dev.kobj,
>                          kobject_name(&mem_blk->dev.kobj));
>                 sysfs_remove_link(&mem_blk->dev.kobj,
>                          kobject_name(&node_devices[nid]->dev.kobj));
>         }
> -       NODEMASK_FREE(unlinked_nodes);
>         return 0;
>  }
> 
> 
> nodemask_t is 128bytes when CONFIG_NODES_SHIFT is 10 , which is the maximum value.
> We just need to check whether we can overflow the stack or not.
> 
> AFAICS, it is not really a shore stack but it might not be that deep either.


-- 

Thanks,

David / dhildenb

