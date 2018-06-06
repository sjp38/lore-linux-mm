Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 05EDF6B0005
	for <linux-mm@kvack.org>; Wed,  6 Jun 2018 09:28:14 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id k18-v6so709864itb.0
        for <linux-mm@kvack.org>; Wed, 06 Jun 2018 06:28:14 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j1-v6sor7575505iob.117.2018.06.06.06.28.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Jun 2018 06:28:12 -0700 (PDT)
MIME-Version: 1.0
References: <CAJ6kbHezPzbLW=1mwdnywMn639X4eLz9nnRZdk6oeyLjXR6mQg@mail.gmail.com>
 <20180606124322.GB32498@dhcp22.suse.cz>
In-Reply-To: <20180606124322.GB32498@dhcp22.suse.cz>
From: Rafael Telles <rafaelt@simbioseventures.com>
Date: Wed, 6 Jun 2018 10:28:00 -0300
Message-ID: <CAJ6kbHdz-UWL6dBdBZy9WFV6QBYqmMNEuUm+5s9LQok_RLDZfg@mail.gmail.com>
Subject: Re: Memory mapped pages not being swapped out
Content-Type: multipart/alternative; boundary="00000000000069bb4d056df923fe"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

--00000000000069bb4d056df923fe
Content-Type: text/plain; charset="UTF-8"

Thank you so much for your attention Michal,

Are there any settings (such as sysctl parameters) that I can use to better
control the memory reclaiming? Such as: defining the max. amount of mmap
pages allocated or max. amount of memory used by mmap pages?

Or will the system start reclaiming only when it needs more memory?

I found that I could use madvise with MADV_DONTNEED in order to actively
free RSS memory used by mmap pages, but it would add more complexity on my
software.

On Wed, Jun 6, 2018 at 9:43 AM Michal Hocko <mhocko@kernel.org> wrote:

> On Tue 05-06-18 16:14:02, Rafael Telles wrote:
> > Hi there, I am running a program where I need to map hundreds of
> thousands
> > of files and each file has several kilobytes (min. of 4kb per file). The
> > program calls mmap() for every 4096 bytes on each file, ending up with
> > millions of memory mapped pages, so I have ceil(N/4096) pages for each
> > file, where N is the file size.
> >
> > As the program runs, more files are created and the older files get
> bigger,
> > then I need to remap those pages, so it's always adding more pages.
> >
> > I am concerned about when and how Linux is going to swap out pages in
> order
> > to get more memory, the program seems to only increase memory usage
> overall
> > and I am afraid it runs out of memory.
>
> We definitely do reclaim mmaped memory - be it a page cache or anonymous
> memory. The code doing that is mostly in shrink_page_list (resp.
> page_check_references for aging decisions) - somehow non-trivial to
> follow but you know where to start looking at least ;)
>
> > I tried setting these sysctl parameters so it would swap out as soon as
> > possible (just to understand how Linux memory management works), but it
> > didn't change anything:
> >
> > vm.zone_reclaim_mode = 1
>
> This will make difference only for NUMA machines and it will try to
> keep allocations to local nodes. It can lead to a more extensive
> reclaim but I would definitely not recommend setting it up unless you
> want a strong NUMA locality payed by reclaiming more while the rest of
> the memory might be sitting idle.
>
>
> > vm.min_unmapped_ratio = 99
>
> This one is active only for the zone/node reclaim and tells whether to
> reclaim the specific node based on how much of memory is mapped. Your
> setting would tell that the node is not worth to be reclaimed unless 99%
> of it is clean page cache (the behavior depends on the zone_reclaim_mode
> because zone_reclaim_mode = 1 excludes mapped pages AFAIR).
>
> So this will most likely not do what you think.
>
> > How can I be sure the program won't run out of memory?
>
> The default overcommit setting should not allow you to mmap too much in
> many cases.
>
> > Do I have to manually unmap pages to free memory?
>
> No.
> --
> Michal Hocko
> SUSE Labs
>

--00000000000069bb4d056df923fe
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Thank you so much for your attention Michal,<div><br></div=
><div>Are there any settings (such as sysctl parameters) that I can use to =
better control the memory reclaiming? Such as: defining the max. amount of =
mmap pages allocated or max. amount of memory used by mmap pages?</div><div=
><br></div><div>Or will the system start reclaiming only when it needs more=
 memory?</div><div><br></div><div>I found that I could use madvise with MAD=
V_DONTNEED in order to actively free RSS memory used by mmap pages, but it =
would add more complexity on my software.</div></div><br><div class=3D"gmai=
l_quote"><div dir=3D"ltr">On Wed, Jun 6, 2018 at 9:43 AM Michal Hocko &lt;<=
a href=3D"mailto:mhocko@kernel.org">mhocko@kernel.org</a>&gt; wrote:<br></d=
iv><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left=
:1px #ccc solid;padding-left:1ex">On Tue 05-06-18 16:14:02, Rafael Telles w=
rote:<br>
&gt; Hi there, I am running a program where I need to map hundreds of thous=
ands<br>
&gt; of files and each file has several kilobytes (min. of 4kb per file). T=
he<br>
&gt; program calls mmap() for every 4096 bytes on each file, ending up with=
<br>
&gt; millions of memory mapped pages, so I have ceil(N/4096) pages for each=
<br>
&gt; file, where N is the file size.<br>
&gt; <br>
&gt; As the program runs, more files are created and the older files get bi=
gger,<br>
&gt; then I need to remap those pages, so it&#39;s always adding more pages=
.<br>
&gt; <br>
&gt; I am concerned about when and how Linux is going to swap out pages in =
order<br>
&gt; to get more memory, the program seems to only increase memory usage ov=
erall<br>
&gt; and I am afraid it runs out of memory.<br>
<br>
We definitely do reclaim mmaped memory - be it a page cache or anonymous<br=
>
memory. The code doing that is mostly in shrink_page_list (resp.<br>
page_check_references for aging decisions) - somehow non-trivial to<br>
follow but you know where to start looking at least ;)<br>
<br>
&gt; I tried setting these sysctl parameters so it would swap out as soon a=
s<br>
&gt; possible (just to understand how Linux memory management works), but i=
t<br>
&gt; didn&#39;t change anything:<br>
&gt; <br>
&gt; vm.zone_reclaim_mode =3D 1<br>
<br>
This will make difference only for NUMA machines and it will try to<br>
keep allocations to local nodes. It can lead to a more extensive<br>
reclaim but I would definitely not recommend setting it up unless you<br>
want a strong NUMA locality payed by reclaiming more while the rest of<br>
the memory might be sitting idle.<br>
<br>
<br>
&gt; vm.min_unmapped_ratio =3D 99<br>
<br>
This one is active only for the zone/node reclaim and tells whether to<br>
reclaim the specific node based on how much of memory is mapped. Your<br>
setting would tell that the node is not worth to be reclaimed unless 99%<br=
>
of it is clean page cache (the behavior depends on the zone_reclaim_mode<br=
>
because zone_reclaim_mode =3D 1 excludes mapped pages AFAIR).<br>
<br>
So this will most likely not do what you think.<br>
<br>
&gt; How can I be sure the program won&#39;t run out of memory?<br>
<br>
The default overcommit setting should not allow you to mmap too much in<br>
many cases.<br>
<br>
&gt; Do I have to manually unmap pages to free memory?<br>
<br>
No.<br>
-- <br>
Michal Hocko<br>
SUSE Labs<br>
</blockquote></div>

--00000000000069bb4d056df923fe--
