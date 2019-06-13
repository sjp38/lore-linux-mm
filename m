Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 93A4EC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 08:23:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59BD120851
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 08:23:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59BD120851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE3B06B0005; Thu, 13 Jun 2019 04:23:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C94E56B0007; Thu, 13 Jun 2019 04:23:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B838D6B000A; Thu, 13 Jun 2019 04:23:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7DD8A6B0005
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 04:23:20 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d27so29834788eda.9
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 01:23:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=qShYouWOrO2P4M1ZBJfQCzwSFQ7+BKHcrZX/LY1rQuc=;
        b=TG7Wzu3mU8s3ccTPfAlk+C0IviM3BQxhFEWVaa8i4aaq6+Auo8EeikjPswEelA9WtK
         Rpvvu4ghBzFmaPA7q8C1RebuyedkhkEhABCUZ4Fyh3Op0CITf5OWcNRmaAENQ5as6DDR
         Y53Yeu0CiXaQYohnjxT2Yc4qXAxfkKllQ3k7fqWELzy2RLB1Aec2bL/LLTPW58B0HMNQ
         zuYHOhirzFYG+Qi/8P//NqYjRbLmIusTtx4iY7aE1o3gNm5GFsyTwA1zLl5zYi/KYhvq
         3NH6moc1bc2jAP3vh97AGdNODVcBt9G4ahx+0UV8Eq/AYD86O/mi2Bz5krs8vOT6AQEA
         50uw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXsBmbW9jnILyYYYvJlHyICvO8/MpIawB1iBYRnz6b0/UUS8fIV
	vHBgbUp57gnX3Hal3y2u1l06NNigfyWjZRnCU6j439T/RkKnKd/y5Ol+gJK708ATz2GF10SMH9o
	cnU88VTkK769PUfpcGMMRgafzaeVQlArp3lQSEVS5jyezr9OzzVYm522yHQhj9TU=
X-Received: by 2002:a50:b6ce:: with SMTP id f14mr70527413ede.236.1560414200081;
        Thu, 13 Jun 2019 01:23:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzWnBV8OUnOpFQ8a35dqQ2YR01CH9+oSQcraH/kk5CfKgkzHSn75BddsntN06/JLjomeGLG
X-Received: by 2002:a50:b6ce:: with SMTP id f14mr70527376ede.236.1560414199470;
        Thu, 13 Jun 2019 01:23:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560414199; cv=none;
        d=google.com; s=arc-20160816;
        b=MAlktH2vFKL6F8GECtU9yS9utfy3fdSxuivcHHLWJHRynn5MSaP4+hW67L2wknjBqQ
         jWTSM/ozdBkgP+W0RN//XJnAD4NGpxd8lHFGteRD8Gzaky+Pj/8SEOSymOAAhxdc+RWE
         powywIfheFAod68iYdDYliX/Yvf5V9cnv2l8Lum0aL/fy0MnYY+QD1Yz7aoQBI2K9RB1
         d1rDLKEYIIeL6YQULnB1qNRsKHI0R6zNQ3WpfjUBk0NqrZxkpLw3haW0L4cvG9QLarrw
         N31QyDCNpjJWTcK1TVb7G3OYCQw/kOaxMu77yXjh4A+iw0sG9HJOSZlNrRE6LdEhv2Ly
         LH/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=qShYouWOrO2P4M1ZBJfQCzwSFQ7+BKHcrZX/LY1rQuc=;
        b=kb+NVUtnQPqLSd86cUHQ47gzdF3ydLPc5c3bgSnOHva+tNnwIx9ZO1aeaUKFxkOJSX
         P9+OhMIFWuZr3UhIRr6CbANtOMDKfzFBvy9gYVXOrcyGFf2Vvcxv5A6uN7FkF9jXaXO4
         fDKrNFwmvjmJ4AwKui4k8usMCpdWr9+bf/p/EJdtAPECVWAsMGDnoeRqlOxD9/926TJN
         PaOJwyru06NF4RRRMbkX52pWM5hFVA2cbsRtJb2D9xftCzwdcLb0RIQtFATabLv71lWr
         /5Vm6uukCXgG/7FLeoafhviN61gp/DBORziInb5sKpXHvCZvt72O2eTDPBWmot61XHUc
         toZA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z5si1596536ejb.106.2019.06.13.01.23.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 01:23:19 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E4C40AD5E;
	Thu, 13 Jun 2019 08:23:18 +0000 (UTC)
Date: Thu, 13 Jun 2019 10:23:18 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Joel Savitz <jsavitz@redhat.com>
Cc: linux-kernel@vger.kernel.org, Rafael Aquini <aquini@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>, linux-mm@kvack.org
Subject: Re: [RESEND PATCH v2] mm/oom_killer: Add task UID to info message on
 an oom kill
Message-ID: <20190613082318.GB9343@dhcp22.suse.cz>
References: <1560362273-534-1-git-send-email-jsavitz@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1560362273-534-1-git-send-email-jsavitz@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 12-06-19 13:57:53, Joel Savitz wrote:
> In the event of an oom kill, useful information about the killed
> process is printed to dmesg. Users, especially system administrators,
> will find it useful to immediately see the UID of the process.

Could you be more specific please? We already print uid when dumping
eligible tasks so it is not overly hard to find that information in the
oom report. Well, except when dumping of eligible tasks is disabled. Is
this what you are after?

Please always be specific about usecases in the changelog. A terse
statement that something is useful doesn't tell much very often.

Thanks!
-- 
Michal Hocko
SUSE Labs

