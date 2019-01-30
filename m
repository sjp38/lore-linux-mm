Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: **
X-Spam-Status: No, score=2.2 required=3.0 tests=CHARSET_FARAWAY_HEADER,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2839AC169C4
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 02:54:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B14D820870
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 02:54:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B14D820870
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 48BD28E0005; Tue, 29 Jan 2019 21:54:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 412308E0001; Tue, 29 Jan 2019 21:54:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2B4AF8E0005; Tue, 29 Jan 2019 21:54:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id F3AA68E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 21:54:26 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id q18so18348957ioj.5
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 18:54:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:mime-version:date:references:in-reply-to
         :content-transfer-encoding;
        bh=IGVKYqOkds3B0tskA/tHt7tGDI2twEsdSJF4nzA0gM0=;
        b=B7H96YfrSZrpv2chkx/xQ+2LH9+Ae1DB3IDLsckJMEukTqqIyge2I8MlPd/mK78Y0E
         vMSy1aL+lHRq1BykYYgjQe2uNF6bUpKIitHQWaR/4xqTFe/ajr7p1+W8i2i2JLuK9zbc
         1OX+eO7PFqD1PYWSq+UJFWdtfmPp2oHc6hyPKgLETxYoAYhtdvI5ZjTJHOUl6ECJTkiL
         R4+EbgwZCFUhdqI69ERwD+G+hirhzzfxxD4sYowJPtzoQdVBAJjJXIqjIRP8CnFERS9B
         VlZvdbRF8tnhTU7toV4PN8M32uAtkwFJXGSB7U2ZLY8cz6xHtSnPOdAjF6mEEdq1KGkz
         u5UQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: AHQUAuZBit8p9craYFg0SskHO76/C+oQSSBJQras6x3jFB39dNXzOt3J
	5aT9ikQB2Yz6hhOx7k4PSjIu+m4o/GA6gNB0J/ZU6ADFbQYuMzPQs/CTHytOzlAOtHrR8058kGG
	RiYO/fFzdL8Kh2K6PwmURF5lGxi/YL+rc2y5A/le7MFGw//OaH2mZGd+7Hp4b9ZZroQ==
X-Received: by 2002:a24:c8d7:: with SMTP id w206mr1237464itf.56.1548816866737;
        Tue, 29 Jan 2019 18:54:26 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia7gNGBtHYHpXxb/MazQDGAwHV/Va6TTVcOUN6sTyQxpZBvRWC4nXJN13dxZf2kNXWCyKgo
X-Received: by 2002:a24:c8d7:: with SMTP id w206mr1237449itf.56.1548816866048;
        Tue, 29 Jan 2019 18:54:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548816866; cv=none;
        d=google.com; s=arc-20160816;
        b=YoaJRwf6I13Bvrkq7G5gTqMr/OMYXZEzjd0rjqXK8zPec0O6JOcv6XajSmIELFeVq4
         CNMKYMPxXINWcECXua0y1vUFsCI0fWIr04pcMcCTnZVNX7MHvr0Pfqj/X0Nvs+p1CeVr
         /cgfrrkq487n81ZFYnLmkj+YD9qw8yEeR0fQZ5iU4JC+lmSzAYJJVn1CM1S32HT2Gfa0
         JJgVqVClz/x0WrS4RKbLMcGJOy64Q6PT2LRSlPd7tkMsr/eYy7+iP0nHYU5SaegghEDx
         cBpFrS/gbbo3M+myzM6+eanPHrKQpblup6gJ01mZE+6ZpsPEBLaHT1FNrpIB/Hwmp4ya
         QsQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:references:date:mime-version
         :cc:to:from:subject:message-id;
        bh=IGVKYqOkds3B0tskA/tHt7tGDI2twEsdSJF4nzA0gM0=;
        b=rlffTd0M9SCX+xzjIxUS/NvBX7AvKMzKfopPvNDKWf8INGJ2I1MGOAXS4JnCIWuaZx
         TtFW48e5DN+YJFvKW98h2/gBsuTMUPNmlfjkTKTwshsgIGa6ABYx0nhGgKFSzf1hjOBU
         MTV9JHq94ChwOQkdYvvjkg1j0Q6Q6KMlB8c6w5T6Z70vHjNdlBVnfqxqeHzbTqGkWcts
         KFTTpyEfcIPawfO7IkDDAidknX3NdE66ozQgdwfHAD6qxHy7AguyZ98KgmuM6HgU1GqA
         uvEHYeUB/iBq6oQ7rSr+EbaCCp4HyhI+Xd9S3wVMAadWX3hphfbifbVN6iUtMdakU9Xd
         V9EA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id p200si405661itb.125.2019.01.29.18.54.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 18:54:25 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav104.sakura.ne.jp (fsav104.sakura.ne.jp [27.133.134.231])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x0U2sK3S090910;
	Wed, 30 Jan 2019 11:54:20 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav104.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav104.sakura.ne.jp);
 Wed, 30 Jan 2019 11:54:20 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav104.sakura.ne.jp)
Received: from www262.sakura.ne.jp (localhost [127.0.0.1])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x0U2sK2w090906;
	Wed, 30 Jan 2019 11:54:20 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: (from i-love@localhost)
	by www262.sakura.ne.jp (8.15.2/8.15.2/Submit) id x0U2sKdE090905;
	Wed, 30 Jan 2019 11:54:20 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Message-Id: <201901300254.x0U2sKdE090905@www262.sakura.ne.jp>
X-Authentication-Warning: www262.sakura.ne.jp: i-love set sender to penguin-kernel@i-love.sakura.ne.jp using -f
Subject: Re: [PATCH] mm: fix sleeping function warning in
 =?ISO-2022-JP?B?YWxsb2Nfc3dhcF9pbmZv?=
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Yang Shi <shy828301@gmail.com>,
        Jiufei Xue <jiufei.xue@linux.alibaba.com>,
        Linux MM <linux-mm@kvack.org>, joseph.qi@linux.alibaba.com
MIME-Version: 1.0
Date: Wed, 30 Jan 2019 11:54:20 +0900
References: <CAHk-=widebSUzbugcLS2txfucxDNOGWFbWBWVseAmxrdypDBrg@mail.gmail.com> <CAHk-=wg=gquY8DT6s1Qb46HkJn=hV2uHeX-dafdb8T4iZAmhdw@mail.gmail.com>
In-Reply-To: <CAHk-=wg=gquY8DT6s1Qb46HkJn=hV2uHeX-dafdb8T4iZAmhdw@mail.gmail.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> > change. But I think that we converted kmalloc() to kvmalloc() without checking
> > context of kvfree() callers. Therefore, I think that kvfree() needs to use
> > vfree_atomic() rather than just saying "vfree() might sleep if called not in
> > interrupt context."...
> 
> Whereabouts in the vfree() path can the kernel sleep?

Indeed. Although __vunmap() must not be called from interrupt context because
mutex_trylock()/mutex_unlock() from try_purge_vmap_area_lazy() from
free_vmap_area_noflush() from free_unmap_vmap_area() from remove_vm_area() from
__vunmap() cannot be called from interrupt context, it seems that there is no
location that does sleeping operation.

Linus Torvalds wrote:
> Which - as mentioned - is fine because we currently don't actually do
> the TLB flush synchronously, but it's worth noting again. "vfree()"
> really is a *lot* different from "kfree()". It's unsafe in all kinds
> of special ways, and the locking difference is just part of it.
> 
> So whatever might_sleep() has found might be a potential real issue at
> some point...

Then, do we automatically defer vfree() to mm_percpu_wq context?

