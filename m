Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 1DAF36B004D
	for <linux-mm@kvack.org>; Sat, 31 Dec 2011 09:55:24 -0500 (EST)
Received: by werf1 with SMTP id f1so9613919wer.14
        for <linux-mm@kvack.org>; Sat, 31 Dec 2011 06:55:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4EFCA4F9.7070703@gmail.com>
References: <CAJd=RBBJG+hLLc3mR-WzByU1gZEcdFUAoZzyir+1A4a0tVnSmg@mail.gmail.com>
	<4EFCA4F9.7070703@gmail.com>
Date: Sat, 31 Dec 2011 22:55:22 +0800
Message-ID: <CAJd=RBCuh=zDLZ7J9sV_p_ghoXP-VX6PEAx01t8p_pziTimxnA@mail.gmail.com>
Subject: Re: [PATCH] mm: vmscam: check page order in isolating lru pages
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>

On Fri, Dec 30, 2011 at 1:35 AM, KOSAKI Motohiro
<kosaki.motohiro@gmail.com> wrote:
> (12/29/11 7:45 AM), Hillf Danton wrote:
>>
>> Before we try to isolate physically contiguous pages, check for page ord=
er
>> is
>> added, and if the reclaim order is no larger than page order, we should
>> give up
>> the attempt.
>>
>> Signed-off-by: Hillf Danton<dhillf@gmail.com>
>> Cc: Michal Hocko<mhocko@suse.cz>
>> Cc: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
>> Cc: Andrew Morton<akpm@linux-foundation.org>
>> Cc: David Rientjes<rientjes@google.com>
>> Cc: Hugh Dickins<hughd@google.com>
>> ---
>>
>> --- a/mm/vmscan.c =C2=A0 =C2=A0 =C2=A0 Thu Dec 29 20:20:16 2011
>> +++ b/mm/vmscan.c =C2=A0 =C2=A0 =C2=A0 Thu Dec 29 20:28:14 2011
>> @@ -1162,6 +1162,7 @@ static unsigned long isolate_lru_pages(u
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long end=
_pfn;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long pag=
e_pfn;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0int zone_id;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned int isolated=
_pages =3D 0;
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0page =3D lru_to_p=
age(src);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0prefetchw_prev_lr=
u_page(page, src, flags);
>> @@ -1172,7 +1173,7 @@ static unsigned long isolate_lru_pages(u
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0case 0:
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0mem_cgroup_lru_del(page);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0list_move(&page->lru, dst);
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 nr_taken +=3D hpage_nr_pages(page);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 isolated_pages =3D hpage_nr_pages(page);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0break;
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0case -EBUSY:
>> @@ -1184,8 +1185,11 @@ static unsigned long isolate_lru_pages(u
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0BUG();
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>>
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nr_taken +=3D isolate=
d_pages;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!order)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0continue;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (isolated_pages !=
=3D 1&& =C2=A0isolated_pages>=3D (1<< =C2=A0order))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 continue;
>
>
> strange space alignment. and I don't think we need "isolated_pages !=3D 1=
"
> check.
>
> Otherwise, Looks good to me.
>
> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>

Hi KOSAKI

It is re-prepared and please review again.
1, changelog is updated,
2, the check for page order is refined,
3, comment is also added.

Thanks
Hillf

=3D=3D=3Dcut please=3D=3D=3D
From: Hillf Danton <dhillf@gmail.com>
Subject: [PATCH] mm: vmscam: check page order in isolating lru pages

Before try to isolate physically contiguous pages, check for page order is
added, and if it is not regular page, we should give up the attempt.

Signed-off-by: Hillf Danton <dhillf@gmail.com>
Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
---

--- a/mm/vmscan.c	Thu Dec 29 20:20:16 2011
+++ b/mm/vmscan.c	Sat Dec 31 22:44:16 2011
@@ -1162,6 +1162,7 @@ static unsigned long isolate_lru_pages(u
 		unsigned long end_pfn;
 		unsigned long page_pfn;
 		int zone_id;
+		unsigned int isolated_pages =3D 1;

 		page =3D lru_to_page(src);
 		prefetchw_prev_lru_page(page, src, flags);
@@ -1172,7 +1173,7 @@ static unsigned long isolate_lru_pages(u
 		case 0:
 			mem_cgroup_lru_del(page);
 			list_move(&page->lru, dst);
-			nr_taken +=3D hpage_nr_pages(page);
+			isolated_pages =3D hpage_nr_pages(page);
 			break;

 		case -EBUSY:
@@ -1184,8 +1185,12 @@ static unsigned long isolate_lru_pages(u
 			BUG();
 		}

+		nr_taken +=3D isolated_pages;
 		if (!order)
 			continue;
+		/* try pfn-based isolation only for regular page */
+		if (isolated_pages !=3D 1)
+			continue;

 		/*
 		 * Attempt to take all pages in the order aligned region
@@ -1227,7 +1232,6 @@ static unsigned long isolate_lru_pages(u
 				break;

 			if (__isolate_lru_page(cursor_page, mode, file) =3D=3D 0) {
-				unsigned int isolated_pages;

 				mem_cgroup_lru_del(cursor_page);
 				list_move(&cursor_page->lru, dst);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
