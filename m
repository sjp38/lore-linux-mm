Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 561336B0005
	for <linux-mm@kvack.org>; Thu, 31 May 2018 17:49:52 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id b192-v6so12667965oii.12
        for <linux-mm@kvack.org>; Thu, 31 May 2018 14:49:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s133-v6sor17180438oif.251.2018.05.31.14.49.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 May 2018 14:49:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180531100849.xkwe5xsjpkw6nev7@quack2.suse.cz>
References: <152699997165.24093.12194490924829406111.stgit@dwillia2-desk3.amr.corp.intel.com>
 <152699999778.24093.18007971664703285330.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180523084030.dvv4jbvsnzrsaz6q@quack2.suse.cz> <CAPcyv4gUM7Br3XONOVkNCg-mvR5U8QLq+OOc54cLpP61LXhJXA@mail.gmail.com>
 <20180530081356.mohu6fx22fzd7fxb@quack2.suse.cz> <CAPcyv4iPa_n7c6iLRtNyE4GdXcn7JcF=Z1bUDmNrjrKvnLic2A@mail.gmail.com>
 <20180531100849.xkwe5xsjpkw6nev7@quack2.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 31 May 2018 14:49:49 -0700
Message-ID: <CAPcyv4j6zjvzxKb3JUHU+iSrPXybj-uRNFAWXoc46dkMgjyN6g@mail.gmail.com>
Subject: Re: [PATCH 05/11] filesystem-dax: set page->index
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, Christoph Hellwig <hch@lst.de>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "Luck, Tony" <tony.luck@intel.com>, linux-xfs <linux-xfs@vger.kernel.org>, "Darrick J. Wong" <darrick.wong@oracle.com>

On Thu, May 31, 2018 at 3:08 AM, Jan Kara <jack@suse.cz> wrote:
[..]
>> >> As far as I can see reflink+dax would require teaching kernel code
>> >> paths that ->mapping may not be a singular relationship. Something
>> >> along the line's of what Jerome was presenting at LSF to create a
>> >> special value to indicate, "call back into the filesystem (or the page
>> >> owner)" to perform this operation.
>> >>
>> >> In the meantime the kernel crashes when userspace accesses poisoned
>> >> pmem via DAX. I assume that reworking rmap for the dax+reflink case
>> >> should not block dax poison handling? Yell if you disagree.
>> >
>> > The thing is, up until get_user_pages() vs truncate series ("fs, dax: use
>> > page->mapping to warn if truncate collides with a busy page" in
>> > particular), DAX was perfectly fine with reflinks since we never needed
>> > page->mapping.
>>
>> Sure, but if this rmap series had come first I still would have needed
>> to implement ->mapping. So unless we invent a general ->mapping
>> replacement and switch all mapping users, it was always going to
>> collide with DAX eventually.
>
> Yes, my comment was more in direction that life would be easier if we could
> keep DAX without rmap support but I guess that's just too cumbersome.

I'm open to deeper reworks later. As it stands currently just calling
madvise(..., MADV_HWPOISON) on a DAX mapping causes a page reference
to be leaked because the madvise code has no clue about proper
handling of DAX pages, and consuming real poison leads to a fatal
condition / reset.

I think fixing those bugs with the current rmap dependencies on
->mapping and ->index is step1 and step2 is a longer term solution for
dax rmap that does also allow reflink. I.e. it's an rmap > reflink
argument for now.

>
>> > Now this series adds even page->index dependency which makes
>> > life for rmap with reflinks even harder. So if nothing else we should at
>> > least make sure reflinked filesystems cannot be mounted with dax mount
>> > option for now and seriously start looking into how to implement rmap with
>> > reflinked files for DAX because this noticeably reduces its usefulness.
>>
>> This restriction is already in place. In xfs_reflink_remap_range() we have:
>>
>>         /* Don't share DAX file data for now. */
>>         if (IS_DAX(inode_in) || IS_DAX(inode_out))
>>                 goto out_unlock;
>
> OK, good.
>
>> All this said, perhaps we don't need to set ->link, it would just mean
>> a wider search through the rmap tree to find if the given page is
>> mapped. So, I think I can forgo setting ->link if I teach the rmap
>> code to search the entire ->mapping.
>
> I guess you mean ->index in the above. And now when thinking about it I don't
> think it is worth the complications to avoid using ->index.

Ok, and yes I meant ->index... sorry, too much struct page on the
brain presently.
