Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4BAF2C46460
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 21:12:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D201126F26
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 21:12:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel-dk.20150623.gappssmtp.com header.i=@kernel-dk.20150623.gappssmtp.com header.b="M6TMkH/V"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D201126F26
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kernel.dk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5861B6B026E; Fri, 31 May 2019 17:12:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 55D116B026F; Fri, 31 May 2019 17:12:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 44B766B0272; Fri, 31 May 2019 17:12:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0F7EE6B026E
	for <linux-mm@kvack.org>; Fri, 31 May 2019 17:12:19 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id w14so7119815plp.4
        for <linux-mm@kvack.org>; Fri, 31 May 2019 14:12:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=vDJef47SRIxwZUsIMJgjK6VVpboiCh9ge6fzV5aK/tc=;
        b=HF754UvUadu/VxJkd4vM2CWGSbIqAjP874Tz6ANKPEgrAO9eeE0XU23L00ppvFolJM
         0J4rHoQJ/aePeseOCxNg0hf+tegGYd3bnvzEd2z+J9wAbXJVhKWPn3SytyGF3aobqCOi
         4DG5DPxJBhtVyHL5OFtcmePOD04j2A3HEW0r7xNu1HXdnbBtPszmcQlTKXCAo7HuMl9p
         frEplj8XnFhl91QfdpiTp7Cn/UYl8GOfHB7YgLgVS40KiKy9oHnpY3mOriGc7wFQUjcb
         Cmfk129rOjPGyEkZ0xl7K6yqhL7Uj0mI+5oY5P4ImZMuZrz9skEss7zLx1mCEUMUQSTr
         p+4A==
X-Gm-Message-State: APjAAAWEEnUwWzPFSpYo39wLxuxBZTJpjVyC0LbYvuaYZh2kExfdMegN
	Z4i/yoOi5GvX4imHhN6P5hTnMhxxVk7N2Jxj/I+9U9+OnnhCr7MtOmiOkk8nBYpHmOaQ4EECpWk
	lVMgvS/ISktlxQXL+/9XnAQCM8ScpAz3XGJehvfTUJIVhEz9lIYAbWir/4FhuXTtLBg==
X-Received: by 2002:a63:6111:: with SMTP id v17mr1799929pgb.206.1559337138558;
        Fri, 31 May 2019 14:12:18 -0700 (PDT)
X-Received: by 2002:a63:6111:: with SMTP id v17mr1799855pgb.206.1559337137841;
        Fri, 31 May 2019 14:12:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559337137; cv=none;
        d=google.com; s=arc-20160816;
        b=exMamnSioCf9CuFp/R6fjMLuTbIh8cydbkhxcQYWOTgmMk+wJ/1A4v+GbbWu7pte4f
         68OmmSUHiMiJ2Or/tulHuqKyWraVsBQnuSZ93SeZfT+lmXkE4UUQSgbTkHGJdaMiOUyT
         39rx/wdhREfiQZA+1bPRBHs3iJqLTWki0C09Zy826Hh5XQNECBaipU68E9FSRbs/H8yB
         0cDbGRSJrkmJt9KMhElUgmcqaBFyLhquAAeGQbCU3XvoQrknrIjb7oYyQwq1PEYp6cij
         FCvf0jlogFXh81qqY6bO/D7SxVKsijDKFJGhE50uw1VNbK3wQSPucHpaWy5s0LrxAWHs
         OOPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=vDJef47SRIxwZUsIMJgjK6VVpboiCh9ge6fzV5aK/tc=;
        b=XI2gYaJ/6jPi+2eDyh6FLSgWmMVP0Jvd41ftPiklgkJZbFHGgfeVW8C9kFDasaIHvv
         WwpAsfVP5/vk9kEpi/qRkMHD7RfKXpRb3xo5jgn4VlVhN34XvlOPu2gL8fiJVGfdYhj3
         jfDXeyVdiDLGR1VXjA4chLdosxYbnaGK09JaMEwcaL9n/4+o5dF2UyKwzaisPKqL96cw
         fununLVH2kk5wK8n5toYL+OXC+QHfxKq1JCkIGgjAdU82uYFDuSfaSppJKim64bJPMO/
         Hu+jrRuxbH05UoFZmz8Uip46/b7Gr6PyfwbDXVscgtL9yflAw4SWngHYxJDswZU+VPwk
         RDpg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b="M6TMkH/V";
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=axboe@kernel.dk
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n5sor8291403pfn.7.2019.05.31.14.12.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 May 2019 14:12:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b="M6TMkH/V";
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=axboe@kernel.dk
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=kernel-dk.20150623.gappssmtp.com; s=20150623;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=vDJef47SRIxwZUsIMJgjK6VVpboiCh9ge6fzV5aK/tc=;
        b=M6TMkH/V/9mT6dRs3J9b/JX5LzJWuFXwJmueAM3sFtd48jYZrEMxKZSv61IH/51s0a
         nBZAEcv60nMTWMfp4GQDDaqmB9pOQpAhc6Gg5T25v0x74DlyNydXHlrxtiS50ajmVpWg
         95Z/dxMhkgG+H4Gz67L0EKh6cK2k8iKq8odbqr31YkMCLCtJ2f2DQQFTQAHEdrETDDaL
         0oa/gJtEwSbqmF86SPddenJQcgV14RIcVDvmz66a6qkISFfQHbRsN9Lt8gS76lz66TSl
         yZrzWqJ7UAwcjk34iWYo1d6KQsFShDEbppxXU88JXpCKwek+zRC93Le8s1LeAPy/Wlaw
         7gRw==
X-Google-Smtp-Source: APXvYqzFrYv4eNgkP3NdKIFIT6J0jMYWieRpMIm6g5Q7gBVb0g3hjSNbYusIqUdd86VOSVu+kOlqQA==
X-Received: by 2002:a65:52c3:: with SMTP id z3mr11512270pgp.56.1559337137443;
        Fri, 31 May 2019 14:12:17 -0700 (PDT)
Received: from [192.168.1.121] (66.29.164.166.static.utbb.net. [66.29.164.166])
        by smtp.gmail.com with ESMTPSA id i7sm7285747pfo.19.2019.05.31.14.12.14
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 May 2019 14:12:16 -0700 (PDT)
Subject: Re: [PATCH] block: fix a crash in do_task_dead()
To: Peter Zijlstra <peterz@infradead.org>, Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, hch@lst.de, oleg@redhat.com,
 gkohli@codeaurora.org, mingo@redhat.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <1559161526-618-1-git-send-email-cai@lca.pw>
 <20190530080358.GG2623@hirez.programming.kicks-ass.net>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <82e88482-1b53-9423-baad-484312957e48@kernel.dk>
Date: Fri, 31 May 2019 15:12:13 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190530080358.GG2623@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/30/19 2:03 AM, Peter Zijlstra wrote:
> On Wed, May 29, 2019 at 04:25:26PM -0400, Qian Cai wrote:
> 
>> Fixes: 0619317ff8ba ("block: add polled wakeup task helper")
> 
> What is the purpose of that patch ?! The Changelog doesn't mention any
> benefit or performance gain. So why not revert that?

Yeah that is actually pretty weak. There are substantial performance
gains for small IOs using this trick, the changelog should have
included those. I guess that was left on the list...

>> Signed-off-by: Qian Cai <cai@lca.pw>
>> ---
>>   include/linux/blkdev.h | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
>> index 592669bcc536..290eb7528f54 100644
>> --- a/include/linux/blkdev.h
>> +++ b/include/linux/blkdev.h
>> @@ -1803,7 +1803,7 @@ static inline void blk_wake_io_task(struct task_struct *waiter)
>>   	 * that case, we don't need to signal a wakeup, it's enough to just
>>   	 * mark us as RUNNING.
>>   	 */
>> -	if (waiter == current)
>> +	if (waiter == current && in_task())
>>   		__set_current_state(TASK_RUNNING);
> 
> NAK, No that's broken too.
> 
> The right fix is something like:
> 
> 	if (waiter == current) {
> 		barrier();
> 		if (current->state & TASK_NORAL)
> 			__set_current_state(TASK_RUNNING);
> 	}
> 
> But even that is yuck to do outside of the scheduler code, as it looses
> tracepoints and stats.
> 
> So can we please just revert that original patch and start over -- if
> needed?

How about we just use your above approach? It looks fine to me (except
the obvious typo). I'd hate to give up this gain, in the realm of
fighting against stupid kernel offload solutions we need every cycle we
can get.

I know it's not super kosher, your patch, but I don't think it's that
bad hidden in a generic helper.

-- 
Jens Axboe

