Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82BFBC10F03
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 00:21:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3F93B217F5
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 00:21:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3F93B217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ECEF56B0006; Tue, 19 Mar 2019 20:21:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EA47F6B0007; Tue, 19 Mar 2019 20:21:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D93346B0008; Tue, 19 Mar 2019 20:21:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id BE3516B0006
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 20:21:06 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id c25so677903qtj.13
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 17:21:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=v2ZLQ79QNXgeJU3MuIahWibb9/y73LMvedva2zDojCU=;
        b=UcCVjc2ndAYXHGzzHNrjYuj2SYVw0p9TTf0awEXKZAIU0SiJSQ7dgFjPKmt1FwtVgz
         NU1F18U8NhaZ2itEI+XWJ0PjDnAZNaS1vPSsHAk7jdtGCfkdMQstiQ8Xa/V88FATlnhG
         E9N7rO3QIXs1nw3IAhITN6R/4Aauu9lVxgP95yrc/tuDGtISWFuuYJsBy9osBAjHDkOP
         L+Y3meQIo5cghg0AcFOaJaJvtHZQ+/klfnD6txkWPUhonRJ6mt6GA5ij9eeR3Q8eIygl
         3gmGOpH4/towgBhNaqabRA5RH2ukKS7rStmGXgOuVqMr93EohHH/8QcRlDC3L/mFlxt0
         Br3g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUnPTNc+8fsWuHEL2G6wu6EmMxS7ZjMB0ZIxBN7L5xZI7IkG5ZW
	o2l3/54Rw2VhUOU2Y69EmnLJ1VEMZcAYOltyozRaRIoFn96xNfXte5OUHic3yZ+gnRqgWenwVBa
	4IDNBVoAIezP/yhcYCu9PEcOojgQNgmBXqA5vHlTy5PHqrxMNJODC1fSeVVlbcZrLJw==
X-Received: by 2002:aed:2219:: with SMTP id n25mr4347869qtc.288.1553041266552;
        Tue, 19 Mar 2019 17:21:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxNHDKNXa0NjOMbvMiIIEY3Bp1wnw2QFC5uqC3sI/Pb7I4yb9mq8Ntb7gJH9mdo5mrAU5NP
X-Received: by 2002:aed:2219:: with SMTP id n25mr4347836qtc.288.1553041265885;
        Tue, 19 Mar 2019 17:21:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553041265; cv=none;
        d=google.com; s=arc-20160816;
        b=SEnkwgq15tj9WQufBaF1WNLAohzXTi3MUWntz5eC/dRfihHRjr3N1tT0o16hOfpeoU
         kVhEZSSY6xLObZr22+fNz8i0/CZrY/1PjIDtXMPKl1Ke7vc/e3MgKZogs/UQhVshrhhB
         8nD9+YtiqNLw/LMSF4XmnZ5IcZyL3qWwFMYJSB3bxctzIiV4XzWb+7i4jBnvxRDjX1Sh
         N5PslzNeUdoQaQzVxXcHHqbtpGKTLOXwilK+N0ruSNqzsDGLMDpDke+4Lh6M7dO4mWtQ
         BRxayir4tzOgmwI3Ft/7K74QIVTXTNM+prNZS8RRFaW3eQUvA5wUd9aRB7GyWTBtPds8
         usEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=v2ZLQ79QNXgeJU3MuIahWibb9/y73LMvedva2zDojCU=;
        b=j8hiig0BUbWlxcR8FdYcTDEmQUVXABDxX7MsSrXvEf9XwI9K+PffdmGeg3N4fX8cQD
         mc3QqHIX4ny14heS+3OTGqT1AdyBWR3EjJm4dw4vLp9aq/k0dO1YYM/sdjo4IDVKRnLY
         Go5pS7EDr8XF7b3hhXbB1MeeqQo3yFoaGXJKJbKtUJu7S4rlFvaAxRTalL1InI8O//R9
         8rIIpNYBr0o5ThySKB/OOQ6UE/Ap0B+5CPkY9qB2XU4EkazJ3VjZSV95Rgy7BKhXHIHd
         diGs59l0bI4rTwxW/+wI31TLuSZNpwGjiChq0XkTP5QDjZZeuS+Y9piBHu++kcN9G8aM
         SFnA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 6si283416qtp.312.2019.03.19.17.21.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 17:21:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 337B8811A9;
	Wed, 20 Mar 2019 00:21:04 +0000 (UTC)
Received: from xz-x1 (ovpn-12-94.pek2.redhat.com [10.72.12.94])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 054F74D9E6;
	Wed, 20 Mar 2019 00:20:52 +0000 (UTC)
Date: Wed, 20 Mar 2019 08:20:43 +0800
From: Peter Xu <peterx@redhat.com>
To: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org,
	Paolo Bonzini <pbonzini@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Maxime Coquelin <maxime.coquelin@redhat.com>,
	Maya Gokhale <gokhale2@llnl.gov>,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>, linux-mm@kvack.org,
	Marty McFadden <mcfadden8@llnl.gov>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	linux-api@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v2 1/1] userfaultfd/sysctl: add
 vm.unprivileged_userfaultfd
Message-ID: <20190320002042.GA8956@xz-x1>
References: <20190319030722.12441-1-peterx@redhat.com>
 <20190319030722.12441-2-peterx@redhat.com>
 <20190319110236.b6169d6b469a587a852c7e09@linux-foundation.org>
 <20190319182822.GK2727@work-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190319182822.GK2727@work-vm>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Wed, 20 Mar 2019 00:21:05 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 06:28:23PM +0000, Dr. David Alan Gilbert wrote:
> * Andrew Morton (akpm@linux-foundation.org) wrote:
> > On Tue, 19 Mar 2019 11:07:22 +0800 Peter Xu <peterx@redhat.com> wrote:
> > 
> > > Add a global sysctl knob "vm.unprivileged_userfaultfd" to control
> > > whether userfaultfd is allowed by unprivileged users.  When this is
> > > set to zero, only privileged users (root user, or users with the
> > > CAP_SYS_PTRACE capability) will be able to use the userfaultfd
> > > syscalls.
> > 
> > Please send along a full description of why you believe Linux needs
> > this feature, for me to add to the changelog.  What is the benefit to
> > our users?  How will it be used?
> > 
> > etcetera.  As it was presented I'm seeing no justification for adding
> > the patch!
> 
> How about:
> 
> ---
> Userfaultfd can be misued to make it easier to exploit existing use-after-free
> (and similar) bugs that might otherwise only make a short window
> or race condition available.  By using userfaultfd to stall a kernel
> thread, a malicious program can keep some state, that it wrote, stable
> for an extended period, which it can then access using an existing
> exploit.   While it doesn't cause the exploit itself, and while it's not
> the only thing that can stall a kernel thread when accessing a memory location,
> it's one of the few that never needs priviledge.
> 
> Add a flag, allowing userfaultfd to be restricted, so that in general 
> it won't be useable by arbitrary user programs, but in environments that
> require userfaultfd it can be turned back on.

Thanks for the quick write up, Dave!  I definitely should have some
justification in the cover letter and carry it until the last version.
Sorry to be unclear at the first glance.

-- 
Peter Xu

