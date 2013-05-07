Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 8C9B66B00CD
	for <linux-mm@kvack.org>; Tue,  7 May 2013 18:28:19 -0400 (EDT)
Received: by mail-qe0-f41.google.com with SMTP id b10so696117qen.28
        for <linux-mm@kvack.org>; Tue, 07 May 2013 15:28:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1367963581-fsskl9vz-mutt-n-horiguchi@ah.jp.nec.com>
References: <1367959554-3218-1-git-send-email-j.glisse@gmail.com>
	<1367963581-fsskl9vz-mutt-n-horiguchi@ah.jp.nec.com>
Date: Tue, 7 May 2013 18:28:18 -0400
Message-ID: <CAH3drwbQ91tb=C2D+fNkdPapK75db0yAaWsUrU2A41Rigsuxfg@mail.gmail.com>
Subject: Re: [PATCH 1/3] mm: honor FOLL_GET flag in follow_hugetlb_page
From: Jerome Glisse <j.glisse@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jerome Glisse <jglisse@redhat.com>

On Tue, May 7, 2013 at 5:53 PM, Naoya Horiguchi
<n-horiguchi@ah.jp.nec.com> wrote:
> On Tue, May 07, 2013 at 04:45:54PM -0400, j.glisse@gmail.com wrote:
>> From: Jerome Glisse <jglisse@redhat.com>
>>
>> Do not increase page count if FOLL_GET is not set.
>>
>> Signed-off-by: Jerome Glisse <jglisse@redhat.com>
>> ---
>>  mm/hugetlb.c | 4 +++-
>>  1 file changed, 3 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index 1a12f5b..5d1e46b 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -2991,7 +2991,9 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
>>  same_page:
>>               if (pages) {
>>                       pages[i] = mem_map_offset(page, pfn_offset);
>> -                     get_page(pages[i]);
>> +                     if (flags & FOLL_GET) {
>> +                             get_page_foll(pages[i]);
>> +                     }
>>               }
>>
>>               if (vmas)
>> --
>
> Hi Jerome,
>
> I think that we need to be careful in handling tail pages, because
> __get_page_tail_foll() uses page->_mapcount as refcount.
> When you get refcount on a tail page and free the hugepage without
> putting the *mapcount*, you will hit BUG_ON() in free_huge_page().
> Yes, this is a very tricky workaround for thp, so to avoid making
> things too complicated, I think either of the following is better:
>  - to get refcount only for head pages, or
>  - to introduce a hugetlbfs variant of get_page_foll().

Maybe a simpler variant is to just not take any refcount, ie like
current code if FOLL_GET is set then take refcount on all page wether
they are head/tail or not. I will resend with that.

> BTW, who do you expect is the caller of follow_hugetlb_page()
> with FOLL_GET (I can't find your subsequent patches 2/3 or 3/3)?
> I'm interested in this change because in my project it's necessary
> to implement this for hugepage migration
> (see https://lkml.org/lkml/2013/3/22/553).

I can not talk about the patchset yet (and it's not fully cook) but i
need to be able to get the page without taking reference so without
the FOLL_GET flag set but i need splitting, well no real splitting, i
need pfn for each fake sub page of huge page (interested in physical
address not in the page struct).

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
