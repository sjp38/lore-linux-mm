Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 001126B0092
	for <linux-mm@kvack.org>; Thu, 17 May 2012 17:25:12 -0400 (EDT)
Received: by mail-vb0-f54.google.com with SMTP id v11so3933557vbm.27
        for <linux-mm@kvack.org>; Thu, 17 May 2012 14:25:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120517004434.GX19697@redhat.com>
References: <1337020877-20087-1-git-send-email-pshelar@nicira.com>
	<20120517004434.GX19697@redhat.com>
Date: Thu, 17 May 2012 14:25:11 -0700
Message-ID: <CALnjE+oNQ6ny2EnyExz3UuetXRD8gQwa5rN8tGdSff9g78FY0g@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: Fix slab->page flags corruption.
From: Pravin Shelar <pshelar@nicira.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: cl@linux.com, penberg@kernel.org, mpm@selenic.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jesse@nicira.com, abhide@nicira.com

On Wed, May 16, 2012 at 5:44 PM, Andrea Arcangeli <aarcange@redhat.com> wro=
te:
> Hi Pravin,
>
> On Mon, May 14, 2012 at 11:41:17AM -0700, Pravin B Shelar wrote:
>> Transparent huge pages can change page->flags (PG_compound_lock)
>> without taking Slab lock. Since THP can not break slab pages we can
>> safely access compound page without taking compound lock.
>>
>> Specificly this patch fixes race between compound_unlock and slab
>> functions which does page-flags update. This can occur when
>> get_page/put_page is called on page from slab object.
>
> DMA on slab running put_page concurrently with kmem_cache_free/kfree
> was unexpected. Is this the scenario where the race happens, right?
>
I have seen slab pages passed for DMA in many instances, e.g. in xfs, ocfs,=
 etc.

>> diff --git a/mm/swap.c b/mm/swap.c
>> index 8ff73d8..d4eb9f6 100644
>> --- a/mm/swap.c
>> +++ b/mm/swap.c
>> @@ -82,6 +82,16 @@ static void put_compound_page(struct page *page)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (likely(page !=3D page_head &&
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0get_page_unless_zero(=
page_head))) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long flags;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (PageSlab(page_head)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* THP can not=
 break up slab pages, avoid
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* taking co=
mpound_lock(). */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (put_page_t=
estzero(page_head))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 VM_BUG_ON(1);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 atomic_dec(&pa=
ge->_mapcount);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto skip_lock=
;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>
> If a THP is splitted before get_page_unless_zero runs, the head page
> may be then freed and reallocated as slab. The "page" then should not
> be freed as a tail page anymore, because it's not a tail page. The
> head just accidentally become a slab (maybe not even a compound slab).
>
> To avoid such scenario this should be enough:
>
> =A0 =A0 if (PageSlab(page_head) && PageTail(page)) {
> =A0 =A0 ...
> =A0 =A0 }
>

right, I will send updated patch.

Thanks,
Pravin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
