Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id B65126B0035
	for <linux-mm@kvack.org>; Thu, 31 Jul 2014 10:13:24 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id lj1so3699470pab.19
        for <linux-mm@kvack.org>; Thu, 31 Jul 2014 07:13:24 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ki8si159955pdb.319.2014.07.31.07.13.21
        for <linux-mm@kvack.org>;
        Thu, 31 Jul 2014 07:13:21 -0700 (PDT)
Date: Thu, 31 Jul 2014 10:13:15 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v8 04/22] Change direct_access calling convention
Message-ID: <20140731141315.GT6754@linux.intel.com>
References: <cover.1406058387.git.matthew.r.wilcox@intel.com>
 <b78b33d94b669a5fbd02e06f2493b43dd5d77698.1406058387.git.matthew.r.wilcox@intel.com>
 <53D9174C.7040906@gmail.com>
 <20140730194503.GQ6754@linux.intel.com>
 <53DA165E.8040601@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53DA165E.8040601@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <openosd@gmail.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jul 31, 2014 at 01:11:42PM +0300, Boaz Harrosh wrote:
> >>> +	if (size < 0)
> >>
> >> 	if(size < PAGE_SIZE), No?
> > 
> > No, absolutely not.  PAGE_SIZE is unsigned long, which (if I understand
> > my C integer promotions correctly) means that 'size' gets promoted to
> > an unsigned long, and we compare them unsigned, so errors will never be
> > caught by this check.
> 
> Good point I agree that you need a cast ie.
> 
>  	if(size < (long)PAGE_SIZE)
> 
> The reason I'm saying this is because of a bug I actually hit when
> playing with partitioning and fdisk, it came out that the last partition's
> size was not page aligned, and code that checked for (< 0) crashed because
> prd returned the last two sectors of the partition, since your API is sector
> based this can happen for you here, before you are memseting a PAGE_SIZE
> you need to test there is space, No? 

Not in ext2/ext4.  It requires block size == PAGE_SIZE, so it's never
going to request the last partial block in a partition.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
