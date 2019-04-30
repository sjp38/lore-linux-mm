Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27DDCC04AA6
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 11:16:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D762D2080C
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 11:16:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D762D2080C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6AB2C6B0003; Tue, 30 Apr 2019 07:16:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6818D6B000C; Tue, 30 Apr 2019 07:16:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 59A216B000E; Tue, 30 Apr 2019 07:16:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0E8986B0003
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 07:16:35 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id x16so3659954edm.16
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 04:16:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=fydu+6qYHerO1cPr92MYvYdO9B7wxgm+yhBMcZrMeDY=;
        b=bSUIjBSjx/tOlDra1w9r49qwYhxyDCO2YsUYxO7T0D8lm7xssWpoBdPvbVHAEgpKzw
         d/cm34ycr5Skfk3doxIAXTcvom3Nan//b086UKkRmbWqDX8OQwpnuB0G/hLiE/Y1a508
         NAr02+g3uznPQTpguRd7wCdv7yV6fFGo5nRA9oLzQvtNa+fK+qlsVvhRpBAnr+GvM21P
         iUILOPAyHSa9ouLufBj0vK4h6OuHeVe3I+C+6KK2ClAuGaVctzjJDzZ4yw8R9ztyCO+1
         Jk7JArZTlzFQdndqdN5boroJoSZ5GS98Sc8oJEIFXH97c8Qz65Hrr0lVj5aIWsu04qeM
         7D+w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAWmkR26Rw0e5kVlwHeZfMMKtq9ylnzGc1v/jeU2fEbb/EEAtlRI
	qjfT7078HdEyyQwA4S1lR6Dcualo10ctvyJRud9bq7D04n+MLE0LYnl6xU6Yjver0lr4dEzAcnv
	/p5oh6dhX8SE0adpnetHIoldUOD4wZo9D4rllIUb1Mfw6sT/v/QpyWf5MLLEPmturmw==
X-Received: by 2002:a17:906:6dc1:: with SMTP id j1mr896131ejt.90.1556622994615;
        Tue, 30 Apr 2019 04:16:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyoRld76/9adKP4Rl1zUPNj1jvE98STUfDMWVYEZznCyjZTVDfDNJ2xeS8FHQ+fxco61ylO
X-Received: by 2002:a17:906:6dc1:: with SMTP id j1mr896086ejt.90.1556622993575;
        Tue, 30 Apr 2019 04:16:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556622993; cv=none;
        d=google.com; s=arc-20160816;
        b=suEGSh68hF/ItlEfJCYZR092a4CPtgQjAneow+sY8Ythn70+0NblDcsBCiLXLR9b/x
         ogxJUWBAGDE2piITFSmX3XO+86B5KbtXYUOlyZ/4E49OwjdjT7I2n/c7DC3zDc7EqyYI
         8qIU0y0ASDBi3gSBWyEvYh2Vko1jQfr+UtGHKIF6+JH3qpqkPN5fGGHvtJqoowmR+J1m
         s6fVO2Q0Evw2vamL3uaHM1Pe6s/1FRU4NnEdOkDUcnEp1QyqBB7tUmrFig3BCYjONxoC
         9PIQ5iQMsBoxObv68FyBNCIoojilFCX8Xu1kibshpzshzD+uEmpLSvtiwAZ6jz0ZmyTs
         b0Yw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=fydu+6qYHerO1cPr92MYvYdO9B7wxgm+yhBMcZrMeDY=;
        b=cdEzqpS8ATHk3/VmMzmZfsxMG1CHlMcKMgfKUcwM76OdDD4gqB8MWP7vKy9Asc7wzG
         /gci6b2XyGNziSOQel2O7o4bBHoqz0+BcQfIwo+w1vPAjgWlEU5HIRquiTptZcLRr+JE
         SB0HYtu5UtvI9waHa2zNf78pXvjqIdO5wd5D3pgaj/k8gqDrWNbyWNLrPPdMzDwoKj1z
         FJDtae6M9ZZa4Pkdj8LifM1VTYFDvTJIMCR6vnXMiMhsBhDMfCFm8u/9fagV/yN0TYu1
         rinFnZQZgSpItMBnt2O2SqB/7OeDgK0jr8+ccSJEy6aFhFXQD9efpbIVUAfs74yn/WWn
         +/2g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a2si16946678edf.93.2019.04.30.04.16.33
        for <linux-mm@kvack.org>;
        Tue, 30 Apr 2019 04:16:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 3C20380D;
	Tue, 30 Apr 2019 04:16:32 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id E981E3F5C1;
	Tue, 30 Apr 2019 04:16:27 -0700 (PDT)
Date: Tue, 30 Apr 2019 12:16:25 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Leon Romanovsky <leon@kernel.org>
Cc: Andrey Konovalov <andreyknvl@google.com>,
	Will Deacon <will.deacon@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Yishai Hadas <yishaih@mellanox.com>,
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v13 16/20] IB/mlx4, arm64: untag user pointers in
 mlx4_get_umem_mr
Message-ID: <20190430111625.GD29799@arrakis.emea.arm.com>
References: <cover.1553093420.git.andreyknvl@google.com>
 <1e2824fd77e8eeb351c6c6246f384d0d89fd2d58.1553093421.git.andreyknvl@google.com>
 <20190429180915.GZ6705@mtr-leonro.mtl.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190429180915.GZ6705@mtr-leonro.mtl.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

(trimmed down the cc list slightly as the message bounces)

On Mon, Apr 29, 2019 at 09:09:15PM +0300, Leon Romanovsky wrote:
> On Wed, Mar 20, 2019 at 03:51:30PM +0100, Andrey Konovalov wrote:
> > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > pass tagged user pointers (with the top byte set to something else other
> > than 0x00) as syscall arguments.
> >
> > mlx4_get_umem_mr() uses provided user pointers for vma lookups, which can
> > only by done with untagged pointers.
> >
> > Untag user pointers in this function.
> >
> > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > ---
> >  drivers/infiniband/hw/mlx4/mr.c | 7 ++++---
> >  1 file changed, 4 insertions(+), 3 deletions(-)
> >
> > diff --git a/drivers/infiniband/hw/mlx4/mr.c b/drivers/infiniband/hw/mlx4/mr.c
> > index 395379a480cb..9a35ed2c6a6f 100644
> > --- a/drivers/infiniband/hw/mlx4/mr.c
> > +++ b/drivers/infiniband/hw/mlx4/mr.c
> > @@ -378,6 +378,7 @@ static struct ib_umem *mlx4_get_umem_mr(struct ib_udata *udata, u64 start,
> >  	 * again
> >  	 */
> >  	if (!ib_access_writable(access_flags)) {
> > +		unsigned long untagged_start = untagged_addr(start);
> >  		struct vm_area_struct *vma;
> >
> >  		down_read(&current->mm->mmap_sem);
> > @@ -386,9 +387,9 @@ static struct ib_umem *mlx4_get_umem_mr(struct ib_udata *udata, u64 start,
> >  		 * cover the memory, but for now it requires a single vma to
> >  		 * entirely cover the MR to support RO mappings.
> >  		 */
> > -		vma = find_vma(current->mm, start);
> > -		if (vma && vma->vm_end >= start + length &&
> > -		    vma->vm_start <= start) {
> > +		vma = find_vma(current->mm, untagged_start);
> > +		if (vma && vma->vm_end >= untagged_start + length &&
> > +		    vma->vm_start <= untagged_start) {
> >  			if (vma->vm_flags & VM_WRITE)
> >  				access_flags |= IB_ACCESS_LOCAL_WRITE;
> >  		} else {
> > --
> 
> Thanks,
> Reviewed-by: Leon Romanovsky <leonro@mellanox.com>

Thanks for the review.

> Interesting, the followup question is why mlx4 is only one driver in IB which
> needs such code in umem_mr. I'll take a look on it.

I don't know. Just using the light heuristics of find_vma() shows some
other places. For example, ib_umem_odp_get() gets the umem->address via
ib_umem_start(). This was previously set in ib_umem_get() as called from
mlx4_get_umem_mr(). Should the above patch have just untagged "start" on
entry?

BTW, what's the provenience of such "start" address here? Is it
something that the user would have malloc()'ed? We try to impose some
restrictions one what is allowed to be tagged in user so that we don't
have to untag the addresses in the kernel. For example, if it was the
result of an mmap() on the device file, we don't allow tagging.

Thanks.

-- 
Catalin

