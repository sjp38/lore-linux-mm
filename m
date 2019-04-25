Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3086C282E1
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 12:03:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 90DFA2084B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 12:03:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 90DFA2084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 002BF6B0010; Thu, 25 Apr 2019 08:03:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF2DD6B0266; Thu, 25 Apr 2019 08:03:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E08DA6B0269; Thu, 25 Apr 2019 08:03:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8F1C16B0010
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 08:03:26 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id 18so149748eds.5
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 05:03:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=RGAVzvZSkV8LPLPRKkdPt/OtQ1NbJz40SrbDp5kvUzA=;
        b=B1L+4ZMdEPDdMoiBU+6wxjGem//7m1HgZ8XsFRVwQCjyzMf0CoIDcno0CyYnANNcu1
         UUbr68SUpZdxTH2X5CsuaiKvVnwcdpqMb5sopJhsEjYXmLWIuHoZqaC3ruvx3nYxmLPG
         /tAdtYXNfAHFehSB6QQbPxBwWWRf85hYpD8Ua9/xtwFbR5yujqJ1KndklqGFQQ1wbgYY
         wSLs1mOux/FKxrODXX+OlkZgquhTBU+5bqQb+6a8PK6ET0NmfUNhbWRYq3CS7GUaLCDM
         9T/6eKwfDHDLdXvU7UKKp1KOAbh8MlrKff/LWFK4YH2ebP7+QdnXD4M44aIAXdrgv+z6
         8krw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXxlhY4a2Q63/r15+Z5EIGUL3NteFzhgcDV+02TJXWOqnj5W1yv
	tXvyl2CH++PemnVxmwz+Fw4KIR4f/FDk2A8T4m4zRVq1Mpt+HvgRgoQ0Ire28BYtnNQQYm4nCtm
	jB5BUbRcY5A65JNJlrvzOj41nUH5wareknoXJ8lS4VM3md//l5ZIUqVldoBqX3Hc=
X-Received: by 2002:a17:906:bc1:: with SMTP id y1mr15940967ejg.110.1556193806026;
        Thu, 25 Apr 2019 05:03:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzlYreFpClTYz60uAg4VWp914F8MPKkjJ1tkcuh+z+Z3C6JTn42O8A3G3GQVW0Jrbr+3XE9
X-Received: by 2002:a17:906:bc1:: with SMTP id y1mr15940924ejg.110.1556193805026;
        Thu, 25 Apr 2019 05:03:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556193805; cv=none;
        d=google.com; s=arc-20160816;
        b=byqcwbkQD/699zbObivMfgBKaeHAtNT9Y/Jy9ipiZOa9Kj56yhJWJK1Nq5kizqH3hu
         4WIX4EWeZBPpJC0+liBCtg2izponE3TflUZAWZOOLw+AXIRcaL993+bm9cOQD8X5rAvx
         hKMBvTRDwLVXkQk3suy57WxR2eOk25zRYPlcmjxg39CAgxwlm2Ri9/enYB3DzC7YSjLg
         5S7moNjAc99rcd1pcb1CNbrmYNa/yUKsOhgri4TjT5McxWQWtyUYvr3b+XcwpGZG9wA3
         GC5YoWlW2gzUKpnU/3udiouWibjaZoJZlD57TgiqEKvVdB4hCEUgNz5iDgO9/AZdNzrN
         o+jg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=RGAVzvZSkV8LPLPRKkdPt/OtQ1NbJz40SrbDp5kvUzA=;
        b=RXCyQQtYVb5rKqp79uNXlWid9uOwRUAQ4gfbUK1yT6+XcCOpjD9fl8PkKdN+xLOQFT
         pHLArVCueWHqZS5Xz9eNazNq9+QsltUEah0J/9vailQULvc+dsBMr/2FBNwaXp48IQqB
         xkqo3SUcSsU9r9H8l6pJGykiCsUVLOFRSPdc133zCxZb4EJua14DpjGiRlzzBmua24oU
         3B/Yhl6foQ77Q6YcL7idjgz6wSfP/kTPxVnvzrveJBVjTh/zgMNWZzTMFhludi6+ixyQ
         By4Dgr172gYKsLj4sM3Tu4FCSvR+0Xe9g8FmKksPlyMGrJJQs2BoGkKBSuco9pJabEKp
         C6yQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i31si823889ede.429.2019.04.25.05.03.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 05:03:25 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 43961AD45;
	Thu, 25 Apr 2019 12:03:24 +0000 (UTC)
Date: Thu, 25 Apr 2019 14:03:22 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, lsf-pc@lists.linux-foundation.org,
	Linux-FSDevel <linux-fsdevel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>, linux-block@vger.kernel.org,
	Christoph Lameter <cl@linux.com>,
	David Rientjes <rientjes@google.com>,
	Pekka Enberg <penberg@kernel.org>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Ming Lei <ming.lei@redhat.com>, linux-xfs@vger.kernel.org,
	Christoph Hellwig <hch@infradead.org>,
	Dave Chinner <david@fromorbit.com>,
	"Darrick J . Wong" <darrick.wong@oracle.com>
Subject: Re: [LSF/MM TOPIC] guarantee natural alignment for kmalloc()?
Message-ID: <20190425120322.GW12751@dhcp22.suse.cz>
References: <790b68b7-3689-0ff6-08ae-936728bc6458@suse.cz>
 <20190411132819.GB22763@bombadil.infradead.org>
 <20190425113358.GI19031@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190425113358.GI19031@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 25-04-19 04:33:59, Matthew Wilcox wrote:
> On Thu, Apr 11, 2019 at 06:28:19AM -0700, Matthew Wilcox wrote:
> > On Thu, Apr 11, 2019 at 02:52:08PM +0200, Vlastimil Babka wrote:
> > > In the session I hope to resolve the question whether this is indeed the
> > > right thing to do for all kmalloc() users, without an explicit alignment
> > > requests, and if it's worth the potentially worse
> > > performance/fragmentation it would impose on a hypothetical new slab
> > > implementation for which it wouldn't be optimal to split power-of-two
> > > sized pages into power-of-two-sized objects (or whether there are any
> > > other downsides).
> > 
> > I think this is exactly the kind of discussion that LSFMM is for!  It's
> > really a whole-system question; is Linux better-off having the flexibility
> > for allocators to return non-power-of-two aligned memory, or allowing
> > consumers of the kmalloc API to assume that "sufficiently large" memory
> > is naturally aligned.
> 
> This has been scheduled for only the MM track.  I think at least the
> filesystem people should be involved in this discussion since it's for
> their benefit.

Agreed. I have marked it as a MM/IO/FS track, we just haven't added it
to the schedule that way. I still plan to go over all topics again and
consolidate the current (very preliminary) schedule. Thanks for catching
this up.

> Do we have an lsf-discuss mailing list this year?  Might be good to
> coordinate arrivals / departures for taxi sharing purposes.

Yes, the list should be established AFAIK and same address as last
years.

-- 
Michal Hocko
SUSE Labs

