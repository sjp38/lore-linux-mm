Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F8ADC76186
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 18:58:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3648C206DD
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 18:58:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3648C206DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D7EE38E0005; Mon, 29 Jul 2019 14:58:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D2E9A8E0002; Mon, 29 Jul 2019 14:58:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C441E8E0005; Mon, 29 Jul 2019 14:58:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 79A848E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 14:58:55 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id z20so38816758edr.15
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 11:58:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=S08JyecU8K8ncYhKyMUKp1kJEMwdjPIR9zpS5xe1j50=;
        b=e6alsiLA7Ui90dQWM7AOIIQUIBwdVEIJUJFi+Dd2Hp5Y5dcThp/BBATMVf448jSplG
         rjX4GF1sJLYPr0FlqPuKXpozV35KtZOnOPET4r88CEhPacbPa6rjJjoojZGZCJvOCtSp
         BM9lbNK41vlWFQmc37DUO7hu7N2HXKdz2ntqmcSB14paS5v3jM90rbH0RCXNNzBoztKX
         ZP7zLH6++eK7gai7WcPMGa0Qi/U1Vdb7KS080uLNY1imfIKKUHp3xUAj+w2CifsqXjjg
         s+MF9vPwNsTPGhS4zPE1JhrRJd2bujai99mjYZjml4r1D1zaon5n7QeH4yE+5C6b1SOd
         wrUw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWkNOutaV6JXwf8feLn4fszn92BzgZDWh12OwmI5rp+E0EElaG2
	a4Kj3fvX4BAn6eosshZK7YnEE+Mucr7QZs5fN0zOHT0mLl3xekyDxpzjAM4FFqGeHOChFUKxkVq
	+Sv7WIaaNcNNuPPdziwkhTdF0ti+SbeJw+i8BKLCyddcf7CKBAO0fnP9plZCzr/Q=
X-Received: by 2002:a05:6402:1507:: with SMTP id f7mr97666735edw.94.1564426735060;
        Mon, 29 Jul 2019 11:58:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwhqBljwqdT4ZKbxWTfR0MERzWs/I8ez0fn6KtoucbZUaaLNbmaLD8K8O6ACWkIyfNhldqw
X-Received: by 2002:a05:6402:1507:: with SMTP id f7mr97666694edw.94.1564426734329;
        Mon, 29 Jul 2019 11:58:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564426734; cv=none;
        d=google.com; s=arc-20160816;
        b=l7nPS5D1oxVzimpY2s7SSj/1mkePs+AF24umMw/Sq4UL377GayHC1aBvdNFFlw3IrU
         6cr8w9QN1dXE42DRjpUXQwJpEHAKrrEhT7+VRTbz6BX7M2kQAX9YEClneUD8Xm+lfgSy
         VAZZkfsHD6MxoSQQHOeIMuAVjFjpMZNvBBMmA0/E9yJ6RS/gegaGA0oTPjIyK1fb1zaP
         ce2zkKfcwRMy9WUOT/5iMAAFJsrY2EOU3oR9uLstmGe/zp02Qgp/lW7m6giAk+qIxy1Y
         o2UGRfOnqSXM6psbdX6WG7W3zIRbrIs2D5yT6vXC4RML1j9XqWnHXSP5E+h6MO1+f+iK
         d6Zg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=S08JyecU8K8ncYhKyMUKp1kJEMwdjPIR9zpS5xe1j50=;
        b=0YaMow/kVElTetKFhEkaW7s4BZbIszaA0klbJxQbc9ztyay9TNUd0QJAhxE64sXHp4
         T+GWJNFZ10FsatCObCoCdS9sT1hsl96YNRlUu60ohhuiJRxrSJb9t5mKTrFrFuXrD1tD
         NeV+cNjR9QPMAZYLXYbSBmbJkeARyEIFXM6C99ctV8+ouy0ayM7F8hdUGm+iNQXjunyI
         VPf7DFDDzj1bKvfwun7rdZfHykQ22gm8Dis0DHR7zXA55rF64sxHTkZx7mGdnsNF0MiJ
         kDhQ/vrJqFUpI8I6wpilzwXK2z4/m0D2L8+y9Ag8Dd8UR7rSwAUvLFbQLaT8zbPouh/i
         jvQw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i13si15309590eja.216.2019.07.29.11.58.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 11:58:54 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E2B4CAD85;
	Mon, 29 Jul 2019 18:58:53 +0000 (UTC)
Date: Mon, 29 Jul 2019 20:58:53 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Waiman Long <longman@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Phil Auld <pauld@redhat.com>
Subject: Re: [PATCH v2] sched/core: Don't use dying mm as active_mm of
 kthreads
Message-ID: <20190729185853.GJ9330@dhcp22.suse.cz>
References: <20190727171047.31610-1-longman@redhat.com>
 <20190729091249.GE9330@dhcp22.suse.cz>
 <556445a2-8912-c017-413c-7a4f36c4b89e@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <556445a2-8912-c017-413c-7a4f36c4b89e@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 29-07-19 11:27:35, Waiman Long wrote:
> On 7/29/19 5:12 AM, Michal Hocko wrote:
> > On Sat 27-07-19 13:10:47, Waiman Long wrote:
> >> It was found that a dying mm_struct where the owning task has exited
> >> can stay on as active_mm of kernel threads as long as no other user
> >> tasks run on those CPUs that use it as active_mm. This prolongs the
> >> life time of dying mm holding up memory and other resources like swap
> >> space that cannot be freed.
> > IIRC use_mm doesn't pin the address space. It only pins the mm_struct
> > itself. So what exactly is the problem here?
> 
> As explained in my response to Peter, I found that resource like swap
> space were depleted even after the exit of the offending program in a
> mostly idle system. This patch is to make sure that those resources get
> freed after program exit ASAP.

Could you elaborate more? How can a mm counter (do not confuse with
mm_users) prevent address space to be torn down on exit?


-- 
Michal Hocko
SUSE Labs

