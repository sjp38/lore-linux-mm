Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D5FCD6B0005
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 17:26:53 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id w186so5802981pgb.10
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 14:26:53 -0800 (PST)
Received: from mail.rimuhosting.com (mail.rimuhosting.com. [206.123.102.5])
        by mx.google.com with ESMTP id v127si1647580pgv.669.2018.01.29.14.26.51
        for <linux-mm@kvack.org>;
        Mon, 29 Jan 2018 14:26:52 -0800 (PST)
Subject: Re: [Bug 198497] New: handle_mm_fault / xen_pmd_val /
 radix_tree_lookup_slot Null pointer
References: <bug-198497-27@https.bugzilla.kernel.org/>
 <20180118135518.639141f0b0ea8bb047ab6306@linux-foundation.org>
 <7ba7635e-249a-9071-75bb-7874506bd2b2@redhat.com>
 <20180119030447.GA26245@bombadil.infradead.org>
 <d38ff996-8294-81a6-075f-d7b2a60aa2f4@rimuhosting.com>
 <20180119132145.GB2897@bombadil.infradead.org>
 <9d2ddba4-3fb3-0fb4-a058-f2cfd1b05538@redhat.com>
 <32ab6fd6-e3c6-9489-8163-aa73861aa71a@rimuhosting.com>
 <20180126194058.GA31600@bombadil.infradead.org>
From: xen@randonwebstuff.com
Message-ID: <9ff38687-edde-6b4e-4532-9c150f8ea647@rimuhosting.com>
Date: Tue, 30 Jan 2018 11:26:42 +1300
MIME-Version: 1.0
In-Reply-To: <20180126194058.GA31600@bombadil.infradead.org>
Content-Type: multipart/alternative;
 boundary="------------499B6FA920FF86F98D8393BB"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Laura Abbott <labbott@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org

This is a multi-part message in MIME format.
--------------499B6FA920FF86F98D8393BB
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit

On 27/01/18 8:40 AM, Matthew Wilcox wrote:

> On Fri, Jan 26, 2018 at 07:54:06PM +1300, xen@randomwebstuff.com wrote:
>> Re-tried with the current latest 4.14 (4.14.15).A  Received the following:
>>
>> [2018-01-24 19:26:57] dev login: [44501.106868] BUG: unable to handle kernel
>> NULL pointer dereference at 00000008
>> [2018-01-25 07:47:50] [44501.106897] IP: __radix_tree_lookup+0x14/0xa0
> Please try including this patch:
>
> https://bugzilla.kernel.org/show_bug.cgi?id=198497#c7
>
> And have you had the chance to run memtest86 yet?
Added the patch at https://bugzilla.kernel.org/show_bug.cgi?id=198497#c7

After, received this stack.

Have not tried memtest86.A  These are production hosts.A  This has 
occurred on multiple hosts.A  I can only recall this occurring on 32 bit 
kernels.A  I cannot recall issues with other VMs not running that kernel 
on the same hosts.

[ A 125.329163] Bad swp_entry: e000000
[ A 125.329202] ------------[ cut here ]------------
[ A 125.329219] WARNING: CPU: 0 PID: 4175 at mm/swap_state.c:339 
lookup_swap_cache+0x140/0x160
[ A 125.329233] CPU: 0 PID: 4175 Comm: apt-show-versio Not tainted 
4.14.15-rh14-20180126233810.xenU.i386-00001-g6ba70cb #1
[ A 125.329245] task: ead9a940 task.stack: e7c8c000
[ A 125.329253] EIP: lookup_swap_cache+0x140/0x160
[ A 125.329260] EFLAGS: 00010282 CPU: 0
[ A 125.329267] EAX: 00000016 EBX: 00000000 ECX: ec5289c4 EDX: 0100016d
[ A 125.329275] ESI: b6312000 EDI: e7d94ea0 EBP: e7c8de24 ESP: e7c8de0c
[ A 125.329284] A DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0069
[ A 125.329295] CR0: 80050033 CR2: b63124b0 CR3: 2718c000 CR4: 00002660
[ A 125.329308] Call Trace:
[ A 125.329323] A ? percpu_counter_add_batch+0x91/0xb0
[ A 125.329332] A swap_readahead_detect+0x66/0x2e0
[ A 125.329343] A ? radix_tree_tag_set+0x7a/0xe0
[ A 125.329352] A do_swap_page+0x1fa/0x860
[ A 125.329361] A ? __set_page_dirty_buffers+0xb1/0xe0
[ A 125.329372] A ? ext4_set_page_dirty+0x22/0x60
[ A 125.329383] A ? fault_dirty_shared_page.isra.90+0x3e/0xa0
[ A 125.329396] A ? xen_pmd_val+0x10/0x20
[ A 125.329403] A handle_mm_fault+0x6f8/0x1020
[ A 125.329414] A ? handle_irq_event_percpu+0x3c/0x50
[ A 125.329424] A __do_page_fault+0x18a/0x450
[ A 125.329432] A ? vmalloc_sync_all+0x250/0x250
[ A 125.329439] A do_page_fault+0x21/0x30
[ A 125.329449] A common_exception+0x45/0x4a
[ A 125.329456] EIP: 0xb7ce397b
[ A 125.329462] EFLAGS: 00010202 CPU: 0
[ A 125.329469] EAX: 0000052a EBX: b7d77ff4 ECX: 000004fa EDX: b6311000
[ A 125.329477] ESI: bf90eae0 EDI: b6ed4b20 EBP: bf90ea60 ESP: bf90ea20
[ A 125.329486] A DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[ A 125.329493] Code: 18 1f 14 c2 85 ff 0f 85 41 ff ff ff f0 ff 05 38 fb 
02 c2 e9 35 ff ff ff 8d 76 00 89 44 24 04 c7 04 24 55 93 f3 c1 e8 8c e7 
f5 ff <0f> ff 8b 5d f4 31 c0 8b 75 f8 8b 7d fc 89 ec 5d c3 64 ff 05 18
[ A 125.329558] ---[ end trace dd2704ca649b44ba ]---

--------------499B6FA920FF86F98D8393BB
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 8bit

<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  </head>
  <body bgcolor="#FFFFFF" text="#000000">
    <p>On 27/01/18 8:40 AM, Matthew Wilcox wrote:<br>
    </p>
    <blockquote type="cite"
      cite="mid:20180126194058.GA31600@bombadil.infradead.org">
      <pre wrap="">On Fri, Jan 26, 2018 at 07:54:06PM +1300, <a class="moz-txt-link-abbreviated" href="mailto:xen@randomwebstuff.com">xen@randomwebstuff.com</a> wrote:
</pre>
      <blockquote type="cite">
        <pre wrap="">Re-tried with the current latest 4.14 (4.14.15).A  Received the following:

[2018-01-24 19:26:57] dev login: [44501.106868] BUG: unable to handle kernel
NULL pointer dereference at 00000008
[2018-01-25 07:47:50] [44501.106897] IP: __radix_tree_lookup+0x14/0xa0
</pre>
      </blockquote>
      <pre wrap="">
Please try including this patch:

<a class="moz-txt-link-freetext" href="https://bugzilla.kernel.org/show_bug.cgi?id=198497#c7">https://bugzilla.kernel.org/show_bug.cgi?id=198497#c7</a>

And have you had the chance to run memtest86 yet?
</pre>
    </blockquote>
    Added the patch at <a
      href="https://bugzilla.kernel.org/show_bug.cgi?id=198497#c7"
      title="https://bugzilla.kernel.org/show_bug.cgi?id=198497#c7"
      style="word-wrap: break-word; text-rendering: optimizeLegibility;
      color: rgb(0, 51, 204); text-decoration: underline; font-family:
      -webkit-standard; font-style: normal; font-variant-caps: normal;
      font-weight: normal; letter-spacing: normal; orphans: auto;
      text-align: start; text-indent: 0px; text-transform: none;
      white-space: normal; widows: auto; word-spacing: 0px;
      -webkit-text-size-adjust: auto; -webkit-text-stroke-width: 0px;">https://bugzilla.kernel.org/show_bug.cgi?id=198497#c7</a><br>
    <br>
    After, received this stack.<br>
    <br>
    Have not tried memtest86.A  These are production hosts.A  This has
    occurred on multiple hosts.A  I can only recall this occurring on 32
    bit kernels.A  I cannot recall issues with other VMs not running that
    kernel on the same hosts.<br>
    <br style="word-wrap: break-word; text-rendering:
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
      display: inline !important; float: none;">[ A 125.329163] Bad
      swp_entry: e000000</span><br style="word-wrap: break-word;
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
      display: inline !important; float: none;">[ A 125.329202]
      ------------[ cut here ]------------</span><br style="word-wrap:
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
      display: inline !important; float: none;">[ A 125.329219] WARNING:
      CPU: 0 PID: 4175 at mm/swap_state.c:339
      lookup_swap_cache+0x140/0x160</span><br style="word-wrap:
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
      display: inline !important; float: none;">[ A 125.329233] CPU: 0
      PID: 4175 Comm: apt-show-versio Not tainted
      4.14.15-rh14-20180126233810.xenU.i386-00001-g6ba70cb #1</span><br
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
      display: inline !important; float: none;">[ A 125.329245] task:
      ead9a940 task.stack: e7c8c000</span><br style="word-wrap:
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
      display: inline !important; float: none;">[ A 125.329253] EIP:
      lookup_swap_cache+0x140/0x160</span><br style="word-wrap:
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
      display: inline !important; float: none;">[ A 125.329260] EFLAGS:
      00010282 CPU: 0</span><br style="word-wrap: break-word;
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
      display: inline !important; float: none;">[ A 125.329267] EAX:
      00000016 EBX: 00000000 ECX: ec5289c4 EDX: 0100016d</span><br
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
      display: inline !important; float: none;">[ A 125.329275] ESI:
      b6312000 EDI: e7d94ea0 EBP: e7c8de24 ESP: e7c8de0c</span><br
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
      display: inline !important; float: none;">[ A 125.329284] A DS: 007b
      ES: 007b FS: 00d8 GS: 00e0 SS: 0069</span><br style="word-wrap:
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
      display: inline !important; float: none;">[ A 125.329295] CR0:
      80050033 CR2: b63124b0 CR3: 2718c000 CR4: 00002660</span><br
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
      display: inline !important; float: none;">[ A 125.329308] Call
      Trace:</span><br style="word-wrap: break-word; text-rendering:
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
      display: inline !important; float: none;">[ A 125.329323] A ?
      percpu_counter_add_batch+0x91/0xb0</span><br style="word-wrap:
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
      display: inline !important; float: none;">[ A 125.329332]
      A swap_readahead_detect+0x66/0x2e0</span><br style="word-wrap:
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
      display: inline !important; float: none;">[ A 125.329343] A ?
      radix_tree_tag_set+0x7a/0xe0</span><br style="word-wrap:
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
      display: inline !important; float: none;">[ A 125.329352]
      A do_swap_page+0x1fa/0x860</span><br style="word-wrap: break-word;
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
      display: inline !important; float: none;">[ A 125.329361] A ?
      __set_page_dirty_buffers+0xb1/0xe0</span><br style="word-wrap:
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
      display: inline !important; float: none;">[ A 125.329372] A ?
      ext4_set_page_dirty+0x22/0x60</span><br style="word-wrap:
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
      display: inline !important; float: none;">[ A 125.329383] A ?
      fault_dirty_shared_page.isra.90+0x3e/0xa0</span><br
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
      display: inline !important; float: none;">[ A 125.329396] A ?
      xen_pmd_val+0x10/0x20</span><br style="word-wrap: break-word;
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
      display: inline !important; float: none;">[ A 125.329403]
      A handle_mm_fault+0x6f8/0x1020</span><br style="word-wrap:
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
      display: inline !important; float: none;">[ A 125.329414] A ?
      handle_irq_event_percpu+0x3c/0x50</span><br style="word-wrap:
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
      display: inline !important; float: none;">[ A 125.329424]
      A __do_page_fault+0x18a/0x450</span><br style="word-wrap:
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
      display: inline !important; float: none;">[ A 125.329432] A ?
      vmalloc_sync_all+0x250/0x250</span><br style="word-wrap:
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
      display: inline !important; float: none;">[ A 125.329439]
      A do_page_fault+0x21/0x30</span><br style="word-wrap: break-word;
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
      display: inline !important; float: none;">[ A 125.329449]
      A common_exception+0x45/0x4a</span><br style="word-wrap:
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
      display: inline !important; float: none;">[ A 125.329456] EIP:
      0xb7ce397b</span><br style="word-wrap: break-word; text-rendering:
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
      display: inline !important; float: none;">[ A 125.329462] EFLAGS:
      00010202 CPU: 0</span><br style="word-wrap: break-word;
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
      display: inline !important; float: none;">[ A 125.329469] EAX:
      0000052a EBX: b7d77ff4 ECX: 000004fa EDX: b6311000</span><br
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
      display: inline !important; float: none;">[ A 125.329477] ESI:
      bf90eae0 EDI: b6ed4b20 EBP: bf90ea60 ESP: bf90ea20</span><br
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
      display: inline !important; float: none;">[ A 125.329486] A DS: 007b
      ES: 007b FS: 0000 GS: 0033 SS: 007b</span><br style="word-wrap:
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
      display: inline !important; float: none;">[ A 125.329493] Code: 18
      1f 14 c2 85 ff 0f 85 41 ff ff ff f0 ff 05 38 fb 02 c2 e9 35 ff ff
      ff 8d 76 00 89 44 24 04 c7 04 24 55 93 f3 c1 e8 8c e7 f5 ff
      &lt;0f&gt; ff 8b 5d f4 31 c0 8b 75 f8 8b 7d fc 89 ec 5d c3 64 ff
      05 18</span><br style="word-wrap: break-word; text-rendering:
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
      display: inline !important; float: none;">[ A 125.329558] ---[ end
      trace dd2704ca649b44ba ]---</span>
  </body>
</html>

--------------499B6FA920FF86F98D8393BB--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
