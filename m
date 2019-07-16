Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6848FC76192
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 19:15:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 80D7F20693
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 19:15:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=protonmail.com header.i=@protonmail.com header.b="YikAa7T7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 80D7F20693
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=protonmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2127A6B0005; Tue, 16 Jul 2019 15:15:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 19CC86B0006; Tue, 16 Jul 2019 15:15:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 03CB08E0001; Tue, 16 Jul 2019 15:15:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 88D376B0005
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 15:15:17 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k22so16580313ede.0
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 12:15:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:dkim-signature:to:from:cc:reply-to:subject
         :message-id:in-reply-to:references:feedback-id:mime-version;
        bh=+jBMdPSZ+HdSzx1cEwnrTlEP5RRuP78Tw12+AxKdxAs=;
        b=hj4NnX921sPYOuunPm8ubmhJ8IxJ/mvTN2e0kbaNgIL5j82p9Q4REj4dNe27PS7xWD
         3FOxlsQOxG4d9eKBJ8HyiYhunWVEXIitrrdGaeG7l0i6Bt5yQ3P5YhG+aLvnv5ozYFn4
         LtKmJlkcjt2pAgZp9GaOCDF2Uw/4VUG8ry1B8VAmdh23aZDGSKc3ce4eHxI7mQKVcT7y
         WEIPc6I4dVIUHDgg0XwjMIMAzoWCA3IhXuEm2R+wknWSZ8WdmyLvNV+Vw7YcN2a8/ha2
         ixjNwejhApXNCEHbZ3JyQ7voJhVMezYn89lDKmc3zIDm8BVQHuboPIfwlqoAybbhNhm0
         TbnA==
X-Gm-Message-State: APjAAAWiiC1ETiBi38YemoxR922zzmZbq0R9uMc08BZSDfRn5Idd69Ky
	aHGoAX2tt/kaIc1vWaQIxrEzuiTCKNshMqBJ02JiLpRmpn913qIQzGJ5NxRmOBFoEspp0wbVRmA
	Hw78DSimBwEjrUYdL6L5njRW93XlevwzkINruUMkY7pWbqjh2HyZ2ahw7ZDqMFlEfSQ==
X-Received: by 2002:a17:906:4a89:: with SMTP id x9mr1403052eju.141.1563304516851;
        Tue, 16 Jul 2019 12:15:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz3Ya9q1FSAZujgHbhUQOJ4yb+HkcU9VKHx6JQYcKiM+6hAbJonHWNvfs2FRPY5TaPC0b8F
X-Received: by 2002:a17:906:4a89:: with SMTP id x9mr1402896eju.141.1563304514936;
        Tue, 16 Jul 2019 12:15:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563304514; cv=none;
        d=google.com; s=arc-20160816;
        b=wGRIMsY0gl8FNgllNVWOBiGsAOAVnEFPsSuOsoRHOoSoC7q+hzuTsqyJILVj1pWRcM
         WCVJ5gxXGuwN3Mmaq8mUZsa5aPzUR8V9t00zQ1/u2IghQo/RoL+wtB/dQmqYaLfNoFWy
         6glRO3Op0UD+eZGJicY5TfvKcNW3PlyjUu7MJcNta0pjntH4DbUgAiAoAD63HkBPYyMf
         KQ8bqcYCeGjyT4/zIx+ePonxhY507/8fPk7C2P0+nCUrdd4tnkomNnHXW0d9OPdJFe2Y
         O+fYmTu8W+lZhrxvthHCPlIa8oomNoRuaHK2NjWhq/a8vDHqD5KEGHEaHWwvZTCoYXvM
         1sTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:feedback-id:references:in-reply-to:message-id:subject
         :reply-to:cc:from:to:dkim-signature:date;
        bh=+jBMdPSZ+HdSzx1cEwnrTlEP5RRuP78Tw12+AxKdxAs=;
        b=IL8MHaIy5ZY87goSs3sUsR4lngoVmT7ZjvPq98dk/cUd9NGgH/KJB7K/JehYx5d1IE
         rpmXJX5rQ7A4ejYgnOsc3lZBkfgTVy9QKP1sYp1O7OGzSK261ClT1oNr2qAYSqb9vAI6
         htsyMxAi/8oKq9Pkmb3QMdbriDUDpUWFQYzO6LzRovfiqVI0NHe3mLCHf1YclMWmLo84
         fUVT5Yd88x/rnDf1vEhp/uuiFgFOgVv6YWiW5/xC57RJYRYZX6x4Yp8J5O/z15qjpOHs
         tlKEcxGZVfEb4h9vdNTucP7zjjoSLVHNnJS7vhGXYDCxFPKl+Fxauqhzg3j2U8NLHDIt
         /TEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@protonmail.com header.s=default header.b=YikAa7T7;
       spf=pass (google.com: domain of howaboutsynergy@protonmail.com designates 185.70.40.136 as permitted sender) smtp.mailfrom=howaboutsynergy@protonmail.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=protonmail.com
Received: from mail-40136.protonmail.ch (mail-40136.protonmail.ch. [185.70.40.136])
        by mx.google.com with ESMTPS id b8si10835869ejd.0.2019.07.16.12.15.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 12:15:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of howaboutsynergy@protonmail.com designates 185.70.40.136 as permitted sender) client-ip=185.70.40.136;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@protonmail.com header.s=default header.b=YikAa7T7;
       spf=pass (google.com: domain of howaboutsynergy@protonmail.com designates 185.70.40.136 as permitted sender) smtp.mailfrom=howaboutsynergy@protonmail.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=protonmail.com
Date: Tue, 16 Jul 2019 19:15:08 +0000
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=protonmail.com;
	s=default; t=1563304513;
	bh=+jBMdPSZ+HdSzx1cEwnrTlEP5RRuP78Tw12+AxKdxAs=;
	h=Date:To:From:Cc:Reply-To:Subject:In-Reply-To:References:
	 Feedback-ID:From;
	b=YikAa7T7QgGxZumWrJE6ROWIVOSBWQhWmdCkLxbD1Q5lNGcNDipcuOhpBG9FtckTm
	 3irunFFCVow2gNRqd039BT7tAedow5SEWBecjdPdDkQ+4cPvLSOCs3x3+2boptiJ12
	 dpL/PoN6SxbsW9XuEW1UEpQaBXSDqljA3qgtehco=
To: Mel Gorman <mgorman@techsingularity.net>
From: howaboutsynergy@protonmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Reply-To: howaboutsynergy@protonmail.com
Subject: Re: [Bug 204165] New: 100% CPU usage in compact_zone_order
Message-ID: <xZGQeie9gbbIEm7ZciNh3PrdV8kTu-SE7KtUYV3cloMCUEdzB7taS5BcTzSUSaThu5_ftcRjr3sYcQB1c9dVPX3i1kQ2eP-xjKvFIpT7wZs=@protonmail.com>
In-Reply-To: <20190716071121.GA24383@techsingularity.net>
References: <bug-204165-27@https.bugzilla.kernel.org/>
 <20190715142524.e0df173a9d7f81a384abf28f@linux-foundation.org>
 <pLm2kTLklcV9AmHLFjB1oi04nZf9UTLlvnvQZoq44_ouTn3LhqcDD8Vi7xjr9qaTbrHfY5rKdwD6yVr43YCycpzm7MDLcbTcrYmGA4O0weU=@protonmail.com>
 <GX2mE2MIJ0H5o4mejfgRsT-Ng_bb19MXio4XzPWFjRzVb4cNpvDC1JXNqtX3k44MpbKg4IEg3amOh5V2Qt0AfMev1FZJoAWNh_CdfYIqxJ0=@protonmail.com>
 <WGYVD8PH-EVhj8iJluAiR5TqOinKtx6BbqdNr2RjFO6kOM_FP2UaLy4-1mXhlpt50wEWAfLFyYTa4p6Ie1xBOuCdguPmrLOW1wJEzxDhcuU=@protonmail.com>
 <EDGpMqBME0-wqL8JuVQeCbXEy1lZkvqS0XMvMj6Z_OFhzyK5J6qXWAgNUCxrcgVLmZVlqMH-eRJrqOCxb1pct39mDyFMcWhIw1ZUTAVXr2o=@protonmail.com>
 <20190716071121.GA24383@techsingularity.net>
Feedback-ID: cNV1IIhYZ3vPN2m1zihrGlihbXC6JOgZ5ekTcEurWYhfLPyLhpq0qxICavacolSJ7w0W_XBloqfdO_txKTblOQ==:Ext:ProtonMail
MIME-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature"; micalg=pgp-sha256; boundary="---------------------ea00e6b2d78cb631f664528351279604"; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
-----------------------ea00e6b2d78cb631f664528351279604
Content-Type: multipart/mixed;boundary=---------------------8da43c4692aba7a8f346db54b897d0d0

-----------------------8da43c4692aba7a8f346db54b897d0d0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;charset=utf-8

On Tuesday, July 16, 2019 12:03 PM, Mel Gorman <mgorman@techsingularity.ne=
t> wrote:
> I tried reproducing this but after 300 attempts with various parameters
> and adding other workloads in the background, I was unable to reproduce
> the problem.
> =



The third time I ran this command `$ time stress -m 220 --vm-bytes 1000000=
0000 --timeout 10`, got 10+ hung:

  PID  %CPU COMMAND                                                       =
                     PR  NI    VIRT    RES S USER     =


 3785  94.5 stress                                                        =
                     20   0 9769416      4 R user     =


 3777  87.3 stress                                                        =
                     20   0 9769416      4 R user     =


 3923  85.5 stress                                                        =
                     20   0 9769416      4 R user     =


 3937  85.5 stress                                                        =
                     20   0 9769416      4 R user     =


 3943  81.8 stress                                                        =
                     20   0 9769416      4 R user     =


 3885  80.0 stress                                                        =
                     20   0 9769416      4 R user     =


 3970  80.0 stress                                                        =
                     20   0 9769416      4 R user     =


 3902  76.4 stress                                                        =
                     20   0 9769416      4 R user     =


 3954  72.7 stress                                                        =
                     20   0 9769416      4 R user     =


 3868  70.9 stress                                                        =
                     20   0 9769416      4 R user     =


 3893  69.1 stress                                                        =
                     20   0 9769416      4 R user     =


 3786  65.5 stress                                                        =
                     20   0 9769416      4 R user     =


 3783  60.0 stress                                                        =
                     20   0 9769416      4 R user     =


 3848  58.2 stress                                                        =
                     20   0 9769416      4 R user     =


 3863  58.2 stress                                                        =
                     20   0 9769416      4 R user     =



looked like this:
```
TERM=3D'xterm-256color'
53.48 573.49
-----------
user@i87k 2019/07/16 20:36:47 -bash5.0.7 t:5 j:0 d:3 pp:1140 p:1623 ut53
!41866 1 0  5.2.1-g527a3db363a3 #71 SMP Tue Jul 16 19:41:12 CEST 2019
/home/user =


$ time stress -m 220 --vm-bytes 10000000000 --timeout 10
stress: info: [1744] dispatching hogs: 0 cpu, 0 io, 220 vm, 0 hdd
stress: info: [1744] successful run completed in 19s

real	0m19.036s
user	0m0.794s
sys	2m59.583s
-----------
user@i87k 2019/07/16 20:37:12 -bash5.0.7 t:5 j:0 d:3 pp:1140 p:1623 ut79
!41867 2 0  5.2.1-g527a3db363a3 #71 SMP Tue Jul 16 19:41:12 CEST 2019
/home/user =


$ time stress -m 220 --vm-bytes 10000000000 --timeout 10
stress: info: [3520] dispatching hogs: 0 cpu, 0 io, 220 vm, 0 hdd
stress: info: [3520] successful run completed in 18s

real	0m18.657s
user	0m0.901s
sys	2m59.700s
-----------
user@i87k 2019/07/16 20:42:28 -bash5.0.7 t:5 j:0 d:3 pp:1140 p:1623 ut394
!41868 3 0  5.2.1-g527a3db363a3 #71 SMP Tue Jul 16 19:41:12 CEST 2019
/home/user =


$ time stress -m 220 --vm-bytes 10000000000 --timeout 10
stress: info: [3771] dispatching hogs: 0 cpu, 0 io, 220 vm, 0 hdd


```
(sure I waited a few minutes until I ran the 3rd one, I don't remember wha=
t trivial things I've been doing during the time - like making sure I got =
the right trace command(s))

I'm pretty sure you need swap in (ext4)zram for this to trigger (faster?),=
 judging by the fuller stacktrace that I showed in prev. email(s) gotten v=
ia 'crash'-s `bt -Tsx pidhere`

On Tuesday, July 16, 2019 9:11 AM, Mel Gorman <mgorman@techsingularity.net=
> wrote:
> High CPU usage in this path is not something I've observed recently.
> When it happens and CPU usage is high, can you run the following command=
s
> please?
> =


> trace-cmd record -e compaction:* sleep 10
> trace-cmd report > trace.log
> =


> and send me the resulting trace.log please?

Ok, getting trace.log as requested:

```
$ sudo trace-cmd record -e compaction:* sleep 10
[sudo] password for user: =


CPU 0: 12430 events lost
CPU 1: 83959 events lost
CPU 4: 13447 events lost
CPU 6: 2825 events lost
CPU 8: 791 events lost
CPU 11: 8475 events lost
CPU0 data recorded at offset=3D0x5bc000
    114487296 bytes in size
CPU1 data recorded at offset=3D0x72eb000
    106885120 bytes in size
CPU2 data recorded at offset=3D0xd8da000
    125046784 bytes in size
CPU3 data recorded at offset=3D0x1501b000
    111022080 bytes in size
CPU4 data recorded at offset=3D0x1b9fc000
    120532992 bytes in size
CPU5 data recorded at offset=3D0x22cef000
    115990528 bytes in size
CPU6 data recorded at offset=3D0x29b8d000
    116109312 bytes in size
CPU7 data recorded at offset=3D0x30a48000
    73822208 bytes in size
CPU8 data recorded at offset=3D0x350af000
    98643968 bytes in size
CPU9 data recorded at offset=3D0x3aec2000
    96514048 bytes in size
CPU10 data recorded at offset=3D0x40acd000
    113967104 bytes in size
CPU11 data recorded at offset=3D0x4777d000
    127184896 bytes in size

trace.dat is 1.3G
-rw-r--r--  1 root root 1326219264 16.07.2019 20:45 trace.dat

$ LD_PRELOAD=3D/usr/lib/trace-cmd/python/ctracecmd.so trace-cmd report > t=
race.log
trace-cmd: symbol lookup error: /usr/lib/trace-cmd/python/ctracecmd.so: un=
defined symbol: PyExc_SystemError

$ trace-cmd report > trace.log
  could not load plugin '/usr/lib/trace-cmd/plugins/plugin_python.so'
/usr/lib/trace-cmd/plugins/plugin_python.so: undefined symbol: PyString_Fr=
omString

I guess we could ignore that?


trace.log is like 4.3G
-rw-r--r--  1 user user 4370520245 16.07.2019 20:50 trace.log


On Tuesday, July 16, 2019 12:03 PM, Mel Gorman <mgorman@techsingularity.ne=
t> wrote:
> I tried reproducing this but after 300 attempts with various parameters
> and adding other workloads in the background, I was unable to reproduce
> the problem.
> =




As a reminder, here's how sysrq+l stacktraces look like (for two of the st=
ress pids):
```
[ 1294.913508] NMI backtrace for cpu 5
[ 1294.913517] CPU: 5 PID: 3848 Comm: stress Kdump: loaded Tainted: G     =
U            5.2.1-g527a3db363a3 #71
[ 1294.913522] Hardware name: System manufacturer System Product Name/PRIM=
E Z370-A, BIOS 2201 05/27/2019
[ 1294.913526] RIP: 0010:ftrace_likely_update+0x1a/0x200
[ 1294.913533] Code: 0b eb bb 66 66 2e 0f 1f 84 00 00 00 00 00 66 90 41 57=
 41 56 41 55 41 54 55 53 48 83 ec 20 48 89 fb 41 89 d4 9c 41 5f 0f 01 ca <=
85> c9 0f 84 8b 00 00 00 48 ff 47 28 8b 15 34 72 47 01 85 d2 75 16
[ 1294.913537] RSP: 0000:ffffa3cd4c7ef848 EFLAGS: 00000286
[ 1294.913552] RAX: 0000000000000000 RBX: ffffffff97546180 RCX: 0000000000=
000000
[ 1294.913557] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffffffff97=
546180
[ 1294.913562] RBP: 000000000017cc6f R08: 0000000000000000 R09: 0000000000=
000000
[ 1294.913567] R10: 0000000000000001 R11: 0000000000000004 R12: 0000000000=
000000
[ 1294.913571] R13: ffff93560dfdc000 R14: 000000000012f44c R15: 0000000000=
000286
[ 1294.913577] FS:  000072d6afdff740(0000) GS:ffff9355ed880000(0000) knlGS=
:0000000000000000
[ 1294.913582] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1294.913590] CR2: 000070fbe8abdc88 CR3: 0000000827a46004 CR4: 0000000000=
3606e0
[ 1294.913595] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000=
000000
[ 1294.913600] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000=
000400
[ 1294.913605] Call Trace:
[ 1294.913609]  _cond_resched+0x2d/0x50
[ 1294.913613]  isolate_migratepages_block+0xf8/0xe40
[ 1294.913618]  compact_zone+0x4f9/0xe10
[ 1294.913626]  compact_zone_order+0xe3/0x120
[ 1294.913630]  try_to_compact_pages+0xde/0x3b0
[ 1294.913635]  __alloc_pages_direct_compact+0x8c/0x170
[ 1294.913639]  __alloc_pages_slowpath+0x65c/0x1290
[ 1294.913644]  __alloc_pages_nodemask+0x4cf/0x530
[ 1294.913648]  do_huge_pmd_anonymous_page+0x17c/0x780
[ 1294.913653]  __handle_mm_fault+0xeee/0x17d0
[ 1294.913661]  handle_mm_fault+0x17b/0x330
[ 1294.913666]  __do_page_fault+0x34e/0x800
[ 1294.913671]  do_page_fault+0x57/0x1f9
[ 1294.913675]  ? page_fault+0x8/0x30
[ 1294.913680]  page_fault+0x1e/0x30
[ 1294.913684] RIP: 0033:0x5a46e611ac10
[ 1294.913690] Code: c0 0f 84 53 02 00 00 8b 54 24 0c 31 c0 85 d2 0f 94 c0=
 89 04 24 41 83 fd 02 0f 8f fa 00 00 00 31 c0 4d 85 ff 7e 10 0f 1f 40 00 <=
c6> 04 03 5a 4c 01 f0 49 39 c7 7f f4 4d 85 e4 0f 84 f4 01 00 00 7e
[ 1294.913695] RSP: 002b:00007fffa51f0f60 EFLAGS: 00010206
[ 1294.913705] RAX: 00000000098c0000 RBX: 000072d45bd40010 RCX: 000072d6af=
f243db
[ 1294.913710] RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 000072d45b=
d40000
[ 1294.913715] RBP: 00005a46e611ba54 R08: 000072d45bd40010 R09: 0000000000=
000000
[ 1294.913720] R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffff=
ffffff
[ 1294.913724] R13: 0000000000000002 R14: 0000000000001000 R15: 0000000254=
0be400
[ 1294.913730] NMI backtrace for cpu 11
[ 1294.913739] CPU: 11 PID: 3902 Comm: stress Kdump: loaded Tainted: G    =
 U            5.2.1-g527a3db363a3 #71
[ 1294.913744] Hardware name: System manufacturer System Product Name/PRIM=
E Z370-A, BIOS 2201 05/27/2019
[ 1294.913748] RIP: 0010:isolate_migratepages_block+0x97b/0xe40
[ 1294.913754] Code: c6 43 79 01 4c 8b 74 24 08 4d 39 fe b9 00 00 00 00 ba=
 00 00 00 00 40 0f 92 c6 40 0f b6 f6 48 c7 c7 90 ac 56 97 e8 05 fe f5 ff <=
4d> 39 fe 0f 82 7a f9 ff ff 4c 39 7c 24 08 0f 84 6f f9 ff ff 0f 1f
[ 1294.913758] RSP: 0000:ffffa3cd4c99f8b0 EFLAGS: 00000286
[ 1294.913768] RAX: 0000000000000000 RBX: ffffa3cd4c99fa50 RCX: 0000000000=
000000
[ 1294.913777] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffffffff97=
56ac90
[ 1294.913781] RBP: 0000000000000001 R08: 0000000000000000 R09: 0000000000=
000000
[ 1294.913786] R10: 0000000000000001 R11: 0000000000000004 R12: 0000000000=
000000
[ 1294.913790] R13: 0000000000000000 R14: 000000000070ee00 R15: 0000000000=
70ece0
[ 1294.913795] FS:  000072d6afdff740(0000) GS:ffff9355edb80000(0000) knlGS=
:0000000000000000
[ 1294.913799] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1294.913804] CR2: 00007d99c6200000 CR3: 00000007ecb1a003 CR4: 0000000000=
3606e0
[ 1294.913813] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000=
000000
[ 1294.913817] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000=
000400
[ 1294.913822] Call Trace:
[ 1294.913826]  compact_zone+0x4f9/0xe10
[ 1294.913830]  compact_zone_order+0xe3/0x120
[ 1294.913835]  try_to_compact_pages+0xde/0x3b0
[ 1294.913839]  __alloc_pages_direct_compact+0x8c/0x170
[ 1294.913848]  __alloc_pages_slowpath+0x65c/0x1290
[ 1294.913852]  __alloc_pages_nodemask+0x4cf/0x530
[ 1294.913856]  do_huge_pmd_anonymous_page+0x17c/0x780
[ 1294.913861]  __handle_mm_fault+0xeee/0x17d0
[ 1294.913865]  handle_mm_fault+0x17b/0x330
[ 1294.913869]  __do_page_fault+0x34e/0x800
[ 1294.913874]  do_page_fault+0x57/0x1f9
[ 1294.913882]  ? page_fault+0x8/0x30
[ 1294.913886]  page_fault+0x1e/0x30
[ 1294.913891] RIP: 0033:0x5a46e611ac10
[ 1294.913896] Code: c0 0f 84 53 02 00 00 8b 54 24 0c 31 c0 85 d2 0f 94 c0=
 89 04 24 41 83 fd 02 0f 8f fa 00 00 00 31 c0 4d 85 ff 7e 10 0f 1f 40 00 <=
c6> 04 03 5a 4c 01 f0 49 39 c7 7f f4 4d 85 e4 0f 84 f4 01 00 00 7e
[ 1294.913901] RSP: 002b:00007fffa51f0f60 EFLAGS: 00010206
[ 1294.913907] RAX: 000000000d0c0000 RBX: 000072d45bd40010 RCX: 000072d6af=
f243db
[ 1294.913916] RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 000072d45b=
d40000
[ 1294.913921] RBP: 00005a46e611ba54 R08: 000072d45bd40010 R09: 0000000000=
000000
[ 1294.913925] R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffff=
ffffff
[ 1294.913929] R13: 0000000000000002 R14: 0000000000001000 R15: 0000000254=
0be400
```

and here's how they look via crash:
```
$ sudo crash "/usr/lib/modules/$(uname -r)/build/vmlinux"
[sudo] password for user: =



crash 7.2.6
Copyright (C) 2002-2019  Red Hat, Inc.
Copyright (C) 2004, 2005, 2006, 2010  IBM Corporation
Copyright (C) 1999-2006  Hewlett-Packard Co
Copyright (C) 2005, 2006, 2011, 2012  Fujitsu Limited
Copyright (C) 2006, 2007  VA Linux Systems Japan K.K.
Copyright (C) 2005, 2011  NEC Corporation
Copyright (C) 1999, 2002, 2007  Silicon Graphics, Inc.
Copyright (C) 1999, 2000, 2001, 2002  Mission Critical Linux, Inc.
This program is free software, covered by the GNU General Public License,
and you are welcome to change it and/or distribute copies of it under
certain conditions.  Enter "help copying" to see the conditions.
This program has absolutely no warranty.  Enter "help warranty" for detail=
s.
 =


GNU gdb (GDB) 7.6
Copyright (C) 2013 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.ht=
ml>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
and "show warranty" for details.
This GDB was configured as "x86_64-unknown-linux-gnu"...

WARNING: kernel relocated [336MB]: patching 121800 gdb minimal_symbol valu=
es

      KERNEL: /usr/lib/modules/5.2.1-g527a3db363a3/build/vmlinux       =


    DUMPFILE: /proc/kcore
        CPUS: 12
        DATE: Tue Jul 16 20:59:48 2019
      UPTIME: 00:23:54
LOAD AVERAGE: 26.83, 21.74, 16.35
       TASKS: 508
    NODENAME: i87k
     RELEASE: 5.2.1-g527a3db363a3
     VERSION: #71 SMP Tue Jul 16 19:41:12 CEST 2019
     MACHINE: x86_64  (3700 Mhz)
      MEMORY: 31.9 GB
         PID: 6417
     COMMAND: "crash"
        TASK: ffff934f9c9a8000  [THREAD_INFO: ffff934f9c9a8000]
         CPU: 2
       STATE: TASK_RUNNING (ACTIVE)

crash> bt -Tsx 3848
PID: 3848   TASK: ffff934f83373d80  CPU: 5   COMMAND: "stress"
  [ffffa3cd4c7eefb8] get_page_from_freelist+0xaa9 at ffffffff96291799
  [ffffa3cd4c7ef0e8] get_page_from_freelist+0xaa9 at ffffffff96291799
  [ffffa3cd4c7ef108] __alloc_pages_slowpath+0x216 at ffffffff96292cb6
  [ffffa3cd4c7ef130] get_page_from_freelist+0xb76 at ffffffff96291866
  [ffffa3cd4c7ef178] get_page_from_freelist+0xaa9 at ffffffff96291799
  [ffffa3cd4c7ef1a0] trace_hardirqs_on_caller+0x32 at ffffffff961bc4b2
  [ffffa3cd4c7ef2e0] ZSTD_compressSequences_internal+0x8db at ffffffff9660=
a27b
  [ffffa3cd4c7ef388] ZSTD_compressSequences_internal+0x8db at ffffffff9660=
a27b
  [ffffa3cd4c7ef4b0] get_zspage_mapping+0x40 at ffffffff962e2220
  [ffffa3cd4c7ef538] decay_load+0x6a at ffffffff96111d1a
  [ffffa3cd4c7ef5a0] __list_add_valid+0x90 at ffffffff965e3ff0
  [ffffa3cd4c7ef650] check_preempt_wakeup+0x267 at ffffffff960f7097
  [ffffa3cd4c7ef6b8] decay_load+0x6a at ffffffff96111d1a
  [ffffa3cd4c7ef700] trace_hardirqs_on_thunk+0x1a at ffffffff96001b02
  [ffffa3cd4c7ef738] update_load_avg+0xca at ffffffff960f73aa
  [ffffa3cd4c7ef740] update_load_avg+0xca at ffffffff960f73aa
  [ffffa3cd4c7ef7a0] finish_task_switch+0xc9 at ffffffff960e6879
  [ffffa3cd4c7ef7e8] finish_task_switch+0x17f at ffffffff960e692f
  [ffffa3cd4c7ef820] __schedule+0x552 at ffffffff969f4752
  [ffffa3cd4c7ef8a8] isolate_migratepages_block+0x97b at ffffffff9626165b
  [ffffa3cd4c7ef918] isolate_migratepages_block+0xf at ffffffff96260cef
  [ffffa3cd4c7ef978] compact_zone+0x4f9 at ffffffff96263eb9
  [ffffa3cd4c7efa38] compact_zone_order+0xe3 at ffffffff962648b3
  [ffffa3cd4c7efaf0] try_to_compact_pages+0xde at ffffffff9626523e
  [ffffa3cd4c7efb60] __alloc_pages_direct_compact+0x8c at ffffffff9629285c
  [ffffa3cd4c7efbb8] __alloc_pages_slowpath+0x65c at ffffffff962930fc
  [ffffa3cd4c7efce8] __alloc_pages_nodemask+0x4cf at ffffffff962941ff
  [ffffa3cd4c7efd60] do_huge_pmd_anonymous_page+0x17c at ffffffff962c6fcc
  [ffffa3cd4c7efdb0] __handle_mm_fault+0xeee at ffffffff96272c3e
  [ffffa3cd4c7efe78] handle_mm_fault+0x17b at ffffffff9627369b
  [ffffa3cd4c7efeb0] __do_page_fault+0x34e at ffffffff9604f8ee
  [ffffa3cd4c7eff20] do_page_fault+0x57 at ffffffff9604fe27
  [ffffa3cd4c7eff38] page_fault+0x8 at ffffffff96a00e78
  [ffffa3cd4c7eff50] page_fault+0x1e at ffffffff96a00e8e
    RIP: 00005a46e611ac10  RSP: 00007fffa51f0f60  RFLAGS: 00010206
    RAX: 00000000098c0000  RBX: 000072d45bd40010  RCX: 000072d6aff243db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 000072d45bd40000
    RBP: 00005a46e611ba54   R8: 000072d45bd40010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -l 3848
PID: 3848   TASK: ffff934f83373d80  CPU: 11  COMMAND: "stress"
 #0 [ffffa3cd4c7ef7f0] __schedule at ffffffff969f471a
    /home/user/build/1packages/4used/kernel/linux-stable/makepkg_pacman/li=
nux-stable/src/linux-stable/kernel/sched/core.c: 2818
 #1 [ffffa3cd4c7ef830] trace_hardirqs_on_thunk at ffffffff96001b02
    /home/user/build/1packages/4used/kernel/linux-stable/makepkg_pacman/li=
nux-stable/src/linux-stable/arch/x86/entry/thunk_64.S: 42
 #2 [ffffa3cd4c7ef8a8] isolate_migratepages_block at ffffffff9626165b
    /home/user/build/1packages/4used/kernel/linux-stable/makepkg_pacman/li=
nux-stable/src/linux-stable/mm/compaction.c: 1039
 #3 [ffffa3cd4c7ef978] compact_zone at ffffffff96263eb9
    /home/user/build/1packages/4used/kernel/linux-stable/makepkg_pacman/li=
nux-stable/src/linux-stable/mm/compaction.c: 1817
 #4 [ffffa3cd4c7efa38] compact_zone_order at ffffffff962648b3
    /home/user/build/1packages/4used/kernel/linux-stable/makepkg_pacman/li=
nux-stable/src/linux-stable/mm/compaction.c: 2313
 #5 [ffffa3cd4c7efaf0] try_to_compact_pages at ffffffff9626523e
    /home/user/build/1packages/4used/kernel/linux-stable/makepkg_pacman/li=
nux-stable/src/linux-stable/mm/compaction.c: 2362
 #6 [ffffa3cd4c7efb60] __alloc_pages_direct_compact at ffffffff9629285c
    /home/user/build/1packages/4used/kernel/linux-stable/makepkg_pacman/li=
nux-stable/src/linux-stable/mm/page_alloc.c: 3831
 #7 [ffffa3cd4c7efbb8] __alloc_pages_slowpath at ffffffff962930fc
    /home/user/build/1packages/4used/kernel/linux-stable/makepkg_pacman/li=
nux-stable/src/linux-stable/mm/page_alloc.c: 4470
 #8 [ffffa3cd4c7efce8] __alloc_pages_nodemask at ffffffff962941ff
    /home/user/build/1packages/4used/kernel/linux-stable/makepkg_pacman/li=
nux-stable/src/linux-stable/mm/page_alloc.c: 4678
 #9 [ffffa3cd4c7efd60] do_huge_pmd_anonymous_page at ffffffff962c6fcc
    /home/user/build/1packages/4used/kernel/linux-stable/makepkg_pacman/li=
nux-stable/src/linux-stable/./include/linux/topology.h: 73
#10 [ffffa3cd4c7efdb0] __handle_mm_fault at ffffffff96272c3e
    /home/user/build/1packages/4used/kernel/linux-stable/makepkg_pacman/li=
nux-stable/src/linux-stable/mm/memory.c: 3788
#11 [ffffa3cd4c7efe78] handle_mm_fault at ffffffff9627369b
    /home/user/build/1packages/4used/kernel/linux-stable/makepkg_pacman/li=
nux-stable/src/linux-stable/mm/memory.c: 4058
#12 [ffffa3cd4c7efeb0] __do_page_fault at ffffffff9604f8ee
    /home/user/build/1packages/4used/kernel/linux-stable/makepkg_pacman/li=
nux-stable/src/linux-stable/arch/x86/mm/fault.c: 1457
#13 [ffffa3cd4c7eff20] do_page_fault at ffffffff9604fe27
    /home/user/build/1packages/4used/kernel/linux-stable/makepkg_pacman/li=
nux-stable/src/linux-stable/./arch/x86/include/asm/jump_label.h: 23
#14 [ffffa3cd4c7eff50] page_fault at ffffffff96a00e8e
    /home/user/build/1packages/4used/kernel/linux-stable/makepkg_pacman/li=
nux-stable/src/linux-stable/arch/x86/entry/entry_64.S: 1156
    RIP: 00005a46e611ac10  RSP: 00007fffa51f0f60  RFLAGS: 00010206
    RAX: 00000000098c0000  RBX: 000072d45bd40010  RCX: 000072d6aff243db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 000072d45bd40000
    RBP: 00005a46e611ba54   R8: 000072d45bd40010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -Tsx 3902
PID: 3902   TASK: ffff934f5264bd80  CPU: 1   COMMAND: "stress"
  [ffffa3cd4c99efb8] get_page_from_freelist+0xaa9 at ffffffff96291799
  [ffffa3cd4c99f108] __alloc_pages_slowpath+0x216 at ffffffff96292cb6
  [ffffa3cd4c99f130] get_page_from_freelist+0xb76 at ffffffff96291866
  [ffffa3cd4c99f178] get_page_from_freelist+0xaa9 at ffffffff96291799
  [ffffa3cd4c99f2e0] ZSTD_compressSequences_internal+0x8db at ffffffff9660=
a27b
  [ffffa3cd4c99f480] test_clear_page_writeback+0x12a at ffffffff9623ad8a
  [ffffa3cd4c99f4a8] trace_hardirqs_on+0x2c at ffffffff961bc30c
  [ffffa3cd4c99f4c8] test_clear_page_writeback+0x18c at ffffffff9623adec
  [ffffa3cd4c99f538] decay_load+0x6a at ffffffff96111d1a
  [ffffa3cd4c99f5a0] __list_add_valid+0x90 at ffffffff965e3ff0
  [ffffa3cd4c99f650] check_preempt_wakeup+0x267 at ffffffff960f7097
  [ffffa3cd4c99f6b8] decay_load+0x6a at ffffffff96111d1a
  [ffffa3cd4c99f6e0] __accumulate_pelt_segments+0x29 at ffffffff96111d89
  [ffffa3cd4c99f700] __update_load_avg_se+0x1cb at ffffffff961120ab
  [ffffa3cd4c99f738] update_load_avg+0xca at ffffffff960f73aa
  [ffffa3cd4c99f740] update_load_avg+0xca at ffffffff960f73aa
  [ffffa3cd4c99f7e0] switch_mm_irqs_off+0x270 at ffffffff96057920
  [ffffa3cd4c99f820] __schedule+0x51a at ffffffff969f471a
  [ffffa3cd4c99f880] preempt_schedule_common+0x15 at ffffffff969f4ed5
  [ffffa3cd4c99f898] _cond_resched+0x3f at ffffffff969f4f3f
  [ffffa3cd4c99f8a8] isolate_migratepages_block+0xf8 at ffffffff96260dd8
  [ffffa3cd4c99f978] compact_zone+0x4f9 at ffffffff96263eb9
  [ffffa3cd4c99fa38] compact_zone_order+0xe3 at ffffffff962648b3
  [ffffa3cd4c99faf0] try_to_compact_pages+0xde at ffffffff9626523e
  [ffffa3cd4c99fb60] __alloc_pages_direct_compact+0x8c at ffffffff9629285c
  [ffffa3cd4c99fbb8] __alloc_pages_slowpath+0x65c at ffffffff962930fc
  [ffffa3cd4c99fce8] __alloc_pages_nodemask+0x4cf at ffffffff962941ff
  [ffffa3cd4c99fd60] do_huge_pmd_anonymous_page+0x17c at ffffffff962c6fcc
  [ffffa3cd4c99fdb0] __handle_mm_fault+0xeee at ffffffff96272c3e
  [ffffa3cd4c99fe78] handle_mm_fault+0x17b at ffffffff9627369b
  [ffffa3cd4c99feb0] __do_page_fault+0x34e at ffffffff9604f8ee
  [ffffa3cd4c99ff20] do_page_fault+0x57 at ffffffff9604fe27
  [ffffa3cd4c99ff38] page_fault+0x8 at ffffffff96a00e78
  [ffffa3cd4c99ff50] page_fault+0x1e at ffffffff96a00e8e
    RIP: 00005a46e611ac10  RSP: 00007fffa51f0f60  RFLAGS: 00010206
    RAX: 000000000d0c0000  RBX: 000072d45bd40010  RCX: 000072d6aff243db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 000072d45bd40000
    RBP: 00005a46e611ba54   R8: 000072d45bd40010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -l 3902
PID: 3902   TASK: ffff934f5264bd80  CPU: 9   COMMAND: "stress"
(active)
crash> =


```
As can be seen, it's doing stuff with(in) zstd, maybe that's why swap in z=
std is needed to reproduce this (more easily? or at all?)


trace.log is still being compressed(via xz) but those running 'stress' pro=
cesses using 100% cpu are only making this slower :)
I'll send it when it's ready?
-----------------------8da43c4692aba7a8f346db54b897d0d0
Content-Type: application/pgp-keys; filename="publickey - howaboutsynergy@protonmail.com - 0x947B9B34.asc"; name="publickey - howaboutsynergy@protonmail.com - 0x947B9B34.asc"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="publickey - howaboutsynergy@protonmail.com - 0x947B9B34.asc"; name="publickey - howaboutsynergy@protonmail.com - 0x947B9B34.asc"

LS0tLS1CRUdJTiBQR1AgUFVCTElDIEtFWSBCTE9DSy0tLS0tDQpWZXJzaW9uOiBPcGVuUEdQLmpz
IHY0LjUuMQ0KQ29tbWVudDogaHR0cHM6Ly9vcGVucGdwanMub3JnDQoNCnhzRk5CRnlmMlFnQkVB
RGhNTmIvSnlDcXkyeXhQeUxBckNSK1dkZnVOc1ZqZ05LMGZhaktDSm9uVWllNw0KRldXYVJhQzhs
RTg0MGkzQ0I1dlpSSmNiQUtWZHlTT3VkRHNuWmd4cmsyeEVOL1BSVWVrNWI0ZkxJRHIwDQpOb3Rt
b0dndXoxd0xXNU9US00zd0g0TXNIM0svT0R6RXhMZ0VNM0ovK0dGUEROemhsL1laNEZJWUhTaGUN
CkRFVytZNXBQajFhMXpDU2JGajR5ZG1hRGRZVWtIUTV6b1RSNGx2ZXFpVk5XUW13dG44YmF3eGE4
MmVyeQ0KUzIrMXZ0NTdTZm42UXNPNWdzRHNlMWlYaGIyZTRPS3dZTUVaK0gvYVkraE13MVoxTmpT
WDdhZmZoZFBUDQptSnB2Vkp1ZnNGS1JhbTViSzk3SHBtbHZlSFYxdU1sdzFLQjQrS3NYZnhTSWlp
bzU3R0Vqbk1vT1N1NnINCjRDYmhyQXBqZGc5cjZVM2ZkU1Y0alRUM3JESFpWbllFSXNnZ1BpUGJN
Wjd4WEdVa2dkQzNtUnJucnNBTQ0KajBSZmlNRTM1dVpoT2hiSzN0bFBIN0dIalFHWHNGQzR2SFcz
b1Z3MksrWUdtbDlvT3gwcVpKTnI2Tkt2DQpkRVdYMU5WbXdQZzQrVmthcVhkV1dLTXJlZnh3Z0NE
bVpCY094R3VuaXE4VEkwenlxdXNQVFJ5QUVPWVgNCmZHdVVUcHJEWUdRVk5aNGN1WkJCU045WHBj
dHliTnJGaDliZmNyNTMrUzZ1WVk5RlZkWmp5a0xCVW1uNw0KcjYxYWM4cndnc3ZuVzBzWktJUGZ5
R2k0K0VpMG81ZUtXcG1WTHVHSUVFWW5vc1lnODdOV0lhVWNZbnk4DQpLemk3dFIyV1YzaVNuVUhP
UmxPMkoxMUlCeE15OTIwbnVMdk03d0FSQVFBQnpVRWlhRzkzWVdKdmRYUnoNCmVXNWxjbWQ1UUhC
eWIzUnZibTFoYVd3dVkyOXRJaUE4YUc5M1lXSnZkWFJ6ZVc1bGNtZDVRSEJ5YjNSdg0KYm0xaGFX
d3VZMjl0UHNMQmRRUVFBUWdBSHdVQ1hKL1pDQVlMQ1FjSUF3SUVGUWdLQWdNV0FnRUNHUUVDDQpH
d01DSGdFQUNna1FIUDNKWUhoYThremtFeEFBbnFwak5aL1NhelpoREVsa0daeHErOGZMamh1NGw1
cGgNCjJVU0dFSEdyZTIrY1k0V2dwZEliRGlVeTE0Tkg0Y1ZLL3FEd1RJazhIZ2x2SVhsOFZzdk1t
SXU1YW9xcg0KdHpiUVVTZi80YkYxRER5WVZmZ21JSnN2cXZRTFg4eldoejJydXJvQmpCbnRwNzVV
UVBZalYvbCtGZmxlDQpIVzJLWG5TUGVmY1B2cTF0SWFNbkkxTHJsK0FxSXN6K0xMZS9tMkpsU0tL
c3F0YTRlZkJORlB6L3ZidEgNCjloOFZ6NTZpUm5RS1dpSGFFa1pIcUtiUC9hc2x2ZmltTHptVFVI
Zk43NVNTMUZpMkJQeG14eFAycDE3MQ0KcmhkMDZoa2V1NjFHRWxPU0M4OG8wc3dVOHJoVWlqem4z
blFHM1dXUFMvQnBIa1RmRjlTNC9na3dMMStMDQp0YUpOdEQwR2J4a29iQU1iMjA2RTNIRzBZY0g4
dTlDdWhXSWlpQ3B0bHJlN2dPckdmTkk2cG5qQUhrSFoNCjFaUWFmSm5oVUN0TFkxQjZZQXZ6SUta
dHM1MG9vTG5tSU5vRmh3MjJRRG9JMnVKU1NzbjkvS1RjOStzNg0KQ2Mvek1TL1NiV0FJdzBGc3Aw
SDRmM1RkSjd6djhRWE03Vjl5M0FOaVVLNFU1NWRESnRjWmxDZzBkS050DQpqYlNzdWUrZCtNS0cv
NnBFUHU1UlloSjJDVDgwOWFtdlRqa0JCOTdQdU4zcnNmYWNWZy9yaWtFdmRKWmoNCmtoWjMyVDJX
bjI0VjJKR0VMT0xLSHE4ZGZoWFNnaDF4YWJ3SUR0QmtleEhlaHVsbmxVekRDM1BHbjl2cQ0Kb29D
K2tnY01MSE52WEpVWlFldTUva29wa0N4cTBVZmc2MEdCc3hITkxjSlFhZlE3UnVuT3dVMEVYSi9a
DQpDQUVRQUxyK241MVkvdTZxUEdvMW1hU3B6Y2RrdUQzQnNQU3VRdlZBbzZpc0VVVUdnY0dmbHA5
by9Id3cNCldFTVFEMWdTTlRaV1BzMjFwbExJbVdJbHFJbExGYWlHS1FnRDRMOHVPVURpVUh1YzRC
VnBHTzMrTERmYQ0KdjBCc0x1enBWRXo0TXcwUjZ3UnAxTWEvWkNZU3pyaENMSHM0RGp4cURRUUkz
T1d5TzBub3lISGl3bGJWDQovS1BvejlUaU9adU93dHNLV3hLSzdaMWZuWlQvREZ1MDMrOEhKWTNi
TlRLamNqT0FYN0QrSUFtd1FaY04NCi9KMElGTkFuL000V01Tc21QdlFDMEtKTVJiRzAxNmhJZHlj
ZDBVQ2M0MG43MUMwTnFTTWJRY0d1RzdoNg0KWEc4dG50VmJSNE5VTTZIV25MekRXN2RpRFpQRXl1
TU1DQWVRZmVabzZ0L3BJd0Q0dDk4dmQzQWg0ZnNzDQpSR0hyWUdzMWpoa2dWTjAxOVZUaDVtUnk3
V2lpUDY4eU43elBBN1Iwa0gydkRCWmxnamdVUlJUaWVLTSsNClV4bllHbE54ek5waWhRZWpVaVEw
MlhPa3VHU1VCYmxUNm1YdFl5UHd5SC9EYmNoa3ZVa3FXejlSS1RURw0KSEJrdERyOHZjcHY1ZG9D
eXY1bW1Pb2ZRYnA0YXBuc0R2SldGejkxbUtYdkdwZlQ1Q1MyaDJhUnRPMW9SDQpadWpIQUhDNGQ0
OXc0MTVSdXo2MlhTTGw0d3E4UHZDcXFWS0dTc1R4bSsvR3plN01yOWZpWjZSVXAvaHUNCndoVm5H
UHE1UzQyQW8wemxOTXpYRTEvajVBS2drOTV2ZEVWeDB5V1ZDbTV1Wnc0K0haeXUyUUdGM3NjWQ0K
NFhDUGRHL2l5d3NjZU1ZMVdXQlZiQS95dWdMSkFCRUJBQUhDd1Y4RUdBRUlBQWtGQWx5ZjJRZ0NH
d3dBDQpDZ2tRSFAzSllIaGE4a3o0eFEvOUhSTlJGRjY4OVVCaXNISXg5eVI3WG5iVTNKaGd3VFAv
bHpSS01rZGcNCjVUSENqN0M1bXpKREtzZmZVMURSWEFtVkM1eWIvc1JEUzQ5aGdOa0ZpZlRxNWF0
V20yTWR4aHAyUlZFWQ0KREl3L2p0Wm5rLy9IWDJ2MDJhd3pJTktUTXM1S0tYdFAyMTA5NG1IT2wr
MzNFRi92T2t3ajJOMHRtL2wzDQp6ZmNDdzVsVHZpbGFCcDd5ZUpJSjB5aU45QlF0Skl3MG9PRjFF
b3k4Z3RlRGFzN2tWVFI0T2pLM0JyQzMNCktMYXFlZEQ0RVRrYSszZHdVZXRETEYyQkZ6Q3JIeDBI
bWFPWXZFNzgwaGpFMk9QQytUNTlwdnU2RG1wYg0KRmczcnlJcVJwSTZxRm5UUlVjVmVSNTU4Ly9Q
K3E1cElGd3F4Y0dwNllTdytXb0Q5UEs2MEd0ZVlIL2FRDQptTW5Ba096RlJSOGpqYVJBa2JtTnFF
L1ZLK2FLeDBBYWlNdy8zTFNsbHNrcGdGNUcvcjBEUXRobVpnRVENCmRNUWdRQWRVbW1EMFp3VzUx
VVVTZzJmaHd3NkFzMHAxWlBYTWdOaWdsLzQ0b0ZQdDZBSVBhc25HejVqRg0KYVRzSjlqdnFFT3lm
dlRtNTNvYnJZeTNaRHJydy9reEZYc1Z6MkVaZzI3Y05yY2Z1ejRzYWtodzUzZFY5DQp4MkVMTkE2
NlVSSFNpRjR6TUYxaVBpL2JGVkVrMEhuVVpNTGJmblV5V0hKTTBNY0RLSCthSDFIOGZpOWcNClVa
TitxWnEveXJ3dzJuYWJMVDRtVXFCTnVQOVZrY2dPdXlwNVhIYlBRZkIwRDI4cW9IWDVjNE1GeEVa
Qw0KV3MrOVRzQkxCdmxBSno3VkF4dWNrY1huWVhUUnNTanBTZUd0czBUeE85TT0NCj1Land6DQot
LS0tLUVORCBQR1AgUFVCTElDIEtFWSBCTE9DSy0tLS0tDQo=
-----------------------8da43c4692aba7a8f346db54b897d0d0--

-----------------------ea00e6b2d78cb631f664528351279604
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: ProtonMail
Comment: https://protonmail.com

wsFcBAEBCAAGBQJdLiIZAAoJEBz9yWB4WvJMPwYQAIT+5a7trlQq58J58vm+
+K4jHiIBPiSSqxasW1/QxqztopvRkVTLkpWiDwuwXQAynroFc+SMncUcKFB9
Ba7HrV2EzpHv5yMJgK/kmqfnPFxj3ObrMYW1RFoxMjQY+tfWjiE1yWj0MWyj
eCjw3lU+HAjP8vV3ZROS+3q8s5DiLlSNgvxoszWRZmdvgSZ1l4+oN25Ofo07
3b3Gt1sr9HqcShZsnyw5mZbtxbL6YYq2FyD+IO/2oe3rGzu7y0m0m4hH9VGo
qSlvKE6fZfqDciHZ6xLpcrRTpk1/NWgIqZJgEilzhONYAFf5wnI9nJkI7cLG
aotPVjSLfgtCQiYGS97UcksNoMH+C5HBr9c4CQz4AIBTFl7JEia0ZbN8UdZL
eLFEYv40EawvSpRh8OMvCRAVFpxNhG9WoDc+rv+MK5gGgMPpTjWgA5gZ6va7
ZgkuIKBxssoNb6u8L7tWb4RIYrZpbWJx9S1Wuks9khq5T9ALNDi/u4ugKfZe
ghA3f7al9AD5SGTLEdSJSEuc/HzjjYuae5gf+A6rfghYp5Qjdnl4drCSlh8B
ESZ6lFFirlvJF/GlO3rzHgNI0p0fLTwcA5sXT5pDHw4pS9Wmrvb7ZKgu9Q+5
GSe7bu5JuHNytbq/GGag2oZ19cyaISsZI0xt24+LeCdoTPV4ozOB4eSJwFGt
ElyT
=41Xu
-----END PGP SIGNATURE-----


-----------------------ea00e6b2d78cb631f664528351279604--

