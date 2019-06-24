Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C325EC43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 08:42:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 85A5320663
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 08:42:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GaVWc9JS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 85A5320663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C2C68E0006; Mon, 24 Jun 2019 04:42:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 073878E0002; Mon, 24 Jun 2019 04:42:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA4B58E0006; Mon, 24 Jun 2019 04:42:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id C9EFD8E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 04:42:32 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id y13so21108793iol.6
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 01:42:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=hZDK98pFVpxt3chkW1SOjanxcVKTD0vgdvliCnO9TDw=;
        b=Xuoy1wffprA0cWVFoyf8yRnvfFhw1LX1GRSe3mfJM4it4/oE9yv49g5bv2NyMfHbRM
         H0ZUGLbmDmxRKw2V+wwDyLYbFSGtbRcxgLE1kdh4IWFwYZjdt/KH/eA1KMvOD8V9ruQh
         KsFECMA4P+oz8rLM1kXCbz0KUxJZyulnP2EtChlpkmLQf6LsoUpm2FLIBwHKJjHT9kRq
         QweO8+/1MnsMjZwGtoL7keCcZ3Ne1i1UUxBOs+Fm39RWsyW/GK9YqXKD69GQAmYwPJeY
         LrRV7NLvzfmCC3fb5SJRsdS31s+bMq1tqAWhlELw3OaFPzaR7qp2RSHVO7QBZ53j1J8A
         hsPw==
X-Gm-Message-State: APjAAAWICuWtpGcEmqChRaZ/N8JSYN1h/BUo+Ayq/OA4MPoKzR8hp0IL
	MdOPf26E4oKD8rnxLXdO37CLNsybM7OaDNdc1rWqYqCtVeTnH81hAQxnAtGJR0VvLiwqRLw/Pv4
	KDuTs3AQyIukwYkgDZHJ0uZJd3xeulp8+gJctfylM0ybryLTpLTcu+gpMKY0uTTG/9g==
X-Received: by 2002:a6b:5b01:: with SMTP id v1mr727185ioh.120.1561365752546;
        Mon, 24 Jun 2019 01:42:32 -0700 (PDT)
X-Received: by 2002:a6b:5b01:: with SMTP id v1mr727147ioh.120.1561365751813;
        Mon, 24 Jun 2019 01:42:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561365751; cv=none;
        d=google.com; s=arc-20160816;
        b=AfdMC9Mky1vugEMQgJvZXLtiYvkhJsknDyZeKQ862AgHiHcOpopUmEM7o7ZTw2tvWA
         KR8YCi3FjGqVbFbIsnmTF7t4hJ4Qddy2UR9EoAmvTou97JvbeaDGzHzvE0I+ChWxI/kT
         h+4XLGwnA2bT+sTk5DpsFx7HCqGPQd1kGS9CEUVfanYrlbv/qap6idmK2Ucixg03Nad6
         cQT3yr0AoNIE23Pqq+6aNx5ZBaCcZsp76uTR+LDY+TZp0VcEtS80jdKAyGdmFM96avqW
         T5F/JgcHk3ktcZJ3WLkjnhB0FSbo32xhbUHVZ5FQmc6ZQizF9EkqwOkxPrskOHhjvySX
         LAUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=hZDK98pFVpxt3chkW1SOjanxcVKTD0vgdvliCnO9TDw=;
        b=mCrix645d2EqhxL/8EjfibnKLLcpgMj2Tr9roDyKIoOS//zc7hJKvW9glqIUM+gkG8
         wsZHs4ubjiEPe7vfliz7xvhvrKxShFR+DqtNnWTPDwCmnF3qdAQJt21k8bgnaW3Pp0Ml
         w0kxvn+5dbKf2UdSvyIvQczTTkHIT96NrGvcLuPE94+LDNvYEcx+uJdmmeWHCeXZBf3b
         W2XR8WyQKMEMwfjKd1kjLKc2tIdTfzUsADahfrdonVf5qj4946fQESVEQMuJ0Algb215
         FC2KJtLktUbSIEyEZ9/zPVVE2/LEs3W3dd3zgP2yiArCVGoALGCD32pUx2NCLbYx9qOJ
         HU7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GaVWc9JS;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 197sor27926143jaa.13.2019.06.24.01.42.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 01:42:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GaVWc9JS;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=hZDK98pFVpxt3chkW1SOjanxcVKTD0vgdvliCnO9TDw=;
        b=GaVWc9JSf9wAxISpuhTVscTFLYvILW3vniklJFaI1vv/NHx9x1mRLzYj/z0McDaIeh
         UC2vVaMO7FpWZQP3TW5wdKIxA4UlAI7b2N1VaOCcNCctRhbMbyy6RECYU1QiHsVyOriM
         siiSyvwCDXUyOxOwnDOqdCHjuJsKeAyey2cmjwd9hzF4qJz3x2gW3YxggyHWn3FlToV+
         9rjw8ZCnxaWx2gEpS/hmCi3nAWjd3FobYDlVWMJU+SoqDOTwK6pmo3qlmxzEHHXCx8tF
         vRPGIzZQxBbIJIdesoB/MbQ9xrDVXG0U8pXE/jhRah3fpzWlpC2c5Dzrn2NaYHF7FxKJ
         TYJw==
X-Google-Smtp-Source: APXvYqxx7glCCsFqx7G/HkqXPaiYIfpS79svZoUBDKDV/wgnir+RKuzvj8Mui4giQxIVCXR+W8I7qXj9HjI3nRGl4Eo=
X-Received: by 2002:a05:6638:40c:: with SMTP id q12mr22707922jap.17.1561365751552;
 Mon, 24 Jun 2019 01:42:31 -0700 (PDT)
MIME-Version: 1.0
References: <20190512054829.11899-1-cai@lca.pw> <20190513124112.GH24036@dhcp22.suse.cz>
 <1561123078.5154.41.camel@lca.pw> <20190621135507.GE3429@dhcp22.suse.cz>
In-Reply-To: <20190621135507.GE3429@dhcp22.suse.cz>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Mon, 24 Jun 2019 16:42:20 +0800
Message-ID: <CAFgQCTvSJjzFGGyt_VOvyB46yy6452wach7UmmuY5ZJZ3YZzcg@mail.gmail.com>
Subject: Re: [PATCH -next v2] mm/hotplug: fix a null-ptr-deref during NUMA boot
To: Michal Hocko <mhocko@kernel.org>
Cc: Qian Cai <cai@lca.pw>, Andrew Morton <akpm@linux-foundation.org>, 
	Barret Rhoden <brho@google.com>, Dave Hansen <dave.hansen@intel.com>, 
	Mike Rapoport <rppt@linux.ibm.com>, Peter Zijlstra <peterz@infradead.org>, 
	Michael Ellerman <mpe@ellerman.id.au>, Ingo Molnar <mingo@elte.hu>, Oscar Salvador <osalvador@suse.de>, 
	Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Michal,

What about dropping the change of the online definition of your patch,
just do the following?
diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index e6dad60..9c087c3 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -749,13 +749,12 @@ static void __init init_memory_less_node(int nid)
  */
 void __init init_cpu_to_node(void)
 {
-       int cpu;
+       int cpu, node;
        u16 *cpu_to_apicid = early_per_cpu_ptr(x86_cpu_to_apicid);

        BUG_ON(cpu_to_apicid == NULL);

-       for_each_possible_cpu(cpu) {
-               int node = numa_cpu_node(cpu);
+       for_each_node_mask(node, numa_nodes_parsed) {

                if (node == NUMA_NO_NODE)
                        continue;
@@ -765,6 +764,10 @@ void __init init_cpu_to_node(void)

                numa_set_node(cpu, node);
        }
+       for_each_possible_cpu(cpu) {
+               int node = numa_cpu_node(cpu);
+               numa_set_node(cpu, node);
+       }
 }

Thanks,
  Pingfan

On Fri, Jun 21, 2019 at 9:55 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 21-06-19 09:17:58, Qian Cai wrote:
> > Sigh...
> >
> > I don't see any benefit to keep the broken commit,
> >
> > "x86, numa: always initialize all possible nodes"
> >
> > for so long in linux-next that just prevent x86 NUMA machines with any memory-
> > less node from booting.
> >
> > Andrew, maybe it is time to drop this patch until Michal found some time to fix
> > it properly.
>
> Yes, please drop the patch for now, Andrew. I thought I could get to
> this but time is just scarce.
> --
> Michal Hocko
> SUSE Labs

