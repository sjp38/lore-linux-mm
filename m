Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 19F976B00AC
	for <linux-mm@kvack.org>; Mon, 25 May 2015 06:19:20 -0400 (EDT)
Received: by labbd9 with SMTP id bd9so46781902lab.2
        for <linux-mm@kvack.org>; Mon, 25 May 2015 03:19:19 -0700 (PDT)
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com. [209.85.215.46])
        by mx.google.com with ESMTPS id lp10si5509418lbb.1.2015.05.25.03.19.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 May 2015 03:19:18 -0700 (PDT)
Received: by labbd9 with SMTP id bd9so46781499lab.2
        for <linux-mm@kvack.org>; Mon, 25 May 2015 03:19:17 -0700 (PDT)
Date: Mon, 25 May 2015 12:19:44 +0200
From: Christoffer Dall <christoffer.dall@linaro.org>
Subject: Re: [BUG] Read-Only THP causes stalls (commit 10359213d)
Message-ID: <20150525101944.GA14095@cbox>
References: <20150524193404.GD16910@cbox>
 <20150525100515.GA8275@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150525100515.GA8275@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, ebru.akagunduz@gmail.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kirill.shutemov@linux.intel.com, riel@redhat.com, vbabka@suse.cz, zhangyanfei@cn.fujitsu.com, aarcange@redhat.com, Will Deacon <will.deacon@arm.com>, Andre Przywara <andre.przywara@arm.com>, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org

On Mon, May 25, 2015 at 01:05:15PM +0300, Kirill A. Shutemov wrote:
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
> I don't see the problem on x86.

I'm wondering if we could have some weird combination of how the
specific architecture works along with these patches...

> 
> Some backtraces could help to track it down.
> 
I don't really get backtraces as the sytem just locks up.  But here are
some of the RCU stalls as I've observed them on the console:

http://paste.ubuntu.com/11014701/
http://paste.ubuntu.com/11023143/
http://paste.ubuntu.com/11023261/


Occasionally, I also get this error from the SATA system at the moment
when I power off the device, but not sure if it is related:

  ata1: exception Emask 0x10 SAct 0x0 SErr 0x180000 action 0xe frozen
  ata1: irq_stat 0x00400000, PHY RDY changed
  ata1: SError: { 10B8B Dispar }

Thanks,
-Christoffer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
