Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 80DD46B0007
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 07:56:56 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id d11-v6so20152143iok.21
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 04:56:56 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id p11-v6si17789287iog.104.2018.07.16.04.56.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 04:56:55 -0700 (PDT)
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w6GBs45B113234
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 11:56:54 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp2130.oracle.com with ESMTP id 2k7a3sv2s3-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 11:56:54 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w6GBurnA027052
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 11:56:54 GMT
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w6GBurJJ014519
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 11:56:53 GMT
Received: by mail-oi0-f42.google.com with SMTP id l10-v6so27518405oii.0
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 04:56:53 -0700 (PDT)
MIME-Version: 1.0
References: <5b4a9633.1c69fb81.17984.f7b3@mx.google.com> <0ab16066-5498-374b-5391-3dd7979044aa@collabora.com>
 <20180716105451.GA20734@sirena.org.uk> <20180716110208.GA25227@kroah.com>
In-Reply-To: <20180716110208.GA25227@kroah.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Mon, 16 Jul 2018 07:56:08 -0400
Message-ID: <CAGM2reY7RDLKR3vyr9bne3kVo58qn_F58oYHtUZaA0BChzsQGw@mail.gmail.com>
Subject: Re: mainline/master boot: 177 boots: 2 failed, 174 passed with 1
 conflict (v4.18-rc4-160-gf353078f028f)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org
Cc: broonie@kernel.org, guillaume.tucker@collabora.com, Linux Memory Management List <linux-mm@kvack.org>, kernel@collabora.com, LKML <linux-kernel@vger.kernel.org>, stable@vger.kernel.org, kernel-build-reports@lists.linaro.org

I have reproduced the problem on mainline. Use x86_32 defcontig +
qemu, and problem is reproduced immediately.  I will send an update
once I figure out what is going on.

Pavel
On Mon, Jul 16, 2018 at 7:02 AM Greg Kroah-Hartman
<gregkh@linuxfoundation.org> wrote:
>
> On Mon, Jul 16, 2018 at 11:54:51AM +0100, Mark Brown wrote:
> > On Mon, Jul 16, 2018 at 11:40:06AM +0100, Guillaume Tucker wrote:
> > > On 15/07/18 01:32, kernelci.org bot wrote:
> > > > mainline/master boot: 177 boots: 2 failed, 174 passed with 1 conflict (v4.18-rc4-160-gf353078f028f)
> > > >
> > > > Full Boot Summary: https://kernelci.org/boot/all/job/mainline/branch/master/kernel/v4.18-rc4-160-gf353078f028f/
> > > > Full Build Summary: https://kernelci.org/build/mainline/branch/master/kernel/v4.18-rc4-160-gf353078f028f/
> > > >
> > > > Tree: mainline
> > > > Branch: master
> > > > Git Describe: v4.18-rc4-160-gf353078f028f
> > > > Git Commit: f353078f028fbfe9acd4b747b4a19c69ef6846cd
> > > > Git URL: http://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
> > > > Tested: 67 unique boards, 25 SoC families, 21 builds out of 199
> > > >
> > > > Boot Regressions Detected:
> > > [...]
> > > > x86:
> > > >
> > > >      i386_defconfig:
> > > >          x86-celeron:
> > > >              lab-mhart: new failure (last pass: v4.18-rc4-147-g2db39a2f491a)
> > > >          x86-pentium4:
> > > >              lab-mhart: new failure (last pass: v4.18-rc4-147-g2db39a2f491a)
> > >
> > > Please see below an automated bisection report for this
> > > regression.  Several bisections were run on other x86 platforms
> > > with i386_defconfig on a few revisions up to v4.18-rc5, they all
> > > reached the same "bad" commit.
> > >
> > >
> > > Unfortunately there isn't much to learn from the kernelci.org
> > > boot logs as the kernel seems to crash very early on:
> > >
> > >     https://kernelci.org/boot/all/job/mainline/branch/master/kernel/v4.18-rc5/
> > >     https://storage.kernelci.org/mainline/master/v4.18-rc4-160-gf353078f028f/x86/i386_defconfig/lab-mhart/lava-x86-celeron.html
> > >
> > >
> > > It looks like stable-rc/linux-4.17.y is also broken with
> > > i386_defconfig, which tends to confirm the "bad" commit found by
> > > the automated bisection which was applied there as well:
> > >
> > >     https://kernelci.org/boot/all/job/stable-rc/branch/linux-4.17.y/kernel/v4.17.6-68-gbc0bd9e05fa1/
> >
> > Adding Greg directly to the CCs due to the stable impact, not deleting
> > context for his benefit.
>
> Hey, I read all stable emails, who else would?  :)
>
> > > The automated bisection on kernelci.org is still quite new, so
> > > please take the results with a pinch of salt as the "bad" commit
> > > found may not be the actual root cause of the boot failure.
> > >
> > > Hope this helps!
> > >
> > > Best wishes,
> > > Guillaume
> > >
> > >
> > > --------------------------------------8<--------------------------------------
> > >
> > >
> > >
> > > Bisection result for mainline/master (v4.18-rc4-160-gf353078f028f) on x86-celeron
> > >
> > >   Good:       2db39a2f491a Merge branch 'i2c/for-current' of git://git.kernel.org/pub/scm/linux/kernel/git/wsa/linux
> > >   Bad:        f353078f028f Merge branch 'akpm' (patches from Andrew)
> > >   Found:      e181ae0c5db9 mm: zero unavailable pages before memmap init
> > >
> > > Checks:
> > >   revert:     PASS
> > >   verify:     PASS
> > >
> > > Parameters:
> > >   Tree:       mainline
> > >   URL:        http://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
> > >   Branch:     master
> > >   Target:     x86-celeron
> > >   Lab:        lab-mhart
> > >   Config:     i386_defconfig
> > >   Plan:       boot
> > >
> > > Breaking commit found:
> > >
> > > -------------------------------------------------------------------------------
> > > commit e181ae0c5db9544de9c53239eb22bc012ce75033
> > > Author: Pavel Tatashin <pasha.tatashin@oracle.com>
> > > Date:   Sat Jul 14 09:15:07 2018 -0400
> > >
> > >     mm: zero unavailable pages before memmap init
> > >     We must zero struct pages for memory that is not backed by physical
> > >     memory, or kernel does not have access to.
> > >     Recently, there was a change which zeroed all memmap for all holes in
> > >     e820.  Unfortunately, it introduced a bug that is discussed here:
> > >       https://www.spinics.net/lists/linux-mm/msg156764.html
> > >     Linus, also saw this bug on his machine, and confirmed that reverting
> > >     commit 124049decbb1 ("x86/e820: put !E820_TYPE_RAM regions into
> > >     memblock.reserved") fixes the issue.
> > >     The problem is that we incorrectly zero some struct pages after they
> > >     were setup.
> > >     The fix is to zero unavailable struct pages prior to initializing of
> > >     struct pages.
> > >     A more detailed fix should come later that would avoid double zeroing
> > >     cases: one in __init_single_page(), the other one in
> > >     zero_resv_unavail().
> > >     Fixes: 124049decbb1 ("x86/e820: put !E820_TYPE_RAM regions into memblock.reserved")
> > >     Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> > >     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> > >
> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > index 1521100f1e63..5d800d61ddb7 100644
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -6847,6 +6847,7 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
> > >     /* Initialise every node */
> > >     mminit_verify_pageflags_layout();
> > >     setup_nr_node_ids();
> > > +   zero_resv_unavail();
> > >     for_each_online_node(nid) {
> > >             pg_data_t *pgdat = NODE_DATA(nid);
> > >             free_area_init_node(nid, NULL,
> > > @@ -6857,7 +6858,6 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
> > >                     node_set_state(nid, N_MEMORY);
> > >             check_for_memory(pgdat, nid);
> > >     }
> > > -   zero_resv_unavail();
> > >  }
> > >  static int __init cmdline_parse_core(char *p, unsigned long *core,
> > > @@ -7033,9 +7033,9 @@ void __init set_dma_reserve(unsigned long new_dma_reserve)
> > >  void __init free_area_init(unsigned long *zones_size)
> > >  {
> > > +   zero_resv_unavail();
> > >     free_area_init_node(0, zones_size,
> > >                     __pa(PAGE_OFFSET) >> PAGE_SHIFT, NULL);
> > > -   zero_resv_unavail();
> > >  }
> > >  static int page_alloc_cpu_dead(unsigned int cpu)
> > > -------------------------------------------------------------------------------
>
> So this patch breaks i386, ick.  I'll wait for the fix to hit Linus's
> tree as that's a bit more important to have the large majority of the
> x86-64 boxes fixed with this patch for now.
>
> thanks,
>
> greg k-h
>
