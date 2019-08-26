Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99F23C3A5A5
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 07:33:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 69CFC20874
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 07:33:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 69CFC20874
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1BF376B053B; Mon, 26 Aug 2019 03:33:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 171676B053D; Mon, 26 Aug 2019 03:33:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0AE186B053E; Mon, 26 Aug 2019 03:33:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0222.hostedemail.com [216.40.44.222])
	by kanga.kvack.org (Postfix) with ESMTP id DF1056B053B
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 03:33:35 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 65D86181AC9AE
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 07:33:35 +0000 (UTC)
X-FDA: 75863763990.04.knife16_769ca668f1762
X-HE-Tag: knife16_769ca668f1762
X-Filterd-Recvd-Size: 3228
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 07:33:34 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 619A4AEBF;
	Mon, 26 Aug 2019 07:33:33 +0000 (UTC)
Date: Mon, 26 Aug 2019 09:33:32 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Roman Gushchin <guro@fb.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Kernel Team <Kernel-team@fb.com>
Subject: Re: [PATCH v3 0/3] vmstats/vmevents flushing
Message-ID: <20190826073332.GA7659@dhcp22.suse.cz>
References: <20190819230054.779745-1-guro@fb.com>
 <20190822162709.fa100ba6c58e15ea35670616@linux-foundation.org>
 <20190823003347.GA4252@castle>
 <20190824135339.46da90b968d92529641b3ed2@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190824135339.46da90b968d92529641b3ed2@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat 24-08-19 13:53:39, Andrew Morton wrote:
> On Fri, 23 Aug 2019 00:33:51 +0000 Roman Gushchin <guro@fb.com> wrote:
> 
> > On Thu, Aug 22, 2019 at 04:27:09PM -0700, Andrew Morton wrote:
> > > On Mon, 19 Aug 2019 16:00:51 -0700 Roman Gushchin <guro@fb.com> wrote:
> > > 
> > > > v3:
> > > >   1) rearranged patches [2/3] and [3/3] to make [1/2] and [2/2] suitable
> > > >   for stable backporting
> > > > 
> > > > v2:
> > > >   1) fixed !CONFIG_MEMCG_KMEM build by moving memcg_flush_percpu_vmstats()
> > > >   and memcg_flush_percpu_vmevents() out of CONFIG_MEMCG_KMEM
> > > >   2) merged add-comments-to-slab-enums-definition patch in
> > > > 
> > > > Thanks!
> > > > 
> > > > Roman Gushchin (3):
> > > >   mm: memcontrol: flush percpu vmstats before releasing memcg
> > > >   mm: memcontrol: flush percpu vmevents before releasing memcg
> > > >   mm: memcontrol: flush percpu slab vmstats on kmem offlining
> > > > 
> > > 
> > > Can you please explain why the first two patches were cc:stable but not
> > > the third?
> > > 
> > > 
> > 
> > Because [1] and [2] are fixing commit 42a300353577 ("mm: memcontrol: fix
> > recursive statistics correctness & scalabilty"), which has been merged into 5.2.
> > 
> > And [3] fixes commit fb2f2b0adb98 ("mm: memcg/slab: reparent memcg kmem_caches
> > on cgroup removal"), which is in not yet released 5.3, so stable backport isn't
> > required.
> 
> OK, thanks.  Patches 1 & 2 are good to go but I don't think that #3 has
> had suitable review and I have a note here that Michal has concerns
> with it.

My concern was http://lkml.kernel.org/r/20190814113242.GV17933@dhcp22.suse.cz
so more of a code style kinda thing. Roman has chosen to stay with his
original form and added a comment that NR_SLAB_{UN}RECLAIMABLE are
magic. This is something I can live with even though I would have
preferred it a different way. Nothing serious enough to Nack or insist.
-- 
Michal Hocko
SUSE Labs

