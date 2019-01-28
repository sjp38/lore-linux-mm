Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D8DBC282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 18:42:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F58F2171F
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 18:42:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F58F2171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C59648E0007; Mon, 28 Jan 2019 13:42:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C07E38E0001; Mon, 28 Jan 2019 13:42:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B1F5B8E0007; Mon, 28 Jan 2019 13:42:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 53A188E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 13:42:34 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id y35so6953656edb.5
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 10:42:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=DiTKigtw2nRgJUfNYt3ETabGY0wKEgnAgUVDeaXMepo=;
        b=IOsqRW3cTbcGucFx2oSRT9j+zUohEBZ+MMZO3vN+1w1YjCIReuoa1KvEdaypHVVrpS
         hzXEoSjrJmshQ+yFKAxR2qAo1X8z2N2zzL3vldhzCYSv27dn5gC8FcOtwl4OMpgq27TO
         5TMI9NkN9ZzYeU0rgAWV2daJV9r/gSw9Aae0403sTKbBMmBxRPNYmdhgr7YKwoNq679m
         c1Eq2bDBiXDj63KVlFv3c/2neY7AzcwVER/ZI/F9w/f1cc5rCy1NDr8sOj8PgXd8OkUp
         JycqCdafhvzyRlrRJOVqBtkXWGgOE/8YarBgq/FYoy7O679oCjIWZodZW3t8wfQAjfBP
         fpZQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukcgplPMZBVLZn3lHPj3B2tRfOrJbv67968GmEXQaQofekK5ZGoh
	61wsTcXHaxbNeZpd7TOKxY6WUvHWD369Cer8lDZMomBiye+YDABkVmCynsTAXEPaLzvsLYNQWgT
	0a5K2dxW0LmOv8bET4nTKPSWKNV4pPifI6wzzndPguCCNJP7pQ7itwsM7MWCt3cw=
X-Received: by 2002:a50:f098:: with SMTP id v24mr22606558edl.78.1548700953830;
        Mon, 28 Jan 2019 10:42:33 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4i3h3YHUByoYsMoFhipZCIAiOTqI1z5x0DUHuQbe+yEQArvL0l60wUhRO4mBvqJQ5BrqKs
X-Received: by 2002:a50:f098:: with SMTP id v24mr22606529edl.78.1548700953090;
        Mon, 28 Jan 2019 10:42:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548700953; cv=none;
        d=google.com; s=arc-20160816;
        b=UDloGBMFaFxMA5EhIkBeSKpBkYISQC7qWr8NC2/x9JG+V2S1WXphbZ7anVJt0bURg1
         xGSMQQqqYC9/49sHtBtfFdIvy6PEM7CL9CwDUJiseiwiUvjWnHODO1e1jmmU1pSItnCR
         1iCppCrNR4YzPNjPDfDfYYTxR0stfjckiFXzjQBIkS+cjhAn07H2CUzEbTOam0kgkTYW
         gcv3lpdQJGiV00WVt31ltiysG7r1wxhxIB/uzWRkMi6n6wqhaKxOylFR/DLE8kjy37Us
         CRRZG4yzaO8prKNvgnWykzLHHgSzAxM0eFKUUy6mTpvbgiSl11GY+2rg8QyIGzgEgMNZ
         0NGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=DiTKigtw2nRgJUfNYt3ETabGY0wKEgnAgUVDeaXMepo=;
        b=m+MyxHPrcUd5HbiTuC1zDIi4vWNknxLLzf/v6yR8IkRoNf/Eq1/utVqMsEuu9qbn88
         /0A3P84cp/HT3zWDOPZejqOy75yXy3zKxzLRzr38RZff7+wavtmsLvQwSObU5uipVRAp
         OVflNEAufBQkHxdrslU+27IngnQCLobqU57ra0L3jqLm+as1ATddegR3fWpDttffI5so
         oP6+zTCWGDw1ZvFV6JE4hq+bgiemG0j+laTSN3z7fQMAm8ksfklAvN8JVEMzw3G5BA6t
         3dKH3GBoC1FBNjbcQQ0PM1YnV6hSPL1oaCqGAnZDRe8MBNEf71YZGFq9YyGdQx1r2l6b
         8m6w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f47si2926246edf.53.2019.01.28.10.42.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 10:42:33 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9FB8EB017;
	Mon, 28 Jan 2019 18:42:32 +0000 (UTC)
Date: Mon, 28 Jan 2019 19:42:31 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Arkadiusz =?utf-8?Q?Mi=C5=9Bkiewicz?= <a.miskiewicz@gmail.com>,
	Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org,
	Aleksa Sarai <asarai@suse.de>, Jay Kamat <jgkamat@fb.com>,
	Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>,
	linux-kernel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>
Subject: Re: [PATCH v3] oom, oom_reaper: do not enqueue same task twice
Message-ID: <20190128184231.GS18811@dhcp22.suse.cz>
References: <72aa8863-a534-b8df-6b9e-f69cf4dd5c4d@i-love.sakura.ne.jp>
 <33a07810-6dbc-36be-5bb6-a279773ccf69@i-love.sakura.ne.jp>
 <34e97b46-0792-cc66-e0f2-d72576cdec59@i-love.sakura.ne.jp>
 <2b0c7d6c-c58a-da7d-6f0a-4900694ec2d3@gmail.com>
 <1d161137-55a5-126f-b47e-b2625bd798ca@i-love.sakura.ne.jp>
 <20190127083724.GA18811@dhcp22.suse.cz>
 <ec0d0580-a2dd-f329-9707-0cb91205a216@i-love.sakura.ne.jp>
 <20190127114021.GB18811@dhcp22.suse.cz>
 <e865a044-2c10-9858-f4ef-254bc71d6cc2@i-love.sakura.ne.jp>
 <20190128101513.f35752d6210f0781d0de8d17@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190128101513.f35752d6210f0781d0de8d17@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 28-01-19 10:15:13, Andrew Morton wrote:
> On Sun, 27 Jan 2019 23:57:38 +0900 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp> wrote:
> 
> > Arkadiusz reported that enabling memcg's group oom killing causes
> > strange memcg statistics where there is no task in a memcg despite
> > the number of tasks in that memcg is not 0. It turned out that there
> > is a bug in wake_oom_reaper() which allows enqueuing same task twice
> > which makes impossible to decrease the number of tasks in that memcg
> > due to a refcount leak.
> > 
> > This bug existed since the OOM reaper became invokable from
> > task_will_free_mem(current) path in out_of_memory() in Linux 4.7,
> > but memcg's group oom killing made it easier to trigger this bug by
> > calling wake_oom_reaper() on the same task from one out_of_memory()
> > request.
> > 
> > Fix this bug using an approach used by commit 855b018325737f76
> > ("oom, oom_reaper: disable oom_reaper for oom_kill_allocating_task").
> > As a side effect of this patch, this patch also avoids enqueuing
> > multiple threads sharing memory via task_will_free_mem(current) path.
> > 
> 
> Do we think this is serious enough to warrant a -stable backport?

Yes, I would go with stable backport.

-- 
Michal Hocko
SUSE Labs

