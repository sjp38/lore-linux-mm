Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54D32C10F05
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 21:48:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EE9E5218C3
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 21:48:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EE9E5218C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 27A696B0003; Wed, 20 Mar 2019 17:48:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 204376B0006; Wed, 20 Mar 2019 17:48:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0CE176B0007; Wed, 20 Mar 2019 17:48:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B24F06B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 17:48:09 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id m32so1469147edd.9
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 14:48:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=ti9ripvN2rhcF9NSGZusPod+XiKR1FLqC84BWaRifHI=;
        b=i0UTs0XtNwdTFvh184DrPj1TCVoDiGOrnkStVEkdQzfh7CBA1ortFd/6HaA4vEFaBe
         XKYWwu4C9EfkLo0QaEhs7NJAlx8NiRfjTEb/DjBe/5BM6zrnbjp2Bp4JhZuVqNvvvNrE
         JFlix9iN/OkuaxAYusRsBDcFyxrqSi08W1TQ3cngpXji9Zdr1bHRlbRXLdN08qQF7/XP
         Chbu+q2E+0ykTxp/5TZ1ivOM57YM2cIB1pp6/yryN02OXcXa1gGwVco7gH+wFBiSXw8P
         0ErH7Nov7y+ehq6PXNcZfyQSBOFmboqeGFpKObhhhvUpWr8dcFSYxD/L2exHn/1llV8f
         f6VA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAVuzk3k2nl75ntpZhVWgQ3X3KAH46bYaMO2lcLaEoSue04i0Bep
	Xc6ZR5KPy8jHC4s1rfgKt/rTf6SxaImwH4+qRqo6qpPiyvBvN/ftDI2h8UHvyuM3YVN/xYzYV8e
	y3Odb8733P5K0ER1q+KIJoqPyIRDZpeQM8efIFoDwZ3X9vH3hhXrccqPCLu9ThaZVkA==
X-Received: by 2002:a50:aeec:: with SMTP id f41mr128618edd.279.1553118489212;
        Wed, 20 Mar 2019 14:48:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwb8bNMc72rd1FVkCPZuKCOgGdc6OGFc78s4Aft59CFw1wM5CdYJXnFxV/J/3ti5Gd8LklP
X-Received: by 2002:a50:aeec:: with SMTP id f41mr128558edd.279.1553118487911;
        Wed, 20 Mar 2019 14:48:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553118487; cv=none;
        d=google.com; s=arc-20160816;
        b=yP/ThDp8e/IMin3RTO0M5Dsyvq6ur0qrKrDFJFQtaLo0rSOSUsIRd9nHchnj1LB0qA
         lMiPyqf1eLQmieJZDrJYFKiQsIM7s4YkB+fuK3Dc3tgQoOwX/PfvV+VoneGDhqv/dmZG
         pE23spEiWv0clgvfMjSRgw/twR0Zl4hD93MoZDTUxU8XzHKBL8mo1KbOQUNye3t9dSzz
         2JgQ8jr24sG1rlTzb2a0WxNAmMF3Eqpezxru+mAUuFMz+gYqY12nvV7KFvn4HJEkS+Hf
         6D318JCHmVVfC3C0cVC+e+VABJQbpG5xNesIhsDsyfRDM6i0Qih9I6MFc2rcijKAB2Lp
         fLPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=ti9ripvN2rhcF9NSGZusPod+XiKR1FLqC84BWaRifHI=;
        b=MMXcx3x+ddprBfHTIYCmVensIX5ziyy096durJ3U1dMgHmb8LtCwXiyspbbUi7wMOj
         T1zJmsk5eYBK6512GDZKHq4amdqHpKY4KVCeaMezizFgzxSgZIR2jf5tqpFwgZx+QP0p
         IQqdGuX6YVxLLHQCqnMxPQLI9DEUwLf+gFVGMOWehC/aZ6UHLicB6AQ8Vjy5epeqdxBf
         hpg4X2Eglzo/7oorQwld7Hxp+hwt6gb8cv5ZDF55Hf8utP/e03kq5e0Y77u9+dkquTV9
         jprO+YZu9fZpNcfLvLiDMxpVAClcFIln6pxtRxxnnLqecxr17ngXPNvSwQafU1g++trZ
         DMcg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d14si1246714ede.302.2019.03.20.14.48.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 14:48:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B61CEAFBD;
	Wed, 20 Mar 2019 21:48:06 +0000 (UTC)
Subject: Re: [RFC 0/2] guarantee natural alignment for kmalloc()
To: Matthew Wilcox <willy@infradead.org>
Cc: Christopher Lameter <cl@linux.com>, linux-mm@kvack.org,
 Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>, Ming Lei <ming.lei@redhat.com>,
 Dave Chinner <david@fromorbit.com>,
 "Darrick J . Wong" <darrick.wong@oracle.com>, Christoph Hellwig
 <hch@lst.de>, Michal Hocko <mhocko@kernel.org>,
 linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
References: <20190319211108.15495-1-vbabka@suse.cz>
 <01000169988d4e34-b4178f68-c390-472b-b62f-a57a4f459a76-000000@email.amazonses.com>
 <5d7fee9c-1a80-6ac9-ac1d-b1ce05ed27a8@suse.cz>
 <20190320185347.GZ19508@bombadil.infradead.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <b5290e04-6f29-c237-78a7-511821183efe@suse.cz>
Date: Wed, 20 Mar 2019 22:48:03 +0100
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190320185347.GZ19508@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 3/20/2019 7:53 PM, Matthew Wilcox wrote:
> On Wed, Mar 20, 2019 at 09:48:47AM +0100, Vlastimil Babka wrote:
>> Natural alignment to size is rather well defined, no? Would anyone ever
>> assume a larger one, for what reason?
>> It's now where some make assumptions (even unknowingly) for natural
>> There are two 'odd' sizes 96 and 192, which will keep cacheline size
>> alignment, would anyone really expect more than 64 bytes?
> 
> Presumably 96 will keep being aligned to 32 bytes, as aligning 96 to 64
> just results in 128-byte allocations.

Well, looks like that's what happens. This is with SLAB, but the alignment
calculations should be common: 

slabinfo - version: 2.1
# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <limit> <batchcount> <sharedfactor> : slabdata <active_slabs> <num_slabs> <sharedavail>
kmalloc-96          2611   4896    128   32    1 : tunables  120   60    8 : slabdata    153    153      0
kmalloc-128         4798   5536    128   32    1 : tunables  120   60    8 : slabdata    173    173      0

