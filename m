Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id EFB596B00C8
	for <linux-mm@kvack.org>; Thu, 17 Oct 2013 16:58:59 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id up15so2828188pbc.26
        for <linux-mm@kvack.org>; Thu, 17 Oct 2013 13:58:59 -0700 (PDT)
Received: by mail-vc0-f175.google.com with SMTP id ia6so1483437vcb.34
        for <linux-mm@kvack.org>; Thu, 17 Oct 2013 13:58:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20131016120951.B5012E0090@blue.fi.intel.com>
References: <20131015001304.GH3432@hippobay.mtv.corp.google.com>
 <20131015110146.7E8BEE0090@blue.fi.intel.com> <CACz4_2fiF+vaAbFixgGF+Uxn0av4H8y-aMQdyi3yYs5pdS2WBA@mail.gmail.com>
 <20131016120951.B5012E0090@blue.fi.intel.com>
From: Ning Qu <quning@google.com>
Date: Thu, 17 Oct 2013 13:58:35 -0700
Message-ID: <CACz4_2eR+-N+FmOj+JB0YXKNZZpOaP7JG79rCr=xFKKLp4y7fw@mail.gmail.com>
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

I agree, I review the code of generate truncate and shmem_undo_range again.
There are just too many differences in almost every major piece of
logic. It's really
not possible to extract any meaningful common function to share between the=
m.

And I agree, we will try to refactor any other functions which are
possible. Thanks!

>
> --
>  Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
