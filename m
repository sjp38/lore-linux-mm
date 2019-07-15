Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CBAFFC76195
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 15:44:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 82B0D2081C
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 15:44:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 82B0D2081C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 058C96B0003; Mon, 15 Jul 2019 11:44:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F24416B0005; Mon, 15 Jul 2019 11:44:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E13506B0006; Mon, 15 Jul 2019 11:44:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8DCB26B0003
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 11:44:23 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b12so13876110eds.14
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 08:44:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=gbLdq+T3cCN449bgts4AIg06nkIaeeAOi5GxOmlCW3Y=;
        b=YtNscgVkkjS6x/mZMw8d1qxKRg98ky4st7hKgQObedDUu/0SJMYlRCtyPPgGzzPPC7
         WbZpyWhoCgZdA5Qth27bNHKguUdHTW9Fdc0mD9uZOE/aZ181qAnjY2dW+NfJcaAVMvdk
         jZMc/07gZycLHc+a/u3Lur7T1N3pzJl6vEPuDmYKv7+zAdIzdwTXL6Wq2Ad979pF6dMn
         pYH/qzETneI7apbwQTuQRzIpJtAt6+OuTCewHdJB77pYky0Idhq7iBmBB0sHwXyb4736
         b11biXjU9WhzV2swxXz/iY9AHlySL2U5enc/Wal3vbnoLZZouFDME3fDDrLaebRse9mV
         a8kw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jroedel@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=jroedel@suse.de
X-Gm-Message-State: APjAAAXOjfV7GioV6r4c3/0vOmFNrc3mM0xOy7kLvJD9RuXQnBEIqcNo
	B5VDhkdNFsrjX7cUcppz/YNlNIyRTGbWWdkSXiyTcPM2Q/vbUynuu8u3j0gl9HEOBMCxqzQphi5
	iv4JdMXZpmKb0P5Qed6oVuudrN30cJYMvokqUawenuvNG2Su5b8zp7yryjj2N3TiE1A==
X-Received: by 2002:a17:906:2555:: with SMTP id j21mr21429849ejb.231.1563205463129;
        Mon, 15 Jul 2019 08:44:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJTCMQ1HE9Mvh3j01IOcxFawENFTvE46/QBx79wG3ekmPHQkuJY4l6mQGhc3Qp0Uh86xJ7
X-Received: by 2002:a17:906:2555:: with SMTP id j21mr21429785ejb.231.1563205462150;
        Mon, 15 Jul 2019 08:44:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563205462; cv=none;
        d=google.com; s=arc-20160816;
        b=FkxLhl/8NYkqC2WkRG3m6kKGVfyR0glqd5J5CON28L6zYDwbdf1OXc/L1aqhuQEq+4
         YfnOUA192f1GbDkCuOYKJlHNUZCFl9N186WAydUO/R2ObFSH6PACiB2gA/jH2IV5xfqE
         oxTzNk+YiwvovhkXke0Kd9KiWvjhpcODbzcIjnKCmLyIWRKlXGqZGJxnkHsvHjR2tMfA
         T4UDoFVsnwp3nqwSxZNlvo6L7DceNgHskIh5OvY+iw9/8c4+Ds3XfxNJm1apYQrfxhYn
         pWROnGiMpLEdVx3ch8m+U3LTsuDESFGZ4aBimmgEFpRmzMwrwALFg4bb9UMy8Mje4RLM
         0rAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=gbLdq+T3cCN449bgts4AIg06nkIaeeAOi5GxOmlCW3Y=;
        b=VYSzY/nDfn/Bon1Y9IJM8y+zqDEpcE/Ae8Q7blYlQO8Y3QYsrqo+GRym8WlI+lD89r
         ZHDsU9RsrmmUvEPqxF5fOBRZJJRbwfZyG07RESJbpjcsOK82XX8/2uMpwtXWDn3WJgzl
         Oow2cB3zkMq9LRf/rohv9Yr+83iyrgmR2IApm5li7g40zpTIy8od0NvhRWd3eanbP5l8
         XRUcDJmbBtZ5DIr+RGeoV6l+AA2HLimzwHGHT3eCjYYB0oJkR3GobnGvyjndbgo9rHp+
         r/TO1s+wiivcrWubjYWmFYUx2WQJj5WES00EGvBL5cmOnZyL6tb2NI3pCZ29QJ9N4/5W
         i1QQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jroedel@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=jroedel@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h19si11064560ede.279.2019.07.15.08.44.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 08:44:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of jroedel@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jroedel@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=jroedel@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3A3D5AF78;
	Mon, 15 Jul 2019 15:44:21 +0000 (UTC)
Date: Mon, 15 Jul 2019 17:44:18 +0200
From: Joerg Roedel <jroedel@suse.de>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Joerg Roedel <joro@8bytes.org>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 1/3] x86/mm: Check for pfn instead of page in
 vmalloc_sync_one()
Message-ID: <20190715154418.GA13091@suse.de>
References: <20190715110212.18617-1-joro@8bytes.org>
 <20190715110212.18617-2-joro@8bytes.org>
 <alpine.DEB.2.21.1907151508210.1722@nanos.tec.linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1907151508210.1722@nanos.tec.linutronix.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 15, 2019 at 03:08:42PM +0200, Thomas Gleixner wrote:
> On Mon, 15 Jul 2019, Joerg Roedel wrote:
> 
> > From: Joerg Roedel <jroedel@suse.de>
> > 
> > Do not require a struct page for the mapped memory location
> > because it might not exist. This can happen when an
> > ioremapped region is mapped with 2MB pages.
> > 
> > Signed-off-by: Joerg Roedel <jroedel@suse.de>
> 
> Lacks a Fixes tag, hmm?

Yeah, right, the question is, which commit to put in there. The problem
results from two changes:

	1) Introduction of !SHARED_KERNEL_PMD path in x86-32. In itself
	   this is not a problem, and the path was only enabled for
	   Xen-PV.

	2) Huge IORemapings which use the PMD level. Also not a problem
	   by itself, but together with !SHARED_KERNEL_PMD problematic
	   because it requires to sync the PMD entries between all
	   page-tables, and that was not implemented.

Before PTI-x32 was merged this problem did not show up, maybe because
the 32-bit Xen-PV users did not trigger it. But with PTI-x32 all PAE
users run with !SHARED_KERNEL_PMD and the problem popped up.

For the last patch I put the PTI-x32 enablement commit in the fixes tag,
because that was the one that showed up during bisection. But more
correct would probably be

	5d72b4fba40e ('x86, mm: support huge I/O mapping capability I/F')

Or do I miss something?

Regards,

	Joerg


