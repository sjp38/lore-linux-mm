Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A44CBC00307
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 11:02:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 81F7D206BB
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 11:02:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81F7D206BB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 00D606B0003; Fri,  6 Sep 2019 07:02:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EFF9F6B0006; Fri,  6 Sep 2019 07:02:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DEF2E6B0007; Fri,  6 Sep 2019 07:02:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0229.hostedemail.com [216.40.44.229])
	by kanga.kvack.org (Postfix) with ESMTP id BD36C6B0003
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 07:02:36 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 58D75824CA35
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 11:02:36 +0000 (UTC)
X-FDA: 75904207512.05.name58_6e01532ee3832
X-HE-Tag: name58_6e01532ee3832
X-Filterd-Recvd-Size: 2304
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 11:02:35 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6B409AF2C;
	Fri,  6 Sep 2019 11:02:34 +0000 (UTC)
Date: Fri, 6 Sep 2019 13:02:33 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>
Subject: Re: [RFC PATCH] mm, oom: disable dump_tasks by default
Message-ID: <20190906110233.GE14491@dhcp22.suse.cz>
References: <20190903144512.9374-1-mhocko@kernel.org>
 <af0703d2-17e4-1b8e-eb54-58d7743cad60@i-love.sakura.ne.jp>
 <20190904054004.GA3838@dhcp22.suse.cz>
 <alpine.DEB.2.21.1909041302290.95127@chino.kir.corp.google.com>
 <12bcade2-4190-5e5e-35c6-7a04485d74b9@i-love.sakura.ne.jp>
 <20190905140833.GB3838@dhcp22.suse.cz>
 <20ec856d-0f1e-8903-dbe0-bbc8b7a1847a@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20ec856d-0f1e-8903-dbe0-bbc8b7a1847a@i-love.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 06-09-19 19:46:10, Tetsuo Handa wrote:
> On 2019/09/05 23:08, Michal Hocko wrote:
> > On Thu 05-09-19 22:39:47, Tetsuo Handa wrote:
> > [...]
> >> There is nothing that prevents users from enabling oom_dump_tasks by sysctl.
> >> But that requires a solution for OOM stalling problem.
> > 
> > You can hardly remove stalling if you are not reducing the amount of
> > output or get it into a different context. Whether the later is
> > reasonable is another question but you are essentially losing "at the
> > OOM event state".
> > 
> 
> I am not losing "at the OOM event state". Please find "struct oom_task_info"
> (for now) embedded into "struct task_struct" which holds "at the OOM event state".
> 
> And my patch moves "printk() from dump_tasks()" from OOM context to WQ context.

Workers might be blocked for unbound amount of time and so this
information might be printed late.
-- 
Michal Hocko
SUSE Labs

