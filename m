Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id 9B7376B0032
	for <linux-mm@kvack.org>; Mon, 25 May 2015 10:16:00 -0400 (EDT)
Received: by qkdn188 with SMTP id n188so65498009qkd.2
        for <linux-mm@kvack.org>; Mon, 25 May 2015 07:16:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p74si11421298qha.68.2015.05.25.07.15.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 May 2015 07:15:59 -0700 (PDT)
Date: Mon, 25 May 2015 16:15:25 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [BUG] Read-Only THP causes stalls (commit 10359213d)
Message-ID: <20150525141525.GB26958@redhat.com>
References: <20150524193404.GD16910@cbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150524193404.GD16910@cbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoffer Dall <christoffer.dall@linaro.org>
Cc: linux-mm@kvack.org, ebru.akagunduz@gmail.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kirill.shutemov@linux.intel.com, riel@redhat.com, vbabka@suse.cz, zhangyanfei@cn.fujitsu.com, Will Deacon <will.deacon@arm.com>, Andre Przywara <andre.przywara@arm.com>, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org

Hello Christoffer,

On Sun, May 24, 2015 at 09:34:04PM +0200, Christoffer Dall wrote:
> Hi all,
> 
> I noticed a regression on my arm64 APM X-Gene system a couple
> of weeks back.  I would occassionally see the system lock up and see RCU
> stalls during the caching phase of kernbench.  I then wrote a small
> script that does nothing but cache the files
> (http://paste.ubuntu.com/11324767/) and ran that in a loop.  On a known
> bad commit (v4.1-rc2), out of 25 boots, I never saw it get past 21
> iterations of the loop.  I have since tried to run a bisect from v3.19 to
> v4.0 using 100 iterations as my criteria for a good commit.
> 
> This resulted in the following first bad commit:
> 
> 10359213d05acf804558bda7cc9b8422a828d1cd
> (mm: incorporate read-only pages into transparent huge pages, 2015-02-11)
> 
> Indeed, running the workload on v4.1-rc4 still produced the behavior,
> but reverting the above commit gets me through 100 iterations of the
> loop.
> 
> I have not tried to reproduce on an x86 system.  Turning on a bunch
> of kernel debugging features *seems* to hide the problem.  My config for
> the XGene system is defconfig + CONFIG_BRIDGE and
> CONFIG_POWER_RESET_XGENE.
> 
> Please let me know if I can help test patches or other things I can
> do to help.  I'm afraid that by simply reading the patch I didn't see
> anything obviously wrong with it which would cause this behavior.

As further confirmation, could you try:

echo 0 > /sys/kernel/mm/transparent_hugepage/khugepaged/pages_to_scan

and verify the problem goes away without having to revert the patch?

Accordingly you should reproduce much eaiser this way (setting
$largevalue to 8192 or something, it doesn't matter).

echo $largevalue > /sys/kernel/mm/transparent_hugepage/khugepaged/pages_to_scan
echo 0 > /sys/kernel/mm/transparent_hugepage/khugepaged/alloc_sleep_millisecs
echo 0 > /sys/kernel/mm/transparent_hugepage/khugepaged/scan_sleep_millisecs

Then push the system into swap with some memhog -r1000 xG.

The patch just allows readonly anon pages to be collapsed along with
read-write ones, the vma permissions allows it, so they have to be
swapcache pages, this is why swap shall be required.

Perhaps there's some arch detail that needs fixing but it'll be easier
to track it down once you have a way to reproduce fast.

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
