Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 923AEC10F05
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 14:31:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4DB2C20685
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 14:31:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4DB2C20685
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DD6B16B0003; Tue, 26 Mar 2019 10:31:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D85056B0006; Tue, 26 Mar 2019 10:31:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C75296B0007; Tue, 26 Mar 2019 10:31:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 780736B0003
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 10:31:49 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id w27so5349197edb.13
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 07:31:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=+TlxXrh+DiNHVku0SFSOW6+lTQTgWbZKu8A6jsP3y9A=;
        b=i8SgBj5gjxaQ+c01doz7mYDCA9fVou/L8qaDwfef85pVPwaMpZoWO0jiLqmJzCCY6Q
         I+b7F0K7hSktHLUdbldWWR5o1Cvc0KdVboSU6wewzdOm0BGK1NY8SwVHdA+aUtBrqzib
         zlE9WV0NuI0UbctAFzJrTeG4ZwON7aw3CRs63nOpOjAuPOycAK+4omvGDgEzOfUohkUN
         guxO53zNMuh5onUn6ojp2DoOJBj82Jnq2nvmdSnvKzZo1G96nSUljB1AefnWrIddSBI0
         3pVySF1uWuTqCo9Xu5IGQNNnEXFIDLGN3bm4OpRR5au0D5aQ6336WaWjCnnghQbaM9Ud
         Gc0g==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVHpcdx5d1Oeo8A/ijonnOQrkGuUWaSyER5nbb4BLIbKvBBYDy7
	LtuB49UfsLSexWBpxXOEdDJ0kRhMCD7Ef9O0RKdMk+Ci9si3butFW64vrx5GR5PzvJfF3cAoVKu
	T+eh7wfzjA/OjSS9QAwC9G9NYScfnxm9O8trnqWLqoqndkC+hMqn8jKxqO/r2xFM=
X-Received: by 2002:a17:906:b298:: with SMTP id q24mr4168387ejz.62.1553610709028;
        Tue, 26 Mar 2019 07:31:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwWmVqf3jfWx4upG6MJ54IB4GiMZB1dQgDSPwP9MHTqOMLPa0AaBWjslBLKBdZI5jFtdytH
X-Received: by 2002:a17:906:b298:: with SMTP id q24mr4168349ejz.62.1553610708224;
        Tue, 26 Mar 2019 07:31:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553610708; cv=none;
        d=google.com; s=arc-20160816;
        b=n67oRC29YrIBQRkt9ZE2KXzHON/MGR8gWNsRvyzBPtAMkIt78oZe1UwuIFu8WoQUJp
         l3R0kYiCIqC3dF66g1gfDkwkM091ujOQ0f2oAksIC2diNzv81uUZs4pl2aiq01FqOkO3
         vM1nywIJ+4u2Zvvd66mOL01UgXnZCtTgKxHnmg6VFmyn99yKPT5R8gsJuuJhxWFLaJB6
         +XQZPwP06yN9dnKNmIBwTZ1n/s3n72G8wt6VAzySJFhJBpm1TAnOv2jjS/x7L4VxmfQv
         cJxSDPMvnsaOCQfNt56Pz2+zUl8kKU14xdOot5MyAfxY/VS4Li66SZo2wRX0oxHjZH2X
         LoMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=+TlxXrh+DiNHVku0SFSOW6+lTQTgWbZKu8A6jsP3y9A=;
        b=1CSd7Vkvur79zyBkueNZPJxuIQrnRoPs5Ivxq8Zv4DFfQpMROCEaPbJttTcsMRmRmk
         Y4tHsKFs+l2dqlcrMslP2DB+AuO8ZU5o0fhxXWZdQZL42IBjPwl+6A5NBWzBViJcado1
         kyX+5gvnFD/O9Xixc81t/C67iJ4DJNC2Oh4otQHhHwM1fDi4LviQSoXY+AzxDtk8AaW4
         cD+ZF5lQRrk97xJqmKDOgy4pMKmcRmct57L7EfNhdcC1VRuL2YR8lMwgxpMZtoUTlhL+
         44jJSH4LRI4QmAFpUJrJHeFpHjL7tTahA/hbVyxFNxSC3g9/geWI7neuEElgdI4vFqYW
         Vd9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c48si2177547edc.283.2019.03.26.07.31.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 07:31:48 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5FD71B00B;
	Tue, 26 Mar 2019 14:31:47 +0000 (UTC)
Date: Tue, 26 Mar 2019 15:31:45 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Baoquan He <bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, rppt@linux.ibm.com, osalvador@suse.de,
	willy@infradead.org, william.kucharski@oracle.com
Subject: Re: [PATCH v2 2/4] mm/sparse: Optimize sparse_add_one_section()
Message-ID: <20190326143145.GR28406@dhcp22.suse.cz>
References: <20190326090227.3059-1-bhe@redhat.com>
 <20190326090227.3059-3-bhe@redhat.com>
 <20190326092936.GK28406@dhcp22.suse.cz>
 <20190326100817.GV3659@MiWiFi-R3L-srv>
 <20190326101710.GN28406@dhcp22.suse.cz>
 <20190326134522.GB21943@MiWiFi-R3L-srv>
 <20190326140348.GQ28406@dhcp22.suse.cz>
 <20190326141803.GX3659@MiWiFi-R3L-srv>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190326141803.GX3659@MiWiFi-R3L-srv>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 26-03-19 22:18:03, Baoquan He wrote:
> On 03/26/19 at 03:03pm, Michal Hocko wrote:
> > On Tue 26-03-19 21:45:22, Baoquan He wrote:
> > > On 03/26/19 at 11:17am, Michal Hocko wrote:
> > > > On Tue 26-03-19 18:08:17, Baoquan He wrote:
> > > > > On 03/26/19 at 10:29am, Michal Hocko wrote:
> > > > > > On Tue 26-03-19 17:02:25, Baoquan He wrote:
> > > > > > > Reorder the allocation of usemap and memmap since usemap allocation
> > > > > > > is much simpler and easier. Otherwise hard work is done to make
> > > > > > > memmap ready, then have to rollback just because of usemap allocation
> > > > > > > failure.
> > > > > > 
> > > > > > Is this really worth it? I can see that !VMEMMAP is doing memmap size
> > > > > > allocation which would be 2MB aka costly allocation but we do not do
> > > > > > __GFP_RETRY_MAYFAIL so the allocator backs off early.
> > > > > 
> > > > > In !VMEMMAP case, it truly does simple allocation directly. surely
> > > > > usemap which size is 32 is smaller. So it doesn't matter that much who's
> > > > > ahead or who's behind. However, this benefit a little in VMEMMAP case.
> > > > 
> > > > How does it help there? The failure should be even much less probable
> > > > there because we simply fall back to a small 4kB pages and those
> > > > essentially never fail.
> > > 
> > > OK, I am fine to drop it. Or only put the section existence checking
> > > earlier to avoid unnecessary usemap/memmap allocation?
> > 
> > DO you have any data on how often that happens? Should basically never
> > happening, right?
> 
> Oh, you think about it in this aspect. Yes, it rarely happens.
> Always allocating firstly can increase efficiency. Then I will just drop
> it.

OK, let me try once more. Doing a check early is something that makes
sense in general. Another question is whether the check is needed at
all. So rather than fiddling with its placement I would go whether it is
actually failing at all. I suspect it doesn't because the memory hotplug
is currently enforced to be section aligned. There are people who would
like to allow subsection or section unaligned aware hotplug and then
this would be much more relevant but without any solid justification
such a patch is not really helpful because it might cause code conflicts
with other work or obscure the git blame tracking by an additional hop.

In short, if you want to optimize something then make sure you describe
what you are optimizing how it helps.
-- 
Michal Hocko
SUSE Labs

