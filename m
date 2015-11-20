Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id A43C86B0253
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 22:13:25 -0500 (EST)
Received: by qgea14 with SMTP id a14so65062559qge.0
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 19:13:25 -0800 (PST)
Received: from mail-qk0-x22d.google.com (mail-qk0-x22d.google.com. [2607:f8b0:400d:c09::22d])
        by mx.google.com with ESMTPS id e200si9354400qhc.22.2015.11.19.19.13.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Nov 2015 19:13:25 -0800 (PST)
Received: by qkfo3 with SMTP id o3so32650302qkf.1
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 19:13:24 -0800 (PST)
Date: Thu, 19 Nov 2015 22:13:21 -0500
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [RFC 0/8] userfaultfd: add write protect support
Message-ID: <20151120031321.GC3093@gmail.com>
References: <cover.1447964595.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <cover.1447964595.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, kernel-team@fb.com, Andrew Morton <akpm@linux-foundation.org>

On Thu, Nov 19, 2015 at 02:33:45PM -0800, Shaohua Li wrote:
> Hi,
> 
> There is plan to support write protect fault into userfaultfd before, but it's
> not implemented yet. I'm working on a library to support different types of
> buffer like compressed buffer and file buffer, something like a page cache
> implementation in userspace. The buffer enables userfaultfd and does something
> like decompression in userfault handler. When memory size exceeds a
> threshold, madvise is used to reclaim memory. The problem is data can be
> corrupted in reclaim without memory protection support.
> 
> For example, in the compressed buffer case, reclaim does:
> 1. compress memory range and store compressed data elsewhere
> 2. madvise the memory range
> 
> But if the memory is changed before 2, new change is lost. memory write
> protection can solve the issue. With it, the reclaim does:
> 1. write protect memory range
> 2. compress memory range and store compressed data elsewhere
> 3. madvise the memory range
> 4. undo write protect memory range and wakeup tasks waiting in write protect
> fault.
> If a task changes memory before 3, write protect fault will be triggered. we
> can put the task into sleep till step 4 runs for example. In this way memory
> changes will not be lost.

While i understand the whole concept of write protection while doing compression.
I do not see valid usecase for this. Inside the kernel we already have thing like
zswap that already does what you seem to want to do (ie compress memory range and
transparently uncompress it on next CPU access).

I fail to see a usecase where we would realy would like to do this in userspace.

> 
> This patch set add write protect support for userfaultfd. One issue is write
> protect fault can happen even without enabling write protect in userfault. For
> example, a write to address backed by zero page. There is no way to distinguish
> if this is a write protect fault expected by userfault. This patch just blindly
> triggers write protect fault to userfault if corresponding vma enables
> VM_UFFD_WP. Application should be prepared to handle such write protect fault.
> 
> Thanks,
> Shaohua
> 
> 
> Shaohua Li (8):
>   userfaultfd: add helper for writeprotect check
>   userfaultfd: support write protection for userfault vma range
>   userfaultfd: expose writeprotect API to ioctl
>   userfaultfd: allow userfaultfd register success with writeprotection
>   userfaultfd: undo write proctection in unregister
>   userfaultfd: hook userfault handler to write protection fault
>   userfaultfd: fault try one more time
>   userfaultfd: enabled write protection in userfaultfd API

>From organization point of view, i would put the "expose writeprotect API to ioctl"
as the last patch in the serie after all the plumbing is done. This would make
"enabled write protection in userfaultfd API" useless and avoid akward changes in
some of the others patches where you add commented/disabled code.

Also you want to handle GUP, like you want the write protection to fails if there
is GUP and you want GUP to force breaking write protection, otherwise this will be
broken if anyone mix it with something that trigger GUP.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
