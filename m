Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 587856B00DC
	for <linux-mm@kvack.org>; Wed, 23 Oct 2013 18:14:12 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id un1so1597413pbc.5
        for <linux-mm@kvack.org>; Wed, 23 Oct 2013 15:14:12 -0700 (PDT)
Received: from psmtp.com ([74.125.245.129])
        by mx.google.com with SMTP id ar2si3169428pbc.292.2013.10.23.15.14.10
        for <linux-mm@kvack.org>;
        Wed, 23 Oct 2013 15:14:11 -0700 (PDT)
Received: by mail-ie0-f169.google.com with SMTP id ar20so2470994iec.14
        for <linux-mm@kvack.org>; Wed, 23 Oct 2013 15:14:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <526844E6.1080307@codeaurora.org>
References: <526844E6.1080307@codeaurora.org>
Date: Wed, 23 Oct 2013 15:14:09 -0700
Message-ID: <CAA25o9TqiwOOxhez176Bv=FS6pDQ6+D3FjB1jzKzpnZ8YjNkMg@mail.gmail.com>
Subject: Re: zram/zsmalloc issues in very low memory conditions
From: Luigi Semenzato <semenzato@google.com>
Content-Type: multipart/alternative; boundary=089e013cc02815efb004e96fd6d6
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Olav Haugan <ohaugan@codeaurora.org>
Cc: Minchan Kim <minchan@kernel.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

--089e013cc02815efb004e96fd6d6
Content-Type: text/plain; charset=ISO-8859-1

On Wed, Oct 23, 2013 at 2:51 PM, Olav Haugan <ohaugan@codeaurora.org> wrote:

> I am trying to use zram in very low memory conditions and I am having
> some issues. zram is in the reclaim path. So if the system is very low
> on memory the system is trying to reclaim pages by swapping out (in this
> case to zram). However, since we are very low on memory zram fails to
> get a page from zsmalloc and thus zram fails to store the page. We get
> into a cycle where the system is low on memory so it tries to swap out
> to get more memory but swap out fails because there is not enough memory
> in the system! The major problem I am seeing is that there does not seem
> to be a way for zram to tell the upper layers to stop swapping out
> because the swap device is essentially "full" (since there is no more
> memory available for zram pages). Has anyone thought about this issue
> already and have ideas how to solve this or am I missing something and I
> should not be seeing this issue?


What do you want the system to do at this point?  OOM kill?  Also, if you
are that low on memory, how are you preventing thrashing on the code pages?

I am asking because we also use zram but haven't run into this
problem---however we had to deal with other problems that motivate these
questions.


>
> I am also seeing a couple other issues that I was wondering whether
> folks have already thought about:
>
> 1) The size of a swap device is statically computed when the swap device
> is turned on (nr_swap_pages). The size of zram swap device is dynamic
> since we are compressing the pages and thus the swap subsystem thinks
> that the zram swap device is full when it is not really full. Any
> plans/thoughts about the possibility of being able to update the size
> and/or the # of available pages in a swap device on the fly?
>

That is a known limitation of zram.  If can predict your compression ratio
and your working set size, it's not a big problem: allocate a swap device
which, based on the expected compression ratio, will use up RAM until
what's left is just enough for the working set.


>
> 2) zsmalloc fails when the page allocated is at physical address 0 (pfn
> = 0) since the handle returned from zsmalloc is encoded as (<PFN>,
> <obj_idx>) and thus the resulting handle will be 0 (since obj_idx starts
> at 0). zs_malloc returns the handle but does not distinguish between a
> valid handle of 0 and a failure to allocate. A possible solution to this
> would be to start the obj_idx at 1. Is this feasible?
>

Sorry, no idea on this.  Probably Minchan can reply.


>
> Thanks,
>
> Olav Haugan
>
> --
> The Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
> hosted by The Linux Foundation
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--089e013cc02815efb004e96fd6d6
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><br><div class=3D"gmail=
_quote">On Wed, Oct 23, 2013 at 2:51 PM, Olav Haugan <span dir=3D"ltr">&lt;=
<a href=3D"mailto:ohaugan@codeaurora.org" target=3D"_blank">ohaugan@codeaur=
ora.org</a>&gt;</span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">I am trying to use zram in very low memory c=
onditions and I am having<br>
some issues. zram is in the reclaim path. So if the system is very low<br>
on memory the system is trying to reclaim pages by swapping out (in this<br=
>
case to zram). However, since we are very low on memory zram fails to<br>
get a page from zsmalloc and thus zram fails to store the page. We get<br>
into a cycle where the system is low on memory so it tries to swap out<br>
to get more memory but swap out fails because there is not enough memory<br=
>
in the system! The major problem I am seeing is that there does not seem<br=
>
to be a way for zram to tell the upper layers to stop swapping out<br>
because the swap device is essentially &quot;full&quot; (since there is no =
more<br>
memory available for zram pages). Has anyone thought about this issue<br>
already and have ideas how to solve this or am I missing something and I<br=
>
should not be seeing this issue?</blockquote><div><br></div><div>What do yo=
u want the system to do at this point? =A0OOM kill? =A0Also, if you are tha=
t low on memory, how are you preventing thrashing on the code pages?</div>
<div><br></div><div>I am asking because we also use zram but haven&#39;t ru=
n into this problem---however we had to deal with other problems that motiv=
ate these questions.=A0</div><div>=A0</div><blockquote class=3D"gmail_quote=
" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">

<br>
I am also seeing a couple other issues that I was wondering whether<br>
folks have already thought about:<br>
<br>
1) The size of a swap device is statically computed when the swap device<br=
>
is turned on (nr_swap_pages). The size of zram swap device is dynamic<br>
since we are compressing the pages and thus the swap subsystem thinks<br>
that the zram swap device is full when it is not really full. Any<br>
plans/thoughts about the possibility of being able to update the size<br>
and/or the # of available pages in a swap device on the fly?<br></blockquot=
e><div><br></div><div>That is a known limitation of zram. =A0If can predict=
 your compression ratio and your working set size, it&#39;s not a big probl=
em: allocate a swap device which, based on the expected compression ratio, =
will use up RAM until what&#39;s left is just enough for the working set.</=
div>
<div>=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;=
border-left:1px #ccc solid;padding-left:1ex">
<br>
2) zsmalloc fails when the page allocated is at physical address 0 (pfn<br>
=3D 0) since the handle returned from zsmalloc is encoded as (&lt;PFN&gt;,<=
br>
&lt;obj_idx&gt;) and thus the resulting handle will be 0 (since obj_idx sta=
rts<br>
at 0). zs_malloc returns the handle but does not distinguish between a<br>
valid handle of 0 and a failure to allocate. A possible solution to this<br=
>
would be to start the obj_idx at 1. Is this feasible?<br></blockquote><div>=
<br></div><div>Sorry, no idea on this. =A0Probably Minchan can reply.</div>=
<div>=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;=
border-left:1px #ccc solid;padding-left:1ex">

<br>
Thanks,<br>
<br>
Olav Haugan<br>
<span class=3D"HOEnZb"><font color=3D"#888888"><br>
--<br>
The Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,<br>
hosted by The Linux Foundation<br>
<br>
--<br>
To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39; in<br>
the body to <a href=3D"mailto:majordomo@kvack.org">majordomo@kvack.org</a>.=
 =A0For more info on Linux MM,<br>
see: <a href=3D"http://www.linux-mm.org/" target=3D"_blank">http://www.linu=
x-mm.org/</a> .<br>
Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont@kvack.org=
">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org">email@kva=
ck.org</a> &lt;/a&gt;<br>
</font></span></blockquote></div><br></div></div>

--089e013cc02815efb004e96fd6d6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
