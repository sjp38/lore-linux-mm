Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E86CA6B0399
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 20:45:03 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 77so135721940pgc.5
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 17:45:03 -0800 (PST)
Received: from cmccmta1.chinamobile.com (cmccmta1.chinamobile.com. [221.176.66.79])
        by mx.google.com with ESMTP id i9si8103734plk.73.2017.03.09.17.45.01
        for <linux-mm@kvack.org>;
        Thu, 09 Mar 2017 17:45:02 -0800 (PST)
Subject: Re: how to unmap pages in an anonymous mmap?
References: <1487323472-20481-1-git-send-email-lixiubo@cmss.chinamobile.com>
 <09891673-0d95-8b66-ddce-0ace7aea43d1@redhat.com>
 <48b49493-4c82-3ed5-126f-2ea18c701242@cmss.chinamobile.com>
 <21d93bec-a717-5157-8dcf-cc629611572f@redhat.com>
 <85a41492-8aba-b752-c180-ec25f43d2a1a@cmss.chinamobile.com>
 <dfafac31-b762-4939-14f6-8939e661dcd1@redhat.com>
From: Xiubo Li <lixiubo@cmss.chinamobile.com>
Message-ID: <4f1d4fe7-7615-6034-9a63-068535b79e42@cmss.chinamobile.com>
Date: Fri, 10 Mar 2017 09:45:00 +0800
MIME-Version: 1.0
In-Reply-To: <dfafac31-b762-4939-14f6-8939e661dcd1@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andy Grover <agrover@redhat.com>, nab@linux-iscsi.org, mchristi@redhat.com, shli@kernel.org, hch@lst.de, sheng@yasker.org, namei.unix@gmail.com, bart.vanassche@sandisk.com, linux-scsi@vger.kernel.org, target-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Jianfei Hu <hujianfei@cmss.chinamobile.com>



On 2017a1'02ae??28ae?JPY 03:32, Andy Grover wrote:
> On 02/26/2017 09:59 PM, Xiubo Li wrote:
>>> But, We likely don't want to release memory from the data area anyways
>>> while active, in any case. How about if we set a timer when active
>>> commands go to zero, and then reduce data area to some minimum if no new
>>> cmds come in before timer expires?
>> If I understand correctly: for example, we have 1G(as the minimum)
>> data area and all blocks have been allocated and mapped to runner's
>> vma, then we extern it to 1G + 256M as needed. When there have no
>> active cmds and after the timer expires, will it reduce the data area
>> back to 1G ? And then should it release the reduced 256M data area's
>> memories ?
>>
>> If so, after kfree()ed the blocks' memories, it should also try to remove
>> all the ptes which are mapping this page(like using the try_to_umap()),
>> but something like try_to_umap() doesn't export for the modules.
>>
>> Without ummaping the kfree()ed pages' ptes mentioned above, then
>> the reduced 256M vma space couldn't be reused again for the runner
>> process, because the runner has already do the mapping for the reduced
>> vma space to some old physical pages(won't trigger new page fault
>> again). Then there will be a hole, and the hole will be bigger and bigger.
>>
>> Without ummaping the kfree()ed pages' ptes mentioned above, the
>> pages' reference count (page_ref_dec(), which _inc()ed in page fault)
>> couldn't be reduced back too.
> Let's ask people who will know...
>
> Hi linux-mm,
>
> TCM-User (drivers/target/target_core_user.c) currently uses vmalloc()ed
> memory to back a ring buffer that is mmaped by userspace.
>
> We want to move to dynamically mapping pages into this region, and also
> we'd like to unmap/free pages when idle. What's the right way to unmap?
> I see unmap_mapping_range() but that mentions an underlying file, which
> TCMU doesn't have. Or maybe zap_page_range()? But it's not exported.
Hi linux-mm

For the TCMU case, the vm is not anonymous mapping. And still has
device file desc:

mmap(NULL, len, PROT_READ|PROT_WRITE, MAP_SHARED, dev->fd, 0);

If using the unmap_mapping_range() to do the dynamically maping,
is it okay ? Any other potential risks ?

Or the mentioned 'underlying file' is must one desk file ?

Thanks very much,

BRs
Xiubo



> Any advice?
>
> Thanks in advance -- Regards -- Andy



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
