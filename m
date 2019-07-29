Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85252C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 09:12:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 53397206DD
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 09:12:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 53397206DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E25538E0005; Mon, 29 Jul 2019 05:12:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DD5938E0002; Mon, 29 Jul 2019 05:12:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC6A78E0005; Mon, 29 Jul 2019 05:12:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 92B0C8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 05:12:51 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b3so37853169edd.22
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 02:12:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=UkRu0wZ839kXF1j1bCmJnioGpdo1W/FJJ4f7nrTYBCo=;
        b=W+tIYfRBaHz+G9Mg7up3yyoybPn8G/G4wdAdXlejxtN5+YNJ1wb0YLyWI0s/3SMeZM
         0nwxxnNvvkXYeFkZLf2MaeukVJ/DcGc1y3NPxdDX9+e5q5a8rrGxuXVbc1Mx3RRZHhro
         rvCUv/2cmu3UQ5ow4P0ydkzHqNFKWohFmGYx+TUTOV98BFtAw8ny4NiB015o7gdu0Pif
         +d0HUxpt9YwLfDVHiKVNY0q6fAh3SwGNud9swPIi6YcoUJ9Cse3noIVfAR7XfNAbZzDb
         kZ+WyPVctodExgdqajTMJ8OpL7XbwNZid5kciFsKRX4dpaI23LnlanRPei56gNFR5Qd8
         1WfQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXbl/hb8Zo9TjXcF+TPhICIAZVpNUjlAyEc35lkR+xl+Hkz7mTZ
	hadFpRKm5MnZl4YUE3DBrXQisbZc1aCgvlUYsAgjkJ6VKFVqg/IijYjY9HrfSDI5bczEYKOdOZ0
	ILEXwahgy3B6RJd4Zhhk611QZkM5b4xihb9EvSH97cawAB3VT0yV3pYV1jmwqrEg=
X-Received: by 2002:a50:a544:: with SMTP id z4mr93538840edb.71.1564391571159;
        Mon, 29 Jul 2019 02:12:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxlEIifjQ6YIyued51Ra08cmv9JG9UbWcHAxLyXMVRvXUP720R4cWK/Ubcw+IGNQV6HvXEv
X-Received: by 2002:a50:a544:: with SMTP id z4mr93538784edb.71.1564391570419;
        Mon, 29 Jul 2019 02:12:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564391570; cv=none;
        d=google.com; s=arc-20160816;
        b=Gs+gx8gYtfbVqZK4F2uXhuk3ZMCV6FdJ7I+U3GPu9V1hP25jVjWAMWKoIVne9yIucZ
         c4GweS4a1o8U1Yt4rfTbf35k9QvrK/5QW8qLZDL5VMGmZmNQCvaB5LOo9NsFP3jN9B9b
         OPlWu3JWZXUUBq8Y1vMqTBapd34opaKQNsimoEEdt0ogQNgemXoaKRi0CMVr5bFfb5lg
         L+Oimo5KS3DORNVtUrbbJVhjsaWTguWKY9dcXBgft/LTv3/3FDBkjMvriQks+Tq9Ws+O
         s5Xyk1Bm9IeVNmJj5FfTCKoVBZbTNc0C71h+uzl2tni++5ywEYnRJ/A2T0jSeewLFtEr
         tj2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=UkRu0wZ839kXF1j1bCmJnioGpdo1W/FJJ4f7nrTYBCo=;
        b=FSjA5ThyeieQL405+XOv5+utOVZ/idOECTFDMSXdPYTLV9lL0t16gGx7qIe7UMYhry
         8YwqA87wJWTLVtVQhM7AKBxCt52XEVeSAZeYG6BqSTdP8BgC6o2VAPb/915Iy65mgukL
         D6nHCHFtnyXygT9EARPnuFk+g/854CtUA+tfiZeJlilvM3H7OJzwaANuHnvJT+NtmM5P
         o4ZpitSSbM6F9/rxCp/TXzNq+KBoHSj12HrDCegyiNUu8Gtj6130A4rKddJI4f5hUjnh
         qBJGj09nNILzajDOQshypczgpySj/tfW82W2oajVS64iHSPIM8GKmMlYMyMpoKC1dB0Z
         zvdA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w7si18303005edw.223.2019.07.29.02.12.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 02:12:50 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0304BB60C;
	Mon, 29 Jul 2019 09:12:50 +0000 (UTC)
Date: Mon, 29 Jul 2019 11:12:49 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Waiman Long <longman@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Phil Auld <pauld@redhat.com>
Subject: Re: [PATCH v2] sched/core: Don't use dying mm as active_mm of
 kthreads
Message-ID: <20190729091249.GE9330@dhcp22.suse.cz>
References: <20190727171047.31610-1-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190727171047.31610-1-longman@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat 27-07-19 13:10:47, Waiman Long wrote:
> It was found that a dying mm_struct where the owning task has exited
> can stay on as active_mm of kernel threads as long as no other user
> tasks run on those CPUs that use it as active_mm. This prolongs the
> life time of dying mm holding up memory and other resources like swap
> space that cannot be freed.

IIRC use_mm doesn't pin the address space. It only pins the mm_struct
itself. So what exactly is the problem here?

> 
> Fix that by forcing the kernel threads to use init_mm as the active_mm
> if the previous active_mm is dying.
> 
> The determination of a dying mm is based on the absence of an owning
> task. The selection of the owning task only happens with the CONFIG_MEMCG
> option. Without that, there is no simple way to determine the life span
> of a given mm. So it falls back to the old behavior.

Please don't. We really wont to remove mm->owner long term.
-- 
Michal Hocko
SUSE Labs

