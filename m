Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05EB6C10F00
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 15:35:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BEF382171F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 15:35:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BEF382171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5DAC38E0006; Tue, 12 Mar 2019 11:35:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 58A908E0002; Tue, 12 Mar 2019 11:35:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 453538E0006; Tue, 12 Mar 2019 11:35:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 23A568E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 11:35:37 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id b1so1725894qtk.11
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 08:35:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=qGDVXQAEG+Kh+H/FqBzQ/NnTMp/1LNIvNV/PoqSppKI=;
        b=JjIJvoy8AHySYYR3FzGaJd3edwY/G+ROyMwjElyMVmHA7clCcsBZhTXBxChxtoiTFF
         aNRiDVtInwOteqYNbosLc5KoAXE/3ZARMZ1GhFjGgitcNC+wsOw4qbwsQjNjgD2IxKbC
         YOi4LJ7zHXfE0SbBMqBdoNHUfX/CzJvxOMRKJ7J2YSBnd59TcIUYuBuOt5REMy0rZ8tI
         9q/wz9IQlYO6DJtN0V8zeu/LXSsjiNXm2vJQ+qdx4085CSCcS8F9rUjosAPic3sQJSmB
         yWQ7NkRzz29C/ezK0E5iJ2Vqss2y9yHYtzsSMcWHT67RB6npnY5V/3S5RA4WO/QntX30
         TZvQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXxjasruduRW2dNwSoehnwV7BcJtdHcJvi9ikAV9vSomew9ZPKE
	6GTDUXd9jKtPpL241X4rKdOR9VpyXnrDiVxX9ysXY8UGTF3E9f3/srrm1BWRorNTV2JRDPzDkZm
	Zth5L9mgXyIU7dfk992+uhHFyYlMtA8FCVycL3oCsMcQqMAE/nsEanImTrECpkyL5QA==
X-Received: by 2002:ac8:fb0:: with SMTP id b45mr31579967qtk.146.1552404936934;
        Tue, 12 Mar 2019 08:35:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzIoondVEAHKd+uVHWijoLSZIPbwDj6Ttn81wAemQKnOnE7T6Z4gGWmt89+WkKMUoOyJuO5
X-Received: by 2002:ac8:fb0:: with SMTP id b45mr31579903qtk.146.1552404936079;
        Tue, 12 Mar 2019 08:35:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552404936; cv=none;
        d=google.com; s=arc-20160816;
        b=rYzedDsMDkyuS1+WyCc2gdPaNGwHD2I2e9Dw3pWMDwWuVK2K3YzpouFRRijt1U/Lsy
         x5QYH90UOxpT8Qh1ROQW4fp4itaguBdXDAfa3mJtUpPNyIm0V7BCjbxq5rlR9PX0hn2Q
         zzcWLzntlqUgKhM0eElq7elNwV4nq389+bxiqTHTQnAsEmWY7rjztIINOenDHv0pS3SJ
         mtRxyi6dzT3wn66o210KJqvp4BqHQPMRijOKemf2HUYlz5hOQkQkAej8LNWIl7wVBtVA
         KkgdQDrBehhvCZeES2Mn/FvrlF3nEVAtxly+wmdY6/I8Wovco218piP7cBmdxYeLp1RK
         R89w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=qGDVXQAEG+Kh+H/FqBzQ/NnTMp/1LNIvNV/PoqSppKI=;
        b=zCySQdzuJgOCkiLzCJGCMu9hZPpjnSxskARnIK7B7jbEkIuDVjuU2tWJctl/bnuCOV
         HygT51RypPIEXoeMMnqqb00LNNK5qoIAZB3eYl/tCDMOLwiOap6a2VKlUYg8izO2mio/
         AIqVj5gTM7/7zyxwj1nTZm36/efk+lEr6LbkPLKFR+FfSPd9AprybprymOvS9BJh/1S7
         467Uj+VC0OPzdyZDeFt3TChU27Q41Th+uNccj1+CfTl8QTbbBxa8s6jad9V0BbT9o2Je
         nEfZmdMIkst9zh5yY9rjuBBvOmluUh7eZT3Z+P50ySB0AnahKmpLrjpddj1k9uhwX/ZL
         XLwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m42si1967712qvh.60.2019.03.12.08.35.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 08:35:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9722F308FED2;
	Tue, 12 Mar 2019 15:35:33 +0000 (UTC)
Received: from redhat.com (ovpn-117-131.phx2.redhat.com [10.3.117.131])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 0C7025C280;
	Tue, 12 Mar 2019 15:35:30 +0000 (UTC)
Date: Tue, 12 Mar 2019 11:35:29 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Christopher Lameter <cl@linux.com>
Cc: john.hubbard@gmail.com, Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org, Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>, Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH v3 0/1] mm: introduce put_user_page*(), placeholder
 versions
Message-ID: <20190312153528.GB3233@redhat.com>
References: <20190306235455.26348-1-jhubbard@nvidia.com>
 <010001695b4631cd-f4b8fcbf-a760-4267-afce-fb7969e3ff87-000000@email.amazonses.com>
 <20190308190704.GC5618@redhat.com>
 <01000169703e5495-2815ba73-34e8-45d5-b970-45784f653a34-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <01000169703e5495-2815ba73-34e8-45d5-b970-45784f653a34-000000@email.amazonses.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Tue, 12 Mar 2019 15:35:35 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 04:52:07AM +0000, Christopher Lameter wrote:
> On Fri, 8 Mar 2019, Jerome Glisse wrote:
> 
> > >
> > > It would good if that understanding would be enforced somehow given the problems
> > > that we see.
> >
> > This has been discuss extensively already. GUP usage is now widespread in
> > multiple drivers, removing that would regress userspace ie break existing
> > application. We all know what the rules for that is.
> 
> The applications that work are using anonymous memory and memory
> filesystems. I have never seen use cases with a real filesystem and would
> have objected if someone tried something crazy like that.
> 
> Because someone was able to get away with weird ways of abusing the system
> it not an argument that we should continue to allow such things. In fact
> we have repeatedly ensured that the kernel works reliably by improving the
> kernel so that a proper failure is occurring.

Driver doing GUP on mmap of regular file is something that seems to
already have widespread user (in the RDMA devices at least). So they
are active users and they were never told that what they are doing
was illegal.

Note that i am personaly fine with breaking device driver that can not
abide by mmu notifier but the consensus seems that it is not fine to
do so.

> > > > In fact, the GUP documentation even recommends that pattern.
> > >
> > > Isnt that pattern safe for anonymous memory and memory filesystems like
> > > hugetlbfs etc? Which is the common use case.
> >
> > Still an issue in respect to swapout ie if anon/shmem page was map
> > read only in preparation for swapout and we do not report the page
> > as dirty what endup in swap might lack what was written last through
> > GUP.
> 
> Well swapout cannot occur if the page is pinned and those pages are also
> often mlocked.

I would need to check the swapout code but i believe the write to disk
can happen before the pin checks happens. I believe the event flow is:
map read only, allocate swap, write to disk, try to free page which
checks for pin. So that you could write stale data to disk and the GUP
going away before you perform the pin checks.

They are other thing to take into account and that need proper page
dirtying, like soft dirtyness for instance.


> > >
> > > Yes you now have the filesystem as well as the GUP pinner claiming
> > > authority over the contents of a single memory segment. Maybe better not
> > > allow that?
> >
> > This goes back to regressing existing driver with existing users.
> 
> There is no regression if that behavior never really worked.

Well RDMA driver maintainer seems to report that this has been a valid
and working workload for their users.


> > > Two filesystem trying to sync one memory segment both believing to have
> > > exclusive access and we want to sort this out. Why? Dont allow this.
> >
> > This is allowed, it always was, forbidding that case now would regress
> > existing application and it would also means that we are modifying the
> > API we expose to userspace. So again this is not something we can block
> > without regressing existing user.
> 
> We have always stopped the user from doing obviously stupid and risky
> things. It would be logical to do it here as well.

While i would rather only allow device that can handle mmu notifier
it is just not acceptable to regress existing user and they do seem
to exist and had working setup going on for a while.

Cheers,
Jérôme

