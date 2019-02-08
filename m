Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7AD00C282C2
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 01:44:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D5C520869
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 01:44:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D5C520869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 711D38E006E; Thu,  7 Feb 2019 20:44:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C08D8E0002; Thu,  7 Feb 2019 20:44:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 562E48E006E; Thu,  7 Feb 2019 20:44:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 120DE8E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 20:44:23 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id o7so1328110pfi.23
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 17:44:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=NREgLueQYiNpeDvopa6HKK4WeC+DDbVHKpVnYRgFxAA=;
        b=EMmErPBIZstzLSewgKT5E3uaKLulI6wEhMAvWdzAlJ+0AhMdtlWkuUzB8Is85qGGgp
         J42tEhG3PVsgI0KIJ0TECGSCul6O4Q0bws5Lj5pGvSzd0PZDM/GFOVptzXD63tuxt6fL
         7kRQU2N58oi4xT39pvWXB1H8iHLU26ETq40LLeGKF0O93mVcVIbAT/W8NyL5HJE06WS3
         1x7V+lHa3C3WuH3fG7fY26JcpaewzNiyj//GjhZhd5dzp2/Qq71c1mA57sFohIZ0vqQ3
         MWyD/FEIOVmk5aod7G4fnZjnVjIvFTec7GKC5byn8ykzw9WGE3sSfrpXaGx0DWj7LQVM
         P9LA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuYkoLlT5LViiHTpL0I8VDE4DXJiuNwAjz5UAHDXhJ1OEFdoSbXp
	1l0IjmxF1oyrx2NnMesKqTGwPGy49v44PBG4vEVuVSHN3eediOFlmWAHEmCV6EEy0fIWXspxaXg
	kj5kIBgjVBXWzxnCAOnqnBd5oJRKY6ytk5Iwl5M7VCCiABC9Jlzi/DAs6O5V5bkoICA==
X-Received: by 2002:a62:5444:: with SMTP id i65mr19885510pfb.193.1549590262672;
        Thu, 07 Feb 2019 17:44:22 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ4yZ2fIIrtmv1wvr3guVw6OEp0TaVGaDqY3pKDvkuSzbiwrx1epdW72n/InAuZ0VVJMn+j
X-Received: by 2002:a62:5444:: with SMTP id i65mr19885438pfb.193.1549590261623;
        Thu, 07 Feb 2019 17:44:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549590261; cv=none;
        d=google.com; s=arc-20160816;
        b=WqW/eFISpToDsvjwMaR+ynz1cu47B5XhTk8WrYAbxgTBNOBoGv5rAsZRokpbEQ5GNg
         v/luYrbS01ZmOhzhVqo+d/MOhPqOHQEbRh8eWxobx0GkVQrh40VG3Mfw6HOefqLyABDj
         XkkOc09WZgHjpRGDpy/6e5CRJUqtHlUwXeXAKDrDKBsXj9J6H+Y2RvTHH7B3OE/YNXH5
         tY4XZly5mSJyxV9+vFc40oZFAcl6gD8hjrIWR14914+mp4skK0eNFHeuB4IgqNxub8WM
         jt/BxiZy0H4nOeW9KsMaoEEMK9PCFlWojHWf78XSlJdQTnLddSUZId8sx60uyawA9LIL
         fJjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=NREgLueQYiNpeDvopa6HKK4WeC+DDbVHKpVnYRgFxAA=;
        b=bNoVg268Zo3DGo3zKwrj88G6JzNqq86vqZ6SXv6e9lSjN8+358i/Z+OsWAsw6DZkkn
         o8qQvrQLAgYxyr7EwrQ6tGCK58GdmNYOKCAiPqRXkC8bVyrO4n+Gy6pTz20UMv5CXp6y
         3n+1pe+Jp3mPQZugLrnf245JD1QnndvHoFw/k5ir0g34q7xgv/xBpirnZZzFAFUrWuNZ
         4pBrKUC0oY7v4giNUQ+ED96Ap0yrh1sMxqWY/Qt8ER0UTSzkKyFQZIUvawa0y/M3aDqh
         JFTYekOxzIL70Pp7Wd089dPk1R4xz/p1sVR/QezTShQRaMK8rXktMr9rel9MRnvxEe0+
         boDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id p80si706729pfi.124.2019.02.07.17.44.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 17:44:21 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 Feb 2019 17:44:20 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,346,1544515200"; 
   d="scan'208";a="298118289"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga005.jf.intel.com with ESMTP; 07 Feb 2019 17:44:20 -0800
Date: Thu, 7 Feb 2019 17:44:04 -0800
From: Ira Weiny <ira.weiny@intel.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Dave Chinner <david@fromorbit.com>,
	Doug Ledford <dledford@redhat.com>,
	Christopher Lameter <cl@linux.com>,
	Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>,
	lsf-pc@lists.linux-foundation.org,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190208014403.GA32701@iweiny-DESK2.sc.intel.com>
References: <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
 <20190206210356.GZ6173@dastard>
 <20190206220828.GJ12227@ziepe.ca>
 <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
 <20190207035258.GD6173@dastard>
 <20190207052310.GA22726@ziepe.ca>
 <CAPcyv4jd4gxvt3faYYRbv5gkc6NGOKjY_Z-P0Ph=ss=gWZw7sA@mail.gmail.com>
 <20190207171736.GD22726@ziepe.ca>
 <CAPcyv4hsHeCGjcJNEmMg_6FYEsQ_8Z=bvx+WmO1v_LmoXbJrxA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hsHeCGjcJNEmMg_6FYEsQ_8Z=bvx+WmO1v_LmoXbJrxA@mail.gmail.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 07, 2019 at 03:54:58PM -0800, Dan Williams wrote:
> On Thu, Feb 7, 2019 at 9:17 AM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> >
> > Insisting to run RDMA & DAX without ODP and building an elaborate
> > revoke mechanism to support non-ODP HW is inherently baroque.
> >
> > Use the HW that supports ODP.
> >
> > Since no HW can do disable of a MR, the escalation path is SIGKILL
> > which makes it a non-production toy.
> >
> > What you keep missing is that for people doing this - the RDMA is a
> > critical compoment of the system, you can't just say the kernel will
> > randomly degrade/kill RDMA processes - that is a 'toy' configuration
> > that is not production worthy.
> >
> > Especially since this revoke idea is basically a DOS engine for the
> > RDMA protocol if another process can do actions to trigger revoke. Now
> > we have a new class of security problems. (again, screams non
> > production toy)
> >
> > The only production worthy way is to have the FS be a partner in
> > making this work without requiring revoke, so the critical RDMA
> > traffic can operate safely.
> >
> > Otherwise we need to stick to ODP.
> 
> Thanks for this it clears a lot of things up for me...
> 
> ...but this statement:
> 
> > The only production worthy way is to have the FS be a partner in
> > making this work without requiring revoke, so the critical RDMA
> > traffic can operate safely.
> 
> ...belies a path forward. Just swap out "FS be a partner" with "system
> administrator be a partner". In other words, If the RDMA stack can't
> tolerate an MR being disabled then the administrator needs to actively
> disable the paths that would trigger it. Turn off reflink, don't
> truncate, avoid any future FS feature that might generate unwanted
> lease breaks. We would need to make sure that lease notifications
> include the information to identify the lease breaker to debug escapes
> that might happen, but it is a solution that can be qualified to not
> lease break. In any event, this lets end users pick their filesystem
> (modulo RDMA incompatible features), provides an enumeration of lease
> break sources in the kernel, and opens up FS-DAX to a wider array of
> RDMA adapters. In general this is what Linux has historically done,
> give end users technology freedom.

To back off the details of this thread a bit...

The details of limitations imposed and how they would be tracked within the
kernel would be a great thing to discuss face to face.  Hence the reason for my
proposal as a topic.

Ira

