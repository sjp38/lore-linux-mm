Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D328C04AAD
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 17:51:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1778206A3
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 17:51:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1778206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 719D86B0005; Tue,  7 May 2019 13:51:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A3356B0006; Tue,  7 May 2019 13:51:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 544E86B0007; Tue,  7 May 2019 13:51:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 03B5A6B0005
	for <linux-mm@kvack.org>; Tue,  7 May 2019 13:51:37 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n23so15051491edv.9
        for <linux-mm@kvack.org>; Tue, 07 May 2019 10:51:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=QnhL1bOGuZyLGLf3CFAATtCCATwNRzLa5UD+kyH4DkY=;
        b=Cim/cbnqmrrSbbQVARINXl8DT3Y1XiEU/YU5UjdpkB4mlOSj2oyCIv2CBTrryG6Pr9
         5VmEIXxeEfYVcyaEErHs0ErQX7cYLv5e3ZL5QuCB9avQ7qBGoFGMLAZMDR/u5+IWwcyn
         2CFpotD2R1iSqV243ig9p9fs+BzjktF+mkEKRJTEDtOIARNCVmx0b0NTRkThDsSrrZ6S
         gkIe71TLlipqIhM6yyuVpxIqZc41ifZvkX1AeEAxLYHVcN2iDLgVGTT+KwWLtHnSYOgP
         eA2nuAa8PP4p1RtM5arGcCT5R0HTmY8tGcJySLpT4hC/ep0vr66LfDfTCjFWxqCInCOs
         4NRw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWy+OytY7feRGbwZ+VTEkxd31MbjBSs5FD/x+vTSejWI2wim4d4
	QDDAZQNVmlT/DLEn2K8JY9eQb4FLxTPov6Thrm7mwYuHU+oA+quNC4qGK2NZRiwIQ3hlaAt1qmy
	EhtJ3U1cKXxf0Aaq8LGmMupIZ2DcgY+/RnYJUMTaWW8+D7+LQmJfGSgQWZSA9n+c=
X-Received: by 2002:a17:906:d293:: with SMTP id ay19mr25717396ejb.92.1557251496566;
        Tue, 07 May 2019 10:51:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxwT2pXyCXZmVxUaRtohIBjYK2PjWTFkNtSIQF27AQFvgMPjtOb9y3aP9bytEQfYWvu2PnB
X-Received: by 2002:a17:906:d293:: with SMTP id ay19mr25717348ejb.92.1557251495713;
        Tue, 07 May 2019 10:51:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557251495; cv=none;
        d=google.com; s=arc-20160816;
        b=TuACxOl2q18/ci/V//okr1UyHz1pDeBlsL6CHJTId++Nn+NpJNP2jmJGI5vqFZdyqW
         3pQIExYhYruZzO+BUSNcie41tpSV46CZOfL+K6kADTOdDSqEGEyh1DqK68EqpBThKr6J
         TUVUTS2Td+dJRwk8Zw05bLN2pr3JL5wahcnCflbL+U6HdJGefi1NQ6E+FIAYXphHXCc/
         j6VK2Oe0GTTqfqOrjEjOKkHCitFfi/hc9ZEJqh5bLIzflBYyjfNS4retFmBn9G8P+gAG
         d6AbAbkeduT4hbJAWHOlCXLm21/5sc57uambU3y2+BQITgD9sS4kI06wWmJlfwLkqKRc
         UIyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=QnhL1bOGuZyLGLf3CFAATtCCATwNRzLa5UD+kyH4DkY=;
        b=jVr0JYKhundtrO2QEpNgOjPI5aiIXG1WNhSwfDW6ex36hTPhHOvCUh3Wiu6zRcaRSS
         XHa4ifDxt9dx45JICsrdh+diTbRyuxrXDQnh2iKogt+5z2/iOdeqa+4q6O2Y45fTLQZz
         QzP3I7CkAhOmfNPtz9MD9IdYAd84lsvWgumYovhgxRg7eYWInXs97l1CAt3YL7sDYkWG
         fhAnjfZ3VmIdItLr308edFYUQOXHBaor3bFJkQDRzfnE/aXnfSSzL3/vzRgSeUkUzGVo
         YwixyQS/YVsDLcPeYHwRyAEe/KFq6kiJRTz2Wb7Sw3ScxJM5Uwk2mpYJi+yAHmuC9V7D
         ai7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b13si7288966ejj.349.2019.05.07.10.51.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 10:51:35 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 26A7EAEF5;
	Tue,  7 May 2019 17:51:35 +0000 (UTC)
Date: Tue, 7 May 2019 19:51:33 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, Sasha Levin <sashal@kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	stable <stable@vger.kernel.org>,
	Mikhail Zaslonko <zaslonko@linux.ibm.com>,
	Gerald Schaefer <gerald.schaefer@de.ibm.com>,
	Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Pasha Tatashin <Pavel.Tatashin@microsoft.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Sasha Levin <alexander.levin@microsoft.com>,
	linux-mm <linux-mm@kvack.org>
Subject: Re: [PATCH AUTOSEL 4.14 62/95] mm, memory_hotplug: initialize struct
 pages for the full memory section
Message-ID: <20190507175133.GV31017@dhcp22.suse.cz>
References: <20190507053826.31622-1-sashal@kernel.org>
 <20190507053826.31622-62-sashal@kernel.org>
 <CAKgT0Uc8ywg8zrqyM9G+Ws==+yOfxbk6FOMHstO8qsizt8mqXA@mail.gmail.com>
 <CAHk-=win03Q09XEpYmk51VTdoQJTitrr8ON9vgajrLxV8QHk2A@mail.gmail.com>
 <20190507170208.GF1747@sasha-vm>
 <CAHk-=wi5M-CC3CUhmQZOvQE2xJgfBgrgyAxp+tE=1n3DaNocSg@mail.gmail.com>
 <20190507171806.GG1747@sasha-vm>
 <20190507173224.GS31017@dhcp22.suse.cz>
 <20190507173655.GA1403@bombadil.infradead.org>
 <CAHk-=wjFkwKpRGP-MJA6mM6ZOu0aiqtvmqxKR78HHXVd_SwpUg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHk-=wjFkwKpRGP-MJA6mM6ZOu0aiqtvmqxKR78HHXVd_SwpUg@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 07-05-19 10:43:31, Linus Torvalds wrote:
> On Tue, May 7, 2019 at 10:36 AM Matthew Wilcox <willy@infradead.org> wrote:
> >
> > Can we do something with qemu?  Is it flexible enough to hotplug memory
> > at the right boundaries?
> 
> It's not just the actual hotplugged memory, it's things like how the
> e820 tables were laid out for the _regular_ non-hotplug stuff too,
> iirc to get the cases where something didn't work out.
> 
> I'm sure it *could* be emulated, and I'm sure some hotplug (and page
> poison errors etc) testing in qemu would be lovely and presumably some
> people do it, but all the cases so far have been about odd small
> special cases that people didn't think of and didn't hit. I'm not sure
> the qemu testing would think of them either..

Yes, this is exactly my point. It would be great to have those odd small
special cases that we have met already available though. For a
regression testing for them at least.
-- 
Michal Hocko
SUSE Labs

