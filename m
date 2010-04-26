Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 6EFDC6B01E3
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 02:02:02 -0400 (EDT)
Message-ID: <4BD52C4F.40505@redhat.com>
Date: Mon, 26 Apr 2010 09:01:51 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
References: <20100422134249.GA2963@ca-server1.us.oracle.com> <4BD06B31.9050306@redhat.com> <53c81c97-b30f-4081-91a1-7cef1879c6fa@default> <4BD07594.9080905@redhat.com> <b1036777-129b-4531-a730-1e9e5a87cea9@default> <4BD16D09.2030803@redhat.com> <b01d7882-1a72-4ba9-8f46-ba539b668f56@default> <4BD1A74A.2050003@redhat.com> <4830bd20-77b7-46c8-994b-8b4fa9a79d27@default> <4BD1B427.9010905@redhat.com> <b559c57a-0acb-4338-af21-dbfc3b3c0de5@default> <4BD336CF.1000103@redhat.com> <d1bb78ca-5ef6-4a8d-af79-a265f2d4339c@default> <4BD43182.1040508@redhat.com> <c5062f3a-3232-4b21-b032-2ee1f2485ff0@default 4BD44E74.2020506@redhat.com> <7264e3c0-15fe-4b70-a3d8-2c36a2b934df@default>
In-Reply-To: <7264e3c0-15fe-4b70-a3d8-2c36a2b934df@default>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On 04/25/2010 06:29 PM, Dan Magenheimer wrote:
>>> While I admit that I started this whole discussion by implying
>>> that frontswap (and cleancache) might be useful for SSDs, I think
>>> we are going far astray here.  Frontswap is synchronous for a
>>> reason: It uses real RAM, but RAM that is not directly addressable
>>> by a (guest) kernel.  SSD's (at least today) are still I/O devices;
>>> even though they may be very fast, they still live on a PCI (or
>>> slower) bus and use DMA.  Frontswap is not intended for use with
>>> I/O devices.
>>>
>>> Today's memory technologies are either RAM that can be addressed
>>> by the kernel, or I/O devices that sit on an I/O bus.  The
>>> exotic memories that I am referring to may be a hybrid:
>>> memory that is fast enough to live on a QPI/hypertransport,
>>> but slow enough that you wouldn't want to randomly mix and
>>> hand out to userland apps some pages from "exotic RAM" and some
>>> pages from "normal RAM".  Such memory makes no sense today
>>> because OS's wouldn't know what to do with it.  But it MAY
>>> make sense with frontswap (and cleancache).
>>>
>>> Nevertheless, frontswap works great today with a bare-metal
>>> hypervisor.  I think it stands on its own merits, regardless
>>> of one's vision of future SSD/memory technologies.
>>>        
>> Even when frontswapping to RAM on a bare metal hypervisor it makes
>> sense
>> to use an async API, in case you have a DMA engine on board.
>>      
> When pages are 2MB, this may be true.  When pages are 4KB and
> copied individually, it may take longer to program a DMA engine
> than to just copy 4KB.
>    

Of course, you have to use a batching API, like virtio or Xen's rings, 
to avoid the overhead.

> But in any case, frontswap works fine on all existing machines
> today.  If/when most commodity CPUs have an asynchronous RAM DMA
> engine, an asynchronous API may be appropriate.  Or the existing
> swap API might be appropriate. Or the synchronous frontswap API
> may work fine too.  Speculating further about non-existent
> hardware that might exist in the (possibly far) future is irrelevant
> to the proposed patch, which works today on all existing x86 hardware
> and on shipping software.
>    

dma engines are present on commodity hardware now:

http://en.wikipedia.org/wiki/I/O_Acceleration_Technology

I don't know if consumer machines have them, but servers certainly do.  
modprobe ioatdma.


-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
