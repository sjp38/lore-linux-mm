Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 6834A6B0044
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 13:50:56 -0400 (EDT)
Received: by lbbgg6 with SMTP id gg6so1613550lbb.14
        for <linux-mm@kvack.org>; Thu, 26 Apr 2012 10:50:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F98DA64.6030101@kernel.org>
References: <1335375955-32037-1-git-send-email-yinghan@google.com>
	<4F98DA64.6030101@kernel.org>
Date: Thu, 26 Apr 2012 10:50:53 -0700
Message-ID: <CALWz4iwTO6yqLU3i67KRqht7NR6=VMH_Q8j+GcnO9tSn6Nj9Bg@mail.gmail.com>
Subject: Re: [PATCH] rename is_mlocked_vma() to mlocked_vma_newpage()
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Wed, Apr 25, 2012 at 10:17 PM, Minchan Kim <minchan@kernel.org> wrote:
> On 04/26/2012 02:45 AM, Ying Han wrote:
>
>> Andrew pointed out that the is_mlocked_vma() is misnamed. A function
>> with name like that would expect bool return and no side-effects.
>>
>> Since it is called on the fault path for new page, rename it in this
>> patch.
>>
>> Signed-off-by: Ying Han <yinghan@google.com>
>
>
>
> Reviewed-by: Minchan Kim <minchan@kernel.org>
>
> Nitpick:
>
> mlocked_vma_newpage is better?
> It seems I am a paranoic about naming. :-)
> Feel free to ignore if you don't want.

Thanks, at least I see it is inconsistant to the title.

I will post another one

--Ying

>
>
>
>> ---
>> =A0mm/internal.h | =A0 =A05 +++--
>> =A0mm/vmscan.c =A0 | =A0 =A02 +-
>> =A02 files changed, 4 insertions(+), 3 deletions(-)
>>
>> diff --git a/mm/internal.h b/mm/internal.h
>> index 2189af4..a935af3 100644
>> --- a/mm/internal.h
>> +++ b/mm/internal.h
>> @@ -131,7 +131,8 @@ static inline void munlock_vma_pages_all(struct vm_a=
rea_struct *vma)
>> =A0 * to determine if it's being mapped into a LOCKED vma.
>> =A0 * If so, mark page as mlocked.
>> =A0 */
>> -static inline int is_mlocked_vma(struct vm_area_struct *vma, struct pag=
e *page)
>> +static inline int mlock_vma_newpage(struct vm_area_struct *vma,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct=
 page *page)
>> =A0{
>> =A0 =A0 =A0 VM_BUG_ON(PageLRU(page));
>>
>> @@ -189,7 +190,7 @@ extern unsigned long vma_address(struct page *page,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct vm=
_area_struct *vma);
>> =A0#endif
>> =A0#else /* !CONFIG_MMU */
>> -static inline int is_mlocked_vma(struct vm_area_struct *v, struct page =
*p)
>> +static inline int mlock_vma_newpage(struct vm_area_struct *v, struct pa=
ge *p)
>> =A0{
>> =A0 =A0 =A0 return 0;
>> =A0}
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 1a51868..686c63e 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -3531,7 +3531,7 @@ int page_evictable(struct page *page, struct vm_ar=
ea_struct *vma)
>> =A0 =A0 =A0 if (mapping_unevictable(page_mapping(page)))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>>
>> - =A0 =A0 if (PageMlocked(page) || (vma && is_mlocked_vma(vma, page)))
>> + =A0 =A0 if (PageMlocked(page) || (vma && mlock_vma_newpage(vma, page))=
)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>>
>> =A0 =A0 =A0 return 1;
>
>
>
> --
> Kind regards,
> Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
