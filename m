Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 1FC2D900002
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 03:07:31 -0400 (EDT)
Received: by mail-ig0-f171.google.com with SMTP id h18so3857218igc.10
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 00:07:30 -0700 (PDT)
Received: from mail-ig0-x232.google.com (mail-ig0-x232.google.com [2607:f8b0:4001:c05::232])
        by mx.google.com with ESMTPS id p4si1777354igx.8.2014.06.12.00.07.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Jun 2014 00:07:30 -0700 (PDT)
Received: by mail-ig0-f178.google.com with SMTP id hn18so1699327igb.17
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 00:07:30 -0700 (PDT)
Date: Thu, 12 Jun 2014 00:07:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: Proposal to realize hot-add *several sections one time*
In-Reply-To: <53991353.5040607@huawei.com>
Message-ID: <alpine.DEB.2.02.1406120002410.23724@chino.kir.corp.google.com>
References: <53981D81.5060708@huawei.com> <alpine.DEB.2.02.1406111503050.27885@chino.kir.corp.google.com> <53991353.5040607@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Zhen <zhenzhang.zhang@huawei.com>
Cc: gregkh@linuxfoundation.org, laijs@cn.fujitsu.com, sjenning@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wang Nan <wangnan0@huawei.com>

On Thu, 12 Jun 2014, Zhang Zhen wrote:

> >> % echo start_address_of_new_memory count_of_sections > /sys/devices/system/memory/probe
> >>
> >> Then, [start_address_of_new_memory, start_address_of_new_memory +
> >> count_of_sections * memory_block_size] memory range is hot-added.
> >>
> >> If this proposal is reasonable, i will send a patch to realize it.
> >>
> > 
> > The problem is knowing how much memory is being onlined so that you can 
> > definitively determine what count_of_sections should be.  The number of 
> > pages per memory section depends on PAGE_SIZE and SECTION_SIZE_BITS which 
> > differ depending on the architectures that support this interface.  So if 
> > you support count_of_sections, it would return errno even though you have 
> > onlined some sections.
> > 
> Hum, sorry.
> My expression is not right. The count of sections one time hot-added
> depends on sections_per_block.
> 

Ok, so you know specifically what sections_per_block is for your platform 
so you know exactly how many sections need to be added.

> Now we are porting the memory-hotplug to arm.
> But we can only hot-add *fixed number of sections one time* on particular architecture.
> 
> Whether we can add an argument on behalf of the count of the blocks to add ?
> 
> % echo start_address_of_new_memory count_of_blocks > /sys/devices/system/memory/probe
> 
> Then, [start_address_of_new_memory, start_address_of_new_memory + count_of_blocks * memory_block_size]
> memory range is hot-added.
> 

As I said, if the above returns errno at some point, it still can result 
in some sections being onlined.  To be clear: if
"echo 0x10000000 > /sys/devices/system/memory/probe" fails, the section 
starting at address 0x10000000 failed to be onlined for the reason 
specified by errno.  If we follow your suggestion to specify how many 
sections to online, if
"echo '0x10000000 16' > /sys/devices/system/memory/probe" fails, eight 
sections could have been successfully onlined at address 0x10000000 and 
then we encountered a failure (perhaps because the next sections were 
already onlined, we get an -EEXIST).  We don't know what we successfully 
onlined.

This could be mitigated, but there would have to be a convincing reason 
that this is better than using the currently functionally in a loop and 
properly handling your error codes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
