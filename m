Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 5DC346B0005
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 09:28:21 -0500 (EST)
Received: by mail-ig0-f178.google.com with SMTP id ik10so75538648igb.1
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 06:28:21 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id qo6si37753278igb.84.2016.01.04.06.28.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jan 2016 06:28:20 -0800 (PST)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH v2] memory-hotplug: add automatic onlining policy for the newly added memory
References: <1450801950-7744-1-git-send-email-vkuznets@redhat.com>
	<568A560A.80906@citrix.com>
Date: Mon, 04 Jan 2016 15:28:12 +0100
In-Reply-To: <568A560A.80906@citrix.com> (David Vrabel's message of "Mon, 4
	Jan 2016 11:22:50 +0000")
Message-ID: <871t9xto5f.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>
Cc: linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org, Jonathan Corbet <corbet@lwn.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Daniel Kiper <daniel.kiper@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, "K. Y. Srinivasan" <kys@microsoft.com>, Igor Mammedov <imammedo@redhat.com>, Kay Sievers <kay@vrfy.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

David Vrabel <david.vrabel@citrix.com> writes:

> On 22/12/15 16:32, Vitaly Kuznetsov wrote:
>> @@ -1292,6 +1304,11 @@ int __ref add_memory_resource(int nid, struct resource *res)
>>  	/* create new memmap entry */
>>  	firmware_map_add_hotplug(start, start + size, "System RAM");
>>  
>> +	/* online pages if requested */
>> +	if (online)
>> +		online_pages(start >> PAGE_SHIFT, size >> PAGE_SHIFT,
>> +			     MMOP_ONLINE_KEEP);
>
> This will cause the Xen balloon driver to deadlock because it calls
> add_memory_resource() with the balloon_mutex locked and the online page
> callback also locks the balloon_mutex.

Currently xen ballon driver always calls add_memory_resource() with
online=false so this won't happen.

-- 
  Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
