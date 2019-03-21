Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33646C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 21:06:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB83F21916
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 21:06:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB83F21916
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 456B96B0003; Thu, 21 Mar 2019 17:06:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 404776B0006; Thu, 21 Mar 2019 17:06:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2CCCB6B0007; Thu, 21 Mar 2019 17:06:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 08D276B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 17:06:25 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id q21so213024qtf.10
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 14:06:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=As8ETAWVZubBWoI2RZIiNEb93j2sf4q9iICzMLK5TLQ=;
        b=sgENYG3KQ6Rh4Alzogqsihdrw0Qvr2R6APJ6Ft99YAPCGRBeYN/Z7duzIqpYy/Ib2f
         j39Xzn2kWGILHIAyp0s/eD4vkCyEUG288y3fd2ZgnO1YuGaSUoLWKHmMIsxUE0MaIAkx
         0fInwmHkC3VeUUHfnDAbOzzu5uFqNimHC+KUn1VsAtMHFpJRRYrq3L899ELES25X8RFY
         gtGwiP3Jmb6pgvotMccSd5SRd9f/nf/OqIc9VhSQg3RQBkvUjobj3Kl2lvEUAKfgQZ9u
         TB/PTxiQ0FT0oYF7iGu6Enr9DDb7UwXr2TcAP1dU+cuJH+/wtkLOj8w7edFvXypyjWGr
         NGQg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWdR3B1zj44J47NMNGwTtVW1GdIRDvRRVwggpokGpk70n8HGBy7
	Tn2+luE5axeBYSAtcrH6rbkCxaMzYIyx1etILaQwhuchSnQPrkHTKEuFtIeTcHxQ2P23JI+4wYq
	vJ/kP+xk80YULQzTUAvyh8913Vs0UKhtmf8k0p1eycMPhCJAnffAFplQhoT2lGDD7Dw==
X-Received: by 2002:a05:620a:1438:: with SMTP id k24mr4405269qkj.165.1553202384837;
        Thu, 21 Mar 2019 14:06:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqylgF9PP40OpFRjqctVvCEfnkdMzGxVSAMf5kIlyttxES4K1nH5xBJNpBcXe+j7wuI8zwpI
X-Received: by 2002:a05:620a:1438:: with SMTP id k24mr4405203qkj.165.1553202383790;
        Thu, 21 Mar 2019 14:06:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553202383; cv=none;
        d=google.com; s=arc-20160816;
        b=m6VbvvVXRoSNHV+CzIGDR2tEPBIm4VoukpQgP/iBZUNIMZre+CQi5NiptYe2mXF0ht
         vp+4BLWQL9WpYUVFYm06n30TBGzMrp5PqQ5HkTEiATpf1AXVMeR4cktuxhB+KRM0jO3A
         YwxyND29souSHv6AK6Qr9aWF4BIh91bRuGSxlaV61diHHDAJHZoWHHAlKrsFmjUWDepg
         2xHQLgpV3mNUepoUx8/Fcs/zKhcE3t6qJ3u5SI4sbQP0essUu9/2dyWCwwOFDbXEXNPv
         zTxNmu5a6b9b6yzIebxOYubFKrliHwDP1MIAl6Gq6W2jkhV39jIzQJKnNeurdx+k6T7e
         aDtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=As8ETAWVZubBWoI2RZIiNEb93j2sf4q9iICzMLK5TLQ=;
        b=Db24peaUv0IbJpuuYOMXUah0c4x/l49DLiaNIIs/+ib3JRFyHjnArx+XTpr/BziUSc
         rLj9AtZQJbzN0Dpkdzftcg9O4gmypgUd2Wy5SRICw06AL+L/OL/7fKG/10VLl7uc+pT1
         KDWbgMkbw5p3EiUgPCS5Dl99ZR2OfZMKTHZEx0rPmasxrhxFNiXbbiWmDxuVzGO5Yfze
         HDo8CRCof5lyhj5yYO0keb9ugGR24cU/vWr/OgfBgbh4y2upM8hW4x2J2H0e5UKqa5in
         7RCw4OOlpPncyTSSaVT63CHzHVtq+4p4ebkKIBTPa5herzBfzKgN/n1XGrijEfHiUHB8
         Nh9A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 29si3820533qvy.135.2019.03.21.14.06.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 14:06:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B46F33092654;
	Thu, 21 Mar 2019 21:06:22 +0000 (UTC)
Received: from sky.random (ovpn-120-118.rdu2.redhat.com [10.10.120.118])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 041685D6B3;
	Thu, 21 Mar 2019 21:06:18 +0000 (UTC)
Date: Thu, 21 Mar 2019 17:06:17 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
To: Luis Chamberlain <mcgrof@kernel.org>
Cc: "Dr. David Alan Gilbert" <dgilbert@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Peter Xu <peterx@redhat.com>, linux-kernel@vger.kernel.org,
	Paolo Bonzini <pbonzini@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Maxime Coquelin <maxime.coquelin@redhat.com>,
	Maya Gokhale <gokhale2@llnl.gov>,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>, linux-mm@kvack.org,
	Marty McFadden <mcfadden8@llnl.gov>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	linux-api@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v2 1/1] userfaultfd/sysctl: add
 vm.unprivileged_userfaultfd
Message-ID: <20190321210617.GB22094@redhat.com>
References: <20190319030722.12441-1-peterx@redhat.com>
 <20190319030722.12441-2-peterx@redhat.com>
 <20190319110236.b6169d6b469a587a852c7e09@linux-foundation.org>
 <20190319182822.GK2727@work-vm>
 <20190320190112.GD23793@redhat.com>
 <20190321134335.GB1146@42.do-not-panic.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190321134335.GB1146@42.do-not-panic.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Thu, 21 Mar 2019 21:06:22 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

On Thu, Mar 21, 2019 at 01:43:35PM +0000, Luis Chamberlain wrote:
> On Wed, Mar 20, 2019 at 03:01:12PM -0400, Andrea Arcangeli wrote:
> > but
> > that would be better be achieved through SECCOMP and not globally.'.
> 
> That begs the question why not use seccomp for this? What if everyone
> decided to add a knob for all syscalls to do the same? For the commit
> log, why is it OK then to justify a knob for this syscall?

That's a good point and it's obviously more secure because you can
block a lot more than just bpf and userfaultfd: however not all
syscalls have CONFIG_USERFAULTFD=n or CONFIG_BPF_SYSCALL=n that you
can set to =n at build time, then they'll return -ENOSYS (implemented
as sys_ni_syscall in the =n case).

The point of the bpf (already included upstream) and userfaultfd
(proposed) sysctl is to avoid users having to rebuild the kernel if
they want to harden their setup without being forced to run all
containers under seccomp, just like they could by setting those two
config options "=n" at build time.

So you can see it like allowing a runtime selection of
CONFIG_USERFAULTFD and CONFIG_BPF_SYSCALL without the kernel build
time config forcing the decision on behalf of the end user.

Thanks,
Andrea

