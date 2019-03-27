Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED559C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 00:34:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B03822075E
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 00:34:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B03822075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 473E06B0007; Tue, 26 Mar 2019 20:34:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 423D46B0008; Tue, 26 Mar 2019 20:34:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A06E6B000A; Tue, 26 Mar 2019 20:34:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id DB9466B0007
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 20:34:33 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 4so3190078plb.5
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 17:34:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Uy7YzdG3J8PZm5GnndfQwevs8X4LwHClJyqEKK5HNqQ=;
        b=JrR0JItNOuXmkmHBfEZ9ZwDuyvQOK+dMSMZSkTDIVYEpCDHpBH2y8rW7XBbukmKlUU
         tT40XAuu96bJ+Nf7N6g5AO7bPCTfyuD8roDVI6O8FG6wF5LBcuZo7yAlMMDZLdWHLaq7
         +zcEPa8O0LvJTIU6dEGi82fvlIYeDtXuqpKm5Kf2EuHBkBKEsx+Fh4bRaLcI/0+9ocOY
         zmdVAPnepClEJ0tZUSeFlOpj2yw3C4MIG9oT6MQqnghv1cTmsaIt+YoQUfQNRczh4d9C
         VO9ZcL/lBQtq/VAC/v8l0FZPREpqwsaR0PgYG/+E7cObmdA70s44KYsIhT/k9eWEgrsc
         /rYw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 134.134.136.31 as permitted sender) smtp.mailfrom=kbusch@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWRnRexPv20yuWf4oSuK8B7WgxJLDJkzV0hNHptxYOWdgrzrE2V
	u27xoaq/kDHaWJT3x8GwBGOW7vCBGEnC7heDcAdcwVscA2C6gNSk/sN8j2tVKEglaz9dCbPwHzM
	PXF4chOJQsdNyO5L9VJZD5tm82ayALnAvkH/WskHnbqKCY+XD2/zWkBlK59URDy0=
X-Received: by 2002:aa7:8615:: with SMTP id p21mr9255418pfn.98.1553646873548;
        Tue, 26 Mar 2019 17:34:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwrU+6v71bd60kg2aC2LhZp+hA/cl0ueRw9JO0SyoaPEnDHZs3wntr+8Yx7fEwqsltwUZmO
X-Received: by 2002:aa7:8615:: with SMTP id p21mr9255357pfn.98.1553646872736;
        Tue, 26 Mar 2019 17:34:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553646872; cv=none;
        d=google.com; s=arc-20160816;
        b=u6WbbiPVOgpMGX2869njUaQJ4JBLG3HXT0HUrNfE4wPmt/IYTQhMXgUWGEji8izbiP
         ruz6ECWZHJqXDy6nSxQrEq7KluQnJVHEH/d8uFYd0lu6Jj77xDTeyTPImAH3H6WcNrsX
         YdcsC4op3XgiDoJjfr4S+1gGoCCvShnkLSaCynkIIjr0HXevlx91zqgx9Sw0xfee4z3R
         gdOuMV3J2Ncqs0BnCLHMsDRis42GXcDSlLFehS4QX4SYDpU9sjCtvbMtAVZBLWB2PpQu
         FZVLbRPgk3QQP7o41kpjLH/8JCqYj6QWQUmTVSpJScp6WiR/q2EPzwjq+bHbBMw6TIC1
         KlXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Uy7YzdG3J8PZm5GnndfQwevs8X4LwHClJyqEKK5HNqQ=;
        b=sPdMRDcp28DE9OXC5iTM924Gu7iXCkc/8I5F4+YCAu1Lw5xSdIo5AEj03rUtRlj6Iz
         vtPJJNve/GdlSYHfIz7VeICFfk6y9MXlcG4CoATTaA44b26E7KT3c5EzmTqxxLVlGPB+
         ycQdv/cPXzPzIFtlcTi8muFSJwWbqBEbgj3kNbvUBW6kHRkbp4+FnVLIH31V9CXVhLKG
         cmEz5T6pazfwgVOkIVpF65+U355PqRwaNRfvZa5HRAlktDNg5VJstMO8jzwJYTCgseym
         YZijwNFfck9pNrnRFgn3ePH8hPVQ3gJEzYj8cyFzmtJdU0jvj4K9xpTpBIPJ6Ls2ehJQ
         h7Ug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 134.134.136.31 as permitted sender) smtp.mailfrom=kbusch@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id d6si17147578pfg.66.2019.03.26.17.34.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 17:34:32 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 134.134.136.31 as permitted sender) smtp.mailfrom=kbusch@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Mar 2019 17:34:32 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,274,1549958400"; 
   d="scan'208";a="130458805"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by orsmga006.jf.intel.com with ESMTP; 26 Mar 2019 17:34:30 -0700
Date: Tue, 26 Mar 2019 18:35:41 -0600
From: Keith Busch <kbusch@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mhocko@suse.com, mgorman@techsingularity.net, riel@surriel.com,
	hannes@cmpxchg.org, akpm@linux-foundation.org,
	dave.hansen@intel.com, keith.busch@intel.com,
	dan.j.williams@intel.com, fengguang.wu@intel.com, fan.du@intel.com,
	ying.huang@intel.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 06/10] mm: vmscan: demote anon DRAM pages to PMEM node
Message-ID: <20190327003541.GE4328@localhost.localdomain>
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
 <1553316275-21985-7-git-send-email-yang.shi@linux.alibaba.com>
 <20190324222040.GE31194@localhost.localdomain>
 <ceec5604-b1df-2e14-8966-933865245f1c@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ceec5604-b1df-2e14-8966-933865245f1c@linux.alibaba.com>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 25, 2019 at 12:49:21PM -0700, Yang Shi wrote:
> On 3/24/19 3:20 PM, Keith Busch wrote:
> > How do these pages eventually get to swap when migration fails? Looks
> > like that's skipped.
> 
> Yes, they will be just put back to LRU. Actually, I don't expect it would be
> very often to have migration fail at this stage (but I have no test data to
> support this hypothesis) since the pages have been isolated from LRU, so
> other reclaim path should not find them anymore.
> 
> If it is locked by someone else right before migration, it is likely
> referenced again, so putting back to LRU sounds not bad.
> 
> A potential improvement is to have sync migration for kswapd.

Well, it's not that migration fails only if the page is recently
referenced. Migration would fail if there isn't available memory in
the migration node, so this implementation carries an expectation that
migration nodes have higher free capacity than source nodes. And since
your attempting THP's without ever splitting them, that also requires
lower fragmentation for a successful migration.

Applications, however, may allocate and pin pages directly out of that
migration node to the point it does not have so much free capacity or
physical continuity, so we probably shouldn't assume it's the only way
to reclaim pages.

