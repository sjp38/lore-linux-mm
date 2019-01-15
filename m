Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 34D458E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 16:39:20 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id k69so1983821ywa.12
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 13:39:20 -0800 (PST)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id z6si2907590ybk.249.2019.01.15.13.39.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 13:39:19 -0800 (PST)
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
References: <a79b259b-3982-b271-025a-0656f70506f4@nvidia.com>
 <20190111165141.GB3190@redhat.com>
 <1b37061c-5598-1b02-2983-80003f1c71f2@nvidia.com>
 <20190112020228.GA5059@redhat.com>
 <294bdcfa-5bf9-9c09-9d43-875e8375e264@nvidia.com>
 <20190112024625.GB5059@redhat.com>
 <b6f4ed36-fc8d-1f9b-8c74-b12f61d496ae@nvidia.com>
 <20190114145447.GJ13316@quack2.suse.cz> <20190114172124.GA3702@redhat.com>
 <fdece7f8-7e4f-f679-821f-1d05ed748c15@nvidia.com>
 <20190115083412.GD29524@quack2.suse.cz>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <9be3c203-6e44-6b9d-2331-afbcc269d0ff@nvidia.com>
Date: Tue, 15 Jan 2019 13:39:17 -0800
MIME-Version: 1.0
In-Reply-To: <20190115083412.GD29524@quack2.suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Jerome Glisse <jglisse@redhat.com>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro,
 Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On 1/15/19 12:34 AM, Jan Kara wrote:
> On Mon 14-01-19 11:09:20, John Hubbard wrote:
>> On 1/14/19 9:21 AM, Jerome Glisse wrote:
>>>>
[...]
> 
>> For example, the following already survives a basic boot to graphics mode.
>> It requires a bunch of callsite conversions, and a page flag (neither of which
>> is shown here), and may also have "a few" gross conceptual errors, but take a 
>> peek:
> 
> Thanks for writing this down! Some comments inline.
> 

I appreciate your taking a look at this, Jan. I'm still pretty new to gup.c, 
so it's really good to get an early review.


>> +/*
>> + * Manages the PG_gup_pinned flag.
>> + *
>> + * Note that page->_mapcount counting part of managing that flag, because the
>> + * _mapcount is used to determine if PG_gup_pinned can be cleared, in
>> + * page_mkclean().
>> + */
>> +static void track_gup_page(struct page *page)
>> +{
>> +	page = compound_head(page);
>> +
>> +	lock_page(page);
>> +
>> +	wait_on_page_writeback(page);
> 
> ^^ I'd use wait_for_stable_page() here. That is the standard waiting
> mechanism to use before you allow page modification.

OK, will do. In fact, I initially wanted to use wait_for_stable_page(), but 
hesitated when I saw that it won't necessarily do wait_on_page_writeback(), 
and I then I also remembered Dave Chinner recently mentioned that the policy
decision needed some thought in the future (maybe something about block 
device vs. filesystem policy):

void wait_for_stable_page(struct page *page)
{
	if (bdi_cap_stable_pages_required(inode_to_bdi(page->mapping->host)))
		wait_on_page_writeback(page);
}

...but like you say, it's the standard way that fs does this, so we should
just use it.

> 
>> +
>> +	atomic_inc(&page->_mapcount);
>> +	SetPageGupPinned(page);
>> +
>> +	unlock_page(page);
>> +}
>> +
>> +/*
>> + * A variant of track_gup_page() that returns -EBUSY, instead of waiting.
>> + */
>> +static int track_gup_page_atomic(struct page *page)
>> +{
>> +	page = compound_head(page);
>> +
>> +	if (PageWriteback(page) || !trylock_page(page))
>> +		return -EBUSY;
>> +
>> +	if (PageWriteback(page)) {
>> +		unlock_page(page);
>> +		return -EBUSY;
>> +	}
> 
> Here you'd need some helper that would return whether
> wait_for_stable_page() is going to wait. Like would_wait_for_stable_page()
> but maybe you can come up with a better name.

Yes, in order to wait_for_stable_page(), that seems necessary, I agree.


thanks,
-- 
John Hubbard
NVIDIA
