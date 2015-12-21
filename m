Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id 65F086B0006
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 12:49:02 -0500 (EST)
Received: by mail-ob0-f171.google.com with SMTP id 18so127879443obc.2
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 09:49:02 -0800 (PST)
Received: from mail-oi0-x22d.google.com (mail-oi0-x22d.google.com. [2607:f8b0:4003:c06::22d])
        by mx.google.com with ESMTPS id p1si7543141oeq.53.2015.12.21.09.49.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Dec 2015 09:49:01 -0800 (PST)
Received: by mail-oi0-x22d.google.com with SMTP id l9so66975998oia.2
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 09:49:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151221170545.GA13494@linux.intel.com>
References: <1450502540-8744-1-git-send-email-ross.zwisler@linux.intel.com>
	<1450502540-8744-5-git-send-email-ross.zwisler@linux.intel.com>
	<CAPcyv4irspQEPVdYfLK+QfW4t-1_y1gFFVuBm00=i03PFQwEYw@mail.gmail.com>
	<20151221170545.GA13494@linux.intel.com>
Date: Mon, 21 Dec 2015 09:49:01 -0800
Message-ID: <CAPcyv4g-ibFU02chKZchkbZtZHPE=r_DKkfwHAY3pkCFTon2SQ@mail.gmail.com>
Subject: Re: [PATCH v5 4/7] dax: add support for fsync/sync
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, X86 ML <x86@kernel.org>, XFS Developers <xfs@oss.sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Mon, Dec 21, 2015 at 9:05 AM, Ross Zwisler
<ross.zwisler@linux.intel.com> wrote:
> On Sat, Dec 19, 2015 at 10:37:46AM -0800, Dan Williams wrote:
>> On Fri, Dec 18, 2015 at 9:22 PM, Ross Zwisler
>> <ross.zwisler@linux.intel.com> wrote:
[..]
>> Hi Ross, I should have realized this sooner, but what guarantees that
>> the address returned by RADIX_DAX_ADDR(entry) is still valid at this
>> point?  I think we need to store the sector in the radix tree and then
>> perform a new dax_map_atomic() operation to either lookup a valid
>> address or fail the sync request.  Otherwise, if the device is gone
>> we'll crash, or write into some other random vmalloc address space.
>
> Ah, good point, thank you.  v4 of this series is based on a version of
> DAX where we aren't properly dealing with PMEM device removal.  I've got an
> updated version that merges with your dax_map_atomic() changes, and I'll add
> this change into v5 which I will send out today.  Thank you for the
> suggestion.
>
> One clarification, with the code as it is in v4 we are only doing
> clflush/clflushopt/clwb instructions on the kaddr we've stored in the radix
> tree, so I don't think that there is actually a risk of us doing a "write into
> some other random vmalloc address space"?  I think at worse we will end up
> clflushing an address that either isn't mapped or has been remapped by someone
> else.  Or are you worried that the clflush would trigger a cache writeback to
> a memory address where writes have side effects, thus triggering the side
> effect?
>
> I definitely think it needs to be fixed, I'm just trying to make sure I
> understood your comment.

True, this would be flushing an address that was dirtied while valid.
Should be ok in practice for now since dax is effectively limited to
x86, but we should not be leaning on x86 details in an architecture
generic implementation like this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
