Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 377FBC10F14
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 15:54:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC7F921473
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 15:54:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="FjEjH8oq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC7F921473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E7246B0006; Mon,  8 Apr 2019 11:54:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 56CDA6B0008; Mon,  8 Apr 2019 11:54:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 40D806B000A; Mon,  8 Apr 2019 11:54:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0CB726B0006
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 11:54:45 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id j20so8323621otr.0
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 08:54:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=DOD1pypLe94jr/T7lBG/UY8aWm0TnxhhMUj6XEFllZg=;
        b=LLO9Rvhq2YXWAbuNVUoCD2ZntXHmvq8J1RIJBQtBOcr8/lXoScHXEE+2C2+6HMZjcQ
         UMCsb7Zi45QQA/k6Sun15NAXj+WR3mUG8rbrKtU3TrcbSLaO1B3N/j23UAM9mACJwcxq
         vfKFieJvAZcNAc30/1Sv4YtZXOjZ65N0AXkk8xviq6ZiGI5mUlMr51WpHcveA2vXhsd1
         jPxR1Oap9lb354A/7S+6QmCk7frAVnYc+TmlgtMJqvsicKmNfjW+rFOPWjG5Jn9TEV/U
         71QzTdo2LUkgC8FTXV4QjJXn32hWUfx2CdNSyI7HDQdRSuy/3bSmWWalV8l1ysBb2/eH
         zO1Q==
X-Gm-Message-State: APjAAAVAdSTNnwUKsID5mTYQcFYY74kc/m1bo7g9rRV+hrPGXsvy17Zs
	N3vsvr83Kvopoo2thKjbbIWdxFL0jSpkWnZGuV1y8/fpZ2HpfteEf4QOHkIL384tmc6a5ashSB7
	lWitgaGYedtH7aDk/mNEAw1940PPLkWuXS9UU+jcPicvyxRJREbUTNTEotwwCceZotg==
X-Received: by 2002:aca:e4cc:: with SMTP id b195mr16713943oih.39.1554738884489;
        Mon, 08 Apr 2019 08:54:44 -0700 (PDT)
X-Received: by 2002:aca:e4cc:: with SMTP id b195mr16713899oih.39.1554738883775;
        Mon, 08 Apr 2019 08:54:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554738883; cv=none;
        d=google.com; s=arc-20160816;
        b=LM7xuDV+hZHJBUJiJrdUV22dEJQPpU1MBQCWotK+TMWOM137QLm1oQktubfPuj0nB8
         lANYBsswmIVqVH7dRehDbhDv6JwReWT4HnFIeBQrLhU3INu7YwbTumEb1NPQbGewKZ1L
         uV7CaFx1K2YmgvtuEDrJvas3UOy6DupCnrJHZHXNwLhYoOUC8ttyNf0oOZrhRbM2W4rf
         JZEdjATHp/h9eqlDOSnk1kDN4TwS6psl3vK6JCEYKEs4+cqgOqgiXpq8NPwI3ZsZplf/
         pBAEtY511NYUjZOAD4Im31tefmu36JFqPh5EFtkG9owINVrjaFGt8dT33s4Xhf9yICJp
         TXCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=DOD1pypLe94jr/T7lBG/UY8aWm0TnxhhMUj6XEFllZg=;
        b=YCYQhHMmIGAUG1WDxEPxCSiBOiVFMZV8wECVcELFY8KXIPjHn4V73lh7L4EJu1wu4D
         yczOPxOKop9o7owqehqGSmFslU21O/ecCTC9H3UCHaZAjiKWQ34+59zrLzMvSmEYenUK
         Z3gCxo/7RsGsBpBeBpfmTCQrcNva+oh993pGaEOZWHUfIsqazVEL+4XZPXRAtMrbaTZ1
         UO4m1VxqWZSJ+WamwkO1YTjJGsFoHxSNgpY8ZQm5UwcKZlkYZ+aJ05Sl5v6iEEWd9thF
         P1kqzPJ+yV73AlyNIC1AK/hD/51uOEdxrgxETb537ljQe7zD81cpH9l11lZAKjTvfHG1
         d4JA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=FjEjH8oq;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g9sor17108359otr.173.2019.04.08.08.54.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Apr 2019 08:54:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=FjEjH8oq;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=DOD1pypLe94jr/T7lBG/UY8aWm0TnxhhMUj6XEFllZg=;
        b=FjEjH8oqASAGoY3oWhMWbcEek46J4T/r5VapLKuGBvpq4vmONjSw5iWsfnAEXC+7hv
         MsxN8dQOHHWP+r8qb3MJDxkU9XCnlirLetcrl2HbFninvIDnIJ69eh991wXDkZMd5ylk
         qFN2a/kuGqQ6uB53FkrFvvONmCEsixonM7AsYataZ8BsbfpbUzekyl/fkuBQz1PAYA5/
         L/vlzsPUhhRlPfuZEFYWtyFd7x64Ptv25oIdAgsuLieGgzJR8wd6D4IovjSGYWSYZBPx
         5ZmlddVUiAnHOIX9iXg3MBXncSP5Kn7C/JppAFcXMh4ajrdrKJrFgCB7jKJBfquvrmtN
         B29A==
X-Google-Smtp-Source: APXvYqyxFdjNMvG4MYJS/CnnPmtKxS7OIbJ+X/ge0OkLU2Y7BpdOvqkSfNeWc8IFOetR4KsZfhoXfC86jEWkg34kP7g=
X-Received: by 2002:a9d:3f4b:: with SMTP id m69mr20104391otc.246.1554738883389;
 Mon, 08 Apr 2019 08:54:43 -0700 (PDT)
MIME-Version: 1.0
References: <20190309120721.21416-1-aneesh.kumar@linux.ibm.com>
 <8736nrnzxm.fsf@linux.ibm.com> <20190313095834.GF32521@quack2.suse.cz>
 <CAPcyv4irZP2F1acuco7UVbvTARzn5SXvCAWstFYtP7ygLRSXTg@mail.gmail.com> <87r2acn8eq.fsf@linux.ibm.com>
In-Reply-To: <87r2acn8eq.fsf@linux.ibm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 8 Apr 2019 08:54:31 -0700
Message-ID: <CAPcyv4hJ=fhXNYXwtUKwSY=dZo540bLX+d12j3HQswkNWFugRg@mail.gmail.com>
Subject: Re: [PATCH v2] fs/dax: deposit pagetable even when installing zero page
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Jan Kara <jack@suse.cz>, Ross Zwisler <zwisler@kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux MM <linux-mm@kvack.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 8, 2019 at 2:39 AM Aneesh Kumar K.V
<aneesh.kumar@linux.ibm.com> wrote:
>
>
>  Hi Dan,
>
> Dan Williams <dan.j.williams@intel.com> writes:
>
> > On Wed, Mar 13, 2019 at 2:58 AM Jan Kara <jack@suse.cz> wrote:
> >>
> >> On Wed 13-03-19 10:17:17, Aneesh Kumar K.V wrote:
> >> >
> >> > Hi Dan/Andrew/Jan,
> >> >
> >> > "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> writes:
> >> >
> >> > > Architectures like ppc64 use the deposited page table to store hardware
> >> > > page table slot information. Make sure we deposit a page table when
> >> > > using zero page at the pmd level for hash.
> >> > >
> >> > > Without this we hit
> >> > >
> >> > > Unable to handle kernel paging request for data at address 0x00000000
> >> > > Faulting instruction address: 0xc000000000082a74
> >> > > Oops: Kernel access of bad area, sig: 11 [#1]
> >> > > ....
> >> > >
> >> > > NIP [c000000000082a74] __hash_page_thp+0x224/0x5b0
> >> > > LR [c0000000000829a4] __hash_page_thp+0x154/0x5b0
> >> > > Call Trace:
> >> > >  hash_page_mm+0x43c/0x740
> >> > >  do_hash_page+0x2c/0x3c
> >> > >  copy_from_iter_flushcache+0xa4/0x4a0
> >> > >  pmem_copy_from_iter+0x2c/0x50 [nd_pmem]
> >> > >  dax_copy_from_iter+0x40/0x70
> >> > >  dax_iomap_actor+0x134/0x360
> >> > >  iomap_apply+0xfc/0x1b0
> >> > >  dax_iomap_rw+0xac/0x130
> >> > >  ext4_file_write_iter+0x254/0x460 [ext4]
> >> > >  __vfs_write+0x120/0x1e0
> >> > >  vfs_write+0xd8/0x220
> >> > >  SyS_write+0x6c/0x110
> >> > >  system_call+0x3c/0x130
> >> > >
> >> > > Fixes: b5beae5e224f ("powerpc/pseries: Add driver for PAPR SCM regions")
> >> > > Reviewed-by: Jan Kara <jack@suse.cz>
> >> > > Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> >> >
> >> > Any suggestion on which tree this patch should got to? Also since this
> >> > fix a kernel crash, we may want to get this to 5.1?
> >>
> >> I think this should go through Dan's tree...
> >
> > I'll merge this and let it soak in -next for a week and then submit for 5.1-rc2.
>
> Any update on this? Did you get to merge this?

Thanks for the reminder. Will send this week along with some other
libnvdimm related fixes.

