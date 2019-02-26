Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 284F6C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 20:40:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D504021852
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 20:40:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D504021852
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 74D018E0003; Tue, 26 Feb 2019 15:40:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6FB748E0001; Tue, 26 Feb 2019 15:40:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 612288E0003; Tue, 26 Feb 2019 15:40:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0BF0B8E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 15:40:52 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id x13so3758652edq.11
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 12:40:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=JxMHd5xgLUnrCKWn4gqh4NtwqzA60WzC/XA13iSES64=;
        b=JGPg2fHtAW5ij0NcfVNd7lum6hm3hEzAakCJMzyszr2qKc+BmxNURgnGTfL9G5bpqz
         xj6ltWEI9BbWe76X/0xbrfMJum/RtIEZKu4tiddXNw0uVcQ4VZUWBdDLrePgMVwmy/cf
         K+7p/HCSEBJyHoZ5gAPRBj9uNGMI7KVgnhaDS6x7u8kktdrJJTL+PPVEdMqUgYvRXYO2
         wR6ILlg1O/I5C36zufpP7a+iLcVzcl4EGBnRv+v2qM1ByklR5oyHKQ1CO3l4AX4gxBiS
         GqK+1d7VphftmKrJQ3WORx8j0e4ig0f8TAXEzkfUnnVZChAVc0BAq1un1STnpDL89EY2
         X63A==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuYSc3vYzaVtwFajygQQjw8cveuDN6sQ2MfXVNyZSxhqRH77jx7K
	SmakBWpe2/4o5HOKbnf4gseKQ0qwBsZPMKXMRLjaHII669RwJ+wEkhluhl9xg+M5031+CrA0JPj
	PSkalIac+dDuMq9I/OfepNGEp1nHrag3sAZI3sgIrGgO1dQuHTUQv/LA+xDN3lEA=
X-Received: by 2002:a05:6402:1682:: with SMTP id a2mr19815393edv.158.1551213651621;
        Tue, 26 Feb 2019 12:40:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbUe5xBsb44iAvzlwhWda27QloKdTTjfA3SGE5PmU//VxHiIWTjCATG1fbihOIEl0TaVKbm
X-Received: by 2002:a05:6402:1682:: with SMTP id a2mr19815358edv.158.1551213650807;
        Tue, 26 Feb 2019 12:40:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551213650; cv=none;
        d=google.com; s=arc-20160816;
        b=zEEuhLhtvT7TfyqzT22YM3TnyMCd83yLOl48uSxM1ozfl65DVW1TmMRPTx5B1/0vPK
         3nQC7yepqB5VfnRgo4Ej+DvrZu2PxgQ0OkwIqjnQpmr42CUGbxOE88e1spkVC2ddm27E
         1YOW/Drkk2tZ9wBmaPDKDBRf7nZr2Ka1aE8VXuxpM0apQqvg8mPgYJQA42gTOKqbJ3P1
         88BV8wWXjMTV1KMGrz71ig/6U5a5MC7UrJc+b7XABxBPjkCIF5X7zjbj98NN0oNlU39r
         BoqdpNLivLhWhPHZBNlq0uskUSeKDeSgt47Iio8Sv8LQKRm41Pda7iDqzW4HZAroAwIo
         U1LA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=JxMHd5xgLUnrCKWn4gqh4NtwqzA60WzC/XA13iSES64=;
        b=DqD4r0bw2wzcMGWiKYUQ4fbp7A6I2WxZ9LOjs6q/kO8+bx4BlIc2PaleatmvAtm4oO
         ZgwoJp9d33XAIJoT6SevN2SpEOe+0VqDPenfMf72FVDP1bfRUC2R/kH0ihcY+OhiZzH/
         23zr4LMzo/sL/HmCiWZ7Am+U76qJcxUdEspoSOgwvNp33sM8TF3ge27ChhW/+TA7Wcqg
         cJPJ16qr2hWmLWx+jzy5V2KNwdqrBJCqWNCLBsVz425dTy6+B/9IurMJirGbEwLHnYv5
         /IPPYjnYyyCfMf6djTYPkosz7XDijMfrhua3ax0leMCK+WhsmFSIorbby63jdBcLOtw7
         7o8w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f54si4765491eda.138.2019.02.26.12.40.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 12:40:50 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1A2F5B6A5;
	Tue, 26 Feb 2019 20:40:50 +0000 (UTC)
Date: Tue, 26 Feb 2019 21:40:47 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/hotplug: fix an imbalance with DEBUG_PAGEALLOC
Message-ID: <20190226204047.GJ10588@dhcp22.suse.cz>
References: <20190225191710.48131-1-cai@lca.pw>
 <20190226123521.GZ10588@dhcp22.suse.cz>
 <4d4d3140-6d83-6d22-efdb-370351023aea@lca.pw>
 <20190226142352.GC10588@dhcp22.suse.cz>
 <1551203585.6911.47.camel@lca.pw>
 <20190226181648.GG10588@dhcp22.suse.cz>
 <20190226182007.GH10588@dhcp22.suse.cz>
 <1551208782.6911.51.camel@lca.pw>
 <20190226194024.GI10588@dhcp22.suse.cz>
 <1551211839.6911.54.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1551211839.6911.54.camel@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 26-02-19 15:10:39, Qian Cai wrote:
> On Tue, 2019-02-26 at 20:40 +0100, Michal Hocko wrote:
> > It seems you have missed the point of my question. It simply doesn't
> > make much sense to have offline memory mapped. That memory is not
> > accessible in general. So mapping it at the offline time is dubious at
> > best. 
> 
> Well, kernel_map_pages() is like other debug features which could look
> "unusual".
> 
> > Also you do not get through the offlining phase on a newly
> > hotplugged (and not yet onlined) memory. So the patch doesn't look
> > correct to me and it all smells like the bug you are seeing is a wrong
> > reporting.
> > 
> 
> That (physical memory hotadd) is a special case like during the boot. The patch
> is strictly to deal with offline/online memory, i.e., logical/soft memory
> hotplug.

And it doesn't handle it properly AFAICS. You want to get an exception
when accessing an offline memory, don't you? Offline, free or not present
memory is basically the same case - nobody should be touching that
memory.

-- 
Michal Hocko
SUSE Labs

