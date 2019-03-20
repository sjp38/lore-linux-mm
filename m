Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21B68C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 18:17:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B6DA6218A3
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 18:17:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B6DA6218A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C1306B0003; Wed, 20 Mar 2019 14:17:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1713E6B0006; Wed, 20 Mar 2019 14:17:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0868C6B0007; Wed, 20 Mar 2019 14:17:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A94526B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 14:17:04 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id x13so1254929edq.11
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 11:17:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=XYBNTBcnzuZ2Pwh1EIdzzhez3Gfk9u6OWDYBlheg+Zw=;
        b=ZbcU7QucR8t0PV/dvBhVClvz/NMfOX3oS+LAiSJT8b6O73lJyWxUyHJ7imEj8DUpQ3
         E7PVUagBiU/OvD+vZx8nCesfktafn3buM5j2M+PuufSkP236TjbQ0/Jts/o4++Tje2bb
         LmnBJFzIIj/wDrVEU1jPM5ePL5xCch2dLoqwV2THJ5SrAYNeQUJXYQEUYo8p2RLkEzoV
         f4Du54CAUUsV+Oayaik5QYnKIW/rBSb7x5KewU+CPXwjE8ZXpWrdPmfwnRk4GL16Y38F
         qE7/mSZdw3wJUTKMjp6dDvu8eIEQIgRj2ExSK74MxXqGp0G8TDgQEJzUVAV4VpSJKXrD
         w6Jw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAVTpb99u7CEEYNYepc17lMNhPAJcDGM5t75omAu/0OpuiPMcOfw
	FI51wNd7I4SKmghV+Gl7RkUCemnchyzp59NoJm3iIIyhKhXjgmLLyx8S0PoC4N9YJMvGocueHOx
	Lu3VqaPv5VKkVMO1FN3gWQbQgwZwJ46n3qsHfRAGQAQrRpoLOLH3OUh/vVmkPn26YDQ==
X-Received: by 2002:a17:906:1d41:: with SMTP id o1mr17514357ejh.72.1553105824080;
        Wed, 20 Mar 2019 11:17:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzcrfkyn69jyqmfavhHSqKsVw3BTvpUMNWFOMI/bypKy+0B6IwJ5psfmHdeWRIldvHeesjP
X-Received: by 2002:a17:906:1d41:: with SMTP id o1mr17514321ejh.72.1553105823056;
        Wed, 20 Mar 2019 11:17:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553105823; cv=none;
        d=google.com; s=arc-20160816;
        b=Qd+hJLon3EVqiinMI32MqkzGPGIedpsAqI4C02CqeSvCLRCDuujGb0pUp+7NrcQpyj
         mCUE9VJWIzBNiiZSYy27x8ed4Y0kNZzz3AA9sW6ZuWPWAHNPBC6PaXPeLGlrBXYOwZUI
         QyIW2xkgCHLs/yMIsjQaWJqX/EHm9h1SxZjDtAly35T8veWG9KwABbdnFJY/W/G32+0E
         NSZMY+nNuvrHCCOUSgY8ADiGAYd+LEetYOLZZIGqV3oKB5BnO69cAT2V/fpOc2BqFs9V
         g4iNWYGGqX7EmFrXL2Wu5d3pMucjALCihEEslAw6b1ybUBoepW+Dg2lX6pn390qyrE6W
         LiZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=XYBNTBcnzuZ2Pwh1EIdzzhez3Gfk9u6OWDYBlheg+Zw=;
        b=JUfwF6cQ2Msj5iyFHXSWFvqhABTlQGJQkBI65QdEHihp6KsYrF8NVeMNmZmj+fLi4x
         rB9GpMWdX8YoOUlm5l56qSK0JdXmyihO5p8O9Km3hGZlB9OB55QtESjbmuIruM9XgL9s
         1g2Xw0AMziqrW5b/AJzBB7IEysY0xaGs4Jr9iRPzEY8E4U5sVs/ExiDZ4CxQPckApWxa
         Wvv6/WROsy1NaDJLy59Y9f3S6AHfb2xsa2iJ4tPdrN0SwqrSNmulM/kYL7cU+6RD5JqQ
         c+LzfgXz4FxlQptlautWWkUh8PAEq/fwZpYs9HfzoWowQ9Y7Aj9LgqsrESrVqCHoFYPz
         jh8w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v15si1062422edr.91.2019.03.20.11.17.02
        for <linux-mm@kvack.org>;
        Wed, 20 Mar 2019 11:17:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id AE9A8A78;
	Wed, 20 Mar 2019 11:17:01 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id E1F723F59C;
	Wed, 20 Mar 2019 11:16:59 -0700 (PDT)
Date: Wed, 20 Mar 2019 18:16:57 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Qian Cai <cai@lca.pw>, akpm@linux-foundation.org, paulus@ozlabs.org,
	benh@kernel.crashing.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kvm-ppc@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
Subject: Re: [PATCH v2] kmemleak: skip scanning holes in the .bss section
Message-ID: <20190320181656.GB38229@arrakis.emea.arm.com>
References: <20190313145717.46369-1-cai@lca.pw>
 <20190319115747.GB59586@arrakis.emea.arm.com>
 <87lg19y9dp.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87lg19y9dp.fsf@concordia.ellerman.id.au>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 21, 2019 at 12:15:46AM +1100, Michael Ellerman wrote:
> Catalin Marinas <catalin.marinas@arm.com> writes:
> > On Wed, Mar 13, 2019 at 10:57:17AM -0400, Qian Cai wrote:
> >> @@ -1531,7 +1547,14 @@ static void kmemleak_scan(void)
> >>  
> >>  	/* data/bss scanning */
> >>  	scan_large_block(_sdata, _edata);
> >> -	scan_large_block(__bss_start, __bss_stop);
> >> +
> >> +	if (bss_hole_start) {
> >> +		scan_large_block(__bss_start, bss_hole_start);
> >> +		scan_large_block(bss_hole_stop, __bss_stop);
> >> +	} else {
> >> +		scan_large_block(__bss_start, __bss_stop);
> >> +	}
> >> +
> >>  	scan_large_block(__start_ro_after_init, __end_ro_after_init);
> >
> > I'm not a fan of this approach but I couldn't come up with anything
> > better. I was hoping we could check for PageReserved() in scan_block()
> > but on arm64 it ends up not scanning the .bss at all.
> >
> > Until another user appears, I'm ok with this patch.
> >
> > Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> 
> I actually would like to rework this kvm_tmp thing to not be in bss at
> all. It's a bit of a hack and is incompatible with strict RWX.
> 
> If we size it a bit more conservatively we can hopefully just reserve
> some space in the text section for it.
> 
> I'm not going to have time to work on that immediately though, so if
> people want this fixed now then this patch could go in as a temporary
> solution.

I think I have a simpler idea. Kmemleak allows punching holes in
allocated objects, so just turn the data/bss sections into dedicated
kmemleak objects. This happens when kmemleak is initialised, before the
initcalls are invoked. The kvm_free_tmp() would just free the
corresponding part of the bss.

Patch below, only tested briefly on arm64. Qian, could you give it a try
on powerpc? Thanks.

--------8<------------------------------
diff --git a/arch/powerpc/kernel/kvm.c b/arch/powerpc/kernel/kvm.c
index 683b5b3805bd..c4b8cb3c298d 100644
--- a/arch/powerpc/kernel/kvm.c
+++ b/arch/powerpc/kernel/kvm.c
@@ -712,6 +712,8 @@ static void kvm_use_magic_page(void)
 
 static __init void kvm_free_tmp(void)
 {
+	kmemleak_free_part(&kvm_tmp[kvm_tmp_index],
+			   ARRAY_SIZE(kvm_tmp) - kvm_tmp_index);
 	free_reserved_area(&kvm_tmp[kvm_tmp_index],
 			   &kvm_tmp[ARRAY_SIZE(kvm_tmp)], -1, NULL);
 }
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 707fa5579f66..0f6adcbfc2c7 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1529,11 +1529,6 @@ static void kmemleak_scan(void)
 	}
 	rcu_read_unlock();
 
-	/* data/bss scanning */
-	scan_large_block(_sdata, _edata);
-	scan_large_block(__bss_start, __bss_stop);
-	scan_large_block(__start_ro_after_init, __end_ro_after_init);
-
 #ifdef CONFIG_SMP
 	/* per-cpu sections scanning */
 	for_each_possible_cpu(i)
@@ -2071,6 +2066,15 @@ void __init kmemleak_init(void)
 	}
 	local_irq_restore(flags);
 
+	/* register the data/bss sections */
+	create_object((unsigned long)_sdata, _edata - _sdata,
+		      KMEMLEAK_GREY, GFP_ATOMIC);
+	create_object((unsigned long)__bss_start, __bss_stop - __bss_start,
+		      KMEMLEAK_GREY, GFP_ATOMIC);
+	create_object((unsigned long)__start_ro_after_init,
+		      __end_ro_after_init - __start_ro_after_init,
+		      KMEMLEAK_GREY, GFP_ATOMIC);
+
 	/*
 	 * This is the point where tracking allocations is safe. Automatic
 	 * scanning is started during the late initcall. Add the early logged

