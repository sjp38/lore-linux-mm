Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 2BD3D6B0031
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 14:24:09 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so5914988pab.8
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 11:24:08 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id qd5si15293692pbb.211.2014.06.17.11.24.07
        for <linux-mm@kvack.org>;
        Tue, 17 Jun 2014 11:24:08 -0700 (PDT)
Date: Tue, 17 Jun 2014 14:19:25 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v7 00/22] Support ext4 on NV-DIMMs
Message-ID: <20140617181925.GF12025@linux.intel.com>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
 <53A084E3.6080103@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53A084E3.6080103@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <openosd@gmail.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jun 17, 2014 at 09:11:47PM +0300, Boaz Harrosh wrote:
> Looking at the brd code I fail to see how it will ever support NV_DIMMS.
> brd is "struct page" based and shares RAM from the same memory pool as the rest
> of the system. But NV_DIMMS is not page-based and is excluded from the
> memory system. It needs to be exclusively owned by a device and the mounted
> FS.
> 
> We currently have in our lab the old DDR3 based NV_DIMMS and on regular boot
> it appears as RAM. We need to use memmap= option on command line of Kernel
> to exclude it from use by Kernel.
> 
> We have received our DDR4 based NV_DIMMS but still waiting for the actual
> system board to support it. As I understand from STD documentation
> these devices will not identify as RAM and will be exported as ACPI or
> SBUS devices that can be queried for sizes and address as well as properties
> about the chips. So I imagine a udev rule will need to probe the right driver
> to mount over those.
> 
> So currently from what I can see only the infamous PMFS is the setup that
> can actually mount/support my NV_DIMMS today.
> 
> It seems to me like we need a *new* block device that receives, like PMFS,
> an physical_address + size on load and will export this raw region as a block
> device. Of course with support of new DAX API. Should I send in such a device
> code.
> 
> (I've seen the linux-nvdimm project on github but did not see how my above
>  problem is addressed, it looks geared for that other type DDR bus devices)
> 
> So please how is all that suppose to work, what is the strategy stack
> for all this? I guess for now I'm stuck with PMFS.
> 
> (BTW: A public git tree of DAX patches ;-) )

https://github.com/01org/prd should sort you out with both a git tree
and a new block driver.  You'll need to tell it manually what address
range to use.  I'm using it against regular DIMMs, and this works pretty
well for me since my BIOS doesn't zero DRAM on reset.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
