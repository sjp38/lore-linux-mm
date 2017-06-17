Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 66DFF6B0374
	for <linux-mm@kvack.org>; Sat, 17 Jun 2017 12:25:27 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id f20so49184262otd.9
        for <linux-mm@kvack.org>; Sat, 17 Jun 2017 09:25:27 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t11si2209899otc.66.2017.06.17.09.25.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Jun 2017 09:25:26 -0700 (PDT)
Received: from mail-ua0-f180.google.com (mail-ua0-f180.google.com [209.85.217.180])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 02F6A23964
	for <linux-mm@kvack.org>; Sat, 17 Jun 2017 16:25:24 +0000 (UTC)
Received: by mail-ua0-f180.google.com with SMTP id j53so26329653uaa.2
        for <linux-mm@kvack.org>; Sat, 17 Jun 2017 09:25:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <149766213493.22552.4057048843646200083.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <149766212410.22552.15957843500156182524.stgit@dwillia2-desk3.amr.corp.intel.com>
 <149766213493.22552.4057048843646200083.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Sat, 17 Jun 2017 09:25:03 -0700
Message-ID: <CALCETrU1Hg=q4cdQDex--3nVBfwRC1o=9pC6Ss77Z8Lxg7ZJLg@mail.gmail.com>
Subject: Re: [RFC PATCH 2/2] mm, fs: daxfile, an interface for
 byte-addressable updates to pmem
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux API <linux-api@vger.kernel.org>, Dave Chinner <david@fromorbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

On Fri, Jun 16, 2017 at 6:15 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> To date, the full promise of byte-addressable access to persistent
> memory has only been half realized via the filesystem-dax interface. The
> current filesystem-dax mechanism allows an application to consume (read)
> data from persistent storage at byte-size granularity, bypassing the
> full page reads required by traditional storage devices.
>
> Now, for writes, applications still need to contend with
> page-granularity dirtying and flushing semantics as well as filesystem
> coordination for metadata updates after any mmap write. The current
> situation precludes use cases that leverage byte-granularity / in-place
> updates to persistent media.
>
> To get around this limitation there are some specialized applications
> that are using the device-dax interface to bypass the overhead and
> data-safety problems of the current filesystem-dax mmap-write path.
> QEMU-KVM is forced to use device-dax to safely pass through persistent
> memory to a guest [1]. Some specialized databases are using device-dax
> for byte-granularity writes. Outside of those cases, device-dax is
> difficult for general purpose persistent memory applications to consume.
> There is demand for access to pmem without needing to contend with
> special device configuration and other device-dax limitations.
>
> The 'daxfile' interface satisfies this demand and realizes one of Dave
> Chinner's ideas for allowing pmem applications to safely bypass
> fsync/msync requirements. The idea is to make the file immutable with
> respect to the offset-to-block mappings for every extent in the file
> [2]. It turns out that filesystems already need to make this guarantee
> today. This property is needed for files marked as swap files.
>
> The new daxctl() syscall manages setting a file into 'static-dax' mode
> whereby it arranges for the file to be treated as a swapfile as far as
> the filesystem is concerned, but not registered with the core-mm as
> swapfile space. A file in this mode is then safe to be mapped and
> written without the requirement to fsync/msync the writes.  The cpu
> cache management for flushing data to persistence can be handled
> completely in userspace.

Can you remind those of us who haven't played with DAX in a while what
the problem is with mmapping a DAX file without this patchset?  If
there's some bookkkeeping needed to make sure that the filesystem will
invalidate all the mappings if it decides to move the file, maybe that
should be the default rather than needing a new syscall.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
