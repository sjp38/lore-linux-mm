Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 71C106B0055
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 08:05:21 -0400 (EDT)
Received: by gxk12 with SMTP id 12so5989086gxk.4
        for <linux-mm@kvack.org>; Wed, 19 Aug 2009 05:05:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090819120117.GB7306@localhost>
References: <20090816051502.GB13740@localhost>
	 <20090816112910.GA3208@localhost>
	 <20090818234310.A64B.A69D9226@jp.fujitsu.com>
	 <20090819120117.GB7306@localhost>
Date: Wed, 19 Aug 2009 21:05:19 +0900
Message-ID: <2f11576a0908190505h6da96280xf67c962aa3f5ba07@mail.gmail.com>
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Rik van Riel <riel@redhat.com>, Jeff Dike <jdike@addtoit.com>, Avi Kivity <avi@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>> page_referenced_file?
>> I think we should change page_referenced().
>
> Yeah, good catch.
>
>>
>> Instead, How about this?
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>
>> Subject: [PATCH] mm: stop circulating of referenced mlocked pages
>>
>> Currently, mlock() systemcall doesn't gurantee to mark the page PG_Mlock=
ed
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mark PG_mlocked
>
>> because some race prevent page grabbing.
>> In that case, instead vmscan move the page to unevictable lru.
>>
>> However, Recently Wu Fengguang pointed out current vmscan logic isn't so
>> efficient.
>> mlocked page can move circulatly active and inactive list because
>> vmscan check the page is referenced _before_ cull mlocked page.
>>
>> Plus, vmscan should mark PG_Mlocked when cull mlocked page.
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 PG_mlocked
>
>> Otherwise vm stastics show strange number.
>>
>> This patch does that.
>
> Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>

Thanks.



>> Index: b/mm/rmap.c
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> --- a/mm/rmap.c =A0 =A0 =A0 2009-08-18 19:48:14.000000000 +0900
>> +++ b/mm/rmap.c =A0 =A0 =A0 2009-08-18 23:47:34.000000000 +0900
>> @@ -362,7 +362,9 @@ static int page_referenced_one(struct pa
>> =A0 =A0 =A0 =A0* unevictable list.
>> =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 if (vma->vm_flags & VM_LOCKED) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 *mapcount =3D 1; =A0/* break early from loop *=
/
>> + =A0 =A0 =A0 =A0 =A0 =A0 *mapcount =3D 1; =A0 =A0 =A0 =A0 =A0/* break e=
arly from loop */
>> + =A0 =A0 =A0 =A0 =A0 =A0 *vm_flags |=3D VM_LOCKED; /* for prevent to mo=
ve active list */
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 try_set_page_mlocked(vma, page);
>
> That call is not absolutely necessary?

Why? I haven't catch your point.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
