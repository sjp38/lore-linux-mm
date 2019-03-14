Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44A99C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 09:03:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 09AD1217F5
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 09:03:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 09AD1217F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C6EB68E0003; Thu, 14 Mar 2019 05:03:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C44BB8E0001; Thu, 14 Mar 2019 05:03:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF3288E0003; Thu, 14 Mar 2019 05:03:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 519118E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 05:03:50 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id a1so2105897edx.4
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 02:03:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=F5XutsHbpj8vqPNc0V9My8iHtblSimdgu2ot6sW/YUY=;
        b=F7iRedDtqeNOxPkpe6YfjJhKtHa2/UdPxwE++Pc96Vn1mGv+8qszqtxMJWR5KSdNwy
         3+23EW6TDULygttQd7Ep2FLdvWx3SsUDoP6PF+Gh/peGREvW1q+lnGBSnKu7xR4e4tqy
         KEIHOYluFKu8GazCz8M/78wv/vUDP0D0cW5TNZ5XInksYryeVhOd1E6HS7Yl8kwU9OIi
         q4WdCh44dASLO1XuLkrcv+IG3qmCmC8V6REYayTX2egas5w1bg45/YOMsRDz85NnLFEz
         ErDL5L0ZQsExODuI3+sRE+qP3cGNjp/ZX0ucPowPjPXqD3cLOCGTdCIoQ90ds1ZHGvQw
         zHOw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAV2fP8/4jW/H+E9W9JiRDvmhY4I3y3Hdd2wy1uhrHz3SH8kejJ5
	JaSnR97mrnjWSQJGTd4h9i+ItHV2m8ZPyd/rP4oMLm5VcIYHF5R0zCECNSsthmOYQ5t2Bssi3Np
	zAgTFFFB7Q+cJaVY5dbhmkx+TWkWs273btfr2v9JE0eUJG0RX2MCp+Du+RSWPVJLXUQ==
X-Received: by 2002:a50:b308:: with SMTP id q8mr10302102edd.213.1552554229826;
        Thu, 14 Mar 2019 02:03:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz5vfU2iUuIa7K9vWB5v9PmV0SA46nEtjDV8GM8QTnljWoZ0Zd1lN0CMybtA6LAPujGyfBA
X-Received: by 2002:a50:b308:: with SMTP id q8mr10302051edd.213.1552554228960;
        Thu, 14 Mar 2019 02:03:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552554228; cv=none;
        d=google.com; s=arc-20160816;
        b=nTRX6rIt3DzDxcCa1gfVn/YmOVi/yny3wBrKqz7RSD/GgZXnQjhO4TL6Snbdh25/SS
         7g2jnw2fcP3zdQFOgGyd7oyYGDr2YX9YAgt5vWIo+HY5Nsq1RXK1X27CnUV0aiq8qzCb
         +SQAovFfJPyBiDh2TAU+M28thOOV9thHDH7wjUpGT3x5wO4dkMqPrm0VdOptgr0QQOjG
         hdxeNe58rk8aAQsEMwXyqELBAQM6TTDyVxU7+8rDI57FKqwrXCYL1gd9Rp26cDM20WNP
         ISc+9G27vM8XhzV+awxXwjc/LrpitHvAEzbcFodxiuF8rufA2K4xoaBm8debDdMjLSpI
         7CbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=F5XutsHbpj8vqPNc0V9My8iHtblSimdgu2ot6sW/YUY=;
        b=RZOxJjRQyIoCWE6ubscaRYSj5A+UTQ0NhRJV8gpvJkDj9QJT+mG5yuFTA0nLFHlrPE
         RzzFPV+akJci6eu/fkB1P8cIDeSwF7hIyM1TrU6vXIORj2hHD13wNh3GxoAqR+7h0Jdf
         h2dhc97CfZUsJu0S5v0Na01KOI21M5bECew+6lPXe+fz1xoxIx9RePaQwnebW1x/vyOW
         Xdk/KBvpJiIAxKsGvawn2DTR50zJqZcwxhO2dVrtK5yRllTFuI7dlEBvKEl0gxfSwtMn
         qrzdtBZJjXR90bXIIB66UWKaBel/s+IV+NwrGf+OLmmuij9l70CYWqJJknx4TXL4lOKd
         hz8A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gr2si711532ejb.324.2019.03.14.02.03.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 02:03:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id CD34FADFF;
	Thu, 14 Mar 2019 09:03:47 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 0DFAA1E3FE8; Thu, 14 Mar 2019 10:03:45 +0100 (CET)
Date: Thu, 14 Mar 2019 10:03:45 +0100
From: Jan Kara <jack@suse.cz>
To: Christopher Lameter <cl@linux.com>
Cc: Jerome Glisse <jglisse@redhat.com>, john.hubbard@gmail.com,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>, Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH v3 0/1] mm: introduce put_user_page*(), placeholder
 versions
Message-ID: <20190314090345.GB16658@quack2.suse.cz>
References: <20190306235455.26348-1-jhubbard@nvidia.com>
 <010001695b4631cd-f4b8fcbf-a760-4267-afce-fb7969e3ff87-000000@email.amazonses.com>
 <20190308190704.GC5618@redhat.com>
 <01000169703e5495-2815ba73-34e8-45d5-b970-45784f653a34-000000@email.amazonses.com>
 <20190312153528.GB3233@redhat.com>
 <01000169787c61d0-cbc5486e-960a-492f-9ac9-9f6a466efeed-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01000169787c61d0-cbc5486e-960a-492f-9ac9-9f6a466efeed-000000@email.amazonses.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 13-03-19 19:16:51, Christopher Lameter wrote:
> On Tue, 12 Mar 2019, Jerome Glisse wrote:
> 
> > > > This has been discuss extensively already. GUP usage is now widespread in
> > > > multiple drivers, removing that would regress userspace ie break existing
> > > > application. We all know what the rules for that is.
> 
> You are still misstating the issue. In RDMA land GUP is widely used for
> anonyous memory and memory based filesystems. *Not* for real filesystems.

Maybe in your RDMA land. But there are apparently other users which do use
mmap of a file on normal filesystem (e.g. ext4) as a buffer for DMA
(Infiniband does not prohibit this if nothing else, video capture devices
also use very similar pattern of gup-ing pages and using them as video
buffers). And these users are reporting occasional kernel crashes. That's
how this whole effort started. Sadly the DMA to file mmap is working good
enough that people started using it so at this point we cannot just tell:
Sorry it was a mistake to allow this, just rewrite your applications.

Plus we have O_DIRECT io which can use file mmap as a buffer and as Dave
Chinner mentioned there are real applications using this.

So no, we are not going to get away with "just forbid GUP for file backed
pages" which seems to be what you suggest. We might get away with that for
*some* GUP users and you are welcome to do that in the drivers you care
about but definitely not for all.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

