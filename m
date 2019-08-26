Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F450C3A59E
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 07:34:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C464206BA
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 07:34:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C464206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F07046B053D; Mon, 26 Aug 2019 03:34:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB6846B053F; Mon, 26 Aug 2019 03:34:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DCCBC6B0540; Mon, 26 Aug 2019 03:34:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0122.hostedemail.com [216.40.44.122])
	by kanga.kvack.org (Postfix) with ESMTP id BCAA16B053D
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 03:34:19 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 69EDD2C8B
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 07:34:19 +0000 (UTC)
X-FDA: 75863765838.30.kite30_7cf3064d8195d
X-HE-Tag: kite30_7cf3064d8195d
X-Filterd-Recvd-Size: 3972
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net [217.70.183.195])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 07:34:18 +0000 (UTC)
X-Originating-IP: 81.250.144.103
Received: from [10.30.1.20] (lneuilly-657-1-5-103.w81-250.abo.wanadoo.fr [81.250.144.103])
	(Authenticated sender: alex@ghiti.fr)
	by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 49BD560003;
	Mon, 26 Aug 2019 07:34:12 +0000 (UTC)
Subject: Re: [PATCH RESEND 0/8] Fix mmap base in bottom-up mmap
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "James E . J . Bottomley" <James.Bottomley@HansenPartnership.com>,
 Helge Deller <deller@gmx.de>, Heiko Carstens <heiko.carstens@de.ibm.com>,
 Vasily Gorbik <gor@linux.ibm.com>,
 Christian Borntraeger <borntraeger@de.ibm.com>,
 Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>,
 "David S . Miller" <davem@davemloft.net>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>,
 x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>,
 Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>,
 linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
 sparclinux@vger.kernel.org, linux-mm@kvack.org
References: <20190620050328.8942-1-alex@ghiti.fr>
From: Alexandre Ghiti <alex@ghiti.fr>
Message-ID: <abc7ed75-0f51-7f21-5a74-d389f968ee55@ghiti.fr>
Date: Mon, 26 Aug 2019 09:34:11 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190620050328.8942-1-alex@ghiti.fr>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: fr
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/20/19 7:03 AM, Alexandre Ghiti wrote:
> This series fixes the fallback of the top-down mmap: in case of
> failure, a bottom-up scheme can be tried as a last resort between
> the top-down mmap base and the stack, hoping for a large unused stack
> limit.
>
> Lots of architectures and even mm code start this fallback
> at TASK_UNMAPPED_BASE, which is useless since the top-down scheme
> already failed on the whole address space: instead, simply use
> mmap_base.
>
> Along the way, it allows to get rid of of mmap_legacy_base and
> mmap_compat_legacy_base from mm_struct.
>
> Note that arm and mips already implement this behaviour.
>
> Alexandre Ghiti (8):
>    s390: Start fallback of top-down mmap at mm->mmap_base
>    sh: Start fallback of top-down mmap at mm->mmap_base
>    sparc: Start fallback of top-down mmap at mm->mmap_base
>    x86, hugetlbpage: Start fallback of top-down mmap at mm->mmap_base
>    mm: Start fallback top-down mmap at mm->mmap_base
>    parisc: Use mmap_base, not mmap_legacy_base, as low_limit for
>      bottom-up mmap
>    x86: Use mmap_*base, not mmap_*legacy_base, as low_limit for bottom-up
>      mmap
>    mm: Remove mmap_legacy_base and mmap_compat_legacy_code fields from
>      mm_struct
>
>   arch/parisc/kernel/sys_parisc.c  |  8 +++-----
>   arch/s390/mm/mmap.c              |  2 +-
>   arch/sh/mm/mmap.c                |  2 +-
>   arch/sparc/kernel/sys_sparc_64.c |  2 +-
>   arch/sparc/mm/hugetlbpage.c      |  2 +-
>   arch/x86/include/asm/elf.h       |  2 +-
>   arch/x86/kernel/sys_x86_64.c     |  4 ++--
>   arch/x86/mm/hugetlbpage.c        |  7 ++++---
>   arch/x86/mm/mmap.c               | 20 +++++++++-----------
>   include/linux/mm_types.h         |  2 --
>   mm/debug.c                       |  4 ++--
>   mm/mmap.c                        |  2 +-
>   12 files changed, 26 insertions(+), 31 deletions(-)
>

Hi everyone,

Any thoughts about that series ? As said before, this is just a 
preparatory patchset in order to
merge x86 mmap top down code with the generic version.

Thanks for taking a look,

Alex


