Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05A8BC10F06
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 12:57:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 965F020854
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 12:57:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="KtuqdYkv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 965F020854
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA0E18E0003; Thu, 14 Mar 2019 08:57:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E28808E0001; Thu, 14 Mar 2019 08:57:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CCAD08E0003; Thu, 14 Mar 2019 08:57:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id A49CA8E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 08:57:22 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id o135so4571420qke.11
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 05:57:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=bX/rd3bmqqBCTFhzbUqNph1QeoI3wmJKqgdu6nyWf0w=;
        b=ihHvL3Q0AJQfHAJhdrcdZ9xHAf+l1diHjWZJv5uR601fQzK0C3PCqcUiDHO7CkVhyO
         eZjeGa4i8OpqELXnNMj9Xqd3XGUh3eVkj0Hu1NDyBZJ3UN2T2go9o1gwm3+gGRmj5Uvw
         J4QW5nsT7YCbdZh/Ws9nwePMv5jYeHCvVS6mG4WiGiZ+lyniD3AqVzj1sR5kN4zhrIU3
         MtGAyj7xoWWySxVCNMiby4509dZC18Ti2bc0o9lNprmu/3yrnd3q6jWC5wHeNpiktOXK
         U4VocsNuYFqRdPdobyXv8gd8Em6zlBO3FUjx38ZKm2Fa4hjhHfNEtSbnVFGeve78aKMn
         cvRQ==
X-Gm-Message-State: APjAAAXDXztq9Ya4o9Yiico8BoEEChLx9rI2yU2pHM3i6849RRsBwyJm
	VXCmi92+lLokrrs2mUikXqb9bRCAgaOGr3uGv/T9XMEKb8o5XSp8CsKVbt6NBrC6uPo9zAdxmOS
	noo1rCff4Hrv8lBBLglbF7cV274W6QELCyE2kp5nZHHtT40uZ7YqwaKR+no/T+bUMV98vszK2MX
	pZaXQWC0k2x7w1zxDzNF1uGCSG4ukgABWXJAcDzXBwd8QSTa0tkLdhrwRJQ+xrCi6C6WpAVN7M8
	t0YSUyZpmBP6WRZEl4kuKCK5ngGg/x7qWF+kuhnGZcRC6AeVZ89DnbX38p7uMqOs9zhzGh8ltVR
	yz/ZIUN5F/TR3HnZqvRjDM4qsRzAStfpiSC53ZYV+79l29kP97Mx60Tz0MMe70FVA4KkfEqGBCA
	q
X-Received: by 2002:a37:c99c:: with SMTP id m28mr16426101qkl.3.1552568242339;
        Thu, 14 Mar 2019 05:57:22 -0700 (PDT)
X-Received: by 2002:a37:c99c:: with SMTP id m28mr16426053qkl.3.1552568241581;
        Thu, 14 Mar 2019 05:57:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552568241; cv=none;
        d=google.com; s=arc-20160816;
        b=jIWPpckwPcFLJbYvdcYcqhgHKauruVqHavieDo8vrTy6SUYJKZa+hLr2CRRWvs/ycd
         D3L2df0mA+b3e3JkwHZTK2bs498lRl+x6X4XMGbLh7FTyiIo9BtjbC5ObjQ/uHtebwfb
         dh+M7IL+6RslrTwpsPRX20fJ/K2jtiQj84e+xihrTdscY4DyE2l0KIJNN18x3xlcv2KD
         /ojQTToFs6Y52yxQg7wV8WM6B7j+zxVWR2yx9rIj0iOfS3vrCig2QM5fYVesP/kKUjLg
         HTj+u7dvtxErLIfsTB+Q6S5raVB5aVu0i+yy2YhGtCL5uc25xKQ6aUpnp+NdbFFc0sJ0
         386w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=bX/rd3bmqqBCTFhzbUqNph1QeoI3wmJKqgdu6nyWf0w=;
        b=v4WaoCUOHg+mLSSBoAsNhBfTDflV4o49p31HfdshHd9zyh8VLXMY+DAqB2ocFP3jmj
         rWPd0o8/x5p0CIXuR3az4B9MPu6xZlTwqFFLqueIGWDtGLuGipX0KwV+VYB4WgDdD780
         xx3ZFyDMB2vrLRynCs1UG+Exvb0prkjlDzZ3cw9ycaRnduJ7h6m03bN58lj0EDm24ouv
         1Apn01x5wmi2wvasjSMFXadXhACiCvJO0TRiOAUDj2ufcm2HuHfGovNYCpMpj+y9Jv7h
         e+SsBqD23vOEq7VjHbI3HV+npl7Fd7vKRsP/y2RNJZd+CBLzwNoG+5qk0jp9MDK6M2SN
         m/Iw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=KtuqdYkv;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g20sor15795623qtr.72.2019.03.14.05.57.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Mar 2019 05:57:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=KtuqdYkv;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=bX/rd3bmqqBCTFhzbUqNph1QeoI3wmJKqgdu6nyWf0w=;
        b=KtuqdYkv5zyaq6xbbGZTBGQxAmKAEAyqM639VsOxYdzF6+qFgXAeCSsJ3lsWNdwBKa
         Dlb/U3NBUn5PVjvmmOuA41fVskx9ykiRUHXzXhldeQkhA2U0UR2M2Pi39UIIbJouLHBx
         dbrmPwgrTISjAqzk03zyrwSm3D9kAf0Kv92fVum/v9jerCBbbOoqlhrENhOvWoYGxg+A
         jsoTmfUgPkx0kEb1NfTJteG0904Bc6SCzF7gT4BYs4gImC6XMpq9AIDsZzhhey2L64Vo
         VSJ+wZnnALkE7SNdc0nuf/9i2YgPi2lWMZ+kCq2O3VdX9lFgJYf92zkS/VYCAIcMuNVB
         pi1g==
X-Google-Smtp-Source: APXvYqytd9p0uuBZA+SHiOfiS+QNDImQNuNaDK+xWX3URuepKNRKJc6m8GyKCufcLMESAHwzO4Z/Zw==
X-Received: by 2002:aed:3608:: with SMTP id e8mr39101742qtb.31.1552568241012;
        Thu, 14 Mar 2019 05:57:21 -0700 (PDT)
Received: from ziepe.ca ([24.137.65.181])
        by smtp.gmail.com with ESMTPSA id 59sm6692195qtg.26.2019.03.14.05.57.20
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 14 Mar 2019 05:57:20 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1h4PvC-0003Fv-Vi; Thu, 14 Mar 2019 09:57:18 -0300
Date: Thu, 14 Mar 2019 09:57:18 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jan Kara <jack@suse.cz>
Cc: Christopher Lameter <cl@linux.com>, Jerome Glisse <jglisse@redhat.com>,
	john.hubbard@gmail.com, Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org, Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>, Ira Weiny <ira.weiny@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH v3 0/1] mm: introduce put_user_page*(), placeholder
 versions
Message-ID: <20190314125718.GO20037@ziepe.ca>
References: <20190306235455.26348-1-jhubbard@nvidia.com>
 <010001695b4631cd-f4b8fcbf-a760-4267-afce-fb7969e3ff87-000000@email.amazonses.com>
 <20190308190704.GC5618@redhat.com>
 <01000169703e5495-2815ba73-34e8-45d5-b970-45784f653a34-000000@email.amazonses.com>
 <20190312153528.GB3233@redhat.com>
 <01000169787c61d0-cbc5486e-960a-492f-9ac9-9f6a466efeed-000000@email.amazonses.com>
 <20190314090345.GB16658@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190314090345.GB16658@quack2.suse.cz>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 14, 2019 at 10:03:45AM +0100, Jan Kara wrote:
> On Wed 13-03-19 19:16:51, Christopher Lameter wrote:
> > On Tue, 12 Mar 2019, Jerome Glisse wrote:
> > 
> > > > > This has been discuss extensively already. GUP usage is now widespread in
> > > > > multiple drivers, removing that would regress userspace ie break existing
> > > > > application. We all know what the rules for that is.
> > 
> > You are still misstating the issue. In RDMA land GUP is widely used for
> > anonyous memory and memory based filesystems. *Not* for real filesystems.
> 
> Maybe in your RDMA land. But there are apparently other users which do use
> mmap of a file on normal filesystem (e.g. ext4) as a buffer for DMA
> (Infiniband does not prohibit this if nothing else, video capture devices
> also use very similar pattern of gup-ing pages and using them as video
> buffers). And these users are reporting occasional kernel crashes. That's
> how this whole effort started. Sadly the DMA to file mmap is working good
> enough that people started using it so at this point we cannot just tell:
> Sorry it was a mistake to allow this, just rewrite your applications.

This is where we are in RDMA too.. People are trying it and the ones
that do enough load testing find their kernel OOPs

So it is not clear at all if this has graduated to a real use, or just
an experiment. Perhaps there are some system configurations that don't
trigger crashes..

Jason

