Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	HTML_MESSAGE,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 459F8C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 06:29:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C75B22064A
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 06:29:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C75B22064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 33D688E0006; Tue, 30 Jul 2019 02:29:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2EC848E0003; Tue, 30 Jul 2019 02:29:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B5958E0006; Tue, 30 Jul 2019 02:29:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f69.google.com (mail-vs1-f69.google.com [209.85.217.69])
	by kanga.kvack.org (Postfix) with ESMTP id E66688E0003
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 02:29:21 -0400 (EDT)
Received: by mail-vs1-f69.google.com with SMTP id x22so16655551vsj.1
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 23:29:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=IMosPesPFFf9hL8ooifOFytMB+kDSnPB1qWdSk68K9c=;
        b=RuVVSFNEd4Y0A2+bRtU9ETyBZAsnv41Qw7zC35H/zHY1dFxEouIl7WiquGwat2xsPz
         kxJONk8+RPC/7D91aKV+e1GVbabqOmSIqjCEvVYWIneKHVkFq2W7LwgM3GMUwqd6vV58
         Dj9aSllxlpcPvUMTeFs3sX9DZLFRlj01GyVEvI1X3RgsVQAsucrf7WtcOIMgi1TjLPIR
         FkNvrNRayTbO2R/rbBd5dwzhvKbP1u4E2wzIOASJ52mp419DyvaABHxaucKoVlaUCuW4
         55hTaGVpYco/uAUP+RhZNRc2tEgg+nOb6vIKybac2EQBsF/pb57/+/xyuNHpd/81MJkP
         E2pg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of liwan@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=liwan@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVacz5F6XyB9EC+BpEw6nDtDytYkUg89zxud6gcVUeaAbTu4yZV
	fgmCWXDNIcwAoDSe3xwJJUzaQIeD6HRb6Gjo13QCLeDH9hc1psrG7UmY9BxRRu8wNmvhpSLWQZN
	sw8cIfJqu+D3C9rgOj4S4vt2Hp5sIP+0efB64Spr5YeBHkORo+b0zH4kVeW8v4Nd7Sg==
X-Received: by 2002:a67:2704:: with SMTP id n4mr9040559vsn.202.1564468161597;
        Mon, 29 Jul 2019 23:29:21 -0700 (PDT)
X-Received: by 2002:a67:2704:: with SMTP id n4mr9040539vsn.202.1564468160633;
        Mon, 29 Jul 2019 23:29:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564468160; cv=none;
        d=google.com; s=arc-20160816;
        b=QnQJewcDdnOFKlJyD4ZwfuGLt6SKw8IX68v62GAzMukm10aA4tNR6eKrORu0FA7jzU
         b9NGoBPsw0S4TPWAyU1NaUFvgGAtvO861UmXHpIaGH1p0prGtBxNT9+0gnxTCvAZG7Yt
         JMIF2Zs7oM7yH2sQWIH9dhNogpByeUb4kSGDvhd17cLSCBX6J3j/Ng4DhP2XhndaYm/5
         k3sBqhczpvm1Q6GG2GVJbO8tMjqRvqpxJMgQJHR4oxjLoboO8kBvpY+pJp2IjKDxFnnp
         MZoeD2Q17LfqqmWFIxY298urTomFbi4gzkNdbhKKUbDdfIoVLg7hUOBloXtCNTD0tTCq
         gpLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=IMosPesPFFf9hL8ooifOFytMB+kDSnPB1qWdSk68K9c=;
        b=eA95+sT9GPhKDMlr8HFU4plYmEfI+nZ5R7UHVmTkIuXyeXKDT6es12LAAhWwsX1oBl
         4sjpiHS+mbEunDqolKVnS/7b5e/RBIEXvW2CxCzvLjvi6eqVJIaAuYIWj4Oc3QY5pYQX
         0qc6Y23zUlDZQTBIC46TdHVMvOFDfn6nOA1pS66IROcq+atq+ss3btHSxqm07k/0Q/Rt
         7n7Rm10nfetN+ojJSSBBZeOpGn1HNV5IjaEc+b4P3fXt5vK9PMVesc4xQTduevy77U/5
         uhMcrJxfQmsCMKTV9vTh9h1maBa+rAaf12pPs1EcFsVp6MxC3QTkY1A4PZ39Sj+2Ug+Q
         ZA2g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of liwan@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=liwan@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n10sor30717242uap.66.2019.07.29.23.29.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Jul 2019 23:29:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of liwan@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of liwan@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=liwan@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqxFB1ijO49uxdm2nYMRYf/xjt3Bf1iviS/OQbL/KnT0X2QyoLZxB6P9WAlPP3WH+gvuNa4HcwxVS16Ra/LqbU0=
X-Received: by 2002:ab0:67d6:: with SMTP id w22mr3968533uar.68.1564468160052;
 Mon, 29 Jul 2019 23:29:20 -0700 (PDT)
MIME-Version: 1.0
References: <CAEemH2dMW6oh6Bbm=yqUADF+mDhuQgFTTGYftB+xAhqqdYV3Ng@mail.gmail.com>
 <47999e20-ccbe-deda-c960-473db5b56ea0@oracle.com>
In-Reply-To: <47999e20-ccbe-deda-c960-473db5b56ea0@oracle.com>
From: Li Wang <liwang@redhat.com>
Date: Tue, 30 Jul 2019 14:29:09 +0800
Message-ID: <CAEemH2d=vEfppCbCgVoGdHed2kuY3GWnZGhymYT1rnxjoWNdcQ@mail.gmail.com>
Subject: =?UTF-8?Q?Re=3A_=5BMM_Bug=3F=5D_mmap=28=29_triggers_SIGBUS_while_doing_the?=
	=?UTF-8?Q?=E2=80=8B_=E2=80=8Bnuma=5Fmove=5Fpages=28=29_for_offlined_hugepage_in_background?=
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Linux-MM <linux-mm@kvack.org>, 
	LTP List <ltp@lists.linux.it>, xishi.qiuxishi@alibaba-inc.com, mhocko@kernel.org, 
	Cyril Hrubis <chrubis@suse.cz>
Content-Type: multipart/alternative; boundary="000000000000f292b6058ee020fb"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--000000000000f292b6058ee020fb
Content-Type: text/plain; charset="UTF-8"

Hi Mike,

Thanks for trying this.

On Tue, Jul 30, 2019 at 3:01 AM Mike Kravetz <mike.kravetz@oracle.com>
wrote:
>
> On 7/28/19 10:17 PM, Li Wang wrote:
> > Hi Naoya and Linux-MMers,
> >
> > The LTP/move_page12 V2 triggers SIGBUS in the kernel-v5.2.3 testing.
> >
https://github.com/wangli5665/ltp/blob/master/testcases/kernel/syscalls/move_pages/move_pages12.c
> >
> > It seems like the retry mmap() triggers SIGBUS while doing
thenuma_move_pages() in background. That is very similar to the kernelbug
which was mentioned by commit 6bc9b56433b76e40d(mm: fix race
onsoft-offlining ): A race condition between soft offline andhugetlb_fault
which causes unexpected process SIGBUS killing.
> >
> > I'm not sure if that below patch is making sene to memory-failures.c,
but after building a new kernel-5.2.3 with this change, the problem can NOT
be reproduced.
> >
> > Any comments?
>
> Something seems strange.  I can not reproduce with unmodified 5.2.3

It's not 100% reproducible, I tried ten times only hit 4~6 times fail.

Did you try the test case with patch V3(in my branch)?
https://github.com/wangli5665/ltp/commit/198fca89870c1b807a01b27bb1d2ec6e2af1c7b6

# git clone https://github.com/wangli5665/ltp ltp.wangli --depth=1
# cd ltp.wangli/; make autotools;
# ./configure ; make -j24
# cd testcases/kernel/syscalls/move_pages/
# ./move_pages12
tst_test.c:1100: INFO: Timeout per run is 0h 05m 00s
move_pages12.c:249: INFO: Free RAM 64386300 kB
move_pages12.c:267: INFO: Increasing 2048kB hugepages pool on node 0 to 4
move_pages12.c:277: INFO: Increasing 2048kB hugepages pool on node 1 to 4
move_pages12.c:193: INFO: Allocating and freeing 4 hugepages on node 0
move_pages12.c:193: INFO: Allocating and freeing 4 hugepages on node 1
move_pages12.c:183: PASS: Bug not reproduced
tst_test.c:1145: BROK: Test killed by SIGBUS!
move_pages12.c:117: FAIL: move_pages failed: ESRCH

# uname -r
5.2.3

# numactl -H
available: 4 nodes (0-3)
node 0 cpus: 0 1 2 3 4 5 6 7 32 33 34 35 36 37 38 39
node 0 size: 16049 MB
node 0 free: 15736 MB
node 1 cpus: 8 9 10 11 12 13 14 15 40 41 42 43 44 45 46 47
node 1 size: 16123 MB
node 1 free: 15850 MB
node 2 cpus: 16 17 18 19 20 21 22 23 48 49 50 51 52 53 54 55
node 2 size: 16123 MB
node 2 free: 15989 MB
node 3 cpus: 24 25 26 27 28 29 30 31 56 57 58 59 60 61 62 63
node 3 size: 16097 MB
node 3 free: 15278 MB
node distances:
node   0   1   2   3
  0:  10  20  20  20
  1:  20  10  20  20
  2:  20  20  10  20
  3:  20  20  20  10

> Also, the soft_offline_huge_page() code should not come into play with
> this specific test.

I got the "soft offline xxx.. hugepage failed to isolate" message from
soft_offline_huge_page()
in dmesg log.

=== debug print info ===
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1701,7 +1701,7 @@ static int soft_offline_huge_page(struct page *page,
int flags)
         */
        put_hwpoison_page(hpage);
        if (!ret) {
-               pr_info("soft offline: %#lx hugepage failed to isolate\n",
pfn);
+               pr_info("liwang -- soft offline: %#lx hugepage failed to
isolate\n", pfn);
                return -EBUSY;
        }

# dmesg
...
[ 1068.947205] Soft offlining pfn 0x40b200 at process virtual address
0x7f9d8d000000
[ 1068.987054] Soft offlining pfn 0x40ac00 at process virtual address
0x7f9d8d200000
[ 1069.048478] Soft offlining pfn 0x40a800 at process virtual address
0x7f9d8d000000
[ 1069.087413] Soft offlining pfn 0x40ae00 at process virtual address
0x7f9d8d200000
[ 1069.123285] liwang -- soft offline: 0x40ae00 hugepage failed to isolate
[ 1069.160137] Soft offlining pfn 0x80f800 at process virtual address
0x7f9d8d000000
[ 1069.196009] Soft offlining pfn 0x80fe00 at process virtual address
0x7f9d8d200000
[ 1069.243436] Soft offlining pfn 0x40a400 at process virtual address
0x7f9d8d000000
[ 1069.281301] Soft offlining pfn 0x40a600 at process virtual address
0x7f9d8d200000
[ 1069.318171] liwang -- soft offline: 0x40a600 hugepage failed to isolate

-- 
Regards,
Li Wang

--000000000000f292b6058ee020fb
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_default" style=3D"font-size:small">Hi =
Mike,</div><div class=3D"gmail_default" style=3D"font-size:small"><br></div=
><div class=3D"gmail_default" style=3D"font-size:small">Thanks for trying t=
his.</div><br>On Tue, Jul 30, 2019 at 3:01 AM Mike Kravetz &lt;<a href=3D"m=
ailto:mike.kravetz@oracle.com">mike.kravetz@oracle.com</a>&gt; wrote:<br>&g=
t;<br>&gt; On 7/28/19 10:17 PM, Li Wang wrote:<br>&gt; &gt; Hi Naoya and Li=
nux-MMers,<br>&gt; &gt;<br>&gt; &gt; The LTP/move_page12 V2 triggers SIGBUS=
 in the kernel-v5.2.3 testing.<br>&gt; &gt; <a href=3D"https://github.com/w=
angli5665/ltp/blob/master/testcases/kernel/syscalls/move_pages/move_pages12=
.c">https://github.com/wangli5665/ltp/blob/master/testcases/kernel/syscalls=
/move_pages/move_pages12.c</a><br>&gt; &gt;<br>&gt; &gt; It seems like the =
retry mmap() triggers SIGBUS while doing thenuma_move_pages() in background=
. That is very similar to the kernelbug which was mentioned by commit 6bc9b=
56433b76e40d(mm: fix race onsoft-offlining ): A race condition between soft=
 offline andhugetlb_fault which causes unexpected process SIGBUS killing.<b=
r>&gt; &gt;<br>&gt; &gt; I&#39;m not sure if that below patch is making sen=
e to memory-failures.c, but after building a new kernel-5.2.3 with this cha=
nge, the problem can NOT be reproduced.<br>&gt; &gt;<br>&gt; &gt; Any comme=
nts?<br>&gt;<br>&gt; Something seems strange.=C2=A0 I can not reproduce wit=
h unmodified 5.2.3<br><br>It&#39;s not 100% reproducible, I tried ten times=
 only hit 4~6 times fail.<br><br>Did you try the test case with patch V3(in=
 my branch)?<br><a href=3D"https://github.com/wangli5665/ltp/commit/198fca8=
9870c1b807a01b27bb1d2ec6e2af1c7b6">https://github.com/wangli5665/ltp/commit=
/198fca89870c1b807a01b27bb1d2ec6e2af1c7b6</a><br><br># git clone <a href=3D=
"https://github.com/wangli5665/ltp">https://github.com/wangli5665/ltp</a> l=
tp.wangli --depth=3D1<br># cd ltp.wangli/; make autotools;<br># ./configure=
 ; make -j24<div><div class=3D"gmail_default" style=3D"font-size:small"># c=
d testcases/kernel/syscalls/move_pages/</div><div><div class=3D"gmail_defau=
lt" style=3D"font-size:small"># ./move_pages12=C2=A0</div>tst_test.c:1100: =
INFO: Timeout per run is 0h 05m 00s<br>move_pages12.c:249: INFO: Free RAM 6=
4386300 kB<br>move_pages12.c:267: INFO: Increasing 2048kB hugepages pool on=
 node 0 to 4<br>move_pages12.c:277: INFO: Increasing 2048kB hugepages pool =
on node 1 to 4<br>move_pages12.c:193: INFO: Allocating and freeing 4 hugepa=
ges on node 0<br>move_pages12.c:193: INFO: Allocating and freeing 4 hugepag=
es on node 1<br>move_pages12.c:183: PASS: Bug not reproduced<br>tst_test.c:=
1145: BROK: Test killed by SIGBUS!<br>move_pages12.c:117: FAIL: move_pages =
failed: ESRCH<br><div class=3D"gmail_default" style=3D"font-size:small"><br=
></div><div class=3D"gmail_default" style=3D"font-size:small"># uname -r</d=
iv>5.2.3<br><br></div><div># numactl -H<br>available: 4 nodes (0-3)<br>node=
 0 cpus: 0 1 2 3 4 5 6 7 32 33 34 35 36 37 38 39<br>node 0 size: 16049 MB<b=
r>node 0 free: 15736 MB<br>node 1 cpus: 8 9 10 11 12 13 14 15 40 41 42 43 4=
4 45 46 47<br>node 1 size: 16123 MB<br>node 1 free: 15850 MB<br>node 2 cpus=
: 16 17 18 19 20 21 22 23 48 49 50 51 52 53 54 55<br>node 2 size: 16123 MB<=
br>node 2 free: 15989 MB<br>node 3 cpus: 24 25 26 27 28 29 30 31 56 57 58 5=
9 60 61 62 63<br>node 3 size: 16097 MB<br>node 3 free: 15278 MB<br>node dis=
tances:<br>node =C2=A0 0 =C2=A0 1 =C2=A0 2 =C2=A0 3 <br>=C2=A0 0: =C2=A010 =
=C2=A020 =C2=A020 =C2=A020 <br>=C2=A0 1: =C2=A020 =C2=A010 =C2=A020 =C2=A02=
0 <br>=C2=A0 2: =C2=A020 =C2=A020 =C2=A010 =C2=A020 <br>=C2=A0 3: =C2=A020 =
=C2=A020 =C2=A020 =C2=A010 <br><br>&gt; Also, the <span class=3D"gmail_defa=
ult" style=3D"font-size:small"></span>soft_offline_huge_page() code should =
not come into play with<br>&gt; this specific test.</div><div><br><div clas=
s=3D"gmail_default" style=3D"font-size:small">I got the &quot;soft offline =
xxx..=C2=A0<span class=3D"gmail_default"></span>hugepage failed to isolate&=
quot; message from=C2=A0<span class=3D"gmail_default"></span>soft_offline_h=
uge_page() in dmesg log.</div><div class=3D"gmail_default" style=3D"font-si=
ze:small"><br></div><div class=3D"gmail_default" style=3D"font-size:small">=
=3D=3D=3D debug print info =3D=3D=3D</div><div class=3D"gmail_default" styl=
e=3D"font-size:small">--- a/mm/memory-failure.c<br>+++ b/mm/memory-failure.=
c<br>@@ -1701,7 +1701,7 @@ static int soft_offline_huge_page(struct page *p=
age, int flags)<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/<br>=C2=A0 =C2=A0 =
=C2=A0 =C2=A0 put_hwpoison_page(hpage);<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (=
!ret) {<br>- =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pr_info(&quot=
;soft offline: %#lx hugepage failed to isolate\n&quot;, pfn);<br>+ =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pr_info(&quot;liwang -- soft offl=
ine: %#lx hugepage failed to isolate\n&quot;, pfn);<br>=C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EBUSY;<br>=C2=A0 =C2=A0 =C2=A0 =
=C2=A0 }<br></div><br><div class=3D"gmail_default" style=3D"font-size:small=
"># dmesg</div><div class=3D"gmail_default" style=3D"font-size:small">...</=
div><div class=3D"gmail_default" style=3D"font-size:small">[ 1068.947205] S=
oft offlining pfn 0x40b200 at process virtual address 0x7f9d8d000000</div>[=
 1068.987054] Soft offlining pfn 0x40ac00 at process virtual address 0x7f9d=
8d200000<br>[ 1069.048478] Soft offlining pfn 0x40a800 at process virtual a=
ddress 0x7f9d8d000000<br>[ 1069.087413] Soft offlining pfn 0x40ae00 at proc=
ess virtual address 0x7f9d8d200000<br>[ 1069.123285] liwang -- soft offline=
: 0x40ae00 <span class=3D"gmail_default" style=3D"font-size:small"></span>h=
ugepage failed to isolate<br>[ 1069.160137] Soft offlining pfn 0x80f800 at =
process virtual address 0x7f9d8d000000<br>[ 1069.196009] Soft offlining pfn=
 0x80fe00 at process virtual address 0x7f9d8d200000<br>[ 1069.243436] Soft =
offlining pfn 0x40a400 at process virtual address 0x7f9d8d000000<br>[ 1069.=
281301] Soft offlining pfn 0x40a600 at process virtual address 0x7f9d8d2000=
00<br>[ 1069.318171] liwang -- soft offline: 0x40a600 hugepage failed to is=
olate<br><br>-- <br>Regards,<br>Li Wang</div></div><div><br></div></div>

--000000000000f292b6058ee020fb--

