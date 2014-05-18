Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id B9E2F6B0036
	for <linux-mm@kvack.org>; Sun, 18 May 2014 10:58:20 -0400 (EDT)
Received: by mail-we0-f180.google.com with SMTP id t61so4510652wes.11
        for <linux-mm@kvack.org>; Sun, 18 May 2014 07:58:20 -0700 (PDT)
Received: from mail-wg0-x234.google.com (mail-wg0-x234.google.com [2a00:1450:400c:c00::234])
        by mx.google.com with ESMTPS id j8si6384676wje.75.2014.05.18.07.58.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 18 May 2014 07:58:19 -0700 (PDT)
Received: by mail-wg0-f52.google.com with SMTP id l18so6873629wgh.35
        for <linux-mm@kvack.org>; Sun, 18 May 2014 07:58:18 -0700 (PDT)
Message-ID: <5378CA88.3080105@gmail.com>
Date: Sun, 18 May 2014 17:58:16 +0300
From: Boaz Harrosh <openosd@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v7 00/22] Support ext4 on NV-DIMMs
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1395591795.git.matthew.r.wilcox@intel.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-kernel@vger.kernel.org, Sagi Manole <sagi.manole@gmail.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, willy@linux.intel.com

On 03/23/2014 09:08 PM, Matthew Wilcox wrote:
> One of the primary uses for NV-DIMMs is to expose them as a block device
> and use a filesystem to store files on the NV-DIMM.  While that works,
> it currently wastes memory and CPU time buffering the files in the page
> cache.  We have support in ext2 for bypassing the page cache, but it
> has some races which are unfixable in the current design.  This series
> of patches rewrite the underlying support, and add support for direct
> access to ext4.
> 
> This iteration of the patchset rebases to Linus' 3.14-rc7 (plus Kirill's
> patches in linux-next http://marc.info/?l=linux-mm&m=139206489208546&w=2)


Hi Matthew

We are experimenting with NV-DIMMs. The experiment will use its own
FS not based on ext4 at all, more like the infamous PMFS but we want
to start DAX based and not current XIP based. We want to make sure the proposed
new API can be utilized stand alone and there are no extX based assumptions.
(Like the need for direct directory access instead of the ext4
 copy-from-nvdimm-to-ram directory)

Could you please put these patches on a public tree somewhere, or perhaps some
later version, that I can pull directly from? this would help alot.

These patches are a bit hard to patch because it is not clear what
Kirill's patches I need. I tried some linux-next version around 3.14-rc7 that
also include Kirill's patches but it looks like there was farther work done
then your base. I was able to produce a tree with V6 of your
patches but I would hate to do that manual work yet again.
(Any linux base is fine just that I can pull it)
Thanks

Also I'm curios. I see you guys where working on PMFS for a while
fixing and enhancing stuff. Then development stopped and these DAX
patches started showing. Now, PMFS is based on current XIP (I was able
to easily port it to 3.14-rc7). Do you guys have an Internal attempt
to port PMFS to DAX? (We might do it in future just as an exercise
to get intimate with DAX and to make sure nothing is missing.)
What are your plans with PMFS is it dead?

Good day
Boaz



> and fixes several bugs:
> 
>  - Initialise cow_page in do_page_mkwrite() (Matthew Wilcox)
>  - Clear new or unwritten blocks in page fault handler (Matthew Wilcox)
>  - Only call get_block when necessary (Matthew Wilcox)
>  - Reword Kconfig options (Matthew Wilcox / Vishal Verma)
>  - Fix a race between page fault and truncate (Matthew Wilcox)
>  - Fix a race between fault-for-read and fault-for-write (Matthew Wilcox)
>  - Zero the correct bytes in dax_new_buf() (Toshi Kani)
>  - Add DIO_LOCKING to an invocation of dax_do_io in ext4 (Ross Zwisler)
> 
> Relative to the last patchset, I folded the 'Add reporting of major faults'
> patch into the patch that adds the DAX page fault handler.
> 
> The v6 patchset had seven additional xfstests failures.  This patchset
> now passes approximately as many xfstests as ext4 does on a ramdisk.
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
