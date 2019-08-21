Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-15.8 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D85FC3A5A0
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 03:25:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4122B22DD6
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 03:25:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="CI21+U4n"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4122B22DD6
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C6D346B0283; Tue, 20 Aug 2019 23:25:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF69C6B0284; Tue, 20 Aug 2019 23:25:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC00B6B0285; Tue, 20 Aug 2019 23:25:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0073.hostedemail.com [216.40.44.73])
	by kanga.kvack.org (Postfix) with ESMTP id 8C7556B0283
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 23:25:36 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 49DA38248ABD
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 03:25:36 +0000 (UTC)
X-FDA: 75844995072.03.blade61_882c9bcbbde16
X-HE-Tag: blade61_882c9bcbbde16
X-Filterd-Recvd-Size: 5946
Received: from mail-pl1-f193.google.com (mail-pl1-f193.google.com [209.85.214.193])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 03:25:35 +0000 (UTC)
Received: by mail-pl1-f193.google.com with SMTP id d3so538889plr.1
        for <linux-mm@kvack.org>; Tue, 20 Aug 2019 20:25:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=FKWAkiDR5rSbbJHylgJX/d3UkhUAaJmc1tNEs5aP4JU=;
        b=CI21+U4nsmf7wBi8MX/lwJOeIz5A1WSv9OwVMFI4pPUD57NxZftzFB7n+uG+jcdnap
         7Glvco1VzzG0sp+eNaIgQJSrVEwLUhqbQQhap97rg2pMUAET36gee6KdYCFg+hSZsrh5
         DlBUC9OgKHP+wv1njj0zDgd/l1ClTMK1YCNfVaHcXbmZispBCRtz1T4GZZTOfWUF8uIn
         f9x/v79LEMyYOJbkz/rIiDtTMPzr4WgvI9M/kBI6/Tkz0PwTdmOQ4QIFDO07UsgUd0Wc
         O/JDhZHow5uv5sEVcx1PPobeCrnB5L1jCRsiVC7sj2II3lJRMLwT8GV61PDrfxS3GhYY
         crYQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:in-reply-to:message-id
         :references:user-agent:mime-version;
        bh=FKWAkiDR5rSbbJHylgJX/d3UkhUAaJmc1tNEs5aP4JU=;
        b=sNepE+hvuVKhrGUUI1EzMwSmGdPSTi7HsKPR9ZwPNkN4Bk5UBBtLHgmBuGLnKBiYyB
         UijmQfob45BmxUFKVGBwKguMMuYSsyGbFzjFDakSroEH4yQy/rYW1jwaGzcO9CV+EEOb
         pxBi8aywJs0pLDns59+80IzxyiZEAOZDl5mqLte3YON/NJcvKXd8OkFvfGjJl66Vhvwy
         86TO351JFNLwqY1JCT1B4YsBD8TWG/SfLwvyp3MCpG8RLHdVu2KFhMOgYxIHmEWXQedb
         iP5PhjTsHU9SZwTdXVwC+Dj01dNY+rPJZ+9z/HQUd1YM8O1CZ18np0L3s+U4SuBLY4xR
         vY0A==
X-Gm-Message-State: APjAAAW/EaNvrIPwKf7FFNnqpi0n8ZRzFpNDesZQUNRluJRgzrJk/MWa
	sY3P5FXXpapi64pEqbkR7/q3CA==
X-Google-Smtp-Source: APXvYqw7T3zbmDwzrqn0BLzf5Ac0Hjt+YjaptvIvR3GtFvAskUNeAmq+ZSMDpdGW6UVBL/ff7IiwZw==
X-Received: by 2002:a17:902:5a42:: with SMTP id f2mr32046957plm.45.1566357934258;
        Tue, 20 Aug 2019 20:25:34 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id e13sm26285977pfl.130.2019.08.20.20.25.33
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 20 Aug 2019 20:25:33 -0700 (PDT)
Date: Tue, 20 Aug 2019 20:25:32 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Edward Chron <echron@arista.com>
cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
    Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, 
    Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, 
    Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org, colona@arista.com
Subject: Re: [PATCH] mm/oom: Add oom_score_adj value to oom Killed process
 message
In-Reply-To: <20190821001445.32114-1-echron@arista.com>
Message-ID: <alpine.DEB.2.21.1908202024300.141379@chino.kir.corp.google.com>
References: <20190821001445.32114-1-echron@arista.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 20 Aug 2019, Edward Chron wrote:

> For an OOM event: print oom_score_adj value for the OOM Killed process to
> document what the oom score adjust value was at the time the process was
> OOM Killed. The adjustment value can be set by user code and it affects
> the resulting oom_score so it is used to influence kill process selection.
> 
> When eligible tasks are not printed (sysctl oom_dump_tasks = 0) printing
> this value is the only documentation of the value for the process being
> killed. Having this value on the Killed process message documents if a
> miscconfiguration occurred or it can confirm that the oom_score_adj
> value applies as expected.
> 
> An example which illustates both misconfiguration and validation that
> the oom_score_adj was applied as expected is:
> 
> Aug 14 23:00:02 testserver kernel: Out of memory: Killed process 2692
>  (systemd-udevd) total-vm:1056800kB, anon-rss:1052760kB, file-rss:4kB,
>  shmem-rss:0kB oom_score_adj:1000
> 
> The systemd-udevd is a critical system application that should have an
> oom_score_adj of -1000. Here it was misconfigured to have a adjustment
> of 1000 making it a highly favored OOM kill target process. The output
> documents both the misconfiguration and the fact that the process
> was correctly targeted by OOM due to the miconfiguration. Having
> the oom_score_adj on the Killed message ensures that it is documented.
> 
> Signed-off-by: Edward Chron <echron@arista.com>
> Acked-by: Michal Hocko <mhocko@suse.com>

Acked-by: David Rientjes <rientjes@google.com>

vm.oom_dump_tasks is pretty useful, however, so it's curious why you 
haven't left it enabled :/

> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index eda2e2a0bdc6..c781f73b6cd6 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -884,12 +884,13 @@ static void __oom_kill_process(struct task_struct *victim, const char *message)
>  	 */
>  	do_send_sig_info(SIGKILL, SEND_SIG_PRIV, victim, PIDTYPE_TGID);
>  	mark_oom_victim(victim);
> -	pr_err("%s: Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
> +	pr_err("%s: Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB oom_score_adj:%ld\n",
>  		message, task_pid_nr(victim), victim->comm,
>  		K(victim->mm->total_vm),
>  		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
>  		K(get_mm_counter(victim->mm, MM_FILEPAGES)),
> -		K(get_mm_counter(victim->mm, MM_SHMEMPAGES)));
> +		K(get_mm_counter(victim->mm, MM_SHMEMPAGES)),
> +		(long)victim->signal->oom_score_adj);
>  	task_unlock(victim);
>  
>  	/*

Nit: why not just use %hd and avoid the cast to long?

