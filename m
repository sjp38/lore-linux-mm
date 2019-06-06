Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97747C28EB3
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:28:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E9CB214DA
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:28:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="t2yJVjGS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E9CB214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E0CB36B02E4; Thu,  6 Jun 2019 16:28:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DBCC26B02E6; Thu,  6 Jun 2019 16:28:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CAC426B02E7; Thu,  6 Jun 2019 16:28:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 92F4F6B02E4
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:28:43 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id f9so2632007pfn.6
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:28:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=PJA60M0ShvGgAGdvUFVxM+gy8jPoTTfj2EhMnX7Rw2Q=;
        b=pNAAAloxHLEz7gwjpY3tp3un/R9RQXmraks9nBukHPkVY4ow4lg5AuhRR4noJgLMry
         Wrgltf3bxXte+4oIwTAHBur4y4K5NtWrbAyUiiKXOhKi+86YPHka4B1GVAgTec0PytA9
         XZqvFXCmuLqbbYFxjJ5Jn8CI/DpghkJO4lpAKCieOgDXDZJZ5pDajZ1gH7YZt4DJm/+1
         160SEk7nWKsLVKXIdXHdYIQ7RflWmAQPDSJLiwNMSfqg/1nToAs2tyHi3GG2XRiS8n12
         LHk5MHd9HsFUOfguKOjz3PerMszsyPGAZHx6EGVj/G0PdXavSXr4a3b4tEx1oftY9gtR
         tmWw==
X-Gm-Message-State: APjAAAXMp8Hi9I+WfA1Duc6x4PMmN6MLw/ZRfk053LFcOUBPpPt6itTC
	lFum/Wu2yO/VEuo0wj/KsIAogy1pos9OfITAv1pDawueXxaDaAJo5C9YhB+hrsVcoKTWippcdpA
	PF05rBlNZ1tOBtngQXuVysSiHM2hA8Wke4uYYGsc1BeqVmr7Dh65JDrA4wwe94CUrpg==
X-Received: by 2002:a17:90a:216c:: with SMTP id a99mr1630645pje.3.1559852923293;
        Thu, 06 Jun 2019 13:28:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwOihV7cgd1ponoD+v4Bhxpwu7laFT6UGdqq1vjIzUwpBNCexStTD/vGHYunb8MXDPwB6T/
X-Received: by 2002:a17:90a:216c:: with SMTP id a99mr1630598pje.3.1559852922680;
        Thu, 06 Jun 2019 13:28:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852922; cv=none;
        d=google.com; s=arc-20160816;
        b=gtaGsM0aQAEHEZ3MgXRoB5bDQlS2WDGntzcirbD0Jw3iZx7pZe/s5NnSVIZDQ4Eg2L
         cMRMdbBiidhPhO4Mrf06qtsgJHyjPgipRevAnlJrrpajlkWI7Oy75uKtoVPfdKkWF4gv
         BDnM0++T8AbteT7juNOOez5XTP0CRSg+INk0dOghcVA9unCQSS70zf6Pr+I57li27aFB
         aqDJ0ky/DCZYpiugB6tBkrc2+bDtqXfUYPmKevwVM6/okD8WJMf+zgV/bV4gzLZ8FR//
         56BNaaGd22gYlY7SnCYK3vUpOmJDLxc3vP5qWPN0Q0lBYizFMFdeK8NB7nnleiYsD6UA
         mrqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=PJA60M0ShvGgAGdvUFVxM+gy8jPoTTfj2EhMnX7Rw2Q=;
        b=WSEzEzUXQlHBUvg1pWjv6+1olC1m7W8Xo16di7Ro4m4LWBFPlNdRqAX4wWCyCeCwFk
         O4/x/mim5YSc9LpiOfpsAOqlsr2G8IFfdd5nQTFZcBJPkDHgG8ZcBaUQJomIdLJcEb1z
         BRCXUOSHy6X4UWRU1HMgcLDbhBnk/ohdI/MCZB4hUCReLNE2rUsyfa0XRp2awLXe2akM
         Shfvhv6BZnyiPbfrQjR3yGufNaW/voNVWAKWenFkVl7Nh02CMndf8Ndx8sTVkTHeyTDC
         jeOVVZwolmc/bAZwDgyLI2HWq+PZ/bC3IgZGEDgEAQjwwZxgBITsZ94BkkLnTh9P7rdd
         ebLA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=t2yJVjGS;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id o20si25872pjp.48.2019.06.06.13.28.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 13:28:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=t2yJVjGS;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wr1-f51.google.com (mail-wr1-f51.google.com [209.85.221.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 255F720B7C
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 20:28:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559852922;
	bh=7dtJJy+tpf1euG0sliaeXpcZWtPy4t0cTCPj40HG3Gc=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=t2yJVjGScNVAceTq64NgeNXeja0FCFjw2J41UevfqpsJ6YUmmYc3K+axFdZgrqoNG
	 C2AFooBLHsfBQPFkZFLDhZOpkV8pWCqBrBk+Gm5E0fJSf8nVZ02y7HDywrc4PNgA0e
	 TOjlgx5CqdRDt/Fp31naUp8cvXov8xmEnxZSVXlM=
Received: by mail-wr1-f51.google.com with SMTP id x4so3747717wrt.6
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:28:42 -0700 (PDT)
X-Received: by 2002:adf:f2c8:: with SMTP id d8mr4520549wrp.221.1559852920790;
 Thu, 06 Jun 2019 13:28:40 -0700 (PDT)
MIME-Version: 1.0
References: <20190606200926.4029-1-yu-cheng.yu@intel.com> <20190606200926.4029-12-yu-cheng.yu@intel.com>
In-Reply-To: <20190606200926.4029-12-yu-cheng.yu@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 6 Jun 2019 13:28:29 -0700
X-Gmail-Original-Message-ID: <CALCETrXWehe=s4i+VkjxJBLh2AVWRioybpY0nbEWXZjvY_rFeQ@mail.gmail.com>
Message-ID: <CALCETrXWehe=s4i+VkjxJBLh2AVWRioybpY0nbEWXZjvY_rFeQ@mail.gmail.com>
Subject: Re: [PATCH v7 11/14] x86/vsyscall/64: Add ENDBR64 to vsyscall entry points
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, 
	Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, 
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, 
	Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Borislav Petkov <bp@alien8.de>, 
	Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, 
	Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, 
	Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, 
	Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, 
	Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, 
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, Dave Martin <Dave.Martin@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 6, 2019 at 1:17 PM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>
> From: "H.J. Lu" <hjl.tools@gmail.com>
>
> Add ENDBR64 to vsyscall entry points.

I'm still okay with this patch, but this is rather silly.  If anyone
actually executes this code, they're doing it wrong.

--Andy

