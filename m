Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CFC6C31E47
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 08:46:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 213EE206E0
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 08:46:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 213EE206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A2C1F6B0003; Wed, 12 Jun 2019 04:46:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DCEF6B0005; Wed, 12 Jun 2019 04:46:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F25F6B0006; Wed, 12 Jun 2019 04:46:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6BAE16B0003
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 04:46:12 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id z8so14150594qti.1
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 01:46:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=8Z6d7Pc5h0GDrv5AJ+xBedYk/BC2MV2Y54edSWNuCLs=;
        b=jMjDyiCIPvdn/EO9tUkeszGaRC7B+dDLeB0txpjwJcX0cK7T0AfdkwhuhiWrSRKFHS
         JzW3nVgKNumvsopM7Nang8MN7v69lFJMog1i2L9MFvndX5mM7LAnGvRD//busrJ5lZnB
         MxOMvkzjArGpyVmWHNGhGgKbozdtPQtFvPCjgQjgfftqdd/Y3RMPHJ/cUtQa2NBc4BzO
         fThSetAJf6mmJuudCoMM9HeA+aCCl9wzyf/zmr4eoXWZPM1eOGZQpLADb3vlG42nBVva
         5IHLECA/zldnG8KpBIVRvxZ+8tzGA2ySt+agZOzJ3cX0bxqFsJd+NWDwNSLZL43qWbmT
         iP4w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dyoung@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dyoung@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXV/9Ubfrb4ZC1WSrpNmp7axezgan8XTLlX/bYmDqcj0L0CgnDV
	Azs6CN7aJVx6QHjpg2Rc4U37Jmrn89Dl++D3ysWCb2rcnwBTsbHE62OuXf1k5D6CTYowO+rOX/c
	uBnHv1kYXiVo4FsN6qAc3ZAWy8j9qX2LcvyvbUfgAWSwzc1rRJVKfqYw9QIH4bcpMTQ==
X-Received: by 2002:ac8:25e7:: with SMTP id f36mr57248679qtf.139.1560329172200;
        Wed, 12 Jun 2019 01:46:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxoq8mhPhdsP6Y7AnHNARGDikPvwylMl9Jay++Ht2ZnkntnLSWXLSua2/9Bi4RjRjQoGAR3
X-Received: by 2002:ac8:25e7:: with SMTP id f36mr57248637qtf.139.1560329171606;
        Wed, 12 Jun 2019 01:46:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560329171; cv=none;
        d=google.com; s=arc-20160816;
        b=gvyBiFy22d9ydGk2x9ib6TjoUVJsu0xYaHjpIl+aoz/+GjgXH9IwkV73UdDjJdgZgl
         FnfasvWVC7FwpjBAuBgU9Y4R7wD3PJsOuhXxn6p6/iQ/FDnL85AtXoTGvp9mxZw3Yb2W
         +zQZZDpeFKPf5JmnbjtUsSurlSty8+4XK3yR1GkpaSuL0HCuXxw6GeisYXcjjYGb2DQ9
         HZW3mdntv8RvZIE181ePRytcpdUrBfItMWynxRbc3a4KgHbVFGYzJum8y1yz5gd3jRv6
         nTvnO3N9hEww6Y9Rh9ofGZdJT612CuDF+yNtyEUOePawG8pOhuOjUtnQf6UBRmSBbFWs
         zq1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=8Z6d7Pc5h0GDrv5AJ+xBedYk/BC2MV2Y54edSWNuCLs=;
        b=wuC2Sp0Wjr4wzRBUidPz01N4XEQvt7atyoz7ixGibbzKaA2xpyCxSlFFr6Hsubsytk
         Jr8DZsbtWhtcBENu24C/syNx6PL7XR/3cR3pp9acHeJKIhPD7ZjPTui/KfiUWd7/LXbs
         u6gSxkQMDyuc1T4qkemwPGdtlNzwYpSy0PFfqSnBi8JsJjiipD6wa2z/0OnoYKmA991C
         7JdGGfrFA7o01lD8c+a0T/Ph1slxikZ4i16rBimuWLh5fybS0mRthgnYgy5WQiguVDqp
         J5GJN3d6BADWp9gS8vvMabcB4xYAehFKPXttqsiYKy1mu/Gf03d7/UWPnzaZgtFrTnOk
         6JKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dyoung@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dyoung@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f17si7436353qkm.270.2019.06.12.01.46.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 01:46:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of dyoung@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dyoung@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dyoung@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id AAE913004425;
	Wed, 12 Jun 2019 08:46:04 +0000 (UTC)
Received: from dhcp-128-65.nay.redhat.com (ovpn-12-58.pek2.redhat.com [10.72.12.58])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 4D5AD176C9;
	Wed, 12 Jun 2019 08:45:56 +0000 (UTC)
Date: Wed, 12 Jun 2019 16:45:51 +0800
From: Dave Young <dyoung@redhat.com>
To: Chen Zhou <chenzhou10@huawei.com>
Cc: catalin.marinas@arm.com, will.deacon@arm.com, akpm@linux-foundation.org,
	ard.biesheuvel@linaro.org, rppt@linux.ibm.com, tglx@linutronix.de,
	mingo@redhat.com, bp@alien8.de, ebiederm@xmission.com,
	wangkefeng.wang@huawei.com, linux-mm@kvack.org,
	kexec@lists.infradead.org, linux-kernel@vger.kernel.org,
	takahiro.akashi@linaro.org, horms@verge.net.au,
	linux-arm-kernel@lists.infradead.org
Subject: Re: [PATCH 1/4] x86: kdump: move reserve_crashkernel_low() into
 kexec_core.c
Message-ID: <20190612084551.GA24575@dhcp-128-65.nay.redhat.com>
References: <20190507035058.63992-1-chenzhou10@huawei.com>
 <20190507035058.63992-2-chenzhou10@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190507035058.63992-2-chenzhou10@huawei.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Wed, 12 Jun 2019 08:46:10 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,
On 05/07/19 at 11:50am, Chen Zhou wrote:
> In preparation for supporting reserving crashkernel above 4G
> in arm64 as x86_64 does, move reserve_crashkernel_low() into
> kexec/kexec_core.c.

Other than the comments from James, can you move the function into
kernel/crash_core.c, we already have some functions moved there for
sharing.

Thanks
Dave

