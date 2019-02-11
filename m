Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82B3EC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 23:25:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 26EF52184E
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 23:25:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="gnJNhkJR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 26EF52184E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B57AE8E0190; Mon, 11 Feb 2019 18:25:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B07898E0189; Mon, 11 Feb 2019 18:25:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F5F88E0190; Mon, 11 Feb 2019 18:25:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5F6768E0189
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 18:25:13 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id i11so528258pgb.8
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 15:25:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=XRXJe8aZrEDHZZ+k1rwRacB9kSieBbyz6GFANJVHSOY=;
        b=pvDcx2pZHoLJbEPSHfwRKtwuLYhx+hP3Z9r51GnK04p2XE7uUC5ZPhxLcyN7O1Qpq3
         Oua35EKK/CwcZrOc1rfM5ZxQ2VU7vhb23AvC5x4mx2toQZ4uOrRzESOzfgXqFfi1QEHA
         cNYKUfUPasznBQNtHJWwC87znFE4E5sNDgbFIw5ESaAXGeDbVaj/EMdI2e9gXc2CpnZK
         c8DBDi0A6GuXx0A0M4XaSR1BGBzQos2JgXst6fL5pgQLY57gZVvplyf/L7STmpnwws+A
         c73TBjarN1ft4NESHXdvJ1gi8OrMHBnzIOPn74C8l7BtD5/ZYGL6/WcARfKzZzGlXYbL
         xOjA==
X-Gm-Message-State: AHQUAubROI4L6Z9YFStsO7NIndiKIWJ3IdnvzmtsABjwiiRnyci6Dez3
	lZcrKLSm80e7vmi34uuMs9Eesm7GbMgmzOM8laqOq6h3gAyjp/zRyWFyVosyHtwzdKL/l4SEYyB
	U8yLLHDP486LlJE8pG82KezXxvUp74RpzjuvdPNURYHeKwDEYVT7MIlA3Zn7NcvgLIih2nmVcxz
	v9vyW0WWpRVCoOPEybg91ErybbpfIhztscK1+njrGkFkxZ1470KWhwu1gJh+019e+iC8i8a0+kD
	9xLbM03sD8esYPexqk9LdCq2tzbVF6g4k7npW+nX6UD2g0/5T7VGJo4Vq37F+8zQd9qAMTz1X+2
	WeIFClCOfl8sQmBo7AVbM1Nr/lo6UIqDJF2gyf8qwtUG55XyRU7qNI0OW02HdeJDOchPvVmnwy+
	b
X-Received: by 2002:a63:6ec2:: with SMTP id j185mr699456pgc.341.1549927512948;
        Mon, 11 Feb 2019 15:25:12 -0800 (PST)
X-Received: by 2002:a63:6ec2:: with SMTP id j185mr699406pgc.341.1549927512190;
        Mon, 11 Feb 2019 15:25:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549927512; cv=none;
        d=google.com; s=arc-20160816;
        b=SLxp/40HwWRauGtSBggqHXjIHvuwibAbx7sb/RWBAsZc7MNaZcWgnXd9i+1tlnitn/
         fPnoeuWR/YuBwzEpeCarKepxVyl2MyTCabdKty9vLAUh9dy5yluaNzQQekp4UIVcyi8n
         o85e3JImoKhbapJq7boa1CoUDHrXnxIGcD9tyeL7yn0XKRKeOyoTb65F2GlWpTZDsbIf
         /teE1pGHE3ilDTaARrJ5N3Z12yY1h3J3WpxVp7aFjCbhy3wMTmQbzQt58M8PT3fBr/UJ
         JuyY9goj1LH7uuDkeYaxmBTJFfLNgeRICIqCC6IPykHp8nngHFYYmoLqqRsJ6UdIUGpd
         IXnw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=XRXJe8aZrEDHZZ+k1rwRacB9kSieBbyz6GFANJVHSOY=;
        b=Iz0IT5SjHyRlXtbZN0pmJ18QXhomGhWQyw6jEyCNO/x4giD4xM1BVoL6qGTSVdmN4u
         1XrcbjtDGoWhsjkZmv8n5WjJqxByQR0Mz4sF+HkEf/KYdk5WZcLrWYuyuo52iKqCu1Ks
         Ue7Qt+/bFI7/E+vnBTqmBuD+3LgmEvyiajBzBwJOumD9EV6xiFfTz5QLTsH2fgMuxJpX
         TDz5OIWRgQvqsOsyXTgxBSAtlnzrDklGamKZi788pOeUN12vIwn6IbL8EDgjb0tDnHOJ
         k2/8IEU20jIee6oA4P4IejK/uDn1goTFVR4lxhg6m9dNromXHVW1PMhlKXC8E72LR6Ru
         z6Dg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=gnJNhkJR;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o23sor16218781pgv.0.2019.02.11.15.25.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 15:25:12 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=gnJNhkJR;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=XRXJe8aZrEDHZZ+k1rwRacB9kSieBbyz6GFANJVHSOY=;
        b=gnJNhkJRlEjow9q9Z9lougjKtjwotHpRkU8KW8EOTGblSHlRz78aK6SA5VY6sVzmk5
         GBIUFSRk0TNd7EegRjdswufkGnpZuEox6g4EZEJchdOgaRKoi05AvdVnhrfkAu7VelOO
         UwlWvVS0TttC4Wd+cMfsQPXiKrl5GZR1ZwEd2eFJ3kWU5GI2iZzImZaek1wcu7u8rSC4
         43E+DXMn09CTVzBYI9OAmYpa96svnzDBfeDd2ULpsq3VBEO7F8NaslH4gWDlZa2F57Ls
         5k7A5EVf0neMNeakJIJJsBQ7ro3Abv8FuDMIqD0ekRnoyxFwnJrqdhEH4U33q+EmjNwz
         M3aw==
X-Google-Smtp-Source: AHgI3Ia0Yhbeldmp4Aux/hDjVRNRPVzNAGrUxd+eW42PSy/9nnk/gDKe9W8RDapAE/cCOO5rixjcVg==
X-Received: by 2002:a63:aa46:: with SMTP id x6mr733312pgo.452.1549927511766;
        Mon, 11 Feb 2019 15:25:11 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id x6sm9945025pfb.183.2019.02.11.15.25.11
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 15:25:11 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1gtKwo-0003cn-Kh; Mon, 11 Feb 2019 16:25:10 -0700
Date: Mon, 11 Feb 2019 16:25:10 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ira Weiny <ira.weiny@intel.com>, John Hubbard <jhubbard@nvidia.com>,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Davidlohr Bueso <dave@stgolabs.net>,
	Netdev <netdev@vger.kernel.org>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 2/3] mm/gup: Introduce get_user_pages_fast_longterm()
Message-ID: <20190211232510.GP24692@ziepe.ca>
References: <20190211201643.7599-1-ira.weiny@intel.com>
 <20190211201643.7599-3-ira.weiny@intel.com>
 <20190211203916.GA2771@ziepe.ca>
 <bcc03ee1-4c42-48c3-bc67-942c0f04875e@nvidia.com>
 <20190211212652.GA7790@iweiny-DESK2.sc.intel.com>
 <fc9c880b-24f8-7063-6094-00175bc27f7d@nvidia.com>
 <20190211215238.GA23825@iweiny-DESK2.sc.intel.com>
 <20190211220658.GH24692@ziepe.ca>
 <CAPcyv4htDHmH7PVm_=HOWwRKtpcKTPSjrHPLqhwp2vhBUWL4-w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4htDHmH7PVm_=HOWwRKtpcKTPSjrHPLqhwp2vhBUWL4-w@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 02:55:10PM -0800, Dan Williams wrote:

> > I also wonder if someone should think about making fast into a flag
> > too..
> >
> > But I'm not sure when fast should be used vs when it shouldn't :(
> 
> Effectively fast should always be used just in case the user cares
> about performance. It's just that it may fail and need to fall back to
> requiring the vma.

But the fall back / slow path is hidden inside the API, so when should
the caller care? 

ie when should the caller care to use gup_fast vs gup_unlocked? (the
comments say they are the same, but this seems to be a mistake)

Based on some of the comments in the code it looks like this API is
trying to convert itself into:

long get_user_pages_locked(struct task_struct *tsk, struct mm_struct *mm,
                           unsigned long start, unsigned long nr_pages,
			   unsigned int gup_flags, struct page **pages,
			   struct vm_area_struct **vmas, bool *locked)

long get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
                             unsigned long start, unsigned long nr_pages,
			     unsigned int gup_flags, struct page **pages)

(and maybe a FOLL_FAST if there is some reason we have _fast and
_unlocked)

The reason I ask, is that if there is no reason for fast vs unlocked
then maybe Ira should convert HFI to use gup_unlocked and move the
'fast' code into unlocked?

ie move incrementally closer to the desired end-state here.

Jason

