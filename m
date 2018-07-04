Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 30B3E6B027D
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 11:17:40 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id e21-v6so3600557oti.22
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 08:17:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d6-v6sor2594669oig.67.2018.07.04.08.17.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Jul 2018 08:17:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180611154146.jc5xt4gyaihq64lm@quack2.suse.cz>
References: <152850182079.38390.8280340535691965744.stgit@dwillia2-desk3.amr.corp.intel.com>
 <152850187437.38390.2257981090761438811.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180611154146.jc5xt4gyaihq64lm@quack2.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 4 Jul 2018 08:17:38 -0700
Message-ID: <CAPcyv4jRTHNyxfs=8GkjpBp8wxh2jjDoNGipnZ-dswr8nuXh5w@mail.gmail.com>
Subject: Re: [PATCH v4 10/12] filesystem-dax: Introduce dax_lock_page()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, Christoph Hellwig <hch@lst.de>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Mon, Jun 11, 2018 at 8:41 AM, Jan Kara <jack@suse.cz> wrote:
> On Fri 08-06-18 16:51:14, Dan Williams wrote:
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
>
> Some comments below...
>
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
>
> Why do you return struct page here? Any reason behind that?

Unlike lock_page() there is no guarantee that we can lock a mapping
entry given a pfn. There is a chance that we lose a race and can't
validate the pfn to take the lock. So returning 'struct page *' was
there to indicate that we successfully validated the pfn and were able
to take the lock. I'll rework it to just return bool.

> Because struct
> page exists and can be accessed through pfn_to_page() regardless of result
> of this function so it looks a bit confusing. Also dax_lock_page() name
> seems a bit confusing. Maybe dax_lock_pfn_mapping_entry()?

Ok.
