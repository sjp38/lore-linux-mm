Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id 2801A6B0185
	for <linux-mm@kvack.org>; Tue, 26 May 2015 04:08:22 -0400 (EDT)
Received: by lbbzk7 with SMTP id zk7so64795877lbb.0
        for <linux-mm@kvack.org>; Tue, 26 May 2015 01:08:21 -0700 (PDT)
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com. [209.85.215.50])
        by mx.google.com with ESMTPS id m14si10359794laa.111.2015.05.26.01.08.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 May 2015 01:08:20 -0700 (PDT)
Received: by labbd9 with SMTP id bd9so62128348lab.2
        for <linux-mm@kvack.org>; Tue, 26 May 2015 01:08:20 -0700 (PDT)
Date: Tue, 26 May 2015 10:08:48 +0200
From: Christoffer Dall <christoffer.dall@linaro.org>
Subject: Re: [BUG] Read-Only THP causes stalls (commit 10359213d)
Message-ID: <20150526080848.GA27075@cbox>
References: <20150524193404.GD16910@cbox>
 <20150525141525.GB26958@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150525141525.GB26958@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, ebru.akagunduz@gmail.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kirill.shutemov@linux.intel.com, riel@redhat.com, vbabka@suse.cz, zhangyanfei@cn.fujitsu.com, Will Deacon <will.deacon@arm.com>, Andre Przywara <andre.przywara@arm.com>, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org

Hi Andrea,

On Mon, May 25, 2015 at 04:15:25PM +0200, Andrea Arcangeli wrote:
> Hello Christoffer,
> 
> On Sun, May 24, 2015 at 09:34:04PM +0200, Christoffer Dall wrote:
> > Hi all,
> > 
> > I noticed a regression on my arm64 APM X-Gene system a couple
> > of weeks back.  I would occassionally see the system lock up and see RCU
> > stalls during the caching phase of kernbench.  I then wrote a small
> > script that does nothing but cache the files
> > (http://paste.ubuntu.com/11324767/) and ran that in a loop.  On a known
> > bad commit (v4.1-rc2), out of 25 boots, I never saw it get past 21
> > iterations of the loop.  I have since tried to run a bisect from v3.19 to
> > v4.0 using 100 iterations as my criteria for a good commit.
> > 
> > This resulted in the following first bad commit:
> > 
> > 10359213d05acf804558bda7cc9b8422a828d1cd
> > (mm: incorporate read-only pages into transparent huge pages, 2015-02-11)
> > 
> > Indeed, running the workload on v4.1-rc4 still produced the behavior,
> > but reverting the above commit gets me through 100 iterations of the
> > loop.
> > 
> > I have not tried to reproduce on an x86 system.  Turning on a bunch
> > of kernel debugging features *seems* to hide the problem.  My config for
> > the XGene system is defconfig + CONFIG_BRIDGE and
> > CONFIG_POWER_RESET_XGENE.
> > 
> > Please let me know if I can help test patches or other things I can
> > do to help.  I'm afraid that by simply reading the patch I didn't see
> > anything obviously wrong with it which would cause this behavior.
> 
> As further confirmation, could you try:
> 
> echo 0 > /sys/kernel/mm/transparent_hugepage/khugepaged/pages_to_scan

this returns -EINVAL.

But I'm trying now with:

echo never > /sys/kernel/mm/transparent_hugepage/enabled

> 
> and verify the problem goes away without having to revert the patch?

will let you know, so far so good...

> 
> Accordingly you should reproduce much eaiser this way (setting
> $largevalue to 8192 or something, it doesn't matter).
> 
> echo $largevalue > /sys/kernel/mm/transparent_hugepage/khugepaged/pages_to_scan
> echo 0 > /sys/kernel/mm/transparent_hugepage/khugepaged/alloc_sleep_millisecs
> echo 0 > /sys/kernel/mm/transparent_hugepage/khugepaged/scan_sleep_millisecs
> 
> Then push the system into swap with some memhog -r1000 xG.

what is memhog?  I couldn't find the utility in Google...

I did try with the above settings and just push a bunch of data into
ramfs and tmpfs and indeed the sytem died very quickly (on v4.0-rc4).

> 
> The patch just allows readonly anon pages to be collapsed along with
> read-write ones, the vma permissions allows it, so they have to be
> swapcache pages, this is why swap shall be required.
> 
> Perhaps there's some arch detail that needs fixing but it'll be easier
> to track it down once you have a way to reproduce fast.
> 
Yes, would be great to be able to reproduce quickly.

Thanks,
-Christoffer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
