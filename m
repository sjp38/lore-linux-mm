Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 3E9D86B00E7
	for <linux-mm@kvack.org>; Tue, 22 May 2012 18:41:24 -0400 (EDT)
Received: by vbjk17 with SMTP id k17so6343008vbj.21
        for <linux-mm@kvack.org>; Tue, 22 May 2012 15:41:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120522174842.GB4071@redhat.com>
References: <1337293069-22443-1-git-send-email-pshelar@nicira.com>
	<20120522174842.GB4071@redhat.com>
Date: Tue, 22 May 2012 15:41:22 -0700
Message-ID: <CALnjE+qwj5vUrR0ptO==MqpN8=eTTogxrYdY9t3eeWZEK8hpoQ@mail.gmail.com>
Subject: Re: [PATCH v3] mm: Fix slab->page flags corruption.
From: Pravin Shelar <pshelar@nicira.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: cl@linux.com, penberg@kernel.org, mpm@selenic.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jesse@nicira.com, abhide@nicira.com

On Tue, May 22, 2012 at 10:48 AM, Andrea Arcangeli <aarcange@redhat.com> wr=
ote:
> On Thu, May 17, 2012 at 03:17:49PM -0700, Pravin B Shelar wrote:
>> diff --git a/mm/swap.c b/mm/swap.c
>> index 8ff73d8..44a0f81 100644
>> --- a/mm/swap.c
>> +++ b/mm/swap.c
>> @@ -82,6 +82,19 @@ static void put_compound_page(struct page *page)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (likely(page !=3D page_head &&
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0get_page_unless_zero(=
page_head))) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long flags;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (PageSlab(page_head)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (PageTail(p=
age)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 /* THP can not break up slab pages, avoid
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0* taking compound_lock(). */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 if (put_page_testzero(page_head))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 VM_BUG_ON(1);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 atomic_dec(&page->_mapcount);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 goto skip_lock_tail;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 goto skip_lock;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>
> Some commentary on the fact slab prefers not using atomic ops on the
> page->flags could help here.
ok.

>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* page_head wasn't a dang=
ling pointer but it
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* may not be a head page =
anymore by the time
>> @@ -93,6 +106,7 @@ static void put_compound_page(struct page *page)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* __split_h=
uge_page_refcount run before us */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 compound_unl=
ock_irqrestore(page_head, flags);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 VM_BUG_ON(Pa=
geHead(page_head));
>
> Hmmm hmmm while reviewing this one, I've been thinking maybe the head
> page after the hugepage split, could have been freed and reallocated
> as order 1 or 2, and legitimately become an head page again.
>
> The whole point of the bug-on is that it cannot be reallocated as a
> THP beause the tail is still there and it's not free yet, but it
> doesn't take into account the head page could be allocated as a
> compound page of a smaller size and maybe the tail is the last subpage
> of the thp.
>
> So there's the risk of a false positive, in an extremely unlikely case
> (the fact slab goes in unmovable pageblocks and thp goes in movable
> further decreases the probability). All production kernels runs with
> VM_BUG_ON disabled so it's a very small concern, but maybe we should
> delete it. It has never triggered, just code reivew. Do you agree?
>
right, I will delete it.

>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skip_lock:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (put_page=
_testzero(page_head))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 __put_single_page(page_head);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 out_put_single:
>> @@ -115,6 +129,8 @@ static void put_compound_page(struct page *page)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 VM_BUG_ON(atomic_read(&page_=
head->_count) <=3D 0);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 VM_BUG_ON(atomic_read(&page-=
>_count) !=3D 0);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 compound_unlock_irqrestore(p=
age_head, flags);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skip_lock_tail:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (put_page_testzero(page_h=
ead)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (PageHead=
(page_head))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 __put_compound_page(page_head);
>> @@ -162,6 +178,15 @@ bool __get_page_tail(struct page *page)
>> =A0 =A0 =A0 struct page *page_head =3D compound_trans_head(page);
>>
>> =A0 =A0 =A0 if (likely(page !=3D page_head && get_page_unless_zero(page_=
head))) {
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (PageSlab(page_head)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (likely(PageTail(page))) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __get_page_tai=
l_foll(page, false);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return true;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> +
>
> A comment here too would be nice.
>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* page_head wasn't a dangling pointer but=
 it
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* may not be a head page anymore by the t=
ime
>> @@ -175,6 +200,8 @@ bool __get_page_tail(struct page *page)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 got =3D true;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 compound_unlock_irqrestore(page_head, flags)=
;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 out:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(!got))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_page(page_head);
>
> out could go in the line below. Assuming we don't want to be cleaner
> and use put_page above instead of goto, that would also drop a branch
> probably (the goto place is such a slow path). I'm fine either ways.
>
> It's not the cleanest of the patches but it's clearly a performance
> tweak.
>
ok, I will post revised patch.
> Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
>
> Thanks,
> Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
