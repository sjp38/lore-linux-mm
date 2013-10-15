Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 7440F6B0031
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 15:00:27 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so9449587pad.30
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 12:00:27 -0700 (PDT)
Received: by mail-ve0-f177.google.com with SMTP id jw12so655193veb.8
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 12:00:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20131015103334.E3877E0090@blue.fi.intel.com>
References: <20131015001228.GE3432@hippobay.mtv.corp.google.com> <20131015103334.E3877E0090@blue.fi.intel.com>
From: Ning Qu <quning@google.com>
Date: Tue, 15 Oct 2013 12:00:03 -0700
Message-ID: <CACz4_2eoRoyUU1G3veS=veWTi1HtPrgLQK0tyXONXcQj1Xi4EQ@mail.gmail.com>
Subject: Re: [PATCH 04/12] mm, thp, tmpfs: split huge page when moving from
 page cache to swap
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Al Viro <viro@zeniv.linux.org.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Let me take another look at that logic. Thanks!
Best wishes,
--=20
Ning Qu (=E6=9B=B2=E5=AE=81) | Software Engineer | quning@google.com | +1-4=
08-418-6066


On Tue, Oct 15, 2013 at 3:33 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> Ning Qu wrote:
>> in shmem_writepage, we have to split the huge page when moving pages
>> from page cache to swap because we don't support huge page in swap
>> yet.
>>
>> Signed-off-by: Ning Qu <quning@gmail.com>
>> ---
>>  mm/shmem.c | 9 ++++++++-
>>  1 file changed, 8 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/shmem.c b/mm/shmem.c
>> index 8fe17dd..68a0e1d 100644
>> --- a/mm/shmem.c
>> +++ b/mm/shmem.c
>> @@ -898,6 +898,13 @@ static int shmem_writepage(struct page *page, struc=
t writeback_control *wbc)
>>       swp_entry_t swap;
>>       pgoff_t index;
>>
>> +     /* TODO: we have to break the huge page at this point,
>> +      * since we have no idea how to recover a huge page from
>> +      * swap.
>> +      */
>> +     if (PageTransCompound(page))
>> +             split_huge_page(compound_trans_head(page));
>> +
>
> After the split you handle here only first small page of the huge page.
> Is it what we want to do? Should we swap out all small pages of the huge
> page?
>
> --
>  Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
