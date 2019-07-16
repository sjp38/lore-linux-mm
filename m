Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49E51C76191
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 01:52:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B0C520693
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 01:52:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=protonmail.com header.i=@protonmail.com header.b="lFigifjQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B0C520693
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=protonmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 853F66B0003; Mon, 15 Jul 2019 21:52:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 805C66B0005; Mon, 15 Jul 2019 21:52:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6CCDB6B0006; Mon, 15 Jul 2019 21:52:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0189C6B0003
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 21:52:17 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y15so15077865edu.19
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 18:52:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:dkim-signature:to:from:cc:reply-to:subject
         :message-id:in-reply-to:references:feedback-id:mime-version
         :content-transfer-encoding;
        bh=Bqj395L+h00BrSVvdv+w0wLq2v83ZuFSy4yhjEBCK5U=;
        b=jxwiRaINseCbf0IY4p4PSkKeuFGqcdvgYtMK7lWMrD4AdxEin1ChP9PSykYQmwnQMk
         6N3LkiYNMkwxPLnmGmAwg1SKkde/IuCzcDzpoDD8BeaCHq6lZxVQCBveyvEvpAlCIIK2
         LDA0rc9uD9b7woFi4ymeJI56YXn3IPznsg3Kf4N88jAuoyNZl9UaQPEf4sK7SNvTxlYa
         TGi9XRIC3qSmYY5mfjiiJeRFbP6EdFJl20YWqirtn5sVGjZJcWbAue0My4zoXe9nEFRI
         Ivu1YY+/EC6xkHxDsXLiw9kJQ/Aeq3gMamzEpKTXtG9KrvxhXsfmURh94chw6TswbKc5
         ORcA==
X-Gm-Message-State: APjAAAWCycVMV8Fu63unVzgi1/G7BEqlsc8cG98DCVDgv8oJS/ZICabs
	MI/a8MfuS1v0L18i+27ivufQhlP8X6zcTlaUgWarRbKwFB2lmwzG7qKdpOje6pcWYdjcTrRJ2yI
	VKeCN0/xQXSNMsz/nVTGxHihlDSgoawjefxdu1GNjU6KsZ55/gtXGhFUX2+StgvzDoQ==
X-Received: by 2002:a17:906:e241:: with SMTP id gq1mr23005447ejb.265.1563241936357;
        Mon, 15 Jul 2019 18:52:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyz6Wi/IVKWX9S76d0PLnXl2F2HnTWP7GMaCN5+Rv/kkHAwgUXajh2LE9Nedq9ulbzEEXZS
X-Received: by 2002:a17:906:e241:: with SMTP id gq1mr23005366ejb.265.1563241933952;
        Mon, 15 Jul 2019 18:52:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563241933; cv=none;
        d=google.com; s=arc-20160816;
        b=PCbs4dy4qqA7cn66wJAGLWAe+y8Z90Re0R3v33LP/W9Q+D0x0U2sg9OWoSm4AbQtcf
         2tCqCWbhDbxAML1I51H/+GML8iZ9AUj8KW/H/rQHtBTc97HQWwyxIpwnDJuyihpy87BQ
         ysb2POsOqJ/Kn8gn5PIPw8PpEPFlt94XsA1Qq/zHme3TU/stZrRBsbPYHrwlvQqTwd4O
         dEoHaSsOTtaKYE7PIDLv0A1tBX1RKQ5wHjD1HQWAfj/kpbqqbV4NWpy/H1wmfD7tqGZF
         m/aBppceN/B5eTEcJqH+Op3+TRkloGOc38pBWDj/wkodBmpT//XdPO0oKhoUoSk4ShkU
         9QHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:feedback-id:references
         :in-reply-to:message-id:subject:reply-to:cc:from:to:dkim-signature
         :date;
        bh=Bqj395L+h00BrSVvdv+w0wLq2v83ZuFSy4yhjEBCK5U=;
        b=HlOna8Tp9wOWayKMtjk4q9eFcPeVFnPceST90j9S0U0qL7DVkxhI9sDjjwkSBfHZq6
         3Jg3UEyWNKke69dTv9UBJrCwunSOognMxXwDlWLDyX4zAiJr6x2BL+ly1EWVjpa5WsvI
         RzNhhI0w6eenEaC9mRHsPS6j+jn/OmsT8qnBZyyIyE/vLAQgQRGup4MrZ3MwlZwt2HHR
         aOH25gU4zo6UyGGa0N3DbZiPjQR/ywl9bqFMhDOvCxvOj7Bz4VCqTHPbIcsGUpCxVCBD
         4sgtKYyOhxXsEZuvK0BAw7HXK6RkCfBP+lfD22LKO+hJ9u0q1z93qtKChZ6MKxVa/q7B
         j+1A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@protonmail.com header.s=default header.b=lFigifjQ;
       spf=pass (google.com: domain of howaboutsynergy@protonmail.com designates 185.70.40.135 as permitted sender) smtp.mailfrom=howaboutsynergy@protonmail.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=protonmail.com
Received: from mail-40135.protonmail.ch (mail-40135.protonmail.ch. [185.70.40.135])
        by mx.google.com with ESMTPS id i20si9837043ejb.107.2019.07.15.18.52.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 18:52:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of howaboutsynergy@protonmail.com designates 185.70.40.135 as permitted sender) client-ip=185.70.40.135;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@protonmail.com header.s=default header.b=lFigifjQ;
       spf=pass (google.com: domain of howaboutsynergy@protonmail.com designates 185.70.40.135 as permitted sender) smtp.mailfrom=howaboutsynergy@protonmail.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=protonmail.com
Date: Tue, 16 Jul 2019 01:52:09 +0000
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=protonmail.com;
	s=default; t=1563241932;
	bh=Bqj395L+h00BrSVvdv+w0wLq2v83ZuFSy4yhjEBCK5U=;
	h=Date:To:From:Cc:Reply-To:Subject:In-Reply-To:References:
	 Feedback-ID:From;
	b=lFigifjQu8diha0hB3h+Eu1jVEt6C1OWGAgpFUR+dLNus8cC9QXltfhjz7v0XQSUg
	 S/jQwS1s2HedRdDENLOFDAn8jgzlV1aeJ9rx5ePHEk2ZJ6tIia+kCQZ6ypqjkQUi03
	 FnS4+Vq2fuL6sKRD0KTOYGCBZsYlC2ANc/agcZM4=
To: Andrew Morton <akpm@linux-foundation.org>
From: howaboutsynergy@protonmail.com
Cc: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>
Reply-To: howaboutsynergy@protonmail.com
Subject: Re: [Bug 204165] New: 100% CPU usage in compact_zone_order
Message-ID: <GX2mE2MIJ0H5o4mejfgRsT-Ng_bb19MXio4XzPWFjRzVb4cNpvDC1JXNqtX3k44MpbKg4IEg3amOh5V2Qt0AfMev1FZJoAWNh_CdfYIqxJ0=@protonmail.com>
In-Reply-To: <pLm2kTLklcV9AmHLFjB1oi04nZf9UTLlvnvQZoq44_ouTn3LhqcDD8Vi7xjr9qaTbrHfY5rKdwD6yVr43YCycpzm7MDLcbTcrYmGA4O0weU=@protonmail.com>
References: <bug-204165-27@https.bugzilla.kernel.org/>
 <20190715142524.e0df173a9d7f81a384abf28f@linux-foundation.org>
 <pLm2kTLklcV9AmHLFjB1oi04nZf9UTLlvnvQZoq44_ouTn3LhqcDD8Vi7xjr9qaTbrHfY5rKdwD6yVr43YCycpzm7MDLcbTcrYmGA4O0weU=@protonmail.com>
Feedback-ID: cNV1IIhYZ3vPN2m1zihrGlihbXC6JOgZ5ekTcEurWYhfLPyLhpq0qxICavacolSJ7w0W_XBloqfdO_txKTblOQ==:Ext:ProtonMail
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90 Original Me=
ssage =E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90
On Tuesday, July 16, 2019 1:28 AM, <howaboutsynergy@protonmail.com> wrote:

> =E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90 Original =
Message =E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90
> On Monday, July 15, 2019 11:25 PM, Andrew Morton akpm@linux-foundation.or=
g wrote:
>
> > (switched to email. Please respond via emailed reply-to-all, not via th=
e
> > bugzilla web interface).
>
> Roger that.
>
> > On Sat, 13 Jul 2019 19:20:21 +0000 bugzilla-daemon@bugzilla.kernel.org =
wrote:
> >
> > > https://bugzilla.kernel.org/show_bug.cgi?id=3D204165
> > >
> > >             Bug ID: 204165
> > >            Summary: 100% CPU usage in compact_zone_order
> > >
> >
> > Looks like we have a lockup in compact_zone()
> >
> > >            Product: Memory Management
> > >            Version: 2.5
> > >     Kernel Version: 5.2.0-g0ecfebd2b524
> > >           Hardware: x86-64
> > >                 OS: Linux
> > >               Tree: Mainline
> > >             Status: NEW
> > >           Severity: normal
> > >           Priority: P1
> > >          Component: Page Allocator
> > >           Assignee: akpm@linux-foundation.org
> > >           Reporter: howaboutsynergy@pm.me
> > >         Regression: No
> > >
> >
> > I assume this should be "yes". Did previous kernels exhibit this
> > behavior or is it new in 5.2?
>
> Regression: yes?
> I'm not sure...
> tl;dr: seen with kernel linux-stable 5.1.8.r0.g937cc0cc22a2-1
> And really not sure if I've seen it before.
>
> long read:
> At least one previous kernel did because I've seen this before in https:/=
/bugzilla.kernel.org/show_bug.cgi?id=3D203833#c1 where I thought it was due=
 to 'teo' governor but it wasn't (I'm using 'menu' gov. now)
>
> I didn't mention kernel version there, but according to irc logs where I =
seek'd help at the time, the date was June 10th 2019 3am, checking which ke=
rnel I was running at the time (thanks to my q1q repo. git logs) it was 5.1=
.8 (stable)kernel to which I updated on Sun Jun 9 10:50:09 2019 +0200 and h=
ave not changed until Tue Jun 11 05:16:59 2019 +0200
> local/linux-stable 5.1.8.r0.g937cc0cc22a2-1 (builtbydaddy)
>
> Side note:
> I've encountered something similar here https://github.com/constantoverri=
de/qubes-linux-kernel/issues/2
> where kworker would randomly start using 100% CPU and couldn't be killed.=
 The kernel there was 4.18.7, the VM had very little RAM in Qubes there. Si=
nce it's probably a different bug due to that stacktrace being so different=
/unrelated, please ignore.

Well after a maybe 50+ tries, got it triggered on kernel 5.2.1-g527a3db363a=
3

```
$ time stress -m 220 --vm-bytes 10000000000 --timeout 10
stress: info: [19317] dispatching hogs: 0 cpu, 0 io, 220 vm, 0 hdd
stress: FAIL: [19317] (415) <-- worker 19536 got signal 9
stress: WARN: [19317] (417) now reaping child worker processes
stress: FAIL: [19317] (415) <-- worker 19530 got signal 9
stress: WARN: [19317] (417) now reaping child worker processes
```


MiB Mem :  31745.3 total,  28945.2 free,   2055.4 used,    744.7 buff/cache
MiB Swap:  65536.0 total,  63410.3 free,   2125.7 used.  28774.5 avail Mem

  PID  %CPU COMMAND                                                        =
                    PR  NI    VIRT    RES S USER
19335 100.0 stress                                                         =
                    20   0 9769416     12 R user
19376 100.0 stress                                                         =
                    20   0 9769416      0 R user
19418 100.0 stress                                                         =
                    20   0 9769416     12 R user
19490 100.0 stress                                                         =
                    20   0 9769416      8 R user
21020 100.0 dmesg                                                          =
                    20   0    6112   2636 R user


```
[ 1572.246553] sysrq: Show backtrace of all active CPUs
[ 1572.246563] NMI backtrace for cpu 8
[ 1572.246572] CPU: 8 PID: 0 Comm: swapper/8 Kdump: loaded Tainted: G     U=
            5.2.1-g527a3db363a3 #68
[ 1572.246579] Hardware name: System manufacturer System Product Name/PRIME=
 Z370-A, BIOS 1002 07/02/2018
[ 1572.246582] Call Trace:
[ 1572.246589]  <IRQ>
[ 1572.246603]  dump_stack+0x46/0x60
[ 1572.246615]  nmi_cpu_backtrace.cold+0x14/0x53
[ 1572.246623]  ? lapic_can_unplug_cpu.cold+0x42/0x42
[ 1572.246634]  nmi_trigger_cpumask_backtrace+0x8e/0x90
[ 1572.246641]  __handle_sysrq.cold+0x48/0x102
[ 1572.246650]  sysrq_filter+0x2ea/0x3b0
[ 1572.246658]  input_to_handler+0x4d/0xf0
[ 1572.246668]  input_pass_values.part.0+0x109/0x130
[ 1572.246675]  input_handle_event+0x171/0x5a0
[ 1572.246684]  input_event+0x4d/0x70
[ 1572.246694]  hidinput_report_event+0x2e/0x40
[ 1572.246703]  hid_report_raw_event+0x260/0x430
[ 1572.246710]  hid_input_report+0xfb/0x150
[ 1572.246721]  hid_irq_in+0x168/0x190
[ 1572.246730]  __usb_hcd_giveback_urb+0x77/0xe0
[ 1572.246754]  xhci_giveback_urb_in_irq.isra.0+0x62/0x90 [xhci_hcd]
[ 1572.246777]  xhci_td_cleanup+0xf7/0x140 [xhci_hcd]
[ 1572.246799]  xhci_irq+0x7e8/0x1be0 [xhci_hcd]
[ 1572.246811]  __handle_irq_event_percpu+0x2f/0xc0
[ 1572.246820]  handle_irq_event_percpu+0x2c/0x80
[ 1572.246827]  handle_irq_event+0x23/0x43
[ 1572.246838]  handle_edge_irq+0x78/0x190
[ 1572.246846]  handle_irq+0x17/0x20
[ 1572.246857]  do_IRQ+0x3e/0xd0
[ 1572.246865]  common_interrupt+0xf/0xf
[ 1572.246872]  </IRQ>
[ 1572.246880] RIP: 0010:cpuidle_enter_state+0x11f/0x2a0
[ 1572.246890] Code: e8 d6 1c a1 ff 49 89 c6 31 ff e8 fc 2c a1 ff 45 84 ff =
74 12 9c 58 f6 c4 02 0f 85 65 01 00 00 31 ff e8 d5 18 a6 ff fb 45 85 ed <0f=
> 88 c0 00 00 00 49 63 f5 48 8d 04 76 48 c1 e0 05 8b 7c 03 4c 4c
[ 1572.246895] RSP: 0018:ffffbd38c3217e80 EFLAGS: 00000206 ORIG_RAX: ffffff=
ffffffffde
[ 1572.246904] RAX: ffff9699ada5cb00 RBX: ffffffff93062340 RCX: 00000000000=
0001f
[ 1572.246909] RDX: 0000000000000000 RSI: 0000000022a1cd05 RDI: 00000000000=
00000
[ 1572.246916] RBP: 0000016e1126287d R08: 0000016e11320f1b R09: 000000007ff=
fffff
[ 1572.246921] R10: ffff9699ada5bc44 R11: ffff9699ada5bc24 R12: ffff9699ada=
65b00
[ 1572.246925] R13: 0000000000000006 R14: 0000016e11320f1b R15: 00000000000=
00000
[ 1572.246936]  cpuidle_enter+0x24/0x40
[ 1572.246945]  do_idle+0x1c1/0x230
[ 1572.246955]  cpu_startup_entry+0x14/0x20
[ 1572.246963]  start_secondary+0x168/0x1b0
[ 1572.246972]  secondary_startup_64+0xa4/0xb0
[ 1572.246981] Sending NMI from CPU 8 to CPUs 0-7,9-11:
[ 1572.247108] NMI backtrace for cpu 0
[ 1572.247110] CPU: 0 PID: 19376 Comm: stress Kdump: loaded Tainted: G     =
U            5.2.1-g527a3db363a3 #68
[ 1572.247111] Hardware name: System manufacturer System Product Name/PRIME=
 Z370-A, BIOS 1002 07/02/2018
[ 1572.247112] RIP: 0010:compact_zone+0x3cf/0xa70
[ 1572.247115] Code: 7f 70 02 74 07 83 ce 04 89 74 24 50 45 0f b6 6f 74 48 =
8b 55 60 45 84 ed 0f 85 5d 02 00 00 48 39 d0 0f 84 3d 02 00 00 48 89 c7 <48=
> 81 e7 00 fe ff ff a9 ff 01 00 00 0f 84 28 02 00 00 49 89 c4 48
[ 1572.247116] RSP: 0018:ffffbd38cfca7a18 EFLAGS: 00000202
[ 1572.247118] RAX: 000000000022c720 RBX: 000000000022ca00 RCX: 00000000000=
01163
[ 1572.247119] RDX: 0000000000100000 RSI: 000000000000000c RDI: 00000000002=
2c720
[ 1572.247122] RBP: ffff9699cdfded00 R08: 0000000000000001 R09: ffff9699ad6=
5d550
[ 1572.247123] R10: 0000000000000001 R11: ffff9699ad65cb80 R12: 00000000000=
00009
[ 1572.247124] R13: 0000000000000000 R14: 000000000022c720 R15: ffffbd38cfc=
a7ad0
[ 1572.247125] FS:  0000710f1082f740(0000) GS:ffff9699ad600000(0000) knlGS:=
0000000000000000
[ 1572.247126] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1572.247127] CR2: 000056d077f9cea8 CR3: 000000027ed88005 CR4: 00000000003=
606f0
[ 1572.247128] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000000000=
00000
[ 1572.247129] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 00000000000=
00400
[ 1572.247130] Call Trace:
[ 1572.247130]  compact_zone_order+0xde/0x120
[ 1572.247131]  try_to_compact_pages+0x187/0x240
[ 1572.247132]  __alloc_pages_direct_compact+0x87/0x170
[ 1572.247133]  __alloc_pages_slowpath+0x454/0xc20
[ 1572.247134]  ? release_pages+0x348/0x3b0
[ 1572.247134]  __alloc_pages_nodemask+0x268/0x2b0
[ 1572.247137]  do_huge_pmd_anonymous_page+0x131/0x5c0
[ 1572.247138]  __handle_mm_fault+0xc0c/0x1310
[ 1572.247139]  handle_mm_fault+0xa9/0x1d0
[ 1572.247139]  __do_page_fault+0x237/0x480
[ 1572.247140]  do_page_fault+0x1d/0x67
[ 1572.247141]  ? page_fault+0x8/0x30
[ 1572.247142]  page_fault+0x1e/0x30
[ 1572.247143] RIP: 0033:0x5f7c81c80c10
[ 1572.247145] Code: c0 0f 84 53 02 00 00 8b 54 24 0c 31 c0 85 d2 0f 94 c0 =
89 04 24 41 83 fd 02 0f 8f fa 00 00 00 31 c0 4d 85 ff 7e 10 0f 1f 40 00 <c6=
> 04 03 5a 4c 01 f0 49 39 c7 7f f4 4d 85 e4 0f 84 f4 01 00 00 7e
[ 1572.247145] RSP: 002b:00007ffdb884d190 EFLAGS: 00010206
[ 1572.247147] RAX: 0000000016e90000 RBX: 0000710cbc770010 RCX: 0000710f109=
543db
[ 1572.247148] RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000710cbc7=
70000
[ 1572.247149] RBP: 00005f7c81c81a54 R08: 0000710cbc770010 R09: 00000000000=
00000
[ 1572.247152] R10: 0000000000000022 R11: 00000002540be400 R12: fffffffffff=
fffff
[ 1572.247153] R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540=
be400
[ 1572.247212] NMI backtrace for cpu 1
[ 1572.247214] CPU: 1 PID: 19335 Comm: stress Kdump: loaded Tainted: G     =
U            5.2.1-g527a3db363a3 #68
[ 1572.247216] Hardware name: System manufacturer System Product Name/PRIME=
 Z370-A, BIOS 1002 07/02/2018
[ 1572.247217] RIP: 0010:isolate_migratepages_block+0x267/0xa50
[ 1572.247219] Code: 00 00 00 c4 e2 f9 f7 c6 48 8d 5c 03 ff 45 84 ed 0f 85 =
17 ff ff ff 48 ff c3 48 39 5c 24 08 0f 87 46 ff ff ff 4d 89 d7 4d 89 e6 <48=
> 89 d8 0f b6 54 24 77 48 3b 5c 24 08 0f 87 25 02 00 00 84 d2 0f
[ 1572.247220] RSP: 0018:ffffbd38cfb5f958 EFLAGS: 00000202
[ 1572.247223] RAX: 0000000000000001 RBX: 000000000018c060 RCX: ffffbd38cfb=
5fb49
[ 1572.247224] RDX: 0000000000000004 RSI: 0000000000000000 RDI: ffff9699cdf=
ffb00
[ 1572.247225] RBP: ffff9699cdfde000 R08: 0000000000000001 R09: ffff9699ad6=
dd550
[ 1572.247226] R10: 0000000000000000 R11: ffff969946236600 R12: ffffbd38cfb=
5fad0
[ 1572.247230] R13: 0000000000000000 R14: ffffbd38cfb5fad0 R15: 00000000000=
00000
[ 1572.247232] FS:  0000710f1082f740(0000) GS:ffff9699ad680000(0000) knlGS:=
0000000000000000
[ 1572.247233] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1572.247234] CR2: 00007f6eb6d40faa CR3: 000000080b004002 CR4: 00000000003=
606e0
[ 1572.247235] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000000000=
00000
[ 1572.247237] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 00000000000=
00400
[ 1572.247237] Call Trace:
[ 1572.247238]  compact_zone+0x577/0xa70
[ 1572.247239]  compact_zone_order+0xde/0x120
[ 1572.247241]  try_to_compact_pages+0x187/0x240
[ 1572.247242]  __alloc_pages_direct_compact+0x87/0x170
[ 1572.247248]  __alloc_pages_slowpath+0x454/0xc20
[ 1572.247259]  ? release_pages+0x348/0x3b0
[ 1572.247265]  ? __pagevec_lru_add_fn+0x189/0x2a0
[ 1572.247266]  __alloc_pages_nodemask+0x268/0x2b0
[ 1572.247267]  do_huge_pmd_anonymous_page+0x131/0x5c0
[ 1572.247268]  __handle_mm_fault+0xc0c/0x1310
[ 1572.247269]  handle_mm_fault+0xa9/0x1d0
[ 1572.247270]  __do_page_fault+0x237/0x480
[ 1572.247272]  do_page_fault+0x1d/0x67
[ 1572.247273]  ? page_fault+0x8/0x30
[ 1572.247275]  page_fault+0x1e/0x30
[ 1572.247276] RIP: 0033:0x5f7c81c80c10
[ 1572.247280] Code: c0 0f 84 53 02 00 00 8b 54 24 0c 31 c0 85 d2 0f 94 c0 =
89 04 24 41 83 fd 02 0f 8f fa 00 00 00 31 c0 4d 85 ff 7e 10 0f 1f 40 00 <c6=
> 04 03 5a 4c 01 f0 49 39 c7 7f f4 4d 85 e4 0f 84 f4 01 00 00 7e
[ 1572.247281] RSP: 002b:00007ffdb884d190 EFLAGS: 00010206
[ 1572.247287] RAX: 0000000015c90000 RBX: 0000710cbc770010 RCX: 0000710f109=
543db
[ 1572.247289] RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000710cbc7=
70000
[ 1572.247290] RBP: 00005f7c81c81a54 R08: 0000710cbc770010 R09: 00000000000=
00000
[ 1572.247292] R10: 0000000000000022 R11: 00000002540be400 R12: fffffffffff=
fffff
[ 1572.247293] R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540=
be400
[ 1572.247321] NMI backtrace for cpu 2
[ 1572.247328] CPU: 2 PID: 19490 Comm: stress Kdump: loaded Tainted: G     =
U            5.2.1-g527a3db363a3 #68
[ 1572.247331] Hardware name: System manufacturer System Product Name/PRIME=
 Z370-A, BIOS 1002 07/02/2018
[ 1572.247335] RIP: 0010:isolate_migratepages_block+0x1c/0xa50
[ 1572.247339] Code: 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 40 00 41 57 41 56 =
41 55 41 54 55 53 48 81 ec 88 00 00 00 49 89 fe 48 89 f3 48 89 54 24 08 <89=
> 4c 24 3c 65 48 8b 04 25 28 00 00 00 48 89 84 24 80 00 00 00 31
[ 1572.247346] RSP: 0018:ffffbd3929043958 EFLAGS: 00000292
[ 1572.247358] RAX: 0000000000000000 RBX: 000000000062b760 RCX: 00000000000=
0000c
[ 1572.247361] RDX: 000000000062b800 RSI: 000000000062b760 RDI: ffffbd39290=
43ad0
[ 1572.247364] RBP: ffffbd3929043ad0 R08: 0000000000000001 R09: ffff9699ad7=
5d550
[ 1572.247368] R10: 0000000000000001 R11: ffff9699ad75cb80 R12: 00000000006=
2b800
[ 1572.247371] R13: ffff9699cdfded00 R14: ffffbd3929043ad0 R15: ffffbd39290=
43ad0
[ 1572.247377] FS:  0000710f1082f740(0000) GS:ffff9699ad700000(0000) knlGS:=
0000000000000000
[ 1572.247380] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1572.247390] CR2: 000077de6c7b3ec4 CR3: 000000080bde2005 CR4: 00000000003=
606e0
[ 1572.247393] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000000000=
00000
[ 1572.247397] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 00000000000=
00400
[ 1572.247402] Call Trace:
[ 1572.247409]  compact_zone+0x577/0xa70
[ 1572.247415]  compact_zone_order+0xde/0x120
[ 1572.247418]  try_to_compact_pages+0x187/0x240
[ 1572.247423]  __alloc_pages_direct_compact+0x87/0x170
[ 1572.247426]  __alloc_pages_slowpath+0x454/0xc20
[ 1572.247432]  ? release_pages+0x348/0x3b0
[ 1572.247439]  ? __pagevec_lru_add_fn+0x189/0x2a0
[ 1572.247442]  __alloc_pages_nodemask+0x268/0x2b0
[ 1572.247448]  do_huge_pmd_anonymous_page+0x131/0x5c0
[ 1572.247450]  __handle_mm_fault+0xc0c/0x1310
[ 1572.247455]  handle_mm_fault+0xa9/0x1d0
[ 1572.247460]  __do_page_fault+0x237/0x480
[ 1572.247464]  do_page_fault+0x1d/0x67
[ 1572.247468]  ? page_fault+0x8/0x30
[ 1572.247473]  page_fault+0x1e/0x30
[ 1572.247476] RIP: 0033:0x5f7c81c80c10
[ 1572.247482] Code: c0 0f 84 53 02 00 00 8b 54 24 0c 31 c0 85 d2 0f 94 c0 =
89 04 24 41 83 fd 02 0f 8f fa 00 00 00 31 c0 4d 85 ff 7e 10 0f 1f 40 00 <c6=
> 04 03 5a 4c 01 f0 49 39 c7 7f f4 4d 85 e4 0f 84 f4 01 00 00 7e
[ 1572.247488] RSP: 002b:00007ffdb884d190 EFLAGS: 00010206
[ 1572.247494] RAX: 0000000019c90000 RBX: 0000710cbc770010 RCX: 0000710f109=
543db
[ 1572.247500] RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000710cbc7=
70000
[ 1572.247504] RBP: 00005f7c81c81a54 R08: 0000710cbc770010 R09: 00000000000=
00000
[ 1572.247507] R10: 0000000000000022 R11: 00000002540be400 R12: fffffffffff=
fffff
[ 1572.247511] R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540=
be400
[ 1572.247516] NMI backtrace for cpu 5
[ 1572.247520] CPU: 5 PID: 1273 Comm: dmesg Kdump: loaded Tainted: G     U =
           5.2.1-g527a3db363a3 #68
[ 1572.247525] Hardware name: System manufacturer System Product Name/PRIME=
 Z370-A, BIOS 1002 07/02/2018
[ 1572.247530] RIP: 0033:0x7de7c0c81388
[ 1572.247534] Code: 85 e4 fa ff ff 00 00 00 00 c7 85 e0 fa ff ff 00 00 00 =
00 e9 38 f4 ff ff 66 2e 0f 1f 84 00 00 00 00 00 48 83 bd e8 fa ff ff 00 <0f=
> 84 5c 0c 00 00 0f b6 85 dc fa ff ff 83 e0 01 83 bd f0 fa ff ff
[ 1572.247537] RSP: 002b:00007ffeedcb2aa0 EFLAGS: 00000206
[ 1572.247546] RAX: 0000000000000000 RBX: 0000000000000001 RCX: 00000000000=
00004
[ 1572.247551] RDX: 0000000000000000 RSI: 00007de7c0dc95c0 RDI: 00000000000=
00000
[ 1572.247557] RBP: 00007ffeedcb3010 R08: 00007ffeedcb2fd4 R09: 00000000000=
00001
[ 1572.247560] R10: 0000560441280093 R11: 00007ffeedcb2fd4 R12: 00007ffeedc=
b3030
[ 1572.247563] R13: 000056044128008f R14: 00007ffeedcb31b0 R15: 00000000000=
00064
[ 1572.247568] FS:  00007de7c0c01740 GS:  0000000000000000
[ 1572.247575] NMI backtrace for cpu 4
[ 1572.247580] CPU: 4 PID: 1245 Comm: dmesg Kdump: loaded Tainted: G     U =
           5.2.1-g527a3db363a3 #68
[ 1572.247584] Hardware name: System manufacturer System Product Name/PRIME=
 Z370-A, BIOS 1002 07/02/2018
[ 1572.247587] RIP: 0010:_raw_spin_lock+0xb/0x20
[ 1572.247690] Code: 81 05 6d b7 81 6d 00 02 00 00 31 c0 ba ff 00 00 00 f0 =
0f b1 17 75 01 c3 e9 92 14 8f ff 66 90 31 c0 ba 01 00 00 00 f0 0f b1 17 <75=
> 01 c3 89 c6 e9 1b 04 8f ff 66 66 2e 0f 1f 84 00 00 00 00 00 65
[ 1572.247801] RSP: 0018:ffffbd38c546bcb8 EFLAGS: 00000097
[ 1572.247812] RAX: 0000000000000001 RBX: ffff96994b4e5ac0 RCX: 00000000000=
0000a
[ 1572.247815] RDX: 0000000000000001 RSI: ffff9699ad800000 RDI: ffff9699adb=
5cb00
[ 1572.247818] RBP: ffff9699adb5cb00 R08: 000000000000000a R09: ffffbd38c54=
6bd90
[ 1572.247821] R10: 0000000000000000 R11: 0000000000000004 R12: 00000000000=
00001
[ 1572.247827] R13: 0000000000000046 R14: ffff96994b4e6204 R15: 00000000000=
5cb00
[ 1572.247830] FS:  000077a36f17e740(0000) GS:ffff9699ad800000(0000) knlGS:=
0000000000000000
[ 1572.247833] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1572.247837] CR2: 000072d7ae4d9578 CR3: 00000007ca59c006 CR4: 00000000003=
606e0
[ 1572.247840] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000000000=
00000
[ 1572.247847] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 00000000000=
00400
[ 1572.247850] Call Trace:
[ 1572.247853]  try_to_wake_up+0x18d/0x500
[ 1572.247855]  autoremove_wake_function+0xc/0x50
[ 1572.247858]  __wake_up_common+0x7a/0x190
[ 1572.247861]  __wake_up_common_lock+0x79/0xc0
[ 1572.247864]  pipe_write+0x1e3/0x410
[ 1572.247869]  new_sync_write+0x116/0x1b0
[ 1572.247875]  vfs_write+0xb1/0x190
[ 1572.247878]  ksys_write+0x5d/0xe0
[ 1572.247881]  do_syscall_64+0x50/0x170
[ 1572.247884]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[ 1572.247886] RIP: 0033:0x77a36f2984ba
[ 1572.247894] Code: 48 c7 c0 ff ff ff ff eb bc 0f 1f 80 00 00 00 00 f3 0f =
1e fa 64 8b 04 25 18 00 00 00 85 c0 75 18 b8 01 00 00 00 c5 fc 77 0f 05 <48=
> 3d 00 f0 ff ff 77 56 c3 0f 1f 44 00 00 55 48 89 e5 48 83 ec 20
[ 1572.247897] RSP: 002b:00007fffd15cf728 EFLAGS: 00000246 ORIG_RAX: 000000=
0000000001
[ 1572.247903] RAX: ffffffffffffffda RBX: 0000000000000029 RCX: 000077a36f2=
984ba
[ 1572.247906] RDX: 0000000000000029 RSI: 00006261bcaad3c0 RDI: 00000000000=
00001
[ 1572.247909] RBP: 00007fffd15cf750 R08: 000000000000000a R09: 00000000000=
00000
[ 1572.247912] R10: 00007fffd15cf77c R11: 0000000000000246 R12: 00000000000=
00029
[ 1572.247918] R13: 00006261bcaad3c0 R14: 000077a36f36d500 R15: 000077a36f3=
6e300
[ 1572.247922] NMI backtrace for cpu 3
[ 1572.247926] CPU: 3 PID: 19418 Comm: stress Kdump: loaded Tainted: G     =
U            5.2.1-g527a3db363a3 #68
[ 1572.247929] Hardware name: System manufacturer System Product Name/PRIME=
 Z370-A, BIOS 1002 07/02/2018
[ 1572.247932] RIP: 0010:isolate_migratepages_block+0xad/0xa50
[ 1572.247938] Code: 89 ef e8 06 91 ff ff 49 89 c7 be 01 00 00 00 48 89 ef =
e8 f6 90 ff ff 49 89 c5 be 08 00 00 00 48 89 ef e8 e6 90 ff ff 49 89 c4 <be=
> 07 00 00 00 48 89 ef e8 d6 90 ff ff 49 01 c4 4c 03 3c 24 4d 01
[ 1572.247944] RSP: 0018:ffffbd38cfdf7958 EFLAGS: 00000246
[ 1572.247952] RAX: 0000000000000000 RBX: 00000000006f1ba0 RCX: 00000000000=
0000c
[ 1572.247955] RDX: 0000000000000000 RSI: 0000000000000008 RDI: ffff9699cdf=
de000
[ 1572.247958] RBP: ffff9699cdfde000 R08: 0000000000000001 R09: ffff9699ad7=
dd550
[ 1572.247964] R10: 0000000000000001 R11: ffff9699ad7dcb80 R12: 00000000000=
00000
[ 1572.247969] R13: 00000000000012b2 R14: ffffbd38cfdf7ad0 R15: 00000000000=
018a8
[ 1572.247972] FS:  0000710f1082f740(0000) GS:ffff9699ad780000(0000) knlGS:=
0000000000000000
[ 1572.247974] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1572.247977] CR2: 000072d7ae4d9578 CR3: 00000007c59c4001 CR4: 00000000003=
606e0
[ 1572.247980] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000000000=
00000
[ 1572.247983] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 00000000000=
00400
[ 1572.247987] Call Trace:
[ 1572.247990]  compact_zone+0x577/0xa70
[ 1572.247992]  compact_zone_order+0xde/0x120
[ 1572.247995]  try_to_compact_pages+0x187/0x240
[ 1572.248000]  __alloc_pages_direct_compact+0x87/0x170
[ 1572.248004]  __alloc_pages_slowpath+0x454/0xc20
[ 1572.248007]  __alloc_pages_nodemask+0x268/0x2b0
[ 1572.248010]  do_huge_pmd_anonymous_page+0x131/0x5c0
[ 1572.248013]  ? mem_cgroup_throttle_swaprate+0x20/0x113
[ 1572.248018]  __handle_mm_fault+0xc0c/0x1310
[ 1572.248023]  handle_mm_fault+0xa9/0x1d0
[ 1572.248026]  __do_page_fault+0x237/0x480
[ 1572.248030]  do_page_fault+0x1d/0x67
[ 1572.248035]  ? page_fault+0x8/0x30
[ 1572.248039]  page_fault+0x1e/0x30
[ 1572.248042] RIP: 0033:0x5f7c81c80c10
[ 1572.248046] Code: c0 0f 84 53 02 00 00 8b 54 24 0c 31 c0 85 d2 0f 94 c0 =
89 04 24 41 83 fd 02 0f 8f fa 00 00 00 31 c0 4d 85 ff 7e 10 0f 1f 40 00 <c6=
> 04 03 5a 4c 01 f0 49 39 c7 7f f4 4d 85 e4 0f 84 f4 01 00 00 7e
[ 1572.248050] RSP: 002b:00007ffdb884d190 EFLAGS: 00010206
[ 1572.248058] RAX: 0000000026a90000 RBX: 0000710cbc770010 RCX: 0000710f109=
543db
[ 1572.248060] RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000710cbc7=
70000
[ 1572.248065] RBP: 00005f7c81c81a54 R08: 0000710cbc770010 R09: 00000000000=
00000
[ 1572.248070] R10: 0000000000000022 R11: 00000002540be400 R12: fffffffffff=
fffff
[ 1572.248073] R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540=
be400
[ 1572.248078] NMI backtrace for cpu 6
[ 1572.248082] CPU: 6 PID: 1258 Comm: dmesg Kdump: loaded Tainted: G     U =
           5.2.1-g527a3db363a3 #68
[ 1572.248087] Hardware name: System manufacturer System Product Name/PRIME=
 Z370-A, BIOS 1002 07/02/2018
[ 1572.248092] RIP: 0033:0x7cfec2fbca97
[ 1572.248097] Code: 00 00 00 83 e1 1f 48 83 e7 e0 c5 7e 6f 07 c4 c1 7d 74 =
c8 c4 c1 35 74 d0 c5 ed eb c9 c5 fd d7 c1 d3 f8 85 c0 74 1d f3 0f bc c0 <48=
> 01 c8 31 d2 48 8d 04 07 40 3a 30 48 0f 45 c2 c5 f8 77 c3 0f 1f
[ 1572.248102] RSP: 002b:00007fffc45dab98 EFLAGS: 00000202
[ 1572.248110] RAX: 0000000000000001 RBX: 0000582b21b12475 RCX: 00000000000=
0001a
[ 1572.248113] RDX: 0000000000000000 RSI: 000000000000005f RDI: 0000582b21b=
0e7e0
[ 1572.248118] RBP: 0000582b21b0e7fa R08: 000000000000000a R09: 00000000000=
00000
[ 1572.248123] R10: 00007fffc45da9ac R11: 0000000000000246 R12: 0000582b21b=
12459
[ 1572.248126] R13: 0000582b21b0d377 R14: 0000582b21b12440 R15: 0000582b21b=
12456
[ 1572.248131] FS:  00007cfec2e27740 GS:  0000000000000000
[ 1572.248134] NMI backtrace for cpu 7
[ 1572.248137] CPU: 7 PID: 1249 Comm: dmesg Kdump: loaded Tainted: G     U =
           5.2.1-g527a3db363a3 #68
[ 1572.248143] Hardware name: System manufacturer System Product Name/PRIME=
 Z370-A, BIOS 1002 07/02/2018
[ 1572.248145] RIP: 0010:number+0x234/0x360
[ 1572.248149] Code: c6 00 20 48 ff c0 4c 39 c0 75 f0 48 8b 44 24 30 65 48 =
33 04 25 28 00 00 00 0f 85 31 01 00 00 4c 89 c0 48 83 c4 38 5b 5d 41 5c <41=
> 5d 41 5e 41 5f c3 83 e5 ef 44 88 7c 24 16 e9 2e fe ff ff 48 f7
[ 1572.248152] RSP: 0018:ffffbd38c541bd40 EFLAGS: 00000086
[ 1572.248163] RAX: ffff96994b6f0059 RBX: ffffbd38c541bdb8 RCX: 00000000fff=
ffffb
[ 1572.248168] RDX: ffffbd38c541bd07 RSI: 0000000000000034 RDI: ffff969a4b6=
f0056
[ 1572.248170] RBP: ffff96994b6f2058 R08: ffff96994b6f0059 R09: 00000000000=
00000
[ 1572.248172] R10: 0000000000000004 R11: ffff96994b6f0059 R12: ffffffff92e=
33a07
[ 1572.248179] R13: 0000000000000000 R14: 0000000000ffff0a R15: 00000000000=
00000
[ 1572.248183] FS:  00007ef911609740(0000) GS:ffff9699ad980000(0000) knlGS:=
0000000000000000
[ 1572.248186] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1572.248188] CR2: 00007d5d665cfae0 CR3: 00000007cb6ec002 CR4: 00000000003=
606e0
[ 1572.248192] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000000000=
00000
[ 1572.248199] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 00000000000=
00400
[ 1572.248201] Call Trace:
[ 1572.248203]  vsnprintf+0x3e1/0x5b0
[ 1572.248207]  scnprintf+0x4d/0x90
[ 1572.248212]  msg_print_ext_header.constprop.0+0x7f/0xa0
[ 1572.248217]  ? _cond_resched+0x10/0x20
[ 1572.248219]  ? mutex_lock_interruptible+0x9/0x30
[ 1572.248225]  devkmsg_read+0x17f/0x270
[ 1572.248227]  vfs_read+0x98/0x150
[ 1572.248232]  ksys_read+0x5d/0xe0
[ 1572.248234]  do_syscall_64+0x50/0x170
[ 1572.248241]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[ 1572.248245] RIP: 0033:0x7ef911723415
[ 1572.248251] Code: fe ff ff 55 48 89 e5 48 8d 3d 4f bf 0a 00 e8 22 25 02 =
00 66 90 f3 0f 1e fa 64 8b 04 25 18 00 00 00 85 c0 75 10 c5 fc 77 0f 05 <48=
> 3d 00 f0 ff ff 77 53 c3 66 90 55 48 89 e5 48 83 ec 20 48 89 55
[ 1572.248255] RSP: 002b:00007ffcf81cb498 EFLAGS: 00000246 ORIG_RAX: 000000=
0000000000
[ 1572.248262] RAX: ffffffffffffffda RBX: 00005571c56a2440 RCX: 00007ef9117=
23415
[ 1572.248267] RDX: 0000000000001fff RSI: 00005571c56a2440 RDI: 00000000000=
00003
[ 1572.248271] RBP: 00005571c569e7fa R08: 000000000000000a R09: 00000000000=
00000
[ 1572.248273] R10: 00007ffcf81cb2cc R11: 0000000000000246 R12: 00000000000=
0001c
[ 1572.248278] R13: 00005571c569d377 R14: 00005571c56a2440 R15: 00005571c56=
a2456
[ 1572.248285] NMI backtrace for cpu 9
[ 1572.248288] CPU: 9 PID: 400 Comm: systemd-journal Kdump: loaded Tainted:=
 G     U            5.2.1-g527a3db363a3 #68
[ 1572.248292] Hardware name: System manufacturer System Product Name/PRIME=
 Z370-A, BIOS 1002 07/02/2018
[ 1572.248300] RIP: 0010:queued_spin_lock_slowpath+0x17b/0x1d0
[ 1572.248307] Code: e5 83 e0 03 48 c1 e0 04 48 05 c0 d7 05 00 c1 ee 12 ff =
ce 48 63 f6 48 03 04 f5 a0 15 ed 92 48 89 10 8b 42 08 85 c0 75 09 f3 90 <8b=
> 42 08 85 c0 74 f7 48 8b 02 48 85 c0 74 8c 48 89 c6 0f 0d 08 eb
[ 1572.248310] RSP: 0018:ffffbd38c34cbd50 EFLAGS: 00000046
[ 1572.248322] RAX: 0000000000000000 RBX: ffff9699a86f4370 RCX: 00000000002=
80000
[ 1572.248325] RDX: ffff9699adadd7c0 RSI: 0000000000000005 RDI: ffffffff935=
a02ac
[ 1572.248333] RBP: ffffbd38c34cbda8 R08: 0000000000000009 R09: 00000000000=
00000
[ 1572.248336] R10: 0000000000000000 R11: 0000000000000000 R12: ffff9699a49=
80000
[ 1572.248342] R13: 00007ffddcf63680 R14: ffffbd38c34cbe00 R15: ffff9699a86=
f4318
[ 1572.248346] FS:  00007c88db99c840(0000) GS:ffff9699ada80000(0000) knlGS:=
0000000000000000
[ 1572.248351] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1572.248359] CR2: 00007c88cf9be3c0 CR3: 00000008286d4001 CR4: 00000000003=
606e0
[ 1572.248364] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000000000=
00000
[ 1572.248369] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 00000000000=
00400
[ 1572.248375] Call Trace:
[ 1572.248382]  devkmsg_poll+0x3c/0x80
[ 1572.248388]  ep_item_poll.isra.0+0x3a/0xb0
[ 1572.248391]  ep_send_events_proc+0xec/0x230
[ 1572.248394]  ? ep_read_events_proc+0xe0/0xe0
[ 1572.248403]  ep_scan_ready_list.constprop.0+0x9b/0x1f0
[ 1572.248408]  ep_poll+0x87/0x450
[ 1572.248412]  do_epoll_wait+0xab/0xd0
[ 1572.248419]  __x64_sys_epoll_wait+0x15/0x20
[ 1572.248424]  do_syscall_64+0x50/0x170
[ 1572.248428]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[ 1572.248435] RIP: 0033:0x7c88dd1b20b5
[ 1572.248439] Code: 89 55 f8 48 89 75 f0 89 7d fc e8 e6 18 f7 ff 41 89 c0 =
44 8b 55 ec 8b 55 f8 48 8b 75 f0 8b 7d fc b8 e8 00 00 00 c5 fc 77 0f 05 <48=
> 3d 00 f0 ff ff 77 25 89 45 fc 44 89 c7 e8 18 19 f7 ff 8b 45 fc
[ 1572.248444] RSP: 002b:00007ffddcf63650 EFLAGS: 00000293 ORIG_RAX: 000000=
00000000e8
[ 1572.248458] RAX: ffffffffffffffda RBX: 00006265e2ccc3d0 RCX: 00007c88dd1=
b20b5
[ 1572.248461] RDX: 0000000000000020 RSI: 00007ffddcf63680 RDI: 00000000000=
00007
[ 1572.248465] RBP: 00007ffddcf63670 R08: 0000000000000000 R09: 00000000000=
00020
[ 1572.248471] R10: 00000000dd84bf82 R11: 0000000000000293 R12: 00007ffddcf=
63680
[ 1572.248478] R13: 000007494e8c1088 R14: 0000000000000000 R15: 00000000000=
00001
[ 1572.248486] NMI backtrace for cpu 11
[ 1572.248490] CPU: 11 PID: 20040 Comm: dmesg Kdump: loaded Tainted: G     =
U            5.2.1-g527a3db363a3 #68
[ 1572.248493] Hardware name: System manufacturer System Product Name/PRIME=
 Z370-A, BIOS 1002 07/02/2018
[ 1572.248502] RIP: 0033:0x7717bcea7cbb
[ 1572.248509] Code: 48 83 ec 18 49 89 f5 4c 0f af ea 4d 85 ed 0f 84 f0 00 =
00 00 49 89 ff 49 89 f6 49 89 d4 48 89 cb 8b 11 81 e2 00 80 00 00 75 44 <64=
> 48 8b 04 25 10 00 00 00 48 89 45 c8 48 8b b9 88 00 00 00 48 39
[ 1572.248518] RSP: 002b:00007fff79d5f6a0 EFLAGS: 00000246
[ 1572.248531] RAX: 0000000000000001 RBX: 00007717bd00b500 RCX: 00007717bd0=
0b500
[ 1572.248534] RDX: 0000000000000000 RSI: 0000000000000001 RDI: 000062592ce=
a0487
[ 1572.248538] RBP: 00007fff79d5f6e0 R08: 000062592cea0488 R09: 00000000000=
00000
[ 1572.248544] R10: 00007fff79d5f71c R11: 000062592cea0487 R12: 00000000000=
00001
[ 1572.248552] R13: 0000000000000001 R14: 0000000000000001 R15: 000062592ce=
a0487
[ 1572.248557] FS:  00007717bce1c740 GS:  0000000000000000
[ 1572.248563] NMI backtrace for cpu 10
[ 1572.248567] CPU: 10 PID: 1260 Comm: grep Kdump: loaded Tainted: G     U =
           5.2.1-g527a3db363a3 #68
[ 1572.248570] Hardware name: System manufacturer System Product Name/PRIME=
 Z370-A, BIOS 1002 07/02/2018
[ 1572.248577] RIP: 0010:ZSTD_decompressSequences+0x6be/0xb80
[ 1572.248586] Code: 8b 39 48 89 7c 24 68 84 c0 74 13 f3 0f bd c0 8d 48 e9 =
89 ce 49 83 fc ea 0f 86 2c fb ff ff 49 c7 c5 f2 ff ff ff e9 21 fa ff ff <89=
> d0 44 8b 34 85 00 f0 c7 92 44 8b 54 24 70 c4 e2 a9 f7 44 24 68
[ 1572.248589] RSP: 0018:ffffbd38c5a37838 EFLAGS: 00000202
[ 1572.248599] RAX: 0000000000000008 RBX: 0000000000000000 RCX: ffffbd38c60=
22048
[ 1572.248606] RDX: 0000000000000008 RSI: ffffbd38c6022d30 RDI: ffffbd38c60=
228a4
[ 1572.248611] RBP: 0000000000000000 R08: 0000000000000099 R09: 00000000000=
00001
[ 1572.248617] R10: 0000000000000007 R11: 0000000000000006 R12: 00000000000=
00001
[ 1572.248622] R13: 0000000000000006 R14: fffffffffffffffe R15: ffff9699281=
46263
[ 1572.248628] FS:  000077c96a004740(0000) GS:ffff9699adb00000(0000) knlGS:=
0000000000000000
[ 1572.248635] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1572.248642] CR2: 00005a61235ce000 CR3: 00000007cba90004 CR4: 00000000003=
606e0
[ 1572.248648] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000000000=
00000
[ 1572.248659] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 00000000000=
00400
[ 1572.248666] Call Trace:
[ 1572.248672]  ZSTD_decompressMultiFrame+0x329/0x370
[ 1572.248677]  ZSTD_decompressDCtx+0xc/0x10
[ 1572.248680]  zstd_decompress+0x1f/0x40
[ 1572.248685]  zcomp_decompress+0x2e/0x50
[ 1572.248690]  zram_bvec_rw.isra.0+0x5e2/0x6a0
[ 1572.248699]  zram_rw_page+0x7f/0xe0
[ 1572.248705]  bdev_read_page+0x6e/0xa0
[ 1572.248710]  swap_readpage+0xaf/0x1f0
[ 1572.248713]  do_swap_page+0x72e/0x7e0
[ 1572.248718]  __handle_mm_fault+0xa77/0x1310
[ 1572.248722]  handle_mm_fault+0xa9/0x1d0
[ 1572.248725]  __do_page_fault+0x237/0x480
[ 1572.248734]  do_page_fault+0x1d/0x67
[ 1572.248741]  ? reweight_entity+0x15a/0x1a0
[ 1572.248744]  page_fault+0x1e/0x30
[ 1572.248749] RIP: 0010:copy_user_generic_unrolled+0x89/0xc0
[ 1572.248758] Code: 38 4c 89 47 20 4c 89 4f 28 4c 89 57 30 4c 89 5f 38 48 =
8d 76 40 48 8d 7f 40 ff c9 75 b6 89 d1 83 e2 07 c1 e9 03 74 12 4c 8b 06 <4c=
> 89 07 48 8d 76 08 48 8d 7f 08 ff c9 75 ee 21 d2 74 10 89 d1 8a
[ 1572.248766] RSP: 0018:ffffbd38c5a37d90 EFLAGS: 00050203
[ 1572.248780] RAX: 0000000000000016 RBX: ffff96972af7c000 RCX: 00000000000=
00001
[ 1572.248783] RDX: 0000000000000006 RSI: ffff96972af7c008 RDI: 00005a61235=
cdffe
[ 1572.248789] RBP: 0000000000000016 R08: 363478302b6b6361 R09: 00000000000=
00000
[ 1572.248794] R10: 0000000000000003 R11: ffff9699a2261e00 R12: 00000000000=
00016
[ 1572.248800] R13: ffffbd38c5a37e50 R14: 0000000000000000 R15: 00000000000=
00000
[ 1572.248803]  copyout+0x28/0x30
[ 1572.248806]  copy_page_to_iter+0xbc/0x2f0
[ 1572.248809]  pipe_read+0xad/0x2c0
[ 1572.248814]  new_sync_read+0x10f/0x1a0
[ 1572.248821]  vfs_read+0x98/0x150
[ 1572.248826]  ksys_read+0x5d/0xe0
[ 1572.248832]  do_syscall_64+0x50/0x170
[ 1572.248837]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[ 1572.248840] RIP: 0033:0x77c96a140415
[ 1572.248849] Code: fe ff ff 55 48 89 e5 48 8d 3d 4f bf 0a 00 e8 22 25 02 =
00 66 90 f3 0f 1e fa 64 8b 04 25 18 00 00 00 85 c0 75 10 c5 fc 77 0f 05 <48=
> 3d 00 f0 ff ff 77 53 c3 66 90 55 48 89 e5 48 83 ec 20 48 89 55
[ 1572.248855] RSP: 002b:00007fff87565c78 EFLAGS: 00000246 ORIG_RAX: 000000=
0000000000
[ 1572.248869] RAX: ffffffffffffffda RBX: 000000000000e000 RCX: 000077c96a1=
40415
[ 1572.248877] RDX: 000000000000e000 RSI: 00005a61235cdff6 RDI: 00000000000=
00000
[ 1572.248886] RBP: 000000000000e000 R08: 0000000000000000 R09: 00000000000=
19008
[ 1572.248890] R10: 00005a61235b85a0 R11: 0000000000000246 R12: 00005a61235=
cdff6
[ 1572.248893] R13: 0000000000000000 R14: 00005a61235c3100 R15: 00000000000=
00000

```

Ignore the dmesg process, I've had two programs that keep querrying it and =
I've put process to 800Mhz max, to avoid high power usage during this.

the swap is in zram

/etc/fstab shows:
/dev/zram0 none swap defaults,discard 0 0

$ zramctl
NAME       ALGORITHM DISKSIZE   DATA  COMPR  TOTAL STREAMS MOUNTPOINT
/dev/zram2 zstd           64G   4.7M 136.3K   248K      12 /var/tmp
/dev/zram1 zstd           64G 320.3M  84.1M    88M      12 /tmp
/dev/zram0 zstd           64G   1.6G  75.6M 230.6M      12 [SWAP]

I can't find a reliable way to reproduce it, it seems to happen sort of ran=
dom...


