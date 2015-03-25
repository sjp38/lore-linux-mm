Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 26EC56B0038
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 04:10:36 -0400 (EDT)
Received: by wgbcc7 with SMTP id cc7so17964368wgb.0
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 01:10:35 -0700 (PDT)
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com. [209.85.212.182])
        by mx.google.com with ESMTPS id it3si3716015wid.46.2015.03.25.01.10.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 01:10:34 -0700 (PDT)
Received: by wibg7 with SMTP id g7so99602001wib.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 01:10:33 -0700 (PDT)
Message-ID: <55126D77.7040105@plexistor.com>
Date: Wed, 25 Mar 2015 10:10:31 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] RFC: dax: dax_prepare_freeze
References: <55100B78.501@plexistor.com> <55100D10.6090902@plexistor.com> <20150323224047.GQ28621@dastard> <551100E3.9010007@plexistor.com> <20150325022221.GA31342@dastard>
In-Reply-To: <20150325022221.GA31342@dastard>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eryu Guan <eguan@redhat.com>

On 03/25/2015 04:22 AM, Dave Chinner wrote:
> On Tue, Mar 24, 2015 at 08:14:59AM +0200, Boaz Harrosh wrote:
<>
> 
> Then we have wider problem with DAX, then: sync doesn't work
> properly. i.e. if we still has write mapped pages, then we haven't
> flushed dirty cache lines on write-mapped files to the persistent
> domain by the time sync completes.
> 
> So, this shouldn't be some special case that only the freeze code
> takes into account - we need to make sure that sync (and therefore
> freeze) flushes all dirty cache lines and marks all mappings
> clean....
> 

This is not how I understood it and how I read the code.

The sync does happen, .fsync of the FS is called on each
file just as if the user called it. If this is broken it just
needs to be fixed there at the .fsync vector. POSIX mandate
persistence at .fsync so at the vfs layer we rely on that.

So everything at this stage should be synced to real media.

What does not happen is writeback. since dax does not have
any writeback. And because of that nothing turned the
user mappings to read only. This is what I do here but
instead of write-protecting I just unmap because it is
easier for me to code it.

> Cheers,
> Dave.

Cheers
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
