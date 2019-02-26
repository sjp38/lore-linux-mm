Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42B7FC4360F
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 06:53:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 06889213A2
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 06:53:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 06889213A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 91C6D8E0003; Tue, 26 Feb 2019 01:53:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A4938E0002; Tue, 26 Feb 2019 01:53:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 76CFC8E0003; Tue, 26 Feb 2019 01:53:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 469558E0002
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 01:53:56 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id 207so9759304qkf.9
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 22:53:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=EZ6MCBvPn7BiMqCwVYpjDLxFC1jvMALcpmPPbXkLxno=;
        b=onpVeC2RaP3V6H+lTPL+twGAxHFZZtzYN8WjCgx6K33JwcvaE6eGCf4rAk0RMwWEu7
         47DMZyngDdr3DHqktVsAvr/Mw2WkqG6Nu9PRzOr99GsTKbYAnq0/7uxCMdDHRrEVQSvC
         h1PKTyNbfVRp7OkEJtQdHuge0TPml/sylBGvqfNKDgodVCs+XgOy7O2cM2VxGWnJSwsx
         Ozwn7/5sYcOfb+jtf6/RbEnCNauEnVlob+2G/opZcjhKI5rYhqZxkpskvDMNJjZw+VNp
         InryglhbaLnXYfXMw1ropmDdpQ2XyHQmRP6PrK6MLi/zJI075BpxfzIZdHQwvtnd9XjG
         iiFg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZTbDsc8Yo/kUsDgnpSAzoDNdheIwPmfaSPozRg+nnGXJp3He2x
	IZemSyXu2VXz6GSrglO/hZgbRozhsJMHKVwI6KDi2FufnzEnd2KXNrEXbrDbuqfxyABw3xgC9/B
	9kj5tVwniaLnjK0sVYm+ZX6JqlPNW1/aQqMaaEa42CtxvjiRhvC0m5js915+oSmCX7Q==
X-Received: by 2002:a05:620a:1253:: with SMTP id a19mr13364037qkl.271.1551164036034;
        Mon, 25 Feb 2019 22:53:56 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaQ+OTF+BxSfLe+JASopVAzX2ko7biM0g0dEuI7t0GLokOTUkwGO7gOD9e9AGvz1a4yea0G
X-Received: by 2002:a05:620a:1253:: with SMTP id a19mr13364021qkl.271.1551164035447;
        Mon, 25 Feb 2019 22:53:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551164035; cv=none;
        d=google.com; s=arc-20160816;
        b=YyqSq6A2LAVSdrsrrthLEeGHGtyWwfSfigpZQ58lRdzqyn9nuh7gBTwe/ZOJFzzOPZ
         K/frtn3bZoXcpI5beaQX7xQIzKLoN2olDOOX9R6PcVdnoZ/8LA2PMU/0xHC7kmaSnY0N
         wEt9it3aDJCf4nYqqtZ5BuYhw8usyvXHBMvi7JEDIl2B37Op8rTR5iL/MqKeQYgLhHZQ
         UNgKTTaXdJ0O9PO1xP8zTs792CBVVigaSWjTFTGWO9891y8F1rxDpg27YFyp254Qdafo
         FgiKZSbCaX13JcSLSSOoqc3zthjGetFJflF59+7DCGIbaJYUuqjutSKs/j3hUuNptOgT
         V0fg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=EZ6MCBvPn7BiMqCwVYpjDLxFC1jvMALcpmPPbXkLxno=;
        b=cFYJUIWXmGSpgs4MR6vcbHPhTe9GInQgdamJGrlVQmJkGf1ufL9LyW8pdlUbsZTu6p
         ENSbBOTOlVr9JyB8eH+N4H3Ft9NXyWLXKTs43F+tsP9+mVPfwxWmkNm06+KLSpyZmIaI
         jAG4v/WBcyVLh31V0dEmrRkr6/Rii52RR3l1DjSt2yxBpRJI1M3FnkKaAIpbfh/hvbPf
         OQd3jQb55QILDMt9geEMivPDu2DZOPc/V2gT9+gCLABtkiVydqHyWmWFPwhUrX2RAAkh
         /4U9KyuQZA2vitVcBZD2gZ42eHt4+8B5HX8L1Mn0AmHEeiiZVvegVJSlW5YHYipVmFrN
         snXA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 23si3058803qtr.57.2019.02.25.22.53.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 22:53:55 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 81977369BC;
	Tue, 26 Feb 2019 06:53:54 +0000 (UTC)
Received: from xz-x1 (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id C5A9D5D9D1;
	Tue, 26 Feb 2019 06:53:45 +0000 (UTC)
Date: Tue, 26 Feb 2019 14:53:42 +0800
From: Peter Xu <peterx@redhat.com>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Jerome Glisse <jglisse@redhat.com>,
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
Subject: Re: [PATCH v2 24/26] userfaultfd: wp: UFFDIO_REGISTER_MODE_WP
 documentation update
Message-ID: <20190226065342.GJ13653@xz-x1>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-25-peterx@redhat.com>
 <20190225211930.GG10454@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190225211930.GG10454@rapoport-lnx>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Tue, 26 Feb 2019 06:53:54 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 25, 2019 at 11:19:32PM +0200, Mike Rapoport wrote:
> On Tue, Feb 12, 2019 at 10:56:30AM +0800, Peter Xu wrote:
> > From: Martin Cracauer <cracauer@cons.org>
> > 
> > Adds documentation about the write protection support.
> > 
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > [peterx: rewrite in rst format; fixups here and there]
> > Signed-off-by: Peter Xu <peterx@redhat.com>
> 
> Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>
> 
> Peter, can you please also update the man pages (1, 2)?
> 
> [1] http://man7.org/linux/man-pages/man2/userfaultfd.2.html
> [2] http://man7.org/linux/man-pages/man2/ioctl_userfaultfd.2.html

Sure.  Should I post the man patches after the kernel part is merged?

Thanks,

-- 
Peter Xu

