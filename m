Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96F51C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 10:01:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D37620C01
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 10:01:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D37620C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E098A8E0005; Wed, 20 Feb 2019 05:01:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB9338E0002; Wed, 20 Feb 2019 05:01:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD1418E0005; Wed, 20 Feb 2019 05:01:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 75D458E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 05:01:08 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id s50so9695874edd.11
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 02:01:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=kIbaayqcTqDxXJiR9NKrX8YM4v1xIloPcs5M9fysmUA=;
        b=WVXUr/D5Vhz4FAnMmdqwCy0AawzIaB8hOGgV1CEY86tkp5cJGz36ilrdfBFISAChv3
         4/IkLmq/J3PreM4/2pMh94y+0XwTNnYVLOv5vva8PH8dzG0RGPvnKXXyB1oKCrALroWn
         g/7M5SD6nMiIUu+X9ctq9ReNfUnvQYb7Xn3QdKdaFL2gr2jSaCgdtrKyjKTKqMyg8CFA
         90+5f0YPgIDnTqN/Vo4TSls7VSdJlto5lHqU1aOt3R28GOIqjp7hW2TQ3kIiBSeUu/4Z
         u2XC83+WgLSAJ1tuyP0olLUJBJviAS1SQWezAREwckW564K2YHpwxUbLiN5RsdkgfWYW
         7eyw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuatT3qQnyotwzJvI0IqjvZpiwkts2PhEja4zQ18thMPtGdTcqaD
	e3iyk8Ww4QoPFZOJ4ox5M2qoEcPvw7x199dJ2Carzn55BCh6X2VgS26ZOPfyO2QrSxoB2qkvgk7
	tvIAom77KEQNlVZ9XzjKlqNy2WNQmHm+OZxKE/l71cMGRWmoR5MTBck/JUDeNEc8=
X-Received: by 2002:a50:d98a:: with SMTP id w10mr27731077edj.81.1550656868036;
        Wed, 20 Feb 2019 02:01:08 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYn575RPzJp0m8pOO7q7j3atpDHSNQ96NYCSQQnS8GFC3whnd3Clv2LMj1hxf0o2YDFiYTJ
X-Received: by 2002:a50:d98a:: with SMTP id w10mr27731033edj.81.1550656867282;
        Wed, 20 Feb 2019 02:01:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550656867; cv=none;
        d=google.com; s=arc-20160816;
        b=tbVLQok1ksdey8NUtoLypHPAbtjwJmsW4hP+XAh0AqcEX4jq7vmwgGvn74hRTqprd9
         b/WwR32TvvXsC9d2yyJb0yyDw88TxWunZROBBz6HiYaH7JgrXtpBLd2z2XyMGabxtga4
         kqzzRTx1R2dWchPL/NXDUAqhTJrC8QLt1Su6aVQ7g2KUxYGvvZb0TSKaYhLww0vCnnbt
         PJCAISNh8QpWTMhHTJLqFVEuIoN35LMnJh2JC+OGwZUBj5UIJ3fBRilHP87PBewDFuiG
         iGNdbOiqwbqSEk+F0FoVq8bcw7649eMc3yNyLuAPhjuzIU/rDuys7A1Fo3zJgbKly5TM
         V28A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=kIbaayqcTqDxXJiR9NKrX8YM4v1xIloPcs5M9fysmUA=;
        b=OIMpPi0IBn1mPrjByc3TJS1bOK5nkk7q2r8Wl6t/nM4Ndg+6TcCGTMl2hTYxpdpYoZ
         +WVqioF4BXFl369JXpL6HndDbqhR+d/zZ7GVjbdO5rg9Ae7OmrW84f1muGsSf0x4zUzM
         +M7F7Fv9Ek71TlEMlf1xWA/9te9j4hp6u5nJVQVX8qtX4iMFky9noN9segqhDnH3x5nY
         AAPPs22QYXWg81XPOjTm1YpwalvY27wFH7UdfmouZpfQrUZZAh5PpcD2FfIs9e0KPEbY
         RP1JvZR4CQAE6bGCWPDTQIML5ZNkqArA17IfskWeLibyuaGLCIaZvarYVdOBC+sIRYIF
         eMJg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o36si805339edc.220.2019.02.20.02.01.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 02:01:07 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D36D9B624;
	Wed, 20 Feb 2019 10:01:06 +0000 (UTC)
Date: Wed, 20 Feb 2019 11:01:05 +0100
From: Michal Hocko <mhocko@kernel.org>
To: "Bujnak, Stepan" <stepan@pex.com>
Cc: linux-mm@kvack.org, Jonathan Corbet <corbet@lwn.net>, mcgrof@kernel.org,
	hannes@cmpxchg.org
Subject: Re: [PATCH] mm/oom: added option 'oom_dump_task_cmdline'
Message-ID: <20190220100105.GW4525@dhcp22.suse.cz>
References: <20190220032245.2413-1-stepan@pex.com>
 <20190220064939.GT4525@dhcp22.suse.cz>
 <CAFZe2nQW3mUGgSVndzmPirz7BkVUCEyjt=hgxqFn=bntrCsC8A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFZe2nQW3mUGgSVndzmPirz7BkVUCEyjt=hgxqFn=bntrCsC8A@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 20-02-19 09:37:56, Bujnak, Stepan wrote:
> On Wed, Feb 20, 2019 at 7:49 AM Michal Hocko <mhocko@kernel.org> wrote:
[...]
> > You are trying to allocate from the OOM context. That is a big no no.
> > Not to mention that this is deadlock prone because get_cmdline needs
> > mmap_sem and the allocating context migh hold the lock already. So the
> > patch is simply wrong.
> >
> 
> Thanks for the notes. I understand how allocating from OOM context
> is a problem. However I still believe that this would be helpful
> for debugging OOM kills since task->comm is often not descriptive
> enough. Would it help if instead of calling kstrdup_quotable_cmdline()
> which allocates the buffer on heap I called get_cmdline() directly
> passing it stack-allocated buffer of certain size e.g. 256?

No it wouldn't because get_cmdline take mmap_sem lock as already pointed
out.

Please also note that the cmd line might be considered security/privacy
sensitive information and dumping it to the log sounds like a bad idea
in general.
-- 
Michal Hocko
SUSE Labs

