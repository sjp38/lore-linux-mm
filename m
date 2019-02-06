Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4352CC169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 21:05:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F2E09218DA
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 21:05:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="VrEBiF/n"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F2E09218DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7CF548E00FF; Wed,  6 Feb 2019 16:05:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A5278E00E6; Wed,  6 Feb 2019 16:05:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 66DD08E00FF; Wed,  6 Feb 2019 16:05:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3A7CF8E00E6
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 16:05:11 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id w24so7179103otk.22
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 13:05:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Tln1vBiQeKwSmWLEy4Y/wGxdB8A98ek27z5oOhyQLgA=;
        b=gPUvn5Lk4B/asrRWGklWs7CYTn4PoqvHC+SlNl3oMUwKIVbO44DQWq+xXtGC87gi7Z
         a85S0Qk7fcjZTajNDcgdbSYlvzvM0QcHQQzJjRkmiuL3anqLszHpbizv15OW2HXVcUgl
         S4K0+QxRx57sxsIFWX9KssxzqEfTMGfFw2vrGN9FP7AWdtriqX8zVMolgz82QH1D5/iq
         CyYpqzBo9PsaPkQI4BACPNqN2kv0C/VFpCqELnLZrG+TAcdl5CQKHytIjJ4a8uSxctxA
         mr+eYGo9ZxAfgzE1an638ctl9ZjKW42av+dhPdMzaIHRaUvdNlJcOdMcMYPl/3Qxhadl
         W3XA==
X-Gm-Message-State: AHQUAuafMkMk5dAtjgSNSHVpvW2W8zvpiZQZOeTBJJjRO81kSRbhslNl
	rDloyLUxJMTrVik8pbdCG9glgSUUa+ZpzbwZzgQXVeFakWhXP+eH0NY3DG0fuTgsymmas4OdtGz
	3em6K8cdfyd5VkI8baUdUIblYROIbKN7awfF8tGaB07KllZkg6qdPr1DqQT6Pr+L0iVpf2Nxpnn
	F9yFAuyjqkx62H9vha8WZ+gXKa14NtTRfDueQOpWs3m0NOIlX1S9KXe+0oV4Jc9ur6xyvIzIW2U
	wby9YWamBg6cOXNMOokRhOOvhWL7pwMAOsiMDvIXaeNd2ni8u9kGsbI6mMSvh5k9FxfbzEdKTIX
	EkyRH6kko/dVtU82miN/9KFvtgWGqrU1plegmOvzFrSDXxW1cgXaNsz/HxtW0hwICOna0D6VQH9
	g
X-Received: by 2002:a9d:5f13:: with SMTP id f19mr6481083oti.267.1549487110985;
        Wed, 06 Feb 2019 13:05:10 -0800 (PST)
X-Received: by 2002:a9d:5f13:: with SMTP id f19mr6481050oti.267.1549487110324;
        Wed, 06 Feb 2019 13:05:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549487110; cv=none;
        d=google.com; s=arc-20160816;
        b=Ud9Wg85lotYp4K0AiDWIlzjTx5loTj2KCskpW5cGW1j3TSt+eFYZNE78+rQmG7hoaO
         J4EkifkNMrC2h6y98qwlVLLyIsTkGDdmRWXJAaKqcln/dhfSChT192RxQYItZXn91Z6N
         eHUM2BNAr2LIapsVLUcO7LBINrIzTUuQhbKDVUniy+pMq30LpcJKSGVBzN8tRTS3sVdS
         WYKLpFTFZfJ3EgT/oZ3SOQ9nzUluDpt49HQ8nl9qNICXNZb5MUawl0Q67U1NNBA5hujQ
         GzSDOhalXBoMDhtPkKqWoGsYcAmvM8oS1a4h5/gkynl2851k+oL1BjZU2KoWeGRjQvn2
         VcDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Tln1vBiQeKwSmWLEy4Y/wGxdB8A98ek27z5oOhyQLgA=;
        b=b+dVB8tVKYvtsehpaMLtOLJnDBFDeMtvQ9TlfED00EGgen6M8aeRlHvFshMVpqeMbL
         2VMf7x4kE+/2WwZFY/BieUnWRrUCpQhhYc01dtxT/6HUDSH6SGMzLMzTWDoGjxFkB6VX
         M0Z+73WDXugCuK9TuEiAlD9xBJkjGBWkH8NanKRScS4P+2/3PbV1PUkh1J7SLRLwgfnH
         oamwZDvSs32k/07FxYUae/E35HFlS9JFdyTYKylgfsTJ3EWXjKOFQzEoPa4eGTKCrLhY
         zAvxwISKOyeAkXXIqYyRUKiW0t+O0tOTpu4ZWRjm1r+WagQEFpNP1BKlEBp+tNq+Wa8i
         lv+w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="VrEBiF/n";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d129sor12198048oih.165.2019.02.06.13.05.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Feb 2019 13:05:10 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="VrEBiF/n";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Tln1vBiQeKwSmWLEy4Y/wGxdB8A98ek27z5oOhyQLgA=;
        b=VrEBiF/nY0BRkKbELA8YzJ7IN0MCmwGWeP8qEGlxO6zA425I51oG4Sx/5gG8fnO61F
         MyKBWmhcqncgDlOOq+iUihs43ijgFAZqMYYJttETe6AhtQOq+UTWWqBNggUo385bV+9r
         ub9KiMpezLEqr3woQgo9Y09iOoaNs/MaQCy14kWqDTdzxg7zRXMRrtyvVmIs5ERUBuRy
         ZcEaQVS0ymH+Dipc8hCKCOHfeCpGDEq4YdM1p2IZNt3bk0KVtWcwb+X7dUAMrE+sDB+W
         gyowMVU33isZFYYwoJi17/V1JFHCl7yssHiSM0p5Q7/10kTm9kL2vaIvdbTFHosAwCHT
         xBtg==
X-Google-Smtp-Source: AHgI3IY5Sf4Cfy+fW6IBS156GRZUo4fehxu0u1cov625T4vkimXmry6pTIglZ0NOmMcIGuv/4D02xrG6vTD+irmRQ+4=
X-Received: by 2002:aca:240a:: with SMTP id n10mr645661oic.73.1549487109886;
 Wed, 06 Feb 2019 13:05:09 -0800 (PST)
MIME-Version: 1.0
References: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com>
 <20190206095000.GA12006@quack2.suse.cz> <20190206173114.GB12227@ziepe.ca>
 <20190206175233.GN21860@bombadil.infradead.org> <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <20190206183503.GO21860@bombadil.infradead.org> <20190206185233.GE12227@ziepe.ca>
 <CAPcyv4j4gDNHu836N4RfgQsE+eZU9Wt0N9Y09KQ43zV+4mK-eg@mail.gmail.com> <671e7ebc8e125d1ebd71de9943868183e27f052b.camel@redhat.com>
In-Reply-To: <671e7ebc8e125d1ebd71de9943868183e27f052b.camel@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 6 Feb 2019 13:04:57 -0800
Message-ID: <CAPcyv4id2rzJVUZw98PfJ-k05BvD-opwj0XhOWPKZQicmhXJ=g@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
To: Doug Ledford <dledford@redhat.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, 
	Ira Weiny <ira.weiny@intel.com>, lsf-pc@lists.linux-foundation.org, 
	linux-rdma <linux-rdma@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>, 
	Jerome Glisse <jglisse@redhat.com>, Dave Chinner <david@fromorbit.com>, 
	Michal Hocko <mhocko@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 6, 2019 at 12:14 PM Doug Ledford <dledford@redhat.com> wrote:
>
> On Wed, 2019-02-06 at 11:45 -0800, Dan Williams wrote:
> > On Wed, Feb 6, 2019 at 10:52 AM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> > > On Wed, Feb 06, 2019 at 10:35:04AM -0800, Matthew Wilcox wrote:
> > >
> > > > > Admittedly, I'm coming in late to this conversation, but did I miss the
> > > > > portion where that alternative was ruled out?
> > > >
> > > > That's my preferred option too, but the preponderance of opinion leans
> > > > towards "We can't give people a way to make files un-truncatable".
> > >
> > > I haven't heard an explanation why blocking ftruncate is worse than
> > > giving people a way to break RDMA using process by calling ftruncate??
> > >
> > > Isn't it exactly the same argument the other way?
> >
> >
> > If the
> > RDMA application doesn't want it to happen, arrange for it by
> > permissions or other coordination to prevent truncation,
>
> I just argued the *exact* same thing, except from the other side: if you
> want a guaranteed ability to truncate, then arrange the perms so the
> RDMA or DAX capable things can't use the file.

That doesn't make sense. All we have to work with is rwx bits. It's
possible to prevents writes / truncates. There's no permission bit for
mmap, O_DIRECT and RDMA mappings, hence leases.

> >  but once the
> > two conflicting / valid requests have arrived at the filesystem try to
> > move the result forward to the user requested state not block and fail
> > indefinitely.
>
> Except this is wrong.  We already have ETXTBSY, and arguably it is much
> easier for ETXTBSY to simply kill all of the running processes with
> extreme prejudice.  But we don't do that.  We block indefinitely.  So,
> no, there is no expectation that things will "move forward to the user
> requested state".  Not when pages are in use by the kernel, and very
> arguably pages being used for direct I/O are absolutely in use by the
> kernel, then truncate blocks.
>
> There is a major case of dissonant cognitive behavior here if the
> syscall supports ETXTBSY, even though the ability to kill apps using the
> text pages is trivial, but thinks supporting EBUSY is out of the
> question.

It's introducing a new failure mode where one did not exist before.
It's especially problematic when the only difference between the case
when it fails and one where it doesn't comes down to the
idiosyncrasies of DAX mappings and whether or not the RDMA device has
capabilities like ODP.

