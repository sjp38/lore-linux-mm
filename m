Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38E63C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 19:28:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DD9E6206B6
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 19:28:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=plexistor-com.20150623.gappssmtp.com header.i=@plexistor-com.20150623.gappssmtp.com header.b="fc+bCfx3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DD9E6206B6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=plexistor.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 69E006B0003; Tue, 16 Apr 2019 15:28:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 67F436B0006; Tue, 16 Apr 2019 15:28:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 58B156B0007; Tue, 16 Apr 2019 15:28:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0AD6D6B0003
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 15:28:46 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id 7so240097wmj.9
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 12:28:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:references:cc:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding;
        bh=TK0tNNQsPXC2rP0n4i852ZF/PbXASmAnqjad3jaHiRA=;
        b=UWJq2WaYC152FAHHIx06TNWsAVzCp1vT8JicgPv/znjPDBJXcztVs33Drop36FaOTP
         ro0I4GYchPZhA3x2tFH8i5QJDqlTBlfFDh9mzDhpjx5ZWAgjgZcq2cuU7FpIWITW9SSl
         Vv+cq/7dWmHD0TI0mO9Cz5RIlzqwGANpebGByZ8sx+qJgfT8Y32HaqMsPWiDQy2kk3aQ
         TNzVgDGUnZaIJ8tuVDgI4z2vznoVOcKr5tcJJrGNB+4izranllIU5+YtAPIIg02Hj7M0
         6uhe6pWALutQYUFu0v7o5encadFGWEgwqtKJvaIm+MTa6AAGcUzwCvxsWzzm62uMRZR0
         QSLw==
X-Gm-Message-State: APjAAAXxWyykl8gkBzoZDfEN6Q9fSQmeCtEyzszTlpl2dFfsJvEhHv7q
	miu4m8PMDjlWAVgv3qreecPPyi81/RH6X/9IKegyFIpkmsdGv9+r8y1KImH+LcgNS9evt9i0+Zr
	bUoKj+ewchkuN5nn/sj7dcPQOdxhqc0+P/qhk2IXyVCRSFJv83EuFLIkjv4jt4GYEqQ==
X-Received: by 2002:a1c:4602:: with SMTP id t2mr29422055wma.120.1555442925579;
        Tue, 16 Apr 2019 12:28:45 -0700 (PDT)
X-Received: by 2002:a1c:4602:: with SMTP id t2mr29422015wma.120.1555442924857;
        Tue, 16 Apr 2019 12:28:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555442924; cv=none;
        d=google.com; s=arc-20160816;
        b=tputf2oEvqKrpm6uqmXy6gR7H9k1LATYEi5biXZx9AzpN7qXMjSn48VFa1x4YCAYpK
         E91ygR4tI2rQXh3woz8lwAvhTdkY8L9iVICPlAl+r7J4dggSaIYDWfWp5HMGHySh2ZDw
         6enK/aJiW7U9NtBi9SRsc0mNqfYznUewPew3RwqC3cVNSf+qUKXrViZPR/LPcNgKH8XV
         H3jv1wBbTjpbMWPlt3XmypVrXry4turBo3rPikygan4IrJcUYeP3d6eqbf6Rk+y10acp
         8DPNWCQWcxXZvIciOK94/iMY/cWiZ9tIGXz1fjLKPl3/qfHMjK3cnLFAGstY40ibSomJ
         Kzmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:from:cc:references:to:subject:dkim-signature;
        bh=TK0tNNQsPXC2rP0n4i852ZF/PbXASmAnqjad3jaHiRA=;
        b=isTIQnSNuLetXy9Gs8RLpAAgCvd834piw1VUhguW2z844+9enIJZuvvgM95CijaRyL
         Xeq8CV/iCMaLTEeNQSgFC7K4dcJ6OweyP+Lqs2u9Fcm7AWD2MRoRGWiAJhAbq8ceAqDa
         P1oqtg6J64YmSOh2cAoENM5tkP1gEM/nfyV55v1/YhwQG/HPXGBU5t8piKBLerHVi8zb
         z+GjbIDMUqGFfTWbAqWDwF8h7XpR10rbm3P8qWDMaRTojNphtHBU/P5/9JAi29s/ycRa
         YZjzkmnh9c5Rr/A5QhsYFa3aWzbFG+qbXEPuAg5jRVX0lxKobpGGb1yIJl4gFUzBfpqp
         xE8w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@plexistor-com.20150623.gappssmtp.com header.s=20150623 header.b=fc+bCfx3;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of boaz@plexistor.com) smtp.mailfrom=boaz@plexistor.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b4sor37447068wrt.16.2019.04.16.12.28.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Apr 2019 12:28:44 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of boaz@plexistor.com) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@plexistor-com.20150623.gappssmtp.com header.s=20150623 header.b=fc+bCfx3;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of boaz@plexistor.com) smtp.mailfrom=boaz@plexistor.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=plexistor-com.20150623.gappssmtp.com; s=20150623;
        h=subject:to:references:cc:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding;
        bh=TK0tNNQsPXC2rP0n4i852ZF/PbXASmAnqjad3jaHiRA=;
        b=fc+bCfx3WHpqwjPk/QUAHmhBbP17mvJ8cg3f6uOZYuUMnpHOiPGD7Gw1Lzqf/9Nzpu
         8XYVQXEK9qHBh+cuWifmwX2mpgX2zvs/LJT4wlnO+R0bGUqFJrFT/abQl2osdYOTiD5Z
         +X0AKX7Mj1LvVxHAq6+eqlRQIepZrA9Vp0vlHw0exiR7ePIwSrlNE2iBI4LFbEl1Pq1y
         X1AqbNgPGgKOx0VVrLmAS5UBuUpBZPSH6LFWVnLBkjeGk804KCwQ/yESj9g8cW1IAaJl
         eLQXu0oi/5s+y9xl34TvkCNsifrdBrhyZpe+OpncOuV9VUGpn+3ap2eYEtCtkgsr5i6a
         R2YQ==
X-Google-Smtp-Source: APXvYqxZ+hb6o3Fqbpe0NkIQFQExFmffv8jB/fQNUtwEn37w5HEvHoCv1lNfqe/2TtODSW2anznicA==
X-Received: by 2002:adf:f088:: with SMTP id n8mr55276227wro.112.1555442924580;
        Tue, 16 Apr 2019 12:28:44 -0700 (PDT)
Received: from [10.0.0.5] (bzq-84-110-213-170.static-ip.bezeqint.net. [84.110.213.170])
        by smtp.googlemail.com with ESMTPSA id k9sm78041147wru.55.2019.04.16.12.28.41
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 12:28:44 -0700 (PDT)
Subject: Re: [PATCH v1 00/15] Keep track of GUPed pages in fs and block
To: Dan Williams <dan.j.williams@intel.com>,
 Kent Overstreet <kent.overstreet@gmail.com>
References: <20190411210834.4105-1-jglisse@redhat.com>
 <2c124cc4-b97e-ee28-2926-305bc6bc74bd@plexistor.com>
 <20190416185922.GA12818@kmo-pixel>
 <CAPcyv4jLrQ6evLAJzsASh=H6Tzx8E1oiF+YR3L2fOpbZYNUWGg@mail.gmail.com>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-block@vger.kernel.org,
 Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>,
 Jan Kara <jack@suse.cz>, Alexander Viro <viro@zeniv.linux.org.uk>,
 Johannes Thumshirn <jthumshirn@suse.de>, Christoph Hellwig <hch@lst.de>,
 Jens Axboe <axboe@kernel.dk>, Ming Lei <ming.lei@redhat.com>,
 Jason Gunthorpe <jgg@ziepe.ca>, Matthew Wilcox <willy@infradead.org>,
 Steve French <sfrench@samba.org>, linux-cifs@vger.kernel.org,
 Yan Zheng <zyan@redhat.com>, Sage Weil <sage@redhat.com>,
 Ilya Dryomov <idryomov@gmail.com>, Alex Elder <elder@kernel.org>,
 ceph-devel@vger.kernel.org, Eric Van Hensbergen <ericvh@gmail.com>,
 Latchesar Ionkov <lucho@ionkov.net>, Mike Marshall <hubcap@omnibond.com>,
 Martin Brandenburg <martin@omnibond.com>, devel@lists.orangefs.org,
 Dominique Martinet <asmadeus@codewreck.org>,
 v9fs-developer@lists.sourceforge.net, Coly Li <colyli@suse.de>,
 linux-bcache@vger.kernel.org,
 =?UTF-8?Q?Ernesto_A._Fern=c3=a1ndez?= <ernesto.mnd.fernandez@gmail.com>
From: Boaz Harrosh <boaz@plexistor.com>
Message-ID: <ccac6c5a-7120-0455-88de-ca321b01e825@plexistor.com>
Date: Tue, 16 Apr 2019 22:28:40 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:45.0) Gecko/20100101
 Thunderbird/45.4.0
MIME-Version: 1.0
In-Reply-To: <CAPcyv4jLrQ6evLAJzsASh=H6Tzx8E1oiF+YR3L2fOpbZYNUWGg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 16/04/19 22:12, Dan Williams wrote:
> On Tue, Apr 16, 2019 at 11:59 AM Kent Overstreet
> <kent.overstreet@gmail.com> wrote:
<>
> This all reminds of the failed attempt to teach the block layer to
> operate without pages:
> 
> https://lore.kernel.org/lkml/20150316201640.33102.33761.stgit@dwillia2-desk3.amr.corp.intel.com/
> 

Exactly why I want to make sure it is just a [pointer | flag] and not any kind of pfn
type. Let us please not go there again?

>>
>> Question though - why do we need a flag for whether a page is a GUP page or not?
>> Couldn't the needed information just be determined by what range the pfn is not
>> (i.e. whether or not it has a struct page associated with it)?
> 
> That amounts to a pfn_valid() check which is a bit heavier than if we
> can store a flag in the bv_pfn entry directly.
> 
> I'd say create a new PFN_* flag, and make bv_pfn a 'pfn_t' rather than
> an 'unsigned long'.
> 

No, please please not. This is not a pfn and not a pfn_t. It is a page-ptr
and a flag that says where/how to put_page it. IE I did a GUP on this page
please do a PUP on this page instead of regular put_page. So no where do I mean
pfn or pfn_t in this code. Then why?

> That said, I'm still in favor of Jan's proposal to just make the
> bv_page semantics uniform. Otherwise we're complicating this core
> infrastructure for some yet to be implemented GPU memory management
> capabilities with yet to be determined value. Circle back when that
> value is clear, but in the meantime fix the GUP bug.
> 

I agree there are simpler ways to solve the bugs at hand then
to system wide separate get_user_page from get_page and force all put_user
callers to remember what to do. Is there some Document explaining the
all design of where this is going?

Thanks
Boaz

