Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id D9DAB6B0260
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 01:55:18 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ez1so176049980pab.0
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 22:55:18 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id a25si14044248pfg.33.2016.07.21.22.55.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 21 Jul 2016 22:55:18 -0700 (PDT)
Message-ID: <5791B490.2010607@huawei.com>
Date: Fri, 22 Jul 2016 13:52:16 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] kexec: add resriction on the kexec_load
References: <1468980049-1753-1-git-send-email-zhongjiang@huawei.com> <878twxcbae.fsf@x220.int.ebiederm.org> <20160721081049.GA7544@dhcp-128-65.nay.redhat.com>
In-Reply-To: <20160721081049.GA7544@dhcp-128-65.nay.redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Young <dyoung@redhat.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, kexec@lists.infradead.org, akpm@linux-foundation.org, horms@verge.net.au, yinghai@kernel.org, linux-mm@kvack.org

On 2016/7/21 16:10, Dave Young wrote:
> On 07/19/16 at 09:07pm, Eric W. Biederman wrote:
>> zhongjiang <zhongjiang@huawei.com> writes:
>>
>>> From: zhong jiang <zhongjiang@huawei.com>
>>>
>>> I hit the following question when run trinity in my system. The
>>> kernel is 3.4 version. but the mainline have same question to be
>>> solved. The root cause is the segment size is too large, it can
>>> expand the most of the area or the whole memory, therefore, it
>>> may waste an amount of time to abtain a useable page. and other
>>> cases will block until the test case quit. at the some time,
>>> OOM will come up.
>> 5MiB is way too small.  I have seen vmlinux images not to mention
>> ramdisks that get larger than that.  Depending on the system
>> 1GiB might not be an unreasonable ramdisk size.  AKA run an entire live
>> system out of a ramfs.  It works well if you have enough memory.
> There was a use case from Michael Holzheu about a 1.5G ramdisk, see below
> kexec-tools commit:
>
> commit 95741713e790fa6bde7780bbfb772ad88e81a744
> Author: Michael Holzheu <holzheu@linux.vnet.ibm.com>
> Date:   Fri Oct 30 16:02:04 2015 +0100
>
>     kexec/s390x: use mmap instead of read for slurp_file()
>     
>     The slurp_fd() function allocates memory and uses the read() system
> call.
>     This results in double memory consumption for image and initrd:
>     
>      1) Memory allocated in user space by the kexec tool
>      2) Memory allocated in kernel by the kexec() system call
>     
>     The following illustrates the use case that we have on s390x:
>     
>      1) Boot a 4 GB Linux system
>      2) Copy kernel and 1,5 GB ramdisk from external source into tmpfs
> (ram)
>      3) Use kexec to boot kernel with ramdisk
>     
>      Therefore for kexec runtime we need:
>     
>      1,5 GB (tmpfs) + 1,5 GB (kexec malloc) + 1,5 GB (kernel memory) =
> 4,5 GB
>     
>     This patch introduces slurp_file_mmap() which for "normal" files
> uses
>     mmap() instead of malloc()/read(). This reduces the runtime memory
>     consumption of the kexec tool as follows:
>     
>      1,5 GB (tmpfs) + 1,5 GB (kernel memory) = 3 GB
>     
>     Signed-off-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>
>     Reviewed-by: Dave Young <dyoung@redhat.com>
>     Signed-off-by: Simon Horman <horms@verge.net.au>
>
>> I think there is a practical limit at about 50% of memory (because we
>> need two copies in memory the source and the destination pages), but
>> anything else is pretty much reasonable and should have a fair chance of
>> working.
>>
>> A limit that reflected that reality above would be interesting.
>> Anything else will likely cause someone trouble in the futrue.
> Maybe one should test his ramdisk first to ensure it works first before
> really using it.
>
> Thanks
> Dave
>
> .
>
 Thank you reply.  I just test the syscall kexec_load, I don't really run kexec iamge to boot machine.
 Recently , I hit the question. I fix it by passing resonable parameters to kernel from user space.
 no functional change.   is right?  
 according to the W. Biederman advice, I agree so. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
