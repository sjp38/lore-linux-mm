Return-Path: <SRS0=+lVK=PP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3B72C43387
	for <linux-mm@archiver.kernel.org>; Mon,  7 Jan 2019 18:13:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5791C2087F
	for <linux-mm@archiver.kernel.org>; Mon,  7 Jan 2019 18:13:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5791C2087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=collabora.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B4B9D8E0031; Mon,  7 Jan 2019 13:13:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD71E8E0001; Mon,  7 Jan 2019 13:13:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 99E1D8E0031; Mon,  7 Jan 2019 13:13:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3B8BA8E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 13:13:55 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id f18so460316wrt.1
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 10:13:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=G7vfL13FefGMTya6xzgnByE6fZ+0duHn8ctpkjExpBo=;
        b=FJnj7ViUbVmT1V0tiynb9XOSs3G+PVHT2hpe4pULLlRNUmfMh8epNNCAAH30J7EXwE
         ySWR/xtrlvJuq2tyI1PM9eyiH0EDpYeH2cR5GffnygD3uCDHa8tFq2TdGfCCg0Q3+iuE
         8ba0VJv7XFbbKuA5HW55NreUXhISLV6B1K4yz4gJs9OreeCSy+Nz4G3FcmV7HLx9Zz5b
         sYSeEjKHQz09WfwWaUbOlWq3na//IH/BnyZLD4Zn3YLv1ZKkmR8aVgOCjrycXg2dxluB
         vaH1MG/CvWHS5nP0erMprfwIIzcCBlKJIw1OA/6ERM4qrxO0MzVaH3ptub7HWYpG8vNE
         jiJQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of gael.portay@collabora.com designates 2a00:1098:0:82:1000:25:2eeb:e3e3 as permitted sender) smtp.mailfrom=gael.portay@collabora.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
X-Gm-Message-State: AJcUukcXpSPMZMcvsPQpSeyq/qCVC1Menx5IOvI6AY8gNwPpNqba4yoL
	dPcYqUSfgr6q9zWe6KAaVVEOWtKS0OT6HhrbKrLVfdZse3LGScImsWWIqqp+k1+c+9VHOg1MF+1
	9YEy7VozXvC97XKEolg6wb8ezD/lG9d8jgoJHoIlfe3w/3iQMPph81IbKeHOC7UImTQ==
X-Received: by 2002:adf:afdc:: with SMTP id y28mr50591631wrd.275.1546884834773;
        Mon, 07 Jan 2019 10:13:54 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7G6+adc0I1+uBegmFXUHETfTqbjKV5xet2mU+/H8tcv8tgLe59Qlma3JRbG7SZ9Oj2Ec9x
X-Received: by 2002:adf:afdc:: with SMTP id y28mr50591582wrd.275.1546884833828;
        Mon, 07 Jan 2019 10:13:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546884833; cv=none;
        d=google.com; s=arc-20160816;
        b=LwlFO7xI0vj8nFIhTH3Cag5uAePcJ7he+sDj+9TxC+BiJD/smRV0xPvf1xFffCy47s
         OyII4zmD4Bwx2Dv7aimcO7lgQLDVNa4twu6nak4LBBGPppu77TyAx4/Fx375KU1aOCJh
         JbojCEst7QwCzO1blxyCE+eBMj6DWBwzdphRvJ8wS6qFFrKKECqQAKADkiAMlIJazd7t
         ORTQvUTYP+tPmtAP1SdXwzcq/E0FjZZS716onxU24GColMq/91IO17Mb7EIWpvabZzHX
         Q5zHIb8iCv8FiAG9euM2wdQQ1+ABysRwOAY0pEThwjtO+6pOC2iskPJ7btwslLDp2Grn
         axiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=G7vfL13FefGMTya6xzgnByE6fZ+0duHn8ctpkjExpBo=;
        b=uVHyUlYiQ5PpIhV4Km+lhowNwYAnEeYeZXUyb02rOu0T3/KbDH/SOadL4v5U8cWzQg
         u/wqUfoTm6K02foaGVgdYD6u2TD087GSF7Hh0tjTlMom4/L8Fp9th1FmBwXLvSAhTTu2
         wV1SFkotL9SV3r4CG6eceAIj80K4WGIzW6sio+yZW1RvY8CG+wny3bL6VYEX/GWA6ELs
         DIlr6qm6/P1WHsmbBZy9orgsu3IC1XbCAn71qMSJtSlT4lraEDHli3cJprSEN5P6PtJL
         8Z6AgsxOPQs6Q+fPziqLxSGJX3LrMJaYgRm7hS20/SCFg+ENke5yqZoceUxUpwIRXvJm
         RC+A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of gael.portay@collabora.com designates 2a00:1098:0:82:1000:25:2eeb:e3e3 as permitted sender) smtp.mailfrom=gael.portay@collabora.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
Received: from bhuna.collabora.co.uk (bhuna.collabora.co.uk. [2a00:1098:0:82:1000:25:2eeb:e3e3])
        by mx.google.com with ESMTPS id j65si5439852wmj.102.2019.01.07.10.13.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 07 Jan 2019 10:13:53 -0800 (PST)
Received-SPF: pass (google.com: domain of gael.portay@collabora.com designates 2a00:1098:0:82:1000:25:2eeb:e3e3 as permitted sender) client-ip=2a00:1098:0:82:1000:25:2eeb:e3e3;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of gael.portay@collabora.com designates 2a00:1098:0:82:1000:25:2eeb:e3e3 as permitted sender) smtp.mailfrom=gael.portay@collabora.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
Received: from [127.0.0.1] (localhost [127.0.0.1])
	(Authenticated sender: gportay)
	with ESMTPSA id 994522604BB
Date: Mon, 7 Jan 2019 13:13:55 -0500
From: =?utf-8?B?R2HDq2w=?= PORTAY <gael.portay@collabora.com>
To: Laura Abbott <labbott@redhat.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>,
	Alan Stern <stern@rowland.harvard.edu>, linux-mm@kvack.org,
	usb-storage@lists.one-eyed-alien.net
Subject: Re: [usb-storage] Re: cma: deadlock using usb-storage and fs
Message-ID: <20190107181355.qqbdc6pguq4w3z6u@archlinux.localdomain>
References: <20181216222117.v5bzdfdvtulv2t54@archlinux.localdomain>
 <Pine.LNX.4.44L0.1812171038300.1630-100000@iolanthe.rowland.org>
 <20181217182922.bogbrhjm6ubnswqw@archlinux.localdomain>
 <c3ab7935-8d8d-27a0-99a7-0dab51244a42@redhat.com>
 <593e3757-6f50-22bc-d5a9-ea5819b9a63d@oracle.com>
 <da35de2c-b8ad-9b01-b582-8f1f8061e8e1@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <da35de2c-b8ad-9b01-b582-8f1f8061e8e1@redhat.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190107181355.X3QBXvxkRCk5PPJ_3bBSx5_5vFpiQtqSbWaVBOAx3zE@z>

Laura,

On Tue, Dec 18, 2018 at 01:14:42PM -0800, Laura Abbott wrote:
> On 12/18/18 11:42 AM, Mike Kravetz wrote:
> > On 12/17/18 1:57 PM, Laura Abbott wrote:
> > > On 12/17/18 10:29 AM, Gaël PORTAY wrote:
> > > 
> > > Last time I looked at this, we needed the cma_mutex for serialization
> > > so unless we want to rework that, I think we need to not use CMA in the
> > > writeback case (i.e. GFP_IO).

I followed what you suggested and add gfpflags_allow_writeback that
tests against the __GFP_IO flag:

static inline bool gfpflags_allow_writeback(const gfp_t gfp_flags)
{
	return !!(gfp_flags & __GFP_IO);
}

And then not to go for CMA in the case of writeback in function
__dma_alloc:

-	cma = allowblock ? dev_get_cma_area(dev) : false;
+	allowwriteback = gfpflags_allow_writeback(gfp);
+	cma = (allowblock && !allowwriteback) ? dev_get_cma_area(dev) : false;

This workaround fixes the issue I faced (I have prepared a patch).

> > I am wondering if we still need to hold the cma_mutex while calling
> > alloc_contig_range().  Looking back at the history, it appears that
> > the reason for holding the mutex was to prevent two threads from operating
> > on the same pageblock.
> > 
> > Commit 2c7452a075d4 ("mm/page_isolation.c: make start_isolate_page_range()
> > fail if already isolated") will cause alloc_contig_range to return EBUSY
> > if two callers are attempting to operate on the same pageblock.  This was
> > added because memory hotplug as well as gigantac page allocation call
> > alloc_contig_range and could conflict with each other or cma.   cma_alloc
> > has logic to retry if EBUSY is returned.  Although, IIUC it assumes the
> > EBUSY is the result of specific pages being busy as opposed to someone
> > else operating on the pageblock.  Therefore, the retry logic to 'try a
> > different set of pages' is not what one  would/should attempt in the case
> > someone else is operating on the pageblock.
> > 
> > Would it be possible or make sense to remove the mutex and retry when
> > EBUSY?  Or, am I missing some other reason for holding the mutex.
> > 
> 
> I had forgotten that start_isolate_page_range had been updated to
> return -EBUSY. It looks like we would need to update
> the callback for migrate_pages in __alloc_contig_migrate_range
> since alloc_migrate_target by default will use __GFP_IO.
> So I _think_ if we update that to honor GFP_NOIO we could
> remove the mutex assuming the rest of migrate_pages honors
> it properly.
> 

I have also removed the mutex (start_isolate_page_range retunrs -EBUSY),
and it worked (in my case).

But I did not do the proper magic because I am not sure of what should
be done and how: -EBUSY is not handled and __GFP_NOIO is not honored. 

Regards,
Gael

