Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id ADC3683200
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 15:21:01 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id a189so106328684qkc.4
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 12:21:01 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p132si3850799qka.200.2017.03.08.12.20.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 12:20:56 -0800 (PST)
Subject: Re: [PATCHv2 2/5] target/user: Add global data block pool support
References: <1488962743-17028-1-git-send-email-lixiubo@cmss.chinamobile.com>
 <1488962743-17028-3-git-send-email-lixiubo@cmss.chinamobile.com>
From: Andy Grover <agrover@redhat.com>
Message-ID: <3b1ce412-6072-fda1-3002-220cf8fbf34f@redhat.com>
Date: Wed, 8 Mar 2017 12:20:54 -0800
MIME-Version: 1.0
In-Reply-To: <1488962743-17028-3-git-send-email-lixiubo@cmss.chinamobile.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lixiubo@cmss.chinamobile.com, nab@linux-iscsi.org, mchristi@redhat.com
Cc: shli@kernel.org, sheng@yasker.org, linux-scsi@vger.kernel.org, target-devel@vger.kernel.org, namei.unix@gmail.com, linux-mm@kvack.org

On 03/08/2017 12:45 AM, lixiubo@cmss.chinamobile.com wrote:
> From: Xiubo Li <lixiubo@cmss.chinamobile.com>
>
> For each target there will be one ring, when the target number
> grows larger and larger, it could eventually runs out of the
> system memories.
>
> In this patch for each target ring, the cmd area size will be
> limited to 8M and the data area size will be limited to 1G. And
> the data area will be divided into two parts: the fixed and
> growing.
>
> For the fixed part, it will be 1M size and pre-allocated together
> with the cmd area. This could speed up the low iops case, and
> also could make sure that each ring will have at least 1M private
> data size when there has too many targets, which could get their
> data blocks as quick as possible.
>
> For the growing part, it will get the blocks from the global data
> block pool. And this part will be used for high iops case.
>
> The global data block pool is a cache, and the total size will be
> limited to max 2G(grows from 0 to 2G as needed). And it will cache
> the freed data blocks by a list, All targets will get from/release
> to the free blocks here.

Hi Xiubo,

I will leave the detailed patch critique to others but this does seem to 
achieve the goals of 1) larger TCMU data buffers to prevent bottlenecks 
and 2) Allocating memory in a way that avoids using up all system memory 
in corner cases.

The one thing I'm still unsure about is what we need to do to maintain 
the data area's virtual mapping properly. Nobody on linux-mm answered my 
email a few days ago on the right way to do this, alas. But, userspace 
accessing the data area is going to cause tcmu_vma_fault() to be called, 
and it seems to me like we must proactively do something -- some kind of 
unmap call -- before we can reuse that memory for another, possibly 
completely unrelated, backstore's data area. This could allow one 
backstore handler to read or write another's data.

Regards -- Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
