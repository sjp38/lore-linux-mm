Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 505296B0035
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 13:27:39 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id rr4so9016878pbb.20
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 10:27:38 -0700 (PDT)
Received: by mail-vb0-f41.google.com with SMTP id g17so5503541vbg.28
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 10:27:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20131015100213.A0189E0090@blue.fi.intel.com>
References: <20131015001201.GC3432@hippobay.mtv.corp.google.com> <20131015100213.A0189E0090@blue.fi.intel.com>
From: Ning Qu <quning@google.com>
Date: Tue, 15 Oct 2013 10:27:14 -0700
Message-ID: <CACz4_2er-_Xa8oRo_JJTC+HZtDTAcjJ+cNTjrXLhN0Dm7BtXFQ@mail.gmail.com>
Subject: Re: [PATCH 02/12] mm, thp, tmpfs: support to add huge page into page
 cache for tmpfs
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Al Viro <viro@zeniv.linux.org.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Yes, I can try. The code is pretty much similar with some minor difference.

One thing I can do is to move the spin lock part (together with the
corresponding err handling into a common function.

The only problem I can see right now is we need the following
additional line for shm:

__mod_zone_page_state(page_zone(page), NR_SHMEM, nr);

Which means we need to tell if it's coming from shm or not, is that OK
to add additional parameter just for that? Or is there any other
better way we can infer that information? Thanks!
Best wishes,
--=20
Ning Qu (=E6=9B=B2=E5=AE=81) | Software Engineer | quning@google.com | +1-4=
08-418-6066


On Tue, Oct 15, 2013 at 3:02 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> Ning Qu wrote:
>> For replacing a page inside page cache, we assume the huge page
>> has been splitted before getting here.
>>
>> For adding a new page to page cache, huge page support has been added.
>>
>> Also refactor the shm_add_to_page_cache function.
>>
>> Signed-off-by: Ning Qu <quning@gmail.com>
>> ---
>>  mm/shmem.c | 97 +++++++++++++++++++++++++++++++++++++++++++++++++++++++=
+------
>>  1 file changed, 88 insertions(+), 9 deletions(-)
>>
>> diff --git a/mm/shmem.c b/mm/shmem.c
>> index a857ba8..447bd14 100644
>> --- a/mm/shmem.c
>> +++ b/mm/shmem.c
>> @@ -277,27 +277,23 @@ static bool shmem_confirm_swap(struct address_spac=
e *mapping,
>>  }
>>
>>  /*
>> - * Like add_to_page_cache_locked, but error if expected item has gone.
>> + * Replace the swap entry with page cache entry
>>   */
>> -static int shmem_add_to_page_cache(struct page *page,
>> +static int shmem_replace_page_page_cache(struct page *page,
>>                                  struct address_space *mapping,
>>                                  pgoff_t index, gfp_t gfp, void *expecte=
d)
>>  {
>>       int error;
>>
>> -     VM_BUG_ON(!PageLocked(page));
>> -     VM_BUG_ON(!PageSwapBacked(page));
>> +     BUG_ON(PageTransHugeCache(page));
>>
>>       page_cache_get(page);
>>       page->mapping =3D mapping;
>>       page->index =3D index;
>>
>>       spin_lock_irq(&mapping->tree_lock);
>> -     if (!expected)
>> -             error =3D radix_tree_insert(&mapping->page_tree, index, pa=
ge);
>> -     else
>> -             error =3D shmem_radix_tree_replace(mapping, index, expecte=
d,
>> -                                                              page);
>> +
>> +     error =3D shmem_radix_tree_replace(mapping, index, expected, page)=
;
>>       if (!error) {
>>               mapping->nrpages++;
>>               __inc_zone_page_state(page, NR_FILE_PAGES);
>> @@ -312,6 +308,87 @@ static int shmem_add_to_page_cache(struct page *pag=
e,
>>  }
>>
>>  /*
>> + * Insert new page into with page cache
>> + */
>> +static int shmem_insert_page_page_cache(struct page *page,
>> +                                struct address_space *mapping,
>> +                                pgoff_t index, gfp_t gfp)
>> +{
>
> You copy-paste most of add_to_page_cache_locked() code here. Is there a
> way to share the code? Move common part into __add_to_page_cache_locked()
> or something.
>
> --
>  Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
