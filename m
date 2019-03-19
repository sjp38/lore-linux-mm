Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.7 required=3.0 tests=DATE_IN_PAST_12_24,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1241C10F05
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 06:09:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C4DB2184D
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 06:09:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C4DB2184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A8936B0006; Wed, 20 Mar 2019 02:09:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 057B36B0007; Wed, 20 Mar 2019 02:09:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E62846B0008; Wed, 20 Mar 2019 02:09:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id C66DF6B0006
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 02:09:12 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id h51so1316292qte.22
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 23:09:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=aCmAr6euZN4AX+hXU5UkOblwfcl12csePzwJvFQgccg=;
        b=mNFZVDhtk2sZzbWIBHVF6BehlfpmcIK0VIRSvI0qQv4/F+vf0o0Gl9wu8MLOSVlOpG
         BpBShaCVqyQ8wH0uxvmGQkY+yGIZ5zv1Ys2SsEqpdnNkbWgWqrRnJIUkDjo8eU/o7T24
         XCd4/qWnN5uF/1qXUaIu4Xbp8fVgUa2vtWc/HlRrVMydfUPYDNWPFvE6e+hFlFtmx02O
         RFE8rkqr6eCGqnHckSHJ2EojKti/PMh3QJE0Oh27qiSQA9A8kOM6VBW32Y+TvuAzq+UI
         DzvwbR2Hdp3fzjtvHvS3BtFqleNNOEJBUJFtyO1C2/+7yOIovmoTfTSO/ynTU/zxEHDC
         ST1g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVMvCs5Jr6IOdo6PFWjhoWCK2UWw/fhgBuVsW9bSNgQy66GkfpC
	0zng++jlnszhma1jjsv98RNPMZLO9CrqwyTVzgxYX+e4yQDqLX//si59VIdNcgNp0L9/+b1yFK7
	jCCDu6JcEwJHggBh4ESv66F7ZlYHa2rjjN0GlFPQaLzEJM9zlHrQr6o1glor5zUN4IQ==
X-Received: by 2002:a0c:e74b:: with SMTP id g11mr5114540qvn.183.1553062152512;
        Tue, 19 Mar 2019 23:09:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy88VpeLTk0kXsB1w0uZ3+tZVHDW0aU2Uqjr53+IQirqXXhNs9f1izLi4S8IA8MWpN9oQ49
X-Received: by 2002:a0c:e74b:: with SMTP id g11mr5114482qvn.183.1553062151422;
        Tue, 19 Mar 2019 23:09:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553062151; cv=none;
        d=google.com; s=arc-20160816;
        b=05exDyXcULFPHlIU3Yht+drsta3n5pAiFkIEAFpIf3kUgGYOveTc3hAy+RWvpJ5lIB
         iFAtQ5fA/PsGj4qzL3Skwvy/b1S8DTLVPQ/770ArDv4WQLI5j8vaYS+/iCeDfU2mbETL
         ybCw8Z0pOXyjmKaKj5H3RhsFPWRUTE60G/zRJMJmK4vJtL+DuUONJZQ3y8q3eybPSLSa
         xWWsw9Q7ql2WzB1KSlk0r6pV3osasU94DIHWgTK5NeKGbStd8VL1we6SOCILJK7OAX1Y
         n45vAPmc2+rBmaLTT5TI9l/0U+EeGXP1ZHE/WKSUOpYQ5UPNOUBwPhamKljbFzLOAV/9
         QOxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=aCmAr6euZN4AX+hXU5UkOblwfcl12csePzwJvFQgccg=;
        b=EjayDj0H2L8hIfr38FV7OEmr/D5pu+QJhqgOAVlQoe7CQjfZZpLttjckZmdlQoxuJw
         D60VYoHAJmXvo40pmvVAVu01QpWY7uC6T3mrNuGzfFP228eJbF1zB/Ke0rkkOup+X3bH
         Hqng4SklaC5k/SMEVi1XqXIhDCxsLeCO8Vj9ZN1TjBgmvY8FJbmgqgUDu+xYheLjHhCH
         pab9VactlPwXIm95O5QZx+5PuQzyI83ww/FJ7HsYqQyy+JzmFgsjszmoF8TMgqC7EZuN
         Bo0rFYs2e7md5XRR8hFve3b87KXEdBIXBlCv3RoyvijL6atXmuISdlDeCvuveUra6Z3E
         UHxw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c18si488514qve.186.2019.03.19.23.09.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 23:09:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id DB45883F40;
	Wed, 20 Mar 2019 06:09:09 +0000 (UTC)
Received: from sky.random (ovpn-120-78.rdu2.redhat.com [10.10.120.78])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 8C5652E02F;
	Wed, 20 Mar 2019 06:09:03 +0000 (UTC)
Date: Tue, 19 Mar 2019 14:07:29 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
To: Mike Rapoport <rppt@linux.ibm.com>
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
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	linux-api@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 1/1] userfaultfd/sysctl: add
 vm.unprivileged_userfaultfd
Message-ID: <20190319180729.GA27618@redhat.com>
References: <20190319030722.12441-1-peterx@redhat.com>
 <20190319030722.12441-2-peterx@redhat.com>
 <20190319071104.GA6392@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190319071104.GA6392@rapoport-lnx>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Wed, 20 Mar 2019 06:09:10 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

On Tue, Mar 19, 2019 at 09:11:04AM +0200, Mike Rapoport wrote:
> Hi Peter,
> 
> On Tue, Mar 19, 2019 at 11:07:22AM +0800, Peter Xu wrote:
> > Add a global sysctl knob "vm.unprivileged_userfaultfd" to control
> > whether userfaultfd is allowed by unprivileged users.  When this is
> > set to zero, only privileged users (root user, or users with the
> > CAP_SYS_PTRACE capability) will be able to use the userfaultfd
> > syscalls.
> > 
> > Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
> > Suggested-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> > Signed-off-by: Peter Xu <peterx@redhat.com>
> 
> Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>
> 
> Just one minor note below

This looks fine with me too.

> > +	if (!sysctl_unprivileged_userfaultfd && !capable(CAP_SYS_PTRACE))
> > +		return -EPERM;

The only difference between the bpf sysctl and the userfaultfd sysctl
this way is that the bpf sysctl adds the CAP_SYS_ADMIN capability
requirement, while userfaultfd adds the CAP_SYS_PTRACE requirement,
because the userfaultfd monitor is more likely to need CAP_SYS_PTRACE
already if it's doing other kind of tracking on processes runtime, in
addition of userfaultfd. In other words both syscalls works only for
root, when the two sysctl are opt-in set to 1.

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

