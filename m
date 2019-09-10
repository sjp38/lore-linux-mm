Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7AED8C5AE59
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 17:35:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 33D222168B
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 17:35:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 33D222168B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B8E76B0003; Tue, 10 Sep 2019 13:35:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 842206B0005; Tue, 10 Sep 2019 13:35:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 72FEC6B0007; Tue, 10 Sep 2019 13:35:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0174.hostedemail.com [216.40.44.174])
	by kanga.kvack.org (Postfix) with ESMTP id 4CBF06B0003
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 13:35:42 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id C4B3A8243762
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 17:35:41 +0000 (UTC)
X-FDA: 75919713282.03.error82_88ffaaa006821
X-HE-Tag: error82_88ffaaa006821
X-Filterd-Recvd-Size: 2605
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf20.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 17:35:41 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 72866AD17;
	Tue, 10 Sep 2019 17:35:39 +0000 (UTC)
Date: Tue, 10 Sep 2019 19:35:37 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Toshiki Fukasawa <t-fukasawa@vx.jp.nec.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"adobriyan@gmail.com" <adobriyan@gmail.com>,
	"hch@lst.de" <hch@lst.de>,
	"longman@redhat.com" <longman@redhat.com>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"mst@redhat.com" <mst@redhat.com>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Junichi Nomura <j-nomura@ce.jp.nec.com>
Subject: Re: [RFC PATCH v2] mm: initialize struct pages reserved by
 ZONE_DEVICE driver.
Message-ID: <20190910173537.GB4023@dhcp22.suse.cz>
References: <20190906081027.15477-1-t-fukasawa@vx.jp.nec.com>
 <20190910140107.GD2063@dhcp22.suse.cz>
 <CAPcyv4jkZJLzEDne6W2pEDGB+q96NkkozmhKxybTu1LjnPYY9g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jkZJLzEDne6W2pEDGB+q96NkkozmhKxybTu1LjnPYY9g@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 10-09-19 07:53:17, Dan Williams wrote:
> On Tue, Sep 10, 2019 at 7:01 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Fri 06-09-19 08:09:52, Toshiki Fukasawa wrote:
> > [...]
> > > @@ -5856,8 +5855,6 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
> > >               if (!altmap)
> > >                       return;
> > >
> > > -             if (start_pfn == altmap->base_pfn)
> > > -                     start_pfn += altmap->reserve;
> > >               end_pfn = altmap->base_pfn + vmem_altmap_offset(altmap);
> >
> > Who is actually setting reserve? This is is something really impossible
> > to grep for in the kernle and git grep on altmap->reserve doesn't show
> > anything AFAICS.
> 
> Yes, it's difficult to grep, here is the use in the nvdimm case:
> 
>     https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/nvdimm/pfn_devs.c#n600

Thanks! I am still not sure what the proper fix is but this is a useful
pointer.

-- 
Michal Hocko
SUSE Labs

