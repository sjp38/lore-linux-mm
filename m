Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id D826F6B017B
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 18:08:42 -0400 (EDT)
Received: by mail-ie0-f178.google.com with SMTP id rd18so390801iec.9
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 15:08:42 -0700 (PDT)
Received: from mail-ie0-x22f.google.com (mail-ie0-x22f.google.com [2607:f8b0:4001:c03::22f])
        by mx.google.com with ESMTPS id le20si25138745icc.96.2014.06.11.15.08.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Jun 2014 15:08:42 -0700 (PDT)
Received: by mail-ie0-f175.google.com with SMTP id tp5so388557ieb.34
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 15:08:41 -0700 (PDT)
Date: Wed, 11 Jun 2014 15:08:39 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: Proposal to realize hot-add *several sections one time*
In-Reply-To: <53981D81.5060708@huawei.com>
Message-ID: <alpine.DEB.2.02.1406111503050.27885@chino.kir.corp.google.com>
References: <53981D81.5060708@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Zhen <zhenzhang.zhang@huawei.com>
Cc: gregkh@linuxfoundation.org, laijs@cn.fujitsu.com, sjenning@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wang Nan <wangnan0@huawei.com>

On Wed, 11 Jun 2014, Zhang Zhen wrote:

> Hi,
> 
> Now we can hot-add memory by
> 
> % echo start_address_of_new_memory > /sys/devices/system/memory/probe
> 
> Then, [start_address_of_new_memory, start_address_of_new_memory +
> memory_block_size] memory range is hot-added.
> 
> But we can only hot-add *one section one time* by this way.
> Whether we can add an argument on behalf of the count of the sections to add ?
> So we can can hot-add *several sections one time*. Just like:
> 

Not necessarily true, it depends on sections_per_block.  Don't believe 
Documentation/memory-hotplug.txt that suggests this is only for powerpc, 
x86 and sh allow this interface as well.

> % echo start_address_of_new_memory count_of_sections > /sys/devices/system/memory/probe
> 
> Then, [start_address_of_new_memory, start_address_of_new_memory +
> count_of_sections * memory_block_size] memory range is hot-added.
> 
> If this proposal is reasonable, i will send a patch to realize it.
> 

The problem is knowing how much memory is being onlined so that you can 
definitively determine what count_of_sections should be.  The number of 
pages per memory section depends on PAGE_SIZE and SECTION_SIZE_BITS which 
differ depending on the architectures that support this interface.  So if 
you support count_of_sections, it would return errno even though you have 
onlined some sections.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
