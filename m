Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D75FC06510
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 13:19:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4209B2064B
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 13:19:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4209B2064B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C6CCC6B0006; Tue,  2 Jul 2019 09:19:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF61A8E0003; Tue,  2 Jul 2019 09:19:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ABE3A8E0001; Tue,  2 Jul 2019 09:19:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 708616B0006
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 09:19:45 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id c18so9603937pgk.2
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 06:19:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=TYxYbF56mVxGIzRpP0XD96mozOC+LJeOLik+7OWJqFs=;
        b=PV82dq2O7pFk7YE56N+e/eTgUuBhGydqH87ZbWRHwpEaEK1q3QneI1tFODAMmS1JGs
         VXonVR3X9AQniupaBlVQOfcKmxHjotBujsqeAIP1I1is5nZbE7MdtklxdWeVhx0ywBqK
         bwRSzTgaOPtAiWQQoTsNM5sWcj385s8P2Q0i3pj/Wpl4Ekp1EpAWYO2yWDdtJlkeu/GC
         o4FxQvNCMadV4wPsY0WxSGQdDPp/l9pXFduic6fZXF9fc6NhRCz6rsddwGDsBrdiaRp/
         /TlXyvTDX4nZ+Cy3LBCfDpXPJuytwGTsj0QVfSgK5rgH7u/S4Qu9LrS8c8Q+dnfnTpck
         OfKw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAXJrTZVrZ7jwla6ooflWQGsSCV80qNJvnOb+1Gv/CRRPNUbfu94
	ty1kS3IpyJYKIdP+2rbrPLgRNQl5/hoQow7OdGz8KLSCx3NcnHm3OQitizR7PkWoO2TJXXi4l9U
	OSSrDJaXUc3FRVVQfXMaLiSJTkYJA7fZQdbymniBwmiOtbqYHvDpZpBZ/cemnCgAk5w==
X-Received: by 2002:a17:90a:26ef:: with SMTP id m102mr5553252pje.50.1562073585147;
        Tue, 02 Jul 2019 06:19:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyNggPrsk7QdPZuxTIkxFoikQiYV8m2c081pzoXzF2bjYZOICcYyPRSWJL654Hsf/QJEG8Z
X-Received: by 2002:a17:90a:26ef:: with SMTP id m102mr5553188pje.50.1562073584393;
        Tue, 02 Jul 2019 06:19:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562073584; cv=none;
        d=google.com; s=arc-20160816;
        b=SR+pBTCAaCVYW+iEScuvDMwuJWyMEqs4nf0sw3fdHhuRZjRxEG9EXSfozH+umcyt0v
         Ov8FKa76iWtwEDmRacu3PGDyyD2ULhIxQfZKEyJ5w1q7iTwiGpCmwOE5tV7PboBdAs2J
         k+jkELpo+Bhqp3Xs/CATxAOF4WZoqxSCqOm+AbKxoDZiZticyzxpC9bAg/FPxPILjiGN
         16YSYW4D33hv5AhiNb8Nij3fXPGy2ll85yVK291PGgszEmyYaDidgiYxv4GydXtk2nYW
         DRmGLezltc0owCV8UqyMJU1HnJkdZfHznO/4J378ZaX3iP6fFrz16Wg7qLrUu4bOJbVg
         Hlxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=TYxYbF56mVxGIzRpP0XD96mozOC+LJeOLik+7OWJqFs=;
        b=poLNyD/UT0EMyQUjy4o7O4PgxfCbiWOLm2uUKfCehkoBs6uV4CMKCcTdATJ1Ok+SBt
         lNhhgYRDzYpK1yWFox2NsjuXaulKjerpezQyex78OgmoPBzN7l2sKO44tK4RO0rMWwzn
         M+rExNlbi88Thnr171bmR4fWRw7j8gtjkVygNxBpxV4K0zvgGEpcn6oyzY3adOCPjlgP
         jFW9ByeAC+g9zU9Gu2c7eENMGzTC34IMtyR2J+0gJA0ObUVkRZCevk7Rv37Tc9FgIIRl
         B1pxxqxYq6rdzRmRSEh7eM4w0RD2vVDombi+RGb2aZaDqHUK3Au73aR9RkdGkBdMaotl
         TEwg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id u21si12593405pgm.431.2019.07.02.06.19.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jul 2019 06:19:44 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav303.sakura.ne.jp (fsav303.sakura.ne.jp [153.120.85.134])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x62DJanh095690;
	Tue, 2 Jul 2019 22:19:37 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav303.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav303.sakura.ne.jp);
 Tue, 02 Jul 2019 22:19:36 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav303.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126012062002.bbtec.net [126.12.62.2])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x62DJV3T095658
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Tue, 2 Jul 2019 22:19:36 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: [PATCH] mm: mempolicy: don't select exited threads as OOM victims
To: Michal Hocko <mhocko@kernel.org>
Cc: Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org
References: <1561807474-10317-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190701111708.GP6376@dhcp22.suse.cz>
 <15099126-5d0f-51eb-7134-46c5c2db3bf0@i-love.sakura.ne.jp>
 <20190701131736.GX6376@dhcp22.suse.cz>
 <ecc63818-701f-403e-4d15-08c3f8aea8fb@i-love.sakura.ne.jp>
 <20190701134859.GZ6376@dhcp22.suse.cz>
 <a78dbba0-262e-87c5-e278-9e17cf9a63f7@i-love.sakura.ne.jp>
 <20190701140434.GA6376@dhcp22.suse.cz> <20190701141647.GB6376@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <0d81f46e-0b5f-0792-637f-fa88468f33cf@i-love.sakura.ne.jp>
Date: Tue, 2 Jul 2019 22:19:27 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190701141647.GB6376@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/07/01 23:16, Michal Hocko wrote:
> Thinking about it some more it seems that we can go with your original
> fix if we also reorder oom_evaluate_task
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index f719b64741d6..e5feb0f72e3b 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -318,9 +318,6 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
>  	struct oom_control *oc = arg;
>  	unsigned long points;
>  
> -	if (oom_unkillable_task(task, NULL, oc->nodemask))
> -		goto next;
> -
>  	/*
>  	 * This task already has access to memory reserves and is being killed.
>  	 * Don't allow any other task to have access to the reserves unless
> @@ -333,6 +330,9 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
>  		goto abort;
>  	}
>  
> +	if (oom_unkillable_task(task, NULL, oc->nodemask))
> +		goto next;
> +
>  	/*
>  	 * If task is allocating a lot of memory and has been marked to be
>  	 * killed first if it triggers an oom, then select it.
> 
> I do not see any strong reason to keep the current ordering. OOM victim
> check is trivial so it shouldn't add a visible overhead for few
> unkillable tasks that we might encounter.
> 

Yes if we can tolerate that there can be only one OOM victim for !memcg OOM events
(because an OOM victim in a different OOM context will hit "goto abort;" path).



Thinking again, I think that the same problem exists for mask == NULL path
as long as "a process with dying leader and live threads" is possible. Then,
fixing up after has_intersects_mems_allowed()/cpuset_mems_allowed_intersects()
judged that some thread is eligible is better.

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index d1c9c4e..43e499e 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -109,8 +109,23 @@ static bool oom_cpuset_eligible(struct task_struct *start,
 			 */
 			ret = cpuset_mems_allowed_intersects(current, tsk);
 		}
-		if (ret)
-			break;
+		if (ret) {
+			/*
+			 * Exclude dead threads as ineligible when selecting
+			 * an OOM victim. But include dead threads as eligible
+			 * when waiting for OOM victims to get MMF_OOM_SKIP.
+			 *
+			 * Strictly speaking, tsk->mm should be checked under
+			 * task lock because cpuset_mems_allowed_intersects()
+			 * does not take task lock. But racing with exit_mm()
+			 * is not fatal. Thus, use cheaper barrier rather than
+			 * strict task lock.
+			 */
+			smp_rmb();
+			if (tsk->mm || tsk_is_oom_victim(tsk))
+				break;
+			ret = false;
+		}
 	}
 	rcu_read_unlock();
 

