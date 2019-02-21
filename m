Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 008ABC00319
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 17:32:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BCC842083E
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 17:32:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BCC842083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 486058E009A; Thu, 21 Feb 2019 12:32:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 40D628E0094; Thu, 21 Feb 2019 12:32:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2FF7B8E009A; Thu, 21 Feb 2019 12:32:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 022618E0094
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 12:32:47 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id 35so26787096qty.12
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 09:32:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=YiQUSmAeAewTNuG750gHQAGXOlkE4G/wTuJUcCdSmmQ=;
        b=e3vSKB8tKcMjKmlALIMR6LBLRd5JgppoOcIQ9aUady/0myelA68OVhsW0KOiuw0h84
         zVv+q4oUvrVBQyetQ2aM8drswZwSnNwxGZM3EBpzEh2RzYzqO0kXxz27UtGy/QKuPc0d
         xTwak3gulmXR+4wx9QK5wZ3ZOC+/xbsoreVslsArnmorAJ/UopHikXRUddWjI1fNK3vC
         rNCiAET0dk1XNgXXU/LmKEsxVofL/dkdEwRLxdFjYj4KFtwIxGeuTCJJRL3vjWqKj8wx
         LazPGaNPH/KqlQxV+P3xGfZdUpagZ7cq7mlovwuf2sMGQywBC3MU7TnTuRAGIKnM5Bw0
         3png==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuYE/LTzoruWu0mDlBlSxBXEJBxZX32M8Zagu3jE2OL4ZJv1S25R
	0FUxy0B+ooXpnaW1EnZy8e3h73N6ib7NMbjaJuDbV0e7u3claOavmSyHQBHJtp2Wg/Eponbkivx
	F5d2caJ1/CVZqkMoj30cz1vsoaqYR6jDLjoA82QfTp3GIRnv+0K5srCO+NsAWP9UJog==
X-Received: by 2002:a37:c313:: with SMTP id a19mr28552827qkj.220.1550770366767;
        Thu, 21 Feb 2019 09:32:46 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYHkohx9x1q1pxTO+D3qCPvy/biyEVsKBahLS0KU7IT72z8B0j8ODtl4zgVV8qsrWYdrkuJ
X-Received: by 2002:a37:c313:: with SMTP id a19mr28552802qkj.220.1550770366240;
        Thu, 21 Feb 2019 09:32:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550770366; cv=none;
        d=google.com; s=arc-20160816;
        b=fHzeR8Xn9IiLf7Owk9H/fD7F0ZB9D4G7p4QkiuYYcuBRzoFBb04T9mUP3buw1TeiNT
         Pckk/ykO6xhiqpo//00VX63Mr65RXVhh3lK5PqOJr3SalsqldVKaT83GEgYkruhS9Er0
         EsEOnvx+AR6UQsyN2hyivl+n4g5M4sFZVpXXwYuCDbt41lWzZ1Fu0mdkszMZagDBPwL8
         OIrQSNWH379X354jAhv2UXrznZgmhjexGc9V+iYZdylGg6MwIq9Qy48G98EdS9ijkGLL
         jVy/rG3liT66AuyixUyKE06a4C1sGZ2YpO0MOK/VRqErgSG9aJcO2EJG5RmUwHgjMknA
         dnoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=YiQUSmAeAewTNuG750gHQAGXOlkE4G/wTuJUcCdSmmQ=;
        b=CaSgF5uedenWAW7JMaWa0fu/XaDuOqViUOfOQDLefItCMOksGO6TzSS26kGYcZHCXI
         FEyk7oGRP1YzMtt99VKi0Z1vBTzWqR/kBihK/XfpWWdDT6hABjbtb6e4RbRAj3GFgJlE
         EQbFHxrxp778QL+4Yo7mM+sPT/RXlZQU7PZ2jXzkPSRo3iaW5j0gv9M8FmcudxxcXVmq
         6ocGWWdZCL9DASAhS2NiGt0dw2HDILbCs45RKbrZs+wCOBxhFQ6rBV1NIReGalS/StMm
         r99Rldi+7S9KbLhKPlXbXiTNBFXKWf4QxtGnQXPIzDqXE9kXWzBpGD0oX3AWzvxGQVqv
         sa9g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i128si1159444qki.232.2019.02.21.09.32.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 09:32:46 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1D71E308FE63;
	Thu, 21 Feb 2019 17:32:45 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 797251001DC5;
	Thu, 21 Feb 2019 17:32:39 +0000 (UTC)
Date: Thu, 21 Feb 2019 12:32:37 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v2 11/26] mm: merge parameters for change_protection()
Message-ID: <20190221173237.GK2813@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-12-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190212025632.28946-12-peterx@redhat.com>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Thu, 21 Feb 2019 17:32:45 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 10:56:17AM +0800, Peter Xu wrote:
> change_protection() was used by either the NUMA or mprotect() code,
> there's one parameter for each of the callers (dirty_accountable and
> prot_numa).  Further, these parameters are passed along the calls:
> 
>   - change_protection_range()
>   - change_p4d_range()
>   - change_pud_range()
>   - change_pmd_range()
>   - ...
> 
> Now we introduce a flag for change_protect() and all these helpers to
> replace these parameters.  Then we can avoid passing multiple parameters
> multiple times along the way.
> 
> More importantly, it'll greatly simplify the work if we want to
> introduce any new parameters to change_protection().  In the follow up
> patches, a new parameter for userfaultfd write protection will be
> introduced.
> 
> No functional change at all.
> 
> Signed-off-by: Peter Xu <peterx@redhat.com>

It would have been nice if this was a coccinelle patch, easier to
review.

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

> ---
>  include/linux/huge_mm.h |  2 +-
>  include/linux/mm.h      | 14 +++++++++++++-
>  mm/huge_memory.c        |  3 ++-
>  mm/mempolicy.c          |  2 +-
>  mm/mprotect.c           | 29 ++++++++++++++++-------------
>  5 files changed, 33 insertions(+), 17 deletions(-)

[...]

