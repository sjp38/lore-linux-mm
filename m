Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98447C43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 13:00:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6030720449
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 13:00:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6030720449
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EDC4A6B0006; Thu,  2 May 2019 09:00:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E8BBE6B0008; Thu,  2 May 2019 09:00:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D7AAE6B000A; Thu,  2 May 2019 09:00:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9EAC06B0006
	for <linux-mm@kvack.org>; Thu,  2 May 2019 09:00:36 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id 18so1029143eds.5
        for <linux-mm@kvack.org>; Thu, 02 May 2019 06:00:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=rkWR9X3/gvNJuqhYdo8wHnyssnAbedXHHTz/2HdMD+8=;
        b=jtmwitPu6zAb4Xipq+e/w4VttE8gNIyF7xTi5+2UqC896yC8HqceYjUzYC5khpAzB0
         J9ltsFhh9YtcFgToUC6dTLCKXLw4kLiy+UxpFZUO7de3dwuliAAbM4nLxRYgCWewSBiD
         JodVljiQTuZRW1zhOJHDxKUN/ol/EEZCBabTAQLg+ZGIRcQ7zKMxmMgbbN/am8sd6VrB
         sXFcCHyHFHXGmt1p3yGaQj5v9Fmb8+FKYQ/nS1f455E6jbtrTbfWRyKCLUraidqZfXwa
         j3HXdg1ndcdC2bMn0r/YIS8fk3Zw1ypfGAW0MKP454CBOYFPhWTTbpxA5OAfne8FkUwp
         hkbA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVyuYGfVs/TrSGKWh+6Xhf5/ybIJiMf10MOfM0x7Ja4NyHmwEjo
	zd1t/dcu4QASU25jKiIHj2hQMlfiy+Te+YEH639gDXQshqsKuXdsJHKblGpfvMh77qCmJDGmxcr
	zVYha8IlY27WBh/0C36OTfmD6rpem/j2u32lFAVlFpm7ZFQl6LB567K8nevH/Ozk=
X-Received: by 2002:a50:8c24:: with SMTP id p33mr2546912edp.210.1556802036166;
        Thu, 02 May 2019 06:00:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzkaaW4U6+kSf1UrNLevmHZuNbZM4wyiSIOXcbRlPo1Zqz8BFRTpkNvRBTy7YNa4Aq5MqdJ
X-Received: by 2002:a50:8c24:: with SMTP id p33mr2546866edp.210.1556802035366;
        Thu, 02 May 2019 06:00:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556802035; cv=none;
        d=google.com; s=arc-20160816;
        b=Zrsf440d3jUq9zUVBnlcAb1+lc+LOv9ZKNbwRrSHe/85PjHtL7Dl+OZR75U3sJqPXk
         x8BepT7fN2vLouCA5leZown2v9seHe32vkWvTJBydLezzmG9gjn+foWUhMmuFKzSY7Xh
         bbO3UZuJ3JGOU6iZGz+f/7OxsY0/X/zWIWZ8lXK806zY7IgQ5uu+kPycDY3EMml8clPw
         +Wf4ipVlvXOk4T4qf1jzk0BF+/Wl4iAjiiL+2WjnDp1pTxDqEXg5yplSx9m+PBOi510M
         OdLeTLo5jeekIh3+xA5gALIKv4hrRGuSB8x5COlXSQQ1lwANzlql405f3g3zDX5rh5ne
         bOeQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=rkWR9X3/gvNJuqhYdo8wHnyssnAbedXHHTz/2HdMD+8=;
        b=ePRQqkjyjOlmSQ1qsfLQ9uJKbf7Ohr5NWbD14WkS0bo5Mc7Z0oDhEoPb/qIInaKpDK
         rmrcVMbBZhfwzcKSJmIXJBe5CrsA9XvMWsmRoRTP7SI5wWzjyHF32mVjvPyf016oItq/
         hSKHoOT9/SBmMAY+059D8u8Wg4hSUPh8J8Avu8C1zTE8IM4SaXPr6QxikYWIG/DTy8ye
         7hzNk/XuutZacYeocOsO2/rCMkmoT3ef73Hibn6YDlZwFQvIQaZPlKGtS4orWDhSd1Ro
         e3QEmG+aJjzQoyf6AiPQAfsF23KpxnhWKBSKJLlZr1ZH0Wsl91KaoDbuHbhmizgWIPs2
         1G8g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v4si5017690edj.322.2019.05.02.06.00.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 May 2019 06:00:35 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7A7E5AEF9;
	Thu,  2 May 2019 13:00:34 +0000 (UTC)
Date: Thu, 2 May 2019 09:00:31 -0400
From: Michal Hocko <mhocko@kernel.org>
To: Barret Rhoden <brho@google.com>
Cc: linux-mm@kvack.org, Pingfan Liu <kernelfans@gmail.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Peter Zijlstra <peterz@infradead.org>, x86@kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Tony Luck <tony.luck@intel.com>, linuxppc-dev@lists.ozlabs.org,
	linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 1/2] x86, numa: always initialize all possible nodes
Message-ID: <20190502130031.GC29835@dhcp22.suse.cz>
References: <20190212095343.23315-1-mhocko@kernel.org>
 <20190212095343.23315-2-mhocko@kernel.org>
 <34f96661-41c2-27cc-422d-5a7aab526f87@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <34f96661-41c2-27cc-422d-5a7aab526f87@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 01-05-19 15:12:32, Barret Rhoden wrote:
[...]
> A more elegant solution may be to avoid registering with sysfs during early
> boot, or something else entirely.  But I figured I'd ask for help at this
> point.  =)

Thanks for the report and an excellent analysis! This is really helpful.
I will think about this some more but I am traveling this week. It seems
really awkward to register a sysfs file for an empty range. That looks
like a bug to me.

-- 
Michal Hocko
SUSE Labs

