Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF9A0C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 14:02:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C9332085A
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 14:02:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C9332085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 246116B0005; Mon, 25 Mar 2019 10:02:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 21A136B0006; Mon, 25 Mar 2019 10:02:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 10A6D6B0007; Mon, 25 Mar 2019 10:02:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B47D76B0005
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 10:02:24 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id s27so3843266eda.16
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 07:02:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=uSHlmUF1rpi8jhNov2WbkstxfcDETX9FJi3N0xz+iuw=;
        b=mlxRrxO+ke6vCmvzPgYkl9n2fcO3IkmgAGdI1OnKAfrxjpklHZsI285udC6hEfUb5R
         c1ZlVMuWPP+JPvBGD4XW1oGU29VbwkTc47/n2QmXlby+fW4jI9wEZkQwRPihMRYlKfIF
         K6TXg3FQAU8Eh3r2u16pvgvq3P3xKDPt0dpJoRsP/rqZKmc908R/g2Rr7xiYYsMRM6Vh
         oZGs0OePswEWXyfQLs97g3qOZYoNGG82e+l8wddW7kWqHyUoiciFkRExT0sQC383DVQj
         ku91qk7fvtDbrSZWeaSflbQyWZcesjaloBY0/BBedZwFpHrV6cEt3t5QzWsyEjyOZZMP
         t1jw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
X-Gm-Message-State: APjAAAX8WFwXJLBWicZAAkubXaymptOnUFMNJy2yqRjEc1dqQq93QH50
	9PXxv/CefiDTLLSnqegz1cSo5zwfGqzqIJFa0rpiesaswGJxRH78+qbJWZIlx2tnMdNNgN66/+M
	YaRql7izhcjAacilDsoLjL5sG/jI67bDlJqbxYeo1OSMeqK3iWy4CA19o45WytGqMdg==
X-Received: by 2002:a50:b512:: with SMTP id y18mr16242101edd.126.1553522544302;
        Mon, 25 Mar 2019 07:02:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwKeggxr7m1m5MZMP/8CwxtP8/DLj8dTfcbD21rwCzLiS9tHsjZgCOaz5C7xMNGm3zwCgwq
X-Received: by 2002:a50:b512:: with SMTP id y18mr16242054edd.126.1553522543399;
        Mon, 25 Mar 2019 07:02:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553522543; cv=none;
        d=google.com; s=arc-20160816;
        b=TbVjNO9DgG1kFa0VpXshGLCx/xrEBHSms0eoU5MnqT1RWP8OuaOhNdwNtAVV4/OA0f
         eCIw/fxaKDLEbNqNGYVflvK6PVxAPENmaiI1O6TZewT1CtB0gVy85OO/8hiOxnCBUeP+
         XelM0Zx1vZ2lXssce53THN28R3VNuhz+D1TS8oqZlC8NaFKMunvqJtsf6CACbp/+ILi6
         3qwA5+VzQecV6WnK4hxVpxeOI3HfluO7FUP2fXY1j+w+t6BFQWF8QpCjU7McaNE26lfS
         sDlSHlDgoZWSwB0NEIQly10wiRwDyhPIFsKqldjiZ+NDy5tTmKLzRdTqgQ1Mqna+e1RS
         K5Mw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=uSHlmUF1rpi8jhNov2WbkstxfcDETX9FJi3N0xz+iuw=;
        b=HDbZhfdZiPB1uy9P0trUjo98h02Hn/19iBJm8CEmedq/D4WHT2L/0fq/j53FR10j8A
         X75jhorrlT3IJRLD6ovPB9TmRxHc8vm453LfGFPf0LhMI+Cuck//jCtq43hAmxNNyHcz
         2YbS/61Ik0WYB9toh5XzXwSkgBxiZISTAayGBQTdQ74xVbFcIeCi3g5R1O/aMpo9M7Bn
         lE0AwbMWTwvYTiT5/M7KlscNrs3wcDC4W+MkoGjxWaEaG4kmnVquKtwGp4gdHPl8tR0S
         W8We9T8GFTN1dlqmWdYuytAiPIxFyJbpF529MQmle5MWSrtkISO5+AKmLzEX7EgEtwQ4
         1qng==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w44si2331943edd.126.2019.03.25.07.02.22
        for <linux-mm@kvack.org>;
        Mon, 25 Mar 2019 07:02:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 95C1780D;
	Mon, 25 Mar 2019 07:02:21 -0700 (PDT)
Received: from [10.1.199.35] (e107154-lin.cambridge.arm.com [10.1.199.35])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 128E53F59C;
	Mon, 25 Mar 2019 07:02:12 -0700 (PDT)
Subject: Re: [PATCH v13 14/20] drm/amdgpu, arm64: untag user pointers in
 amdgpu_ttm_tt_get_user_pages
To: Catalin Marinas <catalin.marinas@arm.com>,
 Andrey Konovalov <andreyknvl@google.com>
Cc: Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>,
 Robin Murphy <robin.murphy@arm.com>, Kees Cook <keescook@chromium.org>,
 Kate Stewart <kstewart@linuxfoundation.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>,
 "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
 Shuah Khan <shuah@kernel.org>, Vincenzo Frascino
 <vincenzo.frascino@arm.com>, Eric Dumazet <edumazet@google.com>,
 "David S. Miller" <davem@davemloft.net>, Alexei Starovoitov
 <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>,
 Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>,
 Peter Zijlstra <peterz@infradead.org>,
 Arnaldo Carvalho de Melo <acme@kernel.org>,
 Alex Deucher <alexander.deucher@amd.com>,
 =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>,
 "David (ChunMing) Zhou" <David1.Zhou@amd.com>,
 Yishai Hadas <yishaih@mellanox.com>,
 Mauro Carvalho Chehab <mchehab@kernel.org>,
 Jens Wiklander <jens.wiklander@linaro.org>,
 Alex Williamson <alex.williamson@redhat.com>,
 linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
 linux-arch@vger.kernel.org, netdev@vger.kernel.org, bpf@vger.kernel.org,
 amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
 linux-rdma@vger.kernel.org, linux-media@vger.kernel.org,
 kvm@vger.kernel.org, linux-kselftest@vger.kernel.org,
 linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>,
 Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>,
 Lee Smith <Lee.Smith@arm.com>,
 Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
 Jacob Bramley <Jacob.Bramley@arm.com>,
 Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
 Chintan Pandya <cpandya@codeaurora.org>,
 Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
 Dave Martin <Dave.Martin@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
References: <cover.1553093420.git.andreyknvl@google.com>
 <017804b2198a906463d634f84777b6087c9b4a40.1553093421.git.andreyknvl@google.com>
 <20190322155955.GT13384@arrakis.emea.arm.com>
From: Kevin Brodsky <kevin.brodsky@arm.com>
Message-ID: <d054d40e-3f38-5728-8116-3cb0a5957f9b@arm.com>
Date: Mon, 25 Mar 2019 14:02:11 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <20190322155955.GT13384@arrakis.emea.arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-GB
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 22/03/2019 15:59, Catalin Marinas wrote:
> On Wed, Mar 20, 2019 at 03:51:28PM +0100, Andrey Konovalov wrote:
>> This patch is a part of a series that extends arm64 kernel ABI to allow to
>> pass tagged user pointers (with the top byte set to something else other
>> than 0x00) as syscall arguments.
>>
>> amdgpu_ttm_tt_get_user_pages() uses provided user pointers for vma
>> lookups, which can only by done with untagged pointers.
>>
>> Untag user pointers in this function.
>>
>> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
>> ---
>>   drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c | 5 +++--
>>   1 file changed, 3 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
>> index 73e71e61dc99..891b027fa33b 100644
>> --- a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
>> +++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
>> @@ -751,10 +751,11 @@ int amdgpu_ttm_tt_get_user_pages(struct ttm_tt *ttm, struct page **pages)
>>   		 * check that we only use anonymous memory to prevent problems
>>   		 * with writeback
>>   		 */
>> -		unsigned long end = gtt->userptr + ttm->num_pages * PAGE_SIZE;
>> +		unsigned long userptr = untagged_addr(gtt->userptr);
>> +		unsigned long end = userptr + ttm->num_pages * PAGE_SIZE;
>>   		struct vm_area_struct *vma;
>>   
>> -		vma = find_vma(mm, gtt->userptr);
>> +		vma = find_vma(mm, userptr);
>>   		if (!vma || vma->vm_file || vma->vm_end < end) {
>>   			up_read(&mm->mmap_sem);
>>   			return -EPERM;
> I tried to track this down but I failed to see whether user could
> provide an tagged pointer here (under the restrictions as per Vincenzo's
> ABI document).

->userptr is set by radeon_ttm_tt_set_userptr(), itself called from 
radeon_gem_userptr_ioctl(). Any page-aligned value is allowed.

Kevin

