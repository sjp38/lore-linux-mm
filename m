Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7ACC9C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 19:40:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 369C92083D
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 19:40:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 369C92083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C38508E0004; Tue, 26 Feb 2019 14:40:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BBDC88E0001; Tue, 26 Feb 2019 14:40:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A5FD68E0004; Tue, 26 Feb 2019 14:40:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 463C58E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 14:40:27 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id o27so5915260edc.14
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 11:40:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=AvolvAcxXioNyvTz5UGFY/cvO3UIu3EClNqVmLReyxQ=;
        b=DgFef5nuadEoelDttGelQyoVH9XYSPfpqTRINW8a/YuQ7gWVT+MhRTnu+IRgQ+Mluu
         DVi1kzG+fbNYBEV7PZEutdWpEz95lQRq1LUO/WSVXDmZWPy9PisR+DI9sQ6czuKvKigu
         bSYGVo3SkXkRQBHEvt+yc/mECAe9yez1HkHf+8Q26z/guvXiGrbunsjgaNe8aX6Gt29x
         smCEVAXgWG0P7U/bmz6RT10R5vRjwve6CvKVBjr68067pxMvdvDZmkq8MS9yxMVApAxH
         xGqMyPv3ZHscJxcCX71TOKnoKhYmrCBXuyXhrqCmBsnu3bY7yFKK4W7xQxhSlSAZBKha
         AoZg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuZHf9fksQX80Ov3xXAWN5RJvwU9sQ4DbV/Me2gZXNj4VICQFDfb
	iF/jfvo7SpCBTtDlXOfCFvX5VVrjJTnJvhKNhljWOu4FAI1Bz76SxqzPw4Sl4BX8cc2axoQ5WW9
	JrWuAUSEIpmoYdlrfTAId7as7Yq6mmvSNaUbLJYH4jOPPZh24hlObjc5f1QYK97Y=
X-Received: by 2002:a17:906:d1c4:: with SMTP id bs4mr17874426ejb.205.1551210026810;
        Tue, 26 Feb 2019 11:40:26 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYZISKf0NrHZZglD0B/zTS208bxQqdGUI4RImYqkvKempgyC7S1AovYhIJsGEky0D+AvLlk
X-Received: by 2002:a17:906:d1c4:: with SMTP id bs4mr17874392ejb.205.1551210025685;
        Tue, 26 Feb 2019 11:40:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551210025; cv=none;
        d=google.com; s=arc-20160816;
        b=WDDDkB6wCwULK4CCMDnWkQp0GaSHsNvBJjWkbr/BR//08Y0MxNXqVNDBdetHJ362EL
         G4AWr2okbbVSgSBuA+CyI92/CwKpOG19fAzGnIUoDdxpI4N4HtvQmTi+GhfTyvq59t9L
         75kdTxqbLfLPvhJKmwgBsgDQ+sWKTrL8baOgSn01oEtFHAaQyrWpykBCDLYKyWOTVNQC
         T7j+uYHJFq+P90us9/pjZgNhWlELYq6Z04YZcorNT91TAc3M2CCV9ws8jGrXCIAfpbTf
         EfvkiR4YjojRw8mUf7V++wb6q2byMGtZKViL9/CoUOvizbfltwdxMfVYtkfWf9tVeu65
         ko7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=AvolvAcxXioNyvTz5UGFY/cvO3UIu3EClNqVmLReyxQ=;
        b=nwu1ns+spmDK2K7NKFShPZo32fZjWuRkd3BBAAMCczNmp3KIwOSkDTe8LzAdu1zB8k
         wqdUgNKMsmtK8jzgWt4tKCl35s240IlLBj6BnSzxmO9vEyuPE4gVySMr7sl8nCN5Hk4h
         O7e+1t3d85ts8YlwptNjWT+nrBnj2b+VAkNOMGRUDKsUPTRAYwUkrn0f+z7+lZPWOzLg
         0GyvIRl7lsSg/9n9iZK0ctHDCmdPXsWZ0Ej5nbOB3+fAkbBZ7s9zzd+P7FDIOC9eNv4a
         beOWStWay3dT8/paMHCjqsRlNXWaPefzVNBfKRsIWf2mVBSG+xOWbQKenhd/AQ/olu6w
         3C+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m12si5001966edm.354.2019.02.26.11.40.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 11:40:25 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id F32DDAEF3;
	Tue, 26 Feb 2019 19:40:24 +0000 (UTC)
Date: Tue, 26 Feb 2019 20:40:24 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/hotplug: fix an imbalance with DEBUG_PAGEALLOC
Message-ID: <20190226194024.GI10588@dhcp22.suse.cz>
References: <20190225191710.48131-1-cai@lca.pw>
 <20190226123521.GZ10588@dhcp22.suse.cz>
 <4d4d3140-6d83-6d22-efdb-370351023aea@lca.pw>
 <20190226142352.GC10588@dhcp22.suse.cz>
 <1551203585.6911.47.camel@lca.pw>
 <20190226181648.GG10588@dhcp22.suse.cz>
 <20190226182007.GH10588@dhcp22.suse.cz>
 <1551208782.6911.51.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1551208782.6911.51.camel@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 26-02-19 14:19:42, Qian Cai wrote:
> On Tue, 2019-02-26 at 19:20 +0100, Michal Hocko wrote:
> > Btw. what happens if the offlined pfn range is removed completely? Is
> > the range still mapped? What kind of consequences does this have?
> 
> Well, the pages are still marked as reserved as well, so it is up to the
> physically memory hotplug handler to free kernel direct mapping pagetable,
> virtual memory mapping pages, and virtual memory mapping pagetable as by design,
> although I have no way to test it.
> 
> > Also when does this tweak happens on a completely new hotplugged memory
> > range?
> 
> I suppose it will call online_pages() which in-turn call
> kernel_unmap_linear_page() which may or may not have the same issue, but I have
> no way to test that path.

It seems you have missed the point of my question. It simply doesn't
make much sense to have offline memory mapped. That memory is not
accessible in general. So mapping it at the offline time is dubious at
best. Also you do not get through the offlining phase on a newly
hotplugged (and not yet onlined) memory. So the patch doesn't look
correct to me and it all smells like the bug you are seeing is a wrong
reporting.

I might be wrong here of course, because I didn't really get to study
the code very deeply. But then the changelog needs to elaborate much
more than, it bugs on so we make it to not bug.

-- 
Michal Hocko
SUSE Labs

