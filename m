Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E51EC282DD
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 15:05:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C24E6205F4
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 15:05:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="ti8W5H7D"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C24E6205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3281E6B0005; Wed, 17 Apr 2019 11:05:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D9026B0006; Wed, 17 Apr 2019 11:05:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A19E6B0007; Wed, 17 Apr 2019 11:05:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id EE96D6B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 11:05:55 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id k2so7508876ybp.17
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 08:05:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=LVyq6OE19KhM+/xQW2Gwk2ofoXjKkpXeXhoSwbk5MqA=;
        b=o6jGc8scm1BTe8ElKdjvxcVK4SsqvcJ4dmxmWIK2VIehYBRjvzcRdLPbkrKD9rQaxb
         iM9UK9QkBTAxey/htSAvsum2kIFugH760wgl1QUhDEiWyHq55302lcn4RBVuOoj2h7r1
         rpz6LbWyd+tRskWi7SnECLwOs3d6oJUHtc7ufrXn5gCZShj+CQ5KqZ5xlWsGhL59vYHd
         sLNhebZDtZxDd+LeRChFKcXCb5IiAuESBtl7CbcjAaSIGSq/5TfApqCEtWSONpmj/fxn
         e8W9qqCF5HuGELlCH0c7bbdX6LS6yoL7Fh7APOPRvML94W1gl8qiXzxiYJapYyjpRf8T
         gbww==
X-Gm-Message-State: APjAAAVQcx5LVXfbMOJ3O4iLE4qB2PmE8NezKC8TyJfpKZxbiBmRChJE
	ngCjJaWfbGGKdGI/84Zi4W3ubx1e56WdRTq8JyxJsLx6J0NFKPmtx9YjcbkC/pzm893J1XfJgF0
	TwbRCTrrcsvhJe+5EpCI12agRoVXoIpigOhPkeLt/xDMbxH7naR/0ZDfA0Iw6ilHIzw==
X-Received: by 2002:a5b:34f:: with SMTP id q15mr22976708ybp.188.1555513555705;
        Wed, 17 Apr 2019 08:05:55 -0700 (PDT)
X-Received: by 2002:a5b:34f:: with SMTP id q15mr22976629ybp.188.1555513554943;
        Wed, 17 Apr 2019 08:05:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555513554; cv=none;
        d=google.com; s=arc-20160816;
        b=ppYeZO7V37TbA9vf3gOx01bkm6Q7v2mQAAx5M4bSD8c/oqtEGZ6AZxnohDJWWpgbAB
         ogMtShoOB0T7BWGvN3Dcdz25lSmL9DQYv6AJUcb6bePVL8kO1h+wDjE4ob+DQyuejhCk
         nuGE0zKiAN3mepUx6Kg5SvYPR2UKrXUMk7gVQ3iAai4SjQnUiUAidpm7qV49arsnY+Pg
         jy7jSFV7tPguBTezCgFCN2iDp8Trs8y29dxlZpkyRV9kidio/WENIdIklZuObjfvtYPh
         V6ZfsFUBnSRMym0g8OzhD/pZkZIS66OsTd7WolSHUb+5LpzBwDFfUKN3d5HtNuqg6h/t
         b/EQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=LVyq6OE19KhM+/xQW2Gwk2ofoXjKkpXeXhoSwbk5MqA=;
        b=kwqqwQyoFkgjdhh22NK9cZ8NgcOvGrcSJl8IOyIR3liOK5FMgrbhGwz671I4RBO1/6
         BJgHkKIb582pyacqWKSHb0IpWx/CRsJ3933Zf8BV4CY7sXiOF8o8anEROo328+aqKvIU
         WkSrIkTmzToP0PeRC8oSquzgj8hjgrvyssShYC8ZNBJCD2/RE3udnBvBqSdT1I1MXfG7
         osoCO25p/udwUX6pFrIVfIbqHfS38R9rZtXi3UthzGlK2XQAYvh7Mq3F4EgmTws6rlcS
         bN62aL7RCWrdWhObxI0PZL6H1rCdz4DP+SFuUZ2RrIObVPAOeKRm4ai+9mFP4vJo1SBz
         TixQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=ti8W5H7D;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g124sor26045165ybb.2.2019.04.17.08.05.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 08:05:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=ti8W5H7D;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=LVyq6OE19KhM+/xQW2Gwk2ofoXjKkpXeXhoSwbk5MqA=;
        b=ti8W5H7DMOt1m37y3NdNUhonSIHrqY9ax3MP/DwOqIirdqCPaWRNh3hzf6+dTUS8RN
         6uZ0DRf96ReenpoZExR+2F0t80NQhBLa+i4fSzUdLTUmi+YYSIG5HE0JPpHiFWI9yjAx
         dx9TB/Rb3ISoeOU8AjSFUcKZ7wOwz1Ai+/XYIB097IKpJwt0STBD5PAZ6w3nenElwrfu
         e78xTZYXG5QOFAqCEjvr7e33HmMwdYRqwXfBDCE/QyiUXNzmOnL0Ew7MKuQNUW7qORBn
         wxzISXJV/u9CeTwdsQuTBoL3Mo7RnE9pazUVenDU4BtNNeig9S2lz3y48EAddNRibCbh
         P+cQ==
X-Google-Smtp-Source: APXvYqwnaSGgY+8GXvGpEGOeVdfnmrv02humxUlwDvsTeBJqmXiK044S4LlaabEwB+SWiMHu5SYP8Q==
X-Received: by 2002:a25:2d55:: with SMTP id s21mr71611013ybe.170.1555513554132;
        Wed, 17 Apr 2019 08:05:54 -0700 (PDT)
Received: from localhost ([2620:10d:c091:200::2:fc54])
        by smtp.gmail.com with ESMTPSA id k123sm19177171ywa.57.2019.04.17.08.05.52
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Apr 2019 08:05:52 -0700 (PDT)
Date: Wed, 17 Apr 2019 11:05:51 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Kernel Team <Kernel-team@fb.com>
Subject: Re: [PATCH] mm: fix false-positive OVERCOMMIT_GUESS failures
Message-ID: <20190417150551.GA23013@cmpxchg.org>
References: <20190412191418.26333-1-hannes@cmpxchg.org>
 <20190412200629.GA24377@tower.DHCP.thefacebook.com>
 <0d2ad7c1-4a5f-08b0-0f57-0273fedc4f70@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0d2ad7c1-4a5f-08b0-0f57-0273fedc4f70@suse.cz>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 02:04:17PM +0200, Vlastimil Babka wrote:
> On 4/12/19 10:06 PM, Roman Gushchin wrote:
> > On Fri, Apr 12, 2019 at 03:14:18PM -0400, Johannes Weiner wrote:
> >> With the default overcommit==guess we occasionally run into mmap
> >> rejections despite plenty of memory that would get dropped under
> >> pressure but just isn't accounted reclaimable. One example of this is
> >> dying cgroups pinned by some page cache. A previous case was auxiliary
> >> path name memory associated with dentries; we have since annotated
> >> those allocations to avoid overcommit failures (see d79f7aa496fc ("mm:
> >> treat indirectly reclaimable memory as free in overcommit logic")).
> >>
> >> But trying to classify all allocated memory reliably as reclaimable
> >> and unreclaimable is a bit of a fool's errand. There could be a myriad
> >> of dependencies that constantly change with kernel versions.
> 
> Just wondering, did you find at least one another reclaimable case like
> those path names?

I'm only aware of the cgroup structures which can be pinned by a
dentry, inode, or page cache page. But they're an entire tree of
memory allocations, per-cpu memory regions etc. that would be
impossible to annotate correctly; it's also unreclaimable while the
cgroup is user-visible and only becomes reclaimable once rmdir'd.

