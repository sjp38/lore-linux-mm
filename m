Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D39C3C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 09:16:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 984312184A
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 09:16:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 984312184A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 377A48E0003; Thu, 28 Feb 2019 04:16:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 325688E0001; Thu, 28 Feb 2019 04:16:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 216DC8E0003; Thu, 28 Feb 2019 04:16:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id BDA548E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 04:16:04 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id j5so8156892edt.17
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 01:16:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=6NrpsrTAZaLHQxEuYMjD2BkUO7lx4XYeLuzKZsPdRcQ=;
        b=ThIm6fW6mM5W2Ul0l29z4uyZuyzbyL39yIXW33NHmifhels7vRm5BF70JcWUSXPBdb
         Yu6Bx2LVT8V+vHl1qi7+no1hvKQMa4GvYm83HOFFdZ7hvSz9MBfNwViPJ/wCC4p2iCBQ
         KXRhLroIGbt88GekHJ3L3BeQnJZhmIIjWrj7fDZ/aDy0lLj6f+edmzNQYhIkVkdrcfQJ
         yjuBT1Ga759/gIM7Y1rfTRWOAV9uCwA3Vl1ARTkE4vZUS5kM0Nb+fgTdj2XXZ7Pc6JCD
         HIhCBMhySguUwXRDCfmAwrszwnZ/JFRGOTWXaIYD9KZ5s7jChV3taxcnVxjns2SuyPVu
         6gmQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUaM+G5Vc29sFOuDHLYNiURrtTQsR4NwuprqGztJbwdX9ZOvjNY
	a+JxYZnLEOq+hhEQ24L95V+tpytQV08q494BHjyhREHlSjm0xP3Tne2iMdn1jKXr1HnAOtFt1hv
	CYYpbPU8kplgJbtv98H9RwQAZh2i3XzB5kpmnKhwz/xuc+5y0BXhuwMMhgDHKZzA=
X-Received: by 2002:a50:b493:: with SMTP id w19mr2160244edd.11.1551345364317;
        Thu, 28 Feb 2019 01:16:04 -0800 (PST)
X-Google-Smtp-Source: APXvYqzsoO1PctpIOtD86DyHScFuO3OZ7YIiIC4Vu3+ZYK3Tv0fEv9SPRknl7cvg8VY1RVh0Sn5I
X-Received: by 2002:a50:b493:: with SMTP id w19mr2160187edd.11.1551345363394;
        Thu, 28 Feb 2019 01:16:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551345363; cv=none;
        d=google.com; s=arc-20160816;
        b=vGfpKGMi5yo1+P0BQSFuTe4YqZ/oWUF+6O4yMNMYbHsQLvcAd0zNeEr/NDy5Xiuv3q
         5VLEmpWs40GWgqfmQzOZnZ87I+RHwTgNujp0NntSIW2WVssHfDuDPo6zYm7na9p55+F3
         2tuCunU3bFhpD02hI2DZisFXAkwAqcWjr+UkjEeG6/ejvLLadikOiYvdfECkOs10pG27
         Y5EX6q+T+E23IAmHnk9ceg6wdxYGTWOtZY8X2GwXcS+nvMY9znuxK1XfekLMo2Eahojg
         vYLA/CJxDyf0fhq7zclCZs4z/bNxuSYQVIYYHcPiKcMhxNPa04uGifoqZkWHN1K7HFc1
         Ns3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=6NrpsrTAZaLHQxEuYMjD2BkUO7lx4XYeLuzKZsPdRcQ=;
        b=GyatuyoFB0IWYxjQ4HzbgA4cGYWNxr7WX1iZkYnpcGKuONeOjn+hHYmcgpMVd+M1B0
         IC6u0YS837HLkmBKVKTHTWwOLUj1N4DE6k9NncvCHk0vOqHXsEBfoDCYq527yrsH6kQS
         8RwIEtEhtBcnp4E8ZRg1V/5Z0C9lPedQB8ACDHH7to3pvJfPPH4rOWXBFdRj05eEAfE8
         yGaT/kSN+++jWtIvrXJPeX5mldmocr3fKuZRFyoaqh9TTE8CwIl65gdXIwVQsy8eq75P
         QZKRM58WvbaKwy0gbB5ORL0Socw1Bl88qg0xeFpRwT+AJ7BhqeR1ycBnysymAw+zRvr0
         K3Mg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gv8si3969083ejb.278.2019.02.28.01.16.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 01:16:03 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C6DA1ACC0;
	Thu, 28 Feb 2019 09:16:02 +0000 (UTC)
Date: Thu, 28 Feb 2019 10:16:02 +0100
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>,
	Oscar Salvador <osalvador@suse.de>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH] mm,memory_hotplug: Unlock 1GB-hugetlb on x86_64
Message-ID: <20190228091602.GU10588@dhcp22.suse.cz>
References: <20190221094212.16906-1-osalvador@suse.de>
 <20190227215109.cpiaheyqs2qdbl7p@d104.suse.de>
 <201cc8d8-953f-f198-bbfe-96470136db68@oracle.com>
 <bb71b68e-dc1b-a4d3-d842-b311535b92a8@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bb71b68e-dc1b-a4d3-d842-b311535b92a8@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 28-02-19 08:38:34, David Hildenbrand wrote:
> On 27.02.19 23:00, Mike Kravetz wrote:
> > On 2/27/19 1:51 PM, Oscar Salvador wrote:
> >> On Thu, Feb 21, 2019 at 10:42:12AM +0100, Oscar Salvador wrote:
> >>> [1] https://lore.kernel.org/patchwork/patch/998796/
> >>>
> >>> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> >>
> >> Any further comments on this?
> >> I do have a "concern" I would like to sort out before dropping the RFC:
> >>
> >> It is the fact that unless we have spare gigantic pages in other notes, the
> >> offlining operation will loop forever (until the customer cancels the operation).
> >> While I do not really like that, I do think that memory offlining should be done
> >> with some sanity, and the administrator should know in advance if the system is going
> >> to be able to keep up with the memory pressure, aka: make sure we got what we need in
> >> order to make the offlining operation to succeed.
> >> That translates to be sure that we have spare gigantic pages and other nodes
> >> can take them.
> >>
> >> Given said that, another thing I thought about is that we could check if we have
> >> spare gigantic pages at has_unmovable_pages() time.
> >> Something like checking "h->free_huge_pages - h->resv_huge_pages > 0", and if it
> >> turns out that we do not have gigantic pages anywhere, just return as we have
> >> non-movable pages.
> > 
> > Of course, that check would be racy.  Even if there is an available gigantic
> > page at has_unmovable_pages() time there is no guarantee it will be there when
> > we want to allocate/use it.  But, you would at least catch 'most' cases of
> > looping forever.
> > 
> >> But I would rather not convulate has_unmovable_pages() with such checks and "trust"
> >> the administrator.
> 
> I think we have the exact same issue already with huge/ordinary pages if
> we are low on memory. We could loop forever.
> 
> In the long run, we should properly detect such issues and abort instead
> of looping forever I guess. But as we all know, error handling in the
> whole offlining part is still far away from being perfect ...

Migration allocation callbacks use __GFP_RETRY_MAYFAIL to not
be disruptive so they do not trigger the OOM killer and rely on somebody
else to pull the trigger instead. This means that if there is no other
activity on the system the hotplug migration would just loop for ever
or until interrupted by the userspace. THe later is important, user
might define a policy when to terminate and keep retrying is not
necessarily a wrong thing. One can simply do
timeout $TIMEOUT echo 0 > $PATH_TO_MEMBLOCK/online

and ENOMEM handling is not important. But I can see how people might
want to bail out early instead. So I do not have a strong opinion here.
We can try to consider ENOMEM from the migration as a hard failure and
bail out and see whether it works in practice.
-- 
Michal Hocko
SUSE Labs

