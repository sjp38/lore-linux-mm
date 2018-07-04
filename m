Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 53F426B027F
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 11:20:17 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id h21-v6so3851850otl.10
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 08:20:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l186-v6sor2319717oif.94.2018.07.04.08.20.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Jul 2018 08:20:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180612180747.GA28436@linux.intel.com>
References: <152850182079.38390.8280340535691965744.stgit@dwillia2-desk3.amr.corp.intel.com>
 <152850187437.38390.2257981090761438811.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180611154146.jc5xt4gyaihq64lm@quack2.suse.cz> <20180612180747.GA28436@linux.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 4 Jul 2018 08:20:15 -0700
Message-ID: <CAPcyv4ijwH30mO04eVOHa29HUc++wejuM9NDvRLFJtdcF3tt4g@mail.gmail.com>
Subject: Re: [PATCH v4 10/12] filesystem-dax: Introduce dax_lock_page()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Christoph Hellwig <hch@lst.de>, linux-nvdimm <linux-nvdimm@lists.01.org>

On Tue, Jun 12, 2018 at 11:07 AM, Ross Zwisler
<ross.zwisler@linux.intel.com> wrote:
> On Mon, Jun 11, 2018 at 05:41:46PM +0200, Jan Kara wrote:
>> On Fri 08-06-18 16:51:14, Dan Williams wrote:
>> > In preparation for implementing support for memory poison (media error)
>> > handling via dax mappings, implement a lock_page() equivalent. Poison
>> > error handling requires rmap and needs guarantees that the page->mapping
>> > association is maintained / valid (inode not freed) for the duration of
>> > the lookup.
>> >
>> > In the device-dax case it is sufficient to simply hold a dev_pagemap
>> > reference. In the filesystem-dax case we need to use the entry lock.
>> >
>> > Export the entry lock via dax_lock_page() that uses rcu_read_lock() to
>> > protect against the inode being freed, and revalidates the page->mapping
>> > association under xa_lock().
>> >
>> > Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>>
>> Some comments below...
>>
>> > diff --git a/fs/dax.c b/fs/dax.c
>> > index cccf6cad1a7a..b7e71b108fcf 100644
>> > --- a/fs/dax.c
>> > +++ b/fs/dax.c
>> > @@ -361,6 +361,82 @@ static void dax_disassociate_entry(void *entry, struct address_space *mapping,
>> >     }
>> >  }
>> >
>> > +struct page *dax_lock_page(unsigned long pfn)
>> > +{
>>
>> Why do you return struct page here? Any reason behind that? Because struct
>> page exists and can be accessed through pfn_to_page() regardless of result
>> of this function so it looks a bit confusing. Also dax_lock_page() name
>> seems a bit confusing. Maybe dax_lock_pfn_mapping_entry()?
>
> It's also a bit awkward that the functions are asymmetric in their arguments:
> dax_lock_page(pfn) vs dax_unlock_page(struct page)
>
> Looking at dax_lock_page(), we only use 'pfn' to get 'page', so maybe it would
> be cleaner to just always deal with struct page, i.e.:
>
> void dax_lock_page(struct page *page);
> void dax_unlock_page(struct page *page);

No, intent was to have the locking routine return the object that it
validated and then deal with that same object at unlock.
dax_lock_page() can fail to acquire a lock.
