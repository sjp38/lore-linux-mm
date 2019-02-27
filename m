Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D6CBC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:02:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DD75420823
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:02:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DD75420823
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=daenzer.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 58F748E0004; Wed, 27 Feb 2019 12:02:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4EE058E0001; Wed, 27 Feb 2019 12:02:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 319878E0004; Wed, 27 Feb 2019 12:02:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id C53ED8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:02:53 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id t190so2083635wmt.8
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:02:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:cc:from
         :subject:openpgp:autocrypt:to:message-id:date:user-agent
         :mime-version:content-language;
        bh=drrHIEpT4ifJwjNsYe65sPpPLHDOxxNdhTv5FiskUkQ=;
        b=Inh0GYw+OLzOxl2+jH5hCRSdZlxNNW5AYywaUDwulMiySAeiRe9A1PPrsaAN0yS9A6
         9eDEzNdAUTLkBKdYnZwhHKbLoZJf+JUYEo1SlVwTPYG7ZMqoIQrVMdmZwkE0vbi9nOQP
         qJW1LJCKMUM6e+XH+5A6M5IjtZ3nNbJvzfKpOf2TZcKajNUMxpyoFDXJpyFxXmacgOhX
         r/TvLJ+h0edigOSF+pEbllbA9pOxdXA5V8jbcfm9e1B0wKhClR/U91MGn31uKaJlPFHO
         9O5MzSQePJo+ST4obvYpl6VQDqTE7CH3+00iN0/Dq0BkvvdGKdOd/9XAAYNQopi3aC8+
         PXhg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 148.251.143.178 is neither permitted nor denied by best guess record for domain of michel@daenzer.net) smtp.mailfrom=michel@daenzer.net
X-Gm-Message-State: APjAAAWlA8a5zC49WI5H1gmNF1FF4sCAFgdiyESRXxOQXJAcZFgCbksN
	MpuqUVxmyFiILJsj0c8vcHcBAHAJE721k2T0rKJTlWrmyCae+Zl7YDmpi/QSlYRJ4MuV2uoeRm4
	NYVsztMz4w7VEr6z0Ss92n4L0pjX0r4SDmJCcBa96+pJwQ3ITlocFac0iV6t+9l0=
X-Received: by 2002:adf:e785:: with SMTP id n5mr3052755wrm.96.1551286973240;
        Wed, 27 Feb 2019 09:02:53 -0800 (PST)
X-Google-Smtp-Source: APXvYqwWLFXTAljyx270piacVb3qAEqjWNgczd2T6tcFR/lVLmRdF4t429ySDf/t01vyIMAZxvdb
X-Received: by 2002:adf:e785:: with SMTP id n5mr3052703wrm.96.1551286972245;
        Wed, 27 Feb 2019 09:02:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551286972; cv=none;
        d=google.com; s=arc-20160816;
        b=oVzWgRcwWCMDa1o/KJnaC8fwGXaxVZIyfgOFQ4QgeB1D/4dgoZS+BLyZpXJLqG7V6z
         jrbhnWXh7U4ko0apK5dFUMM9eluDiuEjcgeOhWYNK2RKkkdFL+CUv60UWEHKRt7Ev31F
         WFbmkC9w+zRx+HrZlMUeDqldmcv5dudutAxVhiSt+sYwHrEPGoQCzDdfMMaTSyicbzYe
         t9VMyRkBJO8uLDiYrZhCTPvnlap4M8YQsG1c0jbcWc7G8gCQsSsPWg7BlYMngcUl1tpP
         /8fZfUb3AjQYpFJTGUNST+b8OB1Ji21UIizK44xXkFn9uUlJEUdV4MvatoucUs9r/DYV
         c8ew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:mime-version:user-agent:date:message-id:to
         :autocrypt:openpgp:subject:from:cc;
        bh=drrHIEpT4ifJwjNsYe65sPpPLHDOxxNdhTv5FiskUkQ=;
        b=Dx0gAHZaL1p0sH6ymR9yAexwU3YS/IBZIccWP9mExDvEP19C8IyTgvJUQQIc4qxL8C
         1l8UrJSDImL5sgtdBXyaw2Snzog3bJocg5VtSKL4LaiZnUd0c6/ZqIMCb5iPxDgYNB/C
         O6NBjvoQY9Ra6iL7k5ojmJkF7C4Msmj9hTWBydJE+aCvH9Uqy5udaDYJIvynvVQV80ZG
         L2EisEg0ugKVIEw4uhRcQGsYA1X39c2AT+O+I5i5vRU9mbGvhxCm5b+HsRS7UwI0xyqh
         z9nMvKbaiUJPsc0QmBwmC1d7+dQkJaHn1irHrSj4auIi9QJACACndjvKDoLYnYtg3JqW
         NAkw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 148.251.143.178 is neither permitted nor denied by best guess record for domain of michel@daenzer.net) smtp.mailfrom=michel@daenzer.net
Received: from netline-mail3.netline.ch (mail.netline.ch. [148.251.143.178])
        by mx.google.com with ESMTP id p18si1418726wmh.162.2019.02.27.09.02.51
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 09:02:52 -0800 (PST)
Received-SPF: neutral (google.com: 148.251.143.178 is neither permitted nor denied by best guess record for domain of michel@daenzer.net) client-ip=148.251.143.178;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 148.251.143.178 is neither permitted nor denied by best guess record for domain of michel@daenzer.net) smtp.mailfrom=michel@daenzer.net
Received: from localhost (localhost [127.0.0.1])
	by netline-mail3.netline.ch (Postfix) with ESMTP id 95BA82A6059;
	Wed, 27 Feb 2019 18:02:51 +0100 (CET)
X-Virus-Scanned: Debian amavisd-new at netline-mail3.netline.ch
Received: from netline-mail3.netline.ch ([127.0.0.1])
	by localhost (netline-mail3.netline.ch [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id mbnMmEV8rb_5; Wed, 27 Feb 2019 18:02:51 +0100 (CET)
Received: from thor (116.245.63.188.dynamic.wline.res.cust.swisscom.ch [188.63.245.116])
	by netline-mail3.netline.ch (Postfix) with ESMTPSA id 7FBDE2A6058;
	Wed, 27 Feb 2019 18:02:50 +0100 (CET)
Received: from [::1]
	by thor with esmtp (Exim 4.92-RC6)
	(envelope-from <michel@daenzer.net>)
	id 1gz2bZ-0006g0-Ts; Wed, 27 Feb 2019 18:02:49 +0100
Cc: amd-gfx@lists.freedesktop.org, linux-mm@kvack.org
From: =?UTF-8?Q?Michel_D=c3=a4nzer?= <michel@daenzer.net>
Subject: KASAN caught amdgpu / HMM use-after-free
Openpgp: preference=signencrypt
Autocrypt: addr=michel@daenzer.net; prefer-encrypt=mutual; keydata=
 mQGiBDsehS8RBACbsIQEX31aYSIuEKxEnEX82ezMR8z3LG8ktv1KjyNErUX9Pt7AUC7W3W0b
 LUhu8Le8S2va6hi7GfSAifl0ih3k6Bv1Itzgnd+7ZmSrvCN8yGJaHNQfAevAuEboIb+MaVHo
 9EMJj4ikOcRZCmQWw7evu/D9uQdtkCnRY9iJiAGxbwCguBHtpoGMxDOINCr5UU6qt+m4O+UD
 /355ohBBzzyh49lTj0kTFKr0Ozd20G2FbcqHgfFL1dc1MPyigej2gLga2osu2QY0ObvAGkOu
 WBi3LTY8Zs8uqFGDC4ZAwMPoFy3yzu3ne6T7d/68rJil0QcdQjzzHi6ekqHuhst4a+/+D23h
 Za8MJBEcdOhRhsaDVGAJSFEQB1qLBACOs0xN+XblejO35gsDSVVk8s+FUUw3TSWJBfZa3Imp
 V2U2tBO4qck+wqbHNfdnU/crrsHahjzBjvk8Up7VoY8oT+z03sal2vXEonS279xN2B92Tttr
 AgwosujguFO/7tvzymWC76rDEwue8TsADE11ErjwaBTs8ZXfnN/uAANgPLQjTWljaGVsIERh
 ZW56ZXIgPG1pY2hlbEBkYWVuemVyLm5ldD6IXgQTEQIAHgUCQFXxJgIbAwYLCQgHAwIDFQID
 AxYCAQIeAQIXgAAKCRBaga+OatuyAIrPAJ9ykonXI3oQcX83N2qzCEStLNW47gCeLWm/QiPY
 jqtGUnnSbyuTQfIySkK5AQ0EOx6FRRAEAJZkcvklPwJCgNiw37p0GShKmFGGqf/a3xZZEpjI
 qNxzshFRFneZze4f5LhzbX1/vIm5+ZXsEWympJfZzyCmYPw86QcFxyZflkAxHx9LeD+89Elx
 bw6wT0CcLvSv8ROfU1m8YhGbV6g2zWyLD0/naQGVb8e4FhVKGNY2EEbHgFBrAAMGA/0VktFO
 CxFBdzLQ17RCTwCJ3xpyP4qsLJH0yCoA26rH2zE2RzByhrTFTYZzbFEid3ddGiHOBEL+bO+2
 GNtfiYKmbTkj1tMZJ8L6huKONaVrASFzLvZa2dlc2zja9ZSksKmge5BOTKWgbyepEc5qxSju
 YsYrX5xfLgTZC5abhhztpYhGBBgRAgAGBQI7HoVFAAoJEFqBr45q27IAlscAn2Ufk2d6/3p4
 Cuyz/NX7KpL2dQ8WAJ9UD5JEakhfofed8PSqOM7jOO3LCA==
To: Philip Yang <Philip.Yang@amd.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>
Message-ID: <e8466985-a66b-468b-5fff-6e743180da67@daenzer.net>
Date: Wed, 27 Feb 2019 18:02:49 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------F44DAA55B53BA30728B159A3"
Content-Language: en-CA
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------F44DAA55B53BA30728B159A3
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit


See the attached dmesg excerpt. I've hit this a few times running piglit
with amd-staging-drm-next, first on February 22nd.

The memory was freed after calling hmm_mirror_unregister in
amdgpu_mn_destroy.


-- 
Earthling Michel Dänzer               |              https://www.amd.com
Libre software enthusiast             |             Mesa and X developer

--------------F44DAA55B53BA30728B159A3
Content-Type: text/x-log;
 name="kern.log"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="kern.log"

Feb 27 16:58:54 kaveri kernel: [ 2184.979558] ==================================================================
Feb 27 16:58:54 kaveri kernel: [ 2184.979574] BUG: KASAN: use-after-free in __lock_acquire+0x3291/0x4650
Feb 27 16:58:54 kaveri kernel: [ 2184.979579] Read of size 8 at addr ffff8881c7179ed8 by task amd_pinned_memo/21960
Feb 27 16:58:54 kaveri kernel: [ 2184.979581] 
Feb 27 16:58:54 kaveri kernel: [ 2184.979587] CPU: 13 PID: 21960 Comm: amd_pinned_memo Tainted: G        W  OE     5.0.0-rc1-00409-gdbb4a1266c83-dirty #120
Feb 27 16:58:54 kaveri kernel: [ 2184.979591] Hardware name: Micro-Star International Co., Ltd. MS-7A34/B350 TOMAHAWK (MS-7A34), BIOS 1.80 09/13/2017
Feb 27 16:58:54 kaveri kernel: [ 2184.979594] Call Trace:
Feb 27 16:58:54 kaveri kernel: [ 2184.979602]  dump_stack+0x7c/0xc0
Feb 27 16:58:54 kaveri kernel: [ 2184.979606]  ? __lock_acquire+0x3291/0x4650
Feb 27 16:58:54 kaveri kernel: [ 2184.979612]  print_address_description+0x65/0x22e
Feb 27 16:58:54 kaveri kernel: [ 2184.979616]  ? __lock_acquire+0x3291/0x4650
Feb 27 16:58:54 kaveri kernel: [ 2184.979619]  ? __lock_acquire+0x3291/0x4650
Feb 27 16:58:54 kaveri kernel: [ 2184.979623]  kasan_report.cold.3+0x1a/0x40
Feb 27 16:58:54 kaveri kernel: [ 2184.979628]  ? __lock_acquire+0x3291/0x4650
Feb 27 16:58:54 kaveri kernel: [ 2184.979632]  __lock_acquire+0x3291/0x4650
Feb 27 16:58:54 kaveri kernel: [ 2184.979636]  ? find_held_lock+0x33/0x1c0
Feb 27 16:58:54 kaveri kernel: [ 2184.979642]  ? finish_task_switch+0x12b/0x630
Feb 27 16:58:54 kaveri kernel: [ 2184.979647]  ? mark_held_locks+0x140/0x140
Feb 27 16:58:54 kaveri kernel: [ 2184.979651]  ? finish_task_switch+0xf4/0x630
Feb 27 16:58:54 kaveri kernel: [ 2184.979656]  ? _raw_spin_unlock_irq+0x29/0x30
Feb 27 16:58:54 kaveri kernel: [ 2184.979660]  ? lockdep_hardirqs_on+0x37c/0x560
Feb 27 16:58:54 kaveri kernel: [ 2184.979664]  ? finish_task_switch+0x191/0x630
Feb 27 16:58:54 kaveri kernel: [ 2184.979668]  ? __switch_to_asm+0x34/0x70
Feb 27 16:58:54 kaveri kernel: [ 2184.979671]  ? __switch_to_asm+0x40/0x70
Feb 27 16:58:54 kaveri kernel: [ 2184.979676]  ? __schedule+0x800/0x1cb0
Feb 27 16:58:54 kaveri kernel: [ 2184.979681]  lock_acquire+0x103/0x2c0
Feb 27 16:58:54 kaveri kernel: [ 2184.979687]  ? hmm_release+0x1c3/0x2d0
Feb 27 16:58:54 kaveri kernel: [ 2184.979692]  down_write+0x2b/0x80
Feb 27 16:58:54 kaveri kernel: [ 2184.979696]  ? hmm_release+0x1c3/0x2d0
Feb 27 16:58:54 kaveri kernel: [ 2184.979700]  hmm_release+0x1c3/0x2d0
Feb 27 16:58:54 kaveri kernel: [ 2184.979706]  ? uprobe_clear_state+0x5e/0x200
Feb 27 16:58:54 kaveri kernel: [ 2184.979711]  __mmu_notifier_release+0xef/0x3d0
Feb 27 16:58:54 kaveri kernel: [ 2184.979717]  exit_mmap+0x93/0x400
Feb 27 16:58:54 kaveri kernel: [ 2184.979720]  ? quarantine_put+0xb7/0x150
Feb 27 16:58:54 kaveri kernel: [ 2184.979724]  ? do_munmap+0x10/0x10
Feb 27 16:58:54 kaveri kernel: [ 2184.979727]  ? lockdep_hardirqs_on+0x37c/0x560
Feb 27 16:58:54 kaveri kernel: [ 2184.979732]  ? __khugepaged_exit+0x2af/0x3e0
Feb 27 16:58:54 kaveri kernel: [ 2184.979735]  ? __khugepaged_exit+0x2af/0x3e0
Feb 27 16:58:54 kaveri kernel: [ 2184.979738]  ? __khugepaged_exit+0x2af/0x3e0
Feb 27 16:58:54 kaveri kernel: [ 2184.979744]  ? rcu_read_lock_sched_held+0xd8/0x110
Feb 27 16:58:54 kaveri kernel: [ 2184.979748]  ? kmem_cache_free+0x27c/0x2c0
Feb 27 16:58:54 kaveri kernel: [ 2184.979751]  ? __khugepaged_exit+0x2be/0x3e0
Feb 27 16:58:54 kaveri kernel: [ 2184.979756]  mmput+0xb2/0x390
Feb 27 16:58:54 kaveri kernel: [ 2184.979760]  do_exit+0x899/0x2840
Feb 27 16:58:54 kaveri kernel: [ 2184.979765]  ? mm_update_next_owner+0x600/0x600
Feb 27 16:58:54 kaveri kernel: [ 2184.979770]  ? __do_page_fault+0x424/0x9e0
Feb 27 16:58:54 kaveri kernel: [ 2184.979774]  ? lock_downgrade+0x5d0/0x5d0
Feb 27 16:58:54 kaveri kernel: [ 2184.979778]  ? handle_mm_fault+0x4e7/0x750
Feb 27 16:58:54 kaveri kernel: [ 2184.979784]  do_group_exit+0xf0/0x2e0
Feb 27 16:58:54 kaveri kernel: [ 2184.979788]  __x64_sys_exit_group+0x3a/0x50
Feb 27 16:58:54 kaveri kernel: [ 2184.979793]  do_syscall_64+0x9c/0x3d0
Feb 27 16:58:54 kaveri kernel: [ 2184.979797]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
Feb 27 16:58:54 kaveri kernel: [ 2184.979802] RIP: 0033:0x7fcfc943bcf6
Feb 27 16:58:54 kaveri kernel: [ 2184.979806] Code: 00 4c 8b 0d 9c 41 0f 00 eb 19 66 2e 0f 1f 84 00 00 00 00 00 89 d7 89 f0 0f 05 48 3d 00 f0 ff ff 77 22 f4 89 d7 44 89 c0 0f 05 <48> 3d 00 f0 ff ff 76 e2 f7 d8 64 41 89 01 eb da 66 2e 0f 1f 84 00
Feb 27 16:58:54 kaveri kernel: [ 2184.979810] RSP: 002b:00007ffdb68de6e8 EFLAGS: 00000246 ORIG_RAX: 00000000000000e7
Feb 27 16:58:54 kaveri kernel: [ 2184.979815] RAX: ffffffffffffffda RBX: 00007fcfc952c760 RCX: 00007fcfc943bcf6
Feb 27 16:58:54 kaveri kernel: [ 2184.979818] RDX: 0000000000000000 RSI: 000000000000003c RDI: 0000000000000000
Feb 27 16:58:54 kaveri kernel: [ 2184.979821] RBP: 0000000000000000 R08: 00000000000000e7 R09: ffffffffffffff48
Feb 27 16:58:54 kaveri kernel: [ 2184.979824] R10: 0000000000000000 R11: 0000000000000246 R12: 00007fcfc952c760
Feb 27 16:58:54 kaveri kernel: [ 2184.979827] R13: 00000000000004c5 R14: 00007fcfc9535428 R15: 0000000000000000
Feb 27 16:58:54 kaveri kernel: [ 2184.979832] 
Feb 27 16:58:54 kaveri kernel: [ 2184.979835] Allocated by task 21960:
Feb 27 16:58:54 kaveri kernel: [ 2184.979839]  kasan_kmalloc+0xc6/0xd0
Feb 27 16:58:54 kaveri kernel: [ 2184.979843]  hmm_register.part.12+0x48/0x2e0
Feb 27 16:58:54 kaveri kernel: [ 2184.979846]  hmm_mirror_register+0xf5/0x320
Feb 27 16:58:54 kaveri kernel: [ 2184.979948]  amdgpu_mn_get+0x37b/0x6c0 [amdgpu]
Feb 27 16:58:54 kaveri kernel: [ 2184.980040]  amdgpu_mn_register+0xf6/0x710 [amdgpu]
Feb 27 16:58:54 kaveri kernel: [ 2184.980126]  amdgpu_gem_userptr_ioctl+0x656/0x960 [amdgpu]
Feb 27 16:58:54 kaveri kernel: [ 2184.980146]  drm_ioctl_kernel+0x1c6/0x260 [drm]
Feb 27 16:58:54 kaveri kernel: [ 2184.980165]  drm_ioctl+0x42d/0x920 [drm]
Feb 27 16:58:54 kaveri kernel: [ 2184.980242]  amdgpu_drm_ioctl+0xd0/0x1b0 [amdgpu]
Feb 27 16:58:54 kaveri kernel: [ 2184.980246]  do_vfs_ioctl+0x193/0xfd0
Feb 27 16:58:54 kaveri kernel: [ 2184.980249]  ksys_ioctl+0x60/0x90
Feb 27 16:58:54 kaveri kernel: [ 2184.980252]  __x64_sys_ioctl+0x6f/0xb0
Feb 27 16:58:54 kaveri kernel: [ 2184.980255]  do_syscall_64+0x9c/0x3d0
Feb 27 16:58:54 kaveri kernel: [ 2184.980258]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
Feb 27 16:58:54 kaveri kernel: [ 2184.980260] 
Feb 27 16:58:54 kaveri kernel: [ 2184.980263] Freed by task 14381:
Feb 27 16:58:54 kaveri kernel: [ 2184.980266]  __kasan_slab_free+0x12a/0x170
Feb 27 16:58:54 kaveri kernel: [ 2184.980269]  kfree+0xe2/0x290
Feb 27 16:58:54 kaveri kernel: [ 2184.980368]  amdgpu_mn_destroy+0x2f0/0x440 [amdgpu]
Feb 27 16:58:54 kaveri kernel: [ 2184.980372]  process_one_work+0x815/0x1490
Feb 27 16:58:54 kaveri kernel: [ 2184.980375]  worker_thread+0x87/0xb10
Feb 27 16:58:54 kaveri kernel: [ 2184.980379]  kthread+0x2e2/0x3a0
Feb 27 16:58:54 kaveri kernel: [ 2184.980382]  ret_from_fork+0x27/0x50
Feb 27 16:58:54 kaveri kernel: [ 2184.980384] 
Feb 27 16:58:54 kaveri kernel: [ 2184.980387] The buggy address belongs to the object at ffff8881c7179e00
Feb 27 16:58:54 kaveri kernel: [ 2184.980387]  which belongs to the cache kmalloc-256 of size 256
Feb 27 16:58:54 kaveri kernel: [ 2184.980391] The buggy address is located 216 bytes inside of
Feb 27 16:58:54 kaveri kernel: [ 2184.980391]  256-byte region [ffff8881c7179e00, ffff8881c7179f00)
Feb 27 16:58:54 kaveri kernel: [ 2184.980394] The buggy address belongs to the page:
Feb 27 16:58:54 kaveri kernel: [ 2184.980397] page:ffffea00071c5e00 count:1 mapcount:0 mapping:ffff8883bd80ee00 index:0x0 compound_mapcount: 0
Feb 27 16:58:54 kaveri kernel: [ 2184.980403] flags: 0x17fffc000010200(slab|head)
Feb 27 16:58:54 kaveri kernel: [ 2184.980409] raw: 017fffc000010200 ffffea000a4f7900 0000000300000003 ffff8883bd80ee00
Feb 27 16:58:54 kaveri kernel: [ 2184.980413] raw: 0000000000000000 0000000000190019 00000001ffffffff 0000000000000000
Feb 27 16:58:54 kaveri kernel: [ 2184.980416] page dumped because: kasan: bad access detected
Feb 27 16:58:54 kaveri kernel: [ 2184.980418] 
Feb 27 16:58:54 kaveri kernel: [ 2184.980420] Memory state around the buggy address:
Feb 27 16:58:54 kaveri kernel: [ 2184.980423]  ffff8881c7179d80: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc
Feb 27 16:58:54 kaveri kernel: [ 2184.980426]  ffff8881c7179e00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
Feb 27 16:58:54 kaveri kernel: [ 2184.980429] >ffff8881c7179e80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
Feb 27 16:58:54 kaveri kernel: [ 2184.980432]                                                     ^
Feb 27 16:58:54 kaveri kernel: [ 2184.980435]  ffff8881c7179f00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
Feb 27 16:58:54 kaveri kernel: [ 2184.980438]  ffff8881c7179f80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
Feb 27 16:58:54 kaveri kernel: [ 2184.980440] ==================================================================

--------------F44DAA55B53BA30728B159A3--

