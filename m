Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED464C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 15:46:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A9A04206BA
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 15:46:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="K6TPrF6G"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A9A04206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D0B58E0003; Wed, 13 Mar 2019 11:46:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 980368E0001; Wed, 13 Mar 2019 11:46:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 870A58E0003; Wed, 13 Mar 2019 11:46:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 527358E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 11:46:23 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id u132so958376oif.6
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 08:46:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=W+oPxX+piVpJ30lMLFWLXO5frI9ICTeBZDbNkkINo68=;
        b=lboYC5qjggYJMU/toy5M6orSGJwlRZHDsq27nd6POUfBycGwCqIR1rTMkU2l7dfiZ8
         SDWO1HA5zmZp+uo/ulWEtYuGCC1W8F3XX6SWPa5zfFKtd4qoQEvprix5/9JApdRHSkx8
         G++hzKJ3iI6vCV8vvhCosCCtMvAxLOoy2xsnIGC/Pi6aG62NCiGD6cfjVjAs+7Mmz/yI
         CIExiL8zB85IzfbrV+A7gKrEb403qKpeIUCWZH8eZsseB7KZIiugVrXjv5k+hUgHI3rC
         wqhXnAlFH/QEXFLlOpZ+S73FSaPUsPIG3BBJM/wzTA/akKpIZQhAwfLelk27NVZlIwaC
         oIUg==
X-Gm-Message-State: APjAAAVD5f/MkHV006PMQwlf2IqZ0YukEHjhXQ0wgIw4DRl9n0oWmoVs
	pLQs4YOWJR4P8LIhValckncr1dBDT5FJhSlA6/8T6D/BW9r+BVu+Gyg8IvYA+ryHij8PsfyBKYi
	YueaDEC3lUsKEvCd6vMPlcV/XT0fa2QeRZcMHHZPDMGt4VkWzg1w0hrKkHfSycbC0xuXP/9jgOb
	cPsOQreHLEZUzaU1EaqjNgXGOWnJH7Ib0Yq5UkEASHbZImEKtqXzQLokXgRp3hFUzYZk/vv8moq
	J3Ia08hOn3bzO5H98+uMlYgZ45TftQvr6KZltzIxxb0aSN3JgBnuFQmk0Ro3lekQ3Q0IJuqV4JO
	jcZghaZNJ3f7DLeTolT/Bv08WYHlwBlcyl7Els/PCT70rEguAEeFEbiLGAIQn8g/zuBFHRD+YZr
	q
X-Received: by 2002:aca:34d4:: with SMTP id b203mr1977142oia.123.1552491983002;
        Wed, 13 Mar 2019 08:46:23 -0700 (PDT)
X-Received: by 2002:aca:34d4:: with SMTP id b203mr1977110oia.123.1552491982204;
        Wed, 13 Mar 2019 08:46:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552491982; cv=none;
        d=google.com; s=arc-20160816;
        b=DsbpaFuHzXHIjlHMtAVTx6JomwQ99B/IxuxbMTDovomgr/Z7512Kncj5XTmtvsgWTP
         BVBTaMSDNOACEt+AKuGkruMbo0nP6G1ZS1fxZdbUO7jPo32IM5rizkiyjXpAtqp1JJol
         FGf0yYWOzim1NaNBmAmw6N3+3pwIptg4KXwnM8ib7+KVHsRQ4jNNvpNcVZU3PaQQ9PuK
         fucDzWSYsgrEt8C3affS7YTVQWGBGVwO2+m5ANVx651Nn2R64gM/De5czJXBm7rqAyX4
         W12lHrz/cDUFFRuYRbNXTwNCMx60CTAblcncL9HmDAQ2spz9iiVB59BPAZ+up808QC2I
         Jefw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=W+oPxX+piVpJ30lMLFWLXO5frI9ICTeBZDbNkkINo68=;
        b=POTOvaQ52VuC9rZTTyskS/NOgmi4pHgHoHJRnSo/3F7UvE0ak6piGiup5sYPQdZnqt
         DJTPPthVhO2KJN4eehMMS5bz0oN6/42GV7fOJVtDwrNtkXwlThTpuIpzUxTVMoj1f+O7
         2GK62fUJ/+9poaqEHN+KJgE34rrmSjXvSPCv2hdEjo0mEaA1Oq+T5tjh7yREBd2P04/8
         m5BqJBqCzrSZ1Q2/MZ1/9FSgC8IjzrBX8ZzVHnv8WS2KbRSPQBpKjB+Y10A9UeDQx3gT
         jsO1q9s+Xr9ZKpGQ13hZdD3XccaHe/pjrM323vMrN2pgRzp0gTNvCzHUUkeWcn20xokb
         gnFg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=K6TPrF6G;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e4sor5558408oif.133.2019.03.13.08.46.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Mar 2019 08:46:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=K6TPrF6G;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=W+oPxX+piVpJ30lMLFWLXO5frI9ICTeBZDbNkkINo68=;
        b=K6TPrF6Gd0Rm8cnqAH4FSX4ju5kqgdcKWeArLF3aGlkb0COO9WtMkBFFqWX8vuBCC1
         1Oh8FfmxaaVfNPqid3tlVqyGC0CXaNmDrxv1Bm+iFBSgkUq+i00Xr40a/+Rhdcmus0Tp
         Ue/QgklPhjO9XyX9oDRWrZ98rO5KJnn6yCWoA4qey9uEof4IQmZnl3HSOMNmU2yQbAQy
         2SGJw6v5tfq0+7g5u/8dcDgm+SNhEPzr3++427mI5YjCNGHd3vioHbBD3Ue6zJJwZStg
         D76rbhciwPIu6TyS0LptOspjwLG0urszdpdESrAi3MpzIrfODP4ilNp5855L4KiF5vBI
         IiUA==
X-Google-Smtp-Source: APXvYqzeFUEG6z2e2O4tKclCB8I51BgRRqaAVbxJi1OegFmDCC35wG8DixTGq05LsFK9tKxgwi01c1gRidpmHJjcdKc=
X-Received: by 2002:aca:54d8:: with SMTP id i207mr2145761oib.0.1552491981719;
 Wed, 13 Mar 2019 08:46:21 -0700 (PDT)
MIME-Version: 1.0
References: <20190309120721.21416-1-aneesh.kumar@linux.ibm.com>
 <8736nrnzxm.fsf@linux.ibm.com> <20190313095834.GF32521@quack2.suse.cz>
In-Reply-To: <20190313095834.GF32521@quack2.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 13 Mar 2019 08:46:10 -0700
Message-ID: <CAPcyv4irZP2F1acuco7UVbvTARzn5SXvCAWstFYtP7ygLRSXTg@mail.gmail.com>
Subject: Re: [PATCH v2] fs/dax: deposit pagetable even when installing zero page
To: Jan Kara <jack@suse.cz>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Ross Zwisler <zwisler@kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux MM <linux-mm@kvack.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 13, 2019 at 2:58 AM Jan Kara <jack@suse.cz> wrote:
>
> On Wed 13-03-19 10:17:17, Aneesh Kumar K.V wrote:
> >
> > Hi Dan/Andrew/Jan,
> >
> > "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> writes:
> >
> > > Architectures like ppc64 use the deposited page table to store hardware
> > > page table slot information. Make sure we deposit a page table when
> > > using zero page at the pmd level for hash.
> > >
> > > Without this we hit
> > >
> > > Unable to handle kernel paging request for data at address 0x00000000
> > > Faulting instruction address: 0xc000000000082a74
> > > Oops: Kernel access of bad area, sig: 11 [#1]
> > > ....
> > >
> > > NIP [c000000000082a74] __hash_page_thp+0x224/0x5b0
> > > LR [c0000000000829a4] __hash_page_thp+0x154/0x5b0
> > > Call Trace:
> > >  hash_page_mm+0x43c/0x740
> > >  do_hash_page+0x2c/0x3c
> > >  copy_from_iter_flushcache+0xa4/0x4a0
> > >  pmem_copy_from_iter+0x2c/0x50 [nd_pmem]
> > >  dax_copy_from_iter+0x40/0x70
> > >  dax_iomap_actor+0x134/0x360
> > >  iomap_apply+0xfc/0x1b0
> > >  dax_iomap_rw+0xac/0x130
> > >  ext4_file_write_iter+0x254/0x460 [ext4]
> > >  __vfs_write+0x120/0x1e0
> > >  vfs_write+0xd8/0x220
> > >  SyS_write+0x6c/0x110
> > >  system_call+0x3c/0x130
> > >
> > > Fixes: b5beae5e224f ("powerpc/pseries: Add driver for PAPR SCM regions")
> > > Reviewed-by: Jan Kara <jack@suse.cz>
> > > Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> >
> > Any suggestion on which tree this patch should got to? Also since this
> > fix a kernel crash, we may want to get this to 5.1?
>
> I think this should go through Dan's tree...

I'll merge this and let it soak in -next for a week and then submit for 5.1-rc2.

