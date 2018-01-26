Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 48CEF6B0007
	for <linux-mm@kvack.org>; Fri, 26 Jan 2018 01:54:17 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 199so7835930pfy.18
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 22:54:17 -0800 (PST)
Received: from mail.rimuhosting.com (mail.rimuhosting.com. [206.123.102.5])
        by mx.google.com with ESMTP id 5-v6si3275077plx.742.2018.01.25.22.54.13
        for <linux-mm@kvack.org>;
        Thu, 25 Jan 2018 22:54:13 -0800 (PST)
Subject: Re: [Bug 198497] New: handle_mm_fault / xen_pmd_val /
 radix_tree_lookup_slot Null pointer
References: <bug-198497-27@https.bugzilla.kernel.org/>
 <20180118135518.639141f0b0ea8bb047ab6306@linux-foundation.org>
 <7ba7635e-249a-9071-75bb-7874506bd2b2@redhat.com>
 <20180119030447.GA26245@bombadil.infradead.org>
 <d38ff996-8294-81a6-075f-d7b2a60aa2f4@rimuhosting.com>
 <20180119132145.GB2897@bombadil.infradead.org>
 <9d2ddba4-3fb3-0fb4-a058-f2cfd1b05538@redhat.com>
From: xen@randomwebstuff.com
Message-ID: <32ab6fd6-e3c6-9489-8163-aa73861aa71a@rimuhosting.com>
Date: Fri, 26 Jan 2018 19:54:06 +1300
MIME-Version: 1.0
In-Reply-To: <9d2ddba4-3fb3-0fb4-a058-f2cfd1b05538@redhat.com>
Content-Type: multipart/alternative;
 boundary="------------CF75E1793794456A2D1D48BD"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>, Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org

This is a multi-part message in MIME format.
--------------CF75E1793794456A2D1D48BD
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit


On 20/01/18 6:30 AM, Laura Abbott wrote:
> On 01/19/2018 05:21 AM, Matthew Wilcox wrote:
>> On Fri, Jan 19, 2018 at 04:14:42PM +1300, xen@randomwebstuff.com wrote:
>>>
>>> On 19/01/18 4:04 PM, Matthew Wilcox wrote:
>>>> On Thu, Jan 18, 2018 at 02:18:20PM -0800, Laura Abbott wrote:
>>>>> On 01/18/2018 01:55 PM, Andrew Morton wrote:
>>>>>>> [A A  24.647744] BUG: unable to handle kernel NULL pointer 
>>>>>>> dereference at
>>>>>>> 00000008
>>>>>>> [A A  24.647801] IP: __radix_tree_lookup+0x14/0xa0
>>>>>>> [A A  24.647811] *pdpt = 00000000253d6027 *pde = 0000000000000000
>>>>>>> [A A  24.647828] Oops: 0000 [#1] SMP
>>>>>>> [A A  24.647842] CPU: 5 PID: 3600 Comm: java Not tainted
>>>>>>> 4.14.13-rh10-20180115190010.xenU.i386 #1
>>>>>>> [A A  24.647855] task: e52518c0 task.stack: e4e7a000
>>>>>>> [A A  24.647866] EIP: __radix_tree_lookup+0x14/0xa0
>>>>>>> [A A  24.647876] EFLAGS: 00010286 CPU: 5
>>>>>>> [A A  24.647884] EAX: 00000004 EBX: 00000007 ECX: 00000000 EDX: 
>>>>>>> 00000000
>>
>> If my understanding is right, EDX contains the index we're looking up.
>> Which is zero.A  So the swp_entry we got is one bit away from being NULL.
>> Hmm.A  Have you run memtest86 or some other memory tester on the system
>> recently?
>>
>>> PS: cannot recall seeing this issue on x86_64, just 32 bit.
>>
>> Laura has 64-bit instances of this.
>>
>
> The 64-bit backtraces reported in the bugzilla looked different,
> I would consider it a different issue.
>
>> PPS: reminder
>>> this is on a Xen VM which per 
>>> https://xenbits.xen.org/docs/unstable/man/xl.cfg.5.html#PVH-Guest-Specific-Options
>>> has "out of sync pagetables" if that is relevant (we do not set that 
>>> option,
>>> I am unsure what default is used).
>>
>> Laura also has non-Xen instances of this.A  They may not all be the same
>> bug, of course.
>>
Re-tried with the current latest 4.14 (4.14.15).A  Received the following:

[2018-01-24 19:26:57] Ubuntu 14.04.5 LTS dev hvc0
[2018-01-24 19:26:57]
[2018-01-24 19:26:57] dev login: [44501.106868] BUG: unable to handle 
kernel NULL pointer dereference at 00000008
[2018-01-25 07:47:50] [44501.106897] IP: __radix_tree_lookup+0x14/0xa0
[2018-01-25 07:47:50] [44501.106905] *pdpt = 000000001fe82027 *pde = 
0000000000000000
[2018-01-25 07:47:50] [44501.106916] Oops: 0000 [#1] SMP
[2018-01-25 07:47:50] [44501.106924] CPU: 0 PID: 3344 Comm: 
PassengerAgent Not tainted 4.14.15-rh13-20180123235331.xenU.i386 #1
[2018-01-25 07:47:50] [44501.106935] task: dfee39c0 task.stack: dff12000
[2018-01-25 07:47:50] [44501.106943] EIP: __radix_tree_lookup+0x14/0xa0
[2018-01-25 07:47:50] [44501.106950] EFLAGS: 00210286 CPU: 0
[2018-01-25 07:47:50] [44501.106955] EAX: 00000004 EBX: 00000001 ECX: 
00000000 EDX: 00000000
[2018-01-25 07:47:50] [44501.106963] ESI: 00000000 EDI: 00000000 EBP: 
dff13db8 ESP: dff13da0
[2018-01-25 07:47:50] [44501.106971] A DS: 007b ES: 007b FS: 00d8 GS: 
00e0 SS: 0069
[2018-01-25 07:47:50] [44501.106979] CR0: 80050033 CR2: 00000008 CR3: 
1fdb1000 CR4: 00002660
[2018-01-25 07:47:50] [44501.106989] Call Trace:
[2018-01-25 07:47:50] [44501.106995] A radix_tree_lookup_slot+0x13/0x30
[2018-01-25 07:47:50] [44501.107004] A find_get_entry+0x1d/0x120
[2018-01-25 07:47:50] [44501.107011] A pagecache_get_page+0x1f/0x230
[2018-01-25 07:47:50] [44501.107018] A lookup_swap_cache+0x42/0x140
[2018-01-25 07:47:50] [44501.107024] A swap_readahead_detect+0x66/0x2e0
[2018-01-25 07:47:50] [44501.107032] A do_swap_page+0x1fa/0x860
[2018-01-25 07:47:50] [44501.107040] A ? 
__raw_callee_save___pv_queued_spin_unlock+0x9/0x10
[2018-01-25 07:47:50] [44501.107050] A ? xen_pmd_val+0x10/0x20
[2018-01-25 07:47:50] [44501.107057] A handle_mm_fault+0x6f8/0x1020
[2018-01-25 07:47:50] [44501.107065] A ? 
_raw_spin_unlock_irqrestore+0x13/0x20
[2018-01-25 07:47:50] [44501.107074] A ? pvclock_clocksource_read+0xa6/0x1a0
[2018-01-25 07:47:50] [44501.107081] A __do_page_fault+0x18a/0x450
[2018-01-25 07:47:50] [44501.107089] A ? _copy_to_user+0x28/0x40
[2018-01-25 07:47:50] [44501.107096] A ? vmalloc_sync_all+0x250/0x250
[2018-01-25 07:47:50] [44501.107102] A do_page_fault+0x21/0x30
[2018-01-25 07:47:50] [44501.107109] A common_exception+0x45/0x4a
[2018-01-25 07:47:50] [44501.107115] EIP: 0x82c3358
[2018-01-25 07:47:50] [44501.107120] EFLAGS: 00210202 CPU: 0
[2018-01-25 07:47:50] [44501.107126] EAX: b702d0b8 EBX: 081557a9 ECX: 
00000000 EDX: 0a4296bc
[2018-01-25 07:47:50] [44501.107133] ESI: b467c2cc EDI: 00000000 EBP: 
b467c138 ESP: b467c110
[2018-01-25 07:47:50] [44501.107141] A DS: 007b ES: 007b FS: 0000 GS: 
0033 SS: 007b
[2018-01-25 07:47:50] [44501.107147] Code: ff ff ff 00 47 03 e9 69 ff ff 
ff 8b 45 08 89 06 e9 1f ff ff ff 66 90 55 89 e5 57 89 d7 56 53 83 ec 0c 
89 45 ec 89 4d e8 8b 45 ec <8b> 58 04 89 d8 83 e0 03 48 89 5d f0 75 64 
89 d8 83 e0 fe 0f b6
[2018-01-25 07:47:50] [44501.110296] EIP: __radix_tree_lookup+0x14/0xa0 
SS:ESP: 0069:dff13da0
[2018-01-25 07:47:50] [44501.110304] CR2: 0000000000000008
[2018-01-25 07:47:50] [44501.110356] ---[ end trace 89cdd2ba8e7323a8 ]---

--------------CF75E1793794456A2D1D48BD
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 8bit

<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    <p><br>
    </p>
    On 20/01/18 6:30 AM, Laura Abbott wrote:<br>
    <blockquote type="cite"
      cite="mid:9d2ddba4-3fb3-0fb4-a058-f2cfd1b05538@redhat.com">On
      01/19/2018 05:21 AM, Matthew Wilcox wrote:
      <br>
      <blockquote type="cite">On Fri, Jan 19, 2018 at 04:14:42PM +1300,
        <a class="moz-txt-link-abbreviated" href="mailto:xen@randomwebstuff.com">xen@randomwebstuff.com</a> wrote:
        <br>
        <blockquote type="cite">
          <br>
          On 19/01/18 4:04 PM, Matthew Wilcox wrote:
          <br>
          <blockquote type="cite">On Thu, Jan 18, 2018 at 02:18:20PM
            -0800, Laura Abbott wrote:
            <br>
            <blockquote type="cite">On 01/18/2018 01:55 PM, Andrew
              Morton wrote:
              <br>
              <blockquote type="cite">
                <blockquote type="cite">[A A  24.647744] BUG: unable to
                  handle kernel NULL pointer dereference at
                  <br>
                  00000008
                  <br>
                  [A A  24.647801] IP: __radix_tree_lookup+0x14/0xa0
                  <br>
                  [A A  24.647811] *pdpt = 00000000253d6027 *pde =
                  0000000000000000
                  <br>
                  [A A  24.647828] Oops: 0000 [#1] SMP
                  <br>
                  [A A  24.647842] CPU: 5 PID: 3600 Comm: java Not tainted
                  <br>
                  4.14.13-rh10-20180115190010.xenU.i386 #1
                  <br>
                  [A A  24.647855] task: e52518c0 task.stack: e4e7a000
                  <br>
                  [A A  24.647866] EIP: __radix_tree_lookup+0x14/0xa0
                  <br>
                  [A A  24.647876] EFLAGS: 00010286 CPU: 5
                  <br>
                  [A A  24.647884] EAX: 00000004 EBX: 00000007 ECX:
                  00000000 EDX: 00000000
                  <br>
                </blockquote>
              </blockquote>
            </blockquote>
          </blockquote>
        </blockquote>
        <br>
        If my understanding is right, EDX contains the index we're
        looking up.
        <br>
        Which is zero.A  So the swp_entry we got is one bit away from
        being NULL.
        <br>
        Hmm.A  Have you run memtest86 or some other memory tester on the
        system
        <br>
        recently?
        <br>
        <br>
        <blockquote type="cite">PS: cannot recall seeing this issue on
          x86_64, just 32 bit.
          <br>
        </blockquote>
        <br>
        Laura has 64-bit instances of this.
        <br>
        <br>
      </blockquote>
      <br>
      The 64-bit backtraces reported in the bugzilla looked different,
      <br>
      I would consider it a different issue.
      <br>
      <br>
      <blockquote type="cite">PPS: reminder
        <br>
        <blockquote type="cite">this is on a Xen VM which per
<a class="moz-txt-link-freetext" href="https://xenbits.xen.org/docs/unstable/man/xl.cfg.5.html#PVH-Guest-Specific-Options">https://xenbits.xen.org/docs/unstable/man/xl.cfg.5.html#PVH-Guest-Specific-Options</a><br>
          has "out of sync pagetables" if that is relevant (we do not
          set that option,
          <br>
          I am unsure what default is used).
          <br>
        </blockquote>
        <br>
        Laura also has non-Xen instances of this.A  They may not all be
        the same
        <br>
        bug, of course.
        <br>
        <br>
      </blockquote>
    </blockquote>
    Re-tried with the current latest 4.14 (4.14.15).A  Received the
    following:<br>
    <br>
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-24 19:26:57]
      Ubuntu 14.04.5 LTS dev hvc0</span><br style="word-wrap:
      break-word; text-rendering: optimizeLegibility; color: rgb(20, 20,
      20); font-family: -webkit-standard; font-style: normal;
      font-variant-caps: normal; font-weight: normal; letter-spacing:
      normal; orphans: auto; text-align: start; text-indent: 0px;
      text-transform: none; white-space: normal; widows: auto;
      word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px;">
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-24 19:26:57]<span
        class="Apple-converted-space">A </span></span><br
      style="word-wrap: break-word; text-rendering: optimizeLegibility;
      color: rgb(20, 20, 20); font-family: -webkit-standard; font-style:
      normal; font-variant-caps: normal; font-weight: normal;
      letter-spacing: normal; orphans: auto; text-align: start;
      text-indent: 0px; text-transform: none; white-space: normal;
      widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px;">
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-24 19:26:57]
      dev login: [44501.106868] BUG: unable to handle kernel NULL
      pointer dereference at 00000008</span><br style="word-wrap:
      break-word; text-rendering: optimizeLegibility; color: rgb(20, 20,
      20); font-family: -webkit-standard; font-style: normal;
      font-variant-caps: normal; font-weight: normal; letter-spacing:
      normal; orphans: auto; text-align: start; text-indent: 0px;
      text-transform: none; white-space: normal; widows: auto;
      word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px;">
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-25 07:47:50]
      [44501.106897] IP: __radix_tree_lookup+0x14/0xa0</span><br
      style="word-wrap: break-word; text-rendering: optimizeLegibility;
      color: rgb(20, 20, 20); font-family: -webkit-standard; font-style:
      normal; font-variant-caps: normal; font-weight: normal;
      letter-spacing: normal; orphans: auto; text-align: start;
      text-indent: 0px; text-transform: none; white-space: normal;
      widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px;">
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-25 07:47:50]
      [44501.106905] *pdpt = 000000001fe82027 *pde = 0000000000000000<span
        class="Apple-converted-space">A </span></span><br
      style="word-wrap: break-word; text-rendering: optimizeLegibility;
      color: rgb(20, 20, 20); font-family: -webkit-standard; font-style:
      normal; font-variant-caps: normal; font-weight: normal;
      letter-spacing: normal; orphans: auto; text-align: start;
      text-indent: 0px; text-transform: none; white-space: normal;
      widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px;">
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-25 07:47:50]
      [44501.106916] Oops: 0000 [#1] SMP</span><br style="word-wrap:
      break-word; text-rendering: optimizeLegibility; color: rgb(20, 20,
      20); font-family: -webkit-standard; font-style: normal;
      font-variant-caps: normal; font-weight: normal; letter-spacing:
      normal; orphans: auto; text-align: start; text-indent: 0px;
      text-transform: none; white-space: normal; widows: auto;
      word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px;">
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-25 07:47:50]
      [44501.106924] CPU: 0 PID: 3344 Comm: PassengerAgent Not tainted
      4.14.15-rh13-20180123235331.xenU.i386 #1</span><br
      style="word-wrap: break-word; text-rendering: optimizeLegibility;
      color: rgb(20, 20, 20); font-family: -webkit-standard; font-style:
      normal; font-variant-caps: normal; font-weight: normal;
      letter-spacing: normal; orphans: auto; text-align: start;
      text-indent: 0px; text-transform: none; white-space: normal;
      widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px;">
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-25 07:47:50]
      [44501.106935] task: dfee39c0 task.stack: dff12000</span><br
      style="word-wrap: break-word; text-rendering: optimizeLegibility;
      color: rgb(20, 20, 20); font-family: -webkit-standard; font-style:
      normal; font-variant-caps: normal; font-weight: normal;
      letter-spacing: normal; orphans: auto; text-align: start;
      text-indent: 0px; text-transform: none; white-space: normal;
      widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px;">
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-25 07:47:50]
      [44501.106943] EIP: __radix_tree_lookup+0x14/0xa0</span><br
      style="word-wrap: break-word; text-rendering: optimizeLegibility;
      color: rgb(20, 20, 20); font-family: -webkit-standard; font-style:
      normal; font-variant-caps: normal; font-weight: normal;
      letter-spacing: normal; orphans: auto; text-align: start;
      text-indent: 0px; text-transform: none; white-space: normal;
      widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px;">
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-25 07:47:50]
      [44501.106950] EFLAGS: 00210286 CPU: 0</span><br style="word-wrap:
      break-word; text-rendering: optimizeLegibility; color: rgb(20, 20,
      20); font-family: -webkit-standard; font-style: normal;
      font-variant-caps: normal; font-weight: normal; letter-spacing:
      normal; orphans: auto; text-align: start; text-indent: 0px;
      text-transform: none; white-space: normal; widows: auto;
      word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px;">
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-25 07:47:50]
      [44501.106955] EAX: 00000004 EBX: 00000001 ECX: 00000000 EDX:
      00000000</span><br style="word-wrap: break-word; text-rendering:
      optimizeLegibility; color: rgb(20, 20, 20); font-family:
      -webkit-standard; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;">
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-25 07:47:50]
      [44501.106963] ESI: 00000000 EDI: 00000000 EBP: dff13db8 ESP:
      dff13da0</span><br style="word-wrap: break-word; text-rendering:
      optimizeLegibility; color: rgb(20, 20, 20); font-family:
      -webkit-standard; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;">
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-25 07:47:50]
      [44501.106971] A DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0069</span><br
      style="word-wrap: break-word; text-rendering: optimizeLegibility;
      color: rgb(20, 20, 20); font-family: -webkit-standard; font-style:
      normal; font-variant-caps: normal; font-weight: normal;
      letter-spacing: normal; orphans: auto; text-align: start;
      text-indent: 0px; text-transform: none; white-space: normal;
      widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px;">
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-25 07:47:50]
      [44501.106979] CR0: 80050033 CR2: 00000008 CR3: 1fdb1000 CR4:
      00002660</span><br style="word-wrap: break-word; text-rendering:
      optimizeLegibility; color: rgb(20, 20, 20); font-family:
      -webkit-standard; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;">
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-25 07:47:50]
      [44501.106989] Call Trace:</span><br style="word-wrap: break-word;
      text-rendering: optimizeLegibility; color: rgb(20, 20, 20);
      font-family: -webkit-standard; font-style: normal;
      font-variant-caps: normal; font-weight: normal; letter-spacing:
      normal; orphans: auto; text-align: start; text-indent: 0px;
      text-transform: none; white-space: normal; widows: auto;
      word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px;">
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-25 07:47:50]
      [44501.106995] A radix_tree_lookup_slot+0x13/0x30</span><br
      style="word-wrap: break-word; text-rendering: optimizeLegibility;
      color: rgb(20, 20, 20); font-family: -webkit-standard; font-style:
      normal; font-variant-caps: normal; font-weight: normal;
      letter-spacing: normal; orphans: auto; text-align: start;
      text-indent: 0px; text-transform: none; white-space: normal;
      widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px;">
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-25 07:47:50]
      [44501.107004] A find_get_entry+0x1d/0x120</span><br
      style="word-wrap: break-word; text-rendering: optimizeLegibility;
      color: rgb(20, 20, 20); font-family: -webkit-standard; font-style:
      normal; font-variant-caps: normal; font-weight: normal;
      letter-spacing: normal; orphans: auto; text-align: start;
      text-indent: 0px; text-transform: none; white-space: normal;
      widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px;">
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-25 07:47:50]
      [44501.107011] A pagecache_get_page+0x1f/0x230</span><br
      style="word-wrap: break-word; text-rendering: optimizeLegibility;
      color: rgb(20, 20, 20); font-family: -webkit-standard; font-style:
      normal; font-variant-caps: normal; font-weight: normal;
      letter-spacing: normal; orphans: auto; text-align: start;
      text-indent: 0px; text-transform: none; white-space: normal;
      widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px;">
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-25 07:47:50]
      [44501.107018] A lookup_swap_cache+0x42/0x140</span><br
      style="word-wrap: break-word; text-rendering: optimizeLegibility;
      color: rgb(20, 20, 20); font-family: -webkit-standard; font-style:
      normal; font-variant-caps: normal; font-weight: normal;
      letter-spacing: normal; orphans: auto; text-align: start;
      text-indent: 0px; text-transform: none; white-space: normal;
      widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px;">
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-25 07:47:50]
      [44501.107024] A swap_readahead_detect+0x66/0x2e0</span><br
      style="word-wrap: break-word; text-rendering: optimizeLegibility;
      color: rgb(20, 20, 20); font-family: -webkit-standard; font-style:
      normal; font-variant-caps: normal; font-weight: normal;
      letter-spacing: normal; orphans: auto; text-align: start;
      text-indent: 0px; text-transform: none; white-space: normal;
      widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px;">
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-25 07:47:50]
      [44501.107032] A do_swap_page+0x1fa/0x860</span><br
      style="word-wrap: break-word; text-rendering: optimizeLegibility;
      color: rgb(20, 20, 20); font-family: -webkit-standard; font-style:
      normal; font-variant-caps: normal; font-weight: normal;
      letter-spacing: normal; orphans: auto; text-align: start;
      text-indent: 0px; text-transform: none; white-space: normal;
      widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px;">
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-25 07:47:50]
      [44501.107040] A ?
      __raw_callee_save___pv_queued_spin_unlock+0x9/0x10</span><br
      style="word-wrap: break-word; text-rendering: optimizeLegibility;
      color: rgb(20, 20, 20); font-family: -webkit-standard; font-style:
      normal; font-variant-caps: normal; font-weight: normal;
      letter-spacing: normal; orphans: auto; text-align: start;
      text-indent: 0px; text-transform: none; white-space: normal;
      widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px;">
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-25 07:47:50]
      [44501.107050] A ? xen_pmd_val+0x10/0x20</span><br
      style="word-wrap: break-word; text-rendering: optimizeLegibility;
      color: rgb(20, 20, 20); font-family: -webkit-standard; font-style:
      normal; font-variant-caps: normal; font-weight: normal;
      letter-spacing: normal; orphans: auto; text-align: start;
      text-indent: 0px; text-transform: none; white-space: normal;
      widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px;">
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-25 07:47:50]
      [44501.107057] A handle_mm_fault+0x6f8/0x1020</span><br
      style="word-wrap: break-word; text-rendering: optimizeLegibility;
      color: rgb(20, 20, 20); font-family: -webkit-standard; font-style:
      normal; font-variant-caps: normal; font-weight: normal;
      letter-spacing: normal; orphans: auto; text-align: start;
      text-indent: 0px; text-transform: none; white-space: normal;
      widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px;">
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-25 07:47:50]
      [44501.107065] A ? _raw_spin_unlock_irqrestore+0x13/0x20</span><br
      style="word-wrap: break-word; text-rendering: optimizeLegibility;
      color: rgb(20, 20, 20); font-family: -webkit-standard; font-style:
      normal; font-variant-caps: normal; font-weight: normal;
      letter-spacing: normal; orphans: auto; text-align: start;
      text-indent: 0px; text-transform: none; white-space: normal;
      widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px;">
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-25 07:47:50]
      [44501.107074] A ? pvclock_clocksource_read+0xa6/0x1a0</span><br
      style="word-wrap: break-word; text-rendering: optimizeLegibility;
      color: rgb(20, 20, 20); font-family: -webkit-standard; font-style:
      normal; font-variant-caps: normal; font-weight: normal;
      letter-spacing: normal; orphans: auto; text-align: start;
      text-indent: 0px; text-transform: none; white-space: normal;
      widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px;">
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-25 07:47:50]
      [44501.107081] A __do_page_fault+0x18a/0x450</span><br
      style="word-wrap: break-word; text-rendering: optimizeLegibility;
      color: rgb(20, 20, 20); font-family: -webkit-standard; font-style:
      normal; font-variant-caps: normal; font-weight: normal;
      letter-spacing: normal; orphans: auto; text-align: start;
      text-indent: 0px; text-transform: none; white-space: normal;
      widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px;">
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-25 07:47:50]
      [44501.107089] A ? _copy_to_user+0x28/0x40</span><br
      style="word-wrap: break-word; text-rendering: optimizeLegibility;
      color: rgb(20, 20, 20); font-family: -webkit-standard; font-style:
      normal; font-variant-caps: normal; font-weight: normal;
      letter-spacing: normal; orphans: auto; text-align: start;
      text-indent: 0px; text-transform: none; white-space: normal;
      widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px;">
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-25 07:47:50]
      [44501.107096] A ? vmalloc_sync_all+0x250/0x250</span><br
      style="word-wrap: break-word; text-rendering: optimizeLegibility;
      color: rgb(20, 20, 20); font-family: -webkit-standard; font-style:
      normal; font-variant-caps: normal; font-weight: normal;
      letter-spacing: normal; orphans: auto; text-align: start;
      text-indent: 0px; text-transform: none; white-space: normal;
      widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px;">
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-25 07:47:50]
      [44501.107102] A do_page_fault+0x21/0x30</span><br
      style="word-wrap: break-word; text-rendering: optimizeLegibility;
      color: rgb(20, 20, 20); font-family: -webkit-standard; font-style:
      normal; font-variant-caps: normal; font-weight: normal;
      letter-spacing: normal; orphans: auto; text-align: start;
      text-indent: 0px; text-transform: none; white-space: normal;
      widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px;">
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-25 07:47:50]
      [44501.107109] A common_exception+0x45/0x4a</span><br
      style="word-wrap: break-word; text-rendering: optimizeLegibility;
      color: rgb(20, 20, 20); font-family: -webkit-standard; font-style:
      normal; font-variant-caps: normal; font-weight: normal;
      letter-spacing: normal; orphans: auto; text-align: start;
      text-indent: 0px; text-transform: none; white-space: normal;
      widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px;">
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-25 07:47:50]
      [44501.107115] EIP: 0x82c3358</span><br style="word-wrap:
      break-word; text-rendering: optimizeLegibility; color: rgb(20, 20,
      20); font-family: -webkit-standard; font-style: normal;
      font-variant-caps: normal; font-weight: normal; letter-spacing:
      normal; orphans: auto; text-align: start; text-indent: 0px;
      text-transform: none; white-space: normal; widows: auto;
      word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px;">
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-25 07:47:50]
      [44501.107120] EFLAGS: 00210202 CPU: 0</span><br style="word-wrap:
      break-word; text-rendering: optimizeLegibility; color: rgb(20, 20,
      20); font-family: -webkit-standard; font-style: normal;
      font-variant-caps: normal; font-weight: normal; letter-spacing:
      normal; orphans: auto; text-align: start; text-indent: 0px;
      text-transform: none; white-space: normal; widows: auto;
      word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px;">
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-25 07:47:50]
      [44501.107126] EAX: b702d0b8 EBX: 081557a9 ECX: 00000000 EDX:
      0a4296bc</span><br style="word-wrap: break-word; text-rendering:
      optimizeLegibility; color: rgb(20, 20, 20); font-family:
      -webkit-standard; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;">
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-25 07:47:50]
      [44501.107133] ESI: b467c2cc EDI: 00000000 EBP: b467c138 ESP:
      b467c110</span><br style="word-wrap: break-word; text-rendering:
      optimizeLegibility; color: rgb(20, 20, 20); font-family:
      -webkit-standard; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;">
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-25 07:47:50]
      [44501.107141] A DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b</span><br
      style="word-wrap: break-word; text-rendering: optimizeLegibility;
      color: rgb(20, 20, 20); font-family: -webkit-standard; font-style:
      normal; font-variant-caps: normal; font-weight: normal;
      letter-spacing: normal; orphans: auto; text-align: start;
      text-indent: 0px; text-transform: none; white-space: normal;
      widows: auto; word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px;">
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-25 07:47:50]
      [44501.107147] Code: ff ff ff 00 47 03 e9 69 ff ff ff 8b 45 08 89
      06 e9 1f ff ff ff 66 90 55 89 e5 57 89 d7 56 53 83 ec 0c 89 45 ec
      89 4d e8 8b 45 ec &lt;8b&gt; 58 04 89 d8 83 e0 03 48 89 5d f0 75
      64 89 d8 83 e0 fe 0f b6</span><br style="word-wrap: break-word;
      text-rendering: optimizeLegibility; color: rgb(20, 20, 20);
      font-family: -webkit-standard; font-style: normal;
      font-variant-caps: normal; font-weight: normal; letter-spacing:
      normal; orphans: auto; text-align: start; text-indent: 0px;
      text-transform: none; white-space: normal; widows: auto;
      word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px;">
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-25 07:47:50]
      [44501.110296] EIP: __radix_tree_lookup+0x14/0xa0 SS:ESP:
      0069:dff13da0</span><br style="word-wrap: break-word;
      text-rendering: optimizeLegibility; color: rgb(20, 20, 20);
      font-family: -webkit-standard; font-style: normal;
      font-variant-caps: normal; font-weight: normal; letter-spacing:
      normal; orphans: auto; text-align: start; text-indent: 0px;
      text-transform: none; white-space: normal; widows: auto;
      word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px;">
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-25 07:47:50]
      [44501.110304] CR2: 0000000000000008</span><br style="word-wrap:
      break-word; text-rendering: optimizeLegibility; color: rgb(20, 20,
      20); font-family: -webkit-standard; font-style: normal;
      font-variant-caps: normal; font-weight: normal; letter-spacing:
      normal; orphans: auto; text-align: start; text-indent: 0px;
      text-transform: none; white-space: normal; widows: auto;
      word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px;">
    <span style="color: rgb(20, 20, 20); font-family: -webkit-standard;
      font-size: medium; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;
      display: inline !important; float: none;">[2018-01-25 07:47:50]
      [44501.110356] ---[ end trace 89cdd2ba8e7323a8 ]---</span>
  </body>
</html>

--------------CF75E1793794456A2D1D48BD--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
