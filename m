Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 5E7226B008A
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 10:01:48 -0400 (EDT)
Received: by mail-qe0-f53.google.com with SMTP id q19so879887qeb.26
        for <linux-mm@kvack.org>; Wed, 17 Apr 2013 07:01:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <516DE3D1.7030800@gmail.com>
References: <5114DF05.7070702@mellanox.com>
	<CAH3drwbjQa2Xms30b8J_oEUw7Eikcno-7Xqf=7=da3LHWXvkKA@mail.gmail.com>
	<516CF7BB.3050301@gmail.com>
	<CAH3drwbx1aiQEA19+zq6t=GPPNZQEkD27sCjL-Ma2aYns7pMXw@mail.gmail.com>
	<516DE3D1.7030800@gmail.com>
Date: Wed, 17 Apr 2013 10:01:47 -0400
Message-ID: <CAH3drwZ=0iXJwXrZdVUngpwddsu9yj5HCdCcWJuXtz8p=sMWpA@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Hardware initiated paging of user process pages,
 hardware access to the CPU page tables of user processes
From: Jerome Glisse <j.glisse@gmail.com>
Content-Type: multipart/alternative; boundary=047d7bdc853a3d0f8d04da8eeda4
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Shachar Raindel <raindel@mellanox.com>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Roland Dreier <roland@purestorage.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Liran Liss <liranl@mellanox.com>

--047d7bdc853a3d0f8d04da8eeda4
Content-Type: text/plain; charset=ISO-8859-1

On Tue, Apr 16, 2013 at 7:50 PM, Simon Jeons <simon.jeons@gmail.com> wrote:

> On 04/17/2013 12:27 AM, Jerome Glisse wrote:
>
> [snip]
>
>
>>
>> As i said this is for pre-filling already present entry, ie pte that are
>> present with a valid page (no special bit set). This is an optimization so
>> that the GPU can pre-fill its tlb without having to take any mmap_sem. Hope
>> is that in most common case this will be enough, but in some case you will
>> have to go through the lengthy non fast gup.
>>
>
> I know this. What I concern is the pte you mentioned is for normal cpu,
> correct? How can you pre-fill pte and tlb of GPU?
>

You getting confuse, idea is to look at cpu pte and prefill gpu pte. I do
not prefill cpu pte, if a cpu pte is valid then i use the page it point to
prefill the GPU pte.

So i don't pre-fill CPU PTE and TLB GPU, i pre-fill GPU PTE from CPU PTE if
CPU PTE is valid. Other GPU PTE are marked as invalid and will trigger a
fault that will be handle using gup that will fill CPU PTE (if fault happen
at a valid address) at which point GPU PTE is updated or error is reported
if fault happened at an invalid address.

Cheers,
Jerome

--047d7bdc853a3d0f8d04da8eeda4
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div class=3D"gmail_quote">On Tue, Apr 16, 2013 at 7:50 PM, Simon Jeons <sp=
an dir=3D"ltr">&lt;<a href=3D"mailto:simon.jeons@gmail.com" target=3D"_blan=
k">simon.jeons@gmail.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmai=
l_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left=
:1ex">
On 04/17/2013 12:27 AM, Jerome Glisse wrote:<br>
<br>
[snip]<div class=3D"im"><br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
<br>
<br>
As i said this is for pre-filling already present entry, ie pte that are pr=
esent with a valid page (no special bit set). This is an optimization so th=
at the GPU can pre-fill its tlb without having to take any mmap_sem. Hope i=
s that in most common case this will be enough, but in some case you will h=
ave to go through the lengthy non fast gup.<br>

</blockquote>
<br></div>
I know this. What I concern is the pte you mentioned is for normal cpu, cor=
rect? How can you pre-fill pte and tlb of GPU?<br></blockquote></div><br>Yo=
u getting confuse, idea is to look at cpu pte and prefill gpu pte. I do not=
 prefill cpu pte, if a cpu pte is valid then i use the page it point to pre=
fill the GPU pte.<br>
<br>So i don&#39;t pre-fill CPU PTE and TLB GPU, i pre-fill GPU PTE from CP=
U PTE if CPU PTE is valid. Other GPU PTE are marked as invalid and will tri=
gger a fault that will be handle using gup that will fill CPU PTE (if fault=
 happen at a valid address) at which point GPU PTE is updated or error is r=
eported if fault happened at an invalid address.<br>
<br>Cheers,<br>Jerome<br>

--047d7bdc853a3d0f8d04da8eeda4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
