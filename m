Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63B46C0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 10:23:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3179F2133D
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 10:23:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3179F2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BFB906B0003; Mon,  1 Jul 2019 06:22:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BACC58E0003; Mon,  1 Jul 2019 06:22:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC2708E0002; Mon,  1 Jul 2019 06:22:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f80.google.com (mail-ed1-f80.google.com [209.85.208.80])
	by kanga.kvack.org (Postfix) with ESMTP id 607726B0003
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 06:22:59 -0400 (EDT)
Received: by mail-ed1-f80.google.com with SMTP id d13so16599077edo.5
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 03:22:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Gu+8FufpSG2YgTNln/PzBlphY5g4BYvnlZLQ5ChkhQ4=;
        b=SbLyeehYYCubunTLLd/6SSX2a+yP5Fzfx3CQ3G7gMGlxudxMWyCf2j6iYtFwAUSWqt
         olJESSuvr2cx+gwJ6Y1Ti2P/MRBO9Qg0e3GRo7GYCMDYCOAPO6THr9FCG6YZlgXLxvz0
         xqPA9k6ZP6i/hMfCF0Lp+5P1fcYX7ubxiZ3kxTQ6kOVRmjDNfSUkEH51BUSVYiNr5sIO
         s7DeOcNKNCkQYNUQBKlFA/EJ1sC0VOBTrpB/sPmyBmkeUtPw0+s9ejfDP9aVFsBLnZ48
         20HXy81in15hZueWzMELIh3LJIdkIuNWYFdpqSNlFU8Jn2Ah/dNCK1ReoRtZ0qOnKDP7
         /CTw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUeEEdqgU+mr+1F35CW4kqRu2K6huv0mQT6uvCNviVHKXq/pVPg
	Fj1GFRVKZOb7u0jMhGKUYRfyY0NSznVrXCkhlbAuHM2TzJUnpjNwQ7MoNUoKePqMKxS1G7wkTfw
	cCmL17oBjq6VyvyHSiAT12TwZoe14yCtyQX70rDzdBkfQ3wXuoj3Fq/hQJtF94uY=
X-Received: by 2002:a17:906:b209:: with SMTP id p9mr21903253ejz.270.1561976578977;
        Mon, 01 Jul 2019 03:22:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyfuSA5p/j10nMYZx03aTSv2CV9QwlyZhMOWAprwgflIwz7ffK3TeUwItbHHV3QltqesRQ0
X-Received: by 2002:a17:906:b209:: with SMTP id p9mr21903199ejz.270.1561976578234;
        Mon, 01 Jul 2019 03:22:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561976578; cv=none;
        d=google.com; s=arc-20160816;
        b=gH8BEtuuwiFSaIPp9dNwW3jCSLSp1s/1UqPKbfyCNXO2PY4C033iVaE0dEhn53NAGy
         R0m+hN7EQRCXQhaQMgS4RvuFOMEKpLcdzg4a/TvlX/iOrJnGS7chFM6r3ImuGu7se/3q
         ydhi23PpGwcIL3hE4dNiQJM5cVwe7LT7x7BcUGdHhl5Ij0z8whlvhvUrrP2CnxO3JLHO
         pLf3JFVe2pARKxOnxpS0u2CeC+Cr4te2uJStwaQUE9QGZ/YZRGSwwIrYfKVXlilgpG30
         /pwCVxOr1+UIOQYomvIOqYc5SHmvVLY3wN3CLpfr3BdVfaNHipsGo8oMozZvzBeZqT6K
         wlkQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Gu+8FufpSG2YgTNln/PzBlphY5g4BYvnlZLQ5ChkhQ4=;
        b=KyqCcMvGOroeAR5+fVMlieoPnvosp7BbtBAfHSborBtsW/aTzD1abpWg8+x+cJqwYR
         czpH7pn0k27TZCReuCyQCigJZY3oCINE4mxEmgQWkM4G8iBGJWlv080Y4FdmX8y9mzwz
         o+erHyt4uRMnvlJyJJZ1OKDIOKNM8jU2ANC+8wmCxje9X9a8KRMBobQi+Tv9MFDQr3F3
         K/ebmvRUBUsa2XajO7D4CS2mc44qcMxIHr1GJIoqS9kmNmpa6lp5X7vsfcGHjR7m4Rhg
         KlGb9xLN45CMYi3la+runN0rvf6FhuCIIGu1LRRMFGFjsN/6/DlsCN6E7gbcU1ixlm2W
         pZsA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gg5si6864250ejb.165.2019.07.01.03.22.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 03:22:58 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7BEA0AEE6;
	Mon,  1 Jul 2019 10:22:57 +0000 (UTC)
Date: Mon, 1 Jul 2019 12:22:56 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	oleksandr@redhat.com, hdanton@sina.com, lizeb@google.com,
	Dave Hansen <dave.hansen@intel.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v3 0/5] Introduce MADV_COLD and MADV_PAGEOUT
Message-ID: <20190701102256.GN6376@dhcp22.suse.cz>
References: <20190627115405.255259-1-minchan@kernel.org>
 <20190701073848.GB136163@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190701073848.GB136163@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 01-07-19 16:38:48, Minchan Kim wrote:
> 
> Hi Folks,
> 
> Do you guys have comments? I think it would be long enough to be
> pending. If there is no further comments, I want to ask to merge.

This is definitely on my todo list for this week. But please be patient.
It's been _one_ work day since you posted this last version so I do not
think this is stalling for too long. Sure the current version is
probably not too much different from the previous but I didn't get to
review it in the depth yet. All the code duplication doesn't make it
much easier but I understand your reasoning that sharing more code is
not really straightforward.
-- 
Michal Hocko
SUSE Labs

