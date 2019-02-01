Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8BDF2C282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 07:48:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4196320869
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 07:48:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4196320869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB5E38E0002; Fri,  1 Feb 2019 02:48:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D6EF48E0001; Fri,  1 Feb 2019 02:48:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C526E8E0002; Fri,  1 Feb 2019 02:48:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 83B358E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 02:48:13 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id o21so2467309edq.4
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 23:48:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=OykS8konC8WIU8Ih4gBJvAIWdoMMj0yooCTGloeoFbI=;
        b=XrERuGVSemmRHMwpGDcQePfcqaSg2J6OaiZnC7w/ZXeYDZX7cC/aeMxu6pzaZ0s0eA
         eY3ECNhf3uCn1pOLhUDZb+EojFBjNyLxZ0eMT0J/WWJX2t50jbpHSgSS9GGkd0momtZN
         sHRdRcmkYmqmmnHkEgjQKpXKmsdSDOBRceqbGBgGqzz+dNcB7Q7PmX0jWtq/xxCDkWJ6
         N2snl6BMDWoFT30pGMGkBFH33GDh5fm/yA4PPvKCb0wHiNhvguNfxfUfbbN7mqV8uNcq
         SWuE0rb9fuaY39hD7SDKObzzci4QwYvmsnvKTduNVEbHBb2bNtrDJmCWFvQxfAQ27JG1
         ODrw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUuke4XkfHqUFeItR6ITWApfv5QSkYsL9T87vGG9syh+o+MWtGx43n
	fPA/Jr/1q4grNkDYftCN8rOU8fg701ZlghsOv3FeobUzP1juodE3slzcMgIvMgoKjB9KHvWUCya
	3El7Fk2UPNPoFEhEFs3nkvAIQ5X38naG2sMv0TbL4LLwCkYx1tmg4+6tBT3S45Jc=
X-Received: by 2002:a17:906:77da:: with SMTP id m26mr26675977ejn.60.1549007293021;
        Thu, 31 Jan 2019 23:48:13 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4j/zApxPb8uj0neKfYGMB8x322tJOIk+I1/DTWQT1sw+TnjMr/cnTixpfVLakbCTxUp/6M
X-Received: by 2002:a17:906:77da:: with SMTP id m26mr26675945ejn.60.1549007292165;
        Thu, 31 Jan 2019 23:48:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549007292; cv=none;
        d=google.com; s=arc-20160816;
        b=GOoHCT0L3d1qpNCZXUHrS3m9roo8racBEhdhOTB29xupErLn5uAKQVCLepZVsJNTHf
         rX1uc2MGjzu6fb/4s4IzzpAHLBAKEf6XYnQW5ScMnpuTuJmrokKSwFBaQ6D4wvhxn7Qy
         BfhoNS+/z3AYISNcs4YbSBjhWW9rf3yWhOl8JkiHVgxg/Xx4/PMAgd0TV8y2Xhl9vd5M
         Kl1vI6jvkNRHxgltCx7KH9b6gwSki8A4LCxLsrDhQ1JJusIBzicLjpbhsmbT/xcNJzjS
         yEZULe5lBqgOcajIHXAEqT24j4zSf1s1iEaXX2G5sGs6yXfnBsPJrw0HN1mzM6S5Od2O
         CCFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=OykS8konC8WIU8Ih4gBJvAIWdoMMj0yooCTGloeoFbI=;
        b=eJcUz7l0N0WLdgEEmwNrjO7NwV9EsjHgWaZ+dIE7YjE81caOgPM2o29wECdFEE37Ch
         aV29H42h0tGbGjMzatjWCtMWjTBbCNHtIIZoVpaAZneu3iVmDa8Eahr0D0jDI3CcEiS1
         bj6sTwXSLTrQWMpUb1DdsZg/tm5kRbMR0q5xbc3ehBo0p5H7Ciq5wmck+p88UGz1K82j
         z23MLjqO5W3XNGWRa5jXsbuaBekhgzPckaKcgV/imWfwqx1EZSKY/58V4XhM5IewKQd7
         IrpxdHlhsV5UjE8oFD7Ct+GExF91e/OzHQyBha96ip1UmAi/PqC8/VYML3wDC9u//DVq
         aclQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x28si1550336edm.388.2019.01.31.23.48.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 23:48:12 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A54EDAF86;
	Fri,  1 Feb 2019 07:48:11 +0000 (UTC)
Date: Fri, 1 Feb 2019 08:48:09 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Chris Down <chris@chrisdown.name>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH] mm, memcg: Handle cgroup_disable=memory when getting
 memcg protection
Message-ID: <20190201074809.GF11599@dhcp22.suse.cz>
References: <20190201045711.GA18302@chrisdown.name>
 <20190201071203.GD11599@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190201071203.GD11599@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 01-02-19 08:12:03, Michal Hocko wrote:
> On Thu 31-01-19 23:57:11, Chris Down wrote:
> > memcg is NULL if we have CONFIG_MEMCG set, but cgroup_disable=memory on
> > the kernel command line.
> > 
> > Fixes: 8a907cdf0177ab40 ("mm, memcg: proportional memory.{low,min} reclaim")
> 
> JFYI this is not a valid sha1. It is from linux next and it will change
> with the next linux-next release.
> 
> Btw. I still didn't get to look at your patch and I am unlikely to do so
> today. I will be offline next week but I will try to get to it after I
> get back.

Btw. I would appreciate if you could post the patch with all fixups
folded for the final review once things settle down.
-- 
Michal Hocko
SUSE Labs

