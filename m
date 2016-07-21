Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id C6B0A6B0274
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 04:10:58 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id u142so121725005oia.2
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 01:10:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y66si1213320itc.57.2016.07.21.01.10.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jul 2016 01:10:58 -0700 (PDT)
Date: Thu, 21 Jul 2016 16:10:49 +0800
From: Dave Young <dyoung@redhat.com>
Subject: Re: [PATCH] kexec: add resriction on the kexec_load
Message-ID: <20160721081049.GA7544@dhcp-128-65.nay.redhat.com>
References: <1468980049-1753-1-git-send-email-zhongjiang@huawei.com>
 <878twxcbae.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <878twxcbae.fsf@x220.int.ebiederm.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: zhongjiang <zhongjiang@huawei.com>, kexec@lists.infradead.org, akpm@linux-foundation.org, horms@verge.net.au, yinghai@kernel.org, linux-mm@kvack.org

On 07/19/16 at 09:07pm, Eric W. Biederman wrote:
> zhongjiang <zhongjiang@huawei.com> writes:
> 
> > From: zhong jiang <zhongjiang@huawei.com>
> >
> > I hit the following question when run trinity in my system. The
> > kernel is 3.4 version. but the mainline have same question to be
> > solved. The root cause is the segment size is too large, it can
> > expand the most of the area or the whole memory, therefore, it
> > may waste an amount of time to abtain a useable page. and other
> > cases will block until the test case quit. at the some time,
> > OOM will come up.
> 
> 5MiB is way too small.  I have seen vmlinux images not to mention
> ramdisks that get larger than that.  Depending on the system
> 1GiB might not be an unreasonable ramdisk size.  AKA run an entire live
> system out of a ramfs.  It works well if you have enough memory.

There was a use case from Michael Holzheu about a 1.5G ramdisk, see below
kexec-tools commit:

commit 95741713e790fa6bde7780bbfb772ad88e81a744
Author: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Date:   Fri Oct 30 16:02:04 2015 +0100

    kexec/s390x: use mmap instead of read for slurp_file()
    
    The slurp_fd() function allocates memory and uses the read() system
call.
    This results in double memory consumption for image and initrd:
    
     1) Memory allocated in user space by the kexec tool
     2) Memory allocated in kernel by the kexec() system call
    
    The following illustrates the use case that we have on s390x:
    
     1) Boot a 4 GB Linux system
     2) Copy kernel and 1,5 GB ramdisk from external source into tmpfs
(ram)
     3) Use kexec to boot kernel with ramdisk
    
     Therefore for kexec runtime we need:
    
     1,5 GB (tmpfs) + 1,5 GB (kexec malloc) + 1,5 GB (kernel memory) =
4,5 GB
    
    This patch introduces slurp_file_mmap() which for "normal" files
uses
    mmap() instead of malloc()/read(). This reduces the runtime memory
    consumption of the kexec tool as follows:
    
     1,5 GB (tmpfs) + 1,5 GB (kernel memory) = 3 GB
    
    Signed-off-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>
    Reviewed-by: Dave Young <dyoung@redhat.com>
    Signed-off-by: Simon Horman <horms@verge.net.au>

> 
> I think there is a practical limit at about 50% of memory (because we
> need two copies in memory the source and the destination pages), but
> anything else is pretty much reasonable and should have a fair chance of
> working.
> 
> A limit that reflected that reality above would be interesting.
> Anything else will likely cause someone trouble in the futrue.

Maybe one should test his ramdisk first to ensure it works first before
really using it.

Thanks
Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
