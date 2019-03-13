Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E84CC4360F
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:12:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F6A7213A2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:12:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F6A7213A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BADCC8E000E; Wed, 13 Mar 2019 15:12:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B35008E0001; Wed, 13 Mar 2019 15:12:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9FD558E000E; Wed, 13 Mar 2019 15:12:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 75A4D8E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 15:12:31 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id d49so2928052qtd.15
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:12:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:message-id:in-reply-to:references:subject:mime-version
         :content-transfer-encoding:thread-topic:thread-index;
        bh=JgTTL+MI+yOUzbfDM5lYSh2GyUh1ZZe2m/ktqPI/bUg=;
        b=RSc6Ug36FBdsdKDHhoD0T6iTkquJlixcmsXJGiH+fC87u7RPRlyul1IUErcHkjZ694
         3Scx0+qPQ7NmGICISkETGbOlTwq/jKB3kEvxjBwY+TmeUZmBdpmoJWXYWCNAPmxDSTHn
         8K04lsaG6x99XJGtU+hmPwaBA2EsuVbXXj3oYBqhfzxdK+SKGn8rJiSQTsm7QV/4Ajkv
         Tvj+J9L0uD2GyBCB3LiGwOLbjFzSDcz1tQ72RnnC5VMt2yZordWZWEHwtc8y37Imn8eo
         gvrxd1xHppAcpKDiLMU274I5/L/qOB86f8mWmEAGu7m1BzwOWt7lERKga6HTF8AfkjzD
         LLnw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of pbonzini@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=pbonzini@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU3sOQi+axCgG35DpH7AJsFRniPE+XSum90filLmO2jGg/aZ7e7
	caU842tFQ/VSvCTHOUkw9oB1bqmVcfwTUlzji2tl4d9A/8HTYg/efRJ9lBJF0bqNvT7DQU9obBl
	+5RvL6bios5sqysdZTHbM/KNMb2fXIvYczZM28obZRuQaJU0tE/ZyFNR/14uB/ZyWyQ==
X-Received: by 2002:ac8:2447:: with SMTP id d7mr235820qtd.162.1552504351264;
        Wed, 13 Mar 2019 12:12:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzHP61BDmsnAOnKNqxGA3yuSe/1DhFJj7XA1mO2I6EyHXfyvrgA9UYv7dzvOScSE4Q8TZ4L
X-Received: by 2002:ac8:2447:: with SMTP id d7mr235774qtd.162.1552504350628;
        Wed, 13 Mar 2019 12:12:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552504350; cv=none;
        d=google.com; s=arc-20160816;
        b=s+n2yJArRcwTJLbhNvRAMy3tMQgjHe0ftzhueM+lzhlLryx2fo8nvTnwhJDt7n1J+p
         OtMv8aK55S9I2OWZ16FKECgnDw/UHfnHMebUpEkw+VEj7cTfeZbvhjxq1lWaxp8u1Vsr
         EwJTEwJK0at311dvYgz+TDY9DtLIOpEiJOblnyCVRLxGUybshGi5Wb2NZdfegR72Mzvt
         FJ5D7KxrMGxdmL1q73R25JTBWonKlE3a5Nd8wQHDsFKhjAM4gSsWODqC6PcHMuqrqHXG
         ytF3FkJRks8AXLLf064+gsJyRq3BIZQ2eSKyJxz07Lft/rV8J7svKWw09y3i7ATghm+J
         Gmgg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=thread-index:thread-topic:content-transfer-encoding:mime-version
         :subject:references:in-reply-to:message-id:cc:to:from:date;
        bh=JgTTL+MI+yOUzbfDM5lYSh2GyUh1ZZe2m/ktqPI/bUg=;
        b=iieRkUHhItZpkhKWn7LEaR4mXj9yiqkXW4bp8JQvnhOzADEbIBl64+IX3HpfFumOOw
         7QyNyB+O163jHxjyU/Ecse6B/+SZJKiyLFKrVbXSkNFw3CBcpc4NalOaBmX/nHPLmnkN
         /Hpcwk2hVOH7LtgcB2j1MC+bzRXa/2v8OZAXXNDEwrg7uTkUPezbeBYgY9PXb8UaH2Ut
         Ylzd2x156qLccw1HKl2zMDlx9TYK1XDfrRFTlhZYERnxtj967OJr1itzYTH3/OStW4/L
         eYoU458eK8GJp24mPaJeb2VmgrQkrRSkQ6xGhBtnqU7E2yKmpuR9EmQ8SMY6Qc3yrliD
         eW2A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of pbonzini@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=pbonzini@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y53si843661qth.156.2019.03.13.12.12.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 12:12:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of pbonzini@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of pbonzini@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=pbonzini@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A331F3006030;
	Wed, 13 Mar 2019 19:12:29 +0000 (UTC)
Received: from colo-mx.corp.redhat.com (colo-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.20])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 694536591E;
	Wed, 13 Mar 2019 19:12:29 +0000 (UTC)
Received: from zmail18.collab.prod.int.phx2.redhat.com (zmail18.collab.prod.int.phx2.redhat.com [10.5.83.21])
	by colo-mx.corp.redhat.com (Postfix) with ESMTP id 09413181A136;
	Wed, 13 Mar 2019 19:12:29 +0000 (UTC)
Date: Wed, 13 Mar 2019 15:12:28 -0400 (EDT)
From: Paolo Bonzini <pbonzini@redhat.com>
To: Andrea Arcangeli <aarcange@redhat.com>
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
Message-ID: <1934896481.7779933.1552504348591.JavaMail.zimbra@redhat.com>
In-Reply-To: <20190313185230.GH25147@redhat.com>
References: <20190311093701.15734-1-peterx@redhat.com> <58e63635-fc1b-cb53-a4d1-237e6b8b7236@oracle.com> <20190313060023.GD2433@xz-x1> <3714d120-64e3-702e-6eef-4ef253bdb66d@redhat.com> <20190313185230.GH25147@redhat.com>
Subject: Re: [PATCH 0/3] userfaultfd: allow to forbid unprivileged users
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
X-Originating-IP: [93.56.166.5, 10.4.196.11, 10.5.101.130, 10.4.195.27]
Thread-Topic: userfaultfd: allow to forbid unprivileged users
Thread-Index: 6Xwu07wo6ALzDU1D4rR00nCA3NmgqQ==
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Wed, 13 Mar 2019 19:12:29 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


> On Wed, Mar 13, 2019 at 09:22:31AM +0100, Paolo Bonzini wrote:
> Unless somebody suggests a consistent way to make hugetlbfs "just
> work" (like we could achieve clean with CRIU and KVM), I think Oracle
> will need a one liner change in the Oracle setup to echo into that
> file in addition of running the hugetlbfs mount.

Hi Andrea, can you explain more in detail the risks of enabling
userfaultfd for unprivileged users?

Paolo

> Note that DPDK host bridge process will also need a one liner change
> to do a dummy open/close of /dev/kvm to unblock the syscall.
> 
> Thanks,
> Andrea
> 

