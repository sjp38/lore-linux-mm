Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B46C5C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 08:43:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7279E20C01
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 08:43:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7279E20C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 116CE6B0008; Fri,  9 Aug 2019 04:43:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C7686B000E; Fri,  9 Aug 2019 04:43:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED1356B0010; Fri,  9 Aug 2019 04:43:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9DEA46B0008
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 04:43:38 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id m30so513138eda.11
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 01:43:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=SpUt7Y6LhpcRDVu8UknwJ/2cBnANb0jfrfYaWqC13Gc=;
        b=HDRlru+HgYaEMOSdwsT5rJUVoSlZffAy4Z9xMJE1TmefMml+Qp6RJxVnwxB/cg4u50
         9IwraCbP4uKhWPeb8xUmBFNbY69T+3nIOgB9t99Fn/+3hyZTrOXJdDUCoqA0GTwgBLOl
         5K+h72BmHibXgFq2lSqNreeSoTNSNC4Z8xglMWve/364ilCyPSOEroS8g9jwuvkc6X/d
         2wIhJvpA/0X4vjSVNi3aIK3d+xuU7hb/b+4wCIsikIgfmceVTwoQ+pj+etwXckLG9ChU
         FvmMZ5zZgbD96z8YlbvR0djcinTBY5NwLTtI3dT37T8TTxjeachtRpe1uuUbrjvHjRrw
         as+w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAUzDs3XwWAqbAeBo/LadFachoHv/q0Cz7mTHRDwLqR03CGHfSVr
	V+0X7PAj/6VhatZ+CEwbFOVHgaGKXJM3Wsx+iyBytdcyWc7J+EU5/GQajwqA+yVciYoPX//s+EQ
	gIZtXH8jCWjm2xYOFe/J+TgJDPiMNP1iNgiye7/7iSsGkdAzVFg71lwGdP/AHYCPxDw==
X-Received: by 2002:aa7:c24b:: with SMTP id y11mr20897319edo.239.1565340218235;
        Fri, 09 Aug 2019 01:43:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw2Fufu8T7rSQ9Sv0EZsFv/T8rigxetDKLcGgcywrZhvDm5N1Hpnj2vwfJ/8f+IeQjyoJuO
X-Received: by 2002:aa7:c24b:: with SMTP id y11mr20897257edo.239.1565340217086;
        Fri, 09 Aug 2019 01:43:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565340217; cv=none;
        d=google.com; s=arc-20160816;
        b=hSJogvfi0hF8QqpYUaZobeEVpRd50eOSu0hg5RBkrKdNLkXEhUa1TZ5IzclC90hZVw
         JLZ8oF1vNlrDlCdFnKHh/cO+LXrTxg2He7ow1rLvowbWACem4aVMMHfoLgAaXX3Lylsp
         W5MTlE+I4KtaLWQeO8DJuN6nxWcIS4VeiL51Gr+nF9YkXqy5q7i20FEwBuasDomw/onM
         3a9WvPQZHCsEPJGQeZy0j8zqzI3gU87KpaeodWeATX0AYFjtzwi0MoGwx6vTAqbkVQiL
         JRY8ZAyQjN0LhI5T4gzeA0caKs7CDhOqrRCJ5Cqp2RQas6ZzlbQMD3zbZVip6fGRRPPX
         JpAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=SpUt7Y6LhpcRDVu8UknwJ/2cBnANb0jfrfYaWqC13Gc=;
        b=SoV0jTrhotT+pD9Pl5Dvv0r2ZhUZ7i8N/J+qj4MMG7vjLH/H2o8E4X3by2VsgwZ2TC
         wxyqloOczyGx4PWCnPStFAFFE5tJk9mmA7qDdagad4BolNBWv8MYx/lCl3uYBa98O9ah
         sPrz38yadwf9eyff47xP/XCu19NdbXnCle7hSZkc0vppgDwp4uqvs915aEwU4lE73jiH
         StPwpyWscpMv6WmNX+8vcmM8rav1RkqMoWnYMRaJCAby7EbDhmDaPgm7c6FuKUmiTwcB
         ayd+KuHXKpsywXfR49zMhK+5bOZTUXA/aUPZBVAdLT3gDg9JI3D4NbJ3SgqkAerqlm3A
         p8GA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x34si38116556edm.138.2019.08.09.01.43.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 01:43:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 689A0AE49;
	Fri,  9 Aug 2019 08:43:35 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 89DB71E437E; Fri,  9 Aug 2019 10:43:34 +0200 (CEST)
Date: Fri, 9 Aug 2019 10:43:34 +0200
From: Jan Kara <jack@suse.cz>
To: "Weiny, Ira" <ira.weiny@intel.com>
Cc: John Hubbard <jhubbard@nvidia.com>, Michal Hocko <mhocko@kernel.org>,
	Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>,
	"Williams, Dan J" <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	"ceph-devel@vger.kernel.org" <ceph-devel@vger.kernel.org>,
	"devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
	"devel@lists.orangefs.org" <devel@lists.orangefs.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"intel-gfx@lists.freedesktop.org" <intel-gfx@lists.freedesktop.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
	"linux-block@vger.kernel.org" <linux-block@vger.kernel.org>,
	"linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>,
	"linux-fbdev@vger.kernel.org" <linux-fbdev@vger.kernel.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"linux-media@vger.kernel.org" <linux-media@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"linux-rpi-kernel@lists.infradead.org" <linux-rpi-kernel@lists.infradead.org>,
	"linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"rds-devel@oss.oracle.com" <rds-devel@oss.oracle.com>,
	"sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>,
	"x86@kernel.org" <x86@kernel.org>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>
Subject: Re: [PATCH 00/34] put_user_pages(): miscellaneous call sites
Message-ID: <20190809084334.GB17568@quack2.suse.cz>
References: <20190802091244.GD6461@dhcp22.suse.cz>
 <20190802124146.GL25064@quack2.suse.cz>
 <20190802142443.GB5597@bombadil.infradead.org>
 <20190802145227.GQ25064@quack2.suse.cz>
 <076e7826-67a5-4829-aae2-2b90f302cebd@nvidia.com>
 <20190807083726.GA14658@quack2.suse.cz>
 <20190807084649.GQ11812@dhcp22.suse.cz>
 <20190808023637.GA1508@iweiny-DESK2.sc.intel.com>
 <e648a7f3-6a1b-c9ea-1121-7ab69b6b173d@nvidia.com>
 <2807E5FD2F6FDA4886F6618EAC48510E79E79644@CRSMSX101.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2807E5FD2F6FDA4886F6618EAC48510E79E79644@CRSMSX101.amr.corp.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 08-08-19 16:25:04, Weiny, Ira wrote:
> > I thought I'd caught things early enough to get away with the
> > rename and deletion of that. You could either:
> > 
> > a) open code an implementation of vaddr_put_pages_dirty_lock() that
> > doesn't call any of the *put_user_pages_dirty*() variants, or
> > 
> > b) include my first patch ("") are part of your series, or
> > 
> > c) base this on Andrews's tree, which already has merged in my first patch.
> > 
> 
> Yep I can do this.  I did not realize that Andrew had accepted any of
> this work.  I'll check out his tree.  But I don't think he is going to
> accept this series through his tree.  So what is the ETA on that landing
> in Linus' tree?
> 
> To that point I'm still not sure who would take all this as I am now
> touching mm, procfs, rdma, ext4, and xfs.

MM tree would be one candidate for routing but there are other options that
would make sense as well - Dan's tree, VFS tree, or even I can pickup the
patches to my tree if needed. But let's worry about the routing after we
have working and reviewed patches...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

