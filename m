Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id A56946B0005
	for <linux-mm@kvack.org>; Thu,  7 Mar 2013 02:56:07 -0500 (EST)
Message-ID: <513847EC.70509@allwinnertech.com>
Date: Thu, 7 Mar 2013 15:55:24 +0800
From: Shuge <shuge@allwinnertech.com>
MIME-Version: 1.0
Subject: [jbd2 or mm BUG]:   crash while flush JBD2's the pages, that owned
 Slab flag.
Content-Type: multipart/alternative;
	boundary="------------010701060802020507070703"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org, axboe@kernel.dk, linux-mm@kvack.org, kevin@allwinnertech.com

--------------010701060802020507070703
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: quoted-printable


Hi all,

When I debug the file system, I get a problem as follows:

Arch: arm (4 processors)
Kernel version: 3.3.0

 The "b_frozen_data" which is defined as a member of "struct
journal_head" (linux/fs/jbd2/transaction.c Line 785),
it's memory is allocated by "jbd2_alloc". When the memory size is
larger than a PAGE SIZE, the memory is got by "
__get_free_pages", otherwise, is got by "kmem_cache_alloc". The
memory will be used by the "__blk_queue_bounce"(linux/mm/bounce.c).

In this function, the program flow is:
__blk_queue_bounce() -> flush_dcache_page() -> page_mapping() ->
VM_BUG_ON(PageSlab(page))
If the memory is got by "kmem_cache_alloc", it will trigger on a bug.

Kernel panic:
[   34.683049] ------------[ cut here ]------------
[   34.687686] kernel BUG at include/linux/mm.h:791!
[   34.692388] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP
[   34.697869] Modules linked in: screen_print(O) nand(O)
[   34.703049] CPU: 1    Tainted: G           O  (3.3.0 #6)
[   34.708370] PC is at flush_dcache_page+0x34/0xb0
[   34.712992] LR is at blk_queue_bounce+0x16c/0x300
[   34.717697] pc : [<c001677c>]    lr : [<c00bf0b0>]    psr: 20000013
[   34.717703] sp : ee7a7d48  ip : ee7a7d60  fp : ee7a7d5c
[   34.729176] r10: ee228804  r9 : ee228804  r8 : eea979c8
[   34.734397] r7 : 00000000  r6 : ee228890  r5 : d5333840  r4 : 00000000
[   34.740920] r3 : 00000001  r2 : fffffff5  r1 : 00000011  r0 : d5333840
[   34.747446] Flags: nzCv  IRQs on  FIQs on  Mon  SVC_32  ISA ARM  Segment=
 kernel
[   34.754749] Control: 10c53c7d  Table: 6e05806a  DAC: 00000015
......
[   35.726529] Backtrace:
[   35.729000] [<c0016748>] (flush_dcache_page+0x0/0xb0) from [<c00bf0b0>] =
(blk_queue_bounce+0x16c/0x300)
[   35.738297]  r5:ee7a7dac r4:ee2287c0
[   35.741905] [<c00bef44>] (blk_queue_bounce+0x0/0x300) from [<c01fcc58>] =
(blk_queue_bio+0x28/0x2c0)
[   35.750862] [<c01fcc30>] (blk_queue_bio+0x0/0x2c0) from [<c01fb1b8>] (ge=
neric_make_request+0x94/0xcc)
[   35.760078] [<c01fb124>] (generic_make_request+0x0/0xcc) from [<c01fb2f0=
>] (submit_bio+0x100/0x124)
[   35.769114]  r6:00000002 r5:eecb8f08 r4:ee228840
[   35.773774] [<c01fb1f0>] (submit_bio+0x0/0x124) from [<c00e8e68>] (submi=
t_bh+0x130/0x150)
[   35.781942]  r8:00000009 r7:d60f6c5c r6:00000211 r5:eecb8f08 r4:ee228840
[   35.788713] [<c00e8d38>] (submit_bh+0x0/0x150) from [<c014b024>] (jbd2_j=
ournal_commit_transaction+0x7d0/0x11cc)
[   35.798790]  r6:ef253380 r5:eecb8f08 r4:eeac5800 r3:00000001
[   35.804505] [<c014a854>] (jbd2_journal_commit_transaction+0x0/0x11cc) fr=
om [<c014e2a8>] (kjournald2+0xb4/0x248)
[   35.814591] [<c014e1f4>] (kjournald2+0x0/0x248) from [<c006aa90>] (kthre=
ad+0x94/0xa0)
[   35.822422] [<c006a9fc>] (kthread+0x0/0xa0) from [<c005472c>] (do_exit+0=
x0/0x6a4)
[   35.829897]  r6:c005472c r5:c006a9fc r4:eea9bce0
[   35.834556] Code: e5904004 e7e033d3 e3530000 0a000000 (e7f001f2)
[   35.840733] ---[ end trace c2a29bf063d3670f ]---

So, I modify the mm/bounce.c. Details are as follows:


    diff --git a/mm/bounce.c b/mm/bounce.c

      index 4e9ae72..e3f6b53 100644

      --- a/mm/bounce.c

      +++ b/mm/bounce.c

      @@ -214,7 +214,8 @@ static void __blk_queue_bounce(struct
      request_queue *q, struct bio **bio_orig,

                      if (rw =3D=3D WRITE) {

                              char *vto, *vfrom;



      -                       flush_dcache_page(from->bv_page);

      +                       if (!PageSlab(from->bv_page))

      +
      flush_dcache_page(from->bv_page);

                              vto =3D page_address(to->bv_page) +
      to->bv_offset;

                              vfrom =3D kmap(from->bv_page) +
      from->bv_offset;

                              memcpy(vto, vfrom, to->bv_len);

Who can give some suggestions to me.

Thanks

Shuge





NOTICE: This e-mail and any included attachments are intended only for the =
sole use of named and intended recipient (s) only. If you are the named and=
 intended recipient, please note that the information contained in this ema=
il and its embedded files are confidential and privileged. If you are neith=
er the intended nor named recipient, you are hereby notified that any unaut=
horized review, use, disclosure, dissemination, distribution, or copying of=
 this communication, or any of its contents, is strictly prohibited. Please=
 reply to the sender and destroy the original message and all your records =
of this message (whether electronic or otherwise). Furthermore, you should =
not disclose to any other person, use, copy or disseminate the contents of =
this e-mail and/or the documents accompanying it.

--------------010701060802020507070703
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dutf-8">
</head>
<body bgcolor=3D"#FFFFFF">
<div class=3D"moz-forward-container"><br>
<pre>Hi all,

When I debug the file system, I get a problem as follows:

Arch: arm (4 processors)
Kernel version: 3.3.0

&nbsp;The &quot;b_frozen_data&quot; which is defined as a member of &quot;s=
truct
journal_head&quot; (linux/fs/jbd2/transaction.c Line 785),
it's memory is allocated by &quot;jbd2_alloc&quot;. When the memory size is
larger than a PAGE SIZE, the memory is got by &quot;
__get_free_pages&quot;, otherwise, is got by &quot;kmem_cache_alloc&quot;. =
The
memory will be used by the &quot;__blk_queue_bounce&quot;(linux/mm/bounce.c=
).

In this function, the program flow is:
__blk_queue_bounce() -&gt; flush_dcache_page() -&gt; page_mapping() -&gt;
VM_BUG_ON(PageSlab(page))
If the memory is got by &quot;kmem_cache_alloc&quot;, it will trigger on a =
bug.

Kernel panic:
<font color=3D"#ff0000">[   34.683049] ------------[ cut here ]------------
[   34.687686] kernel BUG at include/linux/mm.h:791!
[   34.692388] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP
[   34.697869] Modules linked in: screen_print(O) nand(O)
[   34.703049] CPU: 1    Tainted: G           O  (3.3.0 #6)
[   34.708370] PC is at flush_dcache_page&#43;0x34/0xb0
[   34.712992] LR is at blk_queue_bounce&#43;0x16c/0x300
[   34.717697] pc : [&lt;c001677c&gt;]    lr : [&lt;c00bf0b0&gt;]    psr: 2=
0000013
[   34.717703] sp : ee7a7d48  ip : ee7a7d60  fp : ee7a7d5c
[   34.729176] r10: ee228804  r9 : ee228804  r8 : eea979c8
[   34.734397] r7 : 00000000  r6 : ee228890  r5 : d5333840  r4 : 00000000
[   34.740920] r3 : 00000001  r2 : fffffff5  r1 : 00000011  r0 : d5333840
[   34.747446] Flags: nzCv  IRQs on  FIQs on  Mon  SVC_32  ISA ARM  Segment=
 kernel
[   34.754749] Control: 10c53c7d  Table: 6e05806a  DAC: 00000015
......
[   35.726529] Backtrace:=20
[   35.729000] [&lt;c0016748&gt;] (flush_dcache_page&#43;0x0/0xb0) from [&l=
t;c00bf0b0&gt;] (blk_queue_bounce&#43;0x16c/0x300)
[   35.738297]  r5:ee7a7dac r4:ee2287c0
[   35.741905] [&lt;c00bef44&gt;] (blk_queue_bounce&#43;0x0/0x300) from [&l=
t;c01fcc58&gt;] (blk_queue_bio&#43;0x28/0x2c0)
[   35.750862] [&lt;c01fcc30&gt;] (blk_queue_bio&#43;0x0/0x2c0) from [&lt;c=
01fb1b8&gt;] (generic_make_request&#43;0x94/0xcc)
[   35.760078] [&lt;c01fb124&gt;] (generic_make_request&#43;0x0/0xcc) from =
[&lt;c01fb2f0&gt;] (submit_bio&#43;0x100/0x124)
[   35.769114]  r6:00000002 r5:eecb8f08 r4:ee228840
[   35.773774] [&lt;c01fb1f0&gt;] (submit_bio&#43;0x0/0x124) from [&lt;c00e=
8e68&gt;] (submit_bh&#43;0x130/0x150)
[   35.781942]  r8:00000009 r7:d60f6c5c r6:00000211 r5:eecb8f08 r4:ee228840
[   35.788713] [&lt;c00e8d38&gt;] (submit_bh&#43;0x0/0x150) from [&lt;c014b=
024&gt;] (jbd2_journal_commit_transaction&#43;0x7d0/0x11cc)
[   35.798790]  r6:ef253380 r5:eecb8f08 r4:eeac5800 r3:00000001
[   35.804505] [&lt;c014a854&gt;] (jbd2_journal_commit_transaction&#43;0x0/=
0x11cc) from [&lt;c014e2a8&gt;] (kjournald2&#43;0xb4/0x248)
[   35.814591] [&lt;c014e1f4&gt;] (kjournald2&#43;0x0/0x248) from [&lt;c006=
aa90&gt;] (kthread&#43;0x94/0xa0)
[   35.822422] [&lt;c006a9fc&gt;] (kthread&#43;0x0/0xa0) from [&lt;c005472c=
&gt;] (do_exit&#43;0x0/0x6a4)
[   35.829897]  r6:c005472c r5:c006a9fc r4:eea9bce0
[   35.834556] Code: e5904004 e7e033d3 e3530000 0a000000 (e7f001f2)=20
[   35.840733] ---[ end trace c2a29bf063d3670f ]---</font>

So, I modify the mm/bounce.c.<span id=3D"result_box" class=3D"short_text" l=
ang=3D"en"><span class=3D""> Details are as follows</span></span>:
  =20

    <font color=3D"#3366ff">diff --git a/mm/bounce.c b/mm/bounce.c

      index 4e9ae72..e3f6b53 100644

      --- a/mm/bounce.c

      &#43;&#43;&#43; b/mm/bounce.c

      @@ -214,7 &#43;214,8 @@ static void __blk_queue_bounce(struct
      request_queue *q, struct bio **bio_orig,

      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp; if (rw =3D=3D WRITE) {

      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; char =
*vto, *vfrom;

      &nbsp;

      -&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; flush_dcac=
he_page(from-&gt;bv_page);

      &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (!P=
ageSlab(from-&gt;bv_page))

      &#43;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      flush_dcache_page(from-&gt;bv_page);

      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; vto =
=3D page_address(to-&gt;bv_page) &#43;
      to-&gt;bv_offset;

      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; vfrom=
 =3D kmap(from-&gt;bv_page) &#43;
      from-&gt;bv_offset;

      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; memcp=
y(vto, vfrom, to-&gt;bv_len);</font>

Who can give some suggestions to me.

Thanks

Shuge
</pre>
</div>
<pre class=3D"moz-signature" cols=3D"72">
</pre>
NOTICE: This e-mail and any included attachments are intended only for the =
sole use of named and intended recipient (s) only. If you are the named and=
 intended recipient, please note that the information contained in this ema=
il and its embedded files are confidential
 and privileged. If you are neither the intended nor named recipient, you a=
re hereby notified that any unauthorized review, use, disclosure, dissemina=
tion, distribution, or copying of this communication, or any of its content=
s, is strictly prohibited. Please
 reply to the sender and destroy the original message and all your records =
of this message (whether electronic or otherwise). Furthermore, you should =
not disclose to any other person, use, copy or disseminate the contents of =
this e-mail and/or the documents
 accompanying it.
</body>
</html>

--------------010701060802020507070703--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
