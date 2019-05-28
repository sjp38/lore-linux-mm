Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7AD61C072B1
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 17:02:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 17E702075B
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 17:02:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 17E702075B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 663916B0274; Tue, 28 May 2019 13:02:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 63A3D6B0279; Tue, 28 May 2019 13:02:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 550E06B027A; Tue, 28 May 2019 13:02:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 080516B0274
	for <linux-mm@kvack.org>; Tue, 28 May 2019 13:02:57 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id n23so34040340edv.9
        for <linux-mm@kvack.org>; Tue, 28 May 2019 10:02:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=2eNLXj0BDf+04WD1XZXHrVRn0IpbXBSVpM/syCMyzyg=;
        b=cMoF6bdV1zPwyP8tynUPrX6V6STrwcyxuqiiLt6q7s/dE56wfKrdo4FsHxZwBNQG0g
         QLDhwmRVtD0fefhCTAuYKKlPA0Nkl7dCQH5WxTFntyOwqEnxsy4oZzEGHiHYeGZqdgw3
         EA0PJJLftENFZygdyKoiP81EmDhD5J03mM1TQ+TD9vRpXR4oa5mJJ3iaMN21S0XHHPX3
         FkEN4SdnWqLxoauixLPIwogkfYE2O++gQq8MtyAZ9fIlxcjvuLw43Rfjd+kPMKIIWFME
         SG60jRAwXkTnfVoVst/MMWF7FW4pM2KCm62WNkgh9oA2aBqq0chI2YDNt39/uAOyPjwx
         /daA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAXMNpxZNGwxIJubjf0bGdJbFIBBi1xvnsL5uhUN42sJ+dg+0nWa
	EZQdDUYyWsyEqbtrN9unkUsEYvAKCqhyuS4zYH3M37LV9DW6CnLcBHebkxBzW0m8mO14PBVVTui
	vYhJHnl8I/FXO0cOxBMqSXfawM/oKAVMqOgo1bu3yrr1ADgy1wZ5yW7gFRYjDC1q6HQ==
X-Received: by 2002:a17:906:b2da:: with SMTP id cf26mr3286867ejb.280.1559062976586;
        Tue, 28 May 2019 10:02:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyCiC79QKk28AKCFsJvKhTumtdEPnVabZg1gUQMA2HEHtw0E2vZDNXsRto46ZbZqSFmbiKK
X-Received: by 2002:a17:906:b2da:: with SMTP id cf26mr3286720ejb.280.1559062975097;
        Tue, 28 May 2019 10:02:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559062975; cv=none;
        d=google.com; s=arc-20160816;
        b=fWTKxm7sYQjcETQzLRyPYhbfP7e4FUWoSaunKOy3zQVSRVIwQDOoOcTGEE5oEz6O/V
         hen2UujgxSHCWVSn2eN18S4EkAABDEwDMn9h8nupWhH08G8TAbRi3xH3MWjtsapMvKKm
         cgfFT4p57+sT1GrqGqe3K9CngrSD+NOqm9Q683FPgJ/PqOhrRvwO+RqnbsGxrJRIfDcx
         BKESKWnrw+YjeNVCmGa440yL07QL57VfBfkIQsiekx1rGgFW3Ho+2ycCZXdTNrEsBLeL
         kNO4LMqwRk6HYZFXayU5GP1zkZ4LEfCQPAAnkOxRrl0DkfD3FMIPsBOhONVHpkuQEuCO
         yhIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=2eNLXj0BDf+04WD1XZXHrVRn0IpbXBSVpM/syCMyzyg=;
        b=cKPjVlCteAGGnIKZ7FgasIGt5zuPZhdnu4kYfsAJcTkymJLjy87eKfDCWOHLpX2S9m
         ZyQzEhKI/j4EJ1+wGY2hhqE5d9UcBZ9BER7q94z7obwVzYcQzj7qrvUJdCSMGrg4uAVI
         /s3VKM8nXFYHKlchpkKO78bkrF8JSnf1jREwHOQx3uKw7wRNyqkfR/oeyjshoorqtbxF
         ffqe9U82fWSbs/POaSIWHe6UFHm1NUia43VJBneAPq7C0DdUAjm5uKXYlQTw3L+54EZj
         zmsGL69mPM6s/y86yxRHjnaCAXdtMxeKMw+UTOUO8wrwy3CzpE0rYbn+YwuqB4bghBtO
         kERQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i23si551224ejv.131.2019.05.28.10.02.54
        for <linux-mm@kvack.org>;
        Tue, 28 May 2019 10:02:55 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id A5FEB341;
	Tue, 28 May 2019 10:02:53 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C71E83F59C;
	Tue, 28 May 2019 10:02:47 -0700 (PDT)
Date: Tue, 28 May 2019 18:02:45 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Kees Cook <keescook@chromium.org>
Cc: enh <enh@google.com>, Evgenii Stepanov <eugenis@google.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>, Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v15 00/17] arm64: untag user pointers passed to the kernel
Message-ID: <20190528170244.GF32006@arrakis.emea.arm.com>
References: <20190521182932.sm4vxweuwo5ermyd@mbp>
 <201905211633.6C0BF0C2@keescook>
 <20190522101110.m2stmpaj7seezveq@mbp>
 <CAJgzZoosKBwqXRyA6fb8QQSZXFqfHqe9qO9je5TogHhzuoGXJQ@mail.gmail.com>
 <20190522163527.rnnc6t4tll7tk5zw@mbp>
 <201905221316.865581CF@keescook>
 <20190523144449.waam2mkyzhjpqpur@mbp>
 <201905230917.DEE7A75EF0@keescook>
 <20190523174345.6sv3kcipkvlwfmox@mbp>
 <201905231327.77CA8D0A36@keescook>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201905231327.77CA8D0A36@keescook>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 02:31:16PM -0700, Kees Cook wrote:
> syzkaller already attempts to randomly inject non-canonical and
> 0xFFFF....FFFF addresses for user pointers in syscalls in an effort to
> find bugs like CVE-2017-5123 where waitid() via unchecked put_user() was
> able to write directly to kernel memory[1].
> 
> It seems that using TBI by default and not allowing a switch back to
> "normal" ABI without a reboot actually means that userspace cannot inject
> kernel pointers into syscalls any more, since they'll get universally
> stripped now. Is my understanding correct, here? i.e. exploiting
> CVE-2017-5123 would be impossible under TBI?
> 
> If so, then I think we should commit to the TBI ABI and have a boot
> flag to disable it, but NOT have a process flag, as that would allow
> attackers to bypass the masking. The only flag should be "TBI or MTE".
> 
> If so, can I get top byte masking for other architectures too? Like,
> just to strip high bits off userspace addresses? ;)

Just for fun, hack/attempt at your idea which should not interfere with
TBI. Only briefly tested on arm64 (and the s390 __TYPE_IS_PTR macro is
pretty weird ;)):

--------------------------8<---------------------------------
diff --git a/arch/s390/include/asm/compat.h b/arch/s390/include/asm/compat.h
index 63b46e30b2c3..338455a74eff 100644
--- a/arch/s390/include/asm/compat.h
+++ b/arch/s390/include/asm/compat.h
@@ -11,9 +11,6 @@
 
 #include <asm-generic/compat.h>
 
-#define __TYPE_IS_PTR(t) (!__builtin_types_compatible_p( \
-				typeof(0?(__force t)0:0ULL), u64))
-
 #define __SC_DELOUSE(t,v) ({ \
 	BUILD_BUG_ON(sizeof(t) > 4 && !__TYPE_IS_PTR(t)); \
 	(__force t)(__TYPE_IS_PTR(t) ? ((v) & 0x7fffffff) : (v)); \
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index e2870fe1be5b..b1b9fe8502da 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -119,8 +119,15 @@ struct io_uring_params;
 #define __TYPE_IS_L(t)	(__TYPE_AS(t, 0L))
 #define __TYPE_IS_UL(t)	(__TYPE_AS(t, 0UL))
 #define __TYPE_IS_LL(t) (__TYPE_AS(t, 0LL) || __TYPE_AS(t, 0ULL))
+#define __TYPE_IS_PTR(t) (!__builtin_types_compatible_p(typeof(0 ? (__force t)0 : 0ULL), u64))
 #define __SC_LONG(t, a) __typeof(__builtin_choose_expr(__TYPE_IS_LL(t), 0LL, 0L)) a
+#ifdef CONFIG_64BIT
+#define __SC_CAST(t, a)	(__TYPE_IS_PTR(t) \
+				? (__force t) ((__u64)a & ~(1UL << 55)) \
+				: (__force t) a)
+#else
 #define __SC_CAST(t, a)	(__force t) a
+#endif
 #define __SC_ARGS(t, a)	a
 #define __SC_TEST(t, a) (void)BUILD_BUG_ON_ZERO(!__TYPE_IS_LL(t) && sizeof(t) > sizeof(long))
 

-- 
Catalin

