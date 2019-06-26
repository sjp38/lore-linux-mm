Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F137C48BD8
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 09:18:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0936B20659
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 09:18:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0936B20659
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7A0348E0003; Wed, 26 Jun 2019 05:18:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 74FA78E0002; Wed, 26 Jun 2019 05:18:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 63E9F8E0003; Wed, 26 Jun 2019 05:18:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 13AC78E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:18:20 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id s7so2218866edb.19
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 02:18:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=d1sbKZLmn8pY4AmovjzlahQrsI0ETLrT8QVpBI+5qA4=;
        b=gcF3s4OI5OsxrR/j3wqkVXmQRTpH0hXDFvm5bJgnhUe9mZWiRVkmGMVuDk2pWz+j9q
         x/DMohVw0i6E62eYHh9FlINPxV5D8xGFdJ67VBKnwYGZdNE0iZCn5C2MsBw8yXUK7G4Y
         i5N8GIfbRzmYjl+wYd+u/Mb+mut3gIDWsS6phIojPywe44YKitek0hXDHV8IbBgXaiEs
         v4+rdzXUl3A2BjPaH+5AHYVeVv416vSaD9YKuyEIsfKHwur5Flh3RdXU5IcEI+WUIxGk
         yvFFMi+3gZtEmnxISb0Kk76k9acBmPBB+Y/gvz6xru9pPwjGCSiW6x/ho781LwMsrd7M
         J9yw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXlyo17h99kYsse69UYhUZeIAS/VLGMdJ0Rb/Q+6LMlsb2xGjkj
	AH3nLfH+YEmqFymI3HVtjUIK1B4ltIxf7HwqlokjK37pGqzQnWjCqSH0chZKu5z2CClOwElIK18
	aAkBx0hc3gdrTV0hKXDjP1cF/RSlBKZCiAe+fJFQsf8K4S7OGOcozTYYFPYqOMBI=
X-Received: by 2002:a17:906:9386:: with SMTP id l6mr2970991ejx.51.1561540699653;
        Wed, 26 Jun 2019 02:18:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZHqsKnk4cip8ywBGrA3xkHC1FkpVWwVk0gLqJOCnqYn+MsxHEQ1RQPQlZr6ClKJycWiHn
X-Received: by 2002:a17:906:9386:: with SMTP id l6mr2970935ejx.51.1561540698904;
        Wed, 26 Jun 2019 02:18:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561540698; cv=none;
        d=google.com; s=arc-20160816;
        b=EDXN06E0/zewMDm/dteL+a0xb534a3HbdMBSQ6VySbg2oUukeBj/hJNIcxXWWCWhYd
         Wmb5LyrsoO9ABWDilmGCH9FDSFTFu98RRpICgJICcok1r/3Z3JACxAxY3Gu6sr6kPGPD
         I9PSfXFyr+wUKdoSBC23CrKak7WZtl6kh8OmSJzsR2KL+dDXUODaUFDKCU/eY1fibdiC
         irNjYcB7DAw5sHqW1siflflmp6VMc2gSyiZeN1FLNIN3S/HAabuAkwWlw/aluLY3Mfm+
         bA4XW0Zn9VWjYxuJoegPXDfcCKe355l1DY+HLvQnb9UmPvfHpmMm/FFIqUJV/zyE2LY0
         +M4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=d1sbKZLmn8pY4AmovjzlahQrsI0ETLrT8QVpBI+5qA4=;
        b=t/FeW/B6CPitsr5UDeat7wMRdmLlj3rA3XiXMXNQqg9SF5nELsx1hB4y9rO6QYQw8W
         ORcGuwmdWYfdpacGeg4N2ItEBH/KpBXQvS0F6HEoKfRPEBkEbRuKGAPoQdxEQ1M0QBDt
         YheD5K95iM6JGpIT6fZxuPXY49UOj8LPbqfekCdckIfIvmBrcZH/l9S3TiC+Q8INdYjo
         LeFwnRuLbjooq6S0w7dzO1BktahgkY/3CsZKGyileDxTpSWG4PEJyCmdNSYQ6/J3LUyx
         xoAdB3NMQOM395eYE8iX3zXXH9IOKisTghNwMRLfRC/YxAxBfZSewnzUutVzDBXihPps
         YAvw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d13si2518188edz.9.2019.06.26.02.18.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 02:18:18 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id EEA71ACBC;
	Wed, 26 Jun 2019 09:18:17 +0000 (UTC)
Date: Wed, 26 Jun 2019 11:18:17 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Hillf Danton <hdanton@sina.com>
Cc: Shakeel Butt <shakeelb@google.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, David Rientjes <rientjes@google.com>,
	KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	Paul Jackson <pj@sgi.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	syzbot+d0fc9d3c166bc5e4a94b@syzkaller.appspotmail.com
Subject: Re: [PATCH v3 3/3] oom: decouple mems_allowed from
 oom_unkillable_task
Message-ID: <20190626091759.GP17798@dhcp22.suse.cz>
References: <20190624212631.87212-1-shakeelb@google.com>
 <20190624212631.87212-3-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190624212631.87212-3-shakeelb@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 26-06-19 17:12:10, Hillf Danton wrote:
> 
> On Mon, 24 Jun 2019 14:27:11 -0700 (PDT) Shakeel Butt wrote:
> > 
> > @@ -1085,7 +1091,8 @@ bool out_of_memory(struct oom_control *oc)
> >  	check_panic_on_oom(oc, constraint);
> >  
> >  	if (!is_memcg_oom(oc) && sysctl_oom_kill_allocating_task &&
> > -	    current->mm && !oom_unkillable_task(current, oc->nodemask) &&
> > +	    current->mm && !oom_unkillable_task(current) &&
> > +	    has_intersects_mems_allowed(current, oc) &&
> For what?

This is explained in the changelog I believe - see the initial section
about the history and motivation for the check. This patch removes it
from oom_unkillable_task so we have to check it explicitly here.

> >  	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
> >  		get_task_struct(current);
> >  		oc->chosen = current;
> > -- 
> > 2.22.0.410.gd8fdbe21b5-goog

-- 
Michal Hocko
SUSE Labs

