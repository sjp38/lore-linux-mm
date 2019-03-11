Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9DD1C10F06
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 10:04:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B151E2084F
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 10:04:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B151E2084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 36EF48E0013; Mon, 11 Mar 2019 06:04:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 31C1C8E0002; Mon, 11 Mar 2019 06:04:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E4F58E0013; Mon, 11 Mar 2019 06:04:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id E5A528E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 06:04:57 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id w134so4045201qka.6
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 03:04:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=JBOctbj0E6y/W4InLJy6BTES6NJnTTwTomLr0cR9UjI=;
        b=U5IfgJNNDJOlGR833M8BYKXSP7vXXZ4zrWEji9exOHnQprADufLuUy9IOkQbirUvBV
         3T8Y/+IlJxPxc4LPjzgB0a9Jn5kvXkr2TguLFtlxkFzZInCloearaTbT2LZIjF0IVIAw
         QQ/cZk8mfgtmFKjIZU2QGLQTDhIUQcL0xCNCaQjxO1Iarpi3EtbJ44IKGfzblSxRX2HE
         QC3ZOtJcsiBKOHvzxm4KIkExl2T9J19j+O+ZIJFIkFgL/0YHogzzE5XWB/zCtlxQu3yJ
         na01a6uEt5Ysxl2r68nvfFocBbcCbU4kQTnffdfWE09NYdlcIOTI/DBLfA9SUf3rGrps
         8dRA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dyoung@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dyoung@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW3zUxX5pjFCE5XcIgxyJzwbsR6l1IVWUcPItz+3C6YLuaWaTGL
	oAcJz+EsMzzWapoEhYgGsv6+RvG71BaHjjiMYK/YPIqI1zk8ej3ex2IGN2KG7tacVMI+EiKlFUu
	oEx0FjPdINgk/nexaLSggc93GRi93wstkmEIwC5+81Ajyh7z8gJel6f48tyCSuoeu7w==
X-Received: by 2002:a05:620a:12e1:: with SMTP id f1mr5531625qkl.151.1552298697750;
        Mon, 11 Mar 2019 03:04:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzAzy7XG6CoolP/kWBbCwyGmRZMnKGvR49HxdJiIYPuH2gx29ZBbfdTy4n460fxoozmiemO
X-Received: by 2002:a05:620a:12e1:: with SMTP id f1mr5531596qkl.151.1552298697115;
        Mon, 11 Mar 2019 03:04:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552298697; cv=none;
        d=google.com; s=arc-20160816;
        b=oc0SH6CRwMQeWBWa7q22sCZHq3Ac/lHiv1iz7Hd23Bq6Bs3XDVIeWn50G/FiJNHxQV
         XksLtja2187Ja+Yl8ot/k6QuOxg9ciOIJ0Z6F8Kej3pgiZAF3kzxZAurPx7EGcXVXN4m
         eD/Bs1aHBPMP6azjltaX5u4aWiNd+B2GP1JPa96D5udvU7FxlgH4Gw4wjG5ivTBkSYut
         5ux45OAlNQc18bxC2I8CzhrxP88DQ0+OTMyALX52OQ66K8iTUAn6lNv4Ip02i1G4jefM
         j6l+veRJEvJFlycI06TQQNMoCQ8ktq2TjFGS5iZGnDirRkpphV7fvwm94SBtixGkY0zo
         6gdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=JBOctbj0E6y/W4InLJy6BTES6NJnTTwTomLr0cR9UjI=;
        b=j5i2lXL8f18KKpyncbd2MA1RNLUC6aACZQ555vZ5HSfA+hysX2g+kdPT85YaJ1PqHw
         /BJa3leHkkErvLIIaSUr3Yum+LmikAq69LHky//bkrwTup5yC96KDaSyaHwR7xByaduK
         LixjeJG0ujbcsY65DBeKV0i7j1f7UUdkzEnb0SBflU4GYyhpMXd5MBW63LkJr2Uk4ZwW
         MySsfFJBPoqL2UtK0WB7f0yBWTC1T18uNObn/KbjkKAnlCfK+dLcRcTmiSQCFdJiz8Ep
         5znR6rc2qmaIhCeeuW9BietztrpwP9caLhXSYBe2NLGx1oB2qTw2DM7x64iSq/Utwk8N
         PinQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dyoung@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dyoung@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f129si2452058qkb.56.2019.03.11.03.04.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 03:04:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of dyoung@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dyoung@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dyoung@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 38C79307D90D;
	Mon, 11 Mar 2019 10:04:56 +0000 (UTC)
Received: from dhcp-128-65.nay.redhat.com (ovpn-12-113.pek2.redhat.com [10.72.12.113])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id C4E5617AF9;
	Mon, 11 Mar 2019 10:04:42 +0000 (UTC)
Date: Mon, 11 Mar 2019 18:04:38 +0800
From: Dave Young <dyoung@redhat.com>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org, devel@linuxdriverproject.org,
	linux-fsdevel@vger.kernel.org, linux-pm@vger.kernel.org,
	xen-devel@lists.xenproject.org,
	kexec-ml <kexec@lists.infradead.org>, pv-drivers@vmware.com,
	Andrew Morton <akpm@linux-foundation.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Baoquan He <bhe@redhat.com>, Omar Sandoval <osandov@fb.com>,
	Arnd Bergmann <arnd@arndb.de>, Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@suse.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Lianbo Jiang <lijiang@redhat.com>, Borislav Petkov <bp@alien8.de>,
	Kazuhito Hagio <k-hagio@ab.jp.nec.com>
Subject: Re: [PATCH v2 3/8] kexec: export PG_offline to VMCOREINFO
Message-ID: <20190311100438.GA12545@dhcp-128-65.nay.redhat.com>
References: <20181122100627.5189-1-david@redhat.com>
 <20181122100627.5189-4-david@redhat.com>
 <20190311090402.GA12071@dhcp-128-65.nay.redhat.com>
 <d9e578c3-5ae6-5e82-a0a8-14c7e12c729f@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d9e578c3-5ae6-5e82-a0a8-14c7e12c729f@redhat.com>
User-Agent: Mutt/1.9.5 (2018-04-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Mon, 11 Mar 2019 10:04:56 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> > The patch has been merged, would you mind to send a documentation patch
> > for the vmcoreinfo, which is added recently in Documentation/kdump/vmcoreinfo.txt
> > 
> > A brief description about how this vmcoreinfo field is used is good to
> > have.
> > 
> 
> Turns out, it was already documented
> 
> PG_lru|PG_private|PG_swapcache|PG_swapbacked|PG_slab|PG_hwpoision
> |PG_head_mask|PAGE_BUDDY_MAPCOUNT_VALUE(~PG_buddy)
> |PAGE_OFFLINE_MAPCOUNT_VALUE(~PG_offline)
> -----------------------------------------------------------------
> 
> Page attributes. These flags are used to filter various unnecessary for
> dumping pages.

Good enough, just ignore the request!

Thanks!

