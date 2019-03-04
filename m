Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E48BC43381
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 06:21:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3853C20815
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 06:21:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3853C20815
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B330A8E0003; Mon,  4 Mar 2019 01:21:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE3EB8E0001; Mon,  4 Mar 2019 01:21:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B8008E0003; Mon,  4 Mar 2019 01:21:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7037E8E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 01:21:49 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id q193so3691715qke.12
        for <linux-mm@kvack.org>; Sun, 03 Mar 2019 22:21:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=4H5x4ZP3PV2m8JBIMIESQKMTqM4hHipw5cc/XDViTUk=;
        b=tZSdjBJJMSBtascjQqGV6MXMSAxzpDLph2ZNI6XPXWdcw47ZFVJsuWpljGpZDGl/7H
         GJBHEzQz2zdQyM9sioipSY+O4liRiNrDg6dugm57mr4ZgGYTxwRQqrMKwjczNZJlQ/6c
         QfbeccvOZdAJ5cRNW74qDRhB8M/fT/ikE+RDILCOJ20ywbSjIe3PdpTKeTLQkYh8vsXm
         q1kW5sYzHzzWRFb2C71MGDgGGEE4Vqr95qeh0W4oNBtPe1VOwIXwfsDKWHifjXwpCjFF
         AX1j2P6VWBEpSOHWY0vA2nv4KNsdoav94XMN9z6aA4BNyERNRThH15VBoMGTICU97lKn
         y31g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dyoung@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dyoung@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVu7s9NY/y0VS1+RFWxbmyVBGNhOAyweTYBe9uqxOPGvSJlDA5y
	Bt9M9uPf7FMKJLFbNXyAUfuKmr54ALpribl7n5H2LaJYx2goJHeSeV+aV7NJcu74GuDInh5iGS2
	uO8yAyZELWxug/C4lwgFuIi168nEyDJD+N0FY6USQ0vmB5G6CiBEXFMqqr38S1xBXyg==
X-Received: by 2002:a05:620a:122e:: with SMTP id v14mr12550042qkj.105.1551680509237;
        Sun, 03 Mar 2019 22:21:49 -0800 (PST)
X-Google-Smtp-Source: APXvYqybIO7rvvWHGKWDVHb1BSUbERroIN06CRcAamhodfP8QBQlA/MGMX2xRPDLAH2gQFFZ09TT
X-Received: by 2002:a05:620a:122e:: with SMTP id v14mr12550001qkj.105.1551680508190;
        Sun, 03 Mar 2019 22:21:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551680508; cv=none;
        d=google.com; s=arc-20160816;
        b=Rp5+PZ29UtMIszGzbyWrvAJ7fw1qB5EvWoOOS8Yiwxs+silHmeA9/G6uCNMBc6IvPs
         6+6ROjp9HbMwk74e2qoncW/hlbygYZVpWz7pc297eCowwO7tMQb1hSBIIe/24X1L7Pdw
         qag+uqcN5iXTR513cz4jJxHZnXEO6Fuant0KWX5t6MyLIVUviohyijZ9o/S6YrjTRnAa
         6z+kkvwFaHzYZz2LMJ+arrEAN7lGKKEomVRzK/2P0rrzZEGu10LyMHKhdWVVpV9UOj0l
         n7c0w0nV1zFAZFv69vaMP5ODu1Go3/IeXBv/IXYqCdonFU9S09zgc6rrFDH60rqySaXx
         B0Ig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=4H5x4ZP3PV2m8JBIMIESQKMTqM4hHipw5cc/XDViTUk=;
        b=NdMcbbQzTg2/AjuNdcQtwBWgveN12CcIetUB1K2V65P7ttwEN+rFCwd2K+Epe1fNJn
         UtiIAUzrEFTnaYOx1CZbStY1yM2RsGoQVDpQBwuadkztKqX7IAf8gn2qSlGEln8KA0jm
         wCtbid+59wpQfde96mLIU2VMVyfIt/N7Y1WdZaD/uPZPhCQodO+SE8kw9Wrzex5UTXP0
         JcyEy1QuPxc1YozM8/Y6HVg067wE+n7TS8hlyuSCRuxx3CVFAakJ2RYc61RSId9oBYLk
         lUKGc3jvLRn9zJ5XuiJImoMqJmopcCr+9dsUa7utyEsQw+AprptCuR7cA7KFyPL7I3Au
         kX7w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dyoung@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dyoung@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f89si2649868qtb.236.2019.03.03.22.21.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Mar 2019 22:21:48 -0800 (PST)
Received-SPF: pass (google.com: domain of dyoung@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dyoung@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dyoung@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7F5AA3086268;
	Mon,  4 Mar 2019 06:21:46 +0000 (UTC)
Received: from dhcp-128-65.nay.redhat.com (ovpn-12-176.pek2.redhat.com [10.72.12.176])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 1DB251001DCA;
	Mon,  4 Mar 2019 06:21:21 +0000 (UTC)
Date: Mon, 4 Mar 2019 14:21:18 +0800
From: Dave Young <dyoung@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
	devel@linuxdriverproject.org, linux-fsdevel@vger.kernel.org,
	linux-pm@vger.kernel.org, xen-devel@lists.xenproject.org,
	kexec-ml <kexec@lists.infradead.org>, pv-drivers@vmware.com,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>, Baoquan He <bhe@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Christian Hansen <chansen3@cisco.com>,
	David Rientjes <rientjes@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	Jonathan Corbet <corbet@lwn.net>, Juergen Gross <jgross@suse.com>,
	Julien Freche <jfreche@vmware.com>, Kairui Song <kasong@redhat.com>,
	Kazuhito Hagio <k-hagio@ab.jp.nec.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Konstantin Khlebnikov <koct9i@gmail.com>,
	"K. Y. Srinivasan" <kys@microsoft.com>,
	Len Brown <len.brown@intel.com>, Lianbo Jiang <lijiang@redhat.com>,
	Matthew Wilcox <willy@infradead.org>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Michal Hocko <mhocko@kernel.org>, Michal Hocko <mhocko@suse.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Miles Chen <miles.chen@mediatek.com>, Nadav Amit <namit@vmware.com>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Omar Sandoval <osandov@fb.com>, Pankaj gupta <pagupta@redhat.com>,
	Pavel Machek <pavel@ucw.cz>,
	Pavel Tatashin <pasha.tatashin@oracle.com>,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Stefano Stabellini <sstabellini@kernel.org>,
	Stephen Hemminger <sthemmin@microsoft.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Vitaly Kuznetsov <vkuznets@redhat.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Xavier Deguillard <xdeguillard@vmware.com>
Subject: Re: [PATCH v2 0/8] mm/kdump: allow to exclude pages that are
 logically offline
Message-ID: <20190304062118.GA31037@dhcp-128-65.nay.redhat.com>
References: <20181122100627.5189-1-david@redhat.com>
 <20190227053214.GA12302@dhcp-128-65.nay.redhat.com>
 <20190228114535.150dfaebbe4d00ae48716bf0@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190228114535.150dfaebbe4d00ae48716bf0@linux-foundation.org>
User-Agent: Mutt/1.9.5 (2018-04-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Mon, 04 Mar 2019 06:21:47 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 02/28/19 at 11:45am, Andrew Morton wrote:
> On Wed, 27 Feb 2019 13:32:14 +0800 Dave Young <dyoung@redhat.com> wrote:
> 
> > This series have been in -next for some days, could we get this in
> > mainline? 
> 
> It's been in -next for two months?

Should be around 3 months

> 
> > Andrew, do you have plan about them, maybe next release?
> 
> They're all reviewed except for "xen/balloon: mark inflated pages
> PG_offline". 
> (https://ozlabs.org/~akpm/mmotm/broken-out/xen-balloon-mark-inflated-pages-pg_offline.patch).
> Yes, I plan on sending these to Linus during the merge window for 5.1
> 

Thanks!

