Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 58C7C6B05B2
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 09:00:21 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id t3so11424868pgt.8
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 06:00:21 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id u128si4698168pfu.374.2017.08.25.06.00.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Aug 2017 06:00:19 -0700 (PDT)
Date: Fri, 25 Aug 2017 06:00:11 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v6 3/5] mm: introduce mmap3 for safely defining new mmap
 flags
Message-ID: <20170825130011.GA30072@infradead.org>
References: <150353211413.5039.5228914877418362329.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150353213097.5039.6729469069608762658.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20170824165546.GA3121@infradead.org>
 <CAPcyv4iN0QpUSgOUvisnNQsiV1Pp=4dh7CwAV8FFj=_rFU=aug@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4iN0QpUSgOUvisnNQsiV1Pp=4dh7CwAV8FFj=_rFU=aug@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux API <linux-api@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-xfs@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Aug 24, 2017 at 10:36:02AM -0700, Dan Williams wrote:
> I'll let Andy and Kirill restate their concerns, but one of the
> arguments that swayed me is that any new mmap flag with this hack must
> be documented to only work with MAP_SHARED and that MAP_PRIVATE is
> silently ignored. I agree with the mess and delays it causes for other
> archs and libc, but at the same time this is for new applications and
> libraries that know to look for the new flag, so they need to do the
> extra work to check for the new syscall.

True.  That is for the original hack, but I spent some more time
looking at the mmap code, and there is one thing I noticed:

include/uapi/asm-generic/mman-common.h:

#define MAP_SHARED      0x01            /* Share changes */
#define MAP_PRIVATE     0x02            /* Changes are private */
#define MAP_TYPE        0x0f            /* Mask for type of mapping */

mm/mmap.c:

	if (file) {
		struct inode *inode = file_inode(file);

		switch (flags & MAP_TYPE) {
                case MAP_SHARED:
			...
		case MAP_PRIVATE:
			...
		default:
			return -EINVAL;
		}

and very similar for the anonymous and nommu cases.

So if we pick e.g. 0x4 as the valid bit we don't even need to overload
the MAP_SHARED and MAP_PRIVATE meaning.

> 
> However, if the fcntl lease approach works for the DMA cases then we
> only have the one mmap flag to add for now, so maybe the weird
> MAP_{SHARED|PRIVATE} semantics are tolerable.
---end quoted text---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
