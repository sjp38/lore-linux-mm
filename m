Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4AABC282DA
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 09:20:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ACEA121473
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 09:20:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ACEA121473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 434146B0008; Tue,  9 Apr 2019 05:20:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3E3EB6B000C; Tue,  9 Apr 2019 05:20:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D4006B000D; Tue,  9 Apr 2019 05:20:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D65B96B0008
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 05:20:46 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f9so5536718edy.4
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 02:20:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=LWYtPi/oAp5kLr9CpcOmqDnw+cN50JJ0w+QimGsCwAQ=;
        b=TNY75FmB30Nd9WjF235b01m8bGzZbp7xypZapU7a1OvDYAEIhH5mUXc/LNCapHPZah
         m2rRAHqxeScGn9FGKGx01PWA5Z4kCT9SeaFWxAiUR9EEF29uVsQJLXDcILv9d/AKJDom
         Zsse88aCZriRCuMF4Ycl5kZa/lzdd9Bp/L/UgPAqwBy2b+xLSBZQxiw7rIqCteKBHXSb
         yZ+pFStxgxdsrqGvDr+0Q1wJgzrWNe3FjF7KMOHYghzjD33LRr10odI4pY4U+LkQwADm
         +0YeDajqSYKvJhsQa/mws2QiUPQ8KoqXFqUDHN3mkrpDW0/fz1162rVH0+laXA8mldM+
         Uypw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVktMXGbYoLgo052FWGEBf81nW5W3KnmowL2s2PnA272s3P+sAF
	F7vhbU4zSk0KD4rDNJgo6+GouKFqALDGQyD4c/RMPRsfapQyS7hZvsKIRTxUAzdtvTozCyy6IpX
	iIZh7VX0AoOLt0P+CqsK2X0rdKsHxRGSgZpsmK8Af2M3og+PMTnntZOBqdvXSLWs=
X-Received: by 2002:a17:906:7e47:: with SMTP id z7mr17819408ejr.248.1554801646352;
        Tue, 09 Apr 2019 02:20:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqypEU06dECraDq/6ffxjvf3X4B8+ackTiATrfLXgiFNKmHo37o/xiuHmRNy6+dUFgc1xu7H
X-Received: by 2002:a17:906:7e47:: with SMTP id z7mr17819373ejr.248.1554801645504;
        Tue, 09 Apr 2019 02:20:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554801645; cv=none;
        d=google.com; s=arc-20160816;
        b=YfJdk9wYFVU2vfxfMoYDiMiB2o3rd+8cZ41RUca9R52HfBeB4t3adh4MRlmHcGUEL3
         ifH1REUPeAdApwQNtI/VE3+7Lc19EkoKyDfcGkkcUi1cfwaXiEUfIPFJDqPVmrs/uiVX
         uIEbjJvUUs4Nm5nHO+EMzu3cxGlvHGs/3n2l+cILryraidAZrDjUDk4D/iUQGvp1y2t1
         d/JAFAINDqTp6x9JrjFl21OpX7m1MKA1WlA5vz+QSLMIWtAiqSkhZY+mSQFz885TxfLl
         Ve6lLVOJBKcZ4hU54TdbvQ/rD+gunFGCJLUV/aWUMhAiDuFsaXYpuFEIzOc+A/WFTQuC
         hc8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=LWYtPi/oAp5kLr9CpcOmqDnw+cN50JJ0w+QimGsCwAQ=;
        b=QYc19TJ1S0ip2vpenZPnLsMsm7MTRBRYf3eKcM9//W1SgM/HQBd4SYmcuCr5yEYD/b
         lp/vCu9SUgF+0LYyW6URWOsbnz6USypqMks7kJ53SQN3ELW4WQnQQcDB+ZGN2Y1Czy6v
         /oVpm1VC50ceMksfhrOfRlHumyPVMY90Nb4Tyl+CIZcfDB8up844XRE9jGE5UgbpIlyX
         N4iG+j8sq6rk2yEFCqiAYrVsmmX9bgxbjCu7SX9zL4JkGdLPQDWzrFMUedEYPIbWRW8q
         64OPiEldf7BJ1btvm0A/bbOFcF+LaHTSCEghiFI9YEpBgNeRgkaQoeVLaaOXsklyL2bm
         UvIA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b10si294651eds.235.2019.04.09.02.20.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 02:20:45 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8F75FAEDF;
	Tue,  9 Apr 2019 09:20:44 +0000 (UTC)
Date: Tue, 9 Apr 2019 11:20:42 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Christoph Hellwig <hch@lst.de>, Christopher Lameter <cl@linux.com>,
	linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Ming Lei <ming.lei@redhat.com>, Dave Chinner <david@fromorbit.com>,
	Matthew Wilcox <willy@infradead.org>,
	"Darrick J . Wong" <darrick.wong@oracle.com>,
	linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org,
	lsf-pc@lists.linux-foundation.org
Subject: Re: [RFC 0/2] guarantee natural alignment for kmalloc()
Message-ID: <20190409092042.GB10383@dhcp22.suse.cz>
References: <20190319211108.15495-1-vbabka@suse.cz>
 <01000169988d4e34-b4178f68-c390-472b-b62f-a57a4f459a76-000000@email.amazonses.com>
 <5d7fee9c-1a80-6ac9-ac1d-b1ce05ed27a8@suse.cz>
 <010001699c5563f8-36c6909f-ed43-4839-82da-b5f9f21594b8-000000@email.amazonses.com>
 <4d2a55dc-b29f-1309-0a8e-83b057e186e6@suse.cz>
 <01000169a68852ed-d621a35c-af0c-4759-a8a3-e97e7dfc17a5-000000@email.amazonses.com>
 <2b129aec-f9a5-7ab8-ca4a-0a325621d111@suse.cz>
 <20190407080020.GA9949@lst.de>
 <af1e0b95-f654-4fa9-d400-af01043907ab@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <af1e0b95-f654-4fa9-d400-af01043907ab@suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 09-04-19 10:07:42, Vlastimil Babka wrote:
> On 4/7/19 10:00 AM, Christoph Hellwig wrote:
> > On Fri, Apr 05, 2019 at 07:11:17PM +0200, Vlastimil Babka wrote:
> >> On 3/22/19 6:52 PM, Christopher Lameter wrote:
> >> > On Thu, 21 Mar 2019, Vlastimil Babka wrote:
> >> > 
> >> >> That however doesn't work well for the xfs/IO case where block sizes are
> >> >> not known in advance:
> >> >>
> >> >> https://lore.kernel.org/linux-fsdevel/20190225040904.5557-1-ming.lei@redhat.com/T/#ec3a292c358d05a6b29cc4a9ce3ae6b2faf31a23f
> >> > 
> >> > I thought we agreed to use custom slab caches for that?
> >> 
> >> Hm maybe I missed something but my impression was that xfs/IO folks would have
> >> to create lots of them for various sizes not known in advance, and that it
> >> wasn't practical and would welcome if kmalloc just guaranteed the alignment.
> >> But so far they haven't chimed in here in this thread, so I guess I'm wrong.
> > 
> > Yes, in XFS we might have quite a few.  Never mind all the other
> > block level consumers that might have similar reasonable expectations
> > but haven't triggered the problematic drivers yet.
> 
> What about a LSF session/BoF to sort this out, then? Would need to have people
> from all three MM+FS+IO groups, I suppose.

Sounds like a good plan. Care to send an email to lsf-pc mailing list so
that it doesn't fall through cracks please?

-- 
Michal Hocko
SUSE Labs

