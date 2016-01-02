Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0725A6B0003
	for <linux-mm@kvack.org>; Sat,  2 Jan 2016 06:45:10 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id f206so156399485wmf.0
        for <linux-mm@kvack.org>; Sat, 02 Jan 2016 03:45:09 -0800 (PST)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id i7si59855991wmf.59.2016.01.02.03.45.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Jan 2016 03:45:08 -0800 (PST)
Received: by mail-wm0-x22f.google.com with SMTP id u188so101784283wmu.1
        for <linux-mm@kvack.org>; Sat, 02 Jan 2016 03:45:08 -0800 (PST)
Subject: Re: [PATCH, RESEND] ipc/shm: handle removed segments gracefully in
 shm_mmap()
References: <1447232220-36879-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20151111170347.GA3502@linux-uzut.site>
 <20151111195023.GA17310@node.shutemov.name>
 <20151113053137.GB3502@linux-uzut.site>
 <20151113091259.GB28904@node.shutemov.name>
 <20151113192310.GC3502@linux-uzut.site>
From: Manfred Spraul <manfred@colorfullife.com>
Message-ID: <5687B843.2040804@colorfullife.com>
Date: Sat, 2 Jan 2016 12:45:07 +0100
MIME-Version: 1.0
In-Reply-To: <20151113192310.GC3502@linux-uzut.site>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dmitry Vyukov <dvyukov@google.com>

On 11/13/2015 08:23 PM, Davidlohr Bueso wrote:
>
> So considering EINVAL, even your approach to bumping up nattach by 
> calling
> _shm_open earlier isn't enough. Races exposed to user called rmid can 
> still
> occur between dropping the lock and doing ->mmap(). Ultimately this 
> leads to
> all ipc_valid_object() checks, as we totally ignore SHM_DEST segments 
> nowadays
> since we forbid mapping previously removed segments.
>
> I think this is the first thing we must decide before going forward 
> with this
> mess. ipc currently defines invalid objects by merely checking the 
> deleted flag.
>
> Manfred, any thoughts?
>
With regards to locking: Sorry, shm is too different to msg/sem/mqueue.

With regards to EIDRM / EINVAL:
When all kernel memory was released, then the kernel cannot find out if 
the ID was valid at one time or not.
Thus EIDRM can only be a hint, the OS (kernel/libc) cannot guarantee 
that user space will never see something else.
(trivial example: user space sleeps just before the syscall)

So I would not create special code to optimize EIDRM handling for races. 
If we sometimes report EINVAL, it would be probably ok as well.

--
     Manfred

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
