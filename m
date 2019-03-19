Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 457BBC10F03
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 17:18:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E7B4B20863
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 17:18:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E7B4B20863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3160D6B0005; Tue, 19 Mar 2019 13:18:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C6356B0006; Tue, 19 Mar 2019 13:18:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 167316B0007; Tue, 19 Mar 2019 13:18:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id DC8CB6B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 13:18:53 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id t13so18397819qkm.2
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 10:18:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=Tgody6G2fVxxhTiw+Ocojq4x/LcRzKd1oh5pEBHmCSc=;
        b=R2+E4fb6Kj5BTbXWiLP8mo/t4XTExr5vGLWCZgpQVZ5noNBbuUCe5W67IRT2GsO6hx
         szyezVCknSMqXmR29TyCAomS8oa3oWfa5gebAgCrbTmS0QYbKcVMe5cfYgomBcxxOIwo
         q5FHMrSPxyimGfBtrKyaTctpTXGuUEiPYfEpSlrXdRrxBdBZsz2mKYFomLUvJOMEQj9m
         7GG8PzcsOGu/hroowYWVlqTbQH7QMV9/2LoE8lU2bgaGE5mdlC3Buo4ZoF0p1IrwyLu6
         +oHFRGnAxyfPWj7qvjFFBN3dv5QBRtF+2kZ8gEuLDU67pF6SmP6ns+k4lnGxXQHiIvO/
         XPdw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVLqpGB28rrRCxIGFHRHR9ui5sWGJML7ggrXxT4epeWVGNi30gK
	JNeOnFTBCGw81bAqUWE6TAbnn4Qydgpb7/PJGBaamh/p5J7B1j2h7OmHsXekPXDvO8vKWP7PTcc
	YhNFyH3R/mLj7jSBG8zK4V/Blxirkfh3ctkU7268sfpNimACGUqEWBxpFfSFQhJmMQA==
X-Received: by 2002:a37:b704:: with SMTP id h4mr2785376qkf.39.1553015933575;
        Tue, 19 Mar 2019 10:18:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxeHQ/LK/WfBI3H342utFCBuON9efD56qlLnzcnN23aRVLJTzJYnOLbtebiLGy431j62c3S
X-Received: by 2002:a37:b704:: with SMTP id h4mr2785298qkf.39.1553015932512;
        Tue, 19 Mar 2019 10:18:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553015932; cv=none;
        d=google.com; s=arc-20160816;
        b=hLhrdwi57QfkfN9jxxjfJf+Gbyp7Cgm06I4IuUPl7b1fiV8k7TzlJ7C7IgrDrivhd9
         yYFznivNVhyNHvRBwA4URzdLBsN4tb/8MU0qzuBWJsYgqs9exeyhDiZLvTxMOjFTd7WI
         +eofxZcvyMURU9r8YTv0MTk8s8/LA5tMqGoYYWNJek7wTE0niZmOtnM/LMp4eguriJZt
         w61Ylqdc7zqJVSA8wsv2b4wX+BOR06Hx2TTT5BRfhr9KXg3aGy6xdfHgp2r+BdSiFCsC
         zGxD/gssz5w8KBK6SbYF1nO9bIaBVFxqDZMXWNXraiXIOrckSNkKJfu9iE4I8cAxQSSl
         mQcQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=Tgody6G2fVxxhTiw+Ocojq4x/LcRzKd1oh5pEBHmCSc=;
        b=l+u39FrU4DHXJjBU9OxwbMxYI7Isdz2HM0XDlMOPvnbzwrG80N/Iv9JJS5OCda4HFv
         DYMPI90pUbOKmW6FjJJXK51URhmNNmyUjU3PM1ZMJsFiDLLe/o0u87PkO+Hvqvu4QnSW
         /+LhrHNOhQNbaSxwCncRBY71Qfd0Z3Ea2P84LwAFdSNvkjF8pq8sxJL82Jj2EZid4bJ0
         s55w92D28JrEkcjpbuk97EjMS/BY9sQhHYvlaKKYth0skgSWYOytHrGRsQHMaslW9y+i
         9LweQ4Zw/1UVKiPcbAObNZjyOp43t70mAoAVfCuFlvQ4l7CaXwbzZVykImxsHA7ttb9n
         D7WQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k5si1542081qkf.216.2019.03.19.10.18.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 10:18:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 58D7F59468;
	Tue, 19 Mar 2019 17:18:51 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id B2A075D70D;
	Tue, 19 Mar 2019 17:18:49 +0000 (UTC)
Date: Tue, 19 Mar 2019 13:18:48 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Alex Deucher <alexander.deucher@amd.com>
Subject: Re: [PATCH 00/10] HMM updates for 5.1
Message-ID: <20190319171847.GC3656@redhat.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
 <20190313012706.GB3402@redhat.com>
 <20190313091004.b748502871ba0aa839b924e9@linux-foundation.org>
 <20190318170404.GA6786@redhat.com>
 <20190319094007.a47ce9222b5faacec3e96da4@linux-foundation.org>
 <20190319165802.GA3656@redhat.com>
 <20190319101249.d2076f4bacbef948055ae758@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190319101249.d2076f4bacbef948055ae758@linux-foundation.org>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Tue, 19 Mar 2019 17:18:51 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 10:12:49AM -0700, Andrew Morton wrote:
> On Tue, 19 Mar 2019 12:58:02 -0400 Jerome Glisse <jglisse@redhat.com> wrote:
> 
> > > So I think I'll throw up my hands, drop them all and shall await
> > > developments :(
> > 
> > What more do you want to see ? I can repost with the ack already given
> > and the improve commit wording on some of the patch. But from user point
> > of view nouveau is already upstream, ODP RDMA depends on this patchset
> > and is posted and i have given link to it. amdgpu is queue up. What more
> > do i need ?
> 
> I guess I can ignore linux-next for a few days.  
> 
> Yes, a resend against mainline with those various updates will be
> helpful.  Please go through the various fixes which we had as well:

Yes i will not forget them and i will try to get more config build
to be sure there is not issue. I need to register a tree with the
rand-config builder but i lack place where i can host a https tree
(i believe this is a requirement).

> 
> mm-hmm-use-reference-counting-for-hmm-struct.patch
> mm-hmm-do-not-erase-snapshot-when-a-range-is-invalidated.patch
> mm-hmm-improve-and-rename-hmm_vma_get_pfns-to-hmm_range_snapshot.patch
> mm-hmm-improve-and-rename-hmm_vma_fault-to-hmm_range_fault.patch
> mm-hmm-improve-driver-api-to-work-and-wait-over-a-range.patch
> mm-hmm-improve-driver-api-to-work-and-wait-over-a-range-fix.patch
> mm-hmm-improve-driver-api-to-work-and-wait-over-a-range-fix-fix.patch
> mm-hmm-add-default-fault-flags-to-avoid-the-need-to-pre-fill-pfns-arrays.patch
> mm-hmm-add-an-helper-function-that-fault-pages-and-map-them-to-a-device.patch
> mm-hmm-support-hugetlbfs-snap-shoting-faulting-and-dma-mapping.patch
> mm-hmm-allow-to-mirror-vma-of-a-file-on-a-dax-backed-filesystem.patch
> mm-hmm-allow-to-mirror-vma-of-a-file-on-a-dax-backed-filesystem-fix.patch
> mm-hmm-allow-to-mirror-vma-of-a-file-on-a-dax-backed-filesystem-fix-2.patch
> mm-hmm-add-helpers-for-driver-to-safely-take-the-mmap_sem.patch
> 
> Also, the discussion regarding [07/10] is substantial and is ongoing so
> please let's push along wth that.

I can move it as last patch in the serie but it is needed for ODP RDMA
convertion too. Otherwise i will just move that code into the ODP RDMA
code and will have to move it again into HMM code once i am done with
the nouveau changes and in the meantime i expect other driver will want
to use this 2 helpers too.

> 
> What is the review/discussion status of "[PATCH 09/10] mm/hmm: allow to
> mirror vma of a file on a DAX backed filesystem"?

I explained that this is needed for the ODP RDMA convertion as ODP RDMA
does supported DAX today and thus i can not push that convertion without
that support as otherwise i would regress RDMA ODP.

Also this is to be use by nouveau which is upstream and there is no
reasons to not support vma that happens to be mmap of a file on a file-
system that is using a DAX block device.

I do not think Dan had any comment code wise, i think he was complaining
about the wording of the commit not being clear and i proposed an updated
wording that he seemed to like.

Cheers,
Jérôme

