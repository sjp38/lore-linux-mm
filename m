Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f177.google.com (mail-yk0-f177.google.com [209.85.160.177])
	by kanga.kvack.org (Postfix) with ESMTP id 26AFF828E4
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 14:23:58 -0500 (EST)
Received: by mail-yk0-f177.google.com with SMTP id z13so91200662ykd.0
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 11:23:58 -0800 (PST)
Received: from mail-yw0-x22a.google.com (mail-yw0-x22a.google.com. [2607:f8b0:4002:c05::22a])
        by mx.google.com with ESMTPS id n206si14032559yba.54.2016.02.08.11.23.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Feb 2016 11:23:57 -0800 (PST)
Received: by mail-yw0-x22a.google.com with SMTP id u200so31310146ywf.0
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 11:23:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160208183112.GF2343@linux.intel.com>
References: <1454829553-29499-1-git-send-email-ross.zwisler@linux.intel.com>
	<1454829553-29499-3-git-send-email-ross.zwisler@linux.intel.com>
	<CAPcyv4jT=yAb2_yLfMGqV1SdbQwoWQj7joroeJGAJAcjsMY_oQ@mail.gmail.com>
	<20160208183112.GF2343@linux.intel.com>
Date: Mon, 8 Feb 2016 11:23:56 -0800
Message-ID: <CAPcyv4gdej=BfP-MDWbgTy7JTciiU_6F3zaAyzUJ2Ofgh0gapg@mail.gmail.com>
Subject: Re: [PATCH 2/2] dax: move writeback calls into the filesystems
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <willy@linux.intel.com>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, XFS Developers <xfs@oss.sgi.com>, jmoyer <jmoyer@redhat.com>

On Mon, Feb 8, 2016 at 10:31 AM, Ross Zwisler
<ross.zwisler@linux.intel.com> wrote:
> On Sun, Feb 07, 2016 at 11:13:51AM -0800, Dan Williams wrote:
>> The proposal: make applications explicitly request DAX semantics with
>> a new MAP_DAX flag and fail if DAX is unavailable.  Document that a
>> successful MAP_DAX request mandates that the application assumes
>> responsibility for cpu cache management.
>
>> Require that all applications that mmap the file agree on MAP_DAX.
>
> I think this proposal could run into issues with aliasing.  For example, say
> you have two threads accessing the same region, and one wants to use DAX and
> the other wants to use the page cache.  What happens?
>
> If we satisfy both requests, we end up with one user reading and writing to
> the page cache, while the other is reading and writing directly to the media.
> They can't see each other's changes, and you get data corruption.
>
> If we satisfy the request of whoever asked first, sort of lock the inode into
> that mode, and then return an error to the second thread because they are
> asking for the other mode, we have now introduced a new weird failure case
> where mmaps can randomly fail based on the behavior of other applications.
> I think this is where you were going with the last line quoted above, but I
> don't understand how it would work in an acceptable way.
>
> It seems like we have to have the decision about whether or not to use DAX
> made in the same way for all users of the inode so that we don't run into
> these types of conflicts.

We haven't solved the conflict problem by pushing it out to the inode,
see the recent revert of blkdev_daxset().  We're heading in a
direction where an application can't develop it's own policies about
DAX usage, it's always an administrative decision.  However, maybe
that is ok.  Dave is right that if an application is using an existing
filesystem it should get all the existing semantics.

If the existing semantics (or overhead of maintaining the existing
semantics) turn out not to fit a given pmem-aware application then we
may just need new interfaces (separate from fs/dax.c) to persistent
memory.  I admit we're a ways off from knowing if that is needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
