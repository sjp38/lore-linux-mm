Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 64DFE6B025F
	for <linux-mm@kvack.org>; Sat, 16 Jul 2016 09:55:51 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ez1so139077148pab.0
        for <linux-mm@kvack.org>; Sat, 16 Jul 2016 06:55:51 -0700 (PDT)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0067.outbound.protection.outlook.com. [104.47.40.67])
        by mx.google.com with ESMTPS id fc2si3750799pac.103.2016.07.16.06.55.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 16 Jul 2016 06:55:48 -0700 (PDT)
From: Jens Rottmann <jens.rottmann@adlinktech.com>
Subject: Re: 4.1.28: memory leak introduced by "mm/swap.c: flush lru pvecs on
 compound page arrival"
Date: Sat, 16 Jul 2016 13:55:44 +0000
Message-ID: <BLUPR0501MB208267DA29674B0425D91FDB87340@BLUPR0501MB2082.namprd05.prod.outlook.com>
References: <83d21ffc-eeb8-40f8-7443-8d8291cd5973@ADLINKtech.com>
In-Reply-To: <83d21ffc-eeb8-40f8-7443-8d8291cd5973@ADLINKtech.com>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lukasz Odzioba <lukasz.odzioba@intel.com>, Sasha Levin <sasha.levin@oracle.com>
Cc: "stable@vger.kernel.org" <stable@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi again,

took lack of response to express reluctance examining vendor kernels. There=
fore reproduced and can confirm memory leak on 4.1.28 vanilla x86. Identica=
l symptoms.

Regards,
Jens
________________________________________
From: Jens Rottmann <Jens.Rottmann@ADLINKtech.com>
Sent: Friday, July 15, 2016 21:27
To: Lukasz Odzioba; Sasha Levin
Cc: stable@vger.kernel.org; Michal Hocko; linux-mm@kvack.org; linux-kernel@=
vger.kernel.org
Subject: 4.1.28: memory leak introduced by "mm/swap.c: flush lru pvecs on c=
ompound page arrival"

Hi,

4.1.y stable commit c5ad33184354260be6d05de57e46a5498692f6d6 (Upstream
commit 8f182270dfec432e93fae14f9208a6b9af01009f) "mm/swap.c: flush lru
pvecs on compound page arrival" in 4.1.28 introduces a memory leak.

Simply running

while sleep 0.1; do clear; free; done

shows mem continuously going down, eventually system panics with no
killable processes left. Replacing "sleep" with "unxz -t some.xz" brings
system down within minutes.

Kmemleak did not report anything. Bisect ended at named commit, and
reverting only this commit is indeed sufficient to fix the leak. Swap
partition on/off makes no difference.

My set-up:
i.MX6 (ARM Cortex-A9) dual-core, 2 GB RAM. Kernel sources are from
git.freescale.com i.e. heavily modified by Freescale for i.MX SoCs,
kernel.org stable patches up to 4.1.28 manually added.

I tried to reproduce with vanilla 4.1.28, but that wouldn't boot at all
on my i.MX hardware, hangs immediately after "Starting kernel", sorry.
However there is not a single difference between Freescale and vanilla
in the whole mm/ subdirectory, so I don't think it's i.MX-specific. I
didn't cross-check with an x86 system (yet).

Regards,
Jens

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
