Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49C39C4151A
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 21:21:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F1BC82087E
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 21:21:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F1BC82087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9535D8E0002; Tue, 29 Jan 2019 16:21:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8DC0A8E0001; Tue, 29 Jan 2019 16:21:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A34D8E0002; Tue, 29 Jan 2019 16:21:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4BC5D8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 16:21:56 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id z6so26183275qtj.21
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:21:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=bFGyj3PuXpSbEuTp6rUpVXZdlizM+XJ5KRJ2Ha5esLQ=;
        b=V9WT3DCX6089yWoe4PCdXfoxg/S1HzTAb6phvBp5Sid/C2/ggf2AeL6QAJxzowBvgO
         DeSBEk4hyRYKZ/8Cr+5MhS50JMlmDeVIfYRkoqsG3n3qRKLATA1zz7rrgLYqTmAV2cFW
         f9P6JqutQXbyHC9A2BqdLfucnliZv2Z8adSaNyW87W2UVDwRpOmOYQH4aV2lgGS+h5Ha
         O/ZHycqqeJW57gj0X959TGUn8dCnK6OSFkLTLMOCYNaK3a6au3REUjPNlgcXT3/sZ/e8
         ZOXHx6xrS4dHwBwjPGJWkM2MDjd4eV4Lx+f0tbGqKc9xzcgyrd6bXmUzoNET3YYS3MMN
         UKlQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukeCWSLG+WrCtVZ1hlX2JivZpWucZ8ESnoncu4YO9WQ74i6SerOx
	x0QgJHFA5nQfI7Ubed8rwQiqpCqimbuvvEpCtiVzRYNVq0O459Rurbhy6MgN7FGHuFj0khUj8Lk
	gcMhNgAMaAMlU0dakPx7vk9SvKNPv4swN0JgZKFarZYJ4htUQtianm9Kg7PLNkPXyUA==
X-Received: by 2002:ac8:2368:: with SMTP id b37mr27277464qtb.203.1548796916021;
        Tue, 29 Jan 2019 13:21:56 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7MpR7ZVzcqP5hoEiprC61DJWHIN7gILScw3//Ckvt8VDLjuS201G8A7WX/FpqYPoO5prSQ
X-Received: by 2002:ac8:2368:: with SMTP id b37mr27277423qtb.203.1548796915280;
        Tue, 29 Jan 2019 13:21:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548796915; cv=none;
        d=google.com; s=arc-20160816;
        b=E20tHBV7ZcVH72I4Oq6d3CCxNpWj1quk0zzD/D0WN5m4JzC/pgfoJhJgZz3LAWi/HZ
         i6tgfcUeG2WvG1tqFwIWUO4TV34D/zVhKTQl8M9hSEbzIqsQzCgeBxF3Hqw1geVotT8x
         DPPB4ES+M9hbT7ykiOOtknZ1gm276QFMHZT8KV7Wv7J9DF1ZNi8QFN1H3s7EAGX0yorh
         dQRhsKj7zXZzvDgYrpcHKSANOCCZoDhmnwcJ2qahXhvfJlRjo3fqluxfeZBTgr9ZrQSK
         UV19MAjsX/f8fBRoS0uBZohm0JkiJcy6fXJ0YuRx9gCVYhrtE6ag7DUZaKxRElxfys7O
         5FwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=bFGyj3PuXpSbEuTp6rUpVXZdlizM+XJ5KRJ2Ha5esLQ=;
        b=JKGuGtgtSMfiiI2RKF5jf4syFiaEx5MwLGnz4hBuvev/IJ+Q55+KKT9CojsVrIyIrr
         RfqMH4R/kyeWO2/CNiBdI5jbOCUlfWRk9BisdWppEG4v467M1GwSxkYhtbpuDDDYqI5t
         iwDJQKT3gOERHWkg3RXD4cDeddSGrI3nlzZhwhTK0hmkR7M3MjExvqiGM0uaDmhsTuFz
         EbeFtabvoNzl5/VSqK9BM/irx7aGzXLKGHWUspNEfLlODMmgRWpzq63JY1ajtHN3t+H6
         N/GzWT0tKzlkMbBSTQyoh3OdZPQNcFfqRUiVKM9G75ZictIBIsHynvw142HPIpAmugog
         /S5A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g198si2135670qke.266.2019.01.29.13.21.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 13:21:55 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 41F39DC8FE;
	Tue, 29 Jan 2019 21:21:54 +0000 (UTC)
Received: from redhat.com (ovpn-122-2.rdu2.redhat.com [10.10.122.2])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 1BF5D600CC;
	Tue, 29 Jan 2019 21:21:52 +0000 (UTC)
Date: Tue, 29 Jan 2019 16:21:51 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH 09/10] mm/hmm: allow to mirror vma of a file on a DAX
 backed filesystem
Message-ID: <20190129212150.GP3176@redhat.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
 <20190129165428.3931-10-jglisse@redhat.com>
 <CAPcyv4gNtDQf0mHwhZ8g3nX6ShsjA1tx2KLU_ZzTH1Z1AeA_CA@mail.gmail.com>
 <20190129193123.GF3176@redhat.com>
 <CAPcyv4gkYTZ-_Et1ZriAcoHwhtPEftOt2LnR_kW+hQM5-0G4HA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4gkYTZ-_Et1ZriAcoHwhtPEftOt2LnR_kW+hQM5-0G4HA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Tue, 29 Jan 2019 21:21:54 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 12:51:25PM -0800, Dan Williams wrote:
> On Tue, Jan 29, 2019 at 11:32 AM Jerome Glisse <jglisse@redhat.com> wrote:
> >
> > On Tue, Jan 29, 2019 at 10:41:23AM -0800, Dan Williams wrote:
> > > On Tue, Jan 29, 2019 at 8:54 AM <jglisse@redhat.com> wrote:
> > > >
> > > > From: Jérôme Glisse <jglisse@redhat.com>
> > > >
> > > > This add support to mirror vma which is an mmap of a file which is on
> > > > a filesystem that using a DAX block device. There is no reason not to
> > > > support that case.
> > > >
> > >
> > > The reason not to support it would be if it gets in the way of future
> > > DAX development. How does this interact with MAP_SYNC? I'm also
> > > concerned if this complicates DAX reflink support. In general I'd
> > > rather prioritize fixing the places where DAX is broken today before
> > > adding more cross-subsystem entanglements. The unit tests for
> > > filesystems (xfstests) are readily accessible. How would I go about
> > > regression testing DAX + HMM interactions?
> >
> > HMM mirror CPU page table so anything you do to CPU page table will
> > be reflected to all HMM mirror user. So MAP_SYNC has no bearing here
> > whatsoever as all HMM mirror user must do cache coherent access to
> > range they mirror so from DAX point of view this is just _exactly_
> > the same as CPU access.
> >
> > Note that you can not migrate DAX memory to GPU memory and thus for a
> > mmap of a file on a filesystem that use a DAX block device then you can
> > not do migration to device memory. Also at this time migration of file
> > back page is only supported for cache coherent device memory so for
> > instance on OpenCAPI platform.
> 
> Ok, this addresses the primary concern about maintenance burden. Thanks.
> 
> However the changelog still amounts to a justification of "change
> this, because we can". At least, that's how it reads to me. Is there
> any positive benefit to merging this patch? Can you spell that out in
> the changelog?

There is 3 reasons for this:
    1) Convert ODP to use HMM underneath so that we share code between
    infiniband ODP and GPU drivers. ODP do support DAX today so i can
    not convert ODP to HMM without also supporting DAX in HMM otherwise
    i would regress the ODP features.

    2) I expect people will be running GPGPU on computer with file that
    use DAX and they will want to use HMM there too, in fact from user-
    space point of view wether the file is DAX or not should only change
    one thing ie for DAX file you will never be able to use GPU memory.

    3) I want to convert as many user of GUP to HMM (already posted
    several patchset to GPU mailing list for that and i intend to post
    a v2 of those latter on). Using HMM avoids GUP and it will avoid
    the GUP pin as here we abide by mmu notifier hence we do not want to
    inhibit any of the filesystem regular operation. Some of those GPU
    driver do allow GUP on DAX file. So again i can not regress them.


> > Bottom line is you just have to worry about the CPU page table. What
> > ever you do there will be reflected properly. It does not add any
> > burden to people working on DAX. Unless you want to modify CPU page
> > table without calling mmu notifier but in that case you would not
> > only break HMM mirror user but other thing like KVM ...
> >
> >
> > For testing the issue is what do you want to test ? Do you want to test
> > that a device properly mirror some mmap of a file back by DAX ? ie
> > device driver which use HMM mirror keep working after changes made to
> > DAX.
> >
> > Or do you want to run filesystem test suite using the GPU to access
> > mmap of the file (read or write) instead of the CPU ? In that case any
> > such test suite would need to be updated to be able to use something
> > like OpenCL for. At this time i do not see much need for that but maybe
> > this is something people would like to see.
> 
> In general, as HMM grows intercept points throughout the mm it would
> be helpful to be able to sanity check the implementation.

I usualy use a combination of simple OpenCL programs and hand tailor direct
ioctl hack to force specific code path to happen. I should probably create
a repository with a set of OpenCL tests so that other can also use them.
I need to clean those up into something not too ugly so i am not ashame
of them.

Also at this time the OpenCL bits are not in any distro, most of the bits
are in mesa and Karol and others are doing a great jobs at polishing things
and getting all the bits in. I do expect that in couple months the mainline
of all projects (LLVM, Mesa, libdrm, ...) will have all the bits and then it
will trickle down to your favorite distribution (assuming they build mesa
with OpenCL enabled).

Cheers,
Jérôme

