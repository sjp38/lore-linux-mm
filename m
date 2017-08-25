Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 036536810C3
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 12:25:40 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y14so408703wrd.3
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 09:25:39 -0700 (PDT)
Received: from mout.gmx.net (mout.gmx.net. [212.227.17.21])
        by mx.google.com with ESMTPS id j64si1537750wmd.63.2017.08.25.09.25.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Aug 2017 09:25:38 -0700 (PDT)
Subject: Re: [PATCH v6 3/5] mm: introduce mmap3 for safely defining new mmap
 flags
References: <150353211413.5039.5228914877418362329.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150353213097.5039.6729469069608762658.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20170824165546.GA3121@infradead.org>
 <CAPcyv4iN0QpUSgOUvisnNQsiV1Pp=4dh7CwAV8FFj=_rFU=aug@mail.gmail.com>
 <20170825130011.GA30072@infradead.org>
 <20170825155803.4km7wttzadfqw2vb@node.shutemov.name>
 <20170825160236.GA2561@infradead.org>
 <20170825161607.6v6beg4zjktllt2z@node.shutemov.name>
From: Helge Deller <deller@gmx.de>
Message-ID: <4de21e8d-5e10-ec40-c731-0c079953cf48@gmx.de>
Date: Fri, 25 Aug 2017 18:19:19 +0200
MIME-Version: 1.0
In-Reply-To: <20170825161607.6v6beg4zjktllt2z@node.shutemov.name>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Christoph Hellwig <hch@infradead.org>
Cc: Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux API <linux-api@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-xfs@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-parisc@vger.kernel.org

On 25.08.2017 18:16, Kirill A. Shutemov wrote:
> On Fri, Aug 25, 2017 at 09:02:36AM -0700, Christoph Hellwig wrote:
>> On Fri, Aug 25, 2017 at 06:58:03PM +0300, Kirill A. Shutemov wrote:
>>> Not all archs are ready for this:
>>>
>>> arch/parisc/include/uapi/asm/mman.h:#define MAP_TYPE    0x03            /* Mask for type of mapping */
>>> arch/parisc/include/uapi/asm/mman.h:#define MAP_FIXED   0x04            /* Interpret addr exactly */
>>
>> I'd be happy to say that we should not care about parisc for
>> persistent memory.  We'll just have to find a way to exclude
>> parisc without making life too ugly.
> 
> I don't think creapling mmap() interface for one arch is the right way to
> go. I think the interface should be universal.
> 
> I may imagine MAP_DIRECT can be useful not only for persistent memory.
> For tmpfs instead of mlock()?

On parisc we have
#define MAP_SHARED      0x01            /* Share changes */
#define MAP_PRIVATE     0x02            /* Changes are private */
#define MAP_TYPE        0x03            /* Mask for type of mapping */
#define MAP_FIXED       0x04            /* Interpret addr exactly */
#define MAP_ANONYMOUS   0x10            /* don't use a file */

So, if you need a MAP_DIRECT, wouldn't e.g.
#define MAP_DIRECT      0x08
be possible (for parisc, and others 0x04).
And if MAP_TYPE needs to include this flag on parisc:
#define MAP_TYPE        (0x03 | 0x08)  /* Mask for type of mapping */

Helge

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
