Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4FB6EC742C7
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 15:23:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E625208E4
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 15:23:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E625208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9DA6E8E015B; Fri, 12 Jul 2019 11:23:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 98A868E00DB; Fri, 12 Jul 2019 11:23:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 82B6A8E015B; Fri, 12 Jul 2019 11:23:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2F8BF8E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 11:23:54 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id z24so2742655wmi.9
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 08:23:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=aYZ5mzJK5gc4DUj302MHZQktRUNxigxb7h1wcySusn4=;
        b=mGPUbRoFs3Ltx50DomsN4JGeD/toUwK2laH2ESOSai6x3GQIMxRv/1vfzLuan8i/0X
         Uzk0ome2pcQbSOaoMYt+zYrdWGkQ/k6iMlg5jUHGejfJYYhgkIqhsn9oSyyPMivPvc92
         UySbDXSof3Q8Lmsq/vd+Mldf+O2nHYl0R6O0bS7rJ5rK2UB7yZ2Spod+ehDPSVC+r3wS
         KYeoYBDdqSIcxbvR1BWMAQGfjNkaL8fmuiVBwQ7mjcxc/fx+e/+5KWTXGkLTj9yy20ym
         V1VB15rrx8Hoom60qxU9q8QyO1XWd42Xq9/27GlxHBtfsiDAumY/AJIv60YKwOmaMoLB
         RTEA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAVt0YYwLaEom9rJ2YXdDrCeCnnn/JkU9MVOXPBLt+XMY4vleoqN
	X9mw88dSi2bUDHyLSEgisuxAMfIZ3UQRolGkGERwau60k6Oc5b00LXFOIrA8BJkSbPNUMWcZmnM
	PA6xQBfnaoCAorawro7188tEoiioC9rdrXGVrOiTDWy16XjeD3qOn1HkzNZWiBbyEpg==
X-Received: by 2002:a5d:6205:: with SMTP id y5mr11761927wru.314.1562945033720;
        Fri, 12 Jul 2019 08:23:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwyFPtl9vD0e4q6wCymqrRnpd3j3gtmp7jA1o3D7PeK/0qXRWMTvOgTbjARz9JKSYpth5fK
X-Received: by 2002:a5d:6205:: with SMTP id y5mr11761884wru.314.1562945033071;
        Fri, 12 Jul 2019 08:23:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562945033; cv=none;
        d=google.com; s=arc-20160816;
        b=q8txtosdpaqsdEKPoYehi3JT8VbCi8cg1h44ZTQl44Y0Fvsp/MS17yK9fovoicQEFq
         v0qnKYtXgck9yv1NLm4sbX2S2L7So34cbS5OZurA0vmCOcsLOlKbIL2mpWoYG2lnvGQa
         1h9EVJI0lx2SU3+5c2HS0xtpL9/VMH+TlJ6d6zvz88+Fa1tkVV/81mAWePbSAez3X/Y7
         oPsyO5ZGusJWtHJX3X3ltnohYcgMumZvS9au6BF+4pPugofEKkmFx7lXp4lgEmdsnbjL
         1Z8leA7mwdFjMnH2VNeMdKw0A9fqXLmsVUky+e2ULHUlsELkIZ808MEcaLcMeu5ZT2Xe
         MQBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=aYZ5mzJK5gc4DUj302MHZQktRUNxigxb7h1wcySusn4=;
        b=z65qWU3MxzqgZwadto7sJ41FfBW6Ngv8OY/zgKWyhdvqPBHWHGimSJX3sE0e1xapjr
         Ld0m6ZSrt3xewxSMfHZw0Vcypv8Po+2R4OHTBSjaNyGxRBD5U+LNeVZP96jQfMMyNhDT
         30jcO1smSv3hmykeosemzegnCrJRQNRV9JR8V9q5zK39m9VZbOdVGwGwhDKKJtLKIjQ7
         TpFELufbPwH69SzihfRHW3AnVUKGpp9zumXuygri6VrH25kPCk2enN9OHjbQ7Zc5umPC
         b1GsxqYUKwJM2WUy8fBjvYb6ceut5leyO7zMvqusOAwrvoiB13/JV6618YLrUWEjCBG/
         QC3A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a0a:51c0:0:12e:550::1])
        by mx.google.com with ESMTPS id 90si9510560wrg.260.2019.07.12.08.23.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 12 Jul 2019 08:23:53 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) client-ip=2a0a:51c0:0:12e:550::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from [5.158.153.52] (helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hlxOi-0003SX-Ud; Fri, 12 Jul 2019 17:23:45 +0200
Date: Fri, 12 Jul 2019 17:23:44 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Alexandre Chartre <alexandre.chartre@oracle.com>
cc: Dave Hansen <dave.hansen@intel.com>, pbonzini@redhat.com, 
    rkrcmar@redhat.com, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, 
    dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org, 
    kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org, konrad.wilk@oracle.com, 
    jan.setjeeilers@oracle.com, liran.alon@oracle.com, jwadams@google.com, 
    graf@amazon.de, rppt@linux.vnet.ibm.com
Subject: Re: [RFC v2 00/27] Kernel Address Space Isolation
In-Reply-To: <bfd62213-c7c0-4a90-b377-0de7d9557c4c@oracle.com>
Message-ID: <alpine.DEB.2.21.1907121719290.1788@nanos.tec.linutronix.de>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com> <5cab2a0e-1034-8748-fcbe-a17cf4fa2cd4@intel.com> <2791712a-9f7b-18bc-e686-653181461428@oracle.com> <dbbf6b05-14b6-d184-76f2-8d4da80cec75@intel.com>
 <bfd62213-c7c0-4a90-b377-0de7d9557c4c@oracle.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Jul 2019, Alexandre Chartre wrote:
> On 7/12/19 3:51 PM, Dave Hansen wrote:
> > BTW, the PTI CR3 writes are not *strictly* about the interrupt coming
> > from user vs. kernel.  It's tricky because there's a window both in the
> > entry and exit code where you are in the kernel but have a userspace CR3
> > value.  You end up needing a CR3 write when you have a userspace CR3
> > value when the interrupt occurred, not only when you interrupt userspace
> > itself.
> > 
> 
> Right. ASI is simpler because it comes from the kernel and return to the
> kernel. There's just a small window (on entry) where we have the ASI CR3
> but we quickly switch to the full kernel CR3.

That's wrong in several aspects.

   1) You are looking at it purely from the VMM perspective, which is bogus
      as you already said, that this can/should be used to be extended to
      other scenarios (including kvm ioctl or such).

      So no, it's not just coming from kernel space and returning to it.

      If that'd be true then the entry code could just stay as is because
      you can handle _ALL_ of that very trivial in the atomic VMM
      enter/exit code.

   2) It does not matter how small that window is. If there is a window
      then this needs to be covered, no matter what.

Thanks,

	tglx

