Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id 55DB96B0255
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 10:22:33 -0500 (EST)
Received: by lbbcs9 with SMTP id cs9so72130757lbb.1
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 07:22:32 -0800 (PST)
Received: from mail-lb0-x235.google.com (mail-lb0-x235.google.com. [2a00:1450:4010:c04::235])
        by mx.google.com with ESMTPS id zm8si10705079lbb.100.2015.12.11.07.22.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Dec 2015 07:22:31 -0800 (PST)
Received: by lbbcs9 with SMTP id cs9so72130383lbb.1
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 07:22:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAF6XsOeYWvuNm=uuMCM4YD4a2dCoBe6TvimygPKRe4PMiHwQmw@mail.gmail.com>
References: <CAF6XsOeYWvuNm=uuMCM4YD4a2dCoBe6TvimygPKRe4PMiHwQmw@mail.gmail.com>
Date: Fri, 11 Dec 2015 15:22:31 +0000
Message-ID: <CAF6XsOesbGN=rH0g_2JXMeyovbVPyKYvPQ-jgoVbh8cZkhyFiA@mail.gmail.com>
Subject: Re: Page Cache Monitoring ( Hit/Miss )
From: Allan McAleavy <allan.mcaleavy@gmail.com>
Content-Type: multipart/alternative; boundary=001a11349980597d030526a0e4c3
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--001a11349980597d030526a0e4c3
Content-Type: text/plain; charset=UTF-8

We add a page to the page cache using add_to_page_cache_lru based on the
following assumptions

READ MISS - So add an entry
no_cached_page - so we need to create one from
do_generic_file_read - during a file read operation
page_cache_read - calls add_to_page_cache_lru

CREATE A PAGE
struct page *__page_cache_alloc(gfp_t gfp)

page has flags which identify if dirty or free

Writes
add_to_page_cache
writepage / writepages
set_page_dirty_buffers
do_generic_mapping_read  - ASYNC read of pages in readahed?
__block_write_full_page

READ
find_get_pages


mark_page_accessed() for measuring cache accesses
mark_buffer_dirty() for measuring cache writes
add_to_page_cache_lru() for measuring page additions
account_page_dirtied() for measuring page dirties


 (mark_page_accessed - mark_buffer_dirty) & misses = (add_to_page_cache_lru
- account_page_dirtied),
 from this I then work out the hit ratio etc. Is there any other key
functions I should be tracing?

add_to_page_cache_lru
lru_cache_add
swap.c
filemap.c
vmscan.c

Functions used
lru_cache_add_active_or_unevictable
add_to_page_cache_lru
putback_lru_page

So best use lru_cache_add for additions.

account_page_dirtied() for measuring page dirties
set_page_dirty - calls above
__set_page_dirty_nobuffers - calls above also

mark_buffer_dirty() for measuring cache writes - this calls
__set_page_dirty ( are we getting twice the calls here? )
mark_page_accessed - calls SetPageActive

On Thu, Dec 10, 2015 at 9:42 AM, Allan McAleavy <allan.mcaleavy@gmail.com>
wrote:

> Hi Folks,
>
> I am working on a rewrite of Brendan Greggs original cachestat (ftrace)
> script into bcc. What I was looking for was a steer in the right direction
> for what functions to trace. At present I trace the following.
>
> add_to_page_cache_lru
> account_page_dirtied
> mark_page_accessed
> mark_buffer_dirty
>
> Where total = (mark_page_accessed - mark_buffer_dirty) & misses =
> (add_to_page_cache_lru - account_page_dirtied), from this I then work out
> the hit ratio etc. Is there any other key functions I should be tracing?
>
> Thanks
>

--001a11349980597d030526a0e4c3
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>We add a page to the page cache using add_to_page_cac=
he_lru based on the following assumptions</div><div><br></div><div>READ MIS=
S - So add an entry=C2=A0</div><div>no_cached_page - so we need to create o=
ne from=C2=A0</div><div>do_generic_file_read - during a file read operation=
</div><div>page_cache_read - calls add_to_page_cache_lru=C2=A0</div><div><b=
r></div><div>CREATE A PAGE</div><div>struct page *__page_cache_alloc(gfp_t =
gfp)</div><div><br></div><div>page has flags which identify if dirty or fre=
e</div><div><br></div><div>Writes</div><div>add_to_page_cache</div><div>wri=
tepage / writepages=C2=A0</div><div>set_page_dirty_buffers</div><div>do_gen=
eric_mapping_read =C2=A0- ASYNC read of pages in readahed?</div><div>__bloc=
k_write_full_page</div><div><br></div><div>READ</div><div>find_get_pages</d=
iv><div><br></div><div><br></div><div>mark_page_accessed() for measuring ca=
che accesses</div><div>mark_buffer_dirty() for measuring cache writes</div>=
<div>add_to_page_cache_lru() for measuring page additions</div><div>account=
_page_dirtied() for measuring page dirties</div><div><br></div><div><br></d=
iv><div>=C2=A0(mark_page_accessed - mark_buffer_dirty) &amp; misses =3D (ad=
d_to_page_cache_lru - account_page_dirtied),=C2=A0</div><div>=C2=A0from thi=
s I then work out the hit ratio etc. Is there any other key functions I sho=
uld be tracing?</div><div><br></div><div>add_to_page_cache_lru</div><div>lr=
u_cache_add =C2=A0</div><div>swap.c</div><div>filemap.c</div><div>vmscan.c<=
/div><div><br></div><div>Functions used=C2=A0</div><div>lru_cache_add_activ=
e_or_unevictable</div><div>add_to_page_cache_lru</div><div>putback_lru_page=
</div><div><br></div><div>So best use lru_cache_add for additions.</div><di=
v><br></div><div>account_page_dirtied() for measuring page dirties</div><di=
v>set_page_dirty - calls above</div><div>__set_page_dirty_nobuffers - calls=
 above also=C2=A0</div><div><br></div><div>mark_buffer_dirty() for measurin=
g cache writes - this calls __set_page_dirty ( are we getting twice the cal=
ls here? )=C2=A0</div><div>mark_page_accessed - calls SetPageActive=C2=A0</=
div></div><div class=3D"gmail_extra"><br><div class=3D"gmail_quote">On Thu,=
 Dec 10, 2015 at 9:42 AM, Allan McAleavy <span dir=3D"ltr">&lt;<a href=3D"m=
ailto:allan.mcaleavy@gmail.com" target=3D"_blank">allan.mcaleavy@gmail.com<=
/a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:=
0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"><div dir=3D"ltr"><f=
ont face=3D"Menlo" style=3D"font-size:12.8px">Hi Folks,</font><div style=3D=
"font-size:12.8px"><font face=3D"Menlo"><br></font></div><div style=3D"font=
-size:12.8px"><font face=3D"Menlo">I am working on a rewrite of Brendan Gre=
ggs original cachestat (ftrace) script into bcc. What I was looking for was=
 a steer in the right direction for what functions to trace. At present I t=
race the following.=C2=A0</font></div><div style=3D"font-size:12.8px"><font=
 face=3D"Menlo"><br></font></div><div style=3D"font-size:12.8px"><font face=
=3D"Menlo">add_to_page_cache_lru</font></div><div style=3D"font-size:12.8px=
"><div style=3D"margin:0px"><span style=3D"font-family:Menlo">account_page_=
dirtied</span></div><div style=3D"margin:0px"><font face=3D"Menlo">mark_pag=
e_accessed</font></div><div style=3D"margin:0px"><span style=3D"font-family=
:Menlo">mark_buffer_dirty</span></div><div style=3D"margin:0px"><font face=
=3D"Menlo"><br></font></div></div><div style=3D"font-size:12.8px;margin:0px=
"><font face=3D"Menlo">Where total =3D (mark_page_accessed - mark_buffer_di=
rty) &amp; misses =3D (add_to_page_cache_lru - account_page_dirtied), from =
this I then work out the hit ratio etc. Is there any other key functions I =
should be tracing?</font></div><div style=3D"font-size:12.8px;margin:0px"><=
font face=3D"Menlo"><br></font></div><div style=3D"font-size:12.8px;margin:=
0px"><font face=3D"Menlo">Thanks</font></div></div>
</blockquote></div><br></div>

--001a11349980597d030526a0e4c3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
