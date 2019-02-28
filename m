Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CAF06C10F00
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 04:45:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 648B6218AE
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 04:45:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="VdAJ8jKE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 648B6218AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C08168E0003; Wed, 27 Feb 2019 23:45:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB7988E0001; Wed, 27 Feb 2019 23:45:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA6358E0003; Wed, 27 Feb 2019 23:45:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 68C7C8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 23:45:25 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id 202so14012199pgb.6
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 20:45:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=fgAty79c/lcTaOsIWZQePEkdQgJCu7xgRPDwcH+fVr0=;
        b=uPUtrYNqxAWIe4gQ0Nop8TiIkQOEKcWdqvOAmgE4G3qWJgCZ8H94weqZTScIQSxdP8
         C2hEzh0lrd55RVZDKg7HIZVMdSDaFimvHPGCuG+E3JRE6QIruJtzgdUa+h4yhXAs0x2W
         xJ1bzeiTIr2hkanPS9BxOLxolkMsM9xGsWOuhI7j4sPV7x4p5wZEak6Q87/a9yQ2Xrw5
         bXZiVhwWpRNXto+XOyVikAgM++Mu1x5tiHPjhoZwzqyycsdKWuJd2Un7TQeg78P9iu15
         HONnYlaoaOEi2uY1cu+76By+8vcNWNgOVRyUhELEq6o6eTfhpm1kOXngL7L9F8GkgrjQ
         KL9A==
X-Gm-Message-State: AHQUAubB+Q31Liji4EJYRrFeWPSsqH3dV+5VzbpnjfjRgn0oIbbSD0vn
	65PM3Kbvhvaw7udBapsXgMeFoYVcDL4/ym8p6hv8GYXnQjF1a9YLNeDUZAF0ubS7KXz3FVPRPjG
	AxjwgdsTQbTjbxaAresKQL163LOAW+ysGoXqKCEuiZbrJ7q/8r157jozXpVQq+db9LDhYwV6Vju
	pNcpam8N6cn+894h9LzSbBnQTUQ5VhIajHVXWpL0GCSKm7W8dJESQTJjhViJPtqLcXs+kutSrSS
	m996ZUmzwa1zPDlpn0/orIWjFglF84wMXSZw3/djXAWDstd+OzHNH2aMD7CAxs0ez+VLmLHpIFE
	rqMEkCrMY51qHccq80dWOKG23EQbQklQK2quKtWylNIL0Oq10KiHC39Jq9WWTNhBKFlJ9kg86KL
	W
X-Received: by 2002:a63:7403:: with SMTP id p3mr6497321pgc.343.1551329124895;
        Wed, 27 Feb 2019 20:45:24 -0800 (PST)
X-Received: by 2002:a63:7403:: with SMTP id p3mr6497272pgc.343.1551329123927;
        Wed, 27 Feb 2019 20:45:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551329123; cv=none;
        d=google.com; s=arc-20160816;
        b=AJce9f6crV/S8yJGrKvwLtui2xpyqpOGu/h9LkfcLmopz/WBj8gI5rvGEl5C/tvmOH
         +apHvbUM7eLlMRcojYS7qGwpSRj1GnbN0Kvj5XU5Yc1QhWCQ9H8XSH2Lvd1YjmRapx0W
         NtK5LMCOcytafEKrbOmpFyz6lLeck9om18Wb3Yx+p0TTDjOWwwD1YdMpGQPzTQ1gs/hM
         sTYhQT0ckB5T4TgzEHF5LywZKLmpLAzuJ3zqbNBPsLjVB+uXJA0278UVcnBzlL/YSPfF
         huVp9mZqd+OpPUPwlhV64hmhAKPuhsR3S46aPPZtNhj+TKQfLkoSo6uhp/m7ZWiAN8JF
         +7dQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=fgAty79c/lcTaOsIWZQePEkdQgJCu7xgRPDwcH+fVr0=;
        b=oToV0kSpVY0sUAJbailRU6rqWC0km8jca1cBkFoqv6q3TfNFImrd625xcuZBvrfAUX
         irKm/iYwxLjcuRsel8x6r75gaRlDeBwt0tJTH2WLMa9qVEwOGai7u7qvfdcywPigIQ9+
         u64zDjONbZWfSKEP/m0Luw5HhL/AaJ/LOUta1r/5z2kIqck72DvpfO1ipyD1qFhfezjt
         vvHwpm0Jt1WwfNDj2tXwUXONmoiR+dXWUfsrrVl1O02ySCFxci6afx4Y8Xuy6PWvGXY/
         6mXXaDt/IiOzQQNOpJp2wHMSY/oitEwhXoXoJYLcMVPzxixBwippHB2+dQqAItE7WqLX
         T0Ng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VdAJ8jKE;
       spf=pass (google.com: domain of sergey.senozhatsky.work@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sergey.senozhatsky.work@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 3sor26013725pls.12.2019.02.27.20.45.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Feb 2019 20:45:23 -0800 (PST)
Received-SPF: pass (google.com: domain of sergey.senozhatsky.work@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VdAJ8jKE;
       spf=pass (google.com: domain of sergey.senozhatsky.work@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sergey.senozhatsky.work@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=fgAty79c/lcTaOsIWZQePEkdQgJCu7xgRPDwcH+fVr0=;
        b=VdAJ8jKEkysg0W4tEP6OepXy9a85wkqBr2+SdikdbgRN9wtPzn8CvDsiDswiKvN3tg
         5DIYKmgOg3sKbObRSFqDnpQJSnrF1lWv0ypOdbdhErhoc8R95t/qG7CmwtaNOF/r+c6O
         yvvLRqMtlq3vAXZWze43Bvq9D8KbtoPKXmi6DLbWGyPux8xQAQjudmruzzSDyFsUQXLe
         qP+MznCe8HZui9mZqYzcmGI8FklqNcJ7Lda/v8f0gdEqYvDfY9QdkUmsKqCUjxSLZ4oz
         dN6fq+gtNREHj4xu48tUo0SbRUAENoZ0r0nvBeOQVkznEZ0CoMZJtXLu3JirvkI/vREe
         h7Qg==
X-Google-Smtp-Source: AHgI3IbmcnpWIW0bdA25pVX5YJj7DOMRjR3ZgFouaOsl6Zr+zykJpsNmSY/QARG7ODwR3pnNUGNZTA==
X-Received: by 2002:a17:902:b591:: with SMTP id a17mr6109349pls.228.1551329123575;
        Wed, 27 Feb 2019 20:45:23 -0800 (PST)
Received: from localhost ([110.70.46.182])
        by smtp.gmail.com with ESMTPSA id i10sm5388057pgs.26.2019.02.27.20.45.21
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 27 Feb 2019 20:45:22 -0800 (PST)
Date: Thu, 28 Feb 2019 13:45:19 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Petr Mladek <pmladek@suse.com>,
	Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
	Steven Rostedt <rostedt@goodmis.org>, akpm@linux-foundation.org,
	linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>,
	Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>,
	linux-kernel@vger.kernel.org,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] printk: Ratelimit messages printed by console drivers
Message-ID: <20190228044519.GA32563@jagdpanzerIV>
References: <20180420145720.hb7bbyd5xbm5je32@pathway.suse.cz>
 <20180420111307.44008fc7@gandalf.local.home>
 <20180423103232.k23yulv2e7fah42r@pathway.suse.cz>
 <20180423073603.6b3294ba@gandalf.local.home>
 <20180423124502.423fb57thvbf3zet@pathway.suse.cz>
 <20180425053146.GA25288@jagdpanzerIV>
 <20180426094211.okftwdzgfn72rik3@pathway.suse.cz>
 <20180427102245.GA591@jagdpanzerIV>
 <20180509120050.eyuprdh75grhdsh4@pathway.suse.cz>
 <63adb127-bb4b-d952-73f4-764d0cd78c52@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <63adb127-bb4b-d952-73f4-764d0cd78c52@i-love.sakura.ne.jp>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On (02/26/19 19:24), Tetsuo Handa wrote:
> Does memory allocation by network stack / driver while trying to emit
> the messages include __GFP_DIRECT_RECLAIM flag (e.g. GFP_KERNEL) ?
> Commit 400e22499dd92613821 handles only memory allocations with
> __GFP_DIRECT_RECLAIM flag. If memory allocation when trying to emit
> the messages does not include __GFP_DIRECT_RECLAIM flag (e.g.
> GFP_ATOMIC / GFP_NOWAIT), doesn't this particular problem still exist?

Console drivers are always called from atomic contexts (including
IRQ->printk->console_driver paths); if any console driver does a
GFP_KERNEL allocation then it should be fixed.

	-ss

