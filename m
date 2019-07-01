Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E40E4C0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 13:17:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A8F04214AE
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 13:17:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8F04214AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2C5766B0003; Mon,  1 Jul 2019 09:17:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 275CA8E0005; Mon,  1 Jul 2019 09:17:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 18C108E0002; Mon,  1 Jul 2019 09:17:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f79.google.com (mail-ed1-f79.google.com [209.85.208.79])
	by kanga.kvack.org (Postfix) with ESMTP id C17456B0003
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 09:17:38 -0400 (EDT)
Received: by mail-ed1-f79.google.com with SMTP id l14so16722712edw.20
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 06:17:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=SlJZ+kHS7sinQNMVc1j+RfWUwscl8ySd5VU87E7QYJU=;
        b=qGp945zD3BT1QnG2jEsq97kdjIQRVNcJ8abcyYi9lcKudQNbH5x5IiTBaRO55a5yIJ
         ZRjNMogbbNrxeBF6L0ntdzpeQ1J4O58ELavZnik+VE5mqpH4GP/yHsSd4zKDT6nB1hyO
         qdfMXESqmBOjzZya86IYJiUQOZ9i+aKneKXW1ZEr49M31Yos4Na3vf7tUeFgfjhnkinJ
         95mnEYhthQsNDhTx+P43cWDvUD4l+IxVnAok/pFZgU9H3tplrtK69+tjmmTnh+bEOtVT
         lJ/SzZBniJg9Hjp56iz76CrWPr7uIfnjHFOfYVDv9sQ6/rz/UiS0VetqEN/FwQCjk2En
         frYQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAV39yiWvo9HYKgQxvDuCSQNgODQmGqQHIx/WevtX889XXEFfjyZ
	ItiOhYzEWyqGuN2oAo40nEjB7ueaAFHUnTlCevZRuwlU21RC3y+0n6D6VjJepcQn5e3krwkIVEg
	94oD/bI9G3RI77wRTlrOLGWJG2y3sdi8AMW8Srpkw83CrxWwBOHAQk2t28tpbDo8=
X-Received: by 2002:a17:906:eb93:: with SMTP id mh19mr22622038ejb.42.1561987058362;
        Mon, 01 Jul 2019 06:17:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzVdZ2GSGLrrByBz5NcNLXFhwQj1BQSAbELM8vo8ZrBC58+U1DDR6Xwqn/alwRH0n3i9Xn4
X-Received: by 2002:a17:906:eb93:: with SMTP id mh19mr22621958ejb.42.1561987057460;
        Mon, 01 Jul 2019 06:17:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561987057; cv=none;
        d=google.com; s=arc-20160816;
        b=JGHRcc6uAMu4o5Etd79D83lpvhX9Js8vDNL6xttC3bgrSp6UFFOt03Swi6CBE0PNnP
         XRiWo5TTztaQXaf5C4ivmqwH06ch5ztbY6GvQenwM0a/s0Mvxn8TV/cu5xscWnEUqkhc
         TqIbV2Ihgpex4vg37zLTaArJmlWhcs5OsKp3bRsqeBymoYMy7SQ1kULQhv0fF6L+zraE
         B2d882Qks+pTffjNpvwq6E1HgBcDFNnUZWwH6d4bhBcLq+c0zfUYaASBZ+X1mn0cIzXb
         rTpKdxwifYOcakcKou7aTxlJzGfnuJqaB/ZNAjg3ZAfeGyaQdb8MyIGF2hPmlpC9HHVK
         8tbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=SlJZ+kHS7sinQNMVc1j+RfWUwscl8ySd5VU87E7QYJU=;
        b=P3EZjRHyWA86Bne8er0NE6CbO2QLmqKeq1pZxy0dN5lLOtgbn6x2vYZxgeekf5YEK0
         46xcD0v6gIPxsbFGgEbIwJBEuSgNlefsoL4O2BZcBoDE4B4Dv77vHXKQ2CT2K7Xu5OZB
         rZJXpwJWueksSkDB8bZSuaYE+lV9/aOCZJvEtyegXN6kzIAWHniR9x4zEEoGk8tOJeZb
         t2JrwWcEFNlmoAVJSLmkbd3+VzkqRWp6Vkak/EkU6V4uHtao5YCKhutXDqlz15wlV0JT
         IA5bPewGjtaHXEuNRX+zCrwPESHOFo98u6tx8shdzz1+FOL/BUY1CC/tqJ/lfZaYCOfN
         dJqw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 30si9286705edu.170.2019.07.01.06.17.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 06:17:37 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id CBCA7AD78;
	Mon,  1 Jul 2019 13:17:36 +0000 (UTC)
Date: Mon, 1 Jul 2019 15:17:36 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org
Subject: Re: [PATCH] mm: mempolicy: don't select exited threads as OOM victims
Message-ID: <20190701131736.GX6376@dhcp22.suse.cz>
References: <1561807474-10317-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190701111708.GP6376@dhcp22.suse.cz>
 <15099126-5d0f-51eb-7134-46c5c2db3bf0@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <15099126-5d0f-51eb-7134-46c5c2db3bf0@i-love.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 01-07-19 22:04:22, Tetsuo Handa wrote:
> On 2019/07/01 20:17, Michal Hocko wrote:
> > On Sat 29-06-19 20:24:34, Tetsuo Handa wrote:
> >> Since mpol_put_task_policy() in do_exit() sets mempolicy = NULL,
> >> mempolicy_nodemask_intersects() considers exited threads (e.g. a process
> >> with dying leader and live threads) as eligible. But it is possible that
> >> all of live threads are still ineligible.
> >>
> >> Since has_intersects_mems_allowed() returns true as soon as one of threads
> >> is considered eligible, mempolicy_nodemask_intersects() needs to consider
> >> exited threads as ineligible. Since exit_mm() in do_exit() sets mm = NULL
> >> before mpol_put_task_policy() sets mempolicy = NULL, we can exclude exited
> >> threads by checking whether mm is NULL.
> > 
> > Ok, this makes sense. For this change
> > Acked-by: Michal Hocko <mhocko@suse.com>
> > 
> 
> But I realized that this patch was too optimistic. We need to wait for mm-less
> threads until MMF_OOM_SKIP is set if the process was already an OOM victim.

If the process is an oom victim then _all_ threads are so as well
because that is the address space property. And we already do check that
before reaching oom_badness IIRC. So what is the actual problem you are
trying to solve here?

> If
> we fail to allow the process to reach MMF_OOM_SKIP test, the process will be
> ignored by the OOM killer as soon as all threads pass mm = NULL at exit_mm(), for
> has_intersects_mems_allowed() returns false unless MPOL_{BIND,INTERLEAVE} is used.
> 
> Well, the problem is that exited threads prematurely set mempolicy = NULL.
> Since bitmap memory for cpuset_mems_allowed_intersects() path is freed when
> __put_task_struct() is called, mempolicy memory for mempolicy_nodemask_intersects()
> path should be freed as well when __put_task_struct() is called?

I am sorry but I have hard time understanding what is the actual user
visible problem here.
-- 
Michal Hocko
SUSE Labs

