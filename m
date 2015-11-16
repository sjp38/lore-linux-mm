Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1C15F6B0255
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 11:58:13 -0500 (EST)
Received: by wmww144 with SMTP id w144so128172758wmw.0
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 08:58:12 -0800 (PST)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id b186si26802528wmd.88.2015.11.16.08.58.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Nov 2015 08:58:11 -0800 (PST)
Received: by wmec201 with SMTP id c201so129389993wme.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 08:58:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151116144130.GD3443@quack.suse.cz>
References: <1447459610-14259-1-git-send-email-ross.zwisler@linux.intel.com>
	<20151116144130.GD3443@quack.suse.cz>
Date: Mon, 16 Nov 2015 08:58:11 -0800
Message-ID: <CAPcyv4gb8rh4Xkn-yzjbazftnXp8f6hr21LR5ZZehQBNLeNkZA@mail.gmail.com>
Subject: Re: [PATCH v2 00/11] DAX fsynx/msync support
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, X86 ML <x86@kernel.org>, XFS Developers <xfs@oss.sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Mon, Nov 16, 2015 at 6:41 AM, Jan Kara <jack@suse.cz> wrote:
> On Fri 13-11-15 17:06:39, Ross Zwisler wrote:
>> This patch series adds support for fsync/msync to DAX.
>>
>> Patches 1 through 7 add various utilities that the DAX code will eventually
>> need, and the DAX code itself is added by patch 8.  Patches 9-11 update the
>> three filesystems that currently support DAX, ext2, ext4 and XFS, to use
>> the new DAX fsync/msync code.
>>
>> These patches build on the recent DAX locking changes from Dave Chinner,
>> Jan Kara and myself.  Dave's changes for XFS and my changes for ext2 have
>> been merged in the v4.4 window, but Jan's are still unmerged.  You can grab
>> them here:
>>
>> http://www.spinics.net/lists/linux-ext4/msg49951.html
>
> I had a quick look and the patches look sane to me. I'll try to give them
> more detailed look later this week. When thinking about the general design
> I was wondering: When we have this infrastructure to track data potentially
> lingering in CPU caches, would not it be a performance win to use standard
> cached stores in dax_io() and mark corresponding pages as dirty in page
> cache the same way as this patch set does it for mmaped writes? I have no
> idea how costly are non-temporal stores compared to cached ones and how
> would this compare to the cost of dirty tracking so this may be just
> completely bogus...

Keep in mind that this approach will flush every virtual address that
may be dirty.  For example, if you touch 1byte in a 2MB page we'll end
up looping through the entire 2MB range.  At some point the dirty size
becomes large enough that is cheaper to flush the entire cache, we
have not measured where that crossover point is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
