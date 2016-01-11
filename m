Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id DA2DF828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 06:59:56 -0500 (EST)
Received: by mail-qk0-f178.google.com with SMTP id p186so144752636qke.0
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 03:59:56 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 141si33121519qhk.31.2016.01.11.03.59.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jan 2016 03:59:55 -0800 (PST)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH v3] memory-hotplug: add automatic onlining policy for the newly added memory
References: <1452187421-15747-1-git-send-email-vkuznets@redhat.com>
	<56938B7E.3060902@citrix.com>
Date: Mon, 11 Jan 2016 12:59:48 +0100
In-Reply-To: <56938B7E.3060902@citrix.com> (David Vrabel's message of "Mon, 11
	Jan 2016 11:01:18 +0000")
Message-ID: <871t9ojphn.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Daniel Kiper <daniel.kiper@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, "K. Y. Srinivasan" <kys@microsoft.com>, Igor Mammedov <imammedo@redhat.com>, Kay Sievers <kay@vrfy.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

David Vrabel <david.vrabel@citrix.com> writes:

> On 07/01/16 17:23, Vitaly Kuznetsov wrote:
>> 
>> - Changes since 'v1':
>>   Add 'online' parameter to add_memory_resource() as it is being used by
>>   xen ballon driver and it adds "empty" memory pages [David Vrabel].
>>   (I don't completely understand what prevents manual onlining in this
>>    case as we still have all newly added blocks in sysfs ... this is the
>>    discussion point.)
>

(there is a discussion with Daniel on the same topic in a parallel
thread)

> I'm not sure what you're not understanding here?
>
> Memory added by the Xen balloon driver (whether populated with real
> memory or not) does need to be onlined by udev or similar.


Yes, same as all other memory hotplug mechanisms (hyper-v's balloon
driver and acpi memory hotplug). My patch adds an option to make this
happen automatically. Xen driver is currently excluded because of a
deadlock. If this deadlock is the only problem we can easily change
taking the lock to checking that the lock was taken (and taking in case
it wasn't) or something similar and everything is going to work. From
briefly looking at the code it seems to me it's going to work.

What I wasn't sure about is 'empty pages' you were mentioning. In case
there are some pages we can't online there should be a protection
mechanism actively preventing them from going online (similar to
hv_online_page() in Hyper-V driver) as this patch does nothing
'special' compared to udev onlining newly added blocks. 

-- 
  Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
