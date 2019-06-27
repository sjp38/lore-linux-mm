Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9F98C48BD6
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 06:41:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 69BA220843
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 06:41:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 69BA220843
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 00CE38E0003; Thu, 27 Jun 2019 02:41:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EFFBB8E0002; Thu, 27 Jun 2019 02:41:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DEE8F8E0003; Thu, 27 Jun 2019 02:41:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8DD398E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 02:41:09 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id m23so5290701edr.7
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 23:41:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=JqmmJgjjm71fQUdcGGiSYjLqQsBuM9ywnuoEhWHLi3k=;
        b=nltwjmKfJa650qqRfSyvHpNHTqIpH/aTtUR5Xeqm++lAGoJnZGq4/7j7d+oce0AfXq
         rDwG3GpFagi1e5mgkDPYHt9oKBWG6M1pcxUdoFoAuhY94A9PSNeezJa33WD39OifowUC
         Zaq1FprRKoEbTwsO0qCr8Ca6x/k2gNcUXk6PVT98nfoK9zgEYOJ4L7NCGGuBFCKDUvLJ
         Zja1SEuk4mFh47r9yj0LVG1sEZc8aqq79URNKjBIELvidMRabLQHmepnOCEQAkEgb0al
         nNzNdVQ+n+atrWvER5/WLDqc2t8qYC4Vj4ik9O+EgymaVPvj/N97K6wNyYTJKgE+Ind1
         zkTw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVHgzaP5PJf+Mna5xWLYVP7zV0YXXPpyZKOYLFNRtFUEGWftSxB
	tMySnWC7iyzV8Jp01JvDY0Y4mEfUuQU0Hp2YRkd8ETvKIia9/DbGj6GCsKCqhgLl+uo+AQkaEsx
	f310ly7+kYAXhmlUvifU8l+azA+ILkkDbUlswqi8LsoCIkccWp8mTtrypoba3Ky4=
X-Received: by 2002:a17:906:414:: with SMTP id d20mr1619408eja.275.1561617669128;
        Wed, 26 Jun 2019 23:41:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw59uX3J/Dg6BYNzu+nwt/KdWlPj1X5ZAPJ8/sk2mlP6dRFN9VK5F2JAmTHLOojeTC+kxZW
X-Received: by 2002:a17:906:414:: with SMTP id d20mr1619362eja.275.1561617668285;
        Wed, 26 Jun 2019 23:41:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561617668; cv=none;
        d=google.com; s=arc-20160816;
        b=BjqWQdeDUCEmVVjzjYS25V7Y1ROLu3XggSPqt9IBqBTvCnlO+rmtpT5R9ZgrjjaDQH
         c3ODHy1YmDE8eH2b5h0RMgWDTsmVYM8CZKjauVFtHIKE0PzQz4zB/gK/ydwnGhCzBbPn
         iw8Lnoz2gbRaZSfbnzvoNtgAHk6Or4GLMVWZlEtftjOYTgAxiuuG6z397ko+AIzcT68i
         ZVF1SwpxaZ70lpLf3f3Ky2mycb8cki6l8QLGx2Lldd5m6sRgow9h0DVvFVEtauVSmccv
         7vomRcU7ZIaxTn6ib3kC06/Y19Zd4BXO/Ll/fObqvPDf7sBJuBS0zTWVj96d/YPZ1Jmx
         px+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=JqmmJgjjm71fQUdcGGiSYjLqQsBuM9ywnuoEhWHLi3k=;
        b=RrbvIiDdS+AHwDCg6gv1JY+ze+Uk8OShbez/zPbQXPSuDldZVNeCekENPLQpeprmxX
         s2h9/3lpJ+3LCGAf5uyy2+0kQBsw8lKUr/JWcDQG6mtVGljZPEQqSQt5wftJ0W6LszqM
         0R9cYl7vjfECF//v/BjZEfSBEn+6N2L4bYpERnv+LcmaEOc0BdwW+SGI96AIQ1qvjzdK
         XGVa8loC60vVyZC1owMjTV8h/2c4Fn7AsZ+rUR3IF171JdIk0prbzaxxEajmmtwNYRy0
         bS4wKzUzcixpzjSEBALicZSQyAKwoLE3KKXQMkFtdmsTHoVZcsty9RrTX5xaprBXBvsg
         UZSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p6si1125830eda.198.2019.06.26.23.41.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 23:41:08 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4E3F7AFAE;
	Thu, 27 Jun 2019 06:41:07 +0000 (UTC)
Date: Thu, 27 Jun 2019 08:41:06 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	Linux MM <linux-mm@kvack.org>, nouveau@lists.freedesktop.org,
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>,
	linux-nvdimm <linux-nvdimm@lists.01.org>, linux-pci@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 05/22] mm: export alloc_pages_vma
Message-ID: <20190627064106.GC17798@dhcp22.suse.cz>
References: <20190613094326.24093-6-hch@lst.de>
 <20190620191733.GH12083@dhcp22.suse.cz>
 <CAPcyv4h9+Ha4FVrvDAe-YAr1wBOjc4yi7CAzVuASv=JCxPcFaw@mail.gmail.com>
 <20190625072317.GC30350@lst.de>
 <20190625150053.GJ11400@dhcp22.suse.cz>
 <CAPcyv4j1e5dbBHnc+wmtsNUyFbMK_98WxHNwuD_Vxo4dX9Ce=Q@mail.gmail.com>
 <20190625190038.GK11400@dhcp22.suse.cz>
 <CAPcyv4hU13v7dSQpF0WTQTxQM3L3UsHMUhsFMVz7i4UGLoM89g@mail.gmail.com>
 <20190626054645.GB17798@dhcp22.suse.cz>
 <CAPcyv4jLK2F2UHqbwp4bCEiB7tL8sVsr775egKMmJvfZG+W+NQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4jLK2F2UHqbwp4bCEiB7tL8sVsr775egKMmJvfZG+W+NQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 26-06-19 09:14:32, Dan Williams wrote:
> On Tue, Jun 25, 2019 at 10:46 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Tue 25-06-19 12:52:18, Dan Williams wrote:
> > [...]
> > > > Documentation/process/stable-api-nonsense.rst
> > >
> > > That document has failed to preclude symbol export fights in the past
> > > and there is a reasonable argument to try not to retract functionality
> > > that had been previously exported regardless of that document.
> >
> > Can you point me to any specific example where this would be the case
> > for the core kernel symbols please?
> 
> The most recent example that comes to mind was the thrash around
> __kernel_fpu_{begin,end} [1].

Well, this seems more like a disagreement over a functionality that has
reduced its visibility rather than enforcement of a specific API. And I
do agree that the above document states that this is perfectly
legitimate and no out-of-tree code can rely on _any_ functionality to be
preserved.

On the other hand, I am not really surprised about the discussion
because d63e79b114c02 is a mere clean up not explaining why the
functionality should be restricted to GPL only code. So there certainly
is a room for clarification. Especially when the code has been exported
without this restriction in the past (see 8546c008924d5). So to me this
sounds more like a usual EXPORT_SYMBOL{_GPL} mess.

In any case I really do not see any relation to the maintenance cost
here. GPL symbols are not in any sense more stable than any other
exported symbol. They can change at any time. The only maintenance
burden is to update all _in_kernel_ users of the said symbol. Any
out-of-tree code is on its own to deal with this. Full stop.

GPL or non-GPL symbols are solely to define a scope of the usage.
Nothing less and nothing more.

> I referenced that when debating _GPL symbol policy with Jérôme [2].
> 
> [1]: https://lore.kernel.org/lkml/20190522100959.GA15390@kroah.com/
> [2]: https://lore.kernel.org/lkml/CAPcyv4gb+r==riKFXkVZ7gGdnKe62yBmZ7xOa4uBBByhnK9Tzg@mail.gmail.com/

-- 
Michal Hocko
SUSE Labs

