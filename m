Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27C31C3A5A2
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 18:26:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CDC7B22D6D
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 18:26:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CDC7B22D6D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=codewreck.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E5BD6B0007; Tue,  3 Sep 2019 14:26:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 795C86B0008; Tue,  3 Sep 2019 14:26:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D48C6B000A; Tue,  3 Sep 2019 14:26:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0131.hostedemail.com [216.40.44.131])
	by kanga.kvack.org (Postfix) with ESMTP id 4F4D66B0007
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 14:26:45 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id DD3E8180AD801
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 18:26:44 +0000 (UTC)
X-FDA: 75894440328.21.fold22_1dbdf4d974a29
X-HE-Tag: fold22_1dbdf4d974a29
X-Filterd-Recvd-Size: 2987
Received: from nautica.notk.org (nautica.notk.org [91.121.71.147])
	by imf29.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 18:26:44 +0000 (UTC)
Received: by nautica.notk.org (Postfix, from userid 1001)
	id 8DA9BC009; Tue,  3 Sep 2019 20:26:42 +0200 (CEST)
Date: Tue, 3 Sep 2019 20:26:27 +0200
From: Dominique Martinet <asmadeus@codewreck.org>
To: linux-mm@kvack.org
Subject: How to use huge pages in drivers?
Message-ID: <20190903182627.GA6079@nautica>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000053, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi ; not quite sure where to ask so will start here...


Some context first. I'm inquiring in the context of mckernel[1], a
lightweight kernel that works next to linux (basically offlines a
few/most cores, reserve some memory and have boot a second OS on that to
run HPC applications).
Being brutally honest here, this is mostly research and anyone here
looking into it will probably scream, but I might as well try not to add
too many more reasons to do so....

One of the mecanisms here is that sometimes we want to access the
mckernel memory from linux (either from the process that spawned the
mckernel side process or from a driver in linux), and to do that we have
mapped the mckernel side virtual memory range to that process so it can
page fault.
The (horrible) function doing that can be found here[2], rus_vm_fault -
sends a message to the other side to identify the physical address
corresponding from what we had reserved earlier and map it quite
manually.

We could know at this point if it had been a huge page (very likely) or
not; I'm observing a huge difference of performance with some
interconnect if I add a huge kludge emulating huge pages here (directly
manipulating the process' page table) so I'd very much like to use huge
pages when we know a huge page has been mapped on the other side.



What I'd like to know is:
 - we know (assuming the other side isn't too bugged, but if it is we're
fucked up anyway) exactly what huge-page-sized physical memory range has
been mapped on the other side, is there a way to manually gather the
pages corresponding and merge them into a huge page?

 - from what I understand that does not seem possible/recommended, the
way to go being to have a userland process get huge pages and pass these
to a device (ioctl or something); but I assume that means said process
needs to keep on running all the time that memory is required?
If the page fault needs to split the page (because the other side handed
a "small" page so we can only map a regular page here), can it be merged
back into a huge page for the next time this physical region is used?


[1] https://github.com/RIKEN-SysSoft/mckernel
[2] https://github.com/RIKEN-SysSoft/mckernel/blob/development/executer/kernel/mcctrl/syscall.c#L538

Any input will be appreciated,
-- 
Dominique Martinet

