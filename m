Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9BF50C433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 14:00:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 56FE920B1F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 14:00:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 56FE920B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DFC2E6B0003; Mon,  5 Aug 2019 10:00:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DABD66B0005; Mon,  5 Aug 2019 10:00:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC11A6B0006; Mon,  5 Aug 2019 10:00:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id AE8086B0003
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 10:00:39 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id y13so92242352iol.6
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 07:00:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=4/KzhahMa7EWa5u2SWDcfsI6gr14SLUlkUqCJMdmTzI=;
        b=PbyJS0eozC/s+r04AOIyfF19KBMWEnZTRN+IU2tl3JH298ESv+RvdRsEq1kTgYTFd7
         hAmAEfKDmVd2PjfCmTD6MrGWOruub7ond0WTx/yBpNSwofxhD6ow75vPYNoQPAnC9Kyj
         OxiICibgSdYm5/o4OhrF3RRv98eyXMn8cPkfdtfkvJ+V7ZSpzl8CA/VPRlZcTZpzB9Rl
         ktYIapL8xRuc3WwEslQRkLTsNxLeucV+5CrUQqTjxx6vfMyzdctmmdSKJ0qZYrh9KIqw
         23kRN8Jr6qsnwjFDobErJM8DxT09sIinwZoNht4gsuGKuflIntFFIEUewYvsdXQb9KWC
         mkzA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAWQBgPFWvD8zyFc0NnoglxTxu9/vXBW/dCKzZ3x5mKenhEoUr0E
	AypfR0rVh9j7XLuAZ4KYoyf/IHZfh7ztjRhQHXh47M/uVyLZaRh45Jccvsi9PySR479MOj71eQi
	2Y2Ft4bstfJ7gLwtNZwthBhoVHtJ1fLIVEu5XoZt0ksmjndXZvn+xKHYJd3SCYWSoow==
X-Received: by 2002:a6b:4107:: with SMTP id n7mr18525361ioa.12.1565013639464;
        Mon, 05 Aug 2019 07:00:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwnML0lAc1uRxY/F0myWGigoh4r5trEslRChR9dKaZizeDo8mdicr+JEM6/xDZL0IWSfV7j
X-Received: by 2002:a6b:4107:: with SMTP id n7mr18525288ioa.12.1565013638573;
        Mon, 05 Aug 2019 07:00:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565013638; cv=none;
        d=google.com; s=arc-20160816;
        b=EkgecT75GMVYDi8R+OPh+CmwlJt5ELEzeps85hAynit4pM6NMlg8jlFRxYdN12Bdsa
         jmoBXbDguR1WM2TSKqWeykl3nHt0kst7oXvkQeaN+OLyy0dbMFaUdoyRFL2giLxHu13Z
         CziHc2pBQ+no34xzKImYZ/tjwaS+ENTgBwxjvn0KkqC4ND/+MH9OOFYY3xqDWX/+t8Mt
         S0m38tEoigERtkrrQb3MAKP7TlqRmIjKDyBBoSBDeuEow4k4KCQnZzB/vspId9cXoFd6
         NGle4wzASzhdGe+Ld0MgcCnKDxbB3v1ECPUstnioTqLzhOZdLtLV+PyVzZSz8wPW016F
         30zA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=4/KzhahMa7EWa5u2SWDcfsI6gr14SLUlkUqCJMdmTzI=;
        b=dbIMwxAZ7Sd+hJvy+i3CO5cDhaULqE1CO94TPkS1S5phdgP3Trzj0ZtKyfe3YoL/f0
         8aMT40FbgZh60E4XzrM+1wNkuOBsYiJBJARMw98YsRtQ0fS8Un3lmyPe3SSzguQA90Td
         rYCVKby4amSUeKfUOvyG3tYUWDxl+FbqAl5318Sx6J7XgpS96VGbPlAGg4KMLYQbnzBx
         N2WnsqnADJIO4Soxs8Kjor7W3Ti15SaJ8R1nLXOvbtwOsOr2CazRbFBqkR488UU1TnNL
         IPoccQy6pzwUqCztBEht9PDsR1J5tSz94qlcUDAxcIN80/D5jNkCK8nJ78O4wivEAw5I
         vhrQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id g21si45205677ion.115.2019.08.05.07.00.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 07:00:38 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav401.sakura.ne.jp (fsav401.sakura.ne.jp [133.242.250.100])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x75E0KBv087080;
	Mon, 5 Aug 2019 23:00:20 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav401.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav401.sakura.ne.jp);
 Mon, 05 Aug 2019 23:00:20 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav401.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126012062002.bbtec.net [126.12.62.2])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x75E0GY8087053
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Mon, 5 Aug 2019 23:00:20 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: Possible mem cgroup bug in kernels between 4.18.0 and 5.3-rc1.
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Masoud Sharbiani <msharbiani@apple.com>,
        Greg KH
 <gregkh@linuxfoundation.org>, hannes@cmpxchg.org,
        vdavydov.dev@gmail.com, linux-mm@kvack.org, cgroups@vger.kernel.org,
        linux-kernel@vger.kernel.org
References: <20190802074047.GQ11627@dhcp22.suse.cz>
 <7E44073F-9390-414A-B636-B1AE916CC21E@apple.com>
 <20190802144110.GL6461@dhcp22.suse.cz>
 <5DE6F4AE-F3F9-4C52-9DFC-E066D9DD5EDC@apple.com>
 <20190802191430.GO6461@dhcp22.suse.cz>
 <A06C5313-B021-4ADA-9897-CE260A9011CC@apple.com>
 <f7733773-35bc-a1f6-652f-bca01ea90078@I-love.SAKURA.ne.jp>
 <d7efccf4-7f07-10da-077d-a58dafbf627e@I-love.SAKURA.ne.jp>
 <20190805084228.GB7597@dhcp22.suse.cz>
 <7e3c0399-c091-59cd-dbe6-ff53c7c8adc9@i-love.sakura.ne.jp>
 <20190805114434.GK7597@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <0b817204-29f4-adfb-9b78-4fec5fa8f680@i-love.sakura.ne.jp>
Date: Mon, 5 Aug 2019 23:00:12 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190805114434.GK7597@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/08/05 20:44, Michal Hocko wrote:
>> Allowing forced charge due to being unable to invoke memcg OOM killer
>> will lead to global OOM situation, and just returning -ENOMEM will not
>> solve memcg OOM situation.
> 
> Returning -ENOMEM would effectivelly lead to triggering the oom killer
> from the page fault bail out path. So effectively get us back to before
> 29ef680ae7c21110. But it is true that this is riskier from the
> observability POV when a) the OOM path wouldn't point to the culprit and
> b) it would leak ENOMEM from g-u-p path.
> 

Excuse me? But according to my experiment, below code showed flood of
"Returning -ENOMEM" message instead of invoking the OOM killer.
I didn't find it gets us back to before 29ef680ae7c21110...

--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1884,6 +1884,8 @@ static enum oom_status mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int
        mem_cgroup_unmark_under_oom(memcg);
        if (mem_cgroup_out_of_memory(memcg, mask, order))
                ret = OOM_SUCCESS;
+       else if (!(mask & __GFP_FS))
+               ret = OOM_SKIPPED;
        else
                ret = OOM_FAILED;

@@ -2457,8 +2459,10 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
                goto nomem;
        }
 nomem:
-       if (!(gfp_mask & __GFP_NOFAIL))
+       if (!(gfp_mask & __GFP_NOFAIL)) {
+               printk("Returning -ENOMEM\n");
                return -ENOMEM;
+       }
 force:
        /*
         * The allocation either can't fail or will lead to more memory
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -1071,7 +1071,7 @@ bool out_of_memory(struct oom_control *oc)
         * ___GFP_DIRECT_RECLAIM to get here.
         */
        if (oc->gfp_mask && !(oc->gfp_mask & __GFP_FS))
-               return true;
+               return !is_memcg_oom(oc);

        /*
         * Check if there were limitations on the allocation (only relevant for

