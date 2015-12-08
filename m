Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 82C396B027C
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 19:31:15 -0500 (EST)
Received: by wmuu63 with SMTP id u63so161930726wmu.0
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 16:31:15 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o16si26916566wmd.116.2015.12.07.16.31.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Dec 2015 16:31:14 -0800 (PST)
Date: Mon, 7 Dec 2015 16:31:12 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 0/2] mm: Introduce kernelcore=reliable option
Message-Id: <20151207163112.930a495d24ab259cad9020ac@linux-foundation.org>
In-Reply-To: <1448636635-15946-1-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1448636635-15946-1-git-send-email-izumi.taku@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Taku Izumi <izumi.taku@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, tony.luck@intel.com, qiuxishi@huawei.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, dave.hansen@intel.com, matt@codeblueprint.co.uk

On Sat, 28 Nov 2015 00:03:55 +0900 Taku Izumi <izumi.taku@jp.fujitsu.com> wrote:

> Xeon E7 v3 based systems supports Address Range Mirroring
> and UEFI BIOS complied with UEFI spec 2.5 can notify which
> ranges are reliable (mirrored) via EFI memory map.
> Now Linux kernel utilize its information and allocates
> boot time memory from reliable region.
> 
> My requirement is:
>   - allocate kernel memory from reliable region
>   - allocate user memory from non-reliable region
> 
> In order to meet my requirement, ZONE_MOVABLE is useful.
> By arranging non-reliable range into ZONE_MOVABLE,
> reliable memory is only used for kernel allocations.
> 
> My idea is to extend existing "kernelcore" option and
> introduces kernelcore=reliable option. By specifying
> "reliable" instead of specifying the amount of memory,
> non-reliable region will be arranged into ZONE_MOVABLE.

It is unfortunate that the kernel presently refers to this memory as
"mirrored", but this patchset introduces the new term "reliable".  I
think it would be better if we use "mirrored" throughout.

Of course, mirroring isn't the only way to get reliable memory. 
Perhaps if a part of the system memory has ECC correction then this
also can be accessed using "reliable", in which case your proposed
naming makes sense.  reliable == mirrored || ecc?



Secondly, does this patchset mean that kernelcore=reliable and
kernelcore=100M are exclusive?  Or can the user specify
"kernelcore=reliable,kernelcore=100M" to use 100M of reliable memory
for kernelcore?

This is unclear from the documentation and I suggest that this be
spelled out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
