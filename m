Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 936CEC10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 06:32:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3FBD72184B
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 06:32:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FBD72184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A5EAA6B0005; Thu, 18 Apr 2019 02:32:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A344A6B0006; Thu, 18 Apr 2019 02:32:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 922C06B0007; Thu, 18 Apr 2019 02:32:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5B22A6B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 02:32:22 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y7so702022eds.7
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 23:32:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=JJsGuE4p8f7YUM739jHLkVp8IcOA9Hb98TKzVDtxmZg=;
        b=YatQxtlTuGwyXaQ8AagXnY3QF9pF+r+j9x8yg4q4S1PDU/u2Q4Fncke6H0oNzqRj/c
         cfDdo7aovZ77LbsHSNz3ciKDkCJ3YvZO5Lsj7x6V9bBHp/XBynzM2SCgbi3zRsc43hGR
         OoHtv23mcMQ+DZebBAgPmEPaQDbOPrTcG8iA2FCb+HxRz3+IhUAtuJQblP747kopbAnt
         iaTAN6aHKXFskXW7opFiuOaWB/OBlECMz2QQBAuUItfGY7O9hkoqWvRE3RlvwMiTkeMs
         +E9w+UBiZQSGeIO1iEgqfg9GJVYndoCDa2pIV0RDn8XQCMfhr80gOKkeRLHjsREBwp8u
         Rm1A==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXh8lPMEozYxWqGzr3tuRKcf9tdD76v2+nazqCo0xPpdicgssXH
	zyMiYkAR3n/8wwFzSalFozIjwG3HgupIhJ/Cu+5uyBEU6tx5Fu67W9HApXqgRpm20o92jSj/RNG
	4wtoQ+NhK/8hX8zgrUC5bsyu3PH/HlO17CsLDsZuCl0iZn+/q6BvjDsmz/jqX2tg=
X-Received: by 2002:a17:906:4408:: with SMTP id x8mr33251268ejo.93.1555569141840;
        Wed, 17 Apr 2019 23:32:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxdo/paLIIW/lvaQ+4xufjJzbAW45K7ZJDkJN55DznoE8lDTO/jzME4BdqgUTfBVvd0pBoW
X-Received: by 2002:a17:906:4408:: with SMTP id x8mr33251230ejo.93.1555569140957;
        Wed, 17 Apr 2019 23:32:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555569140; cv=none;
        d=google.com; s=arc-20160816;
        b=Gk1JScqeR/G1GKynBfV00tfG8JpfJ22zO+Uug5cFFkeLi6w+ffLUaDwgMYFflrFL7Z
         EaSP27nkoE4UPCc7ZML9TxNh+kDhenT+NA2XVk+rAfvlDppS3RBJh7as/+t74EFghNc/
         NtBPCTI3KcQLRblJ0uAIvv0L0XTaspAOU7P9+Q6hHJVKIhWyDOkvXffUOVl+sDFC+zJL
         FHjyEwBBa5XUi1mo+0g/pDiUx6Hz1oXV2tcEjhpJ1TvDwFChCKORDdzS0W9AYe6zTAnw
         MQ22f9yYWb2tcYtbBmAvSKjF1+FPWAbT3La7VgiKs6IG6g/IiUztsRDcYwmOy2vT0CFr
         ELAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=JJsGuE4p8f7YUM739jHLkVp8IcOA9Hb98TKzVDtxmZg=;
        b=OP9PncXifDbK08L6AgpVhFKxWpB7SUnxORLUsvQPHcacjUvjPK0XhpW2/Tq9Qpcpet
         pkKlPZCKXyUgsFP8O983PAH5iyikT0KqR/Y9//cXwmAzTLmKEKSS2Uiweeq6BP9F13x5
         UoskU/vxnwD9ziHkGPwxSTmPc9vuYa7DModM+6HIIFqdN4lxhPkNRGrHQf8dSBTxAcEY
         VapI2aXMaSV63seoz6U1QnIrEnjLbuvpN12lQm6Mr2d4cIYqE+UeL4iGzFjLYiLbki9J
         aE9Lb3v/0NlmkxwDLy/yYD0P4I3Kre+3MScRXh1KwUH6JfiuiQ3Q5hfEjpmtEG87tJ7Y
         +UUA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r13si670248ejb.124.2019.04.17.23.32.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 23:32:20 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4D71EAF8A;
	Thu, 18 Apr 2019 06:32:20 +0000 (UTC)
Date: Thu, 18 Apr 2019 08:32:18 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Mel Gorman <mgorman@techsingularity.net>,
	Andrea Arcangeli <aarcange@redhat.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
Subject: Re: [QUESTIONS] THP allocation in NUMA fault migration path
Message-ID: <20190418063218.GA6567@dhcp22.suse.cz>
References: <aa34f38e-5e55-bdb2-133c-016b91245533@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <aa34f38e-5e55-bdb2-133c-016b91245533@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 17-04-19 21:15:41, Yang Shi wrote:
> Hi folks,
> 
> 
> I noticed that there might be new THP allocation in NUMA fault migration
> path (migrate_misplaced_transhuge_page()) even when THP is disabled (set to
> "never"). When THP is set to "never", there should be not any new THP
> allocation, but the migration path is kind of special. So I'm not quite sure
> if this is the expected behavior or not?
> 
> 
> And, it looks this allocation disregards defrag setting too, is this
> expected behavior too?H

Could you point to the specific code? But in general the miTgration path
should allocate the memory matching the migration origin. If the origin
was a THP then I find it quite natural if the target was a huge page as
well. How hard the allocation should try is another question and I
suspect we do want to obedy the defrag setting.
-- 
Michal Hocko
SUSE Labs

