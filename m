Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9BB05C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:33:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59DAB2146E
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:33:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59DAB2146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E336B8E000C; Wed, 13 Mar 2019 15:33:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE36B8E0001; Wed, 13 Mar 2019 15:33:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD33D8E000C; Wed, 13 Mar 2019 15:33:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id A307E8E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 15:33:35 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id b4so2980307qtp.20
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:33:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=/BSwW1LdD9SAPcWqiUczSSFz4KPA6Esz9jiu7oqG/Uw=;
        b=L2KvSEnl2rRAMt/sE78rmfqJ2Hw3x3zZInzBo11sumstE1sGZ5p6+gqLuRG0ih0AnQ
         +juifD8uYTkVzuUj7/Cz20Nw6qMG0tdh1++0GYkpnCgQlGXrJrfHbkfxRFp5WvJAvfsu
         1RqdpSVCPVS1irAkB/A4kTgHCjdx8narN81d2oCQ3ogLQYKCqod9tKB4ExVKdDCvSQsd
         gqxeWtrkia6Q0edXks8YsYMTJ3Sq/F3aVSypLsMZGjFnfJa1+C7+hqjNWokOz24sXqYX
         v+/dJNB9eV2ehA39856O3hc8bHabs6ZNcALmlLMgUcwBd8xfA024WI+iLoPVtk36nPd3
         T0bg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXOl/IpTPKUAjJ4WBl2FnK1O7BzgRwj84zHpvUyOyPfBZF2ypgh
	YEpI+K18tULvlxEDUZhSdsdPuhogz1kxpReFr0vRC9Ee9BBe4OY3VVxsCHqh5d0nCNuc/443FC7
	NiH8KlWPVNXFLnKtWZXZQl9xgAXRL9aPDsaAImo8Xzi8ViqcuMBfVXmD6wSR5kB/lLQ==
X-Received: by 2002:a37:ef03:: with SMTP id j3mr25879784qkk.202.1552505615082;
        Wed, 13 Mar 2019 12:33:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqybloMjOw9d3Jx2BMAzBJaOS8hPcAWJbngx2znVOroToCE13k3eu1Kl+18ubsQD80S9dQeX
X-Received: by 2002:a37:ef03:: with SMTP id j3mr25879736qkk.202.1552505614291;
        Wed, 13 Mar 2019 12:33:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552505614; cv=none;
        d=google.com; s=arc-20160816;
        b=bgISzSCPV9tkzQuCEs/OnxNVukYKePnCZCW6l7e9pxoR8XasKHpEj4/PkdIVjt3UJE
         oJUvxDgS+wWebva+7LCiIZ2Gza4KtM+S6/ouQywvU20vzuI0AFeSwPbW+H+bDUOPKQWa
         TChKHi0ZzaqeuKFVKD2o6xgk3n3yEQJdPXAgNAFZxElKXNJyx9S9kCYG7T3ZykEHkCoM
         pdK7aW0ChNr5tFpGG1Nk328MVN7wDLcQ8vx1jJ67E5jjrvMRNXL+eZLRSvsjblo5nKej
         Dbq++LlAzmZsodBuPk1LK96BHoBfMFKrL9LoL9wKdFimNJhbf0L1fwN1xAUbNTehg+zJ
         38Ng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=/BSwW1LdD9SAPcWqiUczSSFz4KPA6Esz9jiu7oqG/Uw=;
        b=L8cp/fQ4ZwroKH2URdXPnZcZSaAfAXEQ34e8FfQiGNN3UNc3hExiPncKVcXHS/nP6N
         7Vt2+P4CSSFobLcErSZce4g6GmBVo9sEfsZzAt7jQqqfX/rCqDES0fG4liGR8KR006PG
         A44UTpzDUJ4DjuVgWSyz8v7/p7YdZJex5z3sip4VrbXd6WpTplyOcMUEUq0q3AtOAwIN
         ZFRC0FOFR+V4gWo3i7rYBTYIbMc6kHwLF78t/v6vcuOOepgbfShb2OkzhVzVYhtjhaSY
         wc662e1wDmf+IbLj1x8nb9+A0Y0CobuNyOxW9HKrV/ouAm12xz3AdV1H4I6OtRMjqxcl
         /gRA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f3si406100qvi.21.2019.03.13.12.33.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 12:33:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 279E53092669;
	Wed, 13 Mar 2019 19:33:33 +0000 (UTC)
Received: from redhat.com (ovpn-125-95.rdu2.redhat.com [10.10.125.95])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 9F62F5ED2B;
	Wed, 13 Mar 2019 19:33:30 +0000 (UTC)
Date: Wed, 13 Mar 2019 15:33:28 -0400
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
Message-ID: <20190313193328.GA4785@redhat.com>
References: <20190306235455.26348-1-jhubbard@nvidia.com>
 <010001695b4631cd-f4b8fcbf-a760-4267-afce-fb7969e3ff87-000000@email.amazonses.com>
 <20190308190704.GC5618@redhat.com>
 <01000169703e5495-2815ba73-34e8-45d5-b970-45784f653a34-000000@email.amazonses.com>
 <20190312153528.GB3233@redhat.com>
 <01000169787c61d0-cbc5486e-960a-492f-9ac9-9f6a466efeed-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <01000169787c61d0-cbc5486e-960a-492f-9ac9-9f6a466efeed-000000@email.amazonses.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Wed, 13 Mar 2019 19:33:33 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 13, 2019 at 07:16:51PM +0000, Christopher Lameter wrote:
> On Tue, 12 Mar 2019, Jerome Glisse wrote:
> 
> > > > This has been discuss extensively already. GUP usage is now widespread in
> > > > multiple drivers, removing that would regress userspace ie break existing
> > > > application. We all know what the rules for that is.
> 
> You are still misstating the issue. In RDMA land GUP is widely used for
> anonyous memory and memory based filesystems. *Not* for real filesystems.

Then why are they bug report as one pointed out in cover letter ? It
means someone is doing GUP on filesystem. Moreover looking at RDMA
driver i do not see anything that check that VA for GUP belongs to a
vma that is not back by a regular file.

> 
> > > Because someone was able to get away with weird ways of abusing the system
> > > it not an argument that we should continue to allow such things. In fact
> > > we have repeatedly ensured that the kernel works reliably by improving the
> > > kernel so that a proper failure is occurring.
> >
> > Driver doing GUP on mmap of regular file is something that seems to
> > already have widespread user (in the RDMA devices at least). So they
> > are active users and they were never told that what they are doing
> > was illegal.
> 
> Not true. Again please differentiate the use cases between regular
> filesystem and anonyous mappings.

Again where does the bug comes from ? Where in RDMA is the check that
VA belong to a vma that is not back by a file ?

> 
> > > Well swapout cannot occur if the page is pinned and those pages are also
> > > often mlocked.
> >
> > I would need to check the swapout code but i believe the write to disk
> > can happen before the pin checks happens. I believe the event flow is:
> > map read only, allocate swap, write to disk, try to free page which
> > checks for pin. So that you could write stale data to disk and the GUP
> > going away before you perform the pin checks.
> 
> Allocate swap is a separate step that associates a swap entry to an
> anonymous page.
> 
> > They are other thing to take into account and that need proper page
> > dirtying, like soft dirtyness for instance.
> 
> RDMA mapped pages are all dirty all the time.

Point is the pte dirty bit might not be accurate nor the soft dirty bit
because GUP user does not update those bits and thus GUP user need to
call the set_page_dirty or similar to properly report page dirtyness.

> > Well RDMA driver maintainer seems to report that this has been a valid
> > and working workload for their users.
> 
> No they dont.
> 
> Could you please get up to date on the discussion before posting?

Again why is there bug report ? Where is the code in RDMA that check
that VA does not belong to vma that is back by a file ?

As much as i would like that this use case did not exist i fear it
does and it has been upstream for a while. This also very much apply
to O_DIRECT wether you like it or not.

Cheers,
Jérôme

