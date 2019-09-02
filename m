Return-Path: <SRS0=2Zku=W5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20151C3A59B
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 07:16:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4FEC214AE
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 07:16:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4FEC214AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B6A56B0003; Mon,  2 Sep 2019 03:16:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 167B26B0006; Mon,  2 Sep 2019 03:16:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 07C636B0007; Mon,  2 Sep 2019 03:16:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0094.hostedemail.com [216.40.44.94])
	by kanga.kvack.org (Postfix) with ESMTP id DB1E26B0003
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 03:16:20 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 7C493180AD7C3
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 07:16:20 +0000 (UTC)
X-FDA: 75889122120.23.air48_546c2cfd29223
X-HE-Tag: air48_546c2cfd29223
X-Filterd-Recvd-Size: 2652
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf11.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 07:16:20 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4F8ABAEF6;
	Mon,  2 Sep 2019 07:16:18 +0000 (UTC)
Date: Mon, 2 Sep 2019 09:16:17 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Thomas Lindroth <thomas.lindroth@gmail.com>
Cc: linux-mm@kvack.org, stable@vger.kernel.org
Subject: Re: [BUG] Early OOM and kernel NULL pointer dereference in 4.19.69
Message-ID: <20190902071617.GC14028@dhcp22.suse.cz>
References: <31131c2d-a936-8bbf-e58d-a3baaa457340@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <31131c2d-a936-8bbf-e58d-a3baaa457340@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun 01-09-19 22:43:05, Thomas Lindroth wrote:
> After upgrading to the 4.19 series I've started getting problems with
> early OOM.

What is the kenrel you have updated from? Would it be possible to try
the current Linus' tree?

> I run a Gentoo system and do large compiles like the chromium browser in a
> v1 memory cgroup. When I build chromium in the memory cgroup the OOM killer
> runs and kills programs outside of the cgroup. This happens even when there
> is plenty of free memory both in and outside of the cgroup.
[...]
> [ 1146.798696] emerge invoked oom-killer: gfp_mask=0x0(), nodemask=(null), order=0, oom_score_adj=0
> [ 1146.798699] emerge cpuset=
> [ 1146.798701] /
> [ 1146.798703]  mems_allowed=0
> [ 1146.798705] CPU: 4 PID: 16719 Comm: emerge Not tainted 4.19.69 #43
> [ 1146.798707] Hardware name: Gigabyte Technology Co., Ltd. Z97X-Gaming G1/Z97X-Gaming G1, BIOS F9 07/31/2015
> [ 1146.798708] Call Trace:
> [ 1146.798713]  dump_stack+0x46/0x60
> [ 1146.798718]  dump_header+0x67/0x28d
> [ 1146.798721]  oom_kill_process.cold.31+0xb/0x1f3
> [ 1146.798723]  out_of_memory+0x129/0x250
> [ 1146.798728]  pagefault_out_of_memory+0x64/0x77
> [ 1146.798732]  __do_page_fault+0x3c1/0x3d0
> [ 1146.798735]  do_page_fault+0x2c/0x123
> [ 1146.798738]  ? page_fault+0x8/0x30
> [ 1146.798740]  page_fault+0x1e/0x30

This is not a memcg oom killer and the oom killer itself is a reaction
to the allocation not making a forward progress. It smells like
something in the page fault path has return ENOMEM leading to
VM_FAULT_OOM. Seeing unexpected SLUB allocation failures would suggest
that something is not really working properly there.
-- 
Michal Hocko
SUSE Labs

