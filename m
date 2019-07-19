Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E61F8C76188
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 09:13:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B250D2173B
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 09:13:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B250D2173B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 535C16B0005; Fri, 19 Jul 2019 05:13:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E7FA6B0008; Fri, 19 Jul 2019 05:13:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D5A28E0001; Fri, 19 Jul 2019 05:13:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E3E566B0005
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 05:13:15 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id e9so10520608edv.18
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 02:13:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Xw4ivLOt/nv03cA/8fBLfxH29iQYmMmNIruF8LODt3c=;
        b=pe4h/c5ldEnswGjabx6Zrqel+I7BIuGwO6tz5Tc1yrmGsI3wj4sbVKkAQXNaATQo0P
         EQgRJT/otqP3w10XjgvqBHrmSltJQUf98h7/Pxhf9Gi6h2Q4GIejxomT+t0+hoyhA4fY
         U7KZdqLXG3tLIcc4eWudaE7XKRkX1gMEUs1tSDoRwxIa+ZANCbjC9Vb2vrLs+1IkxvQA
         5NxruK+H2G6GrbH+NLOIsSr1QGXJyKbllSxLSJsAX+4Dhn34BRE5HNjyZBdvZq+OsA+2
         tXeRBTuPvCyczE4dhl6S+kM/4S+QtFmJX23VqpFpY639277yRm4k27mznlut87SFa5uS
         b7bw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUgyKjpb95TldvtirxkjghZOhYRF3cYHwYb8c/fzGek8EL0IUKU
	244M3taCfmY5QeA2l1i8oZR8nlzg9qgtncGSzaVA28QAXHq2DkLa5DdjvPGAEw5ZxbnnZ5pWHx7
	YGqcrTDbtsQBy7wL56bRNxBqG4rhjltNQdYOzoQ76ZFZc/GG392IW0oEnob85frk=
X-Received: by 2002:a17:906:154d:: with SMTP id c13mr40695148ejd.208.1563527595454;
        Fri, 19 Jul 2019 02:13:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx37eei5eZfJS98UpfZuKy17rZyFI/DoQwnZ0fmcNDguzjtWNtUEHIErZpt18nVGSjDUe96
X-Received: by 2002:a17:906:154d:: with SMTP id c13mr40695108ejd.208.1563527594748;
        Fri, 19 Jul 2019 02:13:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563527594; cv=none;
        d=google.com; s=arc-20160816;
        b=hw9zHu5+S2oO/YiMUltRYHKIbdI4GR6ziUUvgH+Ouwo5sGd3a2ITKYnxpaUhCgcOMW
         XiLnGQ9/wtx4J8XZsfJMt/LbvolsujIyrws0ubBZuY9NdTCEJpJHyLIVfYV8YN955lY7
         h1kk+Kukej/YfgjYr0oIGsMze4QXOyUJs63VA9f2sY2elDnOEWbv0IZ/x//fgrKX+mud
         jUCLNQqolXf3DN1zvtiMAgZKk2IKYlsdweN8GjObGlGGelAf2PecEg5/HsZSL/BNPrxI
         vEXNhXfYQdKGrKyhsWQ3gyH6sD/EF0aZ5Geq0hgPNKsYNcpNE3v8dRbdne+AFyNEKPGU
         30nA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Xw4ivLOt/nv03cA/8fBLfxH29iQYmMmNIruF8LODt3c=;
        b=QEh3f/W5CEjZJ63Py4Fpz7Ea0aB0MAujni9jVFz2asRS7KTB2dQ4kbi4udBcx0n3rK
         ENgXNPwVCuT4923EYZE1K6+t0dINsH0OD4b/ycGL9rwdTmxkCqhZ1qjl25xLj+vcng+4
         YlirMn1L99eKer5EwUDEJu3hevzAlVv3EuC6CwhpPCizPdDaNXCWFPvUCMUR0/j6IK8y
         jKAUZlaZfEwH8P9PewuPBH2yef0z9kGnBlfUPDqnyQZxxPgp0/7KAEYC51P5tkcrvgps
         zck3MsZG24yEV0kx/AAHjaK9OG7g1Al4U+1IUutEmCL667QWjm206zL3mhZpHz39gruq
         2UVw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f6si898967edd.395.2019.07.19.02.13.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 02:13:14 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 60C7EAFB7;
	Fri, 19 Jul 2019 09:13:14 +0000 (UTC)
Date: Fri, 19 Jul 2019 11:13:13 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Oscar Salvador <osalvador@suse.de>
Subject: Re: [PATCH v1] drivers/base/node.c: Simplify
 unregister_memory_block_under_nodes()
Message-ID: <20190719091313.GR30461@dhcp22.suse.cz>
References: <20190718142239.7205-1-david@redhat.com>
 <20190719084239.GO30461@dhcp22.suse.cz>
 <eff19965-f280-6124-8fc5-56e3101f67cb@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <eff19965-f280-6124-8fc5-56e3101f67cb@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 19-07-19 11:05:51, David Hildenbrand wrote:
> On 19.07.19 10:42, Michal Hocko wrote:
> > On Thu 18-07-19 16:22:39, David Hildenbrand wrote:
> >> We don't allow to offline memory block devices that belong to multiple
> >> numa nodes. Therefore, such devices can never get removed. It is
> >> sufficient to process a single node when removing the memory block.
> >>
> >> Remember for each memory block if it belongs to no, a single, or mixed
> >> nodes, so we can use that information to skip unregistering or print a
> >> warning (essentially a safety net to catch BUGs).
> > 
> > I do not really like NUMA_NO_NODE - 1 thing. This is yet another invalid
> > node that is magic. Why should we even care? In other words why is this
> > patch an improvement?
> 
> Oh, and to answer that part of the question:
> 
> We no longer have to iterate over each pfn of a memory block to be removed.

Is it possible that we are overzealous when unregistering syfs files and
we should simply skip the pfn walk even without this change?

-- 
Michal Hocko
SUSE Labs

