Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22C90C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:09:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8D5A212F5
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:09:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8D5A212F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 857248E0003; Mon, 24 Jun 2019 10:09:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 807AF8E0002; Mon, 24 Jun 2019 10:09:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 71D6B8E0003; Mon, 24 Jun 2019 10:09:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 38BB78E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 10:09:54 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d13so20678841edo.5
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 07:09:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=38bHJkNikBc1eCKeH/7ITGyAVwnUPzn0sHQySwixX8Q=;
        b=HYT3LyB8QEuvPAAcAv27Tlvm1Cmcs3nFjakNanM4qWE4NkF6kBNXWdI5xx+3N97ATn
         kA4C6u/V7bHC4jOhNfo7qAsrYU9TDQ6SR25KmhKkCSdv2D6KiFnJsL1xi9vM2623EG1U
         2QXKm65cB/Euj0nf4dyWnL5TKOFrJ5iLbuFk48ci3yO1GkDqQ5e66lD4p7nSpuOG6P5t
         ufJFhFcVSVE8OLaLjEKivKII6361/uR2phCUzN/WF/n45XCRs76A4pU4Kme2XCqtsvHc
         w26oLb2W96lWqsgTn7Tjd1PDtJkYLCNB0SQmEOpGuf/T8cxAkfr7FbJij6sanUStyAom
         sb2A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Gm-Message-State: APjAAAXMi6ZH2MLNMuGey0Mo3SErqYLZ58zHJ1oaK/qyV9VYgJqKmXMh
	IQPL5SZAAB1bVSiHSfLMtLkKjxGA/PUpwBES0kX/2yxaZt54aVdHLUcOD0i7ZrDMWgWwLeM0NpD
	tSP4HVvs8Xzp4WO/WqG/+/iFzsVDKXBBN33zWE+5M5yk+I4sPK4oK6WNEOlQkaFyJ1g==
X-Received: by 2002:aa7:d0cc:: with SMTP id u12mr75150333edo.212.1561385393814;
        Mon, 24 Jun 2019 07:09:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1eiAC9YtVW1w0tnJFtFzUAC5gJRXugahhMHJkHpU6BvTtmymrsGme3QWnr68xpy+y9xc6
X-Received: by 2002:aa7:d0cc:: with SMTP id u12mr75150261edo.212.1561385393189;
        Mon, 24 Jun 2019 07:09:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561385393; cv=none;
        d=google.com; s=arc-20160816;
        b=mtoCrkIqa6omceZJj7A1ztXcguKtUPagwaxhItH3uBB5+rFPDNJbWUhSceEyHuAwuv
         KWcaoBcN+Jc8MvPX/aHDHt77zERZg8k+FK6ae/YmzEm426/m5V4kAlZHXIOb4rtUgZBl
         l4HnfHKiqUeJkx5OUJkegpMhToSBZVNvk1qqpzaMVmPeGLw0/fmEne6UTrWbo/u7rkwZ
         KcQdiWIA5fz6fJb3cNTSS+7eb/YzK9PiGMDBUeFHry2u3iEqSZXcqHlv8eojq+/WGjWL
         JwlSxTZhCovGnfT7Vgz/i/uQCeJYsTtjgGt1o5/w9qxezGEeX8YPNOK/hTlFliFKYtJO
         wIXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=38bHJkNikBc1eCKeH/7ITGyAVwnUPzn0sHQySwixX8Q=;
        b=yyKkDgEIu89nF172DmkoiCsBd2Xab5PfZPBH7okTCDFk7MEyubvoYZZ5Ss5VQTfpJs
         nbMNOwRC89IJaz/nm3zlvD99IwXDgl4Em7BPe8dJz1QhD6bJ3n8QMlE2Qsg4r0XjTJZ+
         NePY7eeNqORdDMcEAzTleDXkiBNntbBTuvpmrO0Y25cbB0bU3E+PiyJQ+TJc62tCtfdX
         B3AEXwMtrCP5D3/NkBhVTzPkmkGFcotbNF1jZvDSDOJju4pfdtMKUKndXgYQRkTIY5hQ
         WV+teQi61rY0vb+YEnkPlrtgHSLwFNkFAB3uXg1CK8R5FbNmgbx3wNKoOCa5Viw/v/mH
         Z/mQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w19si9700590edc.371.2019.06.24.07.09.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 07:09:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 86070AF2C;
	Mon, 24 Jun 2019 14:09:52 +0000 (UTC)
Date: Mon, 24 Jun 2019 15:09:50 +0100
From: Mel Gorman <mgorman@suse.de>
To: Huang Ying <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>, jhladky@redhat.com,
	lvenanci@redhat.com, Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH -mm] autonuma: Fix scan period updating
Message-ID: <20190624140950.GF2947@suse.de>
References: <20190624025604.30896-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190624025604.30896-1-ying.huang@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 10:56:04AM +0800, Huang Ying wrote:
> The autonuma scan period should be increased (scanning is slowed down)
> if the majority of the page accesses are shared with other processes.
> But in current code, the scan period will be decreased (scanning is
> speeded up) in that situation.
> 
> This patch fixes the code.  And this has been tested via tracing the
> scan period changing and /proc/vmstat numa_pte_updates counter when
> running a multi-threaded memory accessing program (most memory
> areas are accessed by multiple threads).
> 

The patch somewhat flips the logic on whether shared or private is
considered and it's not immediately obvious why that was required. That
aside, other than the impact on numa_pte_updates, what actual
performance difference was measured and on on what workloads?

-- 
Mel Gorman
SUSE Labs

