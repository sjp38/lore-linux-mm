Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B80F6C31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 14:17:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 863AC20873
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 14:17:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 863AC20873
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 20C306B0003; Tue, 18 Jun 2019 10:17:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1BD0B8E0002; Tue, 18 Jun 2019 10:17:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D2B68E0001; Tue, 18 Jun 2019 10:17:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id CADF96B0003
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 10:17:04 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id f2so7847446plr.0
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 07:17:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=ZggU6rAAlwRzghmE4Z3QeunDYOExewKogviPMrAz7Pk=;
        b=gVOR7GUKWuM2oHYJUSC2yAvyoZIcrX1U8cgO+/HR098UQnp0hxaI33Z8tnNYy/Mr+K
         gSJqGeMXOgxsc7lB+zP7J/DTFKpssZBIAc55bKrWi/Ss66Yn/bCqFnaXBmjEG0ZEKWg7
         wEQgAfL7KH1PTbzQYJ5ADQ0Z3yRhdjVJrh4S9L8TyT5W3vAhvOw/Z/6t3teUZ5b65+Vd
         tkyqDwp23N+0wji927SIa6tRIOCpnhOpDPJblvJkfRIcBZKr3G3EIRDfAGyOxd8jpJbd
         wWiXDYkkvVB3SthFOgyTdXAtfXCaO1nd2rcxSpFkRvZCKsKevycLV9C6c0FNDLjCOMmg
         SPOA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAV/q/qBXEoHIQ5ai1lmb0Jeec2YHvz6TJqQ3Gnt/PAM1c7tG7Xz
	GEUBTmZ+HViYwk9Vs+Ppa/0NFCR+OwIi8bfHiAhv2QRGavdVcYtkLFR9CFT7YQP2Dsw+KG/Qtkt
	jBxS8TQyPDSfUcYcWgkMFt69RX/DYkt5/EffURrpTePaImdGYY18CMzjaSMXfKt77yQ==
X-Received: by 2002:a65:454c:: with SMTP id x12mr2929146pgr.354.1560867424326;
        Tue, 18 Jun 2019 07:17:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxiP9ryRCgs+m2ekcP+VzbXnyXMFyypRfXOpF0VjAn303awKvCarMki5HXqRNp7asa5yqQc
X-Received: by 2002:a65:454c:: with SMTP id x12mr2929084pgr.354.1560867423582;
        Tue, 18 Jun 2019 07:17:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560867423; cv=none;
        d=google.com; s=arc-20160816;
        b=GPid/+QUqVTbabiwemjPNBeAzjGAEiL9ocaeUwgUqKcsaB/3gWTSGWGLrnOzEPqv9t
         Mxw3mwT4yuYMorzZcuYbXMnF5A7meF98cSkE2rCVEdGhZCbFh2Mt0k6LmdOkVvQ8ErRh
         xe+7TZs47jOShPphJC+Lz26wTfU+rtwp2+DvEX0+gARHWug5Fd1vSOwbi3KUfQaQl7s4
         iZilzrt6GyzLac+vlWtdb+70G7ZBXIeAJkPzbC1BJMTz7m4i31zgmPnimCqUvRDk0z8u
         DjBJICKDXmzxhjJHorl0zMiV/ztCUZNIiteNA1yNcZc+eMDG9fPjXWfhhSufKk6DAvno
         FiEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=ZggU6rAAlwRzghmE4Z3QeunDYOExewKogviPMrAz7Pk=;
        b=03E42yBChglOzMN0x4oNfw5cgA4iEjkdQP/BJtEkQjxqh53HlSBiLdAIzBeniQzCge
         Zk6FYk0wFq9TjuW2CaST2CogR4ag8sYBynH2RZdIv385nXkRhvTpr3WpV2ExnIPcVgn1
         gGV7IRM5t4avoiadvEwEtsD21bnP5JW02OxrsFOeVzLwDvYorF10ANL8cJtO81yG4MHt
         wJyC6UVMcZLcwkooTKYVOKdUZ6qH2lOfxLFNMSmqBI1uDOYuyZIeE7qN4vhZzq/WyKLs
         +Le+x0qE61IEHeeDHtoJl63M5dbZ5fvnWiTv8py3W+rwgLty5oxNX3kCBSPLvZeFtYYQ
         1Vlg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id d21si3788396pll.369.2019.06.18.07.17.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 07:17:03 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav405.sakura.ne.jp (fsav405.sakura.ne.jp [133.242.250.104])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x5IDNlj4031977;
	Tue, 18 Jun 2019 22:23:47 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav405.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav405.sakura.ne.jp);
 Tue, 18 Jun 2019 22:23:47 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav405.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126012062002.bbtec.net [126.12.62.2])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x5IDNfqt031932
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Tue, 18 Jun 2019 22:23:46 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: [PATCH] mm: oom: Remove thread group leader check in
 oom_evaluate_task().
To: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
        David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
References: <1560853257-14934-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190618121418.GC3318@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <f2960ffa-124f-b66d-3bfe-cc9302d43797@i-love.sakura.ne.jp>
Date: Tue, 18 Jun 2019 22:23:38 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.1
MIME-Version: 1.0
In-Reply-To: <20190618121418.GC3318@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/06/18 21:14, Michal Hocko wrote:
> On Tue 18-06-19 19:20:57, Tetsuo Handa wrote:
>> Since mem_cgroup_scan_tasks() uses CSS_TASK_ITER_PROCS, only thread group
>> leaders will be scanned (unless dying leaders with live threads). Thus,
>> commit d49ad9355420c743 ("mm, oom: prefer thread group leaders for display
>> purposes") makes little sense.
> 
> This can be folded into mm-memcontrol-use-css_task_iter_procs-at-mem_cgroup_scan_tasks.patch
> right?

Yes, if we want to do so.

