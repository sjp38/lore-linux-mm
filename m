Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 64AE06B0005
	for <linux-mm@kvack.org>; Sat, 16 Apr 2016 01:05:33 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id zy2so158253558pac.1
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 22:05:33 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b200si7654446pfb.63.2016.04.15.22.05.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 22:05:32 -0700 (PDT)
Date: Fri, 15 Apr 2016 22:05:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 0/2] Align mmap address for DAX pmd mappings
Message-Id: <20160415220531.c7b55adb5b26eb749fae3186@linux-foundation.org>
In-Reply-To: <1460652511-19636-1-git-send-email-toshi.kani@hpe.com>
References: <1460652511-19636-1-git-send-email-toshi.kani@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: dan.j.williams@intel.com, viro@zeniv.linux.org.uk, willy@linux.intel.com, ross.zwisler@linux.intel.com, kirill.shutemov@linux.intel.com, david@fromorbit.com, jack@suse.cz, tytso@mit.edu, adilger.kernel@dilger.ca, linux-nvdimm@ml01.01.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 14 Apr 2016 10:48:29 -0600 Toshi Kani <toshi.kani@hpe.com> wrote:

> When CONFIG_FS_DAX_PMD is set, DAX supports mmap() using pmd page
> size.  This feature relies on both mmap virtual address and FS
> block (i.e. physical address) to be aligned by the pmd page size.
> Users can use mkfs options to specify FS to align block allocations.
> However, aligning mmap address requires code changes to existing
> applications for providing a pmd-aligned address to mmap().
> 
> For instance, fio with "ioengine=mmap" performs I/Os with mmap() [1].
> It calls mmap() with a NULL address, which needs to be changed to
> provide a pmd-aligned address for testing with DAX pmd mappings.
> Changing all applications that call mmap() with NULL is undesirable.
> 
> This patch-set extends filesystems to align an mmap address for
> a DAX file so that unmodified applications can use DAX pmd mappings.

Matthew sounded unconvinced about the need for this patchset, but I
must say that

: The point is that we do not need to modify existing applications for using
: DAX PMD mappings.
: 
: For instance, fio with "ioengine=mmap" performs I/Os with mmap(). 
: https://github.com/caius/fio/blob/master/engines/mmap.c
: 
: With this change, unmodified fio can be used for testing with DAX PMD
: mappings.  There are many examples like this, and I do not think we want
: to modify all applications that we want to evaluate/test with.

sounds pretty convincing?


And if we go ahead with this, it looks like 4.7 material to me - it
affects ABI and we want to get that stabilized asap.  What do people
think?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
