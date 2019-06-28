Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55CAFC5B579
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 21:49:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F192D2133F
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 21:49:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="Jbtf3SMd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F192D2133F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 561336B0003; Fri, 28 Jun 2019 17:49:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 510BD8E0003; Fri, 28 Jun 2019 17:49:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D8818E0002; Fri, 28 Jun 2019 17:49:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 07A3C6B0003
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 17:49:37 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id e16so3812869pga.4
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 14:49:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=qdZrjeoDNSQsqkyJp6BkgnYTQ7c4BAmADlCHRSbPn3o=;
        b=O/qbTTMDLWelJ+jHJw0U+15ZYQblpUmRVHmbpB8i+2VU7oy9UEnvlfGdMNlg9gG2ut
         pCQ9RN3+QNAf7KKMX58FlYQmACRHdgqBEVaPzO0b71bWO4imai+JDL8zaHvuB8zO1Sje
         MdN2gpGqENH4ZmL01lF/nViTfMQOc6vYan1cOFouuOENL8aGysZDzB6aF9peO+dSCFum
         OYipx7Iat/B49v558FK23lthh1JvmDQYGaHM+b9QhKotLZvrmWsDkUwb01jXxjiJ8RMF
         DsklrJYcU8H+GB7zW45uYVwChE2ur9uRspLKwsk37cYbq4HlP9ebQiPHT26w9vckciq6
         AU/g==
X-Gm-Message-State: APjAAAWuUVmY4f4WeCcUnPvhQ3/LydSs7D6VrkrXwD7vsurzdvyt3dDp
	IiSRaWQfDGZpQ6MKdOsIOJ+03P0+Xly8Jep2U/trtgdpzZCmUDARGS7vAKyMtuHMPFGRhWgp/wY
	+uDL/nsirBms9InnZEMDiFvenUp5U6kN/44xdOQ1sKIRjCuxcaLNH+qI81+XPxuXMIA==
X-Received: by 2002:a17:902:e282:: with SMTP id cf2mr14232838plb.301.1561758576414;
        Fri, 28 Jun 2019 14:49:36 -0700 (PDT)
X-Received: by 2002:a17:902:e282:: with SMTP id cf2mr14232764plb.301.1561758575400;
        Fri, 28 Jun 2019 14:49:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561758575; cv=none;
        d=google.com; s=arc-20160816;
        b=H/tx4kpVIfrdtdhRQL0pbqJyVBH3RxuR9JCIIsExyy7yLYv7px2tXVORlP1QE52PWX
         wDi86CBf+plXQoXr+3E3dEmpk3HSyPeuH6/Zr0M3LPr5jaLgBykzRu1d8NakI6PSVRrD
         0T3DTiayjpf8h/Io8oUqbZOKZrnrNi1AONgYrlu1CHNkdgG6MfCKe8RXIBW7YyNCYoYP
         /1yIITDS/Sg49iBm4QERvE5P3YS9YPVgnJ4EBUjwXU8cLNErqLwOrDeG+usn7JQWt/rE
         4JI/KeZNFk+8H2HU5YyZ6zO055sGhznqTLMxBAZURAvXNs67933PRNZ08sTdTz8+PFGV
         uK6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=qdZrjeoDNSQsqkyJp6BkgnYTQ7c4BAmADlCHRSbPn3o=;
        b=dI9tO6YPxhG8P0uSJtIhEoqDn36fDnqjB62sLCtGbkI6POswHlMUpXr9x1FVDRKm7v
         YWEpa3za7MjpjfS9/ahk1g5gJeqYKP9s3FfRV6rCYhX4adIdrpw781kesRyhCbW0RlyQ
         VLZwJ7ip2v6DCpR4508ddedgtxxTQnNIYL2vSN9NqoRcDp7x+6KK/RaM9+/02M+9y4FQ
         QuxzxAtLuk9ewKzdgWEZoG8B/aJCof3VBQCrmcsYg+C4ADWbqDQvh8oPS/wERcYL98RM
         LLsNgmhjQ8M4enWt4HG4MBZAPOYIKQ2aS1BBJ1fsZlxgxhemEJoKGahtlDf6ndyHwkO3
         lhcw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=Jbtf3SMd;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q39sor4006622pjb.7.2019.06.28.14.49.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Jun 2019 14:49:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=Jbtf3SMd;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20150623.gappssmtp.com; s=20150623;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=qdZrjeoDNSQsqkyJp6BkgnYTQ7c4BAmADlCHRSbPn3o=;
        b=Jbtf3SMdEjxfXc+d5F8QO1cas1KV2BV1hoJs1qRKJoPwT1GlFe/aVrIguqs8TeA5WL
         XFjSvXz5JL1mUxkp/yO9dDhKS2J+SdrJ0lxayg7atN068yg4GTjfLZEsHH6mtervlgTu
         dfdYK9wPBB2jWUqrgrGm8vXuRpOQ+u1Yc96OVeVo3XhBxIwOapG0VhV1rN1dM/PdL3/X
         bn1SdNRys1EYpFylxcnIXF3WzYpVDimXTzieLOZngZ+kqn3ePeZflspOP3g1t7V/TKhT
         bcyf3c/YjSwa+06KGllNZms+B+F87dwMlPa8OT/AmVRI2aAmsjsl+ygOc4phTxqIL3Hv
         VbiA==
X-Google-Smtp-Source: APXvYqz/YPDWsT7hhTRb2Bm2QEJ3v+KaME0sQBT1mNpk1MmCdOSSpZuy1ArM2RVKH8r8EsILBD1Myg==
X-Received: by 2002:a17:90a:c504:: with SMTP id k4mr15615755pjt.104.1561758574932;
        Fri, 28 Jun 2019 14:49:34 -0700 (PDT)
Received: from ?IPv6:2600:1010:b00c:70fb:70e6:7ca0:457a:d080? ([2600:1010:b00c:70fb:70e6:7ca0:457a:d080])
        by smtp.gmail.com with ESMTPSA id d123sm3359464pfc.144.2019.06.28.14.49.33
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jun 2019 14:49:33 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [RFC PATCH 1/3] mm: Introduce VM_IBT for CET legacy code bitmap
From: Andy Lutomirski <luto@amacapital.net>
X-Mailer: iPhone Mail (16F203)
In-Reply-To: <20190628194158.2431-1-yu-cheng.yu@intel.com>
Date: Fri, 28 Jun 2019 14:49:32 -0700
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org,
 linux-arch@vger.kernel.org, linux-api@vger.kernel.org,
 Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>,
 Borislav Petkov <bp@alien8.de>, Cyrill Gorcunov <gorcunov@gmail.com>,
 Dave Hansen <dave.hansen@linux.intel.com>,
 Eugene Syromiatnikov <esyr@redhat.com>,
 Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>,
 Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>,
 Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>,
 Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>,
 Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>,
 Randy Dunlap <rdunlap@infradead.org>,
 "Ravi V. Shankar" <ravi.v.shankar@intel.com>,
 Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
 Dave Martin <Dave.Martin@arm.com>
Content-Transfer-Encoding: quoted-printable
Message-Id: <CBB8C19E-7F65-4D43-9783-6383478700A1@amacapital.net>
References: <20190628194158.2431-1-yu-cheng.yu@intel.com>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jun 28, 2019, at 12:41 PM, Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>=20
> The previous discussion of the IBT legacy code bitmap is here:
>=20
>    https://lkml.org/lkml/2019/6/6/1032
>=20
> When CET Indirect Branch Tracking (IBT) is enabled, the processor expects
> every branch target is an ENDBR instruction, or the target's address is
> marked as legacy in the legacy code bitmap.  The bitmap covers the whole
> user-mode address space (TASK_SIZE_MAX for 64-bit, TASK_SIZE for IA32),
> and each bit represents one page of linear address range.
>=20
> This patch introduces VM_IBT for the bitmap.

There=E2=80=99s no need to allocate a bit for this and to clutter up the fau=
lt code with special cases. Use _install_special_mapping(), please.  If you n=
eed to make it more flexible to cover your use case, please do so.

