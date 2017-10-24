Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id EE1CC6B0038
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 17:21:25 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e64so19317828pfk.0
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 14:21:25 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id s16si629123plp.187.2017.10.24.14.21.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Oct 2017 14:21:24 -0700 (PDT)
Date: Tue, 24 Oct 2017 15:21:19 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 01/17] mm: introduce MAP_SHARED_VALIDATE, a mechanism to
 safely define new mmap flags
Message-ID: <20171024212119.GB1611@linux.intel.com>
References: <20171024152415.22864-1-jack@suse.cz>
 <20171024152415.22864-2-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171024152415.22864-2-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@infradead.org>, linux-ext4@vger.kernel.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Oct 24, 2017 at 05:23:58PM +0200, Jan Kara wrote:
> From: Dan Williams <dan.j.williams@intel.com>
> 
> The mmap(2) syscall suffers from the ABI anti-pattern of not validating
> unknown flags. However, proposals like MAP_SYNC need a mechanism to
> define new behavior that is known to fail on older kernels without the
> support. Define a new MAP_SHARED_VALIDATE flag pattern that is
> guaranteed to fail on all legacy mmap implementations.
> 
> It is worth noting that the original proposal was for a standalone
> MAP_VALIDATE flag. However, when that  could not be supported by all
> archs Linus observed:
> 
>     I see why you *think* you want a bitmap. You think you want
>     a bitmap because you want to make MAP_VALIDATE be part of MAP_SYNC
>     etc, so that people can do
> 
>     ret = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED
> 		    | MAP_SYNC, fd, 0);
> 
>     and "know" that MAP_SYNC actually takes.
> 
>     And I'm saying that whole wish is bogus. You're fundamentally
>     depending on special semantics, just make it explicit. It's already
>     not portable, so don't try to make it so.
> 
>     Rename that MAP_VALIDATE as MAP_SHARED_VALIDATE, make it have a value
>     of 0x3, and make people do
> 
>     ret = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED_VALIDATE
> 		    | MAP_SYNC, fd, 0);
> 
>     and then the kernel side is easier too (none of that random garbage
>     playing games with looking at the "MAP_VALIDATE bit", but just another
>     case statement in that map type thing.
> 
>     Boom. Done.
> 
> Similar to ->fallocate() we also want the ability to validate the
> support for new flags on a per ->mmap() 'struct file_operations'
> instance basis.  Towards that end arrange for flags to be generically
> validated against a mmap_supported_flags exported by 'struct
> file_operations'. By default all existing flags are implicitly
> supported, but new flags require MAP_SHARED_VALIDATE and
> per-instance-opt-in.
> 
> Cc: Jan Kara <jack@suse.cz>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Suggested-by: Christoph Hellwig <hch@lst.de>
> Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> Signed-off-by: Jan Kara <jack@suse.cz>

Looks great.

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
