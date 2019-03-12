Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68127C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 16:58:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 216372083D
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 16:58:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 216372083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C089B8E0003; Tue, 12 Mar 2019 12:58:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB6E18E0002; Tue, 12 Mar 2019 12:58:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA68B8E0003; Tue, 12 Mar 2019 12:58:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 510DB8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 12:58:08 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id p5so1383284edh.2
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 09:58:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=pHx7fAnnL4V1/6hOmMndEvCqfYhmC/Qy1nXTCyCh3eM=;
        b=jeqm6p8wEadOK+bNP12HQJycBL6lSfGOsGisoG/pWd9kbruXOd70GNpm3V1LJP+prN
         RQoksXOLdw+p+lvFCtWarPTVFoXWDS+nKRbLzYnnCjtN8ps4RT2YJ2bHqW5YzlGRA+cB
         v+m1oPyYTcL/QixZLTb1nW1VeBlmfcrqecexQnG3MQcGl8MGF0zBfZKltgcTZTRkL9/7
         1S0Zm7AXkZIj/ctpp5Ycvsd1IK/4YZVI5BWqD/HDMOQ96TXmjNqCqt0WVZb7HYtFmASv
         2N6N6ki8M3U6xdBktIZ92U1Yo/BiPOqbu4w8Bq9EU9WO+b5nXRY7FVC2G0RkcPM8yTUO
         orbg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAU7AUneCaRdt9tUT+hairEKIqxsoArY84wJyuqMAtRaiSjNZVX4
	1ejRe0YKf1oXd77VeVJNCbDDX+bC7mBY/dhwVP1NNmkRbwnfCxzmR2rubilW4Gor69OHUmRf5tf
	ORerCzXIeWRRWa06m6BsXM+JMwRqoG9PIQGWFkoMsmzjaBYdWLiGfBRSgjmJlL4k=
X-Received: by 2002:a50:b7b6:: with SMTP id h51mr3995262ede.277.1552409887825;
        Tue, 12 Mar 2019 09:58:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwW0QS9HKKtoOMNMUzJpGGQx9anJEG8fcFDJ6nJ6GCvnL93pkLoedvGkInBQYDK9r4UeVFW
X-Received: by 2002:a50:b7b6:: with SMTP id h51mr3995223ede.277.1552409887003;
        Tue, 12 Mar 2019 09:58:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552409886; cv=none;
        d=google.com; s=arc-20160816;
        b=z7sqZwyNPNZpyIiqfBsFIXv3skbLPmgUXgs+UPpmEHCbyeJ9vEJ1z/niHXgzvYSX2j
         zg/Z8d/e1KOcc3Qz/wxLUHCoQblHylgrmpYRrdWjwTy+aaVEvwVEG7uuwTve9TLPwF6q
         QObqoGmVoFubEHf//t5sQjVTRCRDYs3DSxGYAGnbhlTLRnwj3+hzp3cf29IGjOdP+GMa
         kKIgBedv1jKFi0NQiCO/DdZQ4HcAoPqPZLQ2TKoM+Alh4zyzGa1gX2k/Q8iOhWc/2apS
         Ktu7+Q1HvR8HM7lRvdyov/ykn7zgQJEaNUaBI9YQvrMDeqJPi96Xxm5La1B2uh2gi4ki
         ia4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=pHx7fAnnL4V1/6hOmMndEvCqfYhmC/Qy1nXTCyCh3eM=;
        b=gnEpkeXCmJlaBYyNJ7qkB6sUSiJQR8t17Pg3J8iV+Keqh4AwuirlDMssbeFavU+Ncr
         2SgiPA7nbMEMLhPLaVClRzb0HHF+WfVLGY1/JX2RR+moqyLoLg9TTA2UO7qS/fJmEO6d
         HTxPiit5qpNLBSrGWNFsh991B/mo4c+QdogoGxUwtenOZUqXwvsEkZ3sZENMkrPSqMaY
         UMioCyMeqEP5XkxXbtnolfvKOxkzCFNVnlkP3/NApxDwyScroeDJe+7DhQNY/wV5gzsS
         TObjAGSio4PK6rxFAwIy2oGFUHg6rqE3HPud3CiqpgE+3nDN+TU2QRGRNodVrRJ3MmZy
         yOkg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v26si67702eja.293.2019.03.12.09.58.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 09:58:06 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 83920AEA9;
	Tue, 12 Mar 2019 16:58:06 +0000 (UTC)
Date: Tue, 12 Mar 2019 17:58:05 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Sultan Alsawaf <sultan@kerneltoast.com>
Cc: Suren Baghdasaryan <surenb@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>,
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Christian Brauner <christian@brauner.io>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, devel@driverdev.osuosl.org,
	linux-mm <linux-mm@kvack.org>, Tim Murray <timmurray@google.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190312165805.GF5721@dhcp22.suse.cz>
References: <20190310203403.27915-1-sultan@kerneltoast.com>
 <20190311174320.GC5721@dhcp22.suse.cz>
 <20190311175800.GA5522@sultan-box.localdomain>
 <CAJuCfpHTjXejo+u--3MLZZj7kWQVbptyya4yp1GLE3hB=BBX7w@mail.gmail.com>
 <20190311204626.GA3119@sultan-box.localdomain>
 <CAJuCfpGpBxofTT-ANEEY+dFCSdwkQswox3s8Uk9Eq0BnK9i0iA@mail.gmail.com>
 <20190312080532.GE5721@dhcp22.suse.cz>
 <20190312163741.GA2762@sultan-box.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190312163741.GA2762@sultan-box.localdomain>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 12-03-19 09:37:41, Sultan Alsawaf wrote:
> I have not had a chance to look at PSI yet, but
> unless a PSI-enabled solution allows allocations to reach the same point as when
> the OOM killer is invoked (which is contradictory to what it sets out to do),
> then it cannot take advantage of all of the alternative memory-reclaim means
> employed in the slowpath, and will result in killing a process before it is
> _really_ necessary.

One more note. The above is true, but you can also hit one of the
thrashing reclaim behaviors and reclaim last few pages again and again
with the whole system really sluggish. That is what PSI is trying to
help with.
-- 
Michal Hocko
SUSE Labs

