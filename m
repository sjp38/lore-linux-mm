Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2502EC46478
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 06:13:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B292A20836
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 06:13:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B292A20836
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 261D46B0006; Tue,  2 Jul 2019 02:13:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 213A38E0003; Tue,  2 Jul 2019 02:13:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 103658E0002; Tue,  2 Jul 2019 02:13:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B27E36B0006
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 02:13:14 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id s7so18801620edb.19
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 23:13:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Pjll8d+trKGUGefXv3u5NQRPmJ/1KTeJUJJu1x1l4hU=;
        b=tfrL/dGB3wb2sY9vsUA4MuCHOyxedUj8pD0qPEUPtfTuPvWsvjLKAZr1MHrmMndq0a
         gFvJZNqd3Fo6EUn6Rb9pzGnZ71crvsGkOFfSLnUcFgkSfVB4HbScr+zBHEaIzJfblOkC
         d7V9MrRTsb46ankzsYe154J4HCFYFHglmJyqf74mUUNV5qEfgWsiR+ureJ/8fkw1cLnU
         FbptaRAtukVwN+tGu82awLC2vwaojf/Un+HGdp74kshOQ0fLtNh7QlO1zBw2X1L8z9Ha
         KenIPkV2pVzZXbcsqvURAgltyTIcHlYE0t00920iB7RldexrcZKd0Vo9oUDc2gUV7bCL
         wluA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXdlu6nrp9fdPVC3k/VRzw8yjAO/65zy3sgMA+APUZvzx48N/MF
	uLypyBeY/AkxHHwHMOvp0dk2eq9bVHVcqwpb9SI+IH5Xf/5avkXvtN7Nf1dKZ+GSMulbVB3oc7T
	Xjh35Vl+2OyitT4byAVQ3BpI2oTSdoXWJkb5cWEt1fLS/sS60+1sFsf5kdhX+Vb4=
X-Received: by 2002:a50:9167:: with SMTP id f36mr33846136eda.297.1562047994236;
        Mon, 01 Jul 2019 23:13:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxhchX0ja3RPtNfQBV7cSDoHEIg3TuI/Rk0BmpwUoJjZ65T8mxF6Hhdx0g3mFs1VynLo7/N
X-Received: by 2002:a50:9167:: with SMTP id f36mr33846073eda.297.1562047993248;
        Mon, 01 Jul 2019 23:13:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562047993; cv=none;
        d=google.com; s=arc-20160816;
        b=Yi6dh+mjfdlHSFvr0pul+wdXv88HYCnLjtnsHoaiMl8Ex1SNiaRrYEsYaPhy4FmKlL
         2i9YquVKvKEj79XhJ/cWcWqr5MYTDemhtAFkAVZyDNy+mGC4RwdJmmwTQbVw0RAF7b8a
         LV9v7xgDQ+WLG96QrKM0M2+wX4jPRzcfVlyodo8tM2Wn0KgjUyzR3JG/73mcXgzqH/62
         Y0uzfDCFG/KYftuz6qj4kdH2izlhdyt28LqHSjslddo0QjDSYmQ2o6YwJqIf7ET9Mtf/
         P2hA4jeXneUX3ucAwrHOtlDSV2Kh2NwFwEB0lNvyMwfc9AR2xnPnvGOY42ti8QvINFDk
         Q9fA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Pjll8d+trKGUGefXv3u5NQRPmJ/1KTeJUJJu1x1l4hU=;
        b=jnBbZWvnMVv3scq6LN1GcEKKeAAZgiKM7EdgO/Qa98CpksDMTmhHs5XNnU5VrMBR8N
         iL0gLtzz5j73kLI3HXGrWzoTKM/P1Ym/M9EtB2MaDKG0MvtVFC6GfYG2gJFo+D2TkJvM
         1ir/7VqNcrg3ozbVfYkMoowDHAEkqf5hqm/2lzP8JW02gV35hOpAH2tU3BDSacHpR1Yd
         sWkQore0HQqmFtxuVgmdXq2IdTm22QWBTEOqTXJSis7nOF0ouXSU4zo61ZyGC6LEQU0k
         JpMJkD4XIvuEou4g3ECOi8wyb4ABlrzXCe3mWvk8z7ftb7fMNpXHiI0Lmc61SkkovHZJ
         QNuw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b10si8615549ejh.360.2019.07.01.23.13.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 23:13:13 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9A75CB008;
	Tue,  2 Jul 2019 06:13:12 +0000 (UTC)
Date: Tue, 2 Jul 2019 08:13:10 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Alastair D'Silva <alastair@d-silva.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pavel Tatashin <pasha.tatashin@oracle.com>,
	Oscar Salvador <osalvador@suse.de>,
	Mike Rapoport <rppt@linux.ibm.com>, Baoquan He <bhe@redhat.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Logan Gunthorpe <logang@deltatee.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH v2 1/3] mm: Trigger bug on if a section is not found in
 __section_nr
Message-ID: <20190702061310.GA978@dhcp22.suse.cz>
References: <20190626061124.16013-1-alastair@au1.ibm.com>
 <20190626061124.16013-2-alastair@au1.ibm.com>
 <20190626062113.GF17798@dhcp22.suse.cz>
 <d4af66721ea53ce7df2d45a567d17a30575672b2.camel@d-silva.org>
 <20190626065751.GK17798@dhcp22.suse.cz>
 <e66e43b1fdfbff94ab23a23c48aa6cbe210a3131.camel@d-silva.org>
 <20190627080724.GK17798@dhcp22.suse.cz>
 <833b9675bc363342827cb8f7c76ebb911f7f960d.camel@d-silva.org>
 <20190701104658.GA6549@dhcp22.suse.cz>
 <7f0ac9250e6fe6318aaf0685be56b121a978ce1b.camel@d-silva.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7f0ac9250e6fe6318aaf0685be56b121a978ce1b.camel@d-silva.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 02-07-19 14:13:25, Alastair D'Silva wrote:
> On Mon, 2019-07-01 at 12:46 +0200, Michal Hocko wrote:
> > On Fri 28-06-19 10:46:28, Alastair D'Silva wrote:
> > [...]
> > > Given that there is already a VM_BUG_ON in the code, how do you
> > > feel
> > > about broadening the scope from 'VM_BUG_ON(!root)' to
> > > 'VM_BUG_ON(!root
> > > > > (root_nr == NR_SECTION_ROOTS))'?
> > 
> > As far as I understand the existing VM_BUG_ON will hit when the
> > mem_section tree gets corrupted. This is a different situation to an
> > incorrect section given so I wouldn't really mix those two. And I
> > still
> > do not see much point to protect from unexpected input parameter as
> > this
> > is internal function as already pointed out.
> > 
> 
> Hi Michael,
> 
> I was able to hit this problem as the system firmware had assigned the
> prototype pmem device an address range above the 128TB limit that we
> originally supported. This has since been lifted to 2PB with patch
> 4ffe713b7587b14695c9bec26a000fc88ef54895.
> 
> As it stands, we cannot move this range lower as the high bits are
> dictated by the location the card is connected.
> 
> Since the physical address of the memory is not controlled by the
> kernel, I believe we should catch (or at least make it easy to debug)
> the sitution where external firmware allocates physical addresses
> beyond that which the kernel supports.

Just make it clear, I am not against a sanitization. I am objecting to
put it into __section_nr because this is way too late. As already
explained, you already must have a bogus mem_section object in hand.
Why cannot you add a sanity check right there when the memory is added?
Either when the section is registered or even sooner in arch_add_memory.

-- 
Michal Hocko
SUSE Labs

