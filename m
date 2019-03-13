Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4DD4EC4360F
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 18:52:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DEE7520854
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 18:52:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DEE7520854
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 52C718E0003; Wed, 13 Mar 2019 14:52:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4DAAE8E0001; Wed, 13 Mar 2019 14:52:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3CB928E0003; Wed, 13 Mar 2019 14:52:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1F39C8E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 14:52:40 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id o135so2414821qke.11
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 11:52:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=M+JZ8TeFWmIFE2e1xRH/xC27DrG2i8KzHZ+5mJ5JOr4=;
        b=E9TTpIEdzZwIxwbBY6Wbd5wFs18xyj3iW/Bjcb5RHDj96SC4Dm2F1VE/apLTiF1Jco
         X4q2PhLwvd0eLydZkEoqqxgmrw0t3fcu7cEZW4sWYKK6pKStnPUypzMVX+pk1fMDNbgm
         NFQYzxsugz3tprfIP6rnPGCNqo3z5RPurNWzZATZEJvFcPn3dj8EtHI5/kMIYw1o3UTX
         yAn+Wv5DMXLk5Q9c1L8q4mAKczYYknKDFHS+I1ZAL40qIGduRBaVH70wwYPt33y7Lwj5
         UR7XgdjZ520mXMUTiX9QnU433Js3mXbt5rSLgEzB471tyk73kRTGpJjI5/U9pV4rZeKF
         ag/w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWD4rrXd7+lm0Ql73ExgO0/6GiBGx5SMvZlRjHGBUomuf3vDRU7
	K1kJzdNO7uJXJJQlkxzL05yNOWoO4QJw3XgUhV7hUAybdUcFEdbw8XvX/aHIaEX+CSgRD1TAPen
	KjRfTuijpKUT1b7EWNjaiH3OywLmwUubCPeIFd/L1c7STKykIbYAZxq4xkqCETG++Bw==
X-Received: by 2002:aed:3781:: with SMTP id j1mr1957795qtb.380.1552503159335;
        Wed, 13 Mar 2019 11:52:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy2/uNhvxJ86lRLnK0kaqHYNHOhUbML0Xnr4qhrpBrCpx/4G8tcap+6tBo3AcEvQD+HKBi0
X-Received: by 2002:aed:3781:: with SMTP id j1mr1957725qtb.380.1552503158208;
        Wed, 13 Mar 2019 11:52:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552503158; cv=none;
        d=google.com; s=arc-20160816;
        b=r7Lxyt38LqNBX9q2Zf9bcoO5/mhRH7QEvkKaJemzc2Q8KbBOQ8XIXdQzZGI0WEiv4E
         rD5OuN4b9L9NettHsd6yHEn1R6lRRsr/3ea+EU9fEAQQne0+g1Sou+A3H7NzI4Gu3q8o
         J6yztU5/XfF6qWVTCO3IDmZysjI6ceNyOjFF/7ogOlB9ZxhwPP9wAJDFHnn5sqbZu9ZB
         kSf3V4mjOzt7IWm4tiW7ALgR6SALziKYJaCA69O8F57oiq5loFuP4YoIawVv5DruRT8b
         MEwr7lUvndFuc2BS9WkdMfXcXjuvTQxnvUmi8RtvUTueT8aKSR7cY6KxV4ilBHNsLr9Q
         DTrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=M+JZ8TeFWmIFE2e1xRH/xC27DrG2i8KzHZ+5mJ5JOr4=;
        b=EkjR+nTQIvfQFV4AZXL0PhlNcgoi3BjHOe0IIs53QXWtYSCsgZ87Pxo3ylDRvx1M6e
         91YyeVbbOBv/WXUI9pe2Ho6xFcPHExYDGh1+FLgaS5Az7p4xaCo5Ia2XgV5kpzoMz5cV
         4KpUQhyETjk2ySp3R3DW3EwDtVKEqVuZr4aeNTvF9QPeXf8IQHNmzp+gQirKKAihB3fP
         6I9fIwH7pRpJOgb+eaEjmZUSxn/yXhDMdpQWm+BAF04o4FvKOvt4e1Xz2JHfpNN+Qvtr
         buwUpysEvPKEc63zzSz0qepw1wcirwwStD4c3Tes8DegNLxpKAF9KD46xcO6D+VKxf5U
         Eu6g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h46si3263079qth.279.2019.03.13.11.52.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 11:52:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A5726307E042;
	Wed, 13 Mar 2019 18:52:36 +0000 (UTC)
Received: from sky.random (ovpn-121-1.rdu2.redhat.com [10.10.121.1])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id C6BA46058F;
	Wed, 13 Mar 2019 18:52:31 +0000 (UTC)
Date: Wed, 13 Mar 2019 14:52:30 -0400
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
Message-ID: <20190313185230.GH25147@redhat.com>
References: <20190311093701.15734-1-peterx@redhat.com>
 <58e63635-fc1b-cb53-a4d1-237e6b8b7236@oracle.com>
 <20190313060023.GD2433@xz-x1>
 <3714d120-64e3-702e-6eef-4ef253bdb66d@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3714d120-64e3-702e-6eef-4ef253bdb66d@redhat.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Wed, 13 Mar 2019 18:52:37 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

On Wed, Mar 13, 2019 at 09:22:31AM +0100, Paolo Bonzini wrote:
> On 13/03/19 07:00, Peter Xu wrote:
> >> However, I can imagine more special cases being added for other users.  And,
> >> once you have more than one special case then you may want to combine them.
> >> For example, kvm and hugetlbfs together.
> > It looks fine to me if we're using MMF_USERFAULTFD_ALLOW flag upon
> > mm_struct, since that seems to be a very general flag that can be used
> > by anything we want to grant privilege for, not only KVM?
> 
> Perhaps you can remove the fork() limitation, and add a new suboption to
> prctl(PR_SET_MM) that sets/resets MMF_USERFAULTFD_ALLOW.  If somebody
> wants to forbid unprivileged userfaultfd and use KVM, they'll have to
> use libvirt or some other privileged management tool.
> 
> We could also add support for this prctl to systemd, and then one could
> do "systemd-run -pAllowUserfaultfd=yes COMMAND".

systemd can already implement -pAllowUserfaultfd=no with seccomp if it
wants. It can also implement -yes if by default turns off userfaultfd
like firejail -seccomp would do.

If the end goal is to implement the filtering with an userland policy
instead of a kernel policy, seccomp enabled for all services sounds
reasonable. It's very unlikely you'll block only userfaultfd, firejail
-seccomp by default blocks dozen of syscalls that are unnecessary
99.9% of the time.

This is not about implementing an userland flexible policy, it's just
a simple kernel policy, to use until userland disables the kernel
policy to takeover with seccomp across the board.

I wouldn't like this too be too complicated because this is already
theoretically overlapping 100% with seccomp.

hugetlbfs is more complicated to detect, because even if you inherit
it from fork(), the services that mounts the fs may be in a different
container than the one that Oracle that uses userfaultfd later on down
the road from a different context. And I don't think it would be ok to
allow running userfaultfd just because you can open a file in an
hugetlbfs file system. With /dev/kvm it's a bit different, that's
chmod o-r by default.. no luser should be able to open it.

Unless somebody suggests a consistent way to make hugetlbfs "just
work" (like we could achieve clean with CRIU and KVM), I think Oracle
will need a one liner change in the Oracle setup to echo into that
file in addition of running the hugetlbfs mount.

Note that DPDK host bridge process will also need a one liner change
to do a dummy open/close of /dev/kvm to unblock the syscall.

Thanks,
Andrea

