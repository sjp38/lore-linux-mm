Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD7DBC433EF
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 11:01:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8877A206A1
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 11:01:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8877A206A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0AB156B0005; Mon,  9 Sep 2019 07:01:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 05CB86B0006; Mon,  9 Sep 2019 07:01:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB2FE6B0007; Mon,  9 Sep 2019 07:01:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0028.hostedemail.com [216.40.44.28])
	by kanga.kvack.org (Postfix) with ESMTP id CA56C6B0005
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 07:01:39 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 67F76824CA16
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 11:01:39 +0000 (UTC)
X-FDA: 75915091518.13.jump17_82cee6e9ec508
X-HE-Tag: jump17_82cee6e9ec508
X-Filterd-Recvd-Size: 4189
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf13.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 11:01:38 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 618F8AD44;
	Mon,  9 Sep 2019 11:01:37 +0000 (UTC)
Date: Mon, 9 Sep 2019 13:01:36 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, l.roehrs@profihost.ag,
	cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	Vlastimil Babka <vbabka@suse.cz>
Subject: Re: lot of MemAvailable but falling cache and raising PSI
Message-ID: <20190909110136.GG27159@dhcp22.suse.cz>
References: <4b4ba042-3741-7b16-2292-198c569da2aa@profihost.ag>
 <20190905114022.GH3838@dhcp22.suse.cz>
 <7a3d23f2-b5fe-b4c0-41cd-e79070637bd9@profihost.ag>
 <e866c481-04f2-fdb4-4d99-e7be2414591e@profihost.ag>
 <20190909082732.GC27159@dhcp22.suse.cz>
 <1d9ee19a-98c9-cd78-1e5b-21d9d6e36792@profihost.ag>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1d9ee19a-98c9-cd78-1e5b-21d9d6e36792@profihost.ag>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[Cc Vlastimil - logs are http://lkml.kernel.org/r/1d9ee19a-98c9-cd78-1e5b-21d9d6e36792@profihost.ag]

On Mon 09-09-19 10:54:21, Stefan Priebe - Profihost AG wrote:
> Hello Michal,
> 
> Am 09.09.19 um 10:27 schrieb Michal Hocko:
> > On Fri 06-09-19 12:08:31, Stefan Priebe - Profihost AG wrote:
> >> These are the biggest differences in meminfo before and after cached
> >> starts to drop. I didn't expect cached end up in MemFree.
> >>
> >> Before:
> >> MemTotal:       16423116 kB
> >> MemFree:          374572 kB
> >> MemAvailable:    5633816 kB
> >> Cached:          5550972 kB
> >> Inactive:        4696580 kB
> >> Inactive(file):  3624776 kB
> >>
> >>
> >> After:
> >> MemTotal:       16423116 kB
> >> MemFree:         3477168 kB
> >> MemAvailable:    6066916 kB
> >> Cached:          2724504 kB
> >> Inactive:        1854740 kB
> >> Inactive(file):   950680 kB
> >>
> >> Any explanation?
> > 
> > Do you have more snapshots of /proc/vmstat as suggested by Vlastimil and
> > me earlier in this thread? Seeing the overall progress would tell us
> > much more than before and after. Or have I missed this data?
> 
> I needed to wait until today to grab again such a situation but from
> what i know it is very clear that MemFree is low and than the kernel
> starts to drop the chaches.
> 
> Attached you'll find two log files.

$ grep pgsteal_kswapd vmstat | uniq -c
   1331 pgsteal_kswapd 37142300
$ grep pgscan_kswapd vmstat | uniq -c
   1331 pgscan_kswapd 37285092

kswapd hasn't scanned nor reclaimed any memory throughout the whole
collected time span. On the other hand we can see direct reclaim active.
But we can see quite some direct reclaim activity:
$ awk '/pgsteal_direct/ {val=$2+0; ln++; if (last && val-last > 0) {printf("%d %d\n", ln, val-last)} last=val}' vmstat | head
17 1058
18 9773
19 1036
24 11413
49 1055
50 1050
51 17938
52 22665
53 29400
54 5997

So there is a steady source of the direct reclaim which is quite
unexpected considering the background reclaim is inactive. Or maybe it
is blocked not able to make a forward progress.

780513 pages has been reclaimed which is 3G worth of memory which
matches the dropdown you are seeing AFAICS.

$ grep allocstall_dma32 vmstat | uniq -c
   1331 allocstall_dma32 0
$ grep allocstall_normal vmstat | uniq -c
   1331 allocstall_normal 39

no direct reclaim invoked for DMA32 and Normal zones. But Movable zone
seems the be the source of the direct reclaim
awk '/allocstall_movable/ {val=$2+0; ln++; if (last && val-last > 0) {printf("%d %d\n", ln, val-last)} last=val}' vmstat | head
17 1
18 9
19 1
24 10
49 1
50 1
51 17
52 20
53 28
54 5

and that matches moments when we reclaimed memory. There seems to be a
steady THP allocations flow so maybe this is a source of the direct
reclaim?
-- 
Michal Hocko
SUSE Labs

