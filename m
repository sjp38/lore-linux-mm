Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 701456B0388
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 13:46:08 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id n141so26981692qke.1
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 10:46:08 -0800 (PST)
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com. [209.85.220.180])
        by mx.google.com with ESMTPS id d17si9948125qka.234.2017.03.03.10.46.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Mar 2017 10:46:07 -0800 (PST)
Received: by mail-qk0-f180.google.com with SMTP id g129so6952223qkd.1
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 10:46:07 -0800 (PST)
Subject: Re: [RFC PATCH 06/12] staging: android: ion: Remove crufty cache
 support
References: <1488491084-17252-1-git-send-email-labbott@redhat.com>
 <1488491084-17252-7-git-send-email-labbott@redhat.com>
 <20170303095654.zbcqkcojo3vf6y4y@phenom.ffwll.local>
 <2273106.Hjr80nPvcZ@avalon>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <87fe5d0a-19d2-b6c7-391f-687aa5ff8571@redhat.com>
Date: Fri, 3 Mar 2017 10:46:03 -0800
MIME-Version: 1.0
In-Reply-To: <2273106.Hjr80nPvcZ@avalon>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Pinchart <laurent.pinchart@ideasonboard.com>, dri-devel@lists.freedesktop.org
Cc: Daniel Vetter <daniel@ffwll.ch>, devel@driverdev.osuosl.org, romlem@google.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, arve@android.com, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Riley Andrews <riandrews@android.com>, Mark Brown <broonie@kernel.org>, Daniel Vetter <daniel.vetter@intel.com>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org

On 03/03/2017 08:39 AM, Laurent Pinchart wrote:
> Hi Daniel,
> 
> On Friday 03 Mar 2017 10:56:54 Daniel Vetter wrote:
>> On Thu, Mar 02, 2017 at 01:44:38PM -0800, Laura Abbott wrote:
>>> Now that we call dma_map in the dma_buf API callbacks there is no need
>>> to use the existing cache APIs. Remove the sync ioctl and the existing
>>> bad dma_sync calls. Explicit caching can be handled with the dma_buf
>>> sync API.
>>>
>>> Signed-off-by: Laura Abbott <labbott@redhat.com>
>>> ---
>>>
>>>  drivers/staging/android/ion/ion-ioctl.c         |  5 ----
>>>  drivers/staging/android/ion/ion.c               | 40 --------------------
>>>  drivers/staging/android/ion/ion_carveout_heap.c |  6 ----
>>>  drivers/staging/android/ion/ion_chunk_heap.c    |  6 ----
>>>  drivers/staging/android/ion/ion_page_pool.c     |  3 --
>>>  drivers/staging/android/ion/ion_system_heap.c   |  5 ----
>>>  6 files changed, 65 deletions(-)
>>>
>>> diff --git a/drivers/staging/android/ion/ion-ioctl.c
>>> b/drivers/staging/android/ion/ion-ioctl.c index 5b2e93f..f820d77 100644
>>> --- a/drivers/staging/android/ion/ion-ioctl.c
>>> +++ b/drivers/staging/android/ion/ion-ioctl.c
>>> @@ -146,11 +146,6 @@ long ion_ioctl(struct file *filp, unsigned int cmd,
>>> unsigned long arg)> 
>>>  			data.handle.handle = handle->id;
>>>  		
>>>  		break;
>>>  	
>>>  	}
>>>
>>> -	case ION_IOC_SYNC:
>>> -	{
>>> -		ret = ion_sync_for_device(client, data.fd.fd);
>>> -		break;
>>> -	}
>>
>> You missed the case ION_IOC_SYNC: in compat_ion.c.
>>
>> While at it: Should we also remove the entire custom_ioctl infrastructure?
>> It's entirely unused afaict, and for a pure buffer allocator I don't see
>> any need to have custom ioctl.
> 
> I second that, if you want to make ion a standard API, then we certainly don't 
> want any custom ioctl.
> 
>> More code to remove potentially:
>> - The entire compat ioctl stuff - would be an abi break, but I guess if we
>>   pick the 32bit abi and clean up the uapi headers we'll be mostly fine.
>>   would allow us to remove compat_ion.c entirely.
>>
>> - ION_IOC_IMPORT: With this ion is purely an allocator, so not sure we
>>   still need to be able to import anything. All the cache flushing/mapping
>>   is done through dma-buf ops/ioctls.
>>
>>

Good point to all of the above. I was considering keeping the import around
for backwards compatibility reasons but given how much other stuff is being
potentially broken, everything should just get ripped out.

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
