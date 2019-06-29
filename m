Return-Path: <SRS0=BwCX=U4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 931AEC5B57A
	for <linux-mm@archiver.kernel.org>; Sat, 29 Jun 2019 14:50:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4EA0D214AF
	for <linux-mm@archiver.kernel.org>; Sat, 29 Jun 2019 14:50:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AlVvTidm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4EA0D214AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=roeck-us.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DFAE96B0003; Sat, 29 Jun 2019 10:50:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DAC838E0003; Sat, 29 Jun 2019 10:50:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C74B18E0002; Sat, 29 Jun 2019 10:50:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f206.google.com (mail-pf1-f206.google.com [209.85.210.206])
	by kanga.kvack.org (Postfix) with ESMTP id 8EDE16B0003
	for <linux-mm@kvack.org>; Sat, 29 Jun 2019 10:50:12 -0400 (EDT)
Received: by mail-pf1-f206.google.com with SMTP id g21so5678368pfb.13
        for <linux-mm@kvack.org>; Sat, 29 Jun 2019 07:50:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=gpwY9SEzwskjwipmCEjEPDzJ+JkSWKdevJdN5fw1/iM=;
        b=jLo9xeZ4cq0rCS0YE9KE353OA3BW+ErafMyggQ8lU4xpiYko0Tx6pwnmBNuZz91f6o
         5ar92f5Skugd3g/IA7ynohHhSDui43m6dg2SIDp2NmuUfNfuQ9/OZ0K6O3/MEvoGiMzx
         +8UBeP3/0KgJWa+zMtePQtcI+gOnFSzzoBlHCARuB+7NWBqttOK5oz7fGycEjQsAm/+g
         YCRzt0bo+fN1wQGJkEtPXmYFRayAt6hOdHMqiyGD28XsWM+B92OykpuAIi+e0idpQvGU
         ZZvsQoB9B/RmyqGy4sQ+66xWmXlEqeDVIhpL+brPmI2NS6MPSt8bw2g154s2s5YJCc8r
         BVXg==
X-Gm-Message-State: APjAAAVr3KXQ0bYTX+AGeJh49pH2q1FO/ADxDuz5pSLjMQI78p8nsyGQ
	aNs72BvG2o2unKdxx/9wGTKl45XxG0xm5vSwiklebGFK3YedOO9Vpv6Q1Z53rqgYpmZzAPhUDsz
	ILbAYj74zeY3OP9ZESI+fi6w5Z181bqTZ0roAT/EBaU165qEp6/Ew0hbJJbec2QQ=
X-Received: by 2002:a17:902:54f:: with SMTP id 73mr17684357plf.246.1561819812161;
        Sat, 29 Jun 2019 07:50:12 -0700 (PDT)
X-Received: by 2002:a17:902:54f:: with SMTP id 73mr17684312plf.246.1561819811455;
        Sat, 29 Jun 2019 07:50:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561819811; cv=none;
        d=google.com; s=arc-20160816;
        b=rkGJ1xmYQVPxoVydLVsdhmIWt46LAwjDB5RpS4RT6a8I9BILxWIOeocIJWKKa5aJZ4
         fGMAOVs+Kr29LH2Cbc658oY7aM6nqWH+MolLVuQ6c0AvLlQX/71zEO+Yt+TkwKVhsSZK
         Rx0AF5RD8ubzZ4opiru42sIDqCQQbD+CX0zfGtDmmnPzO9TZMdr03UKdfN7PNmkNFNu2
         OIe8esCXVsLasx9eeBuE/b4LhL/CnTzYHFf9GAV3+uVwWbJnSji5/dhfw9G3NX5ZKpUP
         oKBGmMw5KBz+yNkjH8uZ/ZRaRJJ9TA4Hi2vMrqLO/B/g3h6sgco9+XmpofC2sutsjLzF
         akSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=gpwY9SEzwskjwipmCEjEPDzJ+JkSWKdevJdN5fw1/iM=;
        b=N9ybA+btP0hMWAYrnnKeFKfG87n+IXPBHEpfuk/38AHuc2esibmZ90H4WwIPbufVXx
         X93V1ovbTxE0TZcsNdBAXI0Fnvw2xq7Uti8Q0AFAmomsrMSMi4I4X/p4BQNrwNckise2
         dO1Ioh9G1TFIs68JEleCJcKZY67JZLXGi9BxVx2Vhkc8wg3z0pHYvvy1ZDSZiYwCFVC0
         uxacYdaimkQR0PZVUPBU1tkCTm70qxqr13CCiRnPXnhEEfQAZb4WQ4vvp13kbIDAnrnc
         YBEuRXIJlKI9B20wKkUQLLp4B2D6+PRTPnKki8F2RoO7QO0liRKvflkm8UzLJaG5IggS
         fNCw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=AlVvTidm;
       spf=pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck7@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 3sor6287695plo.62.2019.06.29.07.50.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 29 Jun 2019 07:50:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=AlVvTidm;
       spf=pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck7@gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=gpwY9SEzwskjwipmCEjEPDzJ+JkSWKdevJdN5fw1/iM=;
        b=AlVvTidmIeM8754EXuPmkm83s6qNg5Jm5gjt3YhUtsu7/PgF7C0PqVa6ptBpiy7P+b
         7w/vUfWCCFqmbb8iWdujQ5RlItRswygS1/W7QpiSFfq/fT2Nu4dRgemGkLF72hCTAl9s
         CRIHmYzfZsico8YFuLWYJ5693A7o/b4yO4xb3CGFk8Csreadz74Dd/N3TbnDzTPI329w
         tmx7Gx26KM0nmNFaM17rZJNe2CjctoMPNGJ1w13qOjvTkEKMGe5RVpeApLtX8/DXjhQN
         S2voeFsnwfTZ/9nocjMAB1DWN9izRoiZR3qOpRdSjzhL8358DohG1/ewXzBcpnKciwy+
         LQqA==
X-Google-Smtp-Source: APXvYqwzAvuZq8uFS3MlBSIKk71/6JUg9AHYM+1A6MpIzGTxNNk8+GY2Jbg28JKN9AieKqNESQt07g==
X-Received: by 2002:a17:902:2bcb:: with SMTP id l69mr18151254plb.155.1561819811065;
        Sat, 29 Jun 2019 07:50:11 -0700 (PDT)
Received: from localhost ([2600:1700:e321:62f0:329c:23ff:fee3:9d7c])
        by smtp.gmail.com with ESMTPSA id r196sm4899405pgr.84.2019.06.29.07.50.09
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Jun 2019 07:50:10 -0700 (PDT)
Date: Sat, 29 Jun 2019 07:50:09 -0700
From: Guenter Roeck <linux@roeck-us.net>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Mark Rutland <mark.rutland@arm.com>, Michal Hocko <mhocko@suse.com>,
	linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Will Deacon <will.deacon@arm.com>,
	Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org,
	Stephen Rothwell <sfr@canb.auug.org.au>, linux-s390@vger.kernel.org,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org,
	Russell King <linux@armlinux.org.uk>,
	Matthew Wilcox <willy@infradead.org>,
	Ingo Molnar <mingo@redhat.com>, James Hogan <jhogan@kernel.org>,
	linux-snps-arc@lists.infradead.org,
	Fenghua Yu <fenghua.yu@intel.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Andy Lutomirski <luto@kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-arm-kernel@lists.infradead.org,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	Tony Luck <tony.luck@intel.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Vineet Gupta <vgupta@synopsys.com>, linux-mips@vger.kernel.org,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linuxppc-dev@lists.ozlabs.org,
	"David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] mm: Generalize and rename notify_page_fault() as
 kprobe_page_fault()
Message-ID: <20190629145009.GA28613@roeck-us.net>
References: <1560420444-25737-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1560420444-25737-1-git-send-email-anshuman.khandual@arm.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Jun 13, 2019 at 03:37:24PM +0530, Anshuman Khandual wrote:
> Architectures which support kprobes have very similar boilerplate around
> calling kprobe_fault_handler(). Use a helper function in kprobes.h to unify
> them, based on the x86 code.
> 
> This changes the behaviour for other architectures when preemption is
> enabled. Previously, they would have disabled preemption while calling the
> kprobe handler. However, preemption would be disabled if this fault was
> due to a kprobe, so we know the fault was not due to a kprobe handler and
> can simply return failure.
> 
> This behaviour was introduced in the commit a980c0ef9f6d ("x86/kprobes:
> Refactor kprobes_fault() like kprobe_exceptions_notify()")
> 

With this patch applied, parisc:allmodconfig images no longer build.

In file included from arch/parisc/mm/fixmap.c:8:
include/linux/kprobes.h: In function 'kprobe_page_fault':
include/linux/kprobes.h:477:9: error:
	implicit declaration of function 'kprobe_fault_handler'; did you mean 'kprobe_page_fault'?

Reverting the patch fixes the problem.

Guenter

