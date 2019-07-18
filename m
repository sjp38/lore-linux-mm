Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A448C76191
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 08:44:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 07F0A2173E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 08:44:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 07F0A2173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9AC3F6B000D; Thu, 18 Jul 2019 04:44:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9337E6B000E; Thu, 18 Jul 2019 04:44:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7FB8B8E0001; Thu, 18 Jul 2019 04:44:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 42DEF6B000D
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 04:44:51 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id m23so19532924edr.7
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 01:44:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=UbtuWMaNqNm0A4t0zaxp0854Eypr7g09S/us24n8g24=;
        b=SBiFGgQj9F6/gULpRmPFZfJm1qX580J28VWnJGuD9lZ2cW4Fgu3uoj6ZZUmqrPNriJ
         c9XrH52NSf7pG6ludjvfxvWtQ5xjJFPMZ8+VhJZgYqnwzfZTFr8jGmy+NgBemwVNk+bu
         KRGaMKgWEYO4k4JcYmLBOY/+Vn7DuPnc84Fop03EjmWqcILJjjLu78vcfbZFWgo+Cy9Q
         0Y0nRR6q9qKZi/sRh0kzXW5WmeqjDVH7aDEWwdqDT48PWlMrAE35EFv0QYTL1ba4wISF
         ZWx0M1AORZtXveIakSfIxvLgRzf9W0McyvCZGtnom/lOxtOm9Drohg2MLMNspXETLyvU
         Qvxw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jroedel@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=jroedel@suse.de
X-Gm-Message-State: APjAAAU+PpXfgBeow6JgRNNUdptJDEg98tMVImD/pYuelVypTdhX/W90
	3y9gZ9KKytKlKLn/Sop56MO6gpblqjp35BF4oZed+aOwggk79dOWJL2qCS86HbfT1MrGjYYmLBL
	w/1oLHZrYc0KAU8RMBzRkXP0GIbe1iMIap+lZRR6ZmzP7LqxOz3G/e7lDw7ZKKp3ifw==
X-Received: by 2002:a17:906:4e95:: with SMTP id v21mr34885765eju.105.1563439490844;
        Thu, 18 Jul 2019 01:44:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwLVR6u2KIyrKxovrcC9mXzo1BFAxkTOuZkMo9VqekZzITdUJgJvLE7OWFALjRuBy1YmkLo
X-Received: by 2002:a17:906:4e95:: with SMTP id v21mr34885747eju.105.1563439490253;
        Thu, 18 Jul 2019 01:44:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563439490; cv=none;
        d=google.com; s=arc-20160816;
        b=cfBnqH9quTnOJBusk8BheEIDVPpwvwFM9vGDdy0aEbtKn+I3kymRWC0S1iQcQ3UrFn
         MsCsWmr/oRSvGdIilhfUv0nqot1PjmdmwUmbVefjh2xzQG8WgmwpHwChzNbftyHW5aOx
         4hi5Z4X+rSdQk6GvoDupZSjClDmJwnvQaukcIyRo7HRLbXOj0ytytT98aXAsxY51MkMH
         /uxlQzqetdykz9BeNzQUjbPl9/UHDGBiQXOuMHz2QTnl1hHWUuw92UIx/RIactymqBaL
         GvwjlWLsJyVWzKzYFrLaYP24bFHOE7FZn8Xeq+KoFlC0qXSd25aux4PJ5gwRCSLRWYda
         OTEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=UbtuWMaNqNm0A4t0zaxp0854Eypr7g09S/us24n8g24=;
        b=zFJ8ivQM9W59OLqInLAdpyVd4uoXWHTCQSY+LJyQTaYCDAGBmjXEtf/kaazf8OhQoL
         V+g5p7whczapTsvw/Pp+oGstvegUbQz1yEj7BZlmS8S11LKJUymgOnWKkTGiHHsb7e05
         +t+1am7JluAmUNZg8lx1aNLXyJhCf+uplPowrFn3n5gep9gn0C42qltSfGuW+xQXHbg3
         /1cilWPmyLa6Bs+7RAvNsqAEMYzxX2jbAPCCZSxDI+5v1HiqJG2Jd+jbVLK3UVmg1y/z
         OxU5AxhDehS3o/W0lhNTicuys7KWSyFX3MMzhb++41d0KfxueJ1J0AZXMJDKutqVUPjS
         hZlQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jroedel@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=jroedel@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u26si308085edm.210.2019.07.18.01.44.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 01:44:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of jroedel@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jroedel@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=jroedel@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B8B67AD22;
	Thu, 18 Jul 2019 08:44:49 +0000 (UTC)
Date: Thu, 18 Jul 2019 10:44:45 +0200
From: Joerg Roedel <jroedel@suse.de>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Joerg Roedel <joro@8bytes.org>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 2/3] x86/mm: Sync also unmappings in vmalloc_sync_one()
Message-ID: <20190718084445.GE13091@suse.de>
References: <20190717071439.14261-1-joro@8bytes.org>
 <20190717071439.14261-3-joro@8bytes.org>
 <28a4c10f-f895-e8ff-d07b-9e4c35aa6342@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <28a4c10f-f895-e8ff-d07b-9e4c35aa6342@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Dave,

On Wed, Jul 17, 2019 at 02:06:01PM -0700, Dave Hansen wrote:
> On 7/17/19 12:14 AM, Joerg Roedel wrote:
> > -	if (!pmd_present(*pmd))
> > +	if (pmd_present(*pmd) ^ pmd_present(*pmd_k))
> >  		set_pmd(pmd, *pmd_k);
> 
> Wouldn't:
> 
> 	if (pmd_present(*pmd) != pmd_present(*pmd_k))
> 		set_pmd(pmd, *pmd_k);
> 
> be a bit more intuitive?

Yes, right. That is much better, I changed it in the patch.

> But, either way, these look fine.  For the series:
> 
> Reviewed-by: Dave Hansen <dave.hansen@linux.intel.com>

Thanks!


	Joerg

