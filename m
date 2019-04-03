Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A191C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 08:12:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 475502084C
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 08:12:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 475502084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA5626B000C; Wed,  3 Apr 2019 04:12:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A2CBC6B000D; Wed,  3 Apr 2019 04:12:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8CC7A6B000E; Wed,  3 Apr 2019 04:12:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3744C6B000C
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 04:12:46 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id m31so7098315edm.4
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 01:12:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=RaqYFOjIk+6NqMdRR4F18iP/aUYykBgqk+rV4IKZ8Z4=;
        b=d6PwM1WfxQjwCiTmsVJg273XoC9opf/HsFiwEOd56qNlzK0t40qlPdzcqEQb9/Cc0W
         3xLjFCb50VkFJrTDg56jlWu58tgtDlpliy6UunQuPldmHYxu4tZ8bHqhzDWNlgbzssrY
         htq286RG3wPmRz9PYz9IcB7WHIX91bE0yddbf5eWTUfEt9qq1PyhysK+xT26s8OORYAo
         MQoSaNp/tiuIZcTc+GZYMTr9Ep6ETjPjip080CTInA8U/9RKFFnmYG9A1zMrngqSrkK0
         eQKr0ShrePyyabLAE7F8eK8dtYbEyLgZKZJSQDdi5pUK05SXBfcQFBOo30NCZN7D9SxG
         uMJw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVxr1FToT/7xtjCQlPHItrKy1f4CwFUyHZS9adFrL/cc/Xcx0Wn
	xLxfhIDBkt0GDWJtFVRE2x568+li+YpZywM7XfsRDBvv+67hCA7UDXfVZqmoDKOvdZQ4Baisemx
	ZrYkg1lWqyBNl2id+mtY23B8Mu0Rn0OlcOkV5btDhrAOIZa3QC4aFuDnKf/Chv1o=
X-Received: by 2002:a50:b1bc:: with SMTP id m57mr48562802edd.116.1554279165788;
        Wed, 03 Apr 2019 01:12:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyk+1rj+Qu/TwHQyp+tb4k4pL5OkJM5bQjW4ATZRCrWyA8D7ji7hvxbjjdcjxqtuqpqsSXC
X-Received: by 2002:a50:b1bc:: with SMTP id m57mr48562551edd.116.1554279160256;
        Wed, 03 Apr 2019 01:12:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554279160; cv=none;
        d=google.com; s=arc-20160816;
        b=N98jzqzRrWh58wYyJAJafJMkErtTOvufEXOGBp1RVKah9pM9PsjEvnTTtTuAfrASyk
         9NouaVMn8IGjRiSNTYu3vIzO/GxjEKqn76YJ1Jlhk27WNRN66TyZRmBtqElAVAZm7JOL
         6os6p/V7HQ0ucMeqYwbkKUP8mSl1T9b9TzuxZ4wnxn3GWEDUff/q1sttzGIHfCP1BxN2
         qkIA2dHhgIgvQaEDJaMrqA6mGMXCA5FvvMIU2weepdBvuVFb3FsI09NCt/9EkDKcAGN7
         JvVaRJMzjecJntxY6xBYnrETzjqQqLEX61WBtA8mp4/cwqeF5X6VEVelirrDUlnCsf0R
         cDcQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=RaqYFOjIk+6NqMdRR4F18iP/aUYykBgqk+rV4IKZ8Z4=;
        b=GPXjGM9YPHO0wji0BixaXbucCyS3rAkcnzMcCnZmpu+CJTYtIOu7MwbMXpQaKyRHRs
         DgYA2LBsnI8pRh083grS2HI3qsTxYBPxc7nVFNsG09xrNIZ4lZkgIbCf99aPllqoS0AO
         4m99nPhYUA9e6RDogbENsVe1bAluQ6/tIqYABFcskfJ6syMH8yFFYChugxEk8TgQVnjk
         D0cDNOAw3ycTkNHBn2Rh8t13zp4xk0kV99Lsuo5khYLkG4oduqDWClgKwXkWbZHjKNOt
         a9foNcX7Kcp4ItlOi2ITXabpDU+aTKZ8lcpksrAQgrkJVmPdpRv48yuvK+3PQ1BYcdDP
         nFcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e14si3061553ejs.265.2019.04.03.01.12.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 01:12:40 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id CB885B010;
	Wed,  3 Apr 2019 08:12:38 +0000 (UTC)
Date: Wed, 3 Apr 2019 10:12:32 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: David Hildenbrand <david@redhat.com>, akpm@linux-foundation.org,
	dan.j.williams@intel.com, Jonathan.Cameron@huawei.com,
	anshuman.khandual@arm.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH 0/4] mm,memory_hotplug: allocate memmap from hotadded
 memory
Message-ID: <20190403081232.GB15605@dhcp22.suse.cz>
References: <20190328134320.13232-1-osalvador@suse.de>
 <cc68ec6d-3ad2-a998-73dc-cb90f3563899@redhat.com>
 <efb08377-ca5d-4110-d7ae-04a0d61ac294@redhat.com>
 <20190329084547.5k37xjwvkgffwajo@d104.suse.de>
 <20190329134243.GA30026@dhcp22.suse.cz>
 <20190401075936.bjt2qsrhw77rib77@d104.suse.de>
 <20190401115306.GF28293@dhcp22.suse.cz>
 <20190402082812.fefamf7qlzulb7t2@d104.suse.de>
 <20190402124845.GD28293@dhcp22.suse.cz>
 <20190403080113.adj2m3szhhnvzu56@d104.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190403080113.adj2m3szhhnvzu56@d104.suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 03-04-19 10:01:16, Oscar Salvador wrote:
> On Tue, Apr 02, 2019 at 02:48:45PM +0200, Michal Hocko wrote:
> > So what is going to happen when you hotadd two memblocks. The first one
> > holds memmaps and then you want to hotremove (not just offline) it?
> 
> If you hot-add two memblocks, this means that either:
> 
> a) you hot-add a 256MB-memory-device (128MB per memblock)
> b) you hot-add two 128MB-memory-device
> 
> Either way, hot-removing only works for memory-device as a whole, so
> there is no problem.
> 
> Vmemmaps are created per hot-added operations, this means that
> vmemmaps will be created for the hot-added range.
> And since hot-add/hot-remove operations works with the same granularity,
> there is no problem.

What does prevent calling somebody arch_add_memory for a range spanning
multiple memblocks from a driver directly. In other words aren't you
making  assumptions about a future usage based on the qemu usecase?

-- 
Michal Hocko
SUSE Labs

