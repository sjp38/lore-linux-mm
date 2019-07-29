Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	HTML_MESSAGE,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5C51C76186
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 05:17:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 419352070D
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 05:17:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 419352070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 908A08E0003; Mon, 29 Jul 2019 01:17:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B9068E0002; Mon, 29 Jul 2019 01:17:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A8D78E0003; Mon, 29 Jul 2019 01:17:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id 56C548E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 01:17:39 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id a4so25973776vki.23
        for <linux-mm@kvack.org>; Sun, 28 Jul 2019 22:17:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :from:date:message-id:subject:to:cc;
        bh=fcCv9MHNIF4hI0relbpOiFS7M9UJhROw7Nzfv6sRNyY=;
        b=t81LWbyklVTzYEschG8rvfqOT3cjUQyCcwqpVSB2154CX+k/3OIh+GDG76vF/HaBRV
         D1dFycMZSwKcov7ZPIi6uy/lCzZT3W1cmcyqBsGKBUug+6ofXkOjC0PEWNwQ6Mbl6DfI
         zdCOW5IG5SSit8XAGRv0RVmJnX4iX3SC+FyOhVSg1yUR5L7Q3ZdnezJySs8j8pGXbgxb
         7Ai1tezZn1+5F9i9v3iZOkaPEtaQMrggWy0qYuK/433jACti2mHmMJn5swINwYdLnAMu
         wpHsWncgN6XpUmu/pk0crs277u4EH5eYT3aZLOt1RT466ewJxk3wkHw8ToOvOHSmmmam
         2J6w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of liwan@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=liwan@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXLuInCS3yTWg5Qh9Nqd8GyX9fm94pdLG4yt2sEePRa+UAl9Wr2
	/ob75FGltD+zwxt07ckEN7u23yMOzsCcdK3u4BcG9kSw46Z3vJ9PKpslyattdLJJsbA9cZq+PZI
	XHiI2N/bTMmRk1EtN7BuROGhGCeOz8oTat7tsh4A83YtdP5aEMgAlTMIFrE1lhWg7ig==
X-Received: by 2002:a9f:3208:: with SMTP id x8mr21786209uad.49.1564377459049;
        Sun, 28 Jul 2019 22:17:39 -0700 (PDT)
X-Received: by 2002:a9f:3208:: with SMTP id x8mr21786192uad.49.1564377458288;
        Sun, 28 Jul 2019 22:17:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564377458; cv=none;
        d=google.com; s=arc-20160816;
        b=qsv91zRJkdoHe/cHczv+1oZ3wVFICUhZwl7diEPSTOg7h0eMJgOJrt0vbDjzYiVYQk
         a1jDnXMwGGod0t4yRmB4SivcaGOewMv3jd6guUmzuFbbboQoAhEXujXGVlEoelEnMElE
         TwiyX/PhjLUcFTkEeQMGLvg+78hYsBY0BmG3QgUVq7tJaTlxs/na/OfTy0WsRPlcFQjO
         rjKUkzzg3fTu8Cfy5JTS/W53v28yZkBg7LzWMZMBZRr9TcLRWHCZpVrHtcepYdZXNXyw
         eu+spSFbDiZcnI4dPj7WmLVcj+I64W5VBsZXNdoMWT++5G5MnzgwPWYVFysE4P0DMgDW
         FK/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:mime-version;
        bh=fcCv9MHNIF4hI0relbpOiFS7M9UJhROw7Nzfv6sRNyY=;
        b=Gqq5zwpcd4gfMSDCHgni2C1B71Z47rFOmS0s2ki2um6XVchyxdsm5YyZ2kDLXJQKE1
         A3q0mPudDvQCrTwN5ZRVYZKNHg8UjeUcKS9ccVWczSAILpDmh1lLRC2bO8tMjraSOJCR
         W8KSGEr5quIg8ViqtcZv+FQjnQuy9NpKEr2+t0THzkopj53wpFEF9XJn4NhsyaOUsUFu
         J1YTA8ZrAwO1fruTnQPpJxhaLrtRothngg/D691viVS/a74HhwG7tH3DzkEdrgbU7UFU
         FEpa98lzj/7mJF46OQfKAqGxzUjQ6Efb6dQSwV0CC0bndmzYi5QnZfwr3D3kITzZYGQT
         9z9g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of liwan@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=liwan@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l190sor17655771vkl.34.2019.07.28.22.17.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 28 Jul 2019 22:17:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of liwan@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of liwan@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=liwan@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqx2I1JxcgzwrYX7T6dYEg9Pz76lPdDf0MccfC7TFcONppQXR3mBKv1aYlv2uDv5cXvBFit+fGSpSlBAImdVNRQ=
X-Received: by 2002:a1f:2117:: with SMTP id h23mr4058435vkh.91.1564377457785;
 Sun, 28 Jul 2019 22:17:37 -0700 (PDT)
MIME-Version: 1.0
From: Li Wang <liwang@redhat.com>
Date: Mon, 29 Jul 2019 13:17:27 +0800
Message-ID: <CAEemH2dMW6oh6Bbm=yqUADF+mDhuQgFTTGYftB+xAhqqdYV3Ng@mail.gmail.com>
Subject: =?UTF-8?Q?=5BMM_Bug=3F=5D_mmap=28=29_triggers_SIGBUS_while_doing_the=E2=80=8B_?=
	=?UTF-8?Q?=E2=80=8Bnuma=5Fmove=5Fpages=28=29_for_offlined_hugepage_in_background?=
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Linux-MM <linux-mm@kvack.org>, LTP List <ltp@lists.linux.it>, mike.kravetz@oracle.com, 
	xishi.qiuxishi@alibaba-inc.com, mhocko@kernel.org, 
	Cyril Hrubis <chrubis@suse.cz>
Content-Type: multipart/alternative; boundary="000000000000aa9fe5058ecb0227"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--000000000000aa9fe5058ecb0227
Content-Type: text/plain; charset="UTF-8"

Hi Naoya and Linux-MMers,

The LTP/move_page12 V2 triggers SIGBUS in the kernel-v5.2.3 testing.
https://github.com/wangli5665/ltp/blob/master/testcases/kernel/syscalls/move_pages/move_pages12.c

It seems like the retry mmap() triggers SIGBUS while doing the
numa_move_pages()
in background. That is very similar to the kernel bug which was mentioned
by commit 6bc9b56433b76e40d(mm: fix race on soft-offlining ): A race
condition between soft offline and hugetlb_fault which causes unexpected
process SIGBUS killing.

I'm not sure if that below patch is making sene to memory-failures.c, but after
building a new kernel-5.2.3 with this change, the problem can NOT be
reproduced.

Any comments?

----------------------------------
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1695,15 +1695,16 @@ static int soft_offline_huge_page(struct page
*page, int flags)
        unlock_page(hpage);

        ret = isolate_huge_page(hpage, &pagelist);
+       if (!ret) {
+               pr_info("soft offline: %#lx hugepage failed to isolate\n",
pfn);
+               return -EBUSY;
+       }
+
        /*
         * get_any_page() and isolate_huge_page() takes a refcount each,
         * so need to drop one here.
         */
        put_hwpoison_page(hpage);
-       if (!ret) {
-               pr_info("soft offline: %#lx hugepage failed to isolate\n",
pfn);
-               return -EBUSY;
-       }


----- test on kernel-v5.2.3 ------
# ./move_pages12
tst_test.c:1100: INFO: Timeout per run is 0h 05m 00s
move_pages12.c:251: INFO: Free RAM 194212832 kB
move_pages12.c:269: INFO: Increasing 2048kB hugepages pool on node 0 to 4
move_pages12.c:279: INFO: Increasing 2048kB hugepages pool on node 1 to 6
move_pages12.c:195: INFO: Allocating and freeing 4 hugepages on node 0
move_pages12.c:195: INFO: Allocating and freeing 4 hugepages on node 1
move_pages12.c:185: PASS: Bug not reproduced
tst_test.c:1145: BROK: Test killed by SIGBUS!
move_pages12.c:114: FAIL: move_pages failed: ESRCH

----- test on kernel-v5.2.3  + above patch------
# ./move_pages12
tst_test.c:1100: INFO: Timeout per run is 0h 05m 00s
move_pages12.c:252: INFO: Free RAM 64780164 kB
move_pages12.c:270: INFO: Increasing 2048kB hugepages pool on node 0 to 7
move_pages12.c:280: INFO: Increasing 2048kB hugepages pool on node 1 to 10
move_pages12.c:196: INFO: Allocating and freeing 4 hugepages on node 0
move_pages12.c:196: INFO: Allocating and freeing 4 hugepages on node 1
move_pages12.c:186: PASS: Bug not reproduced
move_pages12.c:186: PASS: Bug not reproduced
--
Regards,
Li Wang

--000000000000aa9fe5058ecb0227
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi <span class=3D"gmail_default" style=3D"font-size:small"=
>Naoya and Linux-MMers,</span><br><br>The LTP/move_page12 V2 triggers SIGBU=
S in the kernel-v5.2.3 testing. <br><a href=3D"https://github.com/wangli566=
5/ltp/blob/master/testcases/kernel/syscalls/move_pages/move_pages12.c">http=
s://github.com/wangli5665/ltp/blob/master/testcases/kernel/syscalls/move_pa=
ges/move_pages12.c<br></a><br>It seems like=C2=A0<span class=3D"gmail_defau=
lt" style=3D"font-size:small">the</span> retry mmap() triggers SIGBUS while=
 doing the<span class=3D"gmail_default" style=3D"font-size:small"> </span>n=
uma_move_pages() in background. That is very similar to the kernel<span cla=
ss=3D"gmail_default"> </span>bug which was mentioned by commit 6bc9b56433b7=
6e40d(mm: fix race on<span class=3D"gmail_default"> </span>soft-offlining )=
<span class=3D"gmail_default" style=3D"font-size:small">:</span> A race con=
dition between soft offline and<span class=3D"gmail_default"> </span>hugetl=
b_fault which causes unexpected process SIGBUS killing.<div><br>I&#39;m not=
 sure if that below <span class=3D"gmail_default" style=3D"font-size:small"=
>patch </span>is making sene to memory-failures.c, but <span class=3D"gmail=
_default" style=3D"font-size:small">after </span>building a <span class=3D"=
gmail_default" style=3D"font-size:small">new </span>kernel-5.2.3 with <span=
 class=3D"gmail_default" style=3D"font-size:small">this change</span>, the =
problem <span class=3D"gmail_default" style=3D"font-size:small">can NOT be =
reproduced</span>.=C2=A0</div><div><br></div><div>Any comments?<br></div><d=
iv><br>----------------------------------<br>--- a/mm/memory-failure.c<br>+=
++ b/mm/memory-failure.c<br>@@ -1695,15 +1695,16 @@ static int soft_offline=
_huge_page(struct page *page, int flags)<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 unl=
ock_page(hpage);<br><br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D isolate_huge_pa=
ge(hpage, &amp;pagelist);<br>+ =C2=A0 =C2=A0 =C2=A0 if (!ret) {<br>+ =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pr_info(&quot;soft offline: %#lx=
 hugepage failed to isolate\n&quot;, pfn);<br>+ =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 return -EBUSY;<br>+ =C2=A0 =C2=A0 =C2=A0 }<br>+<br>=
=C2=A0 =C2=A0 =C2=A0 =C2=A0 /*<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* get_a=
ny_page() and isolate_huge_page() takes a refcount each,<br>=C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0* so need to drop one here.<br>=C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0*/<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 put_hwpoison_page(hpage);<br>- =
=C2=A0 =C2=A0 =C2=A0 if (!ret) {<br>- =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 pr_info(&quot;soft offline: %#lx hugepage failed to isolate\n=
&quot;, pfn);<br>- =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return =
-EBUSY;<br>- =C2=A0 =C2=A0 =C2=A0 }<br><br><div class=3D"gmail_default" sty=
le=3D"font-size:small"><br></div><div class=3D"gmail_default" style=3D"font=
-size:small">----- test on kernel-v5.2.3 ------</div># ./move_pages12<br>ts=
t_test.c:1100: INFO: Timeout per run is 0h 05m 00s<br>move_pages12.c:251: I=
NFO: Free RAM 194212832 kB<br>move_pages12.c:269: INFO: Increasing 2048kB h=
ugepages pool on node 0 to 4<br>move_pages12.c:279: INFO: Increasing 2048kB=
 hugepages pool on node 1 to 6<br>move_pages12.c:195: INFO: Allocating and =
freeing 4 hugepages on node 0<br>move_pages12.c:195: INFO: Allocating and f=
reeing 4 hugepages on node 1<br>move_pages12.c:185: PASS: Bug not reproduce=
d<br>tst_test.c:1145: BROK: Test killed by SIGBUS!<br>move_pages12.c:114: F=
AIL: move_pages failed: ESRCH<div><br></div><div><div class=3D"gmail_defaul=
t" style=3D"font-size:small">----- test on kernel-v5.2.3=C2=A0 + above patc=
h------</div></div><div class=3D"gmail_default" style=3D"font-size:small">#=
 ./move_pages12=C2=A0</div>tst_test.c:1100: INFO: Timeout per run is 0h 05m=
 00s<br>move_pages12.c:252: INFO: Free RAM 64780164 kB<br>move_pages12.c:27=
0: INFO: Increasing 2048kB hugepages pool on node 0 to 7<br>move_pages12.c:=
280: INFO: Increasing 2048kB hugepages pool on node 1 to 10<br>move_pages12=
.c:196: INFO: Allocating and freeing 4 hugepages on node 0<br>move_pages12.=
c:196: INFO: Allocating and freeing 4 hugepages on node 1<br>move_pages12.c=
:186: PASS: Bug not reproduced<br>move_pages12.c:186: PASS: Bug not reprodu=
ced<br><div class=3D"gmail_default" style=3D"font-size:small"></div>--<br>R=
egards,<br>Li Wang</div></div>

--000000000000aa9fe5058ecb0227--

