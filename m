Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1FCB4C10F13
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 17:18:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C926120863
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 17:18:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="GsBfuMaH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C926120863
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 444A86B0006; Mon,  8 Apr 2019 13:18:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F51E6B0007; Mon,  8 Apr 2019 13:18:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2BDF06B0008; Mon,  8 Apr 2019 13:18:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0C9D86B0006
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 13:18:50 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id c17so11687314iom.21
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 10:18:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=I0hrpN+n/xSYHN63HyWBfrYsRb+kkodDIb8th+w7s5I=;
        b=UsX4FXmsbbCw+MtCmAaapbYJmOUO/a9H7QelYXhSYax1JXX8mrcmZypkVy1et3//sh
         DWXl3u5DrUMHdSC/7XtrhrZ6wFD9PUl1SSrvUqe5N4eErKd5TxqUNQEIfyheUun1xOmg
         FroGD+YgoIvFl3jOq6Wp7NDdwcoVDzL1XdhhZnJVuUJKtbFHLD8E+8VarSvkI/QApAgb
         u92OUO/HvyhQ+qojq66rL2y7P+w2L9ULbkBiJpMDpXqeNlhfWzdjb0C211TPknhNshv8
         RkJNZ5XpOS4O7GIAz7cb7NNv73k3FN/fQiiGV9TmIl5Fn4tP0yUJ0mt3CqPyWKfzDZBm
         poOw==
X-Gm-Message-State: APjAAAWmvdAw3RAi7jPO516G8oO1byFoUjodLHgbgdImMKlLoWS3MFg8
	9J1I6/C3znIhZz5zSGmzH90hs3RWKtX76fZlJhvRWkBwP1ZQqubS3Xn1+q1prjnMD2IH4QWC7AY
	J3Sc5I6D7P3AMXCyshFzM3aDfCBv+XRk924w5dVZ8f8BQAlUHD9nIwoAcyidsYyviCw==
X-Received: by 2002:a24:4d8a:: with SMTP id l132mr21618958itb.70.1554743929767;
        Mon, 08 Apr 2019 10:18:49 -0700 (PDT)
X-Received: by 2002:a24:4d8a:: with SMTP id l132mr21618903itb.70.1554743928796;
        Mon, 08 Apr 2019 10:18:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554743928; cv=none;
        d=google.com; s=arc-20160816;
        b=S7yIU3zPkPWe1KXtXQv9TqmzjRDDVsmKd1pyBBx6Mkbd1C84/Qp/n7v5wf2NPWKCfL
         aEmDdk/K/FJnIS3mOc802vRaVxBynnYIquoz4Bppyl8Mp68QxRb0VmaHSX+OwdK2ViAP
         sJqELPk8k/OhhKuGLsT9ca2nHS0rVzd8kyccskTGaphxTAp3kC9CtPPctr8HGZLfSSz7
         OU5s+tHvMSOANHHJ3IL1EVcma2Lm5GvnPiXzIv0bp/U0rr97CpORDFgVKWqSrlNSgEzp
         0EZ2bTTHdLWaOs1j6LZuiiTGROp8KQvoKovxXPCGIk1zroqe94uHQV46AwM+sEbjnc8V
         04bQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=I0hrpN+n/xSYHN63HyWBfrYsRb+kkodDIb8th+w7s5I=;
        b=QNrbpydLmMMtyg170iy4kCxGABheBZZahf7H5bwrXWabkilB2igdZiVDD/Vf1HUkv4
         5nSL4Y1xUht/9axnuOjC2dHd8qxaYm2HcXNLRy/l/HrMjOAouJQ1jPAi/97h9+7E5CSz
         Dpd+Cp6hDscmJQ9zrns9UAlVM62zz/pKrQDAUWjlqoT1dyh/mhLdPfBQmjvWwkZ+rAJ8
         8/WW6JFGA7bJLTpOvsXuYQbw+Im+znHWlqcFX1JFaILfhDz2Brqo5cuTft8d21ZNfzlq
         1LiUylRlngk/aTLgWr35SQP+fv+jBF6tGfMv396SlMvF86ebZS0geMQE+CphXs0j685Y
         ZSXg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=GsBfuMaH;
       spf=pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuzhao@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r21sor19015516iod.129.2019.04.08.10.18.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Apr 2019 10:18:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=GsBfuMaH;
       spf=pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuzhao@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=I0hrpN+n/xSYHN63HyWBfrYsRb+kkodDIb8th+w7s5I=;
        b=GsBfuMaHUMFMyzJ3V3cYar4SzFP84sahUwvImGTlosHxgTZML0TQ8i1Rxrf9pna63Z
         +8iTfa7HdE19DVDqKIJisqZotDWqq9S47+ynqm4pFCv6ZPYmzSV690VRArTsGR1DyZPf
         MKARniVRmy644xNGCuq33rBCsv5PtLXOyAi42pi8YgUk4mqoysEYP8L/Pi1g5R+ZC//I
         lCteEbGd0wMnzni/h33aVERpQwfaU/omsrfuFQsTNIpd7LG93gh3uCn1A3wr2+lp506n
         kdA69KJXF50ka1HlRteSgnLoa3qoc5nhbqyWiZpoQlKJoxCYCmKE/754f2o80y7XGBPD
         jc0w==
X-Google-Smtp-Source: APXvYqxYY5wiGAUEvbwJM7zFq7gs6fRUiI1Rxe3i35EIz8JlwJ7p7elg72cgSIhhFLj69XH5vFY/kQ==
X-Received: by 2002:a6b:d119:: with SMTP id l25mr20027875iob.278.1554743927679;
        Mon, 08 Apr 2019 10:18:47 -0700 (PDT)
Received: from google.com ([2620:15c:183:0:a0c3:519e:9276:fc96])
        by smtp.gmail.com with ESMTPSA id w4sm11647834ioa.38.2019.04.08.10.18.46
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 08 Apr 2019 10:18:47 -0700 (PDT)
Date: Mon, 8 Apr 2019 11:18:42 -0600
From: Yu Zhao <yuzhao@google.com>
To: Will Deacon <will.deacon@arm.com>
Cc: mark.rutland@arm.com, julien.thierry@arm.com, suzuki.poulose@arm.com,
	marc.zyngier@arm.com, catalin.marinas@arm.com,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	christoffer.dall@arm.com, linux-mm@kvack.org, james.morse@arm.com,
	kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org
Subject: Re: [PATCH V2] KVM: ARM: Remove pgtable page standard functions from
 stage-2 page tables
Message-ID: <20190408171842.GA218114@google.com>
References: <3be0b7e0-2ef8-babb-88c9-d229e0fdd220@arm.com>
 <1552397145-10665-1-git-send-email-anshuman.khandual@arm.com>
 <20190401161638.GB22092@fuggles.cambridge.arm.com>
 <20190401183425.GA106130@google.com>
 <20190402090349.GA25936@fuggles.cambridge.arm.com>
 <20190408142212.GA4331@fuggles.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190408142212.GA4331@fuggles.cambridge.arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 08, 2019 at 03:22:38PM +0100, Will Deacon wrote:
> On Tue, Apr 02, 2019 at 10:04:30AM +0100, Will Deacon wrote:
> > On Mon, Apr 01, 2019 at 12:34:25PM -0600, Yu Zhao wrote:
> > > On Mon, Apr 01, 2019 at 05:16:38PM +0100, Will Deacon wrote:
> > > > [+KVM/ARM folks, since I can't take this without an Ack in place from them]
> > > > 
> > > > My understanding is that this patch is intended to replace patch 3/4 in
> > > > this series:
> > > > 
> > > > http://lists.infradead.org/pipermail/linux-arm-kernel/2019-March/638083.html
> > > 
> > > Yes, and sorry for the confusion. I could send an updated series once
> > > this patch is merged. Thanks.
> > 
> > That's alright, I think I'm on top of it (but I'll ask you to check whatever
> > I end up merging). Just wanted to make it easy for the kvm folks to dive in
> > with no context!
> 
> Ok, I've pushed this out onto a temporary branch before I merge it into
> -next:
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/arm64/linux.git/log/?h=pgtable-ctors
> 
> Please can you confirm that it looks ok?

LGTM, thanks.

