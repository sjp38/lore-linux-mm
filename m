Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id C3DAA6B0038
	for <linux-mm@kvack.org>; Wed,  3 May 2017 15:03:04 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id g74so100988694ioi.4
        for <linux-mm@kvack.org>; Wed, 03 May 2017 12:03:04 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id h126si12337655ioa.170.2017.05.03.12.03.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 May 2017 12:03:03 -0700 (PDT)
Subject: Re: [PATCH RFC] hugetlbfs 'noautofill' mount option
References: <326e38dd-b4a8-e0ca-6ff7-af60e8045c74@oracle.com>
 <b0efc671-0d7a-0aef-5646-a635478c31b0@oracle.com>
 <7ff6fb32-7d16-af4f-d9d5-698ab7e9e14b@intel.com>
 <03127895-3c5a-5182-82de-3baa3116749e@oracle.com>
 <22557bf3-14bb-de02-7b1b-a79873c583f1@intel.com>
From: Prakash Sangappa <prakash.sangappa@oracle.com>
Message-ID: <7677d20e-5d53-1fb7-5dac-425edda70b7b@oracle.com>
Date: Wed, 3 May 2017 12:02:59 -0700
MIME-Version: 1.0
In-Reply-To: <22557bf3-14bb-de02-7b1b-a79873c583f1@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 5/2/17 4:43 PM, Dave Hansen wrote:

> On 05/02/2017 04:34 PM, Prakash Sangappa wrote:
>> Similarly, a madvise() option also requires additional system call by every
>> process mapping the file, this is considered a overhead for the database.
> How long-lived are these processes?  For a database, I'd assume that
> this would happen a single time, or a single time per mmap() at process
> startup time.  Such a syscall would be doing something on the order of
> taking mmap_sem, walking the VMA tree, setting a bit per VMA, and
> unlocking.  That's a pretty cheap one-time cost...
Plus a call into the filesystem (a_ops?) to check if the underlying 
filesystem
supports not filling holes to mapped access before setting the bit per vma.
Although the overhead may not be that bad.

Database processes can exit and new once started, for instance, depending on
database activity.


>> If we do consider a new madvise() option, will it be acceptable
>> since this will be specifically for hugetlbfs file mappings?
> Ideally, it would be something that is *not* specifically for hugetlbfs.
>   MADV_NOAUTOFILL, for instance, could be defined to SIGSEGV whenever
> memory is touched that was not populated with MADV_WILLNEED, mlock(), etc...

If this is a generic advice type, necessary support will have to be 
implemented
in various filesystems which can support this.

The proposed behavior for 'noautofill' was to not fill holes in 
files(like sparse files).
In the page fault path, mm would not know if the mmapped address on which
the fault occurred, is over a hole in the file or just that the page is 
not available
in the page cache. The underlying filesystem would be called and it 
determines
if it is a hole and that is where it would fail and not fill the hole, 
if this support is added.
Normally, filesystem which support sparse files(holes in file) 
automatically fill the hole
when accessed. Then there is the issue of file system block size and 
page size. If the
block sizes are smaller then page size, it could mean the noautofill 
would only work
if the hole size is equal to  or a multiple of, page size?

In case of hugetlbfs it is much straight forward. Since this filesystem 
is not like a normal
filesystems and and the file sizes are multiple of huge pages. The hole 
will be a multiple
of the huge page size. For this reason then should the advise be 
specific to hugetlbfs?


>
>> If so,
>> would a new flag to mmap() call itself be acceptable, which would
>> define the proposed behavior?. That way no additional system calls
>> need to be made.
> I don't feel super strongly about it, but I guess an mmap() flag could
> work too.
>

Same goes with the mmap call, if it is a generic flag.

-Prakash.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
