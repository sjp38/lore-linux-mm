Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D07EC43218
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 13:02:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D04D20896
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 13:02:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D04D20896
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 984766B000A; Tue, 11 Jun 2019 09:02:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9352A6B000C; Tue, 11 Jun 2019 09:02:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7FE056B000D; Tue, 11 Jun 2019 09:02:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 33C086B000A
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 09:02:40 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d27so20643234eda.9
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 06:02:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=4DMyWe2oS37T3mS0ayCrmcIxFZr5kIKtudbXOZJI9Hk=;
        b=Wdnsnh+f+x3UHnp3K5gdIDXytp7X78qjJ+HHUlbkrGmimN9G7iMHkoyUxZyExsJBYX
         iLiGDba6gP/DtQLGNSuYBP6Amz7GIofA/aqAkVX1FYJVZCcoTbYM5EnnPSuXtCNuJNVr
         MmzVBPyYeNT5Xj6aCnm8Ez1wwRVdQ6VSSHdSj8LAE5o0PAQtNMMak+KLvEWuOc4LsIaF
         sBKrcAiSBLSlYShCxfM1/Twu3a43VrXoFaHwT8e6O/7bJDy4m2GHRbeJYKe07sJqW4dX
         /S8Y1DYbdqJ8LfGaw7SF68xJYH6bt0KwZ8IabW/WWM0QyJD2kqLKUbxSem0NX830i0Eg
         30BQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAXn7Z5XE2KjQvZZFr29a9g2VPVWQdqGyief3fvGheFVB7bOFeev
	8CC+clYrFKbQvVDDnXHA8LBxcBcz85miDkWTi1wo6bXxMXGmKlNFLzMSXWf1aJrOwGJ5AOvLlKe
	40aq6yyVMeMgKtCEvGwkbn1w7GWqVYRj0QC47WUHIT9WOCspuKhkp9uQjwLlOWKFCvQ==
X-Received: by 2002:a17:906:5048:: with SMTP id e8mr64812618ejk.91.1560258159719;
        Tue, 11 Jun 2019 06:02:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxGXuazBrWFgaFi3bwDP9M/8cxpAVXruIYYAXY6mJc19uohunn2+kn9Xb//5NrT0qfAODti
X-Received: by 2002:a17:906:5048:: with SMTP id e8mr64812528ejk.91.1560258158710;
        Tue, 11 Jun 2019 06:02:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560258158; cv=none;
        d=google.com; s=arc-20160816;
        b=NhdS0aDpVxqasa7sWqHsbmNMvj6B4Ha1HAvJqmF0FEIr358cbfTcBhPBTACAwatuz8
         1MtAiw/JU52OJW82PTZxVdVyzvTbhuPDN8GqHOH8Xl2HVIRMF/O2DR3p1r6aVe58JMkn
         5pespiTi9PYIdkCZaT7/Ho1c2L99W6jddQtsbexLJWLujij84UmMMZhp1PVXKhn7ixVv
         BEujT0OxHTzFtEeYnza1aBU7ygWm4N2S1uuJR9eosB/rk40erl0+QMHgU4hKEhH3p5kT
         x3NixWtDcC/78c8fSVjU+mf4odV7ZkcIvX6LGTO1U0A1qfSVSeKubbSFiOBLSaaahwcY
         bbMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=4DMyWe2oS37T3mS0ayCrmcIxFZr5kIKtudbXOZJI9Hk=;
        b=yyOUeBURl1kpwIbBylY/m4s4dt6JNsXWIyXRuqU1hYNlvIXdE+HXaSEuhjZzA9vFW5
         JC7QiwGNlfK46Z3DBhzLj07VfxC9ChOKbEJSmhyejO+RRkUgciEDUqJkE8ulSqbYfSSc
         kBnTOue3gVi0H7f5hLgmJKSVPeVkP76ccQ8LeLrE7J3qXImH/+B+cm2x3okPpyggoyh0
         3RsEZzIoKTsTMf7TC8MGl1MyDk5ZWxI1TPt65IMGZxSnfTD0QR5MWrfOpAvNSLLY0AnS
         NHD209Hi90I8bmBgANYl1nbOwHT5zi2D91V2y1QpBVWSDWNMW9XbB+GeW7OzeZNTqIE6
         KoFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id q4si3416197ejj.280.2019.06.11.06.02.38
        for <linux-mm@kvack.org>;
        Tue, 11 Jun 2019 06:02:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 9E8EE344;
	Tue, 11 Jun 2019 06:02:37 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 0D24B3F557;
	Tue, 11 Jun 2019 06:02:35 -0700 (PDT)
Date: Tue, 11 Jun 2019 14:02:33 +0100
From: Mark Rutland <mark.rutland@arm.com>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Qian Cai <cai@lca.pw>, Will Deacon <will.deacon@arm.com>,
	akpm@linux-foundation.org, catalin.marinas@arm.com,
	linux-kernel@vger.kernel.org, mhocko@kernel.org, linux-mm@kvack.org,
	vdavydov.dev@gmail.com, hannes@cmpxchg.org, cgroups@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
Subject: Re: [PATCH -next] arm64/mm: fix a bogus GFP flag in pgd_alloc()
Message-ID: <20190611130233.GD29008@lakrids.cambridge.arm.com>
References: <1559656836-24940-1-git-send-email-cai@lca.pw>
 <20190604142338.GC24467@lakrids.cambridge.arm.com>
 <20190610114326.GF15979@fuggles.cambridge.arm.com>
 <1560187575.6132.70.camel@lca.pw>
 <20190611100348.GB26409@lakrids.cambridge.arm.com>
 <20190611124118.GA4761@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190611124118.GA4761@rapoport-lnx>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 03:41:19PM +0300, Mike Rapoport wrote:
> On Tue, Jun 11, 2019 at 11:03:49AM +0100, Mark Rutland wrote:
> > On Mon, Jun 10, 2019 at 01:26:15PM -0400, Qian Cai wrote:
> > > On Mon, 2019-06-10 at 12:43 +0100, Will Deacon wrote:
> > > > On Tue, Jun 04, 2019 at 03:23:38PM +0100, Mark Rutland wrote:
> > > > > On Tue, Jun 04, 2019 at 10:00:36AM -0400, Qian Cai wrote:
> > > > > > The commit "arm64: switch to generic version of pte allocation"
> > > > > > introduced endless failures during boot like,
> > > > > > 
> > > > > > kobject_add_internal failed for pgd_cache(285:chronyd.service) (error:
> > > > > > -2 parent: cgroup)
> > > > > > 
> > > > > > It turns out __GFP_ACCOUNT is passed to kernel page table allocations
> > > > > > and then later memcg finds out those don't belong to any cgroup.
> > > > > 
> > > > > Mike, I understood from [1] that this wasn't expected to be a problem,
> > > > > as the accounting should bypass kernel threads.
> > > > > 
> > > > > Was that assumption wrong, or is something different happening here?
> > > > > 
> > > > > > 
> > > > > > backtrace:
> > > > > >   kobject_add_internal
> > > > > >   kobject_init_and_add
> > > > > >   sysfs_slab_add+0x1a8
> > > > > >   __kmem_cache_create
> > > > > >   create_cache
> > > > > >   memcg_create_kmem_cache
> > > > > >   memcg_kmem_cache_create_func
> > > > > >   process_one_work
> > > > > >   worker_thread
> > > > > >   kthread
> > > > > > 
> > > > > > Signed-off-by: Qian Cai <cai@lca.pw>
> > > > > > ---
> > > > > >  arch/arm64/mm/pgd.c | 2 +-
> > > > > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > > > > 
> > > > > > diff --git a/arch/arm64/mm/pgd.c b/arch/arm64/mm/pgd.c
> > > > > > index 769516cb6677..53c48f5c8765 100644
> > > > > > --- a/arch/arm64/mm/pgd.c
> > > > > > +++ b/arch/arm64/mm/pgd.c
> > > > > > @@ -38,7 +38,7 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
> > > > > >  	if (PGD_SIZE == PAGE_SIZE)
> > > > > >  		return (pgd_t *)__get_free_page(gfp);
> > > > > >  	else
> > > > > > -		return kmem_cache_alloc(pgd_cache, gfp);
> > > > > > +		return kmem_cache_alloc(pgd_cache, GFP_PGTABLE_KERNEL);
> > > > > 
> > > > > This is used to allocate PGDs for both user and kernel pagetables (e.g.
> > > > > for the efi runtime services), so while this may fix the regression, I'm
> > > > > not sure it's the right fix.
> > > > > 
> > > > > Do we need a separate pgd_alloc_kernel()?
> > > > 
> > > > So can I take the above for -rc5, or is somebody else working on a different
> > > > fix to implement pgd_alloc_kernel()?
> > > 
> > > The offensive commit "arm64: switch to generic version of pte allocation" is not
> > > yet in the mainline, but only in the Andrew's tree and linux-next, and I doubt
> > > Andrew will push this out any time sooner given it is broken.
> > 
> > I'd assumed that Mike would respin these patches to implement and use
> > pgd_alloc_kernel() (or take gfp flags) and the updated patches would
> > replace these in akpm's tree.
> > 
> > Mike, could you confirm what your plan is? I'm happy to review/test
> > updated patches for arm64.
> 
> Sorry for the delay, I'm mostly offline these days.
> 
> I wanted to understand first what is the reason for the failure. I've tried
> to reproduce it with qemu, but I failed to find a bootable configuration
> that will have PGD_SIZE != PAGE_SIZE :(

This is the case with 48-bit VA and 64K pages. In that case we have
three levels of table, and the PGD is 1/16th of a page, as it only needs
to resolve 9 bits of virtual address rather than 13.

If you build defconfig + ARM64_64K_PAGES=y, that should be the case:

[mark@lakrids:~/src/linux]% usekorg 8.1.0 aarch64-linux-objdump -d arch/arm64/mm/pgd.o     

arch/arm64/mm/pgd.o:     file format elf64-littleaarch64


Disassembly of section .text:

0000000000000000 <pgd_alloc>:
   0:   a9bf7bfd        stp     x29, x30, [sp, #-16]!
   4:   90000000        adrp    x0, 0 <pgd_alloc>
   8:   5281b801        mov     w1, #0xdc0                      // #3520
   c:   910003fd        mov     x29, sp
  10:   f9400000        ldr     x0, [x0]
  14:   94000000        bl      0 <kmem_cache_alloc>
  18:   a8c17bfd        ldp     x29, x30, [sp], #16
  1c:   d65f03c0        ret

0000000000000020 <pgd_free>:
  20:   a9bf7bfd        stp     x29, x30, [sp, #-16]!
  24:   90000000        adrp    x0, 0 <pgd_alloc>
  28:   910003fd        mov     x29, sp
  2c:   f9400000        ldr     x0, [x0]
  30:   94000000        bl      0 <kmem_cache_free>
  34:   a8c17bfd        ldp     x29, x30, [sp], #16
  38:   d65f03c0        ret

Disassembly of section .init.text:

0000000000000000 <pgd_cache_init>:
   0:   a9bf7bfd        stp     x29, x30, [sp, #-16]!
   4:   52804002        mov     w2, #0x200                      // #512
   8:   d2800004        mov     x4, #0x0                        // #0
   c:   910003fd        mov     x29, sp
  10:   2a0203e1        mov     w1, w2
  14:   52a00083        mov     w3, #0x40000                    // #262144
  18:   90000000        adrp    x0, 0 <pgd_cache_init>
  1c:   91000000        add     x0, x0, #0x0
  20:   94000000        bl      0 <kmem_cache_create>
  24:   90000001        adrp    x1, 0 <pgd_cache_init>
  28:   a8c17bfd        ldp     x29, x30, [sp], #16
  2c:   f9000020        str     x0, [x1]
  30:   d65f03c0        ret

Thanks,
Mark.

