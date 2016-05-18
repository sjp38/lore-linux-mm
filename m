Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0614F6B007E
	for <linux-mm@kvack.org>; Wed, 18 May 2016 04:58:37 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id d62so91994968iof.1
        for <linux-mm@kvack.org>; Wed, 18 May 2016 01:58:37 -0700 (PDT)
Received: from mail-io0-x22c.google.com (mail-io0-x22c.google.com. [2607:f8b0:4001:c06::22c])
        by mx.google.com with ESMTPS id j2si6825308ita.8.2016.05.18.01.58.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 May 2016 01:58:35 -0700 (PDT)
Received: by mail-io0-x22c.google.com with SMTP id 190so56560405iow.1
        for <linux-mm@kvack.org>; Wed, 18 May 2016 01:58:35 -0700 (PDT)
Content-Type: multipart/alternative; boundary="Apple-Mail=_E0FD6C39-7EDB-4E1B-BE72-E25186E14E3C"
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: why the kmalloc return fail when there is free physical address but return success after dropping page caches
From: baotiao <baotiao@gmail.com>
In-Reply-To: <573C2BB6.6070801@suse.cz>
Date: Wed, 18 May 2016 16:58:31 +0800
Message-Id: <78A99337-5542-4E59-A648-AB2A328957D3@gmail.com>
References: <D64A3952-53D8-4B9D-98A1-C99D7E231D42@gmail.com> <573C2BB6.6070801@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>


--Apple-Mail=_E0FD6C39-7EDB-4E1B-BE72-E25186E14E3C
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=windows-1252

Thanks for your reply

>> Hello every, I meet an interesting kernel memory problem. Can anyone
>> help me explain what happen under the kernel
>=20
> Which kernel version is that?

The kernel version is 3.10.0-327.4.5.el7.x86_64
>> The machine's status is describe as blow:
>>=20
>> the machine has 96 physical memory. And the real use memory is about
>> 64G, and the page cache use about 32G. we also use the swap area, at
>> that time we have about 10G(we set the swap max size to 32G). At that
>> moment, we find xfs report
>>=20
>> |Apr 29 21:54:31 w-openstack86 kernel: XFS: possible memory =
allocation
>> deadlock in kmem_alloc (mode:0x250) |
>=20
> Just once, or many times?

the message appear many times
from the code, I know that xfs will try 100 time of kmalloc() function

>> after reading the source code. This message is display from this line
>>=20
>> |ptr =3D kmalloc(size, lflags); if (ptr || (flags &
>> (KM_MAYFAIL|KM_NOSLEEP))) return ptr; if (!(++retries % 100))
>> xfs_err(NULL, "possible memory allocation deadlock in %s =
(mode:0x%x)",
>> __func__, lflags); congestion_wait(BLK_RW_ASYNC, HZ/50); |
>=20
> Any indication what is the size used here?
I don't know the size here, since it is called by the xfs.

>> The error is cause by the kmalloc() function, there is not enough =
memory
>> in the system. But there is still 32G page cache.
>>=20
>> So I run
>>=20
>> |echo 3 > /proc/sys/vm/drop_caches |
>>=20
>> to drop the page cache.
>>=20
>> Then the system is fine.
>=20
> Are you saying that the error message was repeated infinitely until =
you did the drop_caches?


No. the error message don't appear after I drop_cache.

Is it possible the reason is that even we have enough physical pages, =
but there pages is used for page cache, when user call kmalloc(), =
kmalloc() get page from kernel. kernel find that there is not enough =
pages, but some page is used for page cache, we can get some free pages =
from these page caches. so the kernel will call the kswapd to clear away =
some page cache. But it takes too long to get the free pages. And the =
function in xfs kmem_alloc don't set the flag __GFP_WAIT flag. So the =
kmem_alloc always return no enough memory, and print the error message.

----------------------------------------
=20
Github: https://github.com/baotiao
Blog: http://baotiao.github.io/
Stackoverflow: http://stackoverflow.com/users/634415/baotiao=20
Linkedin: http://www.linkedin.com/profile/view?id=3D145231990

> On May 18, 2016, at 16:45, Vlastimil Babka <vbabka@suse.cz> wrote:
>=20
> [+CC Dave]
>=20
> On 05/18/2016 04:38 AM, baotiao wrote:
>> Hello every, I meet an interesting kernel memory problem. Can anyone
>> help me explain what happen under the kernel
>=20
> Which kernel version is that?
>=20
>> The machine's status is describe as blow:
>>=20
>> the machine has 96 physical memory. And the real use memory is about
>> 64G, and the page cache use about 32G. we also use the swap area, at
>> that time we have about 10G(we set the swap max size to 32G). At that
>> moment, we find xfs report
>>=20
>> |Apr 29 21:54:31 w-openstack86 kernel: XFS: possible memory =
allocation
>> deadlock in kmem_alloc (mode:0x250) |
>=20
> Just once, or many times?
>=20
>> after reading the source code. This message is display from this line
>>=20
>> |ptr =3D kmalloc(size, lflags); if (ptr || (flags &
>> (KM_MAYFAIL|KM_NOSLEEP))) return ptr; if (!(++retries % 100))
>> xfs_err(NULL, "possible memory allocation deadlock in %s =
(mode:0x%x)",
>> __func__, lflags); congestion_wait(BLK_RW_ASYNC, HZ/50); |
>=20
> Any indication what is the size used here?
>=20
>> The error is cause by the kmalloc() function, there is not enough =
memory
>> in the system. But there is still 32G page cache.
>>=20
>> So I run
>>=20
>> |echo 3 > /proc/sys/vm/drop_caches |
>>=20
>> to drop the page cache.
>>=20
>> Then the system is fine.
>=20
> Are you saying that the error message was repeated infinitely until =
you did the drop_caches?
>=20
>> But I really don't know the reason. Why after I
>> run drop_caches operation the kmalloc() function will success? I =
think
>> even we use whole physical memory, but we only use 64 real momory, =
the
>> 32G memory are page cache, further we have enough swap space. So why =
the
>> kernel don't flush the page cache or the swap to reserved the kmalloc
>> operation.
>>=20
>>=20
>> ----------------------------------------
>> Github: https://github.com/baotiao
>> Blog: http://baotiao.github.io/
>> Stackoverflow: http://stackoverflow.com/users/634415/baotiao
>> Linkedin: http://www.linkedin.com/profile/view?id=3D145231990


--Apple-Mail=_E0FD6C39-7EDB-4E1B-BE72-E25186E14E3C
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset=windows-1252

<html><head><meta http-equiv=3D"Content-Type" content=3D"text/html =
charset=3Dwindows-1252"></head><body style=3D"word-wrap: break-word; =
-webkit-nbsp-mode: space; -webkit-line-break: after-white-space;" =
class=3D"">Thanks for your reply<div class=3D""><br class=3D""></div><div =
class=3D""><blockquote type=3D"cite" class=3D""><blockquote type=3D"cite" =
class=3D"">Hello every, I meet an interesting kernel memory problem. Can =
anyone<br class=3D"">help me explain what happen under the kernel<br =
class=3D""></blockquote><br class=3D""><span class=3D"" style=3D"float: =
none; display: inline !important;">Which kernel version is =
that?</span><br class=3D""></blockquote></div><div class=3D"">The kernel =
version is&nbsp;3.10.0-327.4.5.el7.x86_64</div><div class=3D""><blockquote=
 type=3D"cite" class=3D""><blockquote type=3D"cite" class=3D"">The =
machine's status is describe as blow:<br class=3D""><br class=3D"">the =
machine has 96 physical memory. And the real use memory is about<br =
class=3D"">64G, and the page cache use about 32G. we also use the swap =
area, at<br class=3D"">that time we have about 10G(we set the swap max =
size to 32G). At that<br class=3D"">moment, we find xfs report<br =
class=3D""><br class=3D"">|Apr 29 21:54:31 w-openstack86 kernel: XFS: =
possible memory allocation<br class=3D"">deadlock in kmem_alloc =
(mode:0x250) |<br class=3D""></blockquote><br class=3D""><span class=3D"" =
style=3D"float: none; display: inline !important;">Just once, or many =
times?</span></blockquote></div><div class=3D"">the message appear many =
times</div><div class=3D"">from the code, I know that xfs will try 100 =
time of kmalloc() function</div><div class=3D""><br class=3D""></div><div =
class=3D""><blockquote type=3D"cite" class=3D""><blockquote type=3D"cite" =
class=3D"">after reading the source code. This message is display from =
this line<br class=3D""><br class=3D"">|ptr =3D kmalloc(size, lflags); =
if (ptr || (flags &amp;<br class=3D"">(KM_MAYFAIL|KM_NOSLEEP))) return =
ptr; if (!(++retries % 100))<br class=3D"">xfs_err(NULL, "possible =
memory allocation deadlock in %s (mode:0x%x)",<br class=3D"">__func__, =
lflags); congestion_wait(BLK_RW_ASYNC, HZ/50); |<br =
class=3D""></blockquote><br class=3D""><span class=3D"" style=3D"float: =
none; display: inline !important;">Any indication what is the size used =
here?</span></blockquote>I don't know the size here, since it is called =
by the xfs.</div><div class=3D""><br class=3D""></div><div =
class=3D""><blockquote type=3D"cite" class=3D""><blockquote type=3D"cite" =
class=3D"">The error is cause by the kmalloc() function, there is not =
enough memory<br class=3D"">in the system. But there is still 32G page =
cache.<br class=3D""><br class=3D"">So I run<br class=3D""><br =
class=3D"">|echo 3 &gt; /proc/sys/vm/drop_caches |<br class=3D""><br =
class=3D"">to drop the page cache.<br class=3D""><br class=3D"">Then the =
system is fine.<br class=3D""></blockquote><br class=3D""><span class=3D""=
 style=3D"float: none; display: inline !important;">Are you saying that =
the error message was repeated infinitely until you did the =
drop_caches?</span></blockquote></div><div class=3D""><br =
class=3D""></div><div class=3D"">No. the error message don't appear =
after I drop_cache.</div><div class=3D""><br class=3D""></div><div =
class=3D"">Is it possible the reason is that even we have enough =
physical pages, but there pages is used for page cache, when user call =
kmalloc(), kmalloc() get page from kernel. kernel find that there is not =
enough pages, but some page is used for page cache, we can get some free =
pages from these page caches. so the kernel will call the kswapd to =
clear away some page cache. But it takes too long to get the free pages. =
And the function in xfs kmem_alloc don't set the flag __GFP_WAIT flag. =
So the kmem_alloc always return no enough memory, and print the error =
message.</div><div class=3D""><br class=3D""></div><div class=3D""><div =
class=3D"">
<div style=3D"color: rgb(0, 0, 0); letter-spacing: normal; orphans: =
auto; text-align: start; text-indent: 0px; text-transform: none; =
white-space: normal; widows: auto; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; word-wrap: break-word; =
-webkit-nbsp-mode: space; -webkit-line-break: after-white-space;" =
class=3D""><div style=3D"color: rgb(0, 0, 0); letter-spacing: normal; =
orphans: auto; text-align: start; text-indent: 0px; text-transform: =
none; white-space: normal; widows: auto; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; word-wrap: break-word; =
-webkit-nbsp-mode: space; -webkit-line-break: after-white-space;" =
class=3D""><div style=3D"orphans: auto; text-align: start; text-indent: =
0px; widows: auto; word-wrap: break-word; -webkit-nbsp-mode: space; =
-webkit-line-break: after-white-space;" class=3D""><div style=3D"color: =
rgb(0, 0, 0); letter-spacing: normal; text-transform: none; white-space: =
normal; word-spacing: 0px; -webkit-text-stroke-width: 0px; orphans: =
auto; text-align: start; text-indent: 0px; widows: auto; word-wrap: =
break-word; -webkit-nbsp-mode: space; -webkit-line-break: =
after-white-space; font-size: 20px;" =
class=3D"">----------------------------------------<br =
class=3D"">&nbsp;</div><div style=3D"orphans: auto; text-align: start; =
text-indent: 0px; widows: auto; word-wrap: break-word; =
-webkit-nbsp-mode: space; -webkit-line-break: after-white-space; =
font-size: 20px;" class=3D"">Github:&nbsp;<a =
href=3D"https://github.com/baotiao" =
class=3D"">https://github.com/baotiao</a><br class=3D"">Blog: <a =
href=3D"http://baotiao.github.io/" =
class=3D"">http://baotiao.github.io/</a><br class=3D"">Stackoverflow: <a =
href=3D"http://stackoverflow.com/users/634415/baotiao" =
class=3D"">http://stackoverflow.com/users/634415/baotiao</a>&nbsp;</div><d=
iv style=3D"orphans: auto; text-align: start; text-indent: 0px; widows: =
auto; word-wrap: break-word; -webkit-nbsp-mode: space; =
-webkit-line-break: after-white-space; font-size: 20px;" =
class=3D"">Linkedin: <a =
href=3D"http://www.linkedin.com/profile/view?id=3D145231990" =
class=3D"">http://www.linkedin.com/profile/view?id=3D145231990</a></div></=
div></div></div>
</div>
<br class=3D""><div><blockquote type=3D"cite" class=3D""><div =
class=3D"">On May 18, 2016, at 16:45, Vlastimil Babka &lt;<a =
href=3D"mailto:vbabka@suse.cz" class=3D"">vbabka@suse.cz</a>&gt; =
wrote:</div><br class=3D"Apple-interchange-newline"><div class=3D""><span =
style=3D"font-family: Helvetica; font-size: 18px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
orphans: auto; text-align: start; text-indent: 0px; text-transform: =
none; white-space: normal; widows: auto; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; float: none; display: inline =
!important;" class=3D"">[+CC Dave]</span><br style=3D"font-family: =
Helvetica; font-size: 18px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; orphans: auto; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; widows: auto; word-spacing: 0px; -webkit-text-stroke-width: =
0px;" class=3D""><br style=3D"font-family: Helvetica; font-size: 18px; =
font-style: normal; font-variant-caps: normal; font-weight: normal; =
letter-spacing: normal; orphans: auto; text-align: start; text-indent: =
0px; text-transform: none; white-space: normal; widows: auto; =
word-spacing: 0px; -webkit-text-stroke-width: 0px;" class=3D""><span =
style=3D"font-family: Helvetica; font-size: 18px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
orphans: auto; text-align: start; text-indent: 0px; text-transform: =
none; white-space: normal; widows: auto; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; float: none; display: inline =
!important;" class=3D"">On 05/18/2016 04:38 AM, baotiao wrote:</span><br =
style=3D"font-family: Helvetica; font-size: 18px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
orphans: auto; text-align: start; text-indent: 0px; text-transform: =
none; white-space: normal; widows: auto; word-spacing: 0px; =
-webkit-text-stroke-width: 0px;" class=3D""><blockquote type=3D"cite" =
style=3D"font-family: Helvetica; font-size: 18px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
orphans: auto; text-align: start; text-indent: 0px; text-transform: =
none; white-space: normal; widows: auto; word-spacing: 0px; =
-webkit-text-stroke-width: 0px;" class=3D"">Hello every, I meet an =
interesting kernel memory problem. Can anyone<br class=3D"">help me =
explain what happen under the kernel<br class=3D""></blockquote><br =
style=3D"font-family: Helvetica; font-size: 18px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
orphans: auto; text-align: start; text-indent: 0px; text-transform: =
none; white-space: normal; widows: auto; word-spacing: 0px; =
-webkit-text-stroke-width: 0px;" class=3D""><span style=3D"font-family: =
Helvetica; font-size: 18px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; orphans: auto; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; widows: auto; word-spacing: 0px; -webkit-text-stroke-width: 0px; =
float: none; display: inline !important;" class=3D"">Which kernel =
version is that?</span><br style=3D"font-family: Helvetica; font-size: =
18px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; orphans: auto; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; widows: =
auto; word-spacing: 0px; -webkit-text-stroke-width: 0px;" class=3D""><br =
style=3D"font-family: Helvetica; font-size: 18px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
orphans: auto; text-align: start; text-indent: 0px; text-transform: =
none; white-space: normal; widows: auto; word-spacing: 0px; =
-webkit-text-stroke-width: 0px;" class=3D""><blockquote type=3D"cite" =
style=3D"font-family: Helvetica; font-size: 18px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
orphans: auto; text-align: start; text-indent: 0px; text-transform: =
none; white-space: normal; widows: auto; word-spacing: 0px; =
-webkit-text-stroke-width: 0px;" class=3D"">The machine's status is =
describe as blow:<br class=3D""><br class=3D"">the machine has 96 =
physical memory. And the real use memory is about<br class=3D"">64G, and =
the page cache use about 32G. we also use the swap area, at<br =
class=3D"">that time we have about 10G(we set the swap max size to 32G). =
At that<br class=3D"">moment, we find xfs report<br class=3D""><br =
class=3D"">|Apr 29 21:54:31 w-openstack86 kernel: XFS: possible memory =
allocation<br class=3D"">deadlock in kmem_alloc (mode:0x250) |<br =
class=3D""></blockquote><br style=3D"font-family: Helvetica; font-size: =
18px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; orphans: auto; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; widows: =
auto; word-spacing: 0px; -webkit-text-stroke-width: 0px;" class=3D""><span=
 style=3D"font-family: Helvetica; font-size: 18px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
orphans: auto; text-align: start; text-indent: 0px; text-transform: =
none; white-space: normal; widows: auto; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; float: none; display: inline =
!important;" class=3D"">Just once, or many times?</span><br =
style=3D"font-family: Helvetica; font-size: 18px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
orphans: auto; text-align: start; text-indent: 0px; text-transform: =
none; white-space: normal; widows: auto; word-spacing: 0px; =
-webkit-text-stroke-width: 0px;" class=3D""><br style=3D"font-family: =
Helvetica; font-size: 18px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; orphans: auto; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; widows: auto; word-spacing: 0px; -webkit-text-stroke-width: =
0px;" class=3D""><blockquote type=3D"cite" style=3D"font-family: =
Helvetica; font-size: 18px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; orphans: auto; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; widows: auto; word-spacing: 0px; -webkit-text-stroke-width: =
0px;" class=3D"">after reading the source code. This message is display =
from this line<br class=3D""><br class=3D"">|ptr =3D kmalloc(size, =
lflags); if (ptr || (flags &amp;<br class=3D"">(KM_MAYFAIL|KM_NOSLEEP))) =
return ptr; if (!(++retries % 100))<br class=3D"">xfs_err(NULL, =
"possible memory allocation deadlock in %s (mode:0x%x)",<br =
class=3D"">__func__, lflags); congestion_wait(BLK_RW_ASYNC, HZ/50); |<br =
class=3D""></blockquote><br style=3D"font-family: Helvetica; font-size: =
18px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; orphans: auto; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; widows: =
auto; word-spacing: 0px; -webkit-text-stroke-width: 0px;" class=3D""><span=
 style=3D"font-family: Helvetica; font-size: 18px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
orphans: auto; text-align: start; text-indent: 0px; text-transform: =
none; white-space: normal; widows: auto; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; float: none; display: inline =
!important;" class=3D"">Any indication what is the size used =
here?</span><br style=3D"font-family: Helvetica; font-size: 18px; =
font-style: normal; font-variant-caps: normal; font-weight: normal; =
letter-spacing: normal; orphans: auto; text-align: start; text-indent: =
0px; text-transform: none; white-space: normal; widows: auto; =
word-spacing: 0px; -webkit-text-stroke-width: 0px;" class=3D""><br =
style=3D"font-family: Helvetica; font-size: 18px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
orphans: auto; text-align: start; text-indent: 0px; text-transform: =
none; white-space: normal; widows: auto; word-spacing: 0px; =
-webkit-text-stroke-width: 0px;" class=3D""><blockquote type=3D"cite" =
style=3D"font-family: Helvetica; font-size: 18px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
orphans: auto; text-align: start; text-indent: 0px; text-transform: =
none; white-space: normal; widows: auto; word-spacing: 0px; =
-webkit-text-stroke-width: 0px;" class=3D"">The error is cause by the =
kmalloc() function, there is not enough memory<br class=3D"">in the =
system. But there is still 32G page cache.<br class=3D""><br class=3D"">So=
 I run<br class=3D""><br class=3D"">|echo 3 &gt; =
/proc/sys/vm/drop_caches |<br class=3D""><br class=3D"">to drop the page =
cache.<br class=3D""><br class=3D"">Then the system is fine.<br =
class=3D""></blockquote><br style=3D"font-family: Helvetica; font-size: =
18px; font-style: normal; font-variant-caps: normal; font-weight: =
normal; letter-spacing: normal; orphans: auto; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; widows: =
auto; word-spacing: 0px; -webkit-text-stroke-width: 0px;" class=3D""><span=
 style=3D"font-family: Helvetica; font-size: 18px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
orphans: auto; text-align: start; text-indent: 0px; text-transform: =
none; white-space: normal; widows: auto; word-spacing: 0px; =
-webkit-text-stroke-width: 0px; float: none; display: inline =
!important;" class=3D"">Are you saying that the error message was =
repeated infinitely until you did the drop_caches?</span><br =
style=3D"font-family: Helvetica; font-size: 18px; font-style: normal; =
font-variant-caps: normal; font-weight: normal; letter-spacing: normal; =
orphans: auto; text-align: start; text-indent: 0px; text-transform: =
none; white-space: normal; widows: auto; word-spacing: 0px; =
-webkit-text-stroke-width: 0px;" class=3D""><br style=3D"font-family: =
Helvetica; font-size: 18px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; orphans: auto; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; widows: auto; word-spacing: 0px; -webkit-text-stroke-width: =
0px;" class=3D""><blockquote type=3D"cite" style=3D"font-family: =
Helvetica; font-size: 18px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; orphans: auto; =
text-align: start; text-indent: 0px; text-transform: none; white-space: =
normal; widows: auto; word-spacing: 0px; -webkit-text-stroke-width: =
0px;" class=3D"">But I really don't know the reason. Why after I<br =
class=3D"">run drop_caches operation the kmalloc() function will =
success? I think<br class=3D"">even we use whole physical memory, but we =
only use 64 real momory, the<br class=3D"">32G memory are page cache, =
further we have enough swap space. So why the<br class=3D"">kernel don't =
flush the page cache or the swap to reserved the kmalloc<br =
class=3D"">operation.<br class=3D""><br class=3D""><br =
class=3D"">----------------------------------------<br class=3D"">Github: =
<a href=3D"https://github.com/baotiao" =
class=3D"">https://github.com/baotiao</a><br class=3D"">Blog: <a =
href=3D"http://baotiao.github.io/" =
class=3D"">http://baotiao.github.io/</a><br class=3D"">Stackoverflow: <a =
href=3D"http://stackoverflow.com/users/634415/baotiao" =
class=3D"">http://stackoverflow.com/users/634415/baotiao</a><br =
class=3D"">Linkedin: <a =
href=3D"http://www.linkedin.com/profile/view?id=3D145231990" =
class=3D"">http://www.linkedin.com/profile/view?id=3D145231990</a></blockq=
uote></div></blockquote></div><br class=3D""></div></body></html>=

--Apple-Mail=_E0FD6C39-7EDB-4E1B-BE72-E25186E14E3C--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
