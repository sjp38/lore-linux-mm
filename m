Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05B3EC76195
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 16:13:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C78ED205ED
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 16:13:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C78ED205ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 448BA8E0009; Tue, 16 Jul 2019 12:13:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F7DE8E0006; Tue, 16 Jul 2019 12:13:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E5728E0009; Tue, 16 Jul 2019 12:13:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0AF2C8E0006
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 12:13:13 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id o16so18468298qtj.6
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 09:13:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=FaRY9REk0dNOyBUpXX2UovVXh7myfxnWc78AJyJvbSM=;
        b=Lkp7AmQAjkW/Ag6UK57czGsQlh/sCzznNlWSdmui5vdzRM91aD1QBKbGQTqwubuY4B
         B04qgbq2ep3wzfYVjpVYCGv72sn2l3Gtcu8l5STZHk+37o8XwSZ03dlKjiYZU81YjaOT
         y5DsGNiY1ImUkRSwhLn2IInfxVcizDCVZOBbH1qcaXEyitcmia1acANxG0mw3kD0Av1z
         xBhmJKqY70HkpAUfaIloHrDr6pvBCF4fYhULURklt6ampwkL6TyPGqcYbPfphF/3n7nI
         Wp8fCcnSDODrHw/AhzI22qjCUaoflYejjPGIiemNG6j8sS3WJ5vvFOaIxlF9szCDG/kZ
         1y3g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAURHuBq8daVNeMjDOC1nXG5MCAweoG/X1SQuKtxkvG1f51mA6ko
	NAu8b+/yzsElIB8N57DWpKrSUdl60FjtadhLxQ10wK6DSoJMgyepicH0F4fmsKqJr9/EpEgHGp+
	NUrLUIGcLIjTAgRWwxwGKj28Ph0lK9RrlKeKXbZBwaONNMLRC3R8E9+G8s5bg6E7WSA==
X-Received: by 2002:a37:97c5:: with SMTP id z188mr23571233qkd.5.1563293592827;
        Tue, 16 Jul 2019 09:13:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx9kz916DJwXwg8yoEKbbB6+jsgpmlXQc4mX63UnT9P6zrviTJdJ8ldRl6jkdb6L+jPsf/U
X-Received: by 2002:a37:97c5:: with SMTP id z188mr23571189qkd.5.1563293592303;
        Tue, 16 Jul 2019 09:13:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563293592; cv=none;
        d=google.com; s=arc-20160816;
        b=Xvdc8jzu3cwg+jGs1kd03p/R/0HRbpsPrZ9I63UG6bNQ/UIWy+CIZ3vvcnURvbPDRP
         Gv2vte10kUGZiHzXk5xmVPwP5IK6r/mGmIWH+c6H1SuIyOaCqz/dymhOgHnRcO9Qu8Jx
         +nag+/gCZrDuVVi2p3CD9E5DcT8uArYOEx1rlBzg32hpicqCOJvxyTTQyfq31W076Zh3
         xo2iupu4N0BMe8DUHTjhRM6fkweVjUJRqPk0CaW3chObJZVP3/ASPj8Gm3Z6VaNtOaKi
         RvmZp5CPJKkwp2PJOgmcPAkZNJYwV8TVUBCgJC5t1UtJRjIxIOWIimPhZt0jXFJ/doUd
         bX6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=FaRY9REk0dNOyBUpXX2UovVXh7myfxnWc78AJyJvbSM=;
        b=wzDckHVcvzQijc2P+4PhrN3kDsm45kL28wGJFPMnz5pjCK2Ke+FtNsqUFtuICUfcbo
         vVENy/YkeUkJvgD/WUJRfVC1R1L+ytAw2Zz/zkVtJ1c7+VtJ3H2ORpK3ubhH5qUa8hW9
         oRH83j4zGhAt64Vj8WSQALO/cHcZxFwmYKCLbwrwd/N8o6YHP3L0apbt22uz/fzS6WGQ
         dYWdxRIYicVBsXOg+rU57j8iOLo5Xh7F1Gx550RlZAzHrrqX3jFP1o2q0zaLy/ZpA9SS
         UaLM2GXO16sRNh6oy5i/jAUsOFhr8AOmwhc8uSewPSxVXS3qT7j49J05IgqQ1V5E8wA4
         NNtw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v35si13699450qtj.81.2019.07.16.09.13.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 09:13:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 98E3481F31;
	Tue, 16 Jul 2019 16:13:10 +0000 (UTC)
Received: from redhat.com (ovpn-122-108.rdu2.redhat.com [10.10.122.108])
	by smtp.corp.redhat.com (Postfix) with SMTP id 8E7D86012C;
	Tue, 16 Jul 2019 16:12:57 +0000 (UTC)
Date: Tue, 16 Jul 2019 12:12:56 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: "Wang, Wei W" <wei.w.wang@intel.com>
Cc: "Hansen, Dave" <dave.hansen@intel.com>,
	David Hildenbrand <david@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	"nitesh@redhat.com" <nitesh@redhat.com>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>,
	"pagupta@redhat.com" <pagupta@redhat.com>,
	"riel@surriel.com" <riel@surriel.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"lcapitulino@redhat.com" <lcapitulino@redhat.com>,
	"aarcange@redhat.com" <aarcange@redhat.com>,
	"pbonzini@redhat.com" <pbonzini@redhat.com>,
	"Williams, Dan J" <dan.j.williams@intel.com>,
	"alexander.h.duyck@linux.intel.com" <alexander.h.duyck@linux.intel.com>
Subject: Re: [PATCH v1 6/6] virtio-balloon: Add support for aerating memory
 via hinting
Message-ID: <20190716120839-mutt-send-email-mst@kernel.org>
References: <20190619222922.1231.27432.stgit@localhost.localdomain>
 <20190619223338.1231.52537.stgit@localhost.localdomain>
 <20190716055017-mutt-send-email-mst@kernel.org>
 <cad839c0-bbe6-b065-ac32-f32c117cf07e@intel.com>
 <3f8b2a76-b2ce-fb73-13d4-22a33fc1eb17@redhat.com>
 <bdb9564d-640d-138f-6695-3fa2c084fcc7@intel.com>
 <286AC319A985734F985F78AFA26841F73E16AB21@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <286AC319A985734F985F78AFA26841F73E16AB21@shsmsx102.ccr.corp.intel.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Tue, 16 Jul 2019 16:13:11 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 16, 2019 at 03:01:52PM +0000, Wang, Wei W wrote:
> On Tuesday, July 16, 2019 10:41 PM, Hansen, Dave wrote:
> > Where is the page allocator integration?  The set you linked to has 5 patches,
> > but only 4 were merged.  This one is missing:
> > 
> > 	https://lore.kernel.org/patchwork/patch/961038/
> 
> For some reason, we used the regular page allocation to get pages
> from the free list at that stage.


This is what Linus suggested, that is why:

https://lkml.org/lkml/2018/6/27/461

and

https://lkml.org/lkml/2018/7/11/795


See also

https://lkml.org/lkml/2018/7/10/1157

for some failed attempts to upstream mm core changes
related to this.

> This part could be improved by Alex
> or Nitesh's approach.
> 
> The page address transmission from the balloon driver to the host
> device could reuse what's upstreamed there. I think you could add a
> new VIRTIO_BALLOON_CMD_xx for your usages.
> 
> Best,
> Wei

