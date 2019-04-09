Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 701A5C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 06:08:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F85420883
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 06:08:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F85420883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F6DF6B0007; Tue,  9 Apr 2019 02:08:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A6916B0008; Tue,  9 Apr 2019 02:08:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 695C26B000C; Tue,  9 Apr 2019 02:08:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4CAEB6B0007
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 02:08:54 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id y64so13747690qka.3
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 23:08:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=gI+CJWeJWAeL1EpC4t/1QXmZ455u94XXr+h646lWamQ=;
        b=jPunfyzHxkXgZ+cD8us8aWSLbRQ2/OJ+B3SaZtdhceEdQ/uL2yiyJK08vokaF51PVo
         MA/Z66IH73IDk/qAILwzCS71kFfDffVJtsJQgkWE40vD9xCiZ/6f1px5SpY+emKvqDOk
         izaxaXEATs74vv2P9Qv/8m/e6PxfqA3+7mx8Yd/Lyt8VfdDezkthcX/RLmERLHVYqQSf
         Nbr+GBpT/0NwAH894wx3JiZFhQ6cwbBtx9W5n9uRBqx4m6oyHOzeOyf11lrDcX/KVF5c
         lSLF7NmZUikAy1FXarA+QwRvQahlAiVAnDvTdNrIGMhQ7AdFQx6Q4gdhN9NKJTmxbDhV
         UZ7w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUxx+W7OtcefpuymUr79t4j1htOGf83ho3tPI8InHIaTQr5xI+R
	0FzxCgTOaCdSGo1o7fvWWm7eEqNpCbbAZgATH9vjncY/DlQcc51HLv3GdE6efBm+Q3WpK9GX5bD
	Re8imhRa+aS8R73BwmyRha36pY+CHDrsBhiQPxQx4qriXxqk9OCtdU1BZzUWxVk4x+A==
X-Received: by 2002:ac8:3328:: with SMTP id t37mr28164110qta.246.1554790134017;
        Mon, 08 Apr 2019 23:08:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwUpOqbMPT/XjaWtYz4+88VOtI2PMq5e4qTakhz7RjK+/olFnBjI41TGbvEBCsTwFMDS9jJ
X-Received: by 2002:ac8:3328:: with SMTP id t37mr28164071qta.246.1554790133093;
        Mon, 08 Apr 2019 23:08:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554790133; cv=none;
        d=google.com; s=arc-20160816;
        b=meczIzqO3eW0kcPIUgaZ/iSnEJ0CsPF0Mzw1WDMmKt2IUra4YFZT+1INMOA82Nxu5A
         iAbb50nTb3fqB5jrVD2vKOJTEyJpnQWVmOQB7elwnjJTj6fY+ak3xspYVbr6FMwXUS9i
         P49tIWvjuoOeZjhGpPEW3qphiFekPcS7vS2aOlkNUuksP2aztTtglvomVMrrZR4VYT6Y
         D+YL94U9L+Iri3pGF3lTtu2dt/FYOHc+U1ucs6VNiY+1sDGKQs6PXB8Swh+25r0jbeWp
         fynSXjyjVDJgK+RyZ1EILUe+RmTCZCM9G3bATdEPDldiNEx79+BTEmYQvRX+WIEN49ZH
         U/XQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=gI+CJWeJWAeL1EpC4t/1QXmZ455u94XXr+h646lWamQ=;
        b=Fu0YIov1O81H7oXCZPKrjWzf2K/wCLImudGl7k2BubnY/ImEhnY/wnJsCu31lxq99S
         wYwp7MzdN/unF8MNE7EzffwLd7NwAy7Bq+edwRW5HyglzFu3iVwMkTaMdo5urmJ7nSkb
         B34jsLVK9IWFCqjzXxTh0zT8c/Y5Rxp9OyUJGl9dK/SkHn6t2is4t9DarN6BP/7Us1SZ
         kj+7oOPpKIhJ2DTALovLJKGReiFn62Ho9fkwU0zbx1OJGj6F1FV7xnmuQCRLi6uNFt51
         kFSapo8/OLWULsLCng5gMfCURjST/AJzVT9pG88FUwvKzt3iZVhvp7+w7RZGKbuPpV2H
         alXw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h15si94195qvo.209.2019.04.08.23.08.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Apr 2019 23:08:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 130523086216;
	Tue,  9 Apr 2019 06:08:51 +0000 (UTC)
Received: from xz-x1 (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id E9A0F63F7C;
	Tue,  9 Apr 2019 06:08:41 +0000 (UTC)
Date: Tue, 9 Apr 2019 14:08:39 +0800
From: Peter Xu <peterx@redhat.com>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: David Hildenbrand <david@redhat.com>, Hugh Dickins <hughd@google.com>,
	Maya Gokhale <gokhale2@llnl.gov>,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Marty McFadden <mcfadden8@llnl.gov>, Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v3 00/28] userfaultfd: write protection support
Message-ID: <20190409060839.GE3389@xz-x1>
References: <20190320020642.4000-1-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190320020642.4000-1-peterx@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Tue, 09 Apr 2019 06:08:52 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 10:06:14AM +0800, Peter Xu wrote:
> This series implements initial write protection support for
> userfaultfd.  Currently both shmem and hugetlbfs are not supported
> yet, but only anonymous memory.  This is the 3nd version of it.
> 
> The latest code can also be found at:
> 
>   https://github.com/xzpeter/linux/tree/uffd-wp-merged
> 
> Note again that the first 5 patches in the series can be seen as
> isolated work on page fault mechanism.  I would hope that they can be
> considered to be reviewed/picked even earlier than the rest of the
> series since it's even useful for existing userfaultfd MISSING case
> [8].

Ping - any further comments for v3?  Is there any chance to have this
series (or the first 5 patches) for 5.2?

Thanks,

-- 
Peter Xu

