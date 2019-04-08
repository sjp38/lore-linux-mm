Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49092C282CE
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 05:42:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0FB0F2083E
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 05:42:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0FB0F2083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A20156B027F; Mon,  8 Apr 2019 01:42:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9CF916B0280; Mon,  8 Apr 2019 01:42:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8BE756B0281; Mon,  8 Apr 2019 01:42:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3D9C96B027F
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 01:42:47 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f18so2682773edx.9
        for <linux-mm@kvack.org>; Sun, 07 Apr 2019 22:42:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=TTMRaubNAc10zBh+WNQGCrkOtrxLz4o7HWKaudaXur8=;
        b=ns3YRPhyiuMtOkthuBoaz4F2bm8sE/AZWcrJ96Qsv0D/NsXO7jhiLBBoL4ZauaYzI7
         kZdnyPZwHTjgXrb07nscrYsguSnIrf4ZhlgxBXj7PnNBKhEafvF3QdGB9vsmGvB0/XaP
         JQtcJu5swo2d8wPopF/6bg9+DScG4ZDQu5FRSTYOr57l5V5h2+XRohlmf3vHZym8ak9Z
         jCZldOkL7R7y7SGE0/b17paJJWBhNpHmZNpeXu9Cn5JZv3XWnHrJDRjCJTKJNgjhTzNM
         MOfIs8xm4ZWzo378FGr8VgryEezWiyN2TeZGHynUcOqzsYLStit2FLuLiZGbGfukpBA4
         Mx/w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAW/IQgxby6g5V0RbJmdod02ldgiqH6Ry8XgF/FMaggHzsXh5iwF
	T0PmLGWN368lNfEKDfvduNOlH3nQQIb4FOCNQ3wE8lznl3k/WtuaNynFkdy0fAvmyRwtLfwgv4y
	gmC1o+Ty+ZVWyy0TcU8l9Pgq5NYWO4fQw+zv/K9di5wnR5Ib8clx28DuNP9HgBUc=
X-Received: by 2002:aa7:d784:: with SMTP id s4mr18002018edq.177.1554702166741;
        Sun, 07 Apr 2019 22:42:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy95AutyNnH0i8jnpFwkRThR5MjstXvVA7BuaUnj/8uJv19A1ZgsmgubsI4A6ZwwRpDSY5F
X-Received: by 2002:aa7:d784:: with SMTP id s4mr18001984edq.177.1554702166041;
        Sun, 07 Apr 2019 22:42:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554702166; cv=none;
        d=google.com; s=arc-20160816;
        b=O22IUgIIXlY+azw3cl8H7JR4Z1ws2TK58vCtElNXNtgW+vLRa6CRPkTcOahHa4Fylc
         EWEHCMK/cDfQMm0HtnMI/aFry3a1hUdXZ+xS9/8bweqtnRcL7DkPYNOG8Yle7rdM4iZG
         nr0RcLpB26qPsBLTS9cbQd29C7UK9cLLbhSdBTckHBTQBl5BQaNGtPBgtH4hgPLa2n+6
         4BjNTWt+ETd2ndRRkoR793P+1G66t6m3UbfhraGUMPQ+7pmcLclProC/mlHyHbXqR15r
         G7njXR+glf0/qzsxcHS/RNueNL6qohcpi7TAZQ6dbJLexWzQjEJR9fSlNsNczftoPdm0
         L1/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=TTMRaubNAc10zBh+WNQGCrkOtrxLz4o7HWKaudaXur8=;
        b=nI27U85k3SqdNZSYVijE+E6ZSl2x1pqdc0Ej+atmtxTrQhAXEXX/7GT53C5ho1aMcZ
         6nJAGneo5HfHf52p2BJMihVKtJKIW2bu5F8puib5Vh8b5dYl+WfJZFMN1OVa1jTTOFyT
         SjQXUG+lbwsHuySnNr4yuomICuKwn4w4UHPgqlv3c/+oOCi5IorNCN+451wpVtFWiBiE
         frLoiD9f3T7j0JI6u7HEhriNjnaSYkRdsat3BbdiCK14RZ5SlleixCmv++48T815Y5jU
         hYTmt+wOBreKOGMG72LXIEvSu31baTzt1Q40B/qtaoeONF4eMdCPKLofQTceETQmrxjz
         D8QQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d10si609158eds.335.2019.04.07.22.42.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Apr 2019 22:42:46 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3F0A8AEDF;
	Mon,  8 Apr 2019 05:42:45 +0000 (UTC)
Date: Mon, 8 Apr 2019 07:42:38 +0200
From: Michal Hocko <mhocko@kernel.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: akpm@linux-foundation.org, rafael@kernel.org, david@redhat.com,
	rafael.j.wysocki@intel.com, osalvador@suse.de, vbabka@suse.cz,
	iamjoonsoo.kim@lge.com, bsingharora@gmail.com,
	gregkh@linuxfoundation.org, yangyingliang@huawei.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [RESENT PATCH] mm/memory_hotplug: Do not unlock when fails to
 take the device_hotplug_lock
Message-ID: <20190408054238.GB18103@dhcp22.suse.cz>
References: <1554696437-9593-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1554696437-9593-1-git-send-email-zhongjiang@huawei.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 08-04-19 12:07:17, zhong jiang wrote:
> When adding the memory by probing memory block in sysfs interface, there is an
> obvious issue that we will unlock the device_hotplug_lock when fails to takes it.
> 
> That issue was introduced in Commit 8df1d0e4a265
> ("mm/memory_hotplug: make add_memory() take the device_hotplug_lock")
> 
> We should drop out in time when fails to take the device_hotplug_lock.
> 
> Fixes: 8df1d0e4a265 ("mm/memory_hotplug: make add_memory() take the device_hotplug_lock")
> Reported-by: Yang yingliang <yangyingliang@huawei.com>
> Signed-off-by: zhong jiang <zhongjiang@huawei.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  drivers/base/memory.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index d9ebb89..0c9e22f 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -507,7 +507,7 @@ static ssize_t probe_store(struct device *dev, struct device_attribute *attr,
>  
>  	ret = lock_device_hotplug_sysfs();
>  	if (ret)
> -		goto out;
> +		return ret;
>  
>  	nid = memory_add_physaddr_to_nid(phys_addr);
>  	ret = __add_memory(nid, phys_addr,
> -- 
> 1.7.12.4
> 

-- 
Michal Hocko
SUSE Labs

