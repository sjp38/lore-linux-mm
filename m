Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B77956B004F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 08:21:37 -0400 (EDT)
Received: by an-out-0708.google.com with SMTP id c3so1723353ana.26
        for <linux-mm@kvack.org>; Wed, 16 Sep 2009 05:21:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090915122632.GC31840@csn.ul.ie>
References: <202cde0e0909132218k70c31a5u922636914e603ad4@mail.gmail.com>
	 <20090915122632.GC31840@csn.ul.ie>
Date: Thu, 17 Sep 2009 00:21:42 +1200
Message-ID: <202cde0e0909160521v41a0d9f2wb1e4fe1e379e8971@mail.gmail.com>
Subject: Re: [PATCH 2/3] Helper which returns the huge page at a given address
	(Take 3)
From: Alexey Korolev <akorolex@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Eric Munson <linux-mm@mgebm.net>, Alexey Korolev <akorolev@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 16, 2009 at 12:26 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Mon, Sep 14, 2009 at 05:18:53PM +1200, Alexey Korolev wrote:
>> This patch provides helper function which returns the huge page at a
>> given address for population before the page has been faulted.
>> It is possible to call hugetlb_get_user_page function in file mmap
>> procedure to get pages before they have been requested by user level.
>>
>
> Worth spelling out that this is similar in principal to get_user_pages()
> but not as painful to use in this specific context.
>

Right. I'll do this. Seems it is important to clearly mention that
this function do not introduce new functionality.

>> include/linux/hugetlb.h | =C2=A0 =C2=A03 +++
>> mm/hugetlb.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 23 ++++++=
+++++++++++++++++
>> 2 files changed, 26 insertions(+)
>>
>> ---
>> Signed-off-by: Alexey Korolev <akorolev@infradead.org>
>
> Patch formatting nit.
>
> diffstat goes below the --- and signed-off-bys go above it.
>
Right. To be fixed.

>>
>> +/*
>> + * hugetlb_get_user_page returns the page at a given address for popula=
tion
>> + * before the page has been faulted.
>> + */
>> +struct page *hugetlb_get_user_page(struct vm_area_struct *vma,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long address)
>> +{
>
> Your leader and comments say that the function can be used before the pag=
es
> have been faulted. It would presumably require that this function be call=
ed
> from within a mmap() handler.
>
> What is happening because you call follow_hugetlb_page() is that the page=
s
> get faulted as part of your mmap() operation. This might make the overall
> operation more expensive than you expected. I don't know if what you real=
ly
> intended was to allocate the huge page, insert it into the page cache and
> have it faulted later if the process actually references the page.
>
> Similarly the leader and comments imply that you expect this to be
> called as part of the mmap() operation. However, nothing would appear to
> prevent the driver calling this function once the page is already
> faulted. Is this intentional?

The implication was not intende. You are correct, the function can be
called later. The leader and comment can be rewritten to make this
clear.

>> + =C2=A0 =C2=A0 int ret;
>> + =C2=A0 =C2=A0 int cnt =3D 1;
>> + =C2=A0 =C2=A0 struct page *pg;
>> + =C2=A0 =C2=A0 struct hstate *h =3D hstate_vma(vma);
>> +
>> + =C2=A0 =C2=A0 address =3D address & huge_page_mask(h);
>> + =C2=A0 =C2=A0 ret =3D follow_hugetlb_page(vma->vm_mm, vma, &pg,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 NULL, &address, &cnt, 0, 0);
>> + =C2=A0 =C2=A0 if (ret < 0)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return ERR_PTR(ret);
>> + =C2=A0 =C2=A0 put_page(pg);
>> +
>> + =C2=A0 =C2=A0 return pg;
>> +}
>
> I think the caller should be responsible for calling put_page(). =C2=A0Ot=
herwise
> there is an outside chance that the page would disappear from you unexpec=
tedly
> depending on exactly how the driver was implemented. It would also
> behave slightly more like get_user_pages().
>
Correct. Lets have behaviour similar to get_user_pages in order to prevent
misunderstanding. Put_page will be removed.

Thank you very much for review. Now I am about to clear out the
mistakes and will pay a lot more attention to patch descriptions and
comments.

Thanks,
Alexey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
