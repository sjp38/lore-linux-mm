Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3273C48BD7
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 15:00:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9396B2146E
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 15:00:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9396B2146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E9F98E0005; Tue, 25 Jun 2019 11:00:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2982B8E0003; Tue, 25 Jun 2019 11:00:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 160F88E0005; Tue, 25 Jun 2019 11:00:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id BCC208E0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 11:00:56 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id l26so25978159eda.2
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 08:00:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ReoY5Ys0QFAyYbddxHovXoyZK5WdLRLpbgSy97cReTA=;
        b=r1p4eyVn4L72Cj7UioyOuTB0uwVjhNTS47wCp3VA3Dj2XkFMAzHMHEIGvf9oZM3Pdh
         lR8a+y0SzaPIJLqBDeP2gu0ECL8io/YAdpOZ5TH+H/vi9kNvHS173WiMdt3/9eKxoVxa
         +q2+Tk564lscEGFkOmd2bGz0ZxhyxVPZ70sW4oDp41V4HZFlnF7rT4egH42cZdtFEm3Z
         ckzpWL7KmEwCqZg54HAgn2h+KEnNy0eBvFAJb4IUpQsGShGKO+vtoUF3OlU7W376DkIQ
         ZUnsveKtMKht1J1lECP4KlFaLpWH6YcnlsbJkI45W7aZMXwgI4ofnqFGZ7sKxnQ3OLEm
         y9yg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAX9F2FTLV1CsXPVcAnMSsXCadDqWIPbQgO1vQ39g+5qQ/tOW3tN
	dQOJ/C/rIghuhgfvod+tiwK9e0HDPuhzkONxAIoVkJwetPz94EnZTJN9NjDleoLvXoNQZypNcIJ
	UQ3crMxgPECnNNi/bWVQsj2hHeQ2i69iBNUiJSjLrENKor4JHbPAfzzc8sTWcjR0=
X-Received: by 2002:a17:906:1596:: with SMTP id k22mr40220440ejd.102.1561474856052;
        Tue, 25 Jun 2019 08:00:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyXdHTwCg8Lc3L9Vq9RaEFHSZUU5CkgitDgKCkEchhHxWN4gOPwYe2cNLt8RtbVrtJ0ZwyL
X-Received: by 2002:a17:906:1596:: with SMTP id k22mr40220347ejd.102.1561474855084;
        Tue, 25 Jun 2019 08:00:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561474855; cv=none;
        d=google.com; s=arc-20160816;
        b=Tj9mc2WkGS5cRdl7d/qtMsQDOs6yBLUweZbLjDyjfxYKTGYxmkhpFBlrg/FHsI4cFm
         b3CSckGzo24ux5AgGqugrAnfjuu3BNaAOI8EohFsHwNOP+w2GcGOP24EBKauRsaN3iRO
         ofqx+ewY0aA+PwbM5F0+/i7+mPiOZ8eG4JT3jbNq2JHHvTw+Z5l/eAplYjeMYyPpO2TC
         cWzw3J1uld6U0cB8t3x19L3QOiXvv+f37XVrYJJU4ZlxB9QT2rpWgGnIz7rZ+wAkudOX
         uzbaRRGDhq7jF32DAlNW97sG7T02P95x8tLN+OViFy2Is2oNThShfaFzi6eauKROtdoW
         RTqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ReoY5Ys0QFAyYbddxHovXoyZK5WdLRLpbgSy97cReTA=;
        b=LjquHFzb1BOTqYbX6cTC2SNCYYoJQz69oe/eJ+Tk83gdHQJd5tcdcyYfjCjblQIvFs
         LjNYI+VN4J6aM/QbPAS9SGPj4YkmCIL+yJ5RVeS9v89pX/9ZXJ/Sz80WP0KbsYVs/dNL
         YnrsGse4XiD1u30ndPZkJSq1pIevaGC1JB1BMHNb40i57HVVymCgqdHAfCc52WDdMbj0
         qNoNGCL9+e3S+FbGVq3iIWaw+0TGs69RM5IBHioW19WKCC8TqlMOd7OaUv0XSGLG9hBJ
         z5elDwxvskzv57WbsMPHdBT2VDw5kYmeab/uPEWqZ4Bnq0FYWvSs4nZucgPtHXwoyxMY
         1pIg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t51si656296eda.310.2019.06.25.08.00.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 08:00:55 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7BBA5AF4C;
	Tue, 25 Jun 2019 15:00:54 +0000 (UTC)
Date: Tue, 25 Jun 2019 17:00:53 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	Linux MM <linux-mm@kvack.org>, nouveau@lists.freedesktop.org,
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>,
	linux-nvdimm <linux-nvdimm@lists.01.org>, linux-pci@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 05/22] mm: export alloc_pages_vma
Message-ID: <20190625150053.GJ11400@dhcp22.suse.cz>
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-6-hch@lst.de>
 <20190620191733.GH12083@dhcp22.suse.cz>
 <CAPcyv4h9+Ha4FVrvDAe-YAr1wBOjc4yi7CAzVuASv=JCxPcFaw@mail.gmail.com>
 <20190625072317.GC30350@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190625072317.GC30350@lst.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 25-06-19 09:23:17, Christoph Hellwig wrote:
> On Mon, Jun 24, 2019 at 11:24:48AM -0700, Dan Williams wrote:
> > I asked for this simply because it was not exported historically. In
> > general I want to establish explicit export-type criteria so the
> > community can spend less time debating when to use EXPORT_SYMBOL_GPL
> > [1].
> > 
> > The thought in this instance is that it is not historically exported
> > to modules and it is safer from a maintenance perspective to start
> > with GPL-only for new symbols in case we don't want to maintain that
> > interface long-term for out-of-tree modules.
> > 
> > Yes, we always reserve the right to remove / change interfaces
> > regardless of the export type, but history has shown that external
> > pressure to keep an interface stable (contrary to
> > Documentation/process/stable-api-nonsense.rst) tends to be less for
> > GPL-only exports.
> 
> Fully agreed.  In the end the decision is with the MM maintainers,
> though, although I'd prefer to keep it as in this series.

I am sorry but I am not really convinced by the above reasoning wrt. to
the allocator API and it has been a subject of many changes over time. I
do not remember a single case where we would be bending the allocator
API because of external modules and I am pretty sure we will push back
heavily if that was the case in the future.

So in this particular case I would go with consistency and export the
same way we do with other functions. Also we do not want people to
reinvent this API and screw that like we have seen in other cases when
external modules try reimplement core functionality themselves.

Thanks!
-- 
Michal Hocko
SUSE Labs

