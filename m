Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2806BC06511
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 06:56:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB38B21882
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 06:56:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB38B21882
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7900B6B0006; Wed,  3 Jul 2019 02:56:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 73F4F8E0003; Wed,  3 Jul 2019 02:56:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 608CB8E0001; Wed,  3 Jul 2019 02:56:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 277F66B0006
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 02:56:46 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id n49so955287edd.15
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 23:56:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=9a4DMvwx+JdyrBKECHVH2r1vcYtXkBa5nQgMio/sS34=;
        b=Fv88nP4B9wLuUzewk4oJnJTL6e5uu0iYarExQJO+YxMhBk4H5Enn7+uMtoNr5hSzAI
         be+WmXLSzQKwaM1qy8vfZxooz+rYnGbdALHz+GsZulr5mbAG5lF8gonL/I3WQjQ69y96
         tcIhvskuCIb+rm62JR4Acef1OgsJU2KAd5y4KZnJ1LeNj/MbqMLB9/5GmeVMhCNqvF96
         aXN1WXp6J5awpAEJpEhAVt43lXTYD24VWTlm5UC71eJ7FP91s9NMKcdfzAQMzabiXtdY
         3iOzgm8ib29sm+IdwZBqgZBJgUoxXGRDLY9wGufrGY2M3HggJ8uTlW5IKyWP0GTTf8j1
         fOQQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAWOXUyfiZ2CB1quNELnmzl8vLVyvX5m3vFSYneQ8UN+PoRnOt8Y
	Lvv9kV8A164Hscx3IZhCzOSXFErfC+FYXrOQAgaRP5wSqtN29Wn3rs1kKNz6DcYgFvOOreTq9ls
	yFV57dJB6ydntXhpG4l3SQ/OCaZpu0pX3Aw5LexvxzZ45DCrSrOytGzHejAnfHl9TRQ==
X-Received: by 2002:a50:b161:: with SMTP id l30mr41050425edd.278.1562137005752;
        Tue, 02 Jul 2019 23:56:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxPvoLAMuhPUmgWn9FJqQIkX1+BeNDM0ZheUztPuLovjbEKdygCHZ+Y5iPHR9N0vM54ENo6
X-Received: by 2002:a50:b161:: with SMTP id l30mr41050389edd.278.1562137005173;
        Tue, 02 Jul 2019 23:56:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562137005; cv=none;
        d=google.com; s=arc-20160816;
        b=rZqPVARMYuy5TQNz0Mo18WQyp98QwLBrxJXDpcJa4zr2HctsKH+2WD5xo62EozKwYh
         XgpXwlZETgEvRTCagIIkKDiS4rDtT8jR4NlV3q6AcWpswJI3n/I6P4zfIKeSHVXM8IPK
         aoog89otXOSkQ3A3W95ACXs7vtfqL9dkgHjp75fTYCUkAntKztLPxaWgrTnEYRRN4iwm
         Ipyf4oYfkvNPQ2C+lt/S32Cmbh2/lF/alUQdkY3O/lDLGVgfaKLtXNuQ6/wCj6Z0lSO2
         Alnv/jJuNF2thQ+ac+sK9egdQyJcIr0xwa8r/pe1NJX4HWG8XzCLet2o7VKuAGX7+VTk
         OKug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=9a4DMvwx+JdyrBKECHVH2r1vcYtXkBa5nQgMio/sS34=;
        b=M53Owsry7ZLhVrIPsKFhGqEfFxkhTgr75kn7tfupnlZtEA49rOGkHlAqu+8KpFMMxU
         inDtFb0oDujDqTV7N8Xtz3ePkR849Y/QCkTo5PZr/1yJAUQTXzgq76fBddR0E2jESOa8
         W7A9Pm1NeH0lmYgpX1sATVxIFLdj/mXLGUVmCQVdddUKygaBPu28vcMTTAVl8YynhEon
         Obbsf+wRIV7pw1Tb2vHRQsHFaijm+er1Ho2AA/2HcLVmLeACoYDuQ27/xcyuiqObJQl7
         4kXsSAfAklzmaJOuDhG/qku1wNM/8k+JE7KzOdqZ7pn2LR5faU1PHpMwRqWAV+Bslzi5
         fdEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id k15si1322711edd.268.2019.07.02.23.56.44
        for <linux-mm@kvack.org>;
        Tue, 02 Jul 2019 23:56:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id DE7C02B;
	Tue,  2 Jul 2019 23:56:43 -0700 (PDT)
Received: from [10.162.42.95] (p8cg001049571a15.blr.arm.com [10.162.42.95])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 02E933F718;
	Tue,  2 Jul 2019 23:58:34 -0700 (PDT)
Subject: Re: [PATCH] mm/page_isolate: change the prototype of
 undo_isolate_page_range()
To: Pingfan Liu <kernelfans@gmail.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko
 <mhocko@suse.com>, Oscar Salvador <osalvador@suse.de>, Qian Cai
 <cai@lca.pw>, linux-kernel@vger.kernel.org
References: <1562075604-8979-1-git-send-email-kernelfans@gmail.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <ada46116-9c87-86ce-9015-351700439ea3@arm.com>
Date: Wed, 3 Jul 2019 12:27:08 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <1562075604-8979-1-git-send-email-kernelfans@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 07/02/2019 07:23 PM, Pingfan Liu wrote:
> undo_isolate_page_range() never fails, so no need to return value.
> 
> Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Qian Cai <cai@lca.pw>
> Cc: Anshuman Khandual <anshuman.khandual@arm.com>
> Cc: linux-kernel@vger.kernel.org

Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>

