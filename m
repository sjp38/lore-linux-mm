Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 6C7116B006A
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 17:02:50 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id 22so535167fge.8
        for <linux-mm@kvack.org>; Tue, 19 Jan 2010 14:02:48 -0800 (PST)
Message-ID: <4B562C05.6080404@gmail.com>
Date: Tue, 19 Jan 2010 23:02:45 +0100
From: Jiri Slaby <jirislaby@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC 1/1] bootmem: move big allocations behing 4G
References: <1263855390-32497-1-git-send-email-jslaby@suse.cz> <20100119143355.GB7932@cmpxchg.org>
In-Reply-To: <20100119143355.GB7932@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, x86@kernel.org
List-ID: <linux-mm.kvack.org>

On 01/19/2010 03:33 PM, Johannes Weiner wrote:
> On Mon, Jan 18, 2010 at 11:56:30PM +0100, Jiri Slaby wrote:
>> Hi, I'm fighting a bug where Grub loads the kernel just fine, whereas
>> isolinux doesn't. I found out, it's due to different addresses of
>> loaded initrd. On a machine with 128G of memory, grub loads the
>> initrd at 895M in our case and flat mem_map (2G long) is allocated
>> above 4G due to 2-4G BIOS reservation.
>>
>> On the other hand, with isolinux, the 0-2G is free and mem_map is
>> placed there leaving no space for others, hence kernel panics for
>> swiotlb which needs to be below 4G.
> 
> Bootmem already protects the lower 16MB DMA zone for the obvious reasons,
> how about shifting the default bootmem goal above the DMA32 zone if it exists?

Hi, I think it makes sense.

> I tested the below on a rather dull x86_64 machine and it seems to work.  Would
> this work in your case as well?  The goal for mem_map should now be above 4G.

It seems that it will. I'll give it a try later (it needs to be set up)
and report back.

> From 1c11ce1e82c6209f0eda72e3340ab0c55cd6f330 Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <jw@emlix.com>
> Date: Tue, 19 Jan 2010 14:14:44 +0100
> Subject: [patch] bootmem: avoid DMA32 zone, if any, by default
> 
> x86_64 and mips define a DMA32 zone additionally to the old DMA
> zone of 16MB.  Bootmem already avoids the old DMA zone if the
> allocation site did not request otherwise.
> 
> But since DMA32 is also a limited resource, avoid using it as well
> by default, if defined.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

So for the time being:
Reviewed-by: Jiri Slaby <jirislaby@gmail.com>

thanks,
-- 
js

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
