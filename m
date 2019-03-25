Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A98FC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 14:08:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB2E22085A
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 14:08:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB2E22085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8351E6B0005; Mon, 25 Mar 2019 10:08:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 80B366B0006; Mon, 25 Mar 2019 10:08:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6ABB66B0007; Mon, 25 Mar 2019 10:08:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0F3B96B0005
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 10:08:42 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id p5so3884836edh.2
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 07:08:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=QuStp80/1COqFN7ZPn+OM4/gbDf4VEiju4htYMZSDPs=;
        b=ekkm3PxoVzm8GjuS/yHB8fOHqFuv7Qojn7SSDKOOejTAEDnQUjaVhs4nH9FBRPADv9
         i8uFIuSzVHj/BkcIFlq65Eggs3mYSZkVduj02E6ElOUS/qWaSmErXqGAk4+J5Ah9x7K/
         1SnruJXSOUlgW/fpCZftF5sU2p2wztF8k3yMCYaLr5BOITDK997sGoKzuKjxrY86VWTm
         LKjUcepj/fbm+eHy0LHQpjnFaAoiGRM2eAmtSq6nZIa3Fi56yOCvoEq6XOjzIBwoNJgX
         d+lnxOh4RYNjUF4nV8Lg1AV7KD0fTzvafsk0Nsl8WpXVrWBDwFTQgBmjKrmIC3zmpLrC
         mCNA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
X-Gm-Message-State: APjAAAUoLe63rCoBZWI4QzlK7Tzqfz6+dqOe8kEAzY/eQVtx5HEYuc1W
	jTgl85k2gpTDHECQawqh6FLowdmP2phEU5oaM/1s21muBnf+qfjk7kjcVg9xfiOHXZr4RRQBIrQ
	iuvH7yeA/roFBTobGkS2lNAxZK2lnnToSQCgyD1nRly+szJ8Ioz0QPvMUV0Ngm34m+Q==
X-Received: by 2002:a17:906:6408:: with SMTP id d8mr6056705ejm.185.1553522921615;
        Mon, 25 Mar 2019 07:08:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwQR9l/KB9vmWNTpWUNhDH+jYOvtAvLsV+LC3SuqM3vH8LsNfRK0Fu8QlXk/fgrmllFL0I/
X-Received: by 2002:a17:906:6408:: with SMTP id d8mr6056660ejm.185.1553522920700;
        Mon, 25 Mar 2019 07:08:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553522920; cv=none;
        d=google.com; s=arc-20160816;
        b=YQoerBwYsNGsthsw1J2VjcRBqwFKdI+UVoLgo8Wc0nCUU5wFoYTlh4luliGFuk3kc9
         84XVEf8Z4iIX0NOCXXbLExbs9nIstM+HJ8kUsAXtWi03tmtdEGGeDQtr6OLf3Mz9ovqc
         1P5tFXxknnDBnWK609cdcbNIc9gh+km6EGaU1Jw2AlsrTpgkP1Q/ciwLwu5Jc7wYooUB
         QRkOykzCwQ5ROr2rqT9tU5DvWuFc612VwLCmWs4g/mzrTJNYWgebDUFiOUAGc98cX4Eh
         kE7MhmYooTeaUeqBIdqpD/9gfhuQkZPqt1blEPeuwNLGEB1al+3QwZHLDYF6QCVdwOZp
         /JtQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=QuStp80/1COqFN7ZPn+OM4/gbDf4VEiju4htYMZSDPs=;
        b=VIQmh6TyK9ClhDSjZQLWBCsoCeiUq8lP8ELWBxAgMM8oUl4Y40Fh5AvWk7JwtHG28Z
         jCCKkRd+nOA1FBfpYF8Q5BaGMz03oBsTTTDln+40Johi17amRPd7l19wfzI2gvoH5n1u
         woklmoFX0rmassIFBOXgj0RgHZveuRb7NxYDa9Mn9kOWFVX8+Vrkwea/sfKLGY/usmUN
         p1edsrKf0liyue30NyNEd2BB77FfGf9AiQHo0FKXZeNlP+yg64rI8DM+t5rXedcWGUdm
         jj8qv61Y8/mXkHMB0YOxu+YrRCLbxQAeU5dPPw/mEi9ptXgrbgjQOadc6dwcRu1XuUmf
         mEJg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s21si1109520edb.391.2019.03.25.07.08.40
        for <linux-mm@kvack.org>;
        Mon, 25 Mar 2019 07:08:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 85E2A80D;
	Mon, 25 Mar 2019 07:08:39 -0700 (PDT)
Received: from [10.1.199.35] (e107154-lin.cambridge.arm.com [10.1.199.35])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id A2AE23F59C;
	Mon, 25 Mar 2019 07:08:31 -0700 (PDT)
Subject: Re: [PATCH v13 17/20] media/v4l2-core, arm64: untag user pointers in
 videobuf_dma_contig_user_get
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
 <ae6961bcdd82e529c76d0747abd310546f81e58e.1553093421.git.andreyknvl@google.com>
 <20190322160726.GV13384@arrakis.emea.arm.com>
From: Kevin Brodsky <kevin.brodsky@arm.com>
Message-ID: <bfaae923-98aa-63e7-c50b-8649dc5fe2bb@arm.com>
Date: Mon, 25 Mar 2019 14:08:30 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <20190322160726.GV13384@arrakis.emea.arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-GB
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 22/03/2019 16:07, Catalin Marinas wrote:
> On Wed, Mar 20, 2019 at 03:51:31PM +0100, Andrey Konovalov wrote:
>> This patch is a part of a series that extends arm64 kernel ABI to allow to
>> pass tagged user pointers (with the top byte set to something else other
>> than 0x00) as syscall arguments.
>>
>> videobuf_dma_contig_user_get() uses provided user pointers for vma
>> lookups, which can only by done with untagged pointers.
>>
>> Untag the pointers in this function.
>>
>> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
>> ---
>>   drivers/media/v4l2-core/videobuf-dma-contig.c | 9 +++++----
>>   1 file changed, 5 insertions(+), 4 deletions(-)
>>
>> diff --git a/drivers/media/v4l2-core/videobuf-dma-contig.c b/drivers/media/v4l2-core/videobuf-dma-contig.c
>> index e1bf50df4c70..8a1ddd146b17 100644
>> --- a/drivers/media/v4l2-core/videobuf-dma-contig.c
>> +++ b/drivers/media/v4l2-core/videobuf-dma-contig.c
>> @@ -160,6 +160,7 @@ static void videobuf_dma_contig_user_put(struct videobuf_dma_contig_memory *mem)
>>   static int videobuf_dma_contig_user_get(struct videobuf_dma_contig_memory *mem,
>>   					struct videobuf_buffer *vb)
>>   {
>> +	unsigned long untagged_baddr = untagged_addr(vb->baddr);
>>   	struct mm_struct *mm = current->mm;
>>   	struct vm_area_struct *vma;
>>   	unsigned long prev_pfn, this_pfn;
>> @@ -167,22 +168,22 @@ static int videobuf_dma_contig_user_get(struct videobuf_dma_contig_memory *mem,
>>   	unsigned int offset;
>>   	int ret;
>>   
>> -	offset = vb->baddr & ~PAGE_MASK;
>> +	offset = untagged_baddr & ~PAGE_MASK;
>>   	mem->size = PAGE_ALIGN(vb->size + offset);
>>   	ret = -EINVAL;
>>   
>>   	down_read(&mm->mmap_sem);
>>   
>> -	vma = find_vma(mm, vb->baddr);
>> +	vma = find_vma(mm, untagged_baddr);
>>   	if (!vma)
>>   		goto out_up;
>>   
>> -	if ((vb->baddr + mem->size) > vma->vm_end)
>> +	if ((untagged_baddr + mem->size) > vma->vm_end)
>>   		goto out_up;
>>   
>>   	pages_done = 0;
>>   	prev_pfn = 0; /* kill warning */
>> -	user_address = vb->baddr;
>> +	user_address = untagged_baddr;
>>   
>>   	while (pages_done < (mem->size >> PAGE_SHIFT)) {
>>   		ret = follow_pfn(vma, user_address, &this_pfn);
> I don't think vb->baddr here is anonymous mmap() but worth checking the
> call paths.

I spent some time on this, I didn't find any restriction on the kind of mapping 
that's allowed here. The API regarding V4L2_MEMORY_USERPTR doesn't seem to say 
anything about that either [0] [1]. It's probably best to ask the V4L2 maintainers.

Kevin

[0] https://www.kernel.org/doc/html/latest/media/uapi/v4l/vidioc-qbuf.html
[1] https://www.kernel.org/doc/html/latest/media/uapi/v4l/userp.html

