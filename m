Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f181.google.com (mail-yk0-f181.google.com [209.85.160.181])
	by kanga.kvack.org (Postfix) with ESMTP id 963B8828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 08:21:59 -0500 (EST)
Received: by mail-yk0-f181.google.com with SMTP id x67so430725434ykd.2
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 05:21:59 -0800 (PST)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id k66si13297234ywd.3.2016.01.11.05.21.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 11 Jan 2016 05:21:58 -0800 (PST)
Message-ID: <5693AC71.8080400@citrix.com>
Date: Mon, 11 Jan 2016 13:21:53 +0000
From: David Vrabel <david.vrabel@citrix.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3] memory-hotplug: add automatic onlining policy for
 the newly added memory
References: <1452187421-15747-1-git-send-email-vkuznets@redhat.com>
	<56938B7E.3060902@citrix.com> <871t9ojphn.fsf@vitty.brq.redhat.com>
In-Reply-To: <871t9ojphn.fsf@vitty.brq.redhat.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Greg
 Kroah-Hartman <gregkh@linuxfoundation.org>, Daniel Kiper <daniel.kiper@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Andrew
 Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, "K. Y. Srinivasan" <kys@microsoft.com>, Igor
 Mammedov <imammedo@redhat.com>, Kay Sievers <kay@vrfy.org>, Konrad
 Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

On 11/01/16 11:59, Vitaly Kuznetsov wrote:
> David Vrabel <david.vrabel@citrix.com> writes:
> 
>> On 07/01/16 17:23, Vitaly Kuznetsov wrote:
>>>
>>> - Changes since 'v1':
>>>   Add 'online' parameter to add_memory_resource() as it is being used by
>>>   xen ballon driver and it adds "empty" memory pages [David Vrabel].
>>>   (I don't completely understand what prevents manual onlining in this
>>>    case as we still have all newly added blocks in sysfs ... this is the
>>>    discussion point.)
>>
> 
> (there is a discussion with Daniel on the same topic in a parallel
> thread)
> 
>> I'm not sure what you're not understanding here?
>>
>> Memory added by the Xen balloon driver (whether populated with real
>> memory or not) does need to be onlined by udev or similar.
> 
> 
> Yes, same as all other memory hotplug mechanisms (hyper-v's balloon
> driver and acpi memory hotplug). My patch adds an option to make this
> happen automatically. Xen driver is currently excluded because of a
> deadlock. If this deadlock is the only problem we can easily change
> taking the lock to checking that the lock was taken (and taking in case
> it wasn't) or something similar and everything is going to work. From
> briefly looking at the code it seems to me it's going to work.

I don't think Linux has recursive mutex that we could use for this.

> What I wasn't sure about is 'empty pages' you were mentioning. In case
> there are some pages we can't online there should be a protection
> mechanism actively preventing them from going online (similar to
> hv_online_page() in Hyper-V driver) as this patch does nothing
> 'special' compared to udev onlining newly added blocks. 

'Empty' (or unpopulated) pages are those without any physical RAM
backing them.  Backend drivers map foreign (from other guest) pages into
these unpopulated pages.  i.e., accesses by the kernel to the virtual
addresses of these pages access memory shared by another guest.

These empty pages are ones we would prefer to be always automatically
onlined because they're hotplugged in response to requests from the
backend drivers.

Anyway, this series is fine with this Xen balloon driver limitation --
it can be addresses at a later date if necessary.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
