Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,T_HK_NAME_DR,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D726C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 18:28:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF2402082F
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 18:28:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF2402082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 32A0C6B0005; Tue, 19 Mar 2019 14:28:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D7176B0006; Tue, 19 Mar 2019 14:28:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 17A4C6B0007; Tue, 19 Mar 2019 14:28:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id E00CE6B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 14:28:45 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id l10so16249178qkj.22
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 11:28:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=30apmnEQmfNZjkyK96GSJdVik20/1QA65Tr6Etwrt5A=;
        b=jO1xsjiTebMsspZFAJCCe535ixST/R8r7ElAhWKZT/pmUsSqixYHYtnZHDiuY9Wtr6
         wxgfMt4mI4FsfWjRW+/BVibjwHPpmCSjmXUlb6CqFURkKhanQEhlETqZwi84W+Uclm5U
         ZdziPdN+YFswpqsbyTEMS4i3ETHpa4zZfqpWttSHJVFP3fStfUNxR17nevlJ8Isb0R6i
         wcxOPJzKeNBXkUMq5PUzEmStq2v39X4SnUC/Uz1ylE2zJxOS+tAFZ+Rrn9gAAd3gB3jn
         c9eU6nKcrUrdSE9jXfO9jYRwWGu9BW1lq5uoyTS9uBy3aw8n2wQ+1/rx56EC0NQMuQ40
         PsCA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dgilbert@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dgilbert@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVu/jGtRUi4vR73e8Sqa0JjRMf10HOaxJ+wikEF2DZfiMY2S7g7
	3/pzxmaXSaxgtv41Go0gePkOQrTGfQ/JKGA3u/4a1GLAoRaWq3s+/8pw3t2XNoBlL97XyO+QXI9
	58lf4LdkgwMBW6npUA2GP9CVdiIItsbWZ2kAs08ooTfImoQUsqgA7StnmmT/gsq/LJg==
X-Received: by 2002:ac8:6a10:: with SMTP id t16mr3156722qtr.242.1553020125597;
        Tue, 19 Mar 2019 11:28:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyD5wnjw2A1VHpwkfao6xrAgErgehaCore/b0UmOl6LQCedKNfUH6ubcmbvpBPrdWr/N0GH
X-Received: by 2002:ac8:6a10:: with SMTP id t16mr3156668qtr.242.1553020124773;
        Tue, 19 Mar 2019 11:28:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553020124; cv=none;
        d=google.com; s=arc-20160816;
        b=vT60WtUrU1/dJeyBlzO4lXxQ22v8A5Gp5Abiijb8fcxGtlZbtLf3yOiaFQVRPSPq6w
         3qUYsOATBDtEMRI749mFCFW4Ymvtmnm/Shpw8j17hMYPWbKolPklRfB4DdCpqPzWgQUI
         FdVX9J5EsqC66V8R5BVfYjYeYXzcSE3thVLnX9umLZyM/2Xi241WLrD+u6CDtHTlF0Ix
         gTnf/rUy5DkHhRMTKJxP6Cn7hWbUvRIcTyvsa1eEsqDntmxHo8FSSRpdjETFzkiZOfKo
         lL35cGsxskUqZT7ugBMzmwreP2RBCmjKCrrL6VCrRa/i768qoCQ9iczoap3rNSYN4l4D
         pX3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=30apmnEQmfNZjkyK96GSJdVik20/1QA65Tr6Etwrt5A=;
        b=usEoBF70HYL3RMGhBPGYxe6hHbrJjjFJutBx6vMEhYn5pch4PpOw6W3izBNJQ9COM1
         wT42IWcPWMBILzsQ4MGwqdKTQEajK4QGqLEjEWDVvXEfNu8gd4Vwi8weZmJHfiHNSckl
         avQcuDtHmIqf5G2HQiQU1GUI52CUhKaF5e/z3rK5W91vDzAvPnNLaFNgaHy92yEogPTa
         0jnNKd/quxJs21VXjj9q5LfyEFbA+/8fsU5fo+ZT4Exfb4kI09jH5fD6zI0RVYSQXk4R
         +Mgv3885KF35YPw24VsdvaI8ZU8hyzKYsIEQhG1qRtKTWWNTrdKR3T3OfGl6B24F99kA
         DARg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dgilbert@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dgilbert@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t7si3512395qtd.292.2019.03.19.11.28.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 11:28:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of dgilbert@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dgilbert@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dgilbert@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 11AFA81F31;
	Tue, 19 Mar 2019 18:28:43 +0000 (UTC)
Received: from work-vm (ovpn-117-168.ams2.redhat.com [10.36.117.168])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 1867F611CD;
	Tue, 19 Mar 2019 18:28:25 +0000 (UTC)
Date: Tue, 19 Mar 2019 18:28:23 +0000
From: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Xu <peterx@redhat.com>, linux-kernel@vger.kernel.org,
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
Message-ID: <20190319182822.GK2727@work-vm>
References: <20190319030722.12441-1-peterx@redhat.com>
 <20190319030722.12441-2-peterx@redhat.com>
 <20190319110236.b6169d6b469a587a852c7e09@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190319110236.b6169d6b469a587a852c7e09@linux-foundation.org>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Tue, 19 Mar 2019 18:28:44 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

* Andrew Morton (akpm@linux-foundation.org) wrote:
> On Tue, 19 Mar 2019 11:07:22 +0800 Peter Xu <peterx@redhat.com> wrote:
> 
> > Add a global sysctl knob "vm.unprivileged_userfaultfd" to control
> > whether userfaultfd is allowed by unprivileged users.  When this is
> > set to zero, only privileged users (root user, or users with the
> > CAP_SYS_PTRACE capability) will be able to use the userfaultfd
> > syscalls.
> 
> Please send along a full description of why you believe Linux needs
> this feature, for me to add to the changelog.  What is the benefit to
> our users?  How will it be used?
> 
> etcetera.  As it was presented I'm seeing no justification for adding
> the patch!

How about:

---
Userfaultfd can be misued to make it easier to exploit existing use-after-free
(and similar) bugs that might otherwise only make a short window
or race condition available.  By using userfaultfd to stall a kernel
thread, a malicious program can keep some state, that it wrote, stable
for an extended period, which it can then access using an existing
exploit.   While it doesn't cause the exploit itself, and while it's not
the only thing that can stall a kernel thread when accessing a memory location,
it's one of the few that never needs priviledge.

Add a flag, allowing userfaultfd to be restricted, so that in general 
it won't be useable by arbitrary user programs, but in environments that
require userfaultfd it can be turned back on.

---

Dave

--
Dr. David Alan Gilbert / dgilbert@redhat.com / Manchester, UK

