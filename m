Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B349CC4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 16:39:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7C1622147A
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 16:39:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C1622147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 121208E0026; Wed, 20 Feb 2019 11:39:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A68A8E0002; Wed, 20 Feb 2019 11:39:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E8AE78E0026; Wed, 20 Feb 2019 11:39:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id A41048E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 11:39:25 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id 38so15396844pld.6
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 08:39:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=C9hOs5LIR0iPQ94dmA8TN9ksS+UeYS8Z0azJvbsIZKw=;
        b=PqrfrSwJ3vhP0q2YzH5bQuQTjmh5NKAR2Bz8pi5W7JlmOKj/wDRoaBQLznPbDeP+Ty
         7OywZTumohE7mBKAweojxGMEL03qDAz+jyfJshG4KgwdSdUm+hL4KjTOCRR3LD/BKbjd
         zNZmjAiuFURD2hcLP5QPGvm/5JI9ti0cgz4mvCRbyv2dGd7CcwRCq5jdRQ/URS/ETB7t
         QdKtXk2zBOmmfJloLFwjXfbaFP4gq8GM8/slVxpPBNh4UPPSHCIrBXMGq2LBPFjkp+ov
         O4IBmVP+xPcxBgQMM42bvcPbftY+3IcZa1ESvmwnvKF4MAihDCUTptfSf8kx2i9Kugql
         lSkg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuaPqi6rw1HUadSC0jO7d472H5cM7MadhEqewrX8ZYzD/0lQ8qRp
	vOMo01884rzcWnV7L+R+lvSU+tdxDaoz35M/cpJcpB1b97+XFuS538McPEaPhMLlxkEkR5lKV/x
	g0w2gxWscc0y2t1XIiZjQ/JnmIma0wyZddEYhHBv9WkzRYZ+98AUPBfXQlytTynFJQQ==
X-Received: by 2002:a62:3a47:: with SMTP id h68mr35296855pfa.202.1550680765257;
        Wed, 20 Feb 2019 08:39:25 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbakmZloSX7fohPck0OpgiXNtaYWVH2I0tV8WFmQXWIBuVEmHh2KkdELH6s4J1i3CZD8Iuz
X-Received: by 2002:a62:3a47:: with SMTP id h68mr35296810pfa.202.1550680764419;
        Wed, 20 Feb 2019 08:39:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550680764; cv=none;
        d=google.com; s=arc-20160816;
        b=c0WjGCdnAByXhW8gkVWhZsp7XlfhV5aDDLXqyaRj7iKEn7/pA3VGmk6nFPS+QHWfOG
         9aH3pHksIl6SW8ZtJNiG6th4DvmGm9/djKo4KqRA2APvL91WwxOBrUMT3m90jJkmrHtu
         PVOvoG4wNrEsH12bX1akMoSfIwTLJq9r02ufuTlUb2aSkUF/SbowByMKwc9ebnes4pjl
         Rv53tJgN7av59tIrQ5OkQ7Tl7iKjWTeT147X1UxH5Q3wXtL/wxw52FYM90XfikgBCwxZ
         0hAixs778sUVgeJpq1q/2dWiUndjueeHXyDTIWjkSUjNt6GNqOckxAdHYcN7mkq4OQfQ
         ktbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=C9hOs5LIR0iPQ94dmA8TN9ksS+UeYS8Z0azJvbsIZKw=;
        b=AGKbOxQDbZNulCNyuv6Y64LzAfRHIOZzOSvIoVaSjGK3afFiqS1Ca+tFWzHjeMwD+x
         OHDAPOC1uFcm11kDzjC26MG2FFkTIcLF71mQvQkBmoMeAepOt95Cx7i/XkOXldqODuWv
         00mnUt7rslyvMUWNq+fO4FkR2sPAxnysloxxq129EafXpT+jgL/B8djF0uppQWqlpxsb
         K/Ol5lVSbcryEKKWF+eA2H/n2n10g1qhBiuyAdlBudsCAidgsMAOjq3Zj8OpWTPMzDBL
         7ufNUGhGPKYpOXVm5L0xH4utxLYRe5ZqVxwtL3suVHE0Ux467QUaF6crI7heddtok7xN
         kK9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id s6si11530483plq.160.2019.02.20.08.39.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 08:39:24 -0800 (PST)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 20 Feb 2019 08:39:23 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,391,1544515200"; 
   d="scan'208";a="125905373"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by fmsmga008.fm.intel.com with ESMTP; 20 Feb 2019 08:39:22 -0800
Date: Wed, 20 Feb 2019 09:39:22 -0700
From: Keith Busch <keith.busch@intel.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: William Kucharski <william.kucharski@oracle.com>,
	lsf-pc@lists.linux-foundation.org, Linux-MM <linux-mm@kvack.org>,
	linux-fsdevel@vger.kernel.org, linux-nvme@lists.infradead.org,
	linux-block@vger.kernel.org
Subject: Re: Read-only Mapping of Program Text using Large THP Pages
Message-ID: <20190220163921.GA4451@localhost.localdomain>
References: <379F21DD-006F-4E33-9BD5-F81F9BA75C10@oracle.com>
 <20190220134454.GF12668@bombadil.infradead.org>
 <07B3B085-C844-4A13-96B1-3DB0F1AF26F5@oracle.com>
 <20190220144345.GG12668@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190220144345.GG12668@bombadil.infradead.org>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2019 at 06:43:46AM -0800, Matthew Wilcox wrote:
> What NVMe doesn't have is a way for the host to tell the controller
> "Here's a 2MB sized I/O; bytes 40960 to 45056 are most important to
> me; please give me a completion event once those bytes are valid and
> then another completion event once the entire I/O is finished".
> 
> I have no idea if hardware designers would be interested in adding that
> kind of complexity, but this is why we also have I/O people at the same
> meeting, so we can get these kinds of whole-stack discussions going.

We have two unused PRP bits, so I guess there's room to define something
like a "me first" flag. I am skeptical we'd get committee approval for
that or partial completion events, though.

I think the host should just split the more important part of the transfer
into a separate command. The only hardware support we have to prioritize
that command ahead of others is with weighted priority queues, but we're
missing driver support for that at the moment.

