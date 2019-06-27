Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8909CC48BD6
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 14:53:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 31FE1205C9
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 14:53:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 31FE1205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 774D48E0017; Thu, 27 Jun 2019 10:53:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 725F48E0002; Thu, 27 Jun 2019 10:53:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5EDCD8E0017; Thu, 27 Jun 2019 10:53:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 11B3A8E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 10:53:06 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id m23so6180914edr.7
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 07:53:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=bZ47DNSm7uAfoWl1tNymi/yFUcugQCX7MC1PS3ufi5w=;
        b=kt0HnnWakxzVSP2Ft+eOPqDWqh1jJsvOGVCEAPJiSF7a+E1ErcoLfT1+6gQl9DgSq8
         ebMPpW5dx7eSFPX9aEM+ZjcVjhwtGxo1eQ/a5JLE7KiBq9r9WJNUpDXzBwumn5uvwBr6
         Z1FSWlIONal85chvaFuwFhBXTH0ILxp11qOSTTO4VASkU7huBo7qGsbZU7yiZSa5OvGx
         ZgSNoePuIFb5GMuQB/Op5GEtTp8i10fDMsmmgt7MYbde564JQMhPJ6ehxyFjCDrHu2Nz
         /tly4vbVjg0GPPm5FxWZPmcORZ5GfmS0nKaEhXIm+Bc0IIgwv0mAqjK5/TpzjR0MVDLZ
         Y30A==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAU3pAC1YtURZQ2T4SaQ6SYKhFxfWXNMMXxEJAS1iQiHpUL3z/VA
	d3AT66q4pfrcHmCoLEMfs0BGnYOlz5B4lc35IQgljV87WC0Z2w5+Qw6gnoJW+Mt6aaVC9Gn1IuC
	sv44Mg9XnjYwvjduWCxhn51keyqK1RArzevwAvFKeexPenXWZJb22g+H9D1u+btM=
X-Received: by 2002:aa7:c3d8:: with SMTP id l24mr4961997edr.58.1561647185655;
        Thu, 27 Jun 2019 07:53:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyMhLMvr0Gor1yhHsH7MZtFwlaJepdZIhUjluRkCrSjkZ6uydkHIf+O5L7GeDMJUsZHGkHO
X-Received: by 2002:aa7:c3d8:: with SMTP id l24mr4961933edr.58.1561647185054;
        Thu, 27 Jun 2019 07:53:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561647185; cv=none;
        d=google.com; s=arc-20160816;
        b=oOsIPJByrA8mthSx8KYSlHIHCQ9+lBt3q6RXD15Q1xWtJw+RDKmp+Q55bscuKlrNLP
         eTCWfHXvCiDGtFVQnoZa5AYDVFZLdHkOe4eFYhDC14a6r56DnyGlgOWMcur9tpXyRm3q
         bfE1UMhmveZlvw1z06hWU/cpgTYL054aKfFZuZTJIKSQxdW/FSE91pYFTE5GfF7lzupR
         Bvmcoe4V//653K3qdhfUb4siE5/31ieCIFOPUFMXKkQviRz5P+NwnhPc42Ibj9wakoDW
         s3g38/HkAxaOlxWuDD27ewtfBk7oFeQo8GGQ7x2OWXPbX2Qn2gl06CnKjexWGBWUGllu
         LRAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=bZ47DNSm7uAfoWl1tNymi/yFUcugQCX7MC1PS3ufi5w=;
        b=We0Np0KYRS+NQzkoBLeJGK1WEAP4tCYsKt6sYhYQLHimDbNo2p5/Xy1CCh5Bq+Lkhe
         oDAsfBmnUVTLKiD5D1WE0pNEts5haCHalULViHnN31JM7TzarQXxcxG4aLOcFupJWv19
         Yj0Bruw7/avoY02ioelSp1mLruAz9JNqqpk/jeSm9yDprKsSsen9yH7koB317TMKeyI4
         1qOK+QHO8jxQ03HOo1p1pDhNnW7y7qo1PdAtC+/3KkUPB35iP6MoPLTcwinxhuaEWi15
         TJdMJJ069pxkNZp2hndVHUYu5f9OBYrD5PP6D69vYiIBtyZfBlNMTNlodvj3qzpADeqf
         CQWg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z2si1572636ejo.352.2019.06.27.07.53.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jun 2019 07:53:05 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6C4A8AFBC;
	Thu, 27 Jun 2019 14:53:04 +0000 (UTC)
Date: Thu, 27 Jun 2019 16:53:02 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Minchan Kim <minchan@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	oleksandr@redhat.com, hdanton@sina.com, lizeb@google.com,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v3 1/5] mm: introduce MADV_COLD
Message-ID: <20190627145302.GC5303@dhcp22.suse.cz>
References: <20190627115405.255259-1-minchan@kernel.org>
 <20190627115405.255259-2-minchan@kernel.org>
 <343599f9-3d99-b74f-1732-368e584fa5ef@intel.com>
 <20190627140203.GB5303@dhcp22.suse.cz>
 <d9341eb3-08eb-3c2b-9786-00b8a4f59953@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d9341eb3-08eb-3c2b-9786-00b8a4f59953@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 27-06-19 07:36:50, Dave Hansen wrote:
[...]
> For MADV_COLD, if we defined it like this, I think we could use it for
> both purposes (demotion and LRU movement):
> 
> 	Pages in the specified regions will be treated as less-recently-
> 	accessed compared to pages in the system with similar access
> 	frequencies.  In contrast to MADV_DONTNEED, the contents of the

you meant s@MADV_DONTNEED@MADV_FREE@ I suppose

> 	region are preserved.
> 
> It would be nice not to talk about reclaim at all since we're not
> promising reclaim per se.

Well, I guess this is just an implementation detail. MADV_FREE is really
only about aging. It is up to the kernel what to do during the reclaim
and the advice doesn't and shouldn't make any difference here.

Now MADV_PAGEOUT would be more tricky in that direction because it
defines an immediate action to page out the range. I do understand your
argument about NUMA unaware applications which might want to get
something like MADV_DEMOTE which would move a page to a secondary memory
(whatever that is) but I think this is asking for its own madvise.
MADV_PAGEOUT has a quite simple semnatic - move to the backing storage -
and I would rather not make it more complex.
-- 
Michal Hocko
SUSE Labs

