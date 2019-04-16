Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B6F1C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 19:15:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B1F1F2075B
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 19:14:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=plexistor-com.20150623.gappssmtp.com header.i=@plexistor-com.20150623.gappssmtp.com header.b="PbrYWf/1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1F1F2075B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=plexistor.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C0FC6B0003; Tue, 16 Apr 2019 15:14:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34A386B0006; Tue, 16 Apr 2019 15:14:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 215086B0007; Tue, 16 Apr 2019 15:14:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id C63926B0003
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 15:14:58 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id n11so244601wmh.2
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 12:14:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:references:cc:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding;
        bh=EhPHhkOro/MgnfsfeFqen1BmFFiSo+7BYZod+X0gN28=;
        b=CPBBqrxMMEpnPSntsUoPc09fLMZqkQzEx+Ok9Rot2fmhTse0t5w0aLlZg125mzeYWE
         jReBd6EcEUsbJKFYjFCctrnBAFfmGvfyU/wjtplLD5DkhNvLZ+nX+1DHd8wLpKuUp0Rh
         6eYokqIWoBpbscB1ArjcoE8U76t/PFMGY+AAQcjuu6YTvmqHt9G8f7W2xx3GZB9hPhU9
         Ni5T/BNtiJHFFl+sGKQSUushQi90pnCkubVBxCkUcvNkwETyOmq7sQxiC+Jp0SPS8W9e
         YIbycXv9cyW2scIRjrxgPcF+b4SKpbisz3AE++wJF+SDdDLGUbyrgBdyJn7Dup0+Es2J
         VD+Q==
X-Gm-Message-State: APjAAAWStymOku60twSQcDfevFiEHlDIf4eQQ59WsYDZ/CZiopQ+qiu5
	S6gZswrJ7vTy2iVACjJ5E61f6uh3rrIoSB/StDAG56ojvI3AuvdmKovLXASORZvpzl+AwJEdfw/
	h04vh+E4+1cAv9GCOf1k6z3nd9KBCSuvuEF9cnmx2bD1d98K5lc6FX/cJcpKuODnCPw==
X-Received: by 2002:a7b:c1cf:: with SMTP id a15mr26866193wmj.44.1555442098200;
        Tue, 16 Apr 2019 12:14:58 -0700 (PDT)
X-Received: by 2002:a7b:c1cf:: with SMTP id a15mr26866156wmj.44.1555442097432;
        Tue, 16 Apr 2019 12:14:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555442097; cv=none;
        d=google.com; s=arc-20160816;
        b=UZXxLiagCk/hTE8E7MN9ukM5uT9lQEn9I0NdnBxFlSNMyxTRmYOlpbNR4UYUvmuUS6
         LU/SyPNlKL2/naP2F53nKq+hJ29wRs5sdi8d8NwqArNFuFM8rrMhPKiCHAWe6uvnb0f4
         WaVBWq/prvJZmO9N4N8p2bIqjARwQNYVv8Begi0w+Dx8OxU7F4Jm+NgMnMmvOnnQi3j0
         lK+3hh3tdXViKag7b8zet7OT8vg1MQWOehLo7ndlhM6cJeItKMye+Q3pfhbTXuTa2PIb
         B9iVxDhGmQ/wN3B8Mip/gE8iLRug14j6LDp64DX3aqBsgbqxJcVPxF5u2Zy4zL/R6i4l
         8/wQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:from:cc:references:to:subject:dkim-signature;
        bh=EhPHhkOro/MgnfsfeFqen1BmFFiSo+7BYZod+X0gN28=;
        b=U1HQyJVW85wmN5LGtbs3M2uiOv3lp0D2wJN//gEgFVQFnpuVz2Vte7rSRCbHxX4nG8
         Fww9mNAOzFdCFEKfScb4cda91YoDZ+Xm3dhAROsTrd9V8kjmm7A1DkUsEGGiyqnGqGoe
         IbhREjeWLIlUJMAULI1a7IPyMbYBAIPUyVjvNefx4ed/ZXY5/RLUzONhefjq47gkb1l7
         BZEzSJCektFWljU2xYvhn4XdzwUV9RI5npQYJLLt8Tp1acFck+2yPIducYSqx86u732P
         5mTL9+MiKz8Css5nKIlu6TEo4OLwamjyjC67FWLYOitNQZ5XD4U1S3L21d+XE3UkVxlK
         W5Mg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@plexistor-com.20150623.gappssmtp.com header.s=20150623 header.b="PbrYWf/1";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of boaz@plexistor.com) smtp.mailfrom=boaz@plexistor.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z8sor37181406wrm.8.2019.04.16.12.14.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Apr 2019 12:14:57 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of boaz@plexistor.com) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@plexistor-com.20150623.gappssmtp.com header.s=20150623 header.b="PbrYWf/1";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of boaz@plexistor.com) smtp.mailfrom=boaz@plexistor.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=plexistor-com.20150623.gappssmtp.com; s=20150623;
        h=subject:to:references:cc:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding;
        bh=EhPHhkOro/MgnfsfeFqen1BmFFiSo+7BYZod+X0gN28=;
        b=PbrYWf/10co+jtOXbfJ6oYlTxA4h+VbvJds0jhbbhNcfAnyxt+JnHLHtQBk5LeZiEC
         mIh4TU4M0wZMyEwaD34dz3y/YRF6H0mrkGNksZXHBuyMFdEzgy0S+kLdTuhdXp3iyl2/
         GjrG3bd0BfzGCgL4SIDMEEDWdLFpqwlBKPrz7CSVK2AtBLmr7/yoS362nN5Y2teoDZ/e
         kvgbKYzbTEA7zrbY8kSfzR0b0wbQ/RZNsCWP2AAyHX1o2clpecr/ybKXyvRmz3TJD7Lm
         YWM+3dk8IQ43NWxpcwhYjhIdJRgmZUuKlwxy9TGFYn/7xlgRhOnGYmMi2caeg6xGUYkQ
         Ugdg==
X-Google-Smtp-Source: APXvYqx/f/+RL7rhmun3xwvyvpePyDYnXhg6X+l+qZsdnqyauV3sTcbHrpB16+OlBlwPuOY6emv+og==
X-Received: by 2002:adf:ec09:: with SMTP id x9mr18059wrn.187.1555442096995;
        Tue, 16 Apr 2019 12:14:56 -0700 (PDT)
Received: from [10.0.0.5] (bzq-84-110-213-170.static-ip.bezeqint.net. [84.110.213.170])
        by smtp.googlemail.com with ESMTPSA id i28sm144881380wrc.32.2019.04.16.12.14.53
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 12:14:56 -0700 (PDT)
Subject: Re: [PATCH v1 00/15] Keep track of GUPed pages in fs and block
To: Jerome Glisse <jglisse@redhat.com>, Boaz Harrosh <boaz@plexistor.com>
References: <20190411210834.4105-1-jglisse@redhat.com>
 <2c124cc4-b97e-ee28-2926-305bc6bc74bd@plexistor.com>
 <20190416184711.GB21526@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-block@vger.kernel.org, linux-mm@kvack.org,
 John Hubbard <jhubbard@nvidia.com>, Jan Kara <jack@suse.cz>,
 Dan Williams <dan.j.williams@intel.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Johannes Thumshirn <jthumshirn@suse.de>, Christoph Hellwig <hch@lst.de>,
 Jens Axboe <axboe@kernel.dk>, Ming Lei <ming.lei@redhat.com>,
 Jason Gunthorpe <jgg@ziepe.ca>, Matthew Wilcox <willy@infradead.org>,
 Steve French <sfrench@samba.org>, linux-cifs@vger.kernel.org,
 samba-technical@lists.samba.org, Yan Zheng <zyan@redhat.com>,
 Sage Weil <sage@redhat.com>, Ilya Dryomov <idryomov@gmail.com>,
 Alex Elder <elder@kernel.org>, ceph-devel@vger.kernel.org,
 Eric Van Hensbergen <ericvh@gmail.com>, Latchesar Ionkov <lucho@ionkov.net>,
 Mike Marshall <hubcap@omnibond.com>, Martin Brandenburg
 <martin@omnibond.com>, devel@lists.orangefs.org,
 Dominique Martinet <asmadeus@codewreck.org>,
 v9fs-developer@lists.sourceforge.net, Coly Li <colyli@suse.de>,
 Kent Overstreet <kent.overstreet@gmail.com>, linux-bcache@vger.kernel.org,
 =?UTF-8?Q?Ernesto_A._Fern=c3=a1ndez?= <ernesto.mnd.fernandez@gmail.com>
From: Boaz Harrosh <boaz@plexistor.com>
Message-ID: <65815835-bb20-5848-829e-659292cca1a2@plexistor.com>
Date: Tue, 16 Apr 2019 22:14:52 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:45.0) Gecko/20100101
 Thunderbird/45.4.0
MIME-Version: 1.0
In-Reply-To: <20190416184711.GB21526@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 16/04/19 21:47, Jerome Glisse wrote:
> On Tue, Apr 16, 2019 at 09:35:04PM +0300, Boaz Harrosh wrote:
>> On Thu, Apr 11, 2019 at 05:08:19PM -0400, jglisse@redhat.com wrote:
>>> From: Jérôme Glisse <jglisse@redhat.com>
>>>
<>
>> Why do we need a bv_pfn. Why not just use the lowest bit of the page-ptr
>> as a flag (pointer always aligned to 64 bytes in our case).
>>
>> So yes we need an inline helper for reference of the page but is it not clearer
>> that we assume a page* and not any kind of pfn ?
>> It will not be the first place using low bits of a pointer for flags.
> 
> Yes i can use the lower bit of struct page * pointer it should be safe on
> all architecture. I wanted to change the bv_page field name to make sure
> that we catch anyone doing any direct dereference. Do you prefer keeping a
> page pointer there ?
> 

Yes I would prefer that personally.
Changing the name (And type to ulong) is a good idea, let the compiler check us.
But lets make sure we all understand this is a page pointer. And not any kind
of pfn.

>>
>> That said. Why we need it at all? I mean why not have it as a bio flag. If it exist
>> at all that a user has a GUP and none-GUP pages to IO at the same request he/she
>> can just submit them as two separate BIOs (chained at the block layer).
>>
>> Many users just submit one page bios and let elevator merge them any way.
> 
> The issue is that bio_vec is use, on its own, outside of bios and for
> those use cases i need to track the GUP status within the bio_vec. Thus
> it is easier to use the same mechanisms for bio too as adding a flag to
> bio would mean that i also have to audit all code path that could merge
> bios. While i believe it should be restrictred to block/blk-merge.c it
> seems some block and some fs have spawn some custom bio manipulation
> (md comes to mind). 

I would imagine they use mechanics as bio-split and bio-clone so it need
only be handled there. but ...

> So using same mechanism for bio_vec and bio seems
> like a safer and easier course of action.
> 

OK I get it thanks. I would imagine the opposite but I have not audited all
call sighs, if you say there are fewer bvec call sites then it makes sense.

> Cheers,
> Jérôme
> 

Thanks
Boaz

