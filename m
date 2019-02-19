Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92628C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 02:05:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2BFDF21773
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 02:05:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2BFDF21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8A99F8E0003; Mon, 18 Feb 2019 21:05:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 857698E0002; Mon, 18 Feb 2019 21:05:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7458D8E0003; Mon, 18 Feb 2019 21:05:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4B7118E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 21:05:18 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id z198so16440772qkb.15
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 18:05:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=QnGCYlaAPfoy9e7CK7GuUHJW+/0iX6oDpxFAQ0SgI1c=;
        b=mF9HqFjulE3Y5Rs5c9jv+s7J6DSpk4f0EIBx5w+hFdC0egoBMRRGKgxB+0lKkOX6Mu
         NZdB82Ehf9zUaKWrxzui/YnQgkNhTbxFs/C+ovOghbBHAIU2BsUpdv/0CG+j2cE+nUBo
         O39SAqIbftBLsd5xyxLX/2VxUYViXM1WnmciXDIiNAs50uwCg8b+aq5g/8vp0QpnkWSI
         qx7UTwfwiGePkOWeDYB2JHJRL2Or6EqprzHF4lzJFWR3MBQ29Rwgcr5+jCWtiJ4+gmNK
         xjPGyumZgxFZADn8pTEMsLKfDovhozckIEz2g+9qgH5YVuSwjCsJYqCGHKShAiXQPhnC
         rRqA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dchinner@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dchinner@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubO9R9AwcwBMHwKuiUGEqCsRYX/V5sK7j+NZZX7SahQbr1Dls/A
	78SL7NNOhtACE4lB6WU8YL0N1Fm72X7ZKO5115jdzeM9omkJ2XlwTMzJ14ePHOv3y4mIYB982F3
	J7RiXYmklLqnWgx72Ko1l3VC1ap5YXORg0a76WsREItSZAd7ymE48hGaHbrvCxEBjjQ==
X-Received: by 2002:a37:a407:: with SMTP id n7mr17021106qke.46.1550541917917;
        Mon, 18 Feb 2019 18:05:17 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYGceXAJnyaKWF6CyiX4xQoxjbNMG14ew/wa7JGE4MhAaxC0C8DcTvBRRET1WXw1vhGtclf
X-Received: by 2002:a37:a407:: with SMTP id n7mr17021067qke.46.1550541917012;
        Mon, 18 Feb 2019 18:05:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550541917; cv=none;
        d=google.com; s=arc-20160816;
        b=fOA8xzSFE5Sh3943G/e9EgD70wcL19QL5sF/YXzgG2+Sw0Z7NMSRtPayLCamgc+pYX
         AUHkPuclmI9+tesm5UFD0O5jF53BwmY0rSIshR0CpGv3aq2FcRYdBda/1RTHkGoQTD5s
         BkiQwhgIrTaJy8arTFYWhtZEQR+XRbXMSl1iDzgFvLLBf5chdp2JdF01WHiziqW8xVDP
         c0G83ewAQCjwo/TMgvp/Z7RHKmfF0Ox3WNEQJK1kOhmEfrZNlQylwWcd/O8wA0ygXgDZ
         bleS7jzvt3PfTJuXK9mUbaaoC2spt4CTFstJq4Ld68vSEX4B6KdbcPkL5R4xAgOlT3jh
         iAyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=QnGCYlaAPfoy9e7CK7GuUHJW+/0iX6oDpxFAQ0SgI1c=;
        b=YwBQlgpYJfAAcDoeCgs5gf5PnRaVFGJkyyg/37K0kYvj1iD9uZ/G1S2PDWe9h1JTS2
         dl4BZmCEjiChzhGfw0BXv93wlRrUvas+dHnrvNpR4dnCkFbtNlMSoA7zzkJ6d1dpW+Z4
         odLFslHrvMEYpEbyxvN4W3crZt7SGFy+160mhT4Yr1OtYcuuGwTqGhsm3PgOQ4Dyj0tP
         Jxc7lUMsklWztn5iQiz+aEK37pOFQTKiZgDMAqQ0YeXEmHDrZOPH5jSEER31gYt3O1pF
         pDaEdQgLNucasUFiIozQj7WiF+IF6dZeIiUnsnROUUXk7uPj8vubOce0WblB7SfvND2V
         UREg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dchinner@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dchinner@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c7si3625622qkf.148.2019.02.18.18.05.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 18:05:17 -0800 (PST)
Received-SPF: pass (google.com: domain of dchinner@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dchinner@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dchinner@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D5DEF11DB94;
	Tue, 19 Feb 2019 02:05:15 +0000 (UTC)
Received: from rh (ovpn-116-82.phx2.redhat.com [10.3.116.82])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id CA90D5C1B2;
	Tue, 19 Feb 2019 02:04:56 +0000 (UTC)
Received: from [::1] (helo=rh)
	by rh with esmtps (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.90_1)
	(envelope-from <dchinner@redhat.com>)
	id 1gvumB-0004M4-23; Tue, 19 Feb 2019 13:04:51 +1100
Date: Tue, 19 Feb 2019 13:04:48 +1100
From: Dave Chinner <dchinner@redhat.com>
To: Roman Gushchin <guro@fb.com>
Cc: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"mhocko@kernel.org" <mhocko@kernel.org>,
	"riel@surriel.com" <riel@surriel.com>,
	"guroan@gmail.com" <guroan@gmail.com>,
	Kernel Team <Kernel-team@fb.com>,
	"hannes@cmpxchg.org" <hannes@cmpxchg.org>
Subject: Re: [LSF/MM TOPIC] dying memory cgroups and slab reclaim issues
Message-ID: <20190219020448.GY31397@rh>
References: <20190219003140.GA5660@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190219003140.GA5660@castle.DHCP.thefacebook.com>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Tue, 19 Feb 2019 02:05:16 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2019 at 12:31:45AM +0000, Roman Gushchin wrote:
> Sorry, resending with the fixed to/cc list. Please, ignore the first letter.

Please resend again with linux-fsdevel on the cc list, because this
isn't a MM topic given the regressions from the shrinker patches
have all been on the filesystem side of the shrinkers....

-Dave.

> --
> 
> Recent reverts of memcg leak fixes [1, 2] reintroduced the problem
> with accumulating of dying memory cgroups. This is a serious problem:
> on most of our machines we've seen thousands on dying cgroups, and
> the corresponding memory footprint was measured in hundreds of megabytes.
> The problem was also independently discovered by other companies.
> 
> The fixes were reverted due to xfs regression investigated by Dave Chinner.
> Simultaneously we've seen a very small (0.18%) cpu regression on some hosts,
> which caused Rik van Riel to propose a patch [3], which aimed to fix the
> regression. The idea is to accumulate small memory pressure and apply it
> periodically, so that we don't overscan small shrinker lists. According
> to Jan Kara's data [4], Rik's patch partially fixed the regression,
> but not entirely.
> 
> The path forward isn't entirely clear now, and the status quo isn't acceptable
> sue to memcg leak bug. Dave and Michal's position is to focus on dying memory
> cgroup case and apply some artificial memory pressure on corresponding slabs
> (probably, during cgroup deletion process). This approach can theoretically
> be less harmful for the subtle scanning balance, and not cause any regressions.
> 
> In my opinion, it's not necessarily true. Slab objects can be shared between
> cgroups, and often can't be reclaimed on cgroup removal without an impact on the
> rest of the system. Applying constant artificial memory pressure precisely only
> on objects accounted to dying cgroups is challenging and will likely
> cause a quite significant overhead. Also, by "forgetting" of some slab objects
> under light or even moderate memory pressure, we're wasting memory, which can be
> used for something useful. Dying cgroups are just making this problem more
> obvious because of their size.
> 
> So, using "natural" memory pressure in a way, that all slabs objects are scanned
> periodically, seems to me as the best solution. The devil is in details, and how
> to do it without causing any regressions, is an open question now.
> 
> Also, completely re-parenting slabs to parent cgroup (not only shrinker lists)
> is a potential option to consider.
> 
> It will be nice to discuss the problem on LSF/MM, agree on general path and
> make a potential list of benchmarks, which can be used to prove the solution.
> 
> [1] https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=a9a238e83fbb0df31c3b9b67003f8f9d1d1b6c96
> [2] https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=69056ee6a8a3d576ed31e38b3b14c70d6c74edcc
> [3] https://lkml.org/lkml/2019/1/28/1865
> [4] https://lkml.org/lkml/2019/2/8/336
> 

-- 
Dave Chinner
dchinner@redhat.com

