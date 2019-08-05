Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEE6CC0650F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 14:26:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6825C20651
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 14:26:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6825C20651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ADB2F6B0005; Mon,  5 Aug 2019 10:26:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A8AAA6B0006; Mon,  5 Aug 2019 10:26:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 952746B0007; Mon,  5 Aug 2019 10:26:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4B0096B0005
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 10:26:26 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id o13so51720589edt.4
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 07:26:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=7slsZU5JvkgCoJxqKr0CUIlHVUtpNZkyxmX8TcyxzJU=;
        b=uTTmD/1oEETY6EeIuJseedOYurkTrY5WKeBwCdd5pEqm/jHzINjsxCNy1f01fPTQJ+
         YZI95k6T1Y1D/6QSJ0XS9WXc/6Xlyd+hTzyojexc/d/OsEkTFZosRFPevm38x0wfms5T
         mSoIFehtfCXYHxvSEkJOvvP8ryO5kaYulWP5WKbfglQ/oQVmoOPr224gVMaT6esxn6Aa
         fPrT68EtwZ6R3oFhIVYoxxKhaL7JpTF99TPiAsrRVpRHJOHnd4wwjSm3Gl2PZOzYUCnl
         ZbkUpHk4LLfF1SUIScnP69L9lTqsvhNzcREoaO1kzNLbGk79AFGYP8E9cxpG5oJiU6oF
         1wZw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUbFefRCz89hP3Z4OxORwiXbD4TZvawFKH0rLIF5ITyGSSvhwa3
	QUMQrMW2ppk4YqviagEbbO17slCvpM9ja21wcAFhBP/afEL2sWaWk6NXFPsxG8DEwglegbTdsCV
	HaUI6x89mweW8mUF3UayXEFKPbc4ecNGd4l+RP3GUB+mJsYLrYKxZwblDN+FD+po=
X-Received: by 2002:a17:906:4894:: with SMTP id v20mr114185481ejq.120.1565015185786;
        Mon, 05 Aug 2019 07:26:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxpz4lmt0SU2qPCgSqJqmh1d92JaU6SkN6L3az68UjFszJZq4XuVsIf1FUthf+Z6/NeCcLO
X-Received: by 2002:a17:906:4894:: with SMTP id v20mr114185406ejq.120.1565015184827;
        Mon, 05 Aug 2019 07:26:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565015184; cv=none;
        d=google.com; s=arc-20160816;
        b=Z3NeBdc3EMYNVbVqR2LfMw4miFXFF8E92ZQGtk+MpoL3GAvOcxXpZCDQU8u2AVqGM5
         Zdk8YStODGbnB3sjZpuzOn+xHMGteZnWE5V+P+glFk422WQePaWoj3qJ5pDrqjTikYhT
         2zQBvhsPvVcub0V4PzAf967pkP1/5DK0lvOdgya2xuMHSS73LOORvFoM7jxBZdEQI5HX
         QDZB7W8+RF2EUFdupNEKYptI4NkyBMKMU8jg0bdPI1gA/yjM7rm5VJQPL/74bKPJP2Rz
         eAGze/5Xj9IUVFxbEu3L5TWLMq74ZT1hKVsEgeoMNMhssFlgSs0wUK8N1Bla2jGfFKdM
         JjBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=7slsZU5JvkgCoJxqKr0CUIlHVUtpNZkyxmX8TcyxzJU=;
        b=oQ/2+EqqTZAoq34VHj9/OATnxk7OERHS+zB+S+p5ey6m1CIbxxiPG2RI1mE/sH8d+Z
         0z8bMXHoTxt9JQ/doO/klgObQ1sYC0xRFl3QP9zeeh0494PLCldKUYZjQG4x3FybU01n
         zNwqbKxVGu3MBt0ewx82jyvQUOFdzRFPqB7P/2KgtnWtoDSIuuwf4LCDRypME2JBlDp5
         NeDcIjH6IvPc+ZqCrdLxpYJHThOpnpUXGS+t5VXCNnbEqGJvUYu6DNvbRo4jNz5NsFyb
         aUMBzZUoM6jg+wBXSzUWzoy7Gj8MrnBJ0mDeaPsiAU+GqYVgfkCEwzgBbHq6jI5mER6b
         ofJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q18si25558905eju.227.2019.08.05.07.26.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 07:26:24 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0C3C0AE48;
	Mon,  5 Aug 2019 14:26:24 +0000 (UTC)
Date: Mon, 5 Aug 2019 16:26:22 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Masoud Sharbiani <msharbiani@apple.com>,
	Greg KH <gregkh@linuxfoundation.org>, hannes@cmpxchg.org,
	vdavydov.dev@gmail.com, linux-mm@kvack.org, cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: Possible mem cgroup bug in kernels between 4.18.0 and 5.3-rc1.
Message-ID: <20190805142622.GR7597@dhcp22.suse.cz>
References: <20190802144110.GL6461@dhcp22.suse.cz>
 <5DE6F4AE-F3F9-4C52-9DFC-E066D9DD5EDC@apple.com>
 <20190802191430.GO6461@dhcp22.suse.cz>
 <A06C5313-B021-4ADA-9897-CE260A9011CC@apple.com>
 <f7733773-35bc-a1f6-652f-bca01ea90078@I-love.SAKURA.ne.jp>
 <d7efccf4-7f07-10da-077d-a58dafbf627e@I-love.SAKURA.ne.jp>
 <20190805084228.GB7597@dhcp22.suse.cz>
 <7e3c0399-c091-59cd-dbe6-ff53c7c8adc9@i-love.sakura.ne.jp>
 <20190805114434.GK7597@dhcp22.suse.cz>
 <0b817204-29f4-adfb-9b78-4fec5fa8f680@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0b817204-29f4-adfb-9b78-4fec5fa8f680@i-love.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 05-08-19 23:00:12, Tetsuo Handa wrote:
> On 2019/08/05 20:44, Michal Hocko wrote:
> >> Allowing forced charge due to being unable to invoke memcg OOM killer
> >> will lead to global OOM situation, and just returning -ENOMEM will not
> >> solve memcg OOM situation.
> > 
> > Returning -ENOMEM would effectivelly lead to triggering the oom killer
> > from the page fault bail out path. So effectively get us back to before
> > 29ef680ae7c21110. But it is true that this is riskier from the
> > observability POV when a) the OOM path wouldn't point to the culprit and
> > b) it would leak ENOMEM from g-u-p path.
> > 
> 
> Excuse me? But according to my experiment, below code showed flood of
> "Returning -ENOMEM" message instead of invoking the OOM killer.
> I didn't find it gets us back to before 29ef680ae7c21110...

You would need to declare OOM_ASYNC to return ENOMEM properly from the
charge (which is effectivelly a revert of 29ef680ae7c21110 for NOFS
allocations). Something like the following

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ba9138a4a1de..cc34ff0932ce 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1797,7 +1797,7 @@ static enum oom_status mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int
 	 * Please note that mem_cgroup_out_of_memory might fail to find a
 	 * victim and then we have to bail out from the charge path.
 	 */
-	if (memcg->oom_kill_disable) {
+	if (memcg->oom_kill_disable || !(mask & __GFP_FS)) {
 		if (!current->in_user_fault)
 			return OOM_SKIPPED;
 		css_get(&memcg->css);

I am quite surprised that your patch didn't trigger the global OOM
though. It might mean that ENOMEM doesn't propagate all the way down to
the #PF handler for this path for some reason.

Anyway what I meant to say is that returning ENOMEM has the
observable issues as well.
-- 
Michal Hocko
SUSE Labs

