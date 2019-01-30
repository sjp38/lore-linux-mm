Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 780A3C282D9
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 14:43:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 240D620882
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 14:43:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 240D620882
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 695938E0003; Wed, 30 Jan 2019 09:43:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 642F38E0001; Wed, 30 Jan 2019 09:43:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 533A18E0003; Wed, 30 Jan 2019 09:43:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2418B8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 09:43:11 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id b185so25697097qkc.3
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 06:43:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Hdf6/8FKnVMgi2EBr9MfxQjMIX2eLqfWUCAXJCy0C/g=;
        b=W5S/4s/SPYl0gv4rBLbSl1tDG7CfTlmVNXfEFdHtM0F+H26warvb8Z8mb2siwHFrKq
         NCZb4ELwH7lXnExP4IZFJVF7gtwl2OHmLG6OqMpsINu8DUm+ekiMsSW25lCGCY4qCivr
         /+DXWFd4vni5WtEDUib0VDfvVAHtVcUqH20k88H3+eWci6gxFfQn2+3sAaTt/SQuBaor
         pu3CFEtJG7izS8simxwXNK/kp1dPIkcYdCTqIGZKURghvaGbWbE8ZFx1QMPLfLYVll9X
         QBp93pZ3c8+Tm+7utjs41FhF5pgAFI/e4FZBje6r3Yn5q7Yzuw6ppUOAG4x2isWfWUaZ
         ru3Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukd5M91MO+IZ48A0p2bnEZN9EmFT7m9uCgTF8we28KoadFrozcT2
	SfbKggso1CTgpFry/ibTmKE/wEXtRTWGYLAdaO1A7cn6XyDpY4FJFlzDjNyHCZrbN/hfJZUkkaM
	54akB2qSYenOgs+zrQB07g8S5FshOhKbSn7NR36+MuRsMJNDxhEzW1gsBNls3zl5KAA==
X-Received: by 2002:a37:2cc2:: with SMTP id s185mr27063101qkh.74.1548859390860;
        Wed, 30 Jan 2019 06:43:10 -0800 (PST)
X-Google-Smtp-Source: ALg8bN40G/gw1mnoCo48DR543eDhddhplC/RhfZZ04vftXR0ssJqKFfS80mEtxDx7SXxPtJ6AN8t
X-Received: by 2002:a37:2cc2:: with SMTP id s185mr27063068qkh.74.1548859390123;
        Wed, 30 Jan 2019 06:43:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548859390; cv=none;
        d=google.com; s=arc-20160816;
        b=mHvh+OsBlMKtww/oWDDcI3zoOigLvKC20GmtJ3SDHxj9UX2X9D5qloxYVLAfZI9CK6
         03Ht4RcL1Hy40rsYLPy+4oP1G+Nu6yYTkBMNrNbrQL+QmT5z8zHuQVvkj9GtPQ40WLor
         W6hXSUW8XVWgYzU6uDppi4NXEnXh3cJV6fP6j9Ij8YY2sLRZLWevDXhixLnPjqnkfjiw
         Nw30WyW/MZeveLE02dOtDWWQ5d8OzALrcxN3l3OosT39J7ot8wCP3/PAV0rkDZfT5O9o
         7+rr1uAZYY07I0X8PfoVxozjSl3s1ZBeEzkbT1dnPRiVsiTOVOS/UGshL42PrGxRDId+
         MhTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Hdf6/8FKnVMgi2EBr9MfxQjMIX2eLqfWUCAXJCy0C/g=;
        b=Lid7gNPVcFvdSKqJ07zPwz8CHc3jp16zBnC/qbborTwonlxGfGuhCYfpFsmgFadG7a
         rhogPjHbdlWslLhBzPSyW7OAsMMaAKzanoEjjAi0wdUkwwg0TlHyaoAW1JtEr5BORx3c
         Pv7m2Gl2BoISmQBzVQ+zeQrUkWmvmT3toLrxvfuWXfpIRjDx2I6Hkbi/VUalzGuxh/tI
         hHgunDznyv+bLhHXxKVkBRayMJxuzLBMY57Jp4B2y6jmvVe8QRsZm1FRql06YJG2nSvG
         zfgWg3GJ0M7SrG0NdDpTKgYFaZJRMIPLxxUEJYVrsTfS2VdvQvvxCRGmd8cC8VrlyQvC
         DVNw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a19si1145892qta.325.2019.01.30.06.43.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 06:43:10 -0800 (PST)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E8534A402E;
	Wed, 30 Jan 2019 14:43:08 +0000 (UTC)
Received: from sky.random (ovpn-121-14.rdu2.redhat.com [10.10.121.14])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id A306718823;
	Wed, 30 Jan 2019 14:43:05 +0000 (UTC)
Date: Wed, 30 Jan 2019 09:43:04 -0500
From: Andrea Arcangeli <aarcange@redhat.com>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Peter Xu <peterx@redhat.com>,
	Blake Caldwell <blake.caldwell@colorado.edu>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@suse.de>,
	Vlastimil Babka <vbabka@suse.cz>,
	David Rientjes <rientjes@google.com>,
	Andrei Vagin <avagin@gmail.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>
Subject: Re: [LSF/MM TOPIC]: userfaultfd (was: [LSF/MM TOPIC] NUMA remote THP
 vs NUMA local non-THP under MADV_HUGEPAGE)
Message-ID: <20190130144304.GA19021@redhat.com>
References: <20190129234058.GH31695@redhat.com>
 <20190130081336.GC17937@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190130081336.GC17937@rapoport-lnx>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Wed, 30 Jan 2019 14:43:09 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Mike,

On Wed, Jan 30, 2019 at 10:13:36AM +0200, Mike Rapoport wrote:
> We (CRIU) have some concerns about obsoleting soft-dirty in favor of
> uffd-wp. If there are other soft-dirty users these concerns would be
> relevant to them as well.
> 
> With soft-dirty we collect the information about the changed memory every
> pre-dump iteration in the following manner:
> * freeze the tasks
> * find entries in /proc/pid/pagemap with SOFT_DIRTY set
> * unfreeze the tasks
> * dump the modified pages to disk/remote host
> 
> While we do need to traverse the /proc/pid/pagemap to identify dirty pages,
> in between the pre-dump iterations and during the actual memory dump the
> tasks are running freely.
> 
> If we are to switch to uffd-wp, every write by the snapshotted/migrated
> task will incur latency of uffd-wp processing by the monitor.

That's valid concern indeed.

I didn't go into the details of what additional feature is needed in
addition to what is already present present in Peter's current
patchset, but you're correct that in order to perform well to do the
softdirty equivalent, we'll also need to add an async event model.

The async event model would be set during UFFD registration. It'd work
like async signals, you just queue up uffd events in the kernel by
allocating them with a slab object (not in the kernel stack of the
faulting process). Only if the monitor won't read() them fast enough
it'll eventually block the write protect fault and release the
mmap_sem but the page fault would always be resolved by the kernel
even in that case. For the monitor there'll be just a stream of
uffd_msg structures to read in multiples of the uffd_msg structure
size with a single syscall per wakeup of the monitor. Conceptually
it'd work the same as how PML works for EPT.

The main downside will be an allocation per fault (soft dirty doesn't
need to do such allocation), but there will be no round-trip to
userland latency added to the wrprotect fault that needs to be logged.

We need the synchronous/blocking uffd-wp for other things that aren't
related to soft dirty and can't be achieved with an async model like
softdirty. Adding an async model later would be a self contained
feature inside uffd.

So the idea would be to ignore any comparison with softdirty until
uffd-wp is finalized, and then evaluate the possibility of adding an
async model which would be simple thing to add in comparison of the
uffd-wp feature itself.

The theoretical expectation would be that softdirty would perform
better for small processes (but for those the overall logging overhead
is small anyway), but when it gets to the hundred-gigabytes/terabytes
regions, async uffd-wp should perform much better.

Thanks,
Andrea

