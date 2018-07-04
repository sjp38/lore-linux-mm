Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 282B56B0279
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 11:11:18 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id 18-v6so3928464oix.4
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 08:11:18 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r84-v6sor2530181oig.185.2018.07.04.08.11.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Jul 2018 08:11:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180612181542.GB28436@linux.intel.com>
References: <152850182079.38390.8280340535691965744.stgit@dwillia2-desk3.amr.corp.intel.com>
 <152850187437.38390.2257981090761438811.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180612181542.GB28436@linux.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 4 Jul 2018 08:11:14 -0700
Message-ID: <CAPcyv4i9kK6e6aWVJWyhdW+WKGVuujmBZXyCQvQ7s-JpAdY_9Q@mail.gmail.com>
Subject: Re: [PATCH v4 10/12] filesystem-dax: Introduce dax_lock_page()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>

On Tue, Jun 12, 2018 at 11:15 AM, Ross Zwisler
<ross.zwisler@linux.intel.com> wrote:
> On Fri, Jun 08, 2018 at 04:51:14PM -0700, Dan Williams wrote:
>> In preparation for implementing support for memory poison (media error)
>> handling via dax mappings, implement a lock_page() equivalent. Poison
>> error handling requires rmap and needs guarantees that the page->mapping
>> association is maintained / valid (inode not freed) for the duration of
>> the lookup.
>>
>> In the device-dax case it is sufficient to simply hold a dev_pagemap
>> reference. In the filesystem-dax case we need to use the entry lock.
>>
>> Export the entry lock via dax_lock_page() that uses rcu_read_lock() to
>> protect against the inode being freed, and revalidates the page->mapping
>> association under xa_lock().
>>
>> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>> ---
>>  fs/dax.c            |   76 +++++++++++++++++++++++++++++++++++++++++++++++++++
>>  include/linux/dax.h |   15 ++++++++++
>>  2 files changed, 91 insertions(+)
>>
>> diff --git a/fs/dax.c b/fs/dax.c
>> index cccf6cad1a7a..b7e71b108fcf 100644
>> --- a/fs/dax.c
>> +++ b/fs/dax.c
>> @@ -361,6 +361,82 @@ static void dax_disassociate_entry(void *entry, struct address_space *mapping,
>>       }
>>  }
>>
>> +struct page *dax_lock_page(unsigned long pfn)
>> +{
>> +     pgoff_t index;
>> +     struct inode *inode;
>> +     wait_queue_head_t *wq;
>> +     void *entry = NULL, **slot;
>> +     struct address_space *mapping;
>> +     struct wait_exceptional_entry_queue ewait;
>> +     struct page *ret = NULL, *page = pfn_to_page(pfn);
>> +
>> +     rcu_read_lock();
>> +     for (;;) {
>> +             mapping = READ_ONCE(page->mapping);
>
> Why the READ_ONCE()?

We're potentially racing inode teardown, so the READ_ONCE() prevents
the compiler from trying to de-reference page->mapping twice and
getting inconsistent answers.

>
>> +
>> +             if (!mapping || !IS_DAX(mapping->host))
>
> Might read better using the dax_mapping() helper.

Sure.

>
> Also, forgive my ignorance, but this implies that dev dax has page->mapping
> set up and that that inode will have IS_DAX set, right?  This will let us get
> past this point for device DAX, and we'll bail out at the S_ISCHR() check?

Yes.

>
>> +                     break;
>> +
>> +             /*
>> +              * In the device-dax case there's no need to lock, a
>> +              * struct dev_pagemap pin is sufficient to keep the
>> +              * inode alive.
>> +              */
>> +             inode = mapping->host;
>> +             if (S_ISCHR(inode->i_mode)) {
>> +                     ret = page;
>
> 'ret' isn't actually used for anything in this function, we just
> unconditionally return 'page'.
>

Yes, bug.

>> +                     break;
>> +             }
>> +
>> +             xa_lock_irq(&mapping->i_pages);
>> +             if (mapping != page->mapping) {
>> +                     xa_unlock_irq(&mapping->i_pages);
>> +                     continue;
>> +             }
>> +             index = page->index;
>> +
>> +             init_wait(&ewait.wait);
>> +             ewait.wait.func = wake_exceptional_entry_func;
>> +
>> +             entry = __radix_tree_lookup(&mapping->i_pages, index, NULL,
>> +                             &slot);
>> +             if (!entry ||
>
> So if we do a lookup and there is no entry in the tree, we won't add an empty
> entry and lock it, we'll just return with no entry in the tree and nothing
> locked.
>
> Then, when we call dax_unlock_page(), we'll eventually hit a WARN_ON_ONCE() in
> dax_unlock_mapping_entry() when we see entry is 0.  And, in that gap we've got
> nothing locked so page faults could have happened, etc... (which would mean
> that instead of WARN_ON_ONCE() for an empty entry, we'd hit it instead for an
> unlocked entry).
>
> Is that okay?  Or do we need to insert a locked empty entry here?

No, the intent was to return NULL and fail the lock, but I messed up
and unconditionally returned the page.
