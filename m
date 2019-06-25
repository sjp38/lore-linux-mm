Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15AD5C48BD5
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 19:00:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CAE2B208CA
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 19:00:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CAE2B208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A0616B0005; Tue, 25 Jun 2019 15:00:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 628748E0003; Tue, 25 Jun 2019 15:00:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4F0248E0002; Tue, 25 Jun 2019 15:00:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id F13366B0005
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 15:00:46 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b3so26796229edd.22
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 12:00:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=IOEiJTOeKmpto/kMH7qP4K/EahNfKYYpVdRK1YANbFg=;
        b=sPYwq3TZKnq0BJ4vZXJpg/nNBLthMITYnR9V/WNSHT3fn8+Uz8S+LGsu6/G4VtTcJI
         E+irRw4/2UhSLQzOJBUndow3ZMkBpfWZ6mtfH3mF2FrOGHUVhQd01tF0yj08SnWvZKUF
         Hk7l1S3ADb1lfQy1EtGS7O5PI/XkOKqTiJ95yK214jppSipV7rUViTSHw5QN5DvVOeLa
         8bMsX1slWR1j2hGggBMU5bZRsEti5E91ptHbFg8sY+IBlYlZ83xhN/IjdpgvcJMaXXst
         R5cuXOoC79+kP9C95j8HLNt7jlzNBaN6/L2Nxt6sPDkyS8wJaulwYMB01VGKXd/4se2C
         Ctdw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVYqkTvFel5tGCIu9ckwkAkIXXqo5lW4440Vvw0oyYuwfFt6I08
	jOoeVgb9TyKHcCHqEhQGN71JQxvpoKVeqJD6syoxDXR1MRnLNKm9NR3gdyTciLJk7UfhvEQuESO
	jHU+9mfSVtF2SeZ73ifB/L1hRKEiyADd+sRhVkPa8pUYOE39uld8yuFtsBLrvmi8=
X-Received: by 2002:a50:9730:: with SMTP id c45mr36000edb.196.1561489246522;
        Tue, 25 Jun 2019 12:00:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwHtMxWhKIyS8GurSuji+2GKqrQqkyLt8yRcf2gg2IYcx7AwlvjgTwPSDoUQkMqL1l8moru
X-Received: by 2002:a50:9730:: with SMTP id c45mr35861edb.196.1561489245496;
        Tue, 25 Jun 2019 12:00:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561489245; cv=none;
        d=google.com; s=arc-20160816;
        b=z9v0VYb9Tn8xQjIun/VA0O4mBAliZ/7VKZXNKGXOaAaO/cO2a6Vs1c6srt4k2CgL0V
         gGlBCrpRQAX8119LzkBibpeFlo5ErRHhv3O+AOl3qtTiPAoJwBHFIudtttm34qrwbU9q
         TIZcFE63gChw0FZi6Di1aceQotl4kNrzuCz0h13DVPWE5tqPus8jiJ+xFdZFKWeHOrgL
         MCsLfy/hv3aSmarFFNs1bLiOBr/NnWakq9EE3rGNRx7m26Cpw8ZEYj0OpAL5/hGuHmqJ
         gnz1BGz8t5ediaQHR2gTlCfxOvmPUczs5p1ht9T9qsCrAegHunyYFEjl8jixGdaCnIOS
         HD/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=IOEiJTOeKmpto/kMH7qP4K/EahNfKYYpVdRK1YANbFg=;
        b=oVLfdPzpr6msu9++RI9Ji+YCXUSSIOayY3bX0CeSauKf/wsmyXiL1F1yHPXzDBcXkv
         oa+Y9ICcx7c8K203BszlcZxJZz4++IDOPwoK2s7+cXRQ5n8HkAt6CIEVKZ0MowTNegzN
         mQFajQ53LxSV/8xNssc98bS53rMiyD463ZDwIdBu07wIx51Zbpgf7eWnLEKlOgLZmsI8
         fGireQ3OpabZKURqwQfxphXr+Y6cC2DLzj5IJdeeh0Js2DWoAASGBW7f6lYgBKEGjFGo
         /0+WKnaWYHDH/FtIvITCGydjlcOql+qTxTerhqu+mh3CbxztrnnImQWgUD9c6hSXiPUV
         5HIg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f58si1238591edf.135.2019.06.25.12.00.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 12:00:45 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6933EAD3A;
	Tue, 25 Jun 2019 19:00:44 +0000 (UTC)
Date: Tue, 25 Jun 2019 21:00:38 +0200
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
Message-ID: <20190625190038.GK11400@dhcp22.suse.cz>
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-6-hch@lst.de>
 <20190620191733.GH12083@dhcp22.suse.cz>
 <CAPcyv4h9+Ha4FVrvDAe-YAr1wBOjc4yi7CAzVuASv=JCxPcFaw@mail.gmail.com>
 <20190625072317.GC30350@lst.de>
 <20190625150053.GJ11400@dhcp22.suse.cz>
 <CAPcyv4j1e5dbBHnc+wmtsNUyFbMK_98WxHNwuD_Vxo4dX9Ce=Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4j1e5dbBHnc+wmtsNUyFbMK_98WxHNwuD_Vxo4dX9Ce=Q@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 25-06-19 11:03:53, Dan Williams wrote:
> On Tue, Jun 25, 2019 at 8:01 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Tue 25-06-19 09:23:17, Christoph Hellwig wrote:
> > > On Mon, Jun 24, 2019 at 11:24:48AM -0700, Dan Williams wrote:
> > > > I asked for this simply because it was not exported historically. In
> > > > general I want to establish explicit export-type criteria so the
> > > > community can spend less time debating when to use EXPORT_SYMBOL_GPL
> > > > [1].
> > > >
> > > > The thought in this instance is that it is not historically exported
> > > > to modules and it is safer from a maintenance perspective to start
> > > > with GPL-only for new symbols in case we don't want to maintain that
> > > > interface long-term for out-of-tree modules.
> > > >
> > > > Yes, we always reserve the right to remove / change interfaces
> > > > regardless of the export type, but history has shown that external
> > > > pressure to keep an interface stable (contrary to
> > > > Documentation/process/stable-api-nonsense.rst) tends to be less for
> > > > GPL-only exports.
> > >
> > > Fully agreed.  In the end the decision is with the MM maintainers,
> > > though, although I'd prefer to keep it as in this series.
> >
> > I am sorry but I am not really convinced by the above reasoning wrt. to
> > the allocator API and it has been a subject of many changes over time. I
> > do not remember a single case where we would be bending the allocator
> > API because of external modules and I am pretty sure we will push back
> > heavily if that was the case in the future.
> 
> This seems to say that you have no direct experience of dealing with
> changing symbols that that a prominent out-of-tree module needs? GPU
> drivers and the core-mm are on a path to increase their cooperation on
> memory management mechanisms over time, and symbol export changes for
> out-of-tree GPU drivers have been a significant source of friction in
> the past.

I have an experience e.g. to rework semantic of some gfp flags and that is
something that users usualy get wrong and never heard that an out of
tree code would insist on an old semantic and pushing us to the corner.

> > So in this particular case I would go with consistency and export the
> > same way we do with other functions. Also we do not want people to
> > reinvent this API and screw that like we have seen in other cases when
> > external modules try reimplement core functionality themselves.
> 
> Consistency is a weak argument when the cost to the upstream community
> is negligible. If the same functionality was available via another /
> already exported interface *that* would be an argument to maintain the
> existing export policy. "Consistency" in and of itself is not a
> precedent we can use more widely in default export-type decisions.
> 
> Effectively I'm arguing EXPORT_SYMBOL_GPL by default with a later
> decision to drop the _GPL. Similar to how we are careful to mark sysfs
> interfaces in Documentation/ABI/ that we are not fully committed to
> maintaining over time, or are otherwise so new that there is not yet a
> good read on whether they can be made permanent.

Documentation/process/stable-api-nonsense.rst
Really. If you want to play with GPL vs. EXPORT_SYMBOL else this is up
to you but I do not see any technical argument to make this particular
interface to the page allocator any different from all others that are
exported to modules.
-- 
Michal Hocko
SUSE Labs

