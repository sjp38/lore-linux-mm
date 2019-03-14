Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6CE85C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 16:16:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2AAC42184C
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 16:16:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2AAC42184C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B89598E0004; Thu, 14 Mar 2019 12:16:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B10D48E0001; Thu, 14 Mar 2019 12:16:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D8F98E0004; Thu, 14 Mar 2019 12:16:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7ABD58E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 12:16:40 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id x18so5128996qkf.8
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 09:16:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=krRP3KY1fGKj7cf+zc7TftkVbuz3X/Fy/C3+kHv3U/A=;
        b=CFtBvOO+y4BJ4oX7Gd55dzYC+b0CnmzSv1LVeLCAm1MJdl42Zw+3YqkawzhF2NIA4Y
         RQvJoDigqMtwK0D8hwjHGtv4SRgbVmrBvsJy9I2Q9w9fIVN2WelUVRzpG76u5s3PHM4Z
         9F/ixErGpnetPKHrs1YcYXqah0asMJ8/nfZl85LwgETlc8/Sr/jMWcYyJ58bLo86I/w3
         euDfK7onBL17ScyluYzICzkbK0v3vTSIpRYM2BtrpUquWUyPZFeAiIcG0GNQDIen1Pwv
         Rg92PNNt4DkrnjuJMszuK8uflEMnAG5RJsBjdKLVY2x8/YXp8FbNZqlbi55K1fYl9wIN
         C6+w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXSnGbneaS2h2rnAtLBhvVt5DTfXdMDq2KrKWllq5ShmTx+Y4f2
	NLgkcbQjC2N91dL4INSpxB4hKq5jJ9ohM0xfze7gtXUpRMm7lxLiWJMBYCyQjGbZLTPxZfv2UVZ
	PBzB5Y9c6bX8JauCJ2xgQP8oLgN2s//Jx8qOPd6JBQmdth3Kzve6j+6Zfa0b3RFsTDQ==
X-Received: by 2002:ac8:1c2c:: with SMTP id a41mr15891126qtk.292.1552580200296;
        Thu, 14 Mar 2019 09:16:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwD2JUXoUpiFYOcV8Fr2PdOQ3gMmtp3rfy71AWCcqQ2P8XmXmgufFAmT7f0H87gphZFMGt0
X-Received: by 2002:ac8:1c2c:: with SMTP id a41mr15891066qtk.292.1552580199522;
        Thu, 14 Mar 2019 09:16:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552580199; cv=none;
        d=google.com; s=arc-20160816;
        b=tnNthMi0FZwAoS4y2p47G4FElk2RAxwaJSPFvpKnnA7KmiTlvFU3OcgQRBCXbiSExU
         LhEAv1Rn2G6pAfNp9nTDHwr0XDkdin6a/oTKQPv2vWuLaIKeqzRVlKPufGlkVmHqBonQ
         eE23FD8HgkQ90pIo71PO207gfbA4+JIKaG09LX9UZrnrz+DZ/QSI/rFf9omsmkKDze2Q
         QBI+/VlWA2X6bZvWOsOTxIQMWRkR4Dg6wmBbxmCGmPX+VVN//L6O/6vPJCNR5HwzrIXE
         mmS6Zzy43VBM7UmyAt51zhiTPaHksVKUaOu4rzwmUQX5n+BVltaznOObZkJUuWfpSUJL
         /4ww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=krRP3KY1fGKj7cf+zc7TftkVbuz3X/Fy/C3+kHv3U/A=;
        b=j2TTFpPpKGErftIPmXQfEQpRiGZMzfuMppYolFQNfnJQlrSC2w9bv2wKXCTG9wxrvM
         MVUoEpcuzthpJPSnDl5BWOSP4WFp63vWTVgmaisHDR8iEcAMKjod2AXKL77Ljm9184VL
         7ctAtiAEpDeTSz6kedilSvUjCa1dTl6pIi+fRT+51QLcsuCgCP7SVJOcF5xnQPJlKKMt
         nRhHzyza+yKwqcuHkweW7AYA+YFQipJRrS0GGwv20lJ1Bdfmb5NCpf1vHTn9CUXB53xX
         fbC6mS+KxTlF8XFyq8K9yAl2PYLa7N2QHKjIuN08APp4xUAkTgizNZktUfW//u5DPOzJ
         wykA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 6si915194qtp.312.2019.03.14.09.16.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 09:16:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7F86F8553B;
	Thu, 14 Mar 2019 16:16:38 +0000 (UTC)
Received: from sky.random (ovpn-121-1.rdu2.redhat.com [10.10.121.1])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 375A117CEB;
	Thu, 14 Mar 2019 16:16:34 +0000 (UTC)
Date: Thu, 14 Mar 2019 12:16:30 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: Peter Xu <peterx@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>,
	linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Maxime Coquelin <maxime.coquelin@redhat.com>, kvm@vger.kernel.org,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>, linux-mm@kvack.org,
	Marty McFadden <mcfadden8@llnl.gov>,
	Maya Gokhale <gokhale2@llnl.gov>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	linux-fsdevel@vger.kernel.org,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3] userfaultfd: allow to forbid unprivileged users
Message-ID: <20190314161630.GS25147@redhat.com>
References: <20190311093701.15734-1-peterx@redhat.com>
 <58e63635-fc1b-cb53-a4d1-237e6b8b7236@oracle.com>
 <20190313060023.GD2433@xz-x1>
 <3714d120-64e3-702e-6eef-4ef253bdb66d@redhat.com>
 <20190313185230.GH25147@redhat.com>
 <1934896481.7779933.1552504348591.JavaMail.zimbra@redhat.com>
 <20190313234458.GJ25147@redhat.com>
 <298b9469-abd2-b02b-5c71-529b8976a46c@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <298b9469-abd2-b02b-5c71-529b8976a46c@redhat.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Thu, 14 Mar 2019 16:16:38 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 14, 2019 at 11:58:15AM +0100, Paolo Bonzini wrote:
> On 14/03/19 00:44, Andrea Arcangeli wrote:
> > Then I thought we can add a tristate so an open of /dev/kvm would also
> > allow the syscall to make things more user friendly because
> > unprivileged containers ideally should have writable mounts done with
> > nodev and no matter the privilege they shouldn't ever get an hold on
> > the KVM driver (and those who do, like kubevirt, will then just work).
> 
> I wouldn't even bother with the KVM special case.  Containers can use
> seccomp if they want a fine-grained policy.

We can have a single boolean 0|1 and stick to a simpler sysctl and no
gid and if you want to use userfaultfd you need to enable it for all
users. I agree seccomp already provides more than enough granularity
to do more finegrined choices.

So this will be for who's paranoid and prefers to disable userfaultfd
as a whole as an hardening feature like the bpf sysctl allows: it will
allow to block uffd syscall without having to rebuild the kernel with
CONFIG_USERFAULTFD=n in environments where seccomp cannot be easily
enabled (i.e. without requiring userland changes).

That's very fine with me, but then it wasn't me complaining in the
first place. Kees?

If the above is ok, we can implement it as a static key, not that the
syscall itself is particularly performance critical but it'll be
simple enough as a boolean (only the ioctl are performance critical
but those are unaffected).

The blog post about UAF is not particularly interesting in my view,
unless both of the following points are true 1) it can be also proven
that the very same two UAF bugs, cannot be exploited by other means
(as far as I can tell it can be exploited by other means regardless of
userfaultfd) and 2) the slab randomization was actually enabled (99%
of the time in all POC all randomization features like kalsr are
incidentally disabled first to facilitate publishing papers and blog
posts, but those are really the features intended to reduce the
reproduciblity of exploits against UAF bugs, not disabling userfaultfd
which only provides a minor advantage, and unlike in PoC environments,
we enable those slab randomization in production 100% of the time
whenever they're available in the kernel).

Thanks,
Andrea

