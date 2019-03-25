Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25B52C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 13:55:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C5E5020830
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 13:55:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C5E5020830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 186876B0003; Mon, 25 Mar 2019 09:55:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 136026B0006; Mon, 25 Mar 2019 09:55:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EF3596B0007; Mon, 25 Mar 2019 09:54:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 912DB6B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 09:54:59 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id t4so3872309eds.1
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 06:54:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=iXu0py71qdgn6kC6c0X9ohJjgxQ1bpGWYDj+FbV2C44=;
        b=XBhaRvMykZPsDMKvXDNYgxbanIPjOxLb9ZtbmGx8qHf1KAJaKMQ8e3HoZGGwbOikLZ
         yQzFqKJY85IVzkqmL1D+7eBf+yNihkVCCeLhUlGrKJoZ47o/O4G7eHHXTjQlXVnB+H7z
         wpJFyH8jxv9GykD8R8Q7BXik6RYsHuNZc6o3H8KxC97Wc84bCGHYAkOadH1iVsoWWkvW
         kVSuk2Obj1eyK1FvytCxM5wv4+hPhsgM0bLg8X9d0YmVAJtt17A4hCPPa5Y3JqNjeBKD
         sj/hmxJYYLhnO+zKGThMzgW5uaPp1PZcKNQOtXmP5IKU1cDIp3R0ElKtSqSuRvrifmu9
         R3XQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
X-Gm-Message-State: APjAAAXX9UjJGgXOFE2WTi/XwmpgeNI9N3HMorLVmtjnijfId6cOxIph
	4A2JbqKbGIPrcfC0CwIUUdb2OQ/PHbD0rJ7BI/Olr1mgOoe3IwPp2GbprKm1PP0IzmWZHgQw4r2
	zn/QenaMUNvGUC/7FM0RcfXSMdVEx24c43VMVHkHIsoPJYDc5NVQfiY25xBeuuerCWQ==
X-Received: by 2002:a17:906:640f:: with SMTP id d15mr12704042ejm.217.1553522099014;
        Mon, 25 Mar 2019 06:54:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyoATW0CH0lnn6zvTnh52AJZ44Iy9ewVXf5Wq/2TyJ3tbqkA7d+I4Qx/QGGKo4KKolxl5eh
X-Received: by 2002:a17:906:640f:: with SMTP id d15mr12703991ejm.217.1553522097815;
        Mon, 25 Mar 2019 06:54:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553522097; cv=none;
        d=google.com; s=arc-20160816;
        b=jS6P6k9FyDATtq+/stpa/rLMX5C1HqrnuE/Ysp/x1ob8AcURqHCf4+rIuOoQ4tNIIz
         +NBeP/GiZfg2SFE5wZgRrqEtWpQLrLYlmhfb3VE/dczj0RFWPXcqix2pozlKIWim6QDy
         Q0JBCqknfONTnLy9GGYJNxqsCX2jQTRy8RchP/vpGK3AIHgbLfjbGib1rjT5ttiV99Qt
         vKjKU/lEgZki7lTS26t+qZ1fvHT5WXZp6M+kDHNMK4VmwpAhi5R6TuJ/rOzulx0srmSb
         KGXAuFTZpGJ2V2FRpMFUvaguzIFBVVmnRCcaYlelFF4XNantJB5sI1I/e0Oh78KKOqmb
         QSUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=iXu0py71qdgn6kC6c0X9ohJjgxQ1bpGWYDj+FbV2C44=;
        b=IEfIok7trQBsJE08T+88wrDJG9fZ8Vzey9KZgr/dmcTyU5GOD2hgLMANAiZwZkmiVi
         NE8wj2d7Da+TTuoHYu5L5KBHwy2O+f4xvFj3gZ06UHQdUOHxXY//H34w2Fg4Ag5imdyj
         59lyzz2MmnZGdi1GkqpmTl6QJfUc5lhA1858VDNpE9GBgL3Jxr2mabeU02IS39xZOW2a
         WbXxRJvUOqI9TTrTt+/ncgj9170CrlDoZvqP5aIwDOVf1VQ9nVBYzcsOg12vHTglWzfy
         cWbHCCbs2MOPdpXH6Ju2wY4JtI7syBfWXEL+90Qptm0zGCCYkVJHdATlSofY4TGo8PZs
         GO3g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d56si483463eda.12.2019.03.25.06.54.57
        for <linux-mm@kvack.org>;
        Mon, 25 Mar 2019 06:54:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 3014F80D;
	Mon, 25 Mar 2019 06:54:56 -0700 (PDT)
Received: from [10.1.199.35] (e107154-lin.cambridge.arm.com [10.1.199.35])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 6EDE93F59C;
	Mon, 25 Mar 2019 06:54:48 -0700 (PDT)
Subject: Re: [PATCH v13 09/20] net, arm64: untag user pointers in
 tcp_zerocopy_receive
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
 <2280b62096ce1fa5c9e9429d18f08f82f4be1b0b.1553093421.git.andreyknvl@google.com>
 <20190322120434.GD13384@arrakis.emea.arm.com>
From: Kevin Brodsky <kevin.brodsky@arm.com>
Message-ID: <e5ed4fff-acf6-7b85-bf8f-df558a9cd33f@arm.com>
Date: Mon, 25 Mar 2019 13:54:46 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <20190322120434.GD13384@arrakis.emea.arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-GB
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 22/03/2019 12:04, Catalin Marinas wrote:
> On Wed, Mar 20, 2019 at 03:51:23PM +0100, Andrey Konovalov wrote:
>> This patch is a part of a series that extends arm64 kernel ABI to allow to
>> pass tagged user pointers (with the top byte set to something else other
>> than 0x00) as syscall arguments.
>>
>> tcp_zerocopy_receive() uses provided user pointers for vma lookups, which
>> can only by done with untagged pointers.
>>
>> Untag user pointers in this function.
>>
>> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
>> ---
>>   net/ipv4/tcp.c | 2 ++
>>   1 file changed, 2 insertions(+)
>>
>> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
>> index 6baa6dc1b13b..855a1f68c1ea 100644
>> --- a/net/ipv4/tcp.c
>> +++ b/net/ipv4/tcp.c
>> @@ -1761,6 +1761,8 @@ static int tcp_zerocopy_receive(struct sock *sk,
>>   	if (address & (PAGE_SIZE - 1) || address != zc->address)
>>   		return -EINVAL;
>>   
>> +	address = untagged_addr(address);
>> +
>>   	if (sk->sk_state == TCP_LISTEN)
>>   		return -ENOTCONN;
> I don't think we need this patch if we stick to Vincenzo's ABI
> restrictions. Can zc->address be an anonymous mmap()? My understanding
> of TCP_ZEROCOPY_RECEIVE is that this is an mmap() on a socket, so user
> should not tag such pointer.

Good point, I hadn't looked into the interface properly. The `vma->vm_ops != 
&tcp_vm_ops` check just below makes sure that the mapping is specifically tied to a 
TCP socket, so definitely not included in the ABI relaxation.

> We want to allow tagged pointers to work transparently only for heap and
> stack, hence the restriction to anonymous mmap() and those addresses
> below sbrk(0).

That's not quite true: in the ABI relaxation v2, all private mappings that are either 
anonymous or backed by a regular file are included. The scope is quite a bit larger 
than heap and stack, even though this is what we're primarily interested in for now.

Kevin

