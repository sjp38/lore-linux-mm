Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5F926440874
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 16:37:04 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id r126so24091548vkg.9
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 13:37:04 -0700 (PDT)
Received: from mail-ua0-x230.google.com (mail-ua0-x230.google.com. [2607:f8b0:400c:c08::230])
        by mx.google.com with ESMTPS id e68si2521311vkg.272.2017.07.13.13.37.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jul 2017 13:37:03 -0700 (PDT)
Received: by mail-ua0-x230.google.com with SMTP id z22so41003997uah.1
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 13:37:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170713163437.GA4469@bombadil.infradead.org>
References: <CAE=wTWYU8F5KDrC9VSxrtckVZ2xmvxy8owxCkZUcY4KXEiz0Og@mail.gmail.com>
 <20170713163437.GA4469@bombadil.infradead.org>
From: Vasilis Dimitsas <vdimitsas@gmail.com>
Date: Thu, 13 Jul 2017 23:36:22 +0300
Message-ID: <CAE=wTWZqwxJqb5v_BBpt97J2YxOGsQd86Nv6E5v6=GJetyE=KQ@mail.gmail.com>
Subject: Re: asynchronous readahead prefetcher operation
Content-Type: multipart/alternative; boundary="f403045dcb962abf5d055438e5df"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org

--f403045dcb962abf5d055438e5df
Content-Type: text/plain; charset="UTF-8"

Hello Matthew,

Thank you for your response. Since at user level I am using the pread()
function, in kernel level, unless I am making a mistake, the
do_generic_file_read() is being called. Inside this, the find_get_page() is
called and if the page is not in the page cache then
page_cache_sync_readahead() is called or page_cache_async_readahead() if
the page is marked with the PG_readahead flag. So, I would like to find in
which exact part of the code can someone understand that the I/O is not
waited for.

Thank you again,

Vasilis

On Thu, Jul 13, 2017 at 7:34 PM, Matthew Wilcox <willy@infradead.org> wrote:

> On Wed, Jul 12, 2017 at 11:31:21PM +0300, Vasilis Dimitsas wrote:
> > I am currently working on a project which is related to the operation of
> > the linux readahead prefetcher. As a result, I am trying to understand
> its
> > operation. Having read thoroughly the relevant part in the kernel code, I
> > realize, from the comments, that part of the prefetching occurs
> > asynchronously. The problem is that I can not verify this from the code.
> >
> > Even if you call page_cache_sync_readahead() or
> > page_cache_async_readahead(), then both will end up in ra_submit(), in
> > which, the operation is common for both cases.
> >
> > So, please could you tell me at which point does the operation of
> > prefetching occurs asynchronously?
>
> The prefetching operation always occurs asynchronously; the
> I/O is submitted and then both page_cache_sync_readahead() and
> page_cache_async_readahead() return to the caller.  They use slightly
> different algorithms, which is why they're different functions, but the
> I/O is not waited for.  It's up to the caller to do that.
>
> I imagine you're looking at filemap_fault(), and it happens like this:
>
>         page = find_get_page(mapping, offset);
> (returns NULL because there's no page in the cache)
>                 do_sync_mmap_readahead(vmf->vma, ra, file, offset);
> (will create pages and put them in the page cache, taking PageLock on each
> page)
>                 page = find_get_page(mapping, offset);
> (finds the page that was just created)
>         if (!lock_page_or_retry(page, vmf->vma->vm_mm, vmf->flags)) {
> (will attempt to lock the page ... if it's locked and the fault lets us
> retry,
> fails so we can handle retries at the higher level.  If it's locked and the
> fault says we can't retry, then sleeps until unlocked.  If/once it's
> unlocked,
> will return success)
>
> When the I/O completes, the page will be unlocked, usually by calling
> page_endio().
>

--f403045dcb962abf5d055438e5df
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hello Matthew,<div><br></div><div>Thank you for your respo=
nse. Since at user level I am using the pread() function, in kernel level, =
unless I am making a mistake, the do_generic_file_read() is being called. I=
nside this, the find_get_page() is called and if the page is not in the pag=
e cache then page_cache_sync_readahead() is called or page_cache_async_read=
ahead() if the page is marked with the PG_readahead flag. So, I would like =
to find in which exact part of the code can someone understand that the I/O=
 is not waited for.</div><div><br></div><div>Thank you again,</div><div><br=
></div><div>Vasilis</div></div><div class=3D"gmail_extra"><br><div class=3D=
"gmail_quote">On Thu, Jul 13, 2017 at 7:34 PM, Matthew Wilcox <span dir=3D"=
ltr">&lt;<a href=3D"mailto:willy@infradead.org" target=3D"_blank">willy@inf=
radead.org</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=
=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"><span cl=
ass=3D"">On Wed, Jul 12, 2017 at 11:31:21PM +0300, Vasilis Dimitsas wrote:<=
br>
&gt; I am currently working on a project which is related to the operation =
of<br>
&gt; the linux readahead prefetcher. As a result, I am trying to understand=
 its<br>
&gt; operation. Having read thoroughly the relevant part in the kernel code=
, I<br>
&gt; realize, from the comments, that part of the prefetching occurs<br>
&gt; asynchronously. The problem is that I can not verify this from the cod=
e.<br>
&gt;<br>
&gt; Even if you call page_cache_sync_readahead() or<br>
&gt; page_cache_async_readahead(), then both will end up in ra_submit(), in=
<br>
&gt; which, the operation is common for both cases.<br>
&gt;<br>
&gt; So, please could you tell me at which point does the operation of<br>
&gt; prefetching occurs asynchronously?<br>
<br>
</span>The prefetching operation always occurs asynchronously; the<br>
I/O is submitted and then both page_cache_sync_readahead() and<br>
page_cache_async_readahead() return to the caller.=C2=A0 They use slightly<=
br>
different algorithms, which is why they&#39;re different functions, but the=
<br>
I/O is not waited for.=C2=A0 It&#39;s up to the caller to do that.<br>
<br>
I imagine you&#39;re looking at filemap_fault(), and it happens like this:<=
br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 page =3D find_get_page(mapping, offset);<br>
(returns NULL because there&#39;s no page in the cache)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 do_sync_mmap_readah=
ead(vmf-&gt;<wbr>vma, ra, file, offset);<br>
(will create pages and put them in the page cache, taking PageLock on each =
page)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page =3D find_get_p=
age(mapping, offset);<br>
(finds the page that was just created)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!lock_page_or_retry(page, vmf-&gt;vma-&gt;v=
m_mm, vmf-&gt;flags)) {<br>
(will attempt to lock the page ... if it&#39;s locked and the fault lets us=
 retry,<br>
fails so we can handle retries at the higher level.=C2=A0 If it&#39;s locke=
d and the<br>
fault says we can&#39;t retry, then sleeps until unlocked.=C2=A0 If/once it=
&#39;s unlocked,<br>
will return success)<br>
<br>
When the I/O completes, the page will be unlocked, usually by calling<br>
page_endio().<br>
</blockquote></div><br></div>

--f403045dcb962abf5d055438e5df--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
