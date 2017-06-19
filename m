Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 446096B0365
	for <linux-mm@kvack.org>; Sun, 18 Jun 2017 21:51:52 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id 37so50732264otu.13
        for <linux-mm@kvack.org>; Sun, 18 Jun 2017 18:51:52 -0700 (PDT)
Received: from mail-ot0-x22d.google.com (mail-ot0-x22d.google.com. [2607:f8b0:4003:c0f::22d])
        by mx.google.com with ESMTPS id g27si3321757otf.347.2017.06.18.18.51.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Jun 2017 18:51:51 -0700 (PDT)
Received: by mail-ot0-x22d.google.com with SMTP id s7so58951071otb.3
        for <linux-mm@kvack.org>; Sun, 18 Jun 2017 18:51:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170618081850.GA26332@lst.de>
References: <149766212410.22552.15957843500156182524.stgit@dwillia2-desk3.amr.corp.intel.com>
 <149766213493.22552.4057048843646200083.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CALCETrU1Hg=q4cdQDex--3nVBfwRC1o=9pC6Ss77Z8Lxg7ZJLg@mail.gmail.com>
 <CAPcyv4j4UEegViDJcLZjVv5AFGC18-DcvHFnhZatB0hH3BY85g@mail.gmail.com>
 <CALCETrUfv26pvmyQ1gOkKbzfSXK2DnmeBG6VmSWjFy1WBhknTw@mail.gmail.com>
 <CAPcyv4iPb69e+rE3fJUzm9U_P_dLfhantU9mvYmV-R0oQee4rA@mail.gmail.com> <20170618081850.GA26332@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sun, 18 Jun 2017 18:51:49 -0700
Message-ID: <CAPcyv4jt2EMfiVB-5uOdjKMuYfLrqUdK4vYkteqAqXkSRqTs5g@mail.gmail.com>
Subject: Re: [RFC PATCH 2/2] mm, fs: daxfile, an interface for
 byte-addressable updates to pmem
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux API <linux-api@vger.kernel.org>, Dave Chinner <david@fromorbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Sun, Jun 18, 2017 at 1:18 AM, Christoph Hellwig <hch@lst.de> wrote:
> On Sat, Jun 17, 2017 at 08:15:05PM -0700, Dan Williams wrote:
>> The hang up is that it requires per-fs enabling as it needs to be
>> careful to manage mmap_sem vs fs journal locks for example. I know the
>> in-development NOVA [1] filesystem is planning to support this out of
>> the gate. ext4 would be open to implementing it, but I think xfs is
>> cold on the idea. Christoph originally proposed it here [2], before
>> Dave went on to propose immutable semantics.
>>
>> [1]: https://github.com/NVSL/NOVA
>> [2]: https://lists.01.org/pipermail/linux-nvdimm/2016-February/004609.html
>
> And I stand to that statement.  Let's get DAX stable first, and
> properly cleaned up (e.g. follow on work with separating it entirely
> from the block device).  Then think hard about how most of the
> persistent memory technologies actually work, including the point that
> for a lot of workloads page cache will be required at least on the
> write side.   And then come up with actual real use cases and we can
> look into it.

I see it differently. We're already at a good point in time to start
iterating on a fix for this issue. Ross and Jan have done a lot of
good work on the dax stability front, and the block-device separation
of dax is well underway.

> And stop trying to shoe-horn crap like this in.

The kernel shoe-horning all pmem+filesystem-dax applications into
abiding page-cache semantics is a problem, and this RFC has already
helped move the needle on a couple fronts. 1/ Swapfiles are subtly
broken which is something worth fixing, and if it gets us a
synchronous-dax mode without major filesystem surgery then that's all
for the better. 2/ There's an appetite for just fixing this
incrementally in each filesystem's fault handler, so if ext4 was able
to prove out an interface / implementation for synchronous faults we
could go with that instead of a pre-allocated + immutable interface
and let other filesystems set their own timelines.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
