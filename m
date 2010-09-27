Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D6A846B004A
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 02:44:59 -0400 (EDT)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <m1sk0x9z62.fsf@fess.ebiederm.org>
	<m1iq1t9z3y.fsf@fess.ebiederm.org>
	<AANLkTin4DKGhcZ4=os1-NxrQ65pEDZ+USG1xpW54y4_T@mail.gmail.com>
	<AANLkTinHGKK-14jq=D__+Q20egPw07qFHg6iQo+aFC9R@mail.gmail.com>
Date: Sun, 26 Sep 2010 23:44:50 -0700
In-Reply-To: <AANLkTinHGKK-14jq=D__+Q20egPw07qFHg6iQo+aFC9R@mail.gmail.com>
	(Pekka Enberg's message of "Mon, 27 Sep 2010 09:39:46 +0300")
Message-ID: <m1zkv37kil.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCH 2/3] mm: Consolidate vma destruction into remove_vma.
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

Pekka Enberg <penberg@kernel.org> writes:

> (Fixing Hugh's email address.)

Sorry about that somehow a typo crept it.

> On Mon, Sep 27, 2010 at 9:37 AM, Pekka Enberg <penberg@kernel.org> wrote:
>> Hi Eric,
>>
>> On Sun, Sep 26, 2010 at 2:34 AM, Eric W. Biederman
>> <ebiederm@xmission.com> wrote:
>>> Consolidate vma destruction in remove_vma. =C2=A0 This is slightly
>>> better for code size and for code maintenance. =C2=A0Avoiding the pain
>>> of 3 copies of everything needed to tear down a vma.
>>>
>>> Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
>>> ---
>>> =C2=A0mm/mmap.c | =C2=A0 21 +++++----------------
>>> =C2=A01 files changed, 5 insertions(+), 16 deletions(-)
>>>
>>> diff --git a/mm/mmap.c b/mm/mmap.c
>>> index 6128dc8..17dd003 100644
>>> --- a/mm/mmap.c
>>> +++ b/mm/mmap.c
>>> @@ -643,16 +643,10 @@ again: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0remove_next =3D 1 + (end > next->vm_end);
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock(&map=
ping->i_mmap_lock);
>>>
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (remove_next) {
>>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (file) {
>>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 fput(file);
>>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 if (next->vm_flags & VM_EXECUTABLE)
>>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 removed_exe_file_vma(mm);
>>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (next->anon_v=
ma)
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0anon_vma_merge(vma, next);
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 remove_vma(next);
>>
>> remove_vma() does vma->vm_ops->close() but we don't do that here. Are
>> you sure the conversion is safe?

Definitely.  It actually isn't possible to reach that point with a
vma that has a close method.

Until I had traced through all of the code paths I suspect calling
remove_vma there might have been a bug fix.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
