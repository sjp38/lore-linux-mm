Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C5E9C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 13:12:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D9374217F5
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 13:12:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D9374217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 746938E0003; Tue, 26 Feb 2019 08:12:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F6508E0001; Tue, 26 Feb 2019 08:12:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E79E8E0003; Tue, 26 Feb 2019 08:12:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1BE6C8E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 08:12:10 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id e46so5493708ede.9
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 05:12:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ODsuJT4y1MQ7R3t86IHmD0j5yAxPxc/U06+Vp2UIHLg=;
        b=c3Nj7NdqECVx6/DD6jjTMihGhb/s1yZFigGCPiN2X1GlKz0B0ffC9QGA+laTMYTJ9x
         OS8s4N1X2SY8IoZtQaNrg5/4l1+rVK+789eBeXTD2nNx29v9LSVnaifMq+LgD0Elex/A
         SBmAGTmPEKB+hc0HeNwCK1k2EAJxxiIecyfXxg/siPR5G3ESj7e1Mw2bizXqK27TOkIA
         YTr0lYWJ7ZiF4vp33dYTW9Sq4y5DqmJbFQjUWJECelbVXz9+RYmlcVro71RpYY+kj4fu
         iMCCX6dlOyvOtTbOP27KY2H8lLK6Rp0S2QSzmrq5Y04nH7qNm2zgvha8EaIEeQ+mnjOT
         KGnQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAub5+FNooCRl1W1EPIsLmuR++Az+/ldG2H4QyYOLY1klOE1IQb6f
	ZJoAEcYC+//YVRhowB75UlDKSjFdH8tYzIRiXVgq1EfHzH27W0ZX1X6VrJTC+8lCudMQwrxfntH
	S5qu03jwbeS8reWxSIIo2xHXbeCZffU+ClGfgvy7iw5HPB/zrReiGQho2M4S1y8s=
X-Received: by 2002:a17:906:b6d6:: with SMTP id ec22mr6291264ejb.163.1551186729682;
        Tue, 26 Feb 2019 05:12:09 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaJ+cFFQu3RVTovtudLP+21Dna2Yt+xCaEEVDLz7hBF5H/FUICmkeAJFNbnlafHwEk+ZiOj
X-Received: by 2002:a17:906:b6d6:: with SMTP id ec22mr6290890ejb.163.1551186722766;
        Tue, 26 Feb 2019 05:12:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551186722; cv=none;
        d=google.com; s=arc-20160816;
        b=xvajhQyyUJvkwbiYAnlVUuz0cU2Yi0RcxAPzhQJi5Sz10Umue5bpmzxqXEKbfii3x3
         PKXRBTYFOO5N2ZaCP0x2KtUlmYD9QxZD4vwGQDCZcBK4sqtM5W9eMUfuNcjHHf2S85dy
         nS5P3QnzX2ueYGZnlJrFnKuJUaSjKuw1v9/Yute6M/1epSR7m9Racbx88ZmT2cdg1LG0
         dfXwlJI9C/j6nmWeJT/NbBkweKnOJ3UionBoiMLwQtETKdTEb1TppOwxInYhfV7FyMRG
         q6SmmW6+Xodw8LEQiof6xq+xgLaWAiywAhgwPtxeUb+w+rWHbtGBD1gfe2qkYaK9X6TR
         mvJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ODsuJT4y1MQ7R3t86IHmD0j5yAxPxc/U06+Vp2UIHLg=;
        b=skxXFypcmL2UtmYQv6uKdhFUiUJPfYWStU1Nym2r+YKGSGTTPgsWYI6PlwHAactDm8
         ixNu8mOX5DGdWwb6MmPlOiXQMBR2WNipHuS/yadXL4l13I2do1cfKsbqOgyjbSEcR9sl
         KvoGgTFk0ZV+o4iZnUzygXRwRzob+84ubE9ZYSa/ww32hI/senbj1yS4SfQwyC3B7Eqt
         3Wb/lWWCQPZOjydLVHn1OiXjlGL7QmQo+s0PhqDOKc0cOXIqqBwRu19PjW+zyzrsGczS
         SagMYcfphWzytunxBAdNc50Q/gp74MIY5C14V59n3b6geiFAS2W56mk7YKsuG8FrmM9r
         C2Tw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g11si2145456ejd.263.2019.02.26.05.12.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 05:12:02 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1D6C1AF72;
	Tue, 26 Feb 2019 13:12:02 +0000 (UTC)
Date: Tue, 26 Feb 2019 14:12:01 +0100
From: Michal Hocko <mhocko@kernel.org>
To: linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>, Dave Hansen <dave.hansen@intel.com>,
	Peter Zijlstra <peterz@infradead.org>, x86@kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Tony Luck <tony.luck@intel.com>, linuxppc-dev@lists.ozlabs.org,
	linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 0/2] x86, numa: always initialize all possible nodes
Message-ID: <20190226131201.GA10588@dhcp22.suse.cz>
References: <20190212095343.23315-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212095343.23315-1-mhocko@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 12-02-19 10:53:41, Michal Hocko wrote:
> Hi,
> this has been posted as an RFC previously [1]. There didn't seem to be
> any objections so I am reposting this for inclusion. I have added a
> debugging patch which prints the zonelist setup for each numa node
> for an easier debugging of a broken zonelist setup.
> 
> [1] http://lkml.kernel.org/r/20190114082416.30939-1-mhocko@kernel.org

Friendly ping. I haven't heard any complains so can we route this via
tip/x86/mm or should we go via mmotm.
-- 
Michal Hocko
SUSE Labs

