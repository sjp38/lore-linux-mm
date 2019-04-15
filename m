Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D89EC10F0E
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 09:15:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4543420656
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 09:15:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4543420656
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F3C666B0007; Mon, 15 Apr 2019 05:15:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EEAEF6B0008; Mon, 15 Apr 2019 05:15:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DDE566B000A; Mon, 15 Apr 2019 05:15:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8B60D6B0007
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 05:15:03 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id h27so8419663eda.8
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 02:15:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=r0xOw9VZZbTGdqeZWKpA4oeuoqazM4HSzIfrGOP0VEQ=;
        b=QavcqKkxR9B+4XbAVojgupLO/dgvMAM79tBpqMqmMbXPrJ+s8l8QbzYf2hX4a+3aAp
         NhNI3C2qti54bq5l96ddyZE4GZpau2bp4X1sSj+WivyMxGWISVxPdQB1FrRCzXbRM4br
         Q9tRFGaqtptFHF0g7+uP4LC8UMzDVKpqlF683aJiBvfR+VvZmEd1YUXia8UqzePX6F5m
         DbEst0RhtoHNev84ELuL4svLJwcV7AgNuAaWpWp1nIPSe/zO8Jpw02BM0YyNcVOvJL31
         2wyoAQLb1cwukC9mW/l98cdUUyD3JuFHfLjlsNBIPMvIl2aWSDr0nhcSSIylmihyfKFt
         DEHQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVhMj1byE/5JHgq5uzF2c0rpoCr3Gy87igl/N5vxplyYDYjm/6O
	97P0c/aEs7IX1hzan+DTUdMs4GFbZx3uicgZkff5VLSb+HxMsTwstkcxf+xaO3K1qD9psGFA2DG
	cJnwaPiSJJLA9txpweI60e5QcVieYMmKffFWsHlrg62UfozdGZKOukGdgR7lGZtY=
X-Received: by 2002:a17:906:7c96:: with SMTP id w22mr18151286ejo.76.1555319703075;
        Mon, 15 Apr 2019 02:15:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyTGfKnGwj3N7P9qPjtZjWUvFct5e3fm8x8Us7Ot4FTGsa+dMA69UnaCV4LkUn9h/VdtJQV
X-Received: by 2002:a17:906:7c96:: with SMTP id w22mr18151250ejo.76.1555319702098;
        Mon, 15 Apr 2019 02:15:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555319702; cv=none;
        d=google.com; s=arc-20160816;
        b=pLV26un4KM4Wg4fC1Ilw3QrdYZdrpmJSwH5ZjAZ/gknC3TMZvcnTjr7+xZy34top+h
         f6BvKsEi9ZIUfLwZ2qoX6xJLw4Q/goW7Q+amKzfPNOajq2ODMliJkmoFbQxFYsE4qp3j
         nSeeo7igQuWKNKrYG1rqb281wHLHsuL8rKZk7kVlcij3QNQhAo1W7Mwb0uyzXthYjcR5
         MxUcN6fma5GtqF05caOdrMAdZACUn2Y3cu3IR/JS/ZRJyjdKjA/uQc/ZisPfB44d8MAF
         JW28Tz0/b8EWKc99xW5YYVus02OdB/UEjAyX2V4zg97U3LScGPlx+d9rf/gK2zASg2z4
         ZHjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=r0xOw9VZZbTGdqeZWKpA4oeuoqazM4HSzIfrGOP0VEQ=;
        b=Lz5WW5IEgDeQopp7WlE/ACmVXwjJZCZV94pvbJr8CnufAtTJGSBw3kjpFvda7Ywu07
         dxzdN88qusKDzLwyZNzrhjY/3e0joyP9QoKSYVtMfXIRq35YX4rjh2Qx1ndmJSr+6YEu
         xD02viTL7X/EGrFOnFq1ZzNgU6WaLvxlrTjdzFhrutTUqloNDTO4W+fPj8YHDttLFSTm
         73F5WSCyObrQarYd+fW40mq+tAAsJCWAsMc48aeLjXwI0YpUz2Jvd4wEXx1rqnangjy9
         EXMv4Z5wRmyouSCuvb7leNJlQtT5QBipgqc25Pz5KZQREvKU2pdxJRO8uHz/czt1tECu
         eJog==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a18si1616238edt.154.2019.04.15.02.15.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 02:15:02 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7FC80AF2F;
	Mon, 15 Apr 2019 09:15:01 +0000 (UTC)
Date: Mon, 15 Apr 2019 11:15:00 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Yufen Yu <yuyufen@huawei.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH] hugetlbfs: move resv_map to hugetlbfs_inode_info
Message-ID: <20190415091500.GG3366@dhcp22.suse.cz>
References: <20190412040240.29861-1-yuyufen@huawei.com>
 <83a4e275-405f-f1d8-2245-d597bef2ec69@oracle.com>
 <20190415061618.GA16061@hori.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190415061618.GA16061@hori.linux.bs1.fc.nec.co.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 15-04-19 06:16:15, Naoya Horiguchi wrote:
> On Fri, Apr 12, 2019 at 04:40:01PM -0700, Mike Kravetz wrote:
> > On 4/11/19 9:02 PM, Yufen Yu wrote:
> > > Commit 58b6e5e8f1ad ("hugetlbfs: fix memory leak for resv_map")
> > ...
> > > However, for inode mode that is 'S_ISBLK', hugetlbfs_evict_inode() may
> > > free or modify i_mapping->private_data that is owned by bdev inode,
> > > which is not expected!
> > ...
> > > We fix the problem by moving resv_map to hugetlbfs_inode_info. It may
> > > be more reasonable.
> > 
> > Your patches force me to consider these potential issues.  Thank you!
> > 
> > The root of all these problems (including the original leak) is that the
> > open of a block special inode will result in bd_acquire() overwriting the
> > value of inode->i_mapping.  Since hugetlbfs inodes normally contain a
> > resv_map at inode->i_mapping->private_data, a memory leak occurs if we do
> > not free the initially allocated resv_map.  In addition, when the
> > inode is evicted/destroyed inode->i_mapping may point to an address space
> > not associated with the hugetlbfs inode.  If code assumes inode->i_mapping
> > points to hugetlbfs inode address space at evict time, there may be bad
> > data references or worse.
> 
> Let me ask a kind of elementary question: is there any good reason/purpose
> to create and use block special files on hugetlbfs?  I never heard about
> such usecases.  I guess that the conflict of the usage of ->i_mapping is
> discovered recently and that's because block special files on hugetlbfs are
> just not considered until recently or well defined.  So I think that we might
> be better to begin with defining it first.

A absolutely agree. Hugetlbfs is overly complicated even without that.
So if this is merely "we have tried it and it has blown up" kinda thing
then just refuse the create blockdev files or document it as undefined.
You need a root to do so anyway.
-- 
Michal Hocko
SUSE Labs

