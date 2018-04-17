Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 81AD16B0007
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 16:09:41 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id l19so5139232qkk.11
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 13:09:41 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z33sor2579062qtc.106.2018.04.17.13.09.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Apr 2018 13:09:37 -0700 (PDT)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [RFC PATCH] mm: correct status code which move_pages() returns
 for zero page
Date: Tue, 17 Apr 2018 16:09:33 -0400
Message-ID: <7674C632-FE3E-42D2-B19D-32F531617043@cs.rutgers.edu>
In-Reply-To: <20180417190044.GK17484@dhcp22.suse.cz>
References: <20180417110615.16043-1-liwang@redhat.com>
 <20180417130300.GF17484@dhcp22.suse.cz>
 <20180417141442.GG17484@dhcp22.suse.cz>
 <CAEemH2dQ+yQ-P-=5J3Y-n+0V0XV-vJkQ81uD=Q3Bh+rHZ4sb-Q@mail.gmail.com>
 <20180417190044.GK17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_11D6B842-A228-4D0A-9E50-49653C9AC952_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, Li Wang <liwang@redhat.com>
Cc: linux-mm@kvack.org, ltp@lists.linux.it, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_11D6B842-A228-4D0A-9E50-49653C9AC952_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 17 Apr 2018, at 15:00, Michal Hocko wrote:

> On Tue 17-04-18 22:28:33, Li Wang wrote:
>> On Tue, Apr 17, 2018 at 10:14 PM, Michal Hocko <mhocko@suse.com> wrote=
:
>>
>>> On Tue 17-04-18 15:03:00, Michal Hocko wrote:
>>>> On Tue 17-04-18 19:06:15, Li Wang wrote:
>>>> [...]
>>>>> diff --git a/mm/migrate.c b/mm/migrate.c
>>>>> index f65dd69..2b315fc 100644
>>>>> --- a/mm/migrate.c
>>>>> +++ b/mm/migrate.c
>>>>> @@ -1608,7 +1608,7 @@ static int do_pages_move(struct mm_struct *mm=
,
>>> nodemask_t task_nodes,
>>>>>                     continue;
>>>>>
>>>>>             err =3D store_status(status, i, err, 1);
>>>>> -           if (err)
>>>>> +           if (!err)
>>>>>                     goto out_flush;
>>>>
>>>> This change just doesn't make any sense to me. Why should we bail ou=
t if
>>>> the store_status is successul? I am trying to wrap my head around th=
e
>>>> test case. 6b9d757ecafc ("mm, numa: rework do_pages_move") tried to
>>>> explain that move_pages has some semantic issues and the new
>>>> implementation might be not 100% replacement. Anyway I am studying t=
he
>>>> test case to come up with a proper fix.
>>>
>>> OK, I get what the test cases does. I've failed to see the subtle
>>> difference between alloc_pages_on_node and numa_alloc_onnode. The lat=
er
>>> doesn't faul in anything.
>>>
>>> Why are we getting EPERM is quite not yet clear to me.
>>> add_page_for_migration uses FOLL_DUMP which should return EFAULT on
>>> zero pages (no_page_table()).
>>>
>>>         err =3D PTR_ERR(page);
>>>         if (IS_ERR(page))
>>>                 goto out;
>>>
>>> therefore bails out from add_page_for_migration and store_status shou=
ld
>>> store that value. There shouldn't be any EPERM on the way.
>>>
>>
>> Yes, I print the the return value and confirmed the
>> add_page_for_migration()=E2=80=8B
>> do right things for zero page. and after store_status(...) the status =
saves
>> -EFAULT.
>> So I did the change above.
>
> OK, I guess I knnow what is going on. I must be overwriting the status
> on the way out by
>
> out_flush:
> 	/* Make sure we do not overwrite the existing error */
> 	err1 =3D do_move_pages_to_node(mm, &pagelist, current_node);
> 	if (!err1)
> 		err1 =3D store_status(status, start, current_node, i - start);
>
> This error handling is rather fragile and I was quite unhappy about it
> at the time I was developing it. I have to remember all the details why=

> I've done it that way but I would bet my hat this is it. More on this
> tomorrow.

Hi Michal and Li,

The problem is that the variable start is not set properly after store_st=
atus(),
like the "start =3D i;" after the first store_status().

The following patch should fix the problem (it has passed all move_pages =
test cases from ltp
on my machine):

diff --git a/mm/migrate.c b/mm/migrate.c
index f65dd69e1fd1..32afa4723e7f 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1619,6 +1619,8 @@ static int do_pages_move(struct mm_struct *mm, node=
mask_t task_nodes,
                        if (err)
                                goto out;
                }
+               /* Move to next page (i+1), after we have saved page stat=
us (until i) */
+               start =3D i + 1;
                current_node =3D NUMA_NO_NODE;
        }
 out_flush:

Feel free to check it by yourselves.

--
Best Regards
Yan Zi

--=_MailMate_11D6B842-A228-4D0A-9E50-49653C9AC952_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJa1lR9AAoJEEGLLxGcTqbMH7UH/0tudc/H5vo/m4c1MaTPSW//
59cd04hThTGtEPnExT1R8NEk9T2h2JUG8rmxPMJC4/cBmLjXxcn5XAMcMD0o3H8f
I0xUytZqMflYy9/wM9haeIJtEbUomxtxOi1g8sEZB8UwnCg9kSPsJZs3oufPw7bM
WnvgZECHr4UyPraFWzYR+y/JAuW8tjh9sucPhlkgKwIX82WxYlbwcV5v1mmC2/bI
ojfgm2/VmXi5IPw7EkMS0KDY+nc6N4gNiFaygt2Zq06FQEkhXW9JDUj8mRotGiGV
26xWZLc69QeJx7W8bTI/QNeClkxsArXrmFkAAYL5CV4JqMxytsT+AU0PBX1dyVU=
=i43Q
-----END PGP SIGNATURE-----

--=_MailMate_11D6B842-A228-4D0A-9E50-49653C9AC952_=--
