Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 1875B6B005A
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 09:32:38 -0500 (EST)
Received: by wgbds11 with SMTP id ds11so2480606wgb.26
        for <linux-mm@kvack.org>; Tue, 10 Jan 2012 06:32:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120110124442.ffb63d63.kamezawa.hiroyu@jp.fujitsu.com>
References: <CAJd=RBAMtT04n8p4ht4oCSOYKVcUcG0-hbSvmjrP-yhwBYhU1A@mail.gmail.com>
	<20120110124442.ffb63d63.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 10 Jan 2012 22:32:36 +0800
Message-ID: <CAJd=RBAS-hz1=ACF86cRKkzrOSyU5LWcHeLmSL+JfMHdE8wh9g@mail.gmail.com>
Subject: Re: [PATCH] mm: vmscan: recompute page status when putting back
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jan 10, 2012 at 11:44 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 6 Jan 2012 22:07:29 +0800
> Hillf Danton <dhillf@gmail.com> wrote:
>
>> If unlikely the given page is isolated from lru list again, its status i=
s
>> recomputed before putting back to lru list, since the comment says page'=
s
>> status can change while we move it among lru.
>>
>>
>> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> Cc: David Rientjes <rientjes@google.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Signed-off-by: Hillf Danton <dhillf@gmail.com>
>> ---
>>
>> --- a/mm/vmscan.c =C2=A0 =C2=A0 Thu Dec 29 20:20:16 2011
>> +++ b/mm/vmscan.c =C2=A0 =C2=A0 Fri Jan =C2=A06 21:31:56 2012
>> @@ -633,12 +633,14 @@ int remove_mapping(struct address_space
>> =C2=A0void putback_lru_page(struct page *page)
>> =C2=A0{
>> =C2=A0 =C2=A0 =C2=A0 int lru;
>> - =C2=A0 =C2=A0 int active =3D !!TestClearPageActive(page);
>> - =C2=A0 =C2=A0 int was_unevictable =3D PageUnevictable(page);
>> + =C2=A0 =C2=A0 int active;
>> + =C2=A0 =C2=A0 int was_unevictable;
>>
>> =C2=A0 =C2=A0 =C2=A0 VM_BUG_ON(PageLRU(page));
>>
>> =C2=A0redo:
>> + =C2=A0 =C2=A0 active =3D !!TestClearPageActive(page);
>> + =C2=A0 =C2=A0 was_unevictable =3D PageUnevictable(page);
>> =C2=A0 =C2=A0 =C2=A0 ClearPageUnevictable(page);
>>
>> =C2=A0 =C2=A0 =C2=A0 if (page_evictable(page, NULL)) {
>
> Hm. Do you handle this case ?
> =3D=3D
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * page's status can change while we move it a=
mong lru. If an evictable
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * page is on unevictable list, it never be fr=
eed. To avoid that,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * check after we added it to the list, again.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (lru =3D=3D LRU_UNEVICTABLE && page_evictab=
le(page, NULL)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!isolate_lru_p=
age(page)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0put_page(page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0goto redo;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =3D=3D
>
> Ok, let's start from "was_unevictable"
>
> "was_unevicatable" is used for this
> =3D=3D
> =C2=A0if (was_unevictable && lru !=3D LRU_UNEVICTABLE)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0count_vm_event(UNE=
VICTABLE_PGRESCUED);
> =3D=3D
> This is for checking that the page turned out to be evictable while we pu=
t it
> into LRU. Assume the 'redo' case, the page's state chages from UNEVICTABL=
E to
> ACTIVE_ANON (for example)
>
> =C2=A01. at start of function: Page was Unevictable, was_unevictable=3Dtr=
ue
> =C2=A02. lru =3D LRU_UNEVICTABLE
> =C2=A03, add the page to LRU.
> =C2=A04. check page_evictable(),..... it returns 'true'.
> =C2=A05. isoalte the page again and goto redo.
> =C2=A06. lru =3D LRU_ACTIVE_ANON
> =C2=A07. add the page to LRU.
> =C2=A08. was_unevictable=3D=3Dtrue, then, count_vm_event(UNEVICTABLE_PGRE=
SCUED);
>
> Your patch overwrites was_unevictable between 5. and 6., then,
> corrupts this event counting.
>
> about "active" flag.
>
> PageActive() flag will be set in lru_cache_add_lru() and
> there will be no inconsistency between page->flags and LRU.
> And, in what case the changes in 'active' will be problematic ?
>
Hi Kame

Thanks for reviewing my work.

With focus on the case that redo occurs, the patch was prepared based on th=
e
assumption that any isolated page could be processed by the function.

If redo does occur, though unlikely, there are two rounds of isolation+putb=
ack
or more for the given page. As shown by my workout of page status, differen=
ce
exists in the two cases.

     =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
                                     without redo           with redo
     =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
       active                      true  50%              true
                                     false 50%              false  100%
     =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
       was_unevictable       true  50%              true   100%
                                      false 50%              false
     =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

And the case with redo could be covered by the case without redo, so there =
is
no corruption of VM events.

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
