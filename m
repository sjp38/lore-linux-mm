Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id D374D440846
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 12:58:45 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id y15so103438pgc.9
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 09:58:45 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id x6si3106547pfk.446.2017.08.24.09.58.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 09:58:43 -0700 (PDT)
Date: Thu, 24 Aug 2017 09:58:38 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v6 1/5] vfs: add flags parameter to ->mmap() in 'struct
 file_operations'
Message-ID: <20170824165838.GB3121@infradead.org>
References: <150353211413.5039.5228914877418362329.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150353211985.5039.4333061601382775843.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <150353211985.5039.4333061601382775843.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, linux-nvdimm@lists.01.org, David Airlie <airlied@linux.ie>, linux-api@vger.kernel.org, Takashi Iwai <tiwai@suse.com>, dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>, luto@kernel.org, linux-fsdevel@vger.kernel.org, Daniel Vetter <daniel.vetter@intel.com>, linux-mm@kvack.org

On Wed, Aug 23, 2017 at 04:48:40PM -0700, Dan Williams wrote:
> We are running running short of vma->vm_flags. We can avoid needing a
> new VM_* flag in some cases if the original @flags submitted to mmap(2)
> is made available to the ->mmap() 'struct file_operations'
> implementation. For example, the proposed addition of MAP_DIRECT can be
> implemented without taking up a new vm_flags bit. Another motivation to
> avoid vm_flags is that they appear in /proc/$pid/smaps, and we have seen
> software that tries to dangerously (TOCTOU) read smaps to infer the
> behavior of a virtual address range.
> 
> This conversion was performed by the following semantic patch. There
> were a few manual edits for oddities like proc_reg_mmap.
> 
> Thanks to Julia for helping me with coccinelle iteration to cover cases
> where the mmap routine is defined in a separate file from the 'struct
> file_operations' instance that consumes it.

How are we going to check that an instance actually supports any
of those flags?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
