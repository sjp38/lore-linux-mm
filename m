Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC93DC10F03
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 06:00:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 480BD20693
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 06:00:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 480BD20693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 991C68E0003; Wed, 13 Mar 2019 02:00:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 941FE8E0002; Wed, 13 Mar 2019 02:00:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 82FBB8E0003; Wed, 13 Mar 2019 02:00:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 595E78E0002
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 02:00:43 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id b4so832501qtp.20
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 23:00:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=018ORMi2AqK0r5jfu0m4Z5NwCXdFEvLOoIB0Tk5uq5k=;
        b=CXXddtMhmWoITDVllUW3NFmZ1HNS2bscZdXiU3+duyBGRXVLCzXBmqNFZHSovfW9sF
         dZVpC5hQ7vrMQP3sROQSYbuTG+AMowRwDkXKezNvKzRSnAQhsmz9m6/DBMoQ1dhh6Xe3
         DWoEvB46jGZBPu6hYVmLW3MSyjptWPfLvpfh3aR6uwOggHMkelOBi4O7dqG1Fl9FYsDF
         qB94eIRKKrYx038FHzW5DWwVoOZcFuPuoJKrTipGt4U4QZ+A7Vei47dVBEOgN8eWJ7Pa
         Kat/uOZbPZabTBNlSyDUAgPQ6KqWaDgjbfvI3j/hyaaqvlpM2cyqlbTh2yegk9gvcJyS
         25RA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUcykSOy8yTX4ZdlsqLtFiidSIhR6a0y/097EC5Vh0aejJ3GBqK
	XQPUedquWX9GhVAf092E9GydnBoybdFOUhRixk92rUFWo62ttiW1XUTjO4BYC2Zl5TkCKphuRz4
	YqvgC0ZrhINDQr9HIQED9kaZydl6GO5kUBTdHtnsmNNpVHyPT+7+pYizq4mjO9QwX2Q==
X-Received: by 2002:a0c:d165:: with SMTP id c34mr33099908qvh.64.1552456843153;
        Tue, 12 Mar 2019 23:00:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyDeC4sbaqj2uFh9liGgb7q52+Il3yXL5a4Y8qRUm6AKSVFrNmChFG2i3DAGHyIohNba8UK
X-Received: by 2002:a0c:d165:: with SMTP id c34mr33099881qvh.64.1552456842396;
        Tue, 12 Mar 2019 23:00:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552456842; cv=none;
        d=google.com; s=arc-20160816;
        b=mbj3iHjd37BDT2cgDmDGZaexOTZul8eSTx6VJrBnf7ww+3deIZj3z8b19GZ3HxYTvp
         5z1XPNlZg08rOQ2Nfe2s86PvKkttYbwb15HM5sjLP8M9KE+qtaxxOeewPy0yqnk/arDA
         pWuYMaEgW3URsk/kdk2pzE4lXGqx+ga+Yd+lH/MyuxbOSYwPepGTQKhzOjcZuEAbex6t
         pFqrvV5lwL7Y1tEfT/tFJpnqy01hzjSi5q26JU8TC6y0S+b77QtK7UQfVK0NTnKpnbeZ
         jEW+O2tCjepgruMCj9IQL981/tugb90JIqFhINWkaEyuWoPgb1Hk0cEYnJJACXe/GY9S
         aU6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=018ORMi2AqK0r5jfu0m4Z5NwCXdFEvLOoIB0Tk5uq5k=;
        b=tNm3xu9cBI7Cq7G4h44k3pvg5NOrQEEMMP9B6hTKP473A6j+oh/N1Z9AYhd9l0AHh+
         L9hVKIAQod75286sMknfQtOQ6pKka/cjT6tM5T+iBuO7M4eveOoAQZ7dHTJySPnPlO6v
         Hw3QShzAa4brPFaLHquLuqotsqzmGpLN9lT4F2wcdIznfTQGMlE8H3r/A9pwG5eDzNRz
         R0HGKa6xy1FBWXZdG1dAkhgFxJOy9E1GjGqWt4BreauEIEzIsrYee1t55LhPOWOgcN+R
         qScuMZj8OWSr1N+q6UxqtYbDINuee8qwP/7zuB9FCdZMxNyCBV49rj226Tbd4MixdP9h
         pOow==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m25si2536802qka.75.2019.03.12.23.00.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 23:00:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BA00688E52;
	Wed, 13 Mar 2019 06:00:40 +0000 (UTC)
Received: from xz-x1 (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id AB48B27CD9;
	Wed, 13 Mar 2019 06:00:26 +0000 (UTC)
Date: Wed, 13 Mar 2019 14:00:23 +0800
From: Peter Xu <peterx@redhat.com>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-kernel@vger.kernel.org, Paolo Bonzini <pbonzini@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Maxime Coquelin <maxime.coquelin@redhat.com>, kvm@vger.kernel.org,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>, linux-mm@kvack.org,
	Marty McFadden <mcfadden8@llnl.gov>,
	Maya Gokhale <gokhale2@llnl.gov>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	linux-fsdevel@vger.kernel.org,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3] userfaultfd: allow to forbid unprivileged users
Message-ID: <20190313060023.GD2433@xz-x1>
References: <20190311093701.15734-1-peterx@redhat.com>
 <58e63635-fc1b-cb53-a4d1-237e6b8b7236@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <58e63635-fc1b-cb53-a4d1-237e6b8b7236@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Wed, 13 Mar 2019 06:00:41 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 12:59:34PM -0700, Mike Kravetz wrote:
> On 3/11/19 2:36 AM, Peter Xu wrote:
> > 
> > The "kvm" entry is a bit special here only to make sure that existing
> > users like QEMU/KVM won't break by this newly introduced flag.  What
> > we need to do is simply set the "unprivileged_userfaultfd" flag to
> > "kvm" here to automatically grant userfaultfd permission for processes
> > like QEMU/KVM without extra code to tweak these flags in the admin
> > code.
> 
> Another user is Oracle DB, specifically with hugetlbfs.  For them, we would
> like to add a special case like kvm described above.  The admin controls
> who can have access to hugetlbfs, so I think adding code to the open
> routine as in patch 2 of this series would seem to work.

Yes I think if there's an explicit and safe place we can hook for
hugetlbfs then we can do the similar trick as KVM case.  Though I
noticed that we can not only create hugetlbfs files under the
mountpoint (which the admin can control), but also using some other
ways.  The question (of me... sorry if it's a silly one!) is whether
all other ways to use hugetlbfs is still under control of the admin.
One I know of is memfd_create() which seems to be doable even as
unprivileged users.  If so, should we only limit the uffd privilege to
those hugetlbfs users who use the mountpoint directly?

Another question is about fork() of privileged processes - for KVM we
only grant privilege for the exact process that opened the /dev/kvm
node, and the privilege will be lost for any forked childrens.  Is
that the same thing for OracleDB/Hugetlbfs?

> 
> However, I can imagine more special cases being added for other users.  And,
> once you have more than one special case then you may want to combine them.
> For example, kvm and hugetlbfs together.

It looks fine to me if we're using MMF_USERFAULTFD_ALLOW flag upon
mm_struct, since that seems to be a very general flag that can be used
by anything we want to grant privilege for, not only KVM?

Thanks,

-- 
Peter Xu

