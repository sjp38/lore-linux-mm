Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0C0966B02DA
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 04:19:58 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id o7K8JtVl010471
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 01:19:55 -0700
Received: from ywh2 (ywh2.prod.google.com [10.192.8.2])
	by wpaz29.hot.corp.google.com with ESMTP id o7K8Jsqv018990
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 01:19:54 -0700
Received: by ywh2 with SMTP id 2so1536530ywh.37
        for <linux-mm@kvack.org>; Fri, 20 Aug 2010 01:19:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100820023419.GA5502@localhost>
References: <1282251447-16937-1-git-send-email-mrubin@google.com>
 <1282251447-16937-2-git-send-email-mrubin@google.com> <20100820023419.GA5502@localhost>
From: Michael Rubin <mrubin@google.com>
Date: Fri, 20 Aug 2010 01:19:33 -0700
Message-ID: <AANLkTinzS5J2PsG4Ftmbjvpi=beyD54A=ZrRw3_DA8jv@mail.gmail.com>
Subject: Re: [PATCH 1/3] mm: helper functions for dirty and writeback accounting
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, jack@suse.cz, riel@redhat.com, akpm@linux-foundation.org, david@fromorbit.com, hch@lst.de, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

On Thu, Aug 19, 2010 at 7:34 PM, Wu Fengguang <fengguang.wu@intel.com> wrot=
e:
> On Thu, Aug 19, 2010 at 01:57:25PM -0700, Michael Rubin wrote:
>> Exporting account_pages_dirty and adding a symmetric routine
>> account_pages_writeback.
>
> s/account_pages_writeback/account_page_writeback/

Got it. thanks.

> I'd recommend to separate the changes into two patches.
> It's actually a bug fix to export account_pages_dirty() for ceph,
> which should be a good candidate for 2.6.36.

Good idea.

>> This allows code outside of the mm core to safely manipulate page state
>> and not worry about the other accounting. Not using these routines means
>> that some code will lose track of the accounting and we get bugs. This
>> has happened once already.
>>
>> Signed-off-by: Michael Rubin <mrubin@google.com>
>> ---
>> =A0fs/ceph/addr.c =A0 =A0 =A0| =A0 =A08 ++------
>> =A0fs/nilfs2/segment.c | =A0 =A02 +-
>> =A0include/linux/mm.h =A0| =A0 =A01 +
>> =A0mm/page-writeback.c | =A0 15 +++++++++++++++
>> =A04 files changed, 19 insertions(+), 7 deletions(-)
>>
>> diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
>> index d9c60b8..359aa3a 100644
>> --- a/fs/ceph/addr.c
>> +++ b/fs/ceph/addr.c
>> @@ -106,12 +106,8 @@ static int ceph_set_page_dirty(struct page *page)
>> =A0 =A0 =A0 if (page->mapping) { =A0 =A0/* Race with truncate? */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 WARN_ON_ONCE(!PageUptodate(page));
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (mapping_cap_account_dirty(mapping)) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __inc_zone_page_state(page, NR=
_FILE_DIRTY);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __inc_bdi_stat(mapping->backin=
g_dev_info,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 BDI_RECLAIMABLE);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 task_io_account_write(PAGE_CAC=
HE_SIZE);
>> - =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (mapping_cap_account_dirty(mapping))
>
> That 'if' is not necessary. account_page_dirtied() already has one.
> The extra 'if' is not an optimization either, because the ceph fs is
> not likely to have un-accountable mappings.

Sweet. Thanks.
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 account_page_dirtied(page, pag=
e->mapping);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 radix_tree_tag_set(&mapping->page_tree,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 page_index(p=
age), PAGECACHE_TAG_DIRTY);
>>
>> diff --git a/fs/nilfs2/segment.c b/fs/nilfs2/segment.c
>> index c920164..967ed7d 100644
>> --- a/fs/nilfs2/segment.c
>> +++ b/fs/nilfs2/segment.c
>> @@ -1599,7 +1599,7 @@ nilfs_copy_replace_page_buffers(struct page *page,=
 struct list_head *out)
>> =A0 =A0 =A0 kunmap_atomic(kaddr, KM_USER0);
>>
>> =A0 =A0 =A0 if (!TestSetPageWriteback(clone_page))
>> - =A0 =A0 =A0 =A0 =A0 =A0 inc_zone_page_state(clone_page, NR_WRITEBACK);
>> + =A0 =A0 =A0 =A0 =A0 =A0 account_page_writeback(clone_page, page_mappin=
g(clone_page));
>> =A0 =A0 =A0 unlock_page(clone_page);
>>
>> =A0 =A0 =A0 return 0;
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index a2b4804..b138392 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -855,6 +855,7 @@ int __set_page_dirty_no_writeback(struct page *page)=
;
>> =A0int redirty_page_for_writepage(struct writeback_control *wbc,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page =
*page);
>> =A0void account_page_dirtied(struct page *page, struct address_space *ma=
pping);
>> +void account_page_writeback(struct page *page, struct address_space *ma=
pping);
>> =A0int set_page_dirty(struct page *page);
>> =A0int set_page_dirty_lock(struct page *page);
>> =A0int clear_page_dirty_for_io(struct page *page);
>> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
>> index 37498ef..b8e7b3b 100644
>> --- a/mm/page-writeback.c
>> +++ b/mm/page-writeback.c
>> @@ -1096,6 +1096,21 @@ void account_page_dirtied(struct page *page, stru=
ct address_space *mapping)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 task_io_account_write(PAGE_CACHE_SIZE);
>> =A0 =A0 =A0 }
>> =A0}
>> +EXPORT_SYMBOL(account_page_dirtied);
>> +
>> +/*
>> + * Helper function for set_page_writeback family.
>> + * NOTE: Unlike account_page_dirtied this does not rely on being atomic
>> + * wrt interrupts.
>> + */
>> +
>> +void account_page_writeback(struct page *page, struct address_space *ma=
pping)
>> +{
>> + =A0 =A0 if (mapping_cap_account_dirty(mapping))
>
> The 'if' test and *mapping parameter looks unnecessary at least for
> now. The only place a mapping has BDI_CAP_NO_ACCT_WB but not
> BDI_CAP_NO_WRITEBACK is fuse, which does its own accounting.

Cool.
Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
