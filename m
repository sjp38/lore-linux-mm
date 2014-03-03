Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f181.google.com (mail-ve0-f181.google.com [209.85.128.181])
	by kanga.kvack.org (Postfix) with ESMTP id A59746B0039
	for <linux-mm@kvack.org>; Mon,  3 Mar 2014 18:29:01 -0500 (EST)
Received: by mail-ve0-f181.google.com with SMTP id oy12so2310398veb.40
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 15:29:01 -0800 (PST)
Received: from mail-ve0-x22d.google.com (mail-ve0-x22d.google.com [2607:f8b0:400c:c01::22d])
        by mx.google.com with ESMTPS id i3si5250851vcp.52.2014.03.03.15.29.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 03 Mar 2014 15:29:01 -0800 (PST)
Received: by mail-ve0-f173.google.com with SMTP id oy12so2310205veb.18
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 15:29:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140303143834.90ebe8ec5c6a369e54a599ec@linux-foundation.org>
References: <1393625931-2858-1-git-send-email-quning@google.com>
	<CACQD4-5U3P+QiuNKzt5+VdDDi0ocphR+Jh81eHqG6_+KeaHyRw@mail.gmail.com>
	<20140228174150.8ff4edca.akpm@linux-foundation.org>
	<CACQD4-7UUDMeXdR-NaAAXvk-NRYqW7mHJkjDUM=JRvL54b_Xsg@mail.gmail.com>
	<CACQD4-5SmUf+krLbef9Yg9HhJ-ipT2QKKq-NW=2C6G=XwXcMcQ@mail.gmail.com>
	<20140303143834.90ebe8ec5c6a369e54a599ec@linux-foundation.org>
Date: Mon, 3 Mar 2014 15:29:00 -0800
Message-ID: <CA+55aFzvCF-tWg7qx2_Om+Y64uJy6ujEyWgcq87UkzSkfbVGqw@mail.gmail.com>
Subject: Re: [PATCH 0/1] mm, shmem: map few pages around fault address if they
 are in page cache
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ning Qu <quning@gmail.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Mar 3, 2014 at 2:38 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
>
> When the file is uncached, results are peculiar:
>
> 0.00user 2.84system 0:50.90elapsed 5%CPU (0avgtext+0avgdata 4198096maxresident)k
> 0inputs+0outputs (1major+49666minor)pagefaults 0swaps
>
> That's approximately 3x more minor faults.

This is not peculiar.

When the file is uncached, some pages will obviously be under IO due
to readahead etc. And the fault-around code very much on purpose will
*not* try to wait for those pages, so any busy pages will just simply
not be faulted-around.

So you should still have fewer minor faults than faulting on *every*
page (ie the non-fault-around case), but I would very much expect that
fault-around will not see the full "one sixteenth" reduction in minor
faults.

And the order of IO will not matter, since the read-ahead is
asynchronous wrt the page-faults.

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
