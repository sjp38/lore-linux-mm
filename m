Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A54A9C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 03:07:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70C04205F4
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 03:07:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70C04205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EB63C6B0005; Mon, 18 Mar 2019 23:07:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E979C6B0006; Mon, 18 Mar 2019 23:07:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA3006B0007; Mon, 18 Mar 2019 23:07:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id B95416B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 23:07:38 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id q12so15459231qtr.3
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 20:07:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=cqg0tDoTWXlWdI4/wgOCYEKFFzITe9p6s/mFURDTDew=;
        b=PjoomJWFzYlqzHE1rjIDh46ZUQwFJM0ZEUW2C0cqyIWogh1YDlMPTKPthP5m8hJPF7
         OqhrAuZhVn8Eo42KLNjIn/FLk/ym0RDOV+q4suaEDKOVs319W1GRJKZAFmvGCD4XS1Jq
         rS+Ebu/1xOugkRTYH7MBI8wZcNs0Ktnu9PC98+0oTGlhXq4kH2Sm1na3XmJCQh0ic0R6
         ErVvF0nNgfzyb1TRRWhGGDk4zCDD5fSNSnTvUCeh1IIa40JZ6yO0kp132fTJhEeIGl1N
         k+KzWiAu1Q16/W4hrKxwEDyWwkeQWLwknNo1hPP347c7GbXg/USfhSCh2Qt1IQi8DmN3
         XuOA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX1mEQUgB7JxEFJ6c6L//rNsbZoLn4ZMhDoxeQjhKY8CPbq96tI
	2cvXUDqisBKFW7mEvqJy8K92ye5qnAoTxuibW4onFbpyHP12RYtU93SYTBXng+vfPTFfxHW0TfG
	B69WZb4OkLd5ZkCiCMrT4Ryky+1K5xIF59cHrtGCufUz2lW2Rwd1/QkPjklQ0kp/nxA==
X-Received: by 2002:ac8:2230:: with SMTP id o45mr151585qto.111.1552964858499;
        Mon, 18 Mar 2019 20:07:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwBIZ+zn1gFWeJaAxlxaW+oxmSpLAQGNZCW5ZNg1y3cqdl7b8GZ+CR6Lni8/tov63gd90+D
X-Received: by 2002:ac8:2230:: with SMTP id o45mr151555qto.111.1552964857599;
        Mon, 18 Mar 2019 20:07:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552964857; cv=none;
        d=google.com; s=arc-20160816;
        b=M1VUJai6U8k2jOO6UHAHSNB+l5PxaDRbXSfTTbrCwQPSTVeAIGzJRIybkzfVXE/MEB
         lXAVDRF/ZbWzx8IapnN1GFEH2nJ9uL/wbVPH5sCvOncV3pILfsNMaDJ5S18DWakJQ5wd
         xWEtA7IK3uw/GOo5Yr+kcn2anxZ64lOCXYZKOuelETVX47ieA0cuBFqW/iMoSg/mDAjM
         UXDEuCYjFJBy7wYGCxoJMxuGBs347hvT6yPvPw+bTEQNO7k5kiPr/H//LYxI+3os0auq
         PdTuIFCC+8eQETLmd9D7PIopNEO6ai9VAYEAwdG1Dlmyw90vWN60WLVMyHvxmYdT+YRB
         R1/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=cqg0tDoTWXlWdI4/wgOCYEKFFzITe9p6s/mFURDTDew=;
        b=OPN+gui6AyEO2rv+hvJweMeEbquMqPc4Mu52x9LY9YClwOI3O2f6kJEyH1oiZcYZ2G
         jO7nWy6/KcEdi0pq7MOYhLeOPs5PFbUnfS3sMK3SHlHT/NrUCZ4leUL1V8evLCAW5U3T
         hemRf3xr4F12x7qWdblL9QBP/CvuRw5ykfaqhDoV8+DHHDfHiV1d2oS1gYgwuJz5ouRl
         lQQKrGQaxKkdrh4ROYlhh0v0ArTYP1GquK5eGqxvB3xAclSnwn0DdjKvKyyQ8cvkVi84
         1srAM+1WYhzreI4nk5+S9esB5cHhFtic2zn8MIU09LilCOXKlB22bQaDFGLTQFyqYp6i
         3zOA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p2si2080127qkm.100.2019.03.18.20.07.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Mar 2019 20:07:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0353A308425C;
	Tue, 19 Mar 2019 03:07:36 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 85F6A5D707;
	Tue, 19 Mar 2019 03:07:23 +0000 (UTC)
From: Peter Xu <peterx@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Paolo Bonzini <pbonzini@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Maxime Coquelin <maxime.coquelin@redhat.com>,
	Maya Gokhale <gokhale2@llnl.gov>,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	peterx@redhat.com,
	Martin Cracauer <cracauer@cons.org>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	linux-mm@kvack.org,
	Marty McFadden <mcfadden8@llnl.gov>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Kees Cook <keescook@chromium.org>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	linux-api@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH v2 0/1] userfaultfd: allow to forbid unprivileged users
Date: Tue, 19 Mar 2019 11:07:21 +0800
Message-Id: <20190319030722.12441-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Tue, 19 Mar 2019 03:07:36 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

This is the second version of the work.  V1 was here:

https://lkml.org/lkml/2019/3/11/207

I removed CC to kvm list since not necessary any more, but added
linux-api to the list as suggested by Kirill.

This one greatly simplifies the previous version, dropped the kvm
special entry and mimic the sysctl_unprivileged_bpf_disabled knob for
userfaultfd as suggested by many.  The major differences comparing to
the BPF flag are: (1) use PTRACE instead of ADMIN capability, and (2)
allow to switch the flag back and forth (BPF does not allow to switch
back to "enabled" if "disabled" once).

So the main idea of this simpler version is that we still keep the old
way as is by default but we only provide a way for admins when they
really want to turn userfaultfd off for unprivileged users.

About procfs vs sysfs: I still used the procfs way because admins can
still leverage sysctl.conf with that and also since no one yet
explicitly asked for sysfs for a better reason yet (And I just noticed
BPF just added another bpf_stats_enabled into sysctl a few weeks ago).

Please have a look, thanks.

Peter Xu (1):
  userfaultfd/sysctl: add vm.unprivileged_userfaultfd

 Documentation/sysctl/vm.txt   | 12 ++++++++++++
 fs/userfaultfd.c              |  5 +++++
 include/linux/userfaultfd_k.h |  2 ++
 kernel/sysctl.c               | 12 ++++++++++++
 4 files changed, 31 insertions(+)

-- 
2.17.1

