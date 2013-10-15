Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 35D286B0031
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 14:49:04 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so9471364pad.2
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 11:49:03 -0700 (PDT)
Received: by mail-vb0-f44.google.com with SMTP id p14so413537vbm.17
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 11:49:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20131015110146.7E8BEE0090@blue.fi.intel.com>
References: <20131015001304.GH3432@hippobay.mtv.corp.google.com> <20131015110146.7E8BEE0090@blue.fi.intel.com>
From: Ning Qu <quning@google.com>
Date: Tue, 15 Oct 2013 11:48:40 -0700
Message-ID: <CACz4_2fiF+vaAbFixgGF+Uxn0av4H8y-aMQdyi3yYs5pdS2WBA@mail.gmail.com>
Subject: Re: [PATCH 07/12] mm, thp, tmpfs: handle huge page in
 shmem_undo_range for truncate
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


On Tue, Oct 15, 2013 at 4:01 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> Ning Qu wrote:
>> When comes to truncate file, add support to handle huge page in the
>> truncate range.
>>
>> Signed-off-by: Ning Qu <quning@gmail.com>
>> ---
>>  mm/shmem.c | 97 +++++++++++++++++++++++++++++++++++++++++++++++++++++++=
-------
>>  1 file changed, 86 insertions(+), 11 deletions(-)
>>
>> diff --git a/mm/shmem.c b/mm/shmem.c
>> index 0a423a9..90f2e0e 100644
>> --- a/mm/shmem.c
>> +++ b/mm/shmem.c
>> @@ -559,6 +559,7 @@ static void shmem_undo_range(struct inode *inode, lo=
ff_t lstart, loff_t lend,
>>       struct shmem_inode_info *info =3D SHMEM_I(inode);
>>       pgoff_t start =3D (lstart + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHI=
FT;
>>       pgoff_t end =3D (lend + 1) >> PAGE_CACHE_SHIFT;
>> +     /* Whether we have to do partial truncate */
>>       unsigned int partial_start =3D lstart & (PAGE_CACHE_SIZE - 1);
>>       unsigned int partial_end =3D (lend + 1) & (PAGE_CACHE_SIZE - 1);
>>       struct pagevec pvec;
>> @@ -570,12 +571,16 @@ static void shmem_undo_range(struct inode *inode, =
loff_t lstart, loff_t lend,
>>       if (lend =3D=3D -1)
>>               end =3D -1;       /* unsigned, so actually very big */
>>
>> +     i_split_down_read(inode);
>>       pagevec_init(&pvec, 0);
>>       index =3D start;
>>       while (index < end) {
>> +             bool thp =3D false;
>> +
>>               pvec.nr =3D shmem_find_get_pages_and_swap(mapping, index,
>>                               min(end - index, (pgoff_t)PAGEVEC_SIZE),
>>                                                       pvec.pages, indice=
s);
>> +
>>               if (!pvec.nr)
>>                       break;
>>               mem_cgroup_uncharge_start();
>> @@ -586,6 +591,25 @@ static void shmem_undo_range(struct inode *inode, l=
off_t lstart, loff_t lend,
>>                       if (index >=3D end)
>>                               break;
>>
>> +                     thp =3D PageTransHugeCache(page);
>> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE
>
> Again. Here and below ifdef is redundant: PageTransHugeCache() is zero
> compile-time and  thp case will be optimize out.

The problem is actually from HPAGE_CACHE_INDEX_MASK, it is marked as
build bug when CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE is false. So we
either wrap some logic inside a inline function, or we have to be like
this .. Or we don't treat the HPAGE_CACHE_INDEX_MASK as a build bug?

>
> And do we really need a copy of truncate logic here? Is there a way to
> share code?
>
The truncate between tmpfs and general one is similar but not exactly
the same (no readahead), so share the whole function might not be a
good choice from the perspective of tmpfs? Anyway, there are other
similar functions in tmpfs, e.g. the one you mentioned for
shmem_add_to_page_cache. It is possible to share the code, I am just
worried it will make the logic more complicated?

Maybe Hugh is in better position to judge on this? Thanks!

> --
>  Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
