Return-Path: <SRS0=KlKP=WU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45BD1C3A5A4
	for <linux-mm@archiver.kernel.org>; Sat, 24 Aug 2019 20:53:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 03F35206BB
	for <linux-mm@archiver.kernel.org>; Sat, 24 Aug 2019 20:53:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="lyJvylBq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03F35206BB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 84EC16B04EA; Sat, 24 Aug 2019 16:53:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7FCCD6B04EB; Sat, 24 Aug 2019 16:53:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 712346B04EC; Sat, 24 Aug 2019 16:53:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0016.hostedemail.com [216.40.44.16])
	by kanga.kvack.org (Postfix) with ESMTP id 4DB4A6B04EA
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 16:53:42 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id CFC4B180AD7C1
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 20:53:41 +0000 (UTC)
X-FDA: 75858522642.11.war04_31fca5a2a70f
X-HE-Tag: war04_31fca5a2a70f
X-Filterd-Recvd-Size: 3164
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf29.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 20:53:41 +0000 (UTC)
Received: from localhost.localdomain (c-73-231-172-41.hsd1.ca.comcast.net [73.231.172.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1EB61206BB;
	Sat, 24 Aug 2019 20:53:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1566680020;
	bh=48MYOIZuW/IlepkB5l0hqSY3B/k6uaeqevV8h/HJIN4=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=lyJvylBqRgh0nqZonlg1xatvHCEzJWQIjkGq8fNgwvLd6ZNxMSmv8fr/qxjFrnIzl
	 410SZHRsRSWG6wQJjxK4S1H03KH7TeFF9f25/Npu7w1bp/WbxOOqF1WEa/j+cyTc5O
	 nWwFxni3w4f2v+KgMihb2OZ45d5S/sdqcJyfWUgg=
Date: Sat, 24 Aug 2019 13:53:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Roman Gushchin <guro@fb.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Hocko
 <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team
 <Kernel-team@fb.com>
Subject: Re: [PATCH v3 0/3] vmstats/vmevents flushing
Message-Id: <20190824135339.46da90b968d92529641b3ed2@linux-foundation.org>
In-Reply-To: <20190823003347.GA4252@castle>
References: <20190819230054.779745-1-guro@fb.com>
	<20190822162709.fa100ba6c58e15ea35670616@linux-foundation.org>
	<20190823003347.GA4252@castle>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 23 Aug 2019 00:33:51 +0000 Roman Gushchin <guro@fb.com> wrote:

> On Thu, Aug 22, 2019 at 04:27:09PM -0700, Andrew Morton wrote:
> > On Mon, 19 Aug 2019 16:00:51 -0700 Roman Gushchin <guro@fb.com> wrote:
> > 
> > > v3:
> > >   1) rearranged patches [2/3] and [3/3] to make [1/2] and [2/2] suitable
> > >   for stable backporting
> > > 
> > > v2:
> > >   1) fixed !CONFIG_MEMCG_KMEM build by moving memcg_flush_percpu_vmstats()
> > >   and memcg_flush_percpu_vmevents() out of CONFIG_MEMCG_KMEM
> > >   2) merged add-comments-to-slab-enums-definition patch in
> > > 
> > > Thanks!
> > > 
> > > Roman Gushchin (3):
> > >   mm: memcontrol: flush percpu vmstats before releasing memcg
> > >   mm: memcontrol: flush percpu vmevents before releasing memcg
> > >   mm: memcontrol: flush percpu slab vmstats on kmem offlining
> > > 
> > 
> > Can you please explain why the first two patches were cc:stable but not
> > the third?
> > 
> > 
> 
> Because [1] and [2] are fixing commit 42a300353577 ("mm: memcontrol: fix
> recursive statistics correctness & scalabilty"), which has been merged into 5.2.
> 
> And [3] fixes commit fb2f2b0adb98 ("mm: memcg/slab: reparent memcg kmem_caches
> on cgroup removal"), which is in not yet released 5.3, so stable backport isn't
> required.

OK, thanks.  Patches 1 & 2 are good to go but I don't think that #3 has
had suitable review and I have a note here that Michal has concerns
with it.


