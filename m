Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 606EAC10F14
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 08:31:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 28C5C20645
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 08:31:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 28C5C20645
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF8966B0003; Tue, 23 Apr 2019 04:31:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA55A6B0006; Tue, 23 Apr 2019 04:31:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A945D6B0007; Tue, 23 Apr 2019 04:31:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5C24A6B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 04:31:51 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f7so2367493edi.20
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 01:31:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=SzhiKLqepLs4TLyFMC3qY82Pew51Os0SgpyAsf9Oskc=;
        b=AUeBR/VudDjVjL1a5EbNym8pV0mgPqyHCb8GN4R9E0y7DIATZ8DnLYic9BCq8qVJhO
         rsVwF52IdJY3aOJgWQKjlwTUVuHIgRE1kDy0ZUtn2NQvCDl/xqlB9Y361MPC61J7Nh9t
         D4vjqBJi8SQBwClhTRyLuBzNM5cKGbj3z0DPsKUfArdmcE+9xRp+CumTCeXLWzuYM97s
         816qD65DFAyISQ1mech62pWIa/TfYYzcZM6YipVJ3CKtywEYtcvNmn55BZhdx/nxpsLx
         FleKke1XZsnFlRpLAFiVU7hiyMXoQdPC6XWddJ3/yVZDRD22bmKon5bIJ7PmIRSilosJ
         a7AQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWorzzOKobCTrmMvwpTOvmZVciHSzGZlfEHM5+SpiO6g5uJieoq
	Bp8vs3fIhM483fN14GkIh4qa8nILyEnXeOCf0R6j+OYMZKogzALuYSo8GaMXPx19P1wy2tLhoWW
	NCv/KM9ckQPyA8qJfdrHzP64DxUrZm4fLfYjRq+2GH0G33EEZAxomEWva8qzjQrI=
X-Received: by 2002:aa7:d950:: with SMTP id l16mr15208991eds.296.1556008310947;
        Tue, 23 Apr 2019 01:31:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyjniSDvVfE6Vac4+xbYJm3PiQiVlDOpY9gj9BQEeaFOhIPlVdhsZ/ASjLwHDJ283+1is2D
X-Received: by 2002:aa7:d950:: with SMTP id l16mr15208944eds.296.1556008310139;
        Tue, 23 Apr 2019 01:31:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556008310; cv=none;
        d=google.com; s=arc-20160816;
        b=G5/FperWFMF5GUD1mEgmss0w6x29WQoOzLUtnlXKgGIH561B5oNzFvn5OybCV4/d70
         oh9TJkynNtVTezuI+Vbolq51BCR+XCxnuFDvEqmIhc1IIYXwVKCAbK//GI9hhIqA5mLL
         +3rEUJv+4cK/034Y1a2DRAjX6t+yyHkXw51jphnBZM8NmLTRNYbtcxlODm5sYvvvp844
         NhCrcfLWcXrvScQj8GK2npkY6GvDttT/p5FI3YZc549ZMMHQF88TsVGGZP+othMwKyM3
         IUUZlAmOmk2Mn5qAb6bEOnTtls3FctZwUqiI+1AL4hd49kb3XE2sG0tygZfxU9H2qPPd
         7Wpg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=SzhiKLqepLs4TLyFMC3qY82Pew51Os0SgpyAsf9Oskc=;
        b=oQiGWefVl6dScRogMv3XiQyomBOxJvviHSj8Ue5bB0ATXMEn4P6AYOpB76SWI9YfUn
         a//416ntxwcf83SpplExc0rO4nPG3fG2D26ma+BfA3nw0BaUYP5R+Qq4SIBe9NjGqetU
         j6I5iZWkhjr0OkSNYyvlgz3fOCnaCmmGRUNMWeH+WkOlHHK2c1pIwxKCQqr6e9MqBIyN
         q10obutUjRiqeJtigPb6ERP82st779gTpENdpdQ8gWSTDxKGS8xRJBZPRsEBfagDBuY9
         12vOJgGbkZbvp/DiRUm/ivzZCUuAiZ1ljecPCsJpz0HWYEqWbOff0+3BA3MTVF2O/Izl
         D0gA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b9si351368edw.129.2019.04.23.01.31.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 01:31:50 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 86760AED6;
	Tue, 23 Apr 2019 08:31:49 +0000 (UTC)
Date: Tue, 23 Apr 2019 10:31:48 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Alexander Potapenko <glider@google.com>, akpm@linux-foundation.org,
	cl@linux.com, dvyukov@google.com, keescook@chromium.org,
	labbott@redhat.com, linux-mm@kvack.org,
	linux-security-module@vger.kernel.org,
	kernel-hardening@lists.openwall.com
Subject: Re: [PATCH 1/3] mm: security: introduce the init_allocations=1 boot
 option
Message-ID: <20190423083148.GF25106@dhcp22.suse.cz>
References: <20190418154208.131118-1-glider@google.com>
 <20190418154208.131118-2-glider@google.com>
 <981d439a-1107-2730-f27e-17635ee4a125@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <981d439a-1107-2730-f27e-17635ee4a125@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 18-04-19 09:35:32, Dave Hansen wrote:
> On 4/18/19 8:42 AM, Alexander Potapenko wrote:
> > This option adds the possibility to initialize newly allocated pages and
> > heap objects with zeroes. This is needed to prevent possible information
> > leaks and make the control-flow bugs that depend on uninitialized values
> > more deterministic.
> 
> Isn't it better to do this at free time rather than allocation time?  If
> doing it at free, you can't even have information leaks for pages that
> are in the allocator.

I would tend to agree here. Free path is usually less performance sensitive
than the allocation. Those really hot paths tend to defer the work.

I am also worried that an opt-out gfp flag would tend to be used
incorrectly as the history has shown for others - e.g. __GFP_TEMPORARY.
So I would rather see this robust without a fine tuning unless there is
real use case that would suffer from this and we can think of a
background scrubbing or something similar.

-- 
Michal Hocko
SUSE Labs

