Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id B51D16B0073
	for <linux-mm@kvack.org>; Thu, 27 Feb 2014 09:01:28 -0500 (EST)
Received: by mail-qg0-f50.google.com with SMTP id z60so5757536qgd.9
        for <linux-mm@kvack.org>; Thu, 27 Feb 2014 06:01:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id x3si2661706qab.188.2014.02.27.06.01.27
        for <linux-mm@kvack.org>;
        Thu, 27 Feb 2014 06:01:28 -0800 (PST)
Message-ID: <530F451F.9020107@redhat.com>
Date: Thu, 27 Feb 2014 15:01:03 +0100
From: Florian Weimer <fweimer@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 00/22] Support ext4 on NV-DIMMs
References: <1393337918-28265-1-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1393337918-28265-1-git-send-email-matthew.r.wilcox@intel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, willy@linux.intel.com

On 02/25/2014 03:18 PM, Matthew Wilcox wrote:
> One of the primary uses for NV-DIMMs is to expose them as a block device
> and use a filesystem to store files on the NV-DIMM.  While that works,
> it currently wastes memory and CPU time buffering the files in the page
> cache.  We have support in ext2 for bypassing the page cache, but it
> has some races which are unfixable in the current design.  This series
> of patches rewrite the underlying support, and add support for direct
> access to ext4.

I'm wondering if there is a potential security issue lurking here.

Some distributions use udisks2 to grant permission to local console 
users to create new loop devices from files.  File systems on these 
block devices are then mounted.  This is a replacement for several file 
systems implemented in user space, and for the users, this is a good 
thing because the in-kernel implementations are generally of higher quality.

What happens if we have DAX support in the entire stack, and an 
enterprising user mounts a file system?  Will she be able to fuzz the 
file system or binfmt loaders concurrently, changing the bits while they 
are being read?

Currently, it appears that the loop device duplicates pages in the page 
cache, so this does not seem to be possible, but DAX support might 
change this.

-- 
Florian Weimer / Red Hat Product Security Team

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
