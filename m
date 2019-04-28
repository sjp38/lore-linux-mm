Return-Path: <SRS0=7ROk=S6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DATE_IN_PAST_03_06,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D6A8C4321A
	for <linux-mm@archiver.kernel.org>; Sun, 28 Apr 2019 18:09:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7CC682067C
	for <linux-mm@archiver.kernel.org>; Sun, 28 Apr 2019 18:09:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZnQfGnJh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CC682067C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED0286B0005; Sun, 28 Apr 2019 14:09:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E5AB36B0006; Sun, 28 Apr 2019 14:09:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF5566B0007; Sun, 28 Apr 2019 14:09:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id AAFE66B0005
	for <linux-mm@kvack.org>; Sun, 28 Apr 2019 14:09:01 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id l85so4392012vke.15
        for <linux-mm@kvack.org>; Sun, 28 Apr 2019 11:09:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=6G87Dj6yZ5aVii9cRIgIUe0la0ajlwk3ddJZEG1C8NA=;
        b=EDKEs4GMsVS4Dzhvpbz6oBuUGqgJ9zth9ab9J3mwlEAkJaMPZqbZxYOnQoQXgLgQYk
         ZHpS+TmAx/diUEadHdJjzseVlV6uNbyh91qRle3lNxLGEzAXhfFHlB1cRXk3G4F5HHfC
         Pn5dX7ePgkxyKb4bkVrqHRdK6kgzq6QV+NIg+qmGlFtNtLdx+uUo2OkWr79EqA26aTNl
         1E15pbZfpOPmaxoY8ct8gDa8+P5/Oi+4oz+KHlr8uz7VqLnvPld5vZQ53+1nlmpS3CuA
         Href/y2tEbBrdhCM+8qJoqAXD9ztI3QXu5ouyrlOpa6LhWHk14dUmeOqVXsgwZYoMfay
         e/8w==
X-Gm-Message-State: APjAAAUt+5ewmrIwRb7PELyNzmlTVOyt7DYQUWvcPe8aT14MIkpmshab
	e3+lg9Ivb7nGg8K0HZYuUNABN8RIfQyfnGnKsLJgjDIKWNX0zAQXZNjc5w1XxCI8nrk/rQfsB9i
	Wuqb0fYZfZjtc9JNFY1PdafpiQqwsDH/t2EftJDwRAVPO3TiP21b7QeQVVIE1LMkBVw==
X-Received: by 2002:a67:ec8c:: with SMTP id h12mr13955932vsp.28.1556474941195;
        Sun, 28 Apr 2019 11:09:01 -0700 (PDT)
X-Received: by 2002:a67:ec8c:: with SMTP id h12mr13955795vsp.28.1556474938448;
        Sun, 28 Apr 2019 11:08:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556474938; cv=none;
        d=google.com; s=arc-20160816;
        b=LMjBQ6U2UXaZR3ygCSw0ghsaQAb476NIO2L5/jWRG/reEtpKkkPw2PCl6kEeabHFaA
         cD6/N8DF/9CgoomIhA7+mJeZKqAOn0cdRiXzhUr4Nlqs7X7vwXjoSV9uz1SPRYkSdJ1P
         Mjt+94Sa6jprsk8MbY2aHx/gpBV5iaDA/rIlQm8ZWERtTtuyJvR+Q2378LXBooKqy+Nf
         ciK0u+uDWsS01FVB8ejBp4NQPSgfNk2/PE6iC587UeYM7hftS4PwomTtjkafOC9fm9Tn
         d/bwKTSR7zyrk7pVw8NxoUmj7vvted3F7GUY27w2O/MV/wppPuAr266ba6BYlgvFiZCL
         1+mg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=6G87Dj6yZ5aVii9cRIgIUe0la0ajlwk3ddJZEG1C8NA=;
        b=QLXL7Xdyq/OGbSdRnfQnk1l+7E5AjSeXW6jlbVyR06cjWdfNb1na1rr7EE3xJTdCIQ
         PJuePbEvOtjqXqOLiOo+IPJk+/RJHKPETUU8/breeMtn1G0oTYeUdPEZwmTBHQw/F2NH
         +BEeqZJn4ExbUk6+/6cxGwXh+J8lhXYKBCXy0zAO3LqyOnJtCsuyHf9VJUWoyEO119D1
         h5aPLNaDbjg11jDI9YK3+m4YYyLmejXCEy7zPUTO4ZmnbEXa7UIfiPu7U9+gaVM5o36x
         aa095rZYTNM8Etnlt14bUWG7O/HYy+0LuAin8rHJ60tP2CYdIQRRz91UuEbQXd+/UpzD
         wkbg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZnQfGnJh;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n40sor15935087uae.0.2019.04.28.11.08.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 28 Apr 2019 11:08:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZnQfGnJh;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=6G87Dj6yZ5aVii9cRIgIUe0la0ajlwk3ddJZEG1C8NA=;
        b=ZnQfGnJhgadrN1ERyoI0D3sE/f1JZH3BxGke+NQzUWMS15fJNuWpEH8iLxINCGS+bH
         cNuUGIyZgaZ7jNo4xJhXZgwaIpNWel6bsNX86ZZD5wnEIBKIGgTcpLC81xqC8gxx5MuR
         L8fxXtGU5sknAaugTst89WHsuRuvygBoMfrLTle5viMNkRQ2Uh29QHsHwDPvcU8Q0vyY
         aXWnJBkFwXef6h5k6F3cIbdIfMokIp1zhrGrgQNsZ8KVmciBnEW6Q3UszRe8t2fbzCck
         Lf5XBdixDl0xdCk3IkaiwwnGetIQw2l+Og/V3/DOI7Gv8vdU39qm4YNnW515ov+2Kh+5
         oj9g==
X-Google-Smtp-Source: APXvYqztBunzgDMU+QBdrWpiTzWuASctO5Lg8sb1XlmOqFY2WXHajd5RH1Jasu0yRnTpr+5bl2ZMdrsqcFbQkD/jdOI=
X-Received: by 2002:ab0:7319:: with SMTP id v25mr28203118uao.1.1556474936692;
 Sun, 28 Apr 2019 11:08:56 -0700 (PDT)
MIME-Version: 1.0
References: <CACDBo57pEVRjOBf0yLMQ+KuGPeOuFcMufGVzjPJVnwfLFjzFSA@mail.gmail.com>
 <9b1ace64-c4cc-b0b3-f864-c96124137853@suse.cz>
In-Reply-To: <9b1ace64-c4cc-b0b3-f864-c96124137853@suse.cz>
From: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>
Date: Sun, 28 Apr 2019 18:08:49 +0530
Message-ID: <CACDBo56Ui52G=Uoai=GFzAgh3nLBrewGbWo7keW6Yt-0J++CNA@mail.gmail.com>
Subject: Re: vmscan.c: Reclaim unevictable pages.
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	kernelnewbies@kernelnewbies.org, Michal Hocko <mhocko@kernel.org>, minchan@kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 5:12 PM Vlastimil Babka <vbabka@suse.cz> wrote:
>
> On 4/6/19 7:59 AM, Pankaj Suryawanshi wrote:
> > Hello ,
> >
> > shrink_page_list() returns , number of pages reclaimed, when pages is
> > unevictable it returns VM_BUG_ON_PAGE(PageLRU(page) ||
> > PageUnevicatble(page),page);
> >
> > We can add the unevictable pages in reclaim list in
> > shrink_page_list(), return total number of reclaim pages including
> > unevictable pages, let the caller handle unevictable pages.
> >
> > I think the problem is shrink_page_list is awkard. If page is
> > unevictable it goto activate_locked->keep_locked->keep lables, keep
> > lable list_add the unevictable pages and throw the VM_BUG instead of
> > passing it to caller while it relies on caller for
> > non-reclaimed-non-unevictable  page's putback.
> > I think we can make it consistent so that shrink_page_list could
> > return non-reclaimed pages via page_list and caller can handle it. As
> > an advance, it could try to migrate mlocked pages without retrial.
> >
> >
> > Below is the issue i observed of CMA_ALLOC of large size buffer :
> > (Kernel version - 4.14.65 With Android Pie.
> >
> > [   24.718792] page dumped because: VM_BUG_ON_PAGE(PageLRU(page) ||
> > PageUnevictable(page))
> > [   24.726949] page->mem_cgroup:bd008c00
> > [   24.730693] ------------[ cut here ]------------
> > [   24.735304] kernel BUG at mm/vmscan.c:1350!
> > [   24.739478] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP ARM
>
> Please include full report including the full stacktrace, kernel version
> etc etc.

As mention above
kernel version- 4.14.65 for Android pie.

Memory Configuration:
RAM= 2GB, No swaps
CMA reserved = 1GB
Max CMA chunk allocation at one time is 400MB and 400MB

Full stacktrace is as below.

[   35.301071] cma_alloc: cma alloc try name(video) size(0x17c00000)
[   35.312528] page:bf05febc count:55 mapcount:53 mapping:bc8241dc index:0x0
[   35.319405] flags:
0x8019040c(referenced|uptodate|arch_1|mappedtodisk|unevictable|mlocked)
[   35.327682] raw: 8019040c bc8241dc 00000000 00000034 00000037
b9c6fa98 b9c6fa98 00000000
[   35.335981] raw: bd008c00
[   35.339145] page dumped because: VM_BUG_ON_PAGE(PageLRU(page) ||
PageUnevictable(page))
[   35.348402] page->mem_cgroup:bd008c00
[   35.353531] ------------[ cut here ]------------
[   35.358155] kernel BUG at mm/vmscan.c:1350!
[   35.362345] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP ARM
[   35.368185] Modules linked in: vpu_4k_d2_dev jpu_dev vpu
vpu_4k_d2_lib_arm_v4_14(PO) jpu_c6_lib_arm_v4_14(PO)
vpu_d6_lib_arm_v4_14(PO)
[   35.380303] CPU: 1 PID: 3710 Comm: HwBinder:1888_3 Tainted: P
    O    4.14.65-tcc #120
[   35.388823] Hardware name: Android (Flattened Device Tree)
[   35.395182] task: bdd4f080 task.stack: b9c6e000
[   35.399728] PC is at shrink_page_list+0x448/0x106c
[   35.404521] LR is at irq_work_queue+0xc0/0xd4
[   35.408882] pc : [<80360a58>]    lr : [<80313548>]    psr: 60070013
[   35.415147] sp : b9c6fa48  ip : b9c6f8b0  fp : b9c6fafc
[   35.420364] r10: 00000000  r9 : bc8666fc  r8 : b9c6fb0c
[   35.425581] r7 : b9c6fb14  r6 : 00000001  r5 : bf05febc  r4 : bf05fed0
[   35.432101] r3 : 5725f132  r2 : 5725f132  r1 : be57a4f4  r0 : 00000019
[   35.438622] Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment none
[   35.445751] Control: 30c5383d  Table: 5b1dce00  DAC: 00000000
[   35.451488]
[   35.451488] PC: 0x803609d8:
[   35.455750] 09d8
[   35.455753]  ee1d1f90
[   35.457671]  e28330c8
[   35.459934]  e7912003
[   35.462197]  e2822001
[   35.464460]  e7812003
[   35.466723]  e121f000
[   35.468986]  e1a00005
[   35.471249]  ebff8a31
[   35.473512]
[   35.477254] 09f8
[   35.477256]  e51b3064
[   35.479172]  e24b2064
[   35.481435]  e5834004
[   35.483699]  e5843000
[   35.485961]  e50b4064
[   35.488224]  e5943000
[   35.490489]  e5842004
[   35.492752]  e3130001
[   35.495015]
[   35.498759] 0a18
[   35.498762]  12433001
[   35.500678]  01a03005
[   35.502943]  e5933000
[   35.505205]  e3130020
[   35.507469]  1a000006
[   35.509732]  e5943000
[   35.511995]  e3130001
[   35.514258]  12433001
[   35.516521]
[   35.520262] 0a38
[   35.520264]  01a03005
[   35.522180]  e5933000
[   35.524444]  e3130702
[   35.526707]  0affff1b
[   35.528970]  e30a13f8
[   35.531233]  e1a00005
[   35.533496]  e34810e0
[   35.535759]  eb0074a8
[   35.538021]
[   35.541763] 0a58
[   35.541766]  e7f001f2
[   35.543681]  e3500000
[   35.545944]  0a000012
[   35.548207]  e5990000
[   35.550470]  e3500000
[   35.552733]  0a000096
[   35.554996]  e3063b04
[   35.557260]  e590201c
[   35.559523]
[   35.563265] 0a78
[   35.563267]  e3483121
[   35.565183]  e5933000
[   35.567446]  e1520003
[   35.569709]  1592108c
[   35.571972]  0a000260
[   35.574237]  e5912038
[   35.576500]  e5923010
[   35.578763]  e3530000
[   35.581025]
[   35.584766] 0a98
[   35.584769]  0a000091
[   35.586684]  e5920014
[   35.588947]  e3a01001
[   35.591212]  e12fff33
[   35.593475]  e3500000
[   35.595738]  1a000009
[   35.598001]  e55b3065
[   35.600264]  e3530000
[   35.602527]
[   35.606270] 0ab8
[   35.606272]  0affff76
[   35.608188]  e5943000
[   35.610452]  e3130001
[   35.612714]  12433001
[   35.614977]  01a03005
[   35.617240]  e5933000
[   35.619503]  e3130802
[   35.621766]  0affff6f
[   35.624029]
[   35.627772]
[   35.627772] LR: 0x803134c8:
[   35.632032] 34c8
[   35.632034]  e2840004
[   35.633950]  e3072dc8
[   35.636213]  ee1d3f90
[   35.638476]  e3482108
[   35.640740]  e1a01000
[   35.643003]  e0832002
[   35.645266]  eb099041
[   35.647529]  e3500000
[   35.649792]
[   35.653533] 34e8
[   35.653536]  1a000018
[   35.655452]  e1a0300d
[   35.657716]  e3c33d7f
[   35.659978]  e3c3303f
[   35.662241]  e5932004
[   35.664504]  e2422001
[   35.666767]  e5832004
[   35.669030]  e3520000
[   35.671293]
[   35.675035] 3508
[   35.675037]  1a000003
[   35.676953]  e5933000
[   35.679216]  e3130002
[   35.681480]  0a000000
[   35.683742]  eb22c35a
[   35.686006]  e1a00005
[   35.688269]  e89da830
[   35.690533]  e2840004
[   35.692795]
[   35.696537] 3528
[   35.696539]  e59f2028
[   35.698455]  ee1d3f90
[   35.700718]  e1a01000
[   35.702981]  e0832002
[   35.705244]  eb09902b
[   35.707508]  e3500000
[   35.709772]  0affffe9
[   35.712035]  ebfe905c
[   35.714297]
[   35.718039] 3548
[   35.718042]  e3500000
[   35.719957]  0affffe6
[   35.722221]  ebfbf71b
[   35.724485]  eaffffe4
[   35.726748]  81087dcc
[   35.729011]  e1a0c00d
[   35.731274]  e92dd818
[   35.733537]  e24cb004
[   35.735799]
[   35.739540] 3568
[   35.739542]  e3070dc8
[   35.741458]  e1a0300d
[   35.743722]  e3480108
[   35.745985]  e2802004
[   35.748248]  ee1dcf90
[   35.750511]  e79c1000
[   35.752774]  e3510000
[   35.755037]  0a000004
[   35.757301]
[   35.761042] 3588
[   35.761045]  e30e1380
[   35.762960]  e3481121
[   35.765224]  e5911000
[   35.767486]  e3510000
[   35.769749]  0a000002
[   35.772012]  e79c0002
[   35.774275]  e3500000
[   35.776538]  089da818
[   35.778801]
[   35.782543] 35a8
[   35.782545]  e3c33d7f
[   35.784460]  e30625b4
[   35.786723]  e3c3303f
[   35.788986]  e3482121
[   35.791251]  e5933010
[   35.793514]  e3530000
[   35.795777]  e283101f
[   35.798040]  e203001f
[   35.800303]
[   35.804044]
[   35.804044] SP: 0xb9c6f9c8:
[   35.808305] f9c8
[   35.808307]  bf05fed0
[   35.810224]  bf05febc
[   35.812487]  00000001
[   35.814751]  b9c6fb14
[   35.817013]  b9c6fb0c
[   35.819277]  bc8666fc
[   35.821539]  00000000
[   35.823804]  b9c6fafc
[   35.826066]
[   35.829807] f9e8
[   35.829810]  b9c6f8b0
[   35.831726]  b9c6fa48
[   35.833988]  80313548
[   35.836251]  80360a58
[   35.838514]  60070013
[   35.840778]  ffffffff
[   35.843042]  5725f132
[   35.845305]  7f000000
[   35.847567]
[   35.851309] fa08
[   35.851312]  00000004
[   35.853227]  bf05febc
[   35.855490]  00000024
[   35.857754]  00000000
[   35.860017]  00000100
[   35.862280]  bf05fed0
[   35.864543]  bf05febc
[   35.866806]  00000001
[   35.869069]
[   35.872811] fa28
[   35.872814]  b9c6fa44
[   35.874730]  b9c6fa38
[   35.876994]  8037dd0c
[   35.879257]  8037db40
[   35.881520]  b9c6fafc
[   35.883782]  b9c6fa48
[   35.886046]  80360a58
[   35.888309]  8037dd08
[   35.890573]
[   35.894315] fa48
[   35.894317]  81216588
[   35.896233]  00000001
[   35.898496]  814230ec
[   35.900759]  810881c0
[   35.903022]  81216588
[   35.905286]  00000000
[   35.907551]  00000010
[   35.909814]  00000005
[   35.912076]
[   35.915817] fa68
[   35.915820]  8141d980
[   35.917735]  00000000
[   35.919998]  00000000
[   35.922261]  8122b7a0
[   35.924525]  00000001
[   35.926788]  00000000
[   35.929051]  00000000
[   35.931314]  00000000
[   35.933576]
[   35.937317] fa88
[   35.937320]  00000000
[   35.939235]  00000000
[   35.941500]  00069fc9
[   35.943763]  00000000
[   35.946025]  bf05fed0
[   35.948288]  bf05fed0
[   35.950551]  bf05ff18
[   35.952814]  bf05fff0
[   35.955076]
[   35.958820] faa8
[   35.958822]  0006a000
[   35.960738]  00000002
[   35.963001]  bf05ffdc
[   35.965277]  00000000
[   35.967552]  bf05fb80
[   35.969817]  b9c6fb94
[   35.972081]  b9c6fb44
[   35.974345]  b9c6fad0
[   35.976608]
[   35.980370]
[   35.980370] IP: 0xb9c6f830:
[   35.984632] f830
[   35.984634]  8020a348
[   35.986550]  80209d18
[   35.988813]  00000000
[   35.991079]  80df2c20
[   35.993342]  80df2a40
[   35.995606]  b9c6f850
[   35.997869]  80288ba8
[   36.000134]  61542020
[   36.002407]
[   36.006171] f850
[   36.006176]  3a656c62
[   36.008094]  31623520
[   36.010359]  30656364
[   36.012627]  44202030
[   36.014893]  203a4341
[   36.017158]  30303030
[   36.019423]  30303030
[   36.021688]  80288b00
[   36.023953]
[   36.027697] f870
[   36.027700]  80df36fc
[   36.029618]  8146f038
[   36.031883]  00000000
[   36.034148]  00000000
[   36.036413]  294f5028
[   36.038678]  80df3700
[   36.040954]  00000000
[   36.043224]  5725f132
[   36.045490]
[   36.049235] f890
[   36.049239]  0000000b
[   36.051160]  b9c6f9b8
[   36.053428]  80df378c
[   36.055694]  00000000
[   36.057961]  60070093
[   36.060230]  81447c1c
[   36.062501]  b9c6f8ec
[   36.064767]  b9c6f8b8
[   36.067031]
[   36.070772] f8b0
[   36.070775]  8020e154
[   36.072691]  80209e64
[   36.074956]  00000000
[   36.077219]  0000000b
[   36.079482]  80287520
[   36.081745]  b9c6f9b8
[   36.084009]  80360a58
[   36.086273]  81216588
[   36.088538]
[   36.092282] f8d0
[   36.092285]  e7f001f2
[   36.094200]  00000000
[   36.096464]  80bc9644
[   36.098727]  b9c6e000
[   36.100990]  b9c6f8fc
[   36.103253]  b9c6f8f0
[   36.105516]  8020e364
[   36.107780]  8020dee0
[   36.110043]
[   36.113784] f8f0
[   36.113786]  b9c6f9b4
[   36.115702]  b9c6f900
[   36.117965]  802010e0
[   36.120228]  8020e34c
[   36.122491]  00000006
[   36.124755]  00000000
[   36.127018]  00000000
[   36.129281]  00000004
[   36.131544]

[   36.135546] f910
[   36.135548]  00000000
[   36.137465]  00000001
[   36.139729]  80360a58
[   36.142007]  8144b358
[   36.144290]  b9c6f94c
[   36.146568]  00000019
[   36.148841]  00000000
[   36.151118]  8146dc8a
[   36.153386]
[   36.157135]
[   36.157135] FP: 0xb9c6fa7c:
[   36.161398] fa7c
[   36.161402]  00000000
[   36.163322]  00000000
[   36.165590]  00000000
[   36.167858]  00000000
[   36.170137]  00000000
[   36.172416]  00069fc9
[   36.174685]  00000000
[   36.176952]  bf05fed0
[   36.179227]
[   36.182980] fa9c
[   36.182984]  bf05fed0
[   36.184912]  bf05ff18
[   36.187180]  bf05fff0
[   36.189444]  0006a000
[   36.191708]  00000002
[   36.193971]  bf05ffdc
[   36.196234]  00000000
[   36.198497]  bf05fb80
[   36.200759]
[   36.204501] fabc
[   36.204503]  b9c6fb94
[   36.206418]  b9c6fb44
[   36.208682]  b9c6fad0
[   36.210945]  803785d8
[   36.213208]  5725f132
[   36.215471]  bf05f844
[   36.217734]  bf05ffb8
[   36.219997]  b9c6fb9c
[   36.222259]
[   36.226001] fadc
[   36.226004]  81216588
[   36.227919]  8141e100
[   36.230183]  b9c6fb0c
[   36.232446]  b9c6fb9c
[   36.234709]  b9c6fb88
[   36.236972]  b9c6fb6c
[   36.239234]  b9c6fb00
[   36.241499]  803617c8
[   36.243761]
[   36.247503] fafc
[   36.247505]  8036061c
[   36.249420]  00000000
[   36.251683]  00000001
[   36.253946]  00000020
[   36.256209]  bf05fc6c
[   36.258473]  bf05feac
[   36.260736]  00000000
[   36.262999]  014000c0
[   36.265261]
[   36.269002] fb1c
[   36.269004]  00000000
[   36.270920]  00000000
[   36.273182]  00000000
[   36.275446]  0000000c
[   36.277709]  00000000
[   36.279972]  00000002
[   36.282235]  00000007
[   36.284497]  00000000
[   36.286760]
[   36.290501] fb3c
[   36.290504]  5725f132
[   36.292420]  80379660
[   36.294683]  b9c6fb9c
[   36.296946]  00081a00
[   36.299208]  0006a000
[   36.301471]  b9c6e000
[   36.303734]  814790c4
[   36.305997]  8121e384
[   36.308260]
[   36.312001] fb5c
[   36.312003]  00000000
[   36.313919]  b9c6fc14
[   36.316182]  b9c6fb70
[   36.318445]  80352b2c
[   36.320708]  80361688
[   36.322971]  00000002
[   36.325234]  00000006
[   36.327497]  b9c6fb9c
[   36.329759]
[   36.333502]
[   36.333502] R1: 0xbe57a474:
[   36.337762] a474
[   36.337765]  00000004
[   36.339681]  00000000
[   36.341945]  00000000
[   36.344208]  00000000
[   36.346471]  00000000
[   36.348734]  00000000
[   36.350997]  00000000
[   36.353259]  0000000d
[   36.355522]
[   36.359264] a494
[   36.359266]  00000000
[   36.361182]  00000000
[   36.363445]  00000000
[   36.365708]  80268b30
[   36.367971]  00000000
[   36.370233]  00000000
[   36.372496]  00000000
[   36.374759]  00000000
[   36.377022]
[   36.380763] a4b4
[   36.380765]  00000000
[   36.382681]  bd009200
[   36.384944]  00000004
[   36.387207]  00000000
[   36.389469]  bd0a2dc0
[   36.391733]  00000000
[   36.393996]  00000000
[   36.396258]  00000000
[   36.398521]
[   36.402262] a4d4
[   36.402264]  00000000
[   36.404180]  517cca4f
[   36.406443]  00000002
[   36.408706]  50d6980c
[   36.410969]  00000000
[   36.413232]  be582a64
[   36.415495]  00000001
[   36.417757]  00000007
[   36.420020]
[   36.423762] a4f4
[   36.423764]  00000000
[   36.425679]  802886e8
[   36.427942]  00000000
[   36.430205]  00000000
[   36.432468]  00000000
[   36.434731]  00000000
[   36.436994]  80288c68
[   36.439256]  00000000
[   36.441519]
[   36.445260] a514
[   36.445263]  00000000
[   36.447178]  00000000
[   36.449441]  00000000
[   36.451703]  00000000
[   36.453966]  00000000
[   36.456229]  00000000
[   36.458493]  00000000
[   36.460756]  00000000
[   36.463019]
[   36.466760] a534
[   36.466762]  00000000
[   36.468678]  00000000
[   36.470941]  00000000
[   36.473204]  00000000
[   36.475467]  00000000
[   36.477730]  00000000
[   36.479993]  00000000
[   36.482256]  00000000
[   36.484519]
[   36.488260] a554
[   36.488262]  00000000
[   36.490179]  00000000
[   36.492442]  00000000
[   36.494705]  00000000
[   36.496968]  00000000
[   36.499231]  00000000
[   36.501494]  00000000
[   36.503756]  00000000
[   36.506019]
[   36.509761]
[   36.509761] R4: 0xbf05fe50:
[   36.514021] fe50
[   36.514024]  8001040c
[   36.515940]  bc75dcdc
[   36.518203]  00000002
[   36.520466]  ffffffff
[   36.522728]  00000002
[   36.524992]  bf05fe88
[   36.527255]  bf05fe40
[   36.529518]  00000000
[   36.531780]
[   36.535521] fe70
[   36.535524]  bd008c00
[   36.537440]  8001040c
[   36.539703]  bc75dcdc
[   36.541966]  00000003
[   36.544229]  ffffffff
[   36.546492]  00000002
[   36.548755]  bf05feac
[   36.551018]  bf05fe64
[   36.553280]
[   36.557022] fe90
[   36.557025]  00000000
[   36.558941]  bd008c00
[   36.561204]  80010408
[   36.563466]  bc75f7dc
[   36.565729]  00000049
[   36.567992]  ffffffff
[   36.570255]  00000002
[   36.572518]  b9c6fb0c
[   36.574782]
[   36.578523] feb0
[   36.578525]  bf05fe88
[   36.580440]  00000000
[   36.582703]  bd008c00
[   36.584966]  8019040c
[   36.587229]  bc8241dc
[   36.589492]  00000000
[   36.591756]  00000035
[   36.594019]  00000038
[   36.596281]
[   36.600023] fed0
[   36.600025]  b9c6fa98
[   36.601941]  b9c6fa98
[   36.604204]  00000000
[   36.606467]  bd008c00
[   36.608730]  80040048
[   36.610993]  bd3fa641
[   36.613256]  000000c2
[   36.615519]  00000000
[   36.617781]
[   36.621523] fef0
[   36.621525]  00000002
[   36.623441]  bf05fdd4
[   36.625705]  bf05ff3c
[   36.627968]  00000000
[   36.630231]  bd008c00
[   36.632494]  8001040c
[   36.634757]  00000000
[   36.637019]  00000019
[   36.639282]
[   36.643024] ff10
[   36.643026]  ffffffff
[   36.644942]  00000000
[   36.647204]  bf05ff60
[   36.649467]  b9c6faa0
[   36.651730]  00000000
[   36.653993]  bd008c00
[   36.656256]  80040048
[   36.658519]  bd800341
[   36.660781]
[   36.664522] ff30
[   36.664525]  0007057e
[   36.666440]  00000000
[   36.668703]  00000002
[   36.670966]  bf05fef4
[   36.673230]  bf05ffcc
[   36.675493]  00000000
[   36.677756]  bd008c00
[   36.680019]  8001040c
[   36.682281]
[   36.686024]
[   36.686024] R5: 0xbf05fe3c:
[   36.690285] fe3c
[   36.690287]  00000002
[   36.692204]  bf05fe64
[   36.694467]  bf05fe1c
[   36.696730]  00000000
[   36.698993]  bd008c00
[   36.701256]  8001040c
[   36.703519]  bc75dcdc
[   36.705782]  00000002
[   36.708045]
[   36.711786] fe5c
[   36.711789]  ffffffff
[   36.713704]  00000002
[   36.715967]  bf05fe88
[   36.718230]  bf05fe40
[   36.720493]  00000000
[   36.722757]  bd008c00
[   36.725020]  8001040c
[   36.727283]  bc75dcdc
[   36.729546]
[   36.733287] fe7c
[   36.733289]  00000003
[   36.735205]  ffffffff
[   36.737468]  00000002
[   36.739731]  bf05feac
[   36.741995]  bf05fe64
[   36.744258]  00000000
[   36.746521]  bd008c00
[   36.748783]  80010408
[   36.751046]
[   36.754787] fe9c
[   36.754789]  bc75f7dc
[   36.756706]  00000049
[   36.758969]  ffffffff
[   36.761232]  00000002
[   36.763495]  b9c6fb0c
[   36.765758]  bf05fe88
[   36.768020]  00000000
[   36.770283]  bd008c00
[   36.772546]
[   36.776288] febc
[   36.776290]  8019040c
[   36.778206]  bc8241dc
[   36.780469]  00000000
[   36.782732]  00000035
[   36.784995]  00000038
[   36.787258]  b9c6fa98
[   36.789521]  b9c6fa98
[   36.791785]  00000000
[   36.794047]
[   36.797788] fedc
[   36.797791]  bd008c00
[   36.799707]  80040048
[   36.801970]  bd3fa641
[   36.804233]  000000c2
[   36.806496]  00000000
[   36.808760]  00000002
[   36.811023]  bf05fdd4
[   36.813286]  bf05ff3c
[   36.815548]
[   36.819289] fefc
[   36.819291]  00000000
[   36.821207]  bd008c00
[   36.823470]  8001040c
[   36.825733]  00000000
[   36.827996]  00000019
[   36.830259]  ffffffff
[   36.832522]  00000000
[   36.834785]  bf05ff60
[   36.837047]
[   36.840789] ff1c
[   36.840791]  b9c6faa0
[   36.842707]  00000000
[   36.844970]  bd008c00
[   36.847233]  80040048
[   36.849496]  bd800341
[   36.851759]  0007057e
[   36.854022]  00000000
[   36.856284]  00000002
[   36.858548]
[   36.862290]
[   36.862290] R7: 0xb9c6fa94:
[   36.866551] fa94
[   36.866553]  00000000
[   36.868469]  bf05fed0
[   36.870732]  bf05fed0
[   36.872994]  bf05ff18
[   36.875258]  bf05fff0
[   36.877521]  0006a000
[   36.879784]  00000002
[   36.882047]  bf05ffdc
[   36.884309]
[   36.888050] fab4
[   36.888053]  00000000
[   36.889968]  bf05fb80
[   36.892232]  b9c6fb94
[   36.894496]  b9c6fb44
[   36.896758]  b9c6fad0
[   36.899021]  803785d8
[   36.901285]  5725f132
[   36.903548]  bf05f844
[   36.905810]
[   36.909552] fad4
[   36.909554]  bf05ffb8
[   36.911470]  b9c6fb9c
[   36.913733]  81216588
[   36.915996]  8141e100
[   36.918258]  b9c6fb0c
[   36.920521]  b9c6fb9c
[   36.922784]  b9c6fb88
[   36.925048]  b9c6fb6c
[   36.927310]
[   36.931051] faf4
[   36.931053]  b9c6fb00
[   36.932968]  803617c8
[   36.935231]  8036061c
[   36.937494]  00000000
[   36.939757]  00000001
[   36.942021]  00000020
[   36.944284]  bf05fc6c
[   36.946546]  bf05feac
[   36.948809]
[   36.952550] fb14
[   36.952552]  00000000
[   36.954468]  014000c0
[   36.956731]  00000000
[   36.958994]  00000000
[   36.961257]  00000000
[   36.963520]  0000000c
[   36.965783]  00000000
[   36.968046]  00000002
[   36.970308]
[   36.974050] fb34
[   36.974053]  00000007
[   36.975968]  00000000
[   36.978231]  5725f132
[   36.980494]  80379660
[   36.982757]  b9c6fb9c
[   36.985020]  00081a00
[   36.987283]  0006a000
[   36.989546]  b9c6e000
[   36.991808]
[   36.995549] fb54
[   36.995552]  814790c4
[   36.997467]  8121e384
[   36.999730]  00000000
[   37.001993]  b9c6fc14
[   37.004255]  b9c6fb70
[   37.006518]  80352b2c
[   37.008782]  80361688
[   37.011044]  00000002
[   37.013307]
[   37.017048] fb74
[   37.017051]  00000006
[   37.018966]  b9c6fb9c
[   37.021229]  00082000
[   37.023493]  00069000
[   37.025756]  81216588
[   37.028019]  00000004
[   37.030282]  00069e00
[   37.032545]  805969c8
[   37.034807]
[   37.038550]
[   37.038550] R8: 0xb9c6fa8c:
[   37.042811] fa8c
[   37.042813]  00000000
[   37.044729]  00069fc9
[   37.046992]  00000000
[   37.049254]  bf05fed0
[   37.051517]  bf05fed0
[   37.053780]  bf05ff18
[   37.056043]  bf05fff0
[   37.058307]  0006a000
[   37.060569]
[   37.064310] faac
[   37.064313]  00000002
[   37.066228]  bf05ffdc
[   37.068491]  00000000
[   37.070754]  bf05fb80
[   37.073017]  b9c6fb94
[   37.075280]  b9c6fb44
[   37.077543]  b9c6fad0
[   37.079806]  803785d8
[   37.082068]
[   37.085809] facc
[   37.085811]  5725f132
[   37.087727]  bf05f844
[   37.089990]  bf05ffb8
[   37.092254]  b9c6fb9c
[   37.094517]  81216588
[   37.096780]  8141e100
[   37.099043]  b9c6fb0c
[   37.101305]  b9c6fb9c
[   37.103568]
[   37.107310] faec
[   37.107313]  b9c6fb88
[   37.109228]  b9c6fb6c
[   37.111491]  b9c6fb00
[   37.113754]  803617c8
[   37.116017]  8036061c
[   37.118280]  00000000
[   37.120543]  00000001
[   37.122806]  00000020
[   37.125070]
[   37.128811] fb0c
[   37.128814]  bf05fc6c
[   37.130729]  bf05feac
[   37.132992]  00000000
[   37.135255]  014000c0
[   37.137518]  00000000
[   37.139781]  00000000
[   37.142044]  00000000
[   37.144307]  0000000c
[   37.146569]
[   37.150310] fb2c
[   37.150313]  00000000
[   37.152228]  00000002
[   37.154491]  00000007
[   37.156754]  00000000
[   37.159017]  5725f132
[   37.161280]  80379660
[   37.163543]  b9c6fb9c
[   37.165806]  00081a00
[   37.168068]
[   37.171809] fb4c
[   37.171812]  0006a000
[   37.173727]  b9c6e000
[   37.175990]  814790c4
[   37.178253]  8121e384
[   37.180516]  00000000
[   37.182779]  b9c6fc14
[   37.185041]  b9c6fb70
[   37.187304]  80352b2c
[   37.189567]
[   37.193309] fb6c
[   37.193311]  80361688
[   37.195226]  00000002
[   37.197489]  00000006
[   37.199753]  b9c6fb9c
[   37.202015]  00082000
[   37.204278]  00069000
[   37.206541]  81216588
[   37.208804]  00000004
[   37.211067]
[   37.214809]
[   37.214809] R9: 0xbc86667c:
[   37.219069] 667c
[   37.219072]  00000000
[   37.220988]  00000000
[   37.223251]  bc866684
[   37.225515]  bc866684
[   37.227778]  00000000
[   37.230041]  dead4ead
[   37.232304]  ffffffff
[   37.234567]  ffffffff
[   37.236829]
[   37.240572] 669c
[   37.240574]  00000000
[   37.242490]  00000000
[   37.244753]  00000000
[   37.247015]  00000000
[   37.249278]  00000000
[   37.251541]  be4c1580
[   37.253804]  bc8666b4
[   37.256067]  bc8666b4
[   37.258330]
[   37.262072] 66bc
[   37.262074]  bc8666bc
[   37.263991]  bc8666bc
[   37.266253]  bc866364
[   37.268516]  bc866a24
[   37.270779]  bc8666cc
[   37.273042]  bc8666cc
[   37.275306]  bc6f6e34
[   37.277569]  00000000
[   37.279832]
[   37.283572] 66dc
[   37.283575]  00000000
[   37.285490]  00000000
[   37.287753]  00000000
[   37.290016]  00000001
[   37.292279]  00000000
[   37.294542]  00000000
[   37.296805]  80c17b80
[   37.299067]  00000000
[   37.301330]
[   37.305071] 66fc
[   37.305073]  bc8665f8
[   37.306990]  01180020
[   37.309254]  bc89e261
[   37.311517]  00740074
[   37.313780]  dead4ead
[   37.316043]  ffffffff
[   37.318305]  ffffffff
[   37.320568]  00000000
[   37.322831]
[   37.326572] 671c
[   37.326574]  bdf4abfc
[   37.328490]  bdf4ab94
[   37.330753]  00000000
[   37.333016]  bc866728
[   37.335279]  bc866728
[   37.337542]  00000000
[   37.339805]  dead4ead
[   37.342069]  ffffffff
[   37.344332]
[   37.348073] 673c
[   37.348075]  ffffffff
[   37.349991]  00000000
[   37.352254]  00000001
[   37.354517]  00000031
[   37.356780]  00000002
[   37.359043]  00000000
[   37.361306]  80c18000
[   37.363569]  00000000
[   37.365832]
[   37.369573] 675c
[   37.369575]  00000000
[   37.371491]  dead4ead
[   37.373754]  ffffffff
[   37.376017]  ffffffff
[   37.378280]  014200ca
[   37.380543]  bc866770
[   37.382806]  bc866770
[   37.385069]  00000000
[   37.387331]
[   37.391076] Process HwBinder:1888_3 (pid: 3710, stack limit = 0xb9c6e218)
[   37.397856] Stack: (0xb9c6fa48 to 0xb9c70000)
[   37.402206] fa40:                   81216588 00000001 814230ec
810881c0 81216588 00000000
[   37.410377] fa60: 00000010 00000005 8141d980 00000000 00000000
8122b7a0 00000001 00000000
[   37.418548] fa80: 00000000 00000000 00000000 00000000 00069fc9
00000000 bf05fed0 bf05fed0
[   37.426719] faa0: bf05ff18 bf05fff0 0006a000 00000002 bf05ffdc
00000000 bf05fb80 b9c6fb94
[   37.434891] fac0: b9c6fb44 b9c6fad0 803785d8 5725f132 bf05f844
bf05ffb8 b9c6fb9c 81216588
[   37.443062] fae0: 8141e100 b9c6fb0c b9c6fb9c b9c6fb88 b9c6fb6c
b9c6fb00 803617c8 8036061c
[   37.451232] fb00: 00000000 00000001 00000020 bf05fc6c bf05feac
00000000 014000c0 00000000
[   37.459403] fb20: 00000000 00000000 0000000c 00000000 00000002
00000007 00000000 5725f132
[   37.467575] fb40: 80379660 b9c6fb9c 00081a00 0006a000 b9c6e000
814790c4 8121e384 00000000
[   37.475747] fb60: b9c6fc14 b9c6fb70 80352b2c 80361688 00000002
00000006 b9c6fb9c 00082000
[   37.483918] fb80: 00069000 81216588 00000004 00069e00 805969c8
00000000 00000000 bf05ffcc
[   37.492089] fba0: bf05fb94 8141e100 00000000 00000020 00000200
00000000 00000000 00000000
[   37.500260] fbc0: 00069e00 014000c0 ffffffff 00000000 00000000
00000000 00000002 00000001
[   37.508431] fbe0: 00000000 5725f132 00017c00 00069e00 00009e00
8147bf24 00017c00 fffffff4
[   37.516602] fc00: 00017c00 00040000 b9c6fc9c b9c6fc18 803bd8c8
803529bc 000000ff 00000000
[   37.524773] fc20: 5c87ac0b 223793b7 81216588 00000008 8121e384
814790c4 00000000 00000000
[   37.532945] fc40: 014000c0 81426d08 000000ff 8147bf34 b9c6fc74
b9c6fc60 5c87ac0b 00000000
[   37.541116] fc60: 223793b7 600e0093 b9c6fc8c 5725f132 80bc8e34
00000001 81216588 17c00000
[   37.549287] fc80: 00017c00 b9c6fd64 80607f30 00000000 b9c6fcac
b9c6fca0 80694188 803bd780
[   37.557459] fca0: b9c6fd0c b9c6fcb0 80218720 80694154 80287520
80313494 b9c6fd3c b9c6fcc8
[   37.565630] fcc0: 80287a70 bd2da400 00000707 00c00000 3839f8d9
80287d44 8144b358 5725f132
[   37.573801] fce0: 00000001 00000001 80607f30 b94d0140 00c00000
81216588 b9c6fe08 00000000
[   37.581972] fd00: b9c6fd3c b9c6fd10 80218854 802186d8 b9c6fd64
80607f30 00000001 00000000
[   37.590143] fd20: 014000c0 81216588 014000c0 bd2da400 b9c6fdc4
b9c6fd40 80217e28 8021881c
[   37.598315] fd40: 00000000 00000000 00000000 00000000 ffffffff
00000000 600e0013 80607f30
[   37.606487] fd60: b9248100 00000000 bd2da400 17c00000 014000c0
00000008 00000707 00c00000
[   37.614658] fd80: 80607f30 b9c6fd01 00000000 80287ad4 80e34724
5725f132 b9c6fdc4 00000707
[   37.622830] fda0: 00c00000 8148ff6c bd2da400 80c01778 17c00000
00000080 b9c6fdf4 b9c6fdc8
[   37.631001] fdc0: 80218000 80217c98 00000707 00c00000 00000000
00000044 80607f30 b9c6fdf8
[   37.639172] fde0: 81216588 81490278 b9c6fe3c b9c6fdf8 80607f30
80217fc0 00000044 00400000
[   37.647344] fe00: 00020000 00000000 ffffffff ffffffff b9c6fe3c
5725f132 81490278 b9c6fe7c
[   37.655515] fe20: 00000501 b9248100 00000008 00000008 b9c6fe5c
b9c6fe40 80607fa0 80607de4
[   37.663687] fe40: 00000501 6d3ff34c 81216588 00000501 b9c6fec4
b9c6fe60 806082d4 80607f6c
[   37.671857] fe60: 00000501 65646976 8c42006f 6d72907c 00000000
6d72b7e9 6c766588 00000000
[   37.680029] fe80: 00000008 00000000 bd26a610 00000000 00000000
b9c6ffb0 81216588 00000000
[   37.688200] fea0: 00000036 5725f132 b9c6e000 00000000 00000000
bd22b880 b9c6fee4 b9c6fec8
[   37.696372] fec0: 80431254 806081f4 804311f0 81216588 6d3ff34c
bcbbd820 b9c6ff7c b9c6fee8
[   37.704543] fee0: 803d8094 804311fc 00000008 00000080 b9c6ff54
b9c6ff00 8050158c 804fa9f0
[   37.712714] ff00: 00000005 00000001 b9c6ff1c b959c000 bd26a610
bce5f8e8 b9c60501 b9c6ff0b
[   37.720885] ff20: b9c6ff10 b9248100 b9c6ff5c 5725f132 803e4230
80edc10c 80edb888 6d3ff34c
[   37.729056] ff40: 00000501 b9248100 b9c6ff7c 5725f132 804f76e8
00000000 b9248101 b9248100
[   37.737227] ff60: 6d3ff34c 00000501 00000008 00000080 b9c6ffa4
b9c6ff80 803d8140 803d78a4
[   37.745398] ff80: 6c773875 00000008 00000000 00000036 80209364
b9c6e000 00000000 b9c6ffa8
[   37.753570] ffa0: 80209334 803d80d8 6c773875 00000008 00000008
00000501 6d3ff34c 6d3ff314
[   37.761740] ffc0: 6c773875 00000008 00000000 00000036 00000000
6db612c8 6db61334 6df27ae0
[   37.769911] ffe0: 6d3ff34c 6d3ff300 6f169b3d 6f19bd94 600e0010
00000008 00000000 00000000
[   37.778079] Backtrace:
[   37.780531] [<80360610>] (shrink_page_list) from [<803617c8>]
(reclaim_clean_pages_from_list+0x14c/0x1a8)
[   37.790093]  r10:b9c6fb88 r9:b9c6fb9c r8:b9c6fb0c r7:8141e100
r6:81216588 r5:b9c6fb9c
[   37.797914]  r4:bf05ffb8
[   37.800444] [<8036167c>] (reclaim_clean_pages_from_list) from
[<80352b2c>] (alloc_contig_range+0x17c/0x4e0)
[   37.810178]  r10:00000000 r9:8121e384 r8:814790c4 r7:b9c6e000
r6:0006a000 r5:00081a00
[   37.817999]  r4:b9c6fb9c
[   37.820529] [<803529b0>] (alloc_contig_range) from [<803bd8c8>]
(cma_alloc+0x154/0x5dc)
[   37.828527]  r10:00040000 r9:00017c00 r8:fffffff4 r7:00017c00
r6:8147bf24 r5:00009e00
[   37.836347]  r4:00069e00
[   37.838878] [<803bd774>] (cma_alloc) from [<80694188>]
(dma_alloc_from_contiguous+0x40/0x44)
[   37.847310]  r10:00000000 r9:80607f30 r8:b9c6fd64 r7:00017c00
r6:17c00000 r5:81216588
[   37.855131]  r4:00000001
[   37.857661] [<80694148>] (dma_alloc_from_contiguous) from
[<80218720>] (__alloc_from_contiguous+0x54/0x144)
[   37.867396] [<802186cc>] (__alloc_from_contiguous) from
[<80218854>] (cma_allocator_alloc+0x44/0x4c)
[   37.876523]  r10:00000000 r9:b9c6fe08 r8:81216588 r7:00c00000
r6:b94d0140 r5:80607f30
[   37.884343]  r4:00000001
[   37.886870] [<80218810>] (cma_allocator_alloc) from [<80217e28>]
(__dma_alloc+0x19c/0x2e4)
[   37.895125]  r5:bd2da400 r4:014000c0
[   37.898695] [<80217c8c>] (__dma_alloc) from [<80218000>]
(arm_dma_alloc+0x4c/0x54)
[   37.906258]  r10:00000080 r9:17c00000 r8:80c01778 r7:bd2da400
r6:8148ff6c r5:00c00000
[   37.914079]  r4:00000707
[   37.916608] [<80217fb4>] (arm_dma_alloc) from [<80607f30>]
(__pmap_get_info+0x158/0x188)
[   37.924690]  r5:81490278 r4:81216588
[   37.936257]  r9:00000008 r8:00000008 r7:b9248100 r6:00000501
r5:b9c6fe7c r4:81490278
[   38.024605] ---[ end trace c33587d96a17f914 ]---
[   38.029216] Kernel panic - not syncing: Fatal exception
[   38.034438] CPU2: stopping
[   38.037147] CPU: 2 PID: 0 Comm: swapper/2 Tainted: P      D    O
4.14.65-tcc #120
[   38.044880] Hardware name: Android (Flattened Device Tree)
[   38.051224] Backtrace:
[   38.053671] [<8020dbec>] (dump_backtrace) from [<8020ded0>]
(show_stack+0x18/0x1c)
[   38.061233]  r6:60070193 r5:8141c19c r4:00000000 r3:5725f132
[   38.066888] [<8020deb8>] (show_stack) from [<80ba8e30>]
(dump_stack+0x94/0xa8)
[   38.074104] [<80ba8d9c>] (dump_stack) from [<8021143c>]
(handle_IPI+0x1dc/0x3fc)
[   38.081492]  r6:81422548 r5:8108a1cc r4:00000004 r3:5725f132
[   38.087144] [<80211260>] (handle_IPI) from [<80201500>]
(gic_handle_irq+0x94/0x98)
[   38.094707]  r10:00000000 r9:c0003000 r8:c0002000 r7:bd0e3f18
r6:c000200c r5:81216b94
[   38.102527]  r4:81257e3c
[   38.105056] [<8020146c>] (gic_handle_irq) from [<80bc9578>]
(__irq_svc+0x58/0x8c)
[   38.112530] Exception stack(0xbd0e3f18 to 0xbd0e3f60)
[   38.117573] 3f00:
    00008e34 3d50b000
[   38.125744] 3f20: 00000000 8021c460 bd0e2000 81216618 812165b4
00000000 81089a70 81216624
[   38.133914] 3f40: 00000000 bd0e3f74 bd0e3f78 bd0e3f68 80209e1c
80209e20 60070013 ffffffff
[   38.142085]  r9:bd0e2000 r8:81089a70 r7:bd0e3f4c r6:ffffffff
r5:60070013 r4:80209e20
[   38.149823] [<80209de0>] (arch_cpu_idle) from [<80bc8d08>]
(default_idle_call+0x28/0x34)
[   38.157909] [<80bc8ce0>] (default_idle_call) from [<802728f4>]
(do_idle+0x1dc/0x2d4)
[   38.165646] [<80272718>] (do_idle) from [<80272cd8>]
(cpu_startup_entry+0x20/0x24)
[   38.173209]  r10:00000000 r9:410fd034 r8:20003010 r7:81447c58
r6:30c0387d r5:00000002
[   38.181028]  r4:00000084
[   38.183556] [<80272cb8>] (cpu_startup_entry) from [<80211010>]
(secondary_start_kernel+0x184/0x1a8)
[   38.192595] [<80210e8c>] (secondary_start_kernel) from [<202019cc>]
(0x202019cc)
[   38.199981]  r5:00000000 r4:5d08acc0
[   38.203547] CPU3: stopping
[   38.206248] CPU: 3 PID: 0 Comm: swapper/3 Tainted: P      D    O
4.14.65-tcc #120
[   38.213982] Hardware name: Android (Flattened Device Tree)
[   38.220325] Backtrace:
[   38.222767] [<8020dbec>] (dump_backtrace) from [<8020ded0>]
(show_stack+0x18/0x1c)
[   38.230328]  r6:600f0193 r5:8141c19c r4:00000000 r3:5725f132
[   38.235981] [<8020deb8>] (show_stack) from [<80ba8e30>]
(dump_stack+0x94/0xa8)
[   38.243197] [<80ba8d9c>] (dump_stack) from [<8021143c>]
(handle_IPI+0x1dc/0x3fc)
[   38.250585]  r6:81422548 r5:8108a1cc r4:00000004 r3:5725f132
[   38.256237] [<80211260>] (handle_IPI) from [<80201500>]
(gic_handle_irq+0x94/0x98)
[   38.263800]  r10:00000000 r9:c0003000 r8:c0002000 r7:bd0e5f18
r6:c000200c r5:81216b94
[   38.271620]  r4:81257e3c
[   38.274147] [<8020146c>] (gic_handle_irq) from [<80bc9578>]
(__irq_svc+0x58/0x8c)
[   38.281620] Exception stack(0xbd0e5f18 to 0xbd0e5f60)
[   38.286663] 5f00:
    0000aa90 3d51d000
[   38.294833] 5f20: 00000000 8021c460 bd0e4000 81216618 812165b4
00000000 81089a70 81216624
[   38.303004] 5f40: 00000000 bd0e5f74 bd0e5f78 bd0e5f68 80209e1c
80209e20 600f0013 ffffffff
[   38.311174]  r9:bd0e4000 r8:81089a70 r7:bd0e5f4c r6:ffffffff
r5:600f0013 r4:80209e20
[   38.318911] [<80209de0>] (arch_cpu_idle) from [<80bc8d08>]
(default_idle_call+0x28/0x34)
[   38.326996] [<80bc8ce0>] (default_idle_call) from [<802728f4>]
(do_idle+0x1dc/0x2d4)
[   38.334733] [<80272718>] (do_idle) from [<80272cd8>]
(cpu_startup_entry+0x20/0x24)
[   38.342296]  r10:00000000 r9:410fd034 r8:20003010 r7:81447c58
r6:30c0387d r5:00000003
[   38.350116]  r4:00000084
[   38.352643] [<80272cb8>] (cpu_startup_entry) from [<80211010>]
(secondary_start_kernel+0x184/0x1a8)
[   38.361681] [<80210e8c>] (secondary_start_kernel) from [<202019cc>]
(0x202019cc)
[   38.369067]  r5:00000000 r4:5d08acc0
[   38.372633] CPU0: stopping
[   38.375334] CPU: 0 PID: 0 Comm: swapper/0 Tainted: P      D    O
4.14.65-tcc #120
[   38.383068] Hardware name: Android (Flattened Device Tree)
[   38.389411] Backtrace:
[   38.391853] [<8020dbec>] (dump_backtrace) from [<8020ded0>]
(show_stack+0x18/0x1c)
[   38.399415]  r6:600e0193 r5:8141c19c r4:00000000 r3:5725f132
[   38.405068] [<8020deb8>] (show_stack) from [<80ba8e30>]
(dump_stack+0x94/0xa8)
[   38.412284] [<80ba8d9c>] (dump_stack) from [<8021143c>]
(handle_IPI+0x1dc/0x3fc)
[   38.419671]  r6:81422548 r5:8108a1cc r4:00000004 r3:5725f132
[   38.425324] [<80211260>] (handle_IPI) from [<80201500>]
(gic_handle_irq+0x94/0x98)
[   38.432886]  r10:00000000 r9:c0003000 r8:c0002000 r7:81201eb8
r6:c000200c r5:81216b94
[   38.440706]  r4:81257e3c
[   38.443233] [<8020146c>] (gic_handle_irq) from [<80bc9578>]
(__irq_svc+0x58/0x8c)
[   38.450706] Exception stack(0x81201eb8 to 0x81201f00)
[   38.455748] 1ea0:
    0001fbac 3d4e7000
[   38.463919] 1ec0: 00000000 8021c460 81200000 81216618 812165b4
00000000 81089a70 81216624
[   38.472089] 1ee0: 00000000 81201f14 81201f18 81201f08 80209e1c
80209e20 600e0013 ffffffff
[   38.480260]  r9:81200000 r8:81089a70 r7:81201eec r6:ffffffff
r5:600e0013 r4:80209e20
[   38.487997] [<80209de0>] (arch_cpu_idle) from [<80bc8d08>]
(default_idle_call+0x28/0x34)
[   38.496082] [<80bc8ce0>] (default_idle_call) from [<802728f4>]
(do_idle+0x1dc/0x2d4)
[   38.503818] [<80272718>] (do_idle) from [<80272cd8>]
(cpu_startup_entry+0x20/0x24)
[   38.511381]  r10:81072a48 r9:81216580 r8:ffffffff r7:81447880
r6:00000000 r5:00000002
[   38.519200]  r4:000000be
[   38.521730] [<80272cb8>] (cpu_startup_entry) from [<80bc096c>]
(rest_init+0xd4/0xd8)
[   38.529470] [<80bc0898>] (rest_init) from [<81000e94>]
(start_kernel+0x428/0x480)
[   38.536943]  r5:00000000 r4:814478d0
[   38.540512] [<81000a6c>] (start_kernel) from [<20008090>] (0x20008090)
[   38.547032] [vioc disp0] M:0x0000ffe7 S:0x4400002e
[   38.551814] [vioc disp1] M:0x0000ffff S:0x9000003e
[   38.556596] [viod wdma2] M:0x000003ff S:0x800001a0


>
> >
> >
> > Below is the patch which solved this issue :
> >
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index be56e2e..12ac353 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -998,7 +998,7 @@ static unsigned long shrink_page_list(struct
> > list_head *page_list,
> >                 sc->nr_scanned++;
> >
> >                 if (unlikely(!page_evictable(page)))
> > -                       goto activate_locked;
> > +                      goto cull_mlocked;
> >
> >                 if (!sc->may_unmap && page_mapped(page))
> >                         goto keep_locked;
> > @@ -1331,7 +1331,12 @@ static unsigned long shrink_page_list(struct
> > list_head *page_list,
> >                 } else
> >                         list_add(&page->lru, &free_pages);
> >                 continue;
> > -
> > +cull_mlocked:
> > +                if (PageSwapCache(page))
> > +                        try_to_free_swap(page);
> > +                unlock_page(page);
> > +                list_add(&page->lru, &ret_pages);
> > +                continue;
> >  activate_locked:
> >                 /* Not a candidate for swapping, so reclaim swap space. */
> >                 if (PageSwapCache(page) && (mem_cgroup_swap_full(page) ||
> >
> >
> >
> >
> > It fixes the below issue.
> >
> > 1. Large size buffer allocation using cma_alloc successful with
> > unevictable pages.
> >
> > cma_alloc of current kernel will fail due to unevictable page
> >
> > Please let me know if anything i am missing.
> >
> > Regards,
> > Pankaj
> >
>

