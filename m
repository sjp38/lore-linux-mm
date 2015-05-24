Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id 5CE1D6B00D8
	for <linux-mm@kvack.org>; Sun, 24 May 2015 15:33:40 -0400 (EDT)
Received: by lbbuc2 with SMTP id uc2so40688166lbb.2
        for <linux-mm@kvack.org>; Sun, 24 May 2015 12:33:39 -0700 (PDT)
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com. [209.85.215.54])
        by mx.google.com with ESMTPS id d4si6629350lbb.6.2015.05.24.12.33.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 May 2015 12:33:38 -0700 (PDT)
Received: by labbd9 with SMTP id bd9so38710204lab.2
        for <linux-mm@kvack.org>; Sun, 24 May 2015 12:33:37 -0700 (PDT)
Date: Sun, 24 May 2015 21:34:04 +0200
From: Christoffer Dall <christoffer.dall@linaro.org>
Subject: [BUG] Read-Only THP causes stalls (commit 10359213d)
Message-ID: <20150524193404.GD16910@cbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, ebru.akagunduz@gmail.com
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kirill.shutemov@linux.intel.com, riel@redhat.com, vbabka@suse.cz, zhangyanfei@cn.fujitsu.com, aarcange@redhat.com, Will Deacon <will.deacon@arm.com>, Andre Przywara <andre.przywara@arm.com>, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org

Hi all,

I noticed a regression on my arm64 APM X-Gene system a couple
of weeks back.  I would occassionally see the system lock up and see RCU
stalls during the caching phase of kernbench.  I then wrote a small
script that does nothing but cache the files
(http://paste.ubuntu.com/11324767/) and ran that in a loop.  On a known
bad commit (v4.1-rc2), out of 25 boots, I never saw it get past 21
iterations of the loop.  I have since tried to run a bisect from v3.19 to
v4.0 using 100 iterations as my criteria for a good commit.

This resulted in the following first bad commit:

10359213d05acf804558bda7cc9b8422a828d1cd
(mm: incorporate read-only pages into transparent huge pages, 2015-02-11)

Indeed, running the workload on v4.1-rc4 still produced the behavior,
but reverting the above commit gets me through 100 iterations of the
loop.

I have not tried to reproduce on an x86 system.  Turning on a bunch
of kernel debugging features *seems* to hide the problem.  My config for
the XGene system is defconfig + CONFIG_BRIDGE and
CONFIG_POWER_RESET_XGENE.

Please let me know if I can help test patches or other things I can
do to help.  I'm afraid that by simply reading the patch I didn't see
anything obviously wrong with it which would cause this behavior.

Thanks,
-Christoffer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
