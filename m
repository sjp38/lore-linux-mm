Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id E4BF56B0031
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 14:48:47 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so1379945pdj.1
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 11:48:47 -0700 (PDT)
Received: by mail-vc0-f169.google.com with SMTP id hu8so508291vcb.14
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 11:48:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20131016120951.B5012E0090@blue.fi.intel.com>
References: <20131015001304.GH3432@hippobay.mtv.corp.google.com>
 <20131015110146.7E8BEE0090@blue.fi.intel.com> <CACz4_2fiF+vaAbFixgGF+Uxn0av4H8y-aMQdyi3yYs5pdS2WBA@mail.gmail.com>
 <20131016120951.B5012E0090@blue.fi.intel.com>
From: Ning Qu <quning@google.com>
Date: Wed, 16 Oct 2013 11:48:24 -0700
Message-ID: <CACz4_2eAots8Xk3C8Vosqc24vs28OtsD4LecsH19MjWeQaw+2Q@mail.gmail.com>
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


On Wed, Oct 16, 2013 at 5:09 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> Ning Qu wrote:
>> > Again. Here and below ifdef is redundant: PageTransHugeCache() is zero
>> > compile-time and  thp case will be optimize out.
>>
>> The problem is actually from HPAGE_CACHE_INDEX_MASK, it is marked as
>> build bug when CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE is false. So we
>> either wrap some logic inside a inline function, or we have to be like
>> this .. Or we don't treat the HPAGE_CACHE_INDEX_MASK as a build bug?
>
> HPAGE_CACHE_INDEX_MASK shouldn't be a problem.
> If it's wrapped into 'if PageTransHugeCache(page)' or similar it will be
> eliminated by compiler if thp-pc disabled and build bug will not be
> triggered.
>
Yes, you are totally right about this. I have remove all the ifdef for
CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE now. Thanks!

>>
>> >
>> > And do we really need a copy of truncate logic here? Is there a way to
>> > share code?
>> >
>> The truncate between tmpfs and general one is similar but not exactly
>> the same (no readahead), so share the whole function might not be a
>> good choice from the perspective of tmpfs? Anyway, there are other
>> similar functions in tmpfs, e.g. the one you mentioned for
>> shmem_add_to_page_cache. It is possible to share the code, I am just
>> worried it will make the logic more complicated?
>
> I think introducing thp-pc is good opportunity to refactor all these code=
.
>
> --
>  Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
