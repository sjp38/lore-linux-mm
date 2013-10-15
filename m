Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 0A9A06B0031
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 14:58:32 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id y10so9245991pdj.39
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 11:58:32 -0700 (PDT)
Received: by mail-vc0-f180.google.com with SMTP id ld13so5377633vcb.39
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 11:58:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20131015102912.2BC99E0090@blue.fi.intel.com>
References: <20131015001214.GD3432@hippobay.mtv.corp.google.com> <20131015102912.2BC99E0090@blue.fi.intel.com>
From: Ning Qu <quning@google.com>
Date: Tue, 15 Oct 2013 11:58:09 -0700
Message-ID: <CACz4_2eh3F2An9F0GxSvw8kSmn2VZbqbdRVGXA2B=gvPFCChUw@mail.gmail.com>
Subject: Re: [PATCH 03/12] mm, thp, tmpfs: handle huge page cases in shmem_getpage_gfp
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Al Viro <viro@zeniv.linux.org.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Best wishes,
--=20
Ning Qu (=E6=9B=B2=E5=AE=81) | Software Engineer | quning@google.com | +1-4=
08-418-6066


On Tue, Oct 15, 2013 at 3:29 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> Ning Qu wrote:
>> We don't support huge page when page is moved from page cache to swap.
>> So in this function, we enable huge page handling in two case:
>>
>> 1) when a huge page is found in the page cache,
>> 2) or we need to alloc a huge page for page cache
>>
>> We have to refactor all the calls to shmem_getpages to simplify the job
>> of caller. Right now shmem_getpage does:
>>
>> 1) simply request a page, default as a small page
>> 2) or caller specify a flag to request either a huge page or a small pag=
e,
>> then leave the caller to decide how to use it
>>
>> Signed-off-by: Ning Qu <quning@gmail.com>
>> ---
>>  mm/shmem.c | 139 +++++++++++++++++++++++++++++++++++++++++++++++-------=
-------
>>  1 file changed, 108 insertions(+), 31 deletions(-)
>>
>> diff --git a/mm/shmem.c b/mm/shmem.c
>> index 447bd14..8fe17dd 100644
>> --- a/mm/shmem.c
>> +++ b/mm/shmem.c
>> @@ -115,15 +115,43 @@ static unsigned long shmem_default_max_inodes(void=
)
>>  static bool shmem_should_replace_page(struct page *page, gfp_t gfp);
>>  static int shmem_replace_page(struct page **pagep, gfp_t gfp,
>>                               struct shmem_inode_info *info, pgoff_t ind=
ex);
>> +
>>  static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
>> -     struct page **pagep, enum sgp_type sgp, gfp_t gfp, int *fault_type=
);
>> +     struct page **pagep, enum sgp_type sgp, gfp_t gfp, int flags,
>> +     int *fault_type);
>> +
>> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE
>> +static inline int shmem_getpage(struct inode *inode, pgoff_t index,
>> +     struct page **pagep, enum sgp_type sgp, gfp_t gfp, int flags,
>> +     int *fault_type)
>> +{
>> +     int ret =3D 0;
>> +     struct page *page =3D NULL;
>>
>> +     if ((flags & AOP_FLAG_TRANSHUGE) &&
>> +         mapping_can_have_hugepages(inode->i_mapping)) {
>
> I don't think we need ifdef here. mapping_can_have_hugepages() will be 0
> compile-time, if CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE is not defined and
> compiler should optimize out thp case.

The same problem since HPAGE_CACHE_INDEX_MASK is build bug?

>
>> @@ -1298,27 +1348,37 @@ repeat:
>>                               error =3D -ENOSPC;
>>                               goto unacct;
>>                       }
>> -                     percpu_counter_inc(&sbinfo->used_blocks);
>>               }
>>
>> -             page =3D shmem_alloc_page(gfp, info, index);
>> +             if (must_use_thp) {
>> +                     page =3D shmem_alloc_hugepage(gfp, info, index);
>> +                     if (page) {
>> +                             count_vm_event(THP_WRITE_ALLOC);
>> +                             nr =3D hpagecache_nr_pages(page);
>
> nr =3D hpagecache_nr_pages(page) can be moved below if (must_use_thp).
> hpagecache_nr_pages(page) evaluates to 0 for small pages.
>
you mean something like this? If so, then fixed.

               if (must_use_thp) {
                        page =3D shmem_alloc_hugepage(gfp, info, index);
                        if (page) {
                                count_vm_event(THP_WRITE_ALLOC);
                        } else
                                count_vm_event(THP_WRITE_ALLOC_FAILED);
                } else {
                        page =3D shmem_alloc_page(gfp, info, index);
                }

                if (!page) {
                        error =3D -ENOMEM;
                        goto unacct;
                }
                nr =3D hpagecache_nr_pages(page);


>
> --
>  Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
