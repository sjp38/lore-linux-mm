Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD4D2C282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 14:41:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9737720645
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 14:41:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9737720645
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 363946B0005; Wed, 17 Apr 2019 10:41:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 310286B0006; Wed, 17 Apr 2019 10:41:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1DA746B0007; Wed, 17 Apr 2019 10:41:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id DBD836B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 10:41:45 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id o3so6065078edr.6
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 07:41:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=kxOwMzbnfT/mmZBXXgRgVBLUWfetHopux5wfWVeKtSQ=;
        b=gebkKaY7jUi4/yoVki2FywbZc/dsx6v22vYn2DbmRdcMTs3pKQkJw4ZKcNGhw+PwEi
         OX0pxEP1LpI/qs+gxx6ciw/Ync1/Rn+fCGsEcKqQYG3/GiTZjkJuwCls5uVYx050/4CI
         u9bmY6WCy4z3zIW9O+9qSLaGdH/XGzsPNfG0mn6Q199kG4NfyJAEViaiM5fpdfnUE0e8
         FQr/cF2jmgzIIfZGUAtRuJ5DwzE/c+gumBtsLFcA+BXti/Z0M2G3nVG+tnsDoZoWP6le
         rKqfMuM9Rli9pj9jMC02imcWFOMNmb9SfypIl3iGw287UmhqGr8EylB88kDgQe8Y1ITq
         H8xA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Gm-Message-State: APjAAAUhaViFbgI/iRRH+TSmzzKQeUpCpzu/nwvmZICTtV1o/MNbzpNs
	lraOMQOSpJNo2krPU33/zRYtGs1yA2G6GJQeFmomfj/bXcH/oGX+b+Y79j4CGJGjB2oDClKTkWM
	nFHeK2rmmrAgjUVZaPMXNIkO4a9nNRTRAqx4iJjpXYiW9kmg2GdXRp5uQdIUCD+cYeQ==
X-Received: by 2002:a17:906:eb96:: with SMTP id mh22mr24495678ejb.186.1555512105462;
        Wed, 17 Apr 2019 07:41:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxSk36z06c8PwIjW2czsaB70fEh/ef4yJNzDLW+ZFWOPkZ78TyUpMPS88aBjHECIudzHQ3h
X-Received: by 2002:a17:906:eb96:: with SMTP id mh22mr24495654ejb.186.1555512104729;
        Wed, 17 Apr 2019 07:41:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555512104; cv=none;
        d=google.com; s=arc-20160816;
        b=UyiacYUJ0e7PiAGisUerhN/XeFc+ZG45+XLp48UbyNa9Gm58G4hKqoQkckHjBmUfyp
         foF73YttGlfKCq1u4G2CXGtja5Vtjv7EA6Uno9KtPcJ/RJ/saD5Ri3ZXXbw7O+Lka0Ep
         lJteIoTuplUbPu7zM0zEKDTq4ZtvQP9wEfRpUlMIJ9ugTaOyiWPFnRmxcohVGNWy4yWi
         q79fh3FE8+9urDojZeZmCGcFMjJvqtQdpFVNVownNU09AZZRGWT+BAySLn0rAqFR6jxs
         Z+b7Dn5L1VpwUoEo8PhNGWzJcT0fsLMRCzJbMCiLcX4Kgwt1MERTDULUDTCjdjHTZJtr
         cL0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=kxOwMzbnfT/mmZBXXgRgVBLUWfetHopux5wfWVeKtSQ=;
        b=pr6M860Spg6pOIaLOBa+hRUHh1Mulg3kO05veIDj+vaeFiVqd/zPQt82f33lphfMCb
         c/Myy8psgmphRefHwwVItZsmoZgn2PMTzkNwcEFB6mS4024ZNDjYY8HBTNNz5xSmqf3c
         VXYuPCYFCmgxqwDXBylBC8FsF9LDEihf7UWWpn4ildMuO2jPm5iqSVPDhrB6WRwoc/m9
         MO4AA2MXmCvBpYUNc55pCQ1IFs2QPGCeY//9Ua6FXSQtjVAWdq91nI1SHh0w0Zltu9qR
         aVq7pAHSwN/nawtRzrdcdYIcUZruyWHmI9/JnG6pOStFk9Xrn9PdSlaAtG6Szfb4AxYl
         PGag==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 46si282853edu.64.2019.04.17.07.41.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 07:41:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id F0045AEEA;
	Wed, 17 Apr 2019 14:41:43 +0000 (UTC)
Date: Wed, 17 Apr 2019 16:41:42 +0200
From: Michal =?iso-8859-1?Q?Koutn=FD?= <mkoutny@suse.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Bartosz Golaszewski <brgl@bgdev.pl>, Arun KS <arunks@codeaurora.org>,
	Geert Uytterhoeven <geert+renesas@glider.be>, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mateusz Guzik <mguzik@redhat.com>, Vlastimil Babka <vbabka@suse.cz>,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: get_cmdline use arg_lock instead of mmap_sem
Message-ID: <20190417144142.GF8962@blackbody.suse.cz>
References: <20190417120347.15397-1-mkoutny@suse.com>
 <20190417134152.GM5878@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190417134152.GM5878@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 03:41:52PM +0200, Michal Hocko <mhocko@kernel.org> wrote:
> Don't we need to use the lock in prctl_set_mm as well then?

Correct. The patch alone just moves the race from
get_cmdline/prctl_set_mm_map to get_cmdline/prctl_set_mm.

arg_lock could be used in prctl_set_mm but the better idea (IMO) is
complete removal of that code in favor of prctl_set_mm_map [1].

Michal

[1] https://lore.kernel.org/lkml/20180405182651.GM15783@uranus.lan/

