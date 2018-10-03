Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 407D56B000A
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 06:48:23 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id u125-v6so2790695ywf.19
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 03:48:23 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id g63-v6si205008ybg.523.2018.10.03.03.48.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 03:48:22 -0700 (PDT)
Subject: Re: [PATCH] mm: Avoid swapping in interrupt context
References: <1538387115-2363-1-git-send-email-amhetre@nvidia.com>
 <20181001122400.GF18290@dhcp22.suse.cz>
From: Ashish Mhetre <amhetre@nvidia.com>
Message-ID: <988dfe01-6553-1e0a-1d98-1b3d3aa67517@nvidia.com>
Date: Wed, 3 Oct 2018 16:18:37 +0530
MIME-Version: 1.0
In-Reply-To: <20181001122400.GF18290@dhcp22.suse.cz>
Content-Type: multipart/alternative;
	boundary="------------522A1BD076428E4A523FF434"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, vdumpa@nvidia.com, Snikam@nvidia.com

--------------522A1BD076428E4A523FF434
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit

>How? No allocation request from the interrupt context can use a
>sleepable allocation context and that means that no reclaim is allowed
>from the IRQ context.
Kernel Oops happened when ZRAM was used as swap with zsmalloc as alloctor
under memory pressure condition.
This is probably because of kmalloc() from IRQ as pointed out by Sergey.

>Could you provide the Oops message?
BUG_ON() got triggered at https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/tree/mm/zsmalloc.c?h=next-20181002#n1324 with Oops message:
[ 264.082531] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP ARM
[ 264.088350] Modules linked in:
[ 264.091406] CPU: 0 PID: 3805 Comm: kworker/0:4 Tainted: G W 
3.10.33-g990282b #1
[ 264.099572] Workqueue: events netstat_work_func
[ 264.104097] task: e7b12040 ti: dc7d4000 task.ti: dc7d4000
[ 264.109485] PC is at zs_map_object+0x180/0x18c
[ 264.113918] LR is at zram_bvec_rw.isra.15+0x304/0x88c
[ 264.118956] pc : [<c01581e8>] lr : [<c0456618>] psr: 200f0013
[ 264.118956] sp : dc7d5460 ip : fff00814 fp : 00000002
[ 264.130407] r10: ea8ec000 r9 : ebc93340 r8 : 00000000
[ 264.135618] r7 : c191502c r6 : dc7d4020 r5 : d25f5684 r4 : ec3158c0
[ 264.142128] r3 : 00000200 r2 : 00000002 r1 : c191502c r0 : ea8ec000


On Monday 01 October 2018 05:54 PM, Michal Hocko wrote:
> On Mon 01-10-18 15:15:15, Ashish Mhetre wrote:
>> From: Sri Krishna chowdary <schowdary@nvidia.com>
>>
>> Pages can be swapped out from interrupt context as well.
> How? No allocation request from the interrupt context can use a
> sleepable allocation context and that means that no reclaim is allowed
> from the IRQ context.
>
>> ZRAM uses zsmalloc allocator to make room for these pages.
>> But zsmalloc is not made to be used from interrupt context.
>> This can result in a kernel Oops.
> Could you provide the Oops message?


--------------522A1BD076428E4A523FF434
Content-Type: text/html; charset="utf-8"
Content-Transfer-Encoding: 8bit

<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    <pre wrap="">&gt;How? No allocation request from the interrupt context can use a
&gt;sleepable allocation context and that means that no reclaim is allowed
&gt;from the IRQ context.
Kernel Oops happened when ZRAM was used as swap with zsmalloc as alloctor
under memory pressure condition.
This is probably because of kmalloc() from IRQ as pointed out by Sergey.

&gt;Could you provide the Oops message?
BUG_ON() got triggered at <a class="moz-txt-link-freetext" href="https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/tree/mm/zsmalloc.c?h=next-20181002#n1324">https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/tree/mm/zsmalloc.c?h=next-20181002#n1324</a> with Oops message:
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 264.082531] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP ARM<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 264.088350] Modules linked in:<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 264.091406] CPU: 0 PID: 3805 Comm: kworker/0:4 Tainted: G W 3.10.33-g990282b #1<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 264.099572] Workqueue: events netstat_work_func<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 264.104097] task: e7b12040 ti: dc7d4000 task.ti: dc7d4000<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 264.109485] PC is at zs_map_object+0x180/0x18c<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 264.113918] LR is at zram_bvec_rw.isra.15+0x304/0x88c<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 264.118956] pc : [&lt;c01581e8&gt;] lr : [&lt;c0456618&gt;] psr: 200f0013<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 264.118956] sp : dc7d5460 ip : fff00814 fp : 00000002<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 264.130407] r10: ea8ec000 r9 : ebc93340 r8 : 00000000<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 264.135618] r7 : c191502c r6 : dc7d4020 r5 : d25f5684 r4 : ec3158c0<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 264.142128] r3 : 00000200 r2 : 00000002 r1 : c191502c r0 : ea8ec000<span> 
</span></span></pre>
    <br>
    <div class="moz-cite-prefix">On Monday 01 October 2018 05:54 PM,
      Michal Hocko wrote:<br>
    </div>
    <blockquote type="cite"
      cite="mid:20181001122400.GF18290@dhcp22.suse.cz">
      <pre wrap="">On Mon 01-10-18 15:15:15, Ashish Mhetre wrote:
</pre>
      <blockquote type="cite">
        <pre wrap="">From: Sri Krishna chowdary <a class="moz-txt-link-rfc2396E" href="mailto:schowdary@nvidia.com">&lt;schowdary@nvidia.com&gt;</a>

Pages can be swapped out from interrupt context as well.
</pre>
      </blockquote>
      <pre wrap="">
How? No allocation request from the interrupt context can use a
sleepable allocation context and that means that no reclaim is allowed
from the IRQ context.

</pre>
      <blockquote type="cite">
        <pre wrap="">ZRAM uses zsmalloc allocator to make room for these pages.
But zsmalloc is not made to be used from interrupt context.
This can result in a kernel Oops.
</pre>
      </blockquote>
      <pre wrap="">
Could you provide the Oops message?
</pre>
    </blockquote>
    <br>
  </body>
</html>

--------------522A1BD076428E4A523FF434--
