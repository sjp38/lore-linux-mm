Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f198.google.com (mail-ob0-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id C01696B007E
	for <linux-mm@kvack.org>; Tue, 17 May 2016 22:39:17 -0400 (EDT)
Received: by mail-ob0-f198.google.com with SMTP id yu3so8102561obb.3
        for <linux-mm@kvack.org>; Tue, 17 May 2016 19:39:17 -0700 (PDT)
Received: from mail-io0-x229.google.com (mail-io0-x229.google.com. [2607:f8b0:4001:c06::229])
        by mx.google.com with ESMTPS id qb7si5837129igb.60.2016.05.17.19.39.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 May 2016 19:39:17 -0700 (PDT)
Received: by mail-io0-x229.google.com with SMTP id i75so48282223ioa.3
        for <linux-mm@kvack.org>; Tue, 17 May 2016 19:39:17 -0700 (PDT)
Received: from [10.18.61.107] ([104.192.110.250])
        by smtp.gmail.com with ESMTPSA id o201sm2034640ioe.15.2016.05.17.19.39.11
        for <linux-mm@kvack.org>
        (version=TLSv1/SSLv3 cipher=OTHER);
        Tue, 17 May 2016 19:39:16 -0700 (PDT)
From: baotiao <baotiao@gmail.com>
Content-Type: multipart/alternative; boundary="Apple-Mail=_28C43B34-7488-4E52-9AF4-8F3BC055A8AF"
Subject: why the kmalloc return fail when there is free physical address but return success after dropping page caches
Message-Id: <D64A3952-53D8-4B9D-98A1-C99D7E231D42@gmail.com>
Date: Wed, 18 May 2016 10:38:52 +0800
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


--Apple-Mail=_28C43B34-7488-4E52-9AF4-8F3BC055A8AF
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

Hello every, I meet an interesting kernel memory problem. Can anyone =
help me explain what happen under the kernel

The machine's status is describe as blow:

the machine has 96 physical memory. And the real use memory is about =
64G, and the page cache use about 32G. we also use the swap area, at =
that time we have about 10G(we set the swap max size to 32G). At that =
moment, we find xfs report

Apr 29 21:54:31 w-openstack86 kernel: XFS: possible memory allocation =
deadlock in kmem_alloc (mode:0x250)

after reading the source code. This message is display from this line

ptr =3D kmalloc(size, lflags); if (ptr || (flags & =
(KM_MAYFAIL|KM_NOSLEEP))) return ptr; if (!(++retries % 100)) =
xfs_err(NULL, "possible memory allocation deadlock in %s (mode:0x%x)", =
__func__, lflags); congestion_wait(BLK_RW_ASYNC, HZ/50);

The error is cause by the kmalloc() function, there is not enough memory =
in the system. But there is still 32G page cache.

So I run

echo 3 > /proc/sys/vm/drop_caches

to drop the page cache.

Then the system is fine. But I really don't know the reason. Why after I =
run drop_caches operation the kmalloc() function will success? I think =
even we use whole physical memory, but we only use 64 real momory, the =
32G memory are page cache, further we have enough swap space. So why the =
kernel don't flush the page cache or the swap to reserved the kmalloc =
operation.


----------------------------------------
=20
Github: https://github.com/baotiao
Blog: http://baotiao.github.io/
Stackoverflow: http://stackoverflow.com/users/634415/baotiao=20
Linkedin: http://www.linkedin.com/profile/view?id=3D145231990


--Apple-Mail=_28C43B34-7488-4E52-9AF4-8F3BC055A8AF
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset=us-ascii

<html><head><meta http-equiv=3D"Content-Type" content=3D"text/html =
charset=3Dus-ascii"></head><body style=3D"word-wrap: break-word; =
-webkit-nbsp-mode: space; -webkit-line-break: after-white-space;" =
class=3D""><div class=3D"post-text" itemprop=3D"text"><p class=3D"">Hello =
every, I meet an interesting kernel memory problem. Can anyone help me =
explain what happen under the kernel</p><p class=3D"">The machine's =
status is describe as blow:</p><p class=3D"">the machine has 96 physical =
memory. And the real use memory is about=20
64G, and the page cache use about 32G. we also use the swap area, at=20
that time we have about 10G(we set the swap max size to 32G). At that=20
moment, we find xfs report </p><p class=3D""><code class=3D"">
Apr 29 21:54:31 w-openstack86 kernel: XFS: possible memory allocation =
deadlock in kmem_alloc (mode:0x250)
</code></p><p class=3D"">after reading the source code. This message is =
display from this line </p><p class=3D""><code class=3D"">
    ptr =3D kmalloc(size, lflags);
    if (ptr || (flags &amp; (KM_MAYFAIL|KM_NOSLEEP)))
      return ptr;
    if (!(++retries % 100))
      xfs_err(NULL,
    "possible memory allocation deadlock in %s (mode:0x%x)",
          __func__, lflags);
    congestion_wait(BLK_RW_ASYNC, HZ/50);
</code></p><p class=3D"">The error is cause by the kmalloc() function, =
there is not enough memory in the system. But there is still 32G page =
cache.</p><p class=3D"">So I run </p><p class=3D""><code class=3D"">
echo 3 &gt; /proc/sys/vm/drop_caches
</code></p><p class=3D"">to drop the page cache.</p><p class=3D"">Then =
the system is fine. But I really don't know the reason.
Why after I run drop_caches operation the kmalloc() function will=20
success? I think even we use whole physical memory, but we only use 64=20=

real momory, the 32G memory are page cache, further we have enough swap=20=

space. So why the kernel don't flush the page cache or the swap to=20
reserved the kmalloc operation.</p><div class=3D""><br =
class=3D""></div></div><div class=3D"">
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
<br class=3D""></body></html>=

--Apple-Mail=_28C43B34-7488-4E52-9AF4-8F3BC055A8AF--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
