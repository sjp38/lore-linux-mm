Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 592C76B0006
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 19:23:39 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id g194-v6so3442746ybf.5
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 16:23:39 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id r5-v6si6400833ywg.345.2018.10.10.16.23.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 16:23:38 -0700 (PDT)
Subject: Re: [PATCH v4 2/3] mm: introduce put_user_page*(), placeholder
 versions
References: <20181008211623.30796-1-jhubbard@nvidia.com>
 <20181008211623.30796-3-jhubbard@nvidia.com>
 <20181008171442.d3b3a1ea07d56c26d813a11e@linux-foundation.org>
 <5198a797-fa34-c859-ff9d-568834a85a83@nvidia.com>
 <20181010085936.GC11507@quack2.suse.cz>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <f5fb98a8-a1dc-6f1d-bc9e-210be14e91b4@nvidia.com>
Date: Wed, 10 Oct 2018 16:23:35 -0700
MIME-Version: 1.0
In-Reply-To: <20181010085936.GC11507@quack2.suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, john.hubbard@gmail.com, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Jerome Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@infradead.org>, Ralph Campbell <rcampbell@nvidia.com>

On 10/10/18 1:59 AM, Jan Kara wrote:
> On Tue 09-10-18 17:42:09, John Hubbard wrote:
>> On 10/8/18 5:14 PM, Andrew Morton wrote:
>>> Also, maintainability.  What happens if someone now uses put_page() by
>>> mistake?  Kernel fails in some mysterious fashion?  How can we prevent
>>> this from occurring as code evolves?  Is there a cheap way of detecting
>>> this bug at runtime?
>>>
>>
>> It might be possible to do a few run-time checks, such as "does page that came 
>> back to put_user_page() have the correct flags?", but it's harder (without 
>> having a dedicated page flag) to detect the other direction: "did someone page 
>> in a get_user_pages page, to put_page?"
>>
>> As Jan said in his reply, converting get_user_pages (and put_user_page) to 
>> work with a new data type that wraps struct pages, would solve it, but that's
>> an awfully large change. Still...given how much of a mess this can turn into 
>> if it's wrong, I wonder if it's worth it--maybe? 
> 
> I'm certainly not opposed to looking into it. But after looking into this
> for a while it is not clear to me how to convert e.g. fs/direct-io.c or
> fs/iomap.c. They pass the reference from gup() via
> bio->bi_io_vec[]->bv_page and then release it after IO completion.
> Propagating the new type to ->bv_page is not good as lower layer do not
> really care how the page is pinned in memory. But we do need to somehow
> pass the information to the IO completion functions in a robust manner.
> 

You know, that problem has to be solved in either case: even if we do not
use a new data type for get_user_pages, we still need to clearly, accurately
match up the get/put pairs. And for the complicated systems (block IO, and
GPU DRM layer, especially) one of the things that has caused me concern is 
the way the pages all end up in a large, complicated pool, and put_page is
used to free all of them, indiscriminately.

So I'm glad you're looking at ways to disambiguate this for the bio system.

> Hmm, what about the following:
> 
> 1) Make gup() return new type - struct user_page *? In practice that would
> be just a struct page pointer with 0 bit set so that people are forced to
> use proper helpers and not just force types (and the setting of bit 0 and
> masking back would be hidden behind CONFIG_DEBUG_USER_PAGE_REFERENCES for
> performance reasons). Also the transition would have to be gradual so we'd
> have to name the function differently and use it from converted code.

Yes. That seems perfect: it just fades away if you're not debugging, but we
can catch lots of problems when CONFIG_DEBUG_USER_PAGE_REFERENCES is set. 

> 
> 2) Provide helper bio_add_user_page() that will take user_page, convert it
> to struct page, add it to the bio, and flag the bio as having pages with
> user references. That code would also make sure the bio is consistent in
> having only user-referenced pages in that case. IO completion (like
> bio_check_pages_dirty(), bio_release_pages() etc.) will check the flag and
> use approprite release function.

I'm very new to bio, so I have to ask: can we be sure that the same types of 
pages are always used, within each bio? Because otherwise, we'll have to plumb 
it all the way down to bio_vec's--or so it appears, based on my reading of 
bio_release_pages() and surrounding code.

> 
> 3) I have noticed fs/direct-io.c may submit zero page for IO when it needs
> to clear stuff so we'll probably need a helper function to acquire 'user pin'
> reference given a page pointer so that that code can be kept reasonably
> simple and pass user_page references all around.
>

This only works if we don't set page flags, because if we do set page flags 
on the single, global zero page, that will break the world. So I'm not sure
that the zero page usage in fs/directio.c is going to survive the conversion
to this new approach. :)
 
> So this way we could maintain reasonable confidence that refcounts didn't
> get mixed up. Thoughts?
> 

After thinking some more about the complicated situations in bio and DRM,
and looking into the future (bug reports...), I am leaning toward your 
struct user_page approach. 

I'm looking forward to hearing other opinions on whether it's worth it to go
and do this fairly intrusive change, in return for, probably, fewer bugs along
the way.


thanks,
-- 
John Hubbard
NVIDIA
