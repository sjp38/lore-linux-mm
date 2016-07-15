Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f197.google.com (mail-ob0-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9DC826B0263
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 15:28:07 -0400 (EDT)
Received: by mail-ob0-f197.google.com with SMTP id wu1so219483908obb.0
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 12:28:07 -0700 (PDT)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0082.outbound.protection.outlook.com. [104.47.34.82])
        by mx.google.com with ESMTPS id x138si8425825oia.164.2016.07.15.12.28.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 15 Jul 2016 12:28:06 -0700 (PDT)
From: Jens Rottmann <Jens.Rottmann@ADLINKtech.com>
Subject: 4.1.28: memory leak introduced by "mm/swap.c: flush lru pvecs on
 compound page arrival"
Message-ID: <83d21ffc-eeb8-40f8-7443-8d8291cd5973@ADLINKtech.com>
Date: Fri, 15 Jul 2016 21:27:55 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lukasz Odzioba <lukasz.odzioba@intel.com>, Sasha Levin <sasha.levin@oracle.com>
Cc: stable@vger.kernel.org, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

4.1.y stable commit c5ad33184354260be6d05de57e46a5498692f6d6 (Upstream
commit 8f182270dfec432e93fae14f9208a6b9af01009f) "mm/swap.c: flush lru
pvecs on compound page arrival" in 4.1.28 introduces a memory leak.

Simply running

while sleep 0.1; do clear; free; done

shows mem continuously going down, eventually system panics with no
killable processes left. Using "unxz -t some.xz" instead of sleep brings
system down within minutes.

Kmemleak did not report anything. Bisect ended at named commit, and
reverting only this commit is indeed sufficient to fix the leak. Swap
partition on/off makes no difference.

My set-up:
i.MX6 (ARM Cortex-A9) dual-core, 2 GB RAM. Kernel sources are from
git.freescale.com i.e. heavily modified by Freescale for i.MX SoCs,
kernel.org stable patches up to 4.1.28 manually added.

I tried to reproduce with vanilla 4.1.28, but that wouldn't boot at all
on my hardware, hangs immediately after "Starting kernel", sorry.
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
