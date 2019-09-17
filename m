Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3DFDBC4CECD
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 10:15:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 19CD121852
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 10:15:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 19CD121852
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD8976B0003; Tue, 17 Sep 2019 06:15:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A894C6B0005; Tue, 17 Sep 2019 06:15:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 99F106B0006; Tue, 17 Sep 2019 06:15:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0174.hostedemail.com [216.40.44.174])
	by kanga.kvack.org (Postfix) with ESMTP id 791EE6B0003
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 06:15:23 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 2077A181AC9AE
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 10:15:23 +0000 (UTC)
X-FDA: 75944005326.26.girl04_2ef75b4777a33
X-HE-Tag: girl04_2ef75b4777a33
X-Filterd-Recvd-Size: 1983
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 10:15:22 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8A029AE7F;
	Tue, 17 Sep 2019 10:15:20 +0000 (UTC)
Date: Tue, 17 Sep 2019 12:15:19 +0200
From: Michal Hocko <mhocko@kernel.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Lucian Adrian Grijincu <lucian@fb.com>, linux-mm@kvack.org,
	Souptick Joarder <jrdr.linux@gmail.com>,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Rik van Riel <riel@fb.com>, Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v3] mm: memory: fix /proc/meminfo reporting for
 MLOCK_ONFAULT
Message-ID: <20190917101519.GD1872@dhcp22.suse.cz>
References: <20190913211119.416168-1-lucian@fb.com>
 <20190916152619.vbi3chozlrzdiuqy@box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190916152619.vbi3chozlrzdiuqy@box>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 16-09-19 18:26:19, Kirill A. Shutemov wrote:
> On Fri, Sep 13, 2019 at 02:11:19PM -0700, Lucian Adrian Grijincu wrote:
> > As pages are faulted in MLOCK_ONFAULT correctly updates
> > /proc/self/smaps, but doesn't update /proc/meminfo's Mlocked field.
> 
> I don't think there's something wrong with this behaviour. It is okay to
> keep the page an evictable LRU list (and not account it to NR_MLOCKED).

evictable list is an implementation detail. Having an overview about an
amount of mlocked pages can be important. Lazy accounting makes this
more fuzzy and harder for admins to monitor.

Sure it is not a bug to panic about but it certainly makes life of poor
admins harder.

If there is a pathological THP behavior possible then we should look
into that as well.
-- 
Michal Hocko
SUSE Labs

