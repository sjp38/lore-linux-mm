Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6CAEC10F00
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 22:06:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B6DD20840
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 22:06:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ovCilbDl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B6DD20840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF3C78E0003; Wed,  6 Mar 2019 17:06:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EA35B8E0002; Wed,  6 Mar 2019 17:06:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D928C8E0003; Wed,  6 Mar 2019 17:06:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id B43BF8E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 17:06:09 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id r21so11056756ioa.13
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 14:06:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=lqPYOaCXuNPqYA0GOIDbs7rPmzwX5TT0hcpajmda5F4=;
        b=aoMXzyFttigoS/q28IIrZ3MdcpN8tGCi0yzZgkT9Nn73J74IDgPzBBJ0tdcQgSEMzz
         oOTR7urfh7U3jSfgazWbuZX+p1G2VCfghrns4e9AdR+95tU6xqGcDWCv7Szyv1dn1Otb
         1IcN/0LPKvVzyXaQ/MIvkM7iKh3rRpHmGtYmxcbkOngQk7/f/a241vMiDGpfYePoFiwg
         0i0zfBuXfAbP68vkVZSlgqTuQay9RQDaHZEliiZ84e9hpVEQGlydlN/PJWVlosO4w4ns
         lajeWNR949W4JKTfrYna2+gZG03lN4XnX/L6cYsmIjGb+vGNzoHoylL+xAnMfT48I2so
         2Z7Q==
X-Gm-Message-State: APjAAAV2oPcouS8yH+602M9/ENzDm8KPO3ID092RKSIvd3sxrdanfS5i
	FM9++Spnt16FOkZwxxVEvdSCZGDSm+w/MorGmHRV29bOtaSwUQ0f4sPkvDTbptn2O2WlFTgAL2i
	eLALhYPLFN3645pPrl7wAk1caFO1ZoN/10g+Um8/mvJ/eGo8FQqy+Dvupvn/mDhytCoFBxwKOnG
	EKAbWxq3JbHSNG1QYQ2FhE0s1O0eOd9uMqstBcOMoy1XjYPkx0W00WTGqr6+7Fe0b2vhpVroVOx
	pY4DSnX0ZVJlnFy9wtVoLUW2QRm6X0k7uN1ZKrlfZOtVTPfV83aHUdpLjo8iDWjVAAqppmyeQxY
	C0es/+RPgYs7wshINBjupUZplbSp/QOraOa92nXfutAke9YSft4ExNN//pUbhZWoDezlWdkYcMt
	1
X-Received: by 2002:a6b:7b05:: with SMTP id l5mr4351694iop.285.1551909969429;
        Wed, 06 Mar 2019 14:06:09 -0800 (PST)
X-Received: by 2002:a6b:7b05:: with SMTP id l5mr4351586iop.285.1551909966982;
        Wed, 06 Mar 2019 14:06:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551909966; cv=none;
        d=google.com; s=arc-20160816;
        b=s59x1aqZyF36Dx7UNp1U+8eoysp5ledVJKBW/ofpkYO2z5HrFLO9OxukSAcnEE27QO
         TTr4v7GHGqp4F3/Y10GVklKf39zMgRaacIQvy5ZY9KSfeohRDa/maywCXNPPZrai3YHh
         NNSYPyBKFpQt2faWw4crlByJFXrGuDXlrDsDXRXfwGNtWGON10gb/Q32pR4Fw3jJMzwK
         21gcWmhjuXc+kVpLiZmjt/t2jvAUjf33ex3lfSUBwYzyf2MwDuwF9hDWPNIgDdPyYN3e
         ASiaPZX37x35SuJ257CNjNu3pSDC6rfemiUaCWUtApMdwbME2N/tZ/Kz3NBAQgX6OxEP
         mbWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=lqPYOaCXuNPqYA0GOIDbs7rPmzwX5TT0hcpajmda5F4=;
        b=qPkSbbfpvoB5NOr+NIBTMIjDB1ZDfiZSQenrEa0EKLpxKFWZ7pHpmatpIDvWpeLOJh
         9z/3sOfIJjR2gLauMVJJoZ6ndgTqrvpspkFA2/WdcL7pfC56Yb7LHWjSV/h46ffRBrrd
         BR/v9LK8dqjU6FJTBPgkq41DH1jPeLKATi7b/GxNsNvy3ZW/3cSC2YyM7Jz02SqfCTrA
         3x2STHw7bktOIwDFJDG1xxIzeOl9hqVc+0+80fZOAuNswXZuq8S4WHuZ5TeRlSejIg2T
         U56of2ti84oio2CDSHJZF5hqfqDKn5BLTT/MfdYQct0hfkY50tcM1qwhbrVOKKXRtcXm
         1wzw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ovCilbDl;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x100sor5179898ita.29.2019.03.06.14.06.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Mar 2019 14:06:06 -0800 (PST)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ovCilbDl;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=lqPYOaCXuNPqYA0GOIDbs7rPmzwX5TT0hcpajmda5F4=;
        b=ovCilbDlrzJq3s5qWLY8FgCbaDYdeGY1uoh6Uxp6KqIaRFOpnLv4C+XYHd2+HmWlke
         qZiGhWTSqDH9bQjgTNemPcHj1e+ciz24NFq/CVhxlkoGzMC/FmVdRC7DL7RGuAxbT4dK
         MINPIMe12fto75VzOihCuchAZ5USA8Rz5P5pPhLOUd8oRklzNbSS2qSSW0egH4yXWgk0
         VqE8La0fkaYEojAezSXn8zXAjTUlrggsyPxp/zTqzXs1feJHj/FrjSKW5j+yrK2VAnQn
         1NIi/3nGxKJTVHbeydLssjBg8CkVD21gsYyUtD2ker/F23gQWfeyF5q5mYE1789RFD0z
         3YXA==
X-Google-Smtp-Source: APXvYqxCBqEmb582tjxfS8Hn0YXcYFl+HtWOzqWbWTd94BKUX34IFenEiQS2F2UsciVYOzbAf21UpFGeXSJn+avDdLw=
X-Received: by 2002:a02:95a:: with SMTP id f87mr5361433jad.83.1551909966364;
 Wed, 06 Mar 2019 14:06:06 -0800 (PST)
MIME-Version: 1.0
References: <20190306155048.12868-1-nitesh@redhat.com> <CAKgT0Ud35pmmfAabYJijWo8qpucUWS8-OzBW=gsotfxZFuS9PQ@mail.gmail.com>
 <1d5e27dc-aade-1be7-2076-b7710fa513b6@redhat.com>
In-Reply-To: <1d5e27dc-aade-1be7-2076-b7710fa513b6@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Wed, 6 Mar 2019 14:05:54 -0800
Message-ID: <CAKgT0UdNPADF+8NMxnWuiB_+_M6_0jTt5NfoOvFN9qbPjGWNtw@mail.gmail.com>
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
To: Nitesh Narayan Lal <nitesh@redhat.com>
Cc: kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com, 
	pagupta@redhat.com, wei.w.wang@intel.com, 
	Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>, 
	David Hildenbrand <david@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, dodgen@google.com, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com, 
	Andrea Arcangeli <aarcange@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 6, 2019 at 11:07 AM Nitesh Narayan Lal <nitesh@redhat.com> wrot=
e:
>
>
> On 3/6/19 1:00 PM, Alexander Duyck wrote:
> > On Wed, Mar 6, 2019 at 7:51 AM Nitesh Narayan Lal <nitesh@redhat.com> w=
rote:
> >> The following patch-set proposes an efficient mechanism for handing fr=
eed memory between the guest and the host. It enables the guests with no pa=
ge cache to rapidly free and reclaims memory to and from the host respectiv=
ely.
> >>
> >> Benefit:
> >> With this patch-series, in our test-case, executed on a single system =
and single NUMA node with 15GB memory, we were able to successfully launch =
5 guests(each with 5 GB memory) when page hinting was enabled and 3 without=
 it. (Detailed explanation of the test procedure is provided at the bottom =
under Test - 1).
> >>
> >> Changelog in v9:
> >>         * Guest free page hinting hook is now invoked after a page has=
 been merged in the buddy.
> >>         * Free pages only with order FREE_PAGE_HINTING_MIN_ORDER(curre=
ntly defined as MAX_ORDER - 1) are captured.
> >>         * Removed kthread which was earlier used to perform the scanni=
ng, isolation & reporting of free pages.
> > Without a kthread this has the potential to get really ugly really
> > fast. If we are going to run asynchronously we should probably be
> > truly asynchonous and just place a few pieces of data in the page that
> > a worker thread can use to identify which pages have been hinted and
> > which pages have not.
>
> Can you please explain what do you mean by truly asynchronous?
>
> With this implementation also I am not reporting the pages synchronously.

The problem is you are making it pseudo synchronous by having to push
pages off to a side buffer aren't you? In my mind we should be able to
have the page hinting go on with little to no interference with
existing page allocation and freeing.

> > Then we can have that one thread just walking
> > through the zone memory pulling out fixed size pieces at a time and
> > providing hints on that. By doing that we avoid the potential of
> > creating a batch of pages that eat up most of the system memory.
> >
> >>         * Pages, captured in the per cpu array are sorted based on the=
 zone numbers. This is to avoid redundancy of acquiring zone locks.
> >>         * Dynamically allocated space is used to hold the isolated gue=
st free pages.
> > I have concerns that doing this per CPU and allocating memory
> > dynamically can result in you losing a significant amount of memory as
> > it sits waiting to be hinted.
> It should not as the buddy will keep merging the pages and we are only
> capturing MAX_ORDER - 1.
> This was the issue with the last patch-series when I was capturing all
> order pages resulting in the per-cpu array to be filled with lower order
> pages.
> >
> >>         * All the pages are reported asynchronously to the host via vi=
rtio driver.
> >>         * Pages are returned back to the guest buddy free list only wh=
en the host response is received.
> > I have been thinking about this. Instead of stealing the page couldn't
> > you simply flag it that there is a hint in progress and simply wait in
> > arch_alloc_page until the hint has been processed?
> With the flag, I am assuming you mean to block the allocation until
> hinting is going on, which is an issue. That was one of the issues
> discussed earlier which I wanted to solve with this implementation.

With the flag we would allow the allocation, but would have to
synchronize with the hinting at that point. I got the idea from the
way the s390 code works. They have both an arch_free_page and an
arch_alloc_page. If I understand correctly the arch_alloc_page is what
is meant to handle the case of a page that has been marked for
hinting, but may not have been hinted on yet. My thought for now is to
keep it simple and use a page flag to indicate that a page is
currently pending a hint. We should be able to spin in such a case and
it would probably still perform better than a solution where we would
not have the memory available and possibly be under memory pressure.

> > The problem is in
> > stealing pages you are going to introduce false OOM issues when the
> > memory isn't available because it is being hinted on.
> I think this situation will arise when the guest is under memory
> pressure. In such situations any attempt to perform isolation will
> anyways fail and we may not be reporting anything at that time.

What I want to avoid is the scenario where an application grabs a
large amount of memory, then frees said memory, and we are sitting on
it for some time because we decide to try and hint on the large chunk.
By processing this sometime after the pages are sent to the buddy
allocator in a separate thread, and by processing a small fixed window
of memory at a time we can avoid making freeing memory expensive, and
still provide the hints in a reasonable time frame.

> >
> >> Pending items:
> >>         * Make sure that the guest free page hinting's current impleme=
ntation doesn't break hugepages or device assigned guests.
> >>         * Follow up on VIRTIO_BALLOON_F_PAGE_POISON's device side supp=
ort. (It is currently missing)
> >>         * Compare reporting free pages via vring with vhost.
> >>         * Decide between MADV_DONTNEED and MADV_FREE.
> >>         * Analyze overall performance impact due to guest free page hi=
nting.
> >>         * Come up with proper/traceable error-message/logs.
> > I'll try applying these patches and see if I can reproduce the results
> > you reported.
> Thanks. Let me know if you run into any issues.
> > With the last patch set I couldn't reproduce the results
> > as you reported them.
> If I remember correctly then the last time you only tried with multiple
> vcpus and not with 1 vcpu.

I had tried 1 vcpu, however I ended up running into some other issues
that made it difficult to even boot the system last week.

> > It has me wondering if you were somehow seeing
> > the effects of a balloon instead of the actual memory hints as I
> > couldn't find any evidence of the memory ever actually being freed
> > back by the hints functionality.
>
> Can you please elaborate what kind of evidence you are looking for?
>
> I did trace the hints on the QEMU/host side.

It looks like the new patches are working as I am seeing the memory
freeing occurring this time around. Although it looks like this is
still generating traces from free_pcpages_bulk if I enable multiple
VCPUs:

[  175.823539] list_add corruption. next->prev should be prev
(ffff947c7ffd61e0), but was ffffc7a29f9e0008. (next=3Dffffc7a29f4c0008).
[  175.825978] ------------[ cut here ]------------
[  175.826889] kernel BUG at lib/list_debug.c:25!
[  175.827766] invalid opcode: 0000 [#1] SMP PTI
[  175.828621] CPU: 5 PID: 1344 Comm: page_fault1_thr Not tainted
5.0.0-next-20190306-baseline+ #76
[  175.830312] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS Bochs 01/01/2011
[  175.831885] RIP: 0010:__list_add_valid+0x35/0x70
[  175.832784] Code: 18 48 8b 32 48 39 f0 75 39 48 39 c7 74 1e 48 39
fa 74 19 b8 01 00 00 00 c3 48 89 c1 48 c7 c7 80 b5 0f a9 31 c0 e8 8f
aa c8 ff <0f> 0b 48 89 c1 48 89 fe 31 c0 48 c7 c7 30 b6 0f a9 e8 79 aa
c8 ff
[  175.836379] RSP: 0018:ffffa717c40839b0 EFLAGS: 00010046
[  175.837394] RAX: 0000000000000075 RBX: ffff947c7ffd61e0 RCX: 00000000000=
00000
[  175.838779] RDX: 0000000000000000 RSI: ffff947c5f957188 RDI: ffff947c5f9=
57188
[  175.840162] RBP: ffff947c7ffd61d0 R08: 000000000000026f R09: 00000000000=
00005
[  175.841539] R10: 0000000000000000 R11: ffffa717c4083730 R12: ffffc7a29f2=
60008
[  175.842932] R13: ffff947c7ffd5d00 R14: ffffc7a29f4c0008 R15: ffffc7a29f2=
60000
[  175.844319] FS:  0000000000000000(0000) GS:ffff947c5f940000(0000)
knlGS:0000000000000000
[  175.845896] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  175.847009] CR2: 00007fffe3421000 CR3: 000000051220e006 CR4: 00000000001=
60ee0
[  175.848390] Call Trace:
[  175.848896]  free_pcppages_bulk+0x4bc/0x6a0
[  175.849723]  free_unref_page_list+0x10d/0x190
[  175.850567]  release_pages+0x103/0x4a0
[  175.851313]  tlb_flush_mmu_free+0x36/0x50
[  175.852105]  unmap_page_range+0x963/0xd50
[  175.852897]  unmap_vmas+0x62/0xc0
[  175.853549]  exit_mmap+0xb5/0x1a0
[  175.854205]  mmput+0x5b/0x120
[  175.854794]  do_exit+0x273/0xc30
[  175.855426]  ? free_unref_page_commit+0x85/0xf0
[  175.856312]  do_group_exit+0x39/0xa0
[  175.857018]  get_signal+0x172/0x7c0
[  175.857703]  do_signal+0x36/0x620
[  175.858355]  ? percpu_counter_add_batch+0x4b/0x60
[  175.859280]  ? __do_munmap+0x288/0x390
[  175.860020]  exit_to_usermode_loop+0x4c/0xa8
[  175.860859]  do_syscall_64+0x152/0x170
[  175.861595]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[  175.862586] RIP: 0033:0x7ffff76a8ec7
[  175.863292] Code: Bad RIP value.
[  175.863928] RSP: 002b:00007ffff4422eb8 EFLAGS: 00000212 ORIG_RAX:
000000000000000b
[  175.865396] RAX: 0000000000000000 RBX: 00007ffff7ff7280 RCX: 00007ffff76=
a8ec7
[  175.866799] RDX: 00007fffe3422000 RSI: 0000000008000000 RDI: 00007fffdb4=
22000
[  175.868194] RBP: 0000000000001000 R08: ffffffffffffffff R09: 00000000000=
00000
[  175.869582] R10: 0000000000000022 R11: 0000000000000212 R12: 00007ffff44=
22fc0
[  175.870984] R13: 0000000000000001 R14: 00007fffffffc1b0 R15: 00007ffff44=
239c0
[  175.872350] Modules linked in: ip6t_rpfilter ip6t_REJECT
nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat
ebtable_broute bridge stp llc ip6table_nat ip6table_mangle
ip6table_raw ip6table_security iptable_nat nf_nat nf_conntrack
nf_defrag_ipv6 nf_defrag_ipv4 iptable_mangle iptable_raw
iptable_security ebtable_filter ebtables ip6table_filter ip6_tables
sunrpc sb_edac crct10dif_pclmul crc32_pclmul ghash_clmulni_intel
kvm_intel kvm ppdev irqbypass parport_pc parport virtio_balloon pcspkr
i2c_piix4 joydev xfs libcrc32c cirrus drm_kms_helper ttm drm e1000
crc32c_intel virtio_blk serio_raw ata_generic floppy pata_acpi
qemu_fw_cfg
[  175.883153] ---[ end trace 5b67f12a67d1f373 ]---

I should be able to rebuild the kernels/qemu and test this patch set
over the next day or two.

Thanks.

- Alex

