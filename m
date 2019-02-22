Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C552EC10F00
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 16:14:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 81E2A20700
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 16:14:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="a9NwRp86"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81E2A20700
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=alien8.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 20ED08E011A; Fri, 22 Feb 2019 11:14:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B6298E0109; Fri, 22 Feb 2019 11:14:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08AE08E011A; Fri, 22 Feb 2019 11:14:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id A165C8E0109
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 11:14:28 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id p3so1187690wrs.7
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 08:14:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=TtW/o2236hee295y0l38KlKQhr9G4t9UGeyqpVmzjfk=;
        b=Ql+FOA6lTk6B0BZGcbZKeYmTMqPlOUO4FW6bAiInn8xoGNWSXov/jp9RKQI00mjHvB
         v2PQMjHIHb0wwEa+zsFh6GSDhlOF9S6Vw8ZBrll9q2TIXUFo4BX3Gyaikf4yX0OdlVdK
         YxRUqS6i1r8p17HztbJ3RUTqMGooiUTfbjxnOd4D4rRo/SjbEwQVRZVDLcazBWcoGGEJ
         QGIzAXJmIKNOF8UR2LSTtSK9sAwg0MH8Zwijn5XxWdPFYPkniljyHchbcHTFXLI8VJEi
         BwdXneDv2ngSGCLXPCYWEnan/wvsnCWCRARqUD1ipdgMBecnXQGwN7kcLsvpTNygHgHj
         GE6g==
X-Gm-Message-State: AHQUAuYpSQ/v0tpzR3oTVELPCpL0eTUNtfX0HuKL26gKjjD9xvd/YVc8
	6yaRTLSu2Qt/aTdRQFct372dvnx+xEfLg8GfyfvJ9/gYwmpW51mIX/dm5oqAFGyJULducpO+fsq
	hyb17Qc7wO4b68KxcINviTjIrFLvVn4qpYH33pMifiUzLcYqK9D+ApBY6KgszLSfygA==
X-Received: by 2002:a1c:c013:: with SMTP id q19mr2758113wmf.93.1550852068123;
        Fri, 22 Feb 2019 08:14:28 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZU2fLvs+U6T84Amw8chvCsxCv9BtifpQfBLa1vlsYaoLAmqTgnff+nTyNBMhNgP2yqdvH4
X-Received: by 2002:a1c:c013:: with SMTP id q19mr2758071wmf.93.1550852067322;
        Fri, 22 Feb 2019 08:14:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550852067; cv=none;
        d=google.com; s=arc-20160816;
        b=g7OZ8g4lsl7R48uRpAUNF9WrqDqd35a+QbMrnZAts6aM2J+yIpl+m0JBaifAyAMbh6
         SSUDbomul7LtVu+p8gQKDnUyuzDW1ajIefkm+0JYZ/3Ni3lBHqTCmKQbDtzhV/inLq6E
         8vwp+9fnJ/flD+l7fHCqokH/xJiyfxqNZAtsukczvMhg6KlSsGtHi4+rP8SZJe3hWdKi
         vN+lQxN9raz1wgjUyzHEjLmRFDIdqpfkhmWMkSv4DeCoHjnyXF94a3Q/iH+uqcHxVfYJ
         AtEnw/yNL10mYpdNjKU0yn8qBKFvq9VAI224zG/R3HW1Dys89IwaEnWWBtNjnPLuVwdM
         e9ow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=TtW/o2236hee295y0l38KlKQhr9G4t9UGeyqpVmzjfk=;
        b=pMC0ZTyGEs6U7K7r7iS+TYltV6lKEp85ZuU6NdZUW13t7LPDUvIzgGng/5TZEuIrT+
         kFxk49RT/rPVW8aUfFhZ2maw/KY9Ny/xGH/EZe7CdZ1PrzvNqJt6MAiPmZzEaxfLwX7d
         IOlrM17yy9PhP3YirX9JLd0gPK9WEzB7oiDSZxs9M+XjxgwLjjSFPJbnZF3iiAwTjGak
         uD065XCJfOnh2ebArrLjlEiP3hzgp8IVewuXCo3fF+/Fvn8exLkeALZcjdqujouKOLBQ
         6XceoFUeFeSMbZnl11yuY50qICiLk72fTsN5rJ7/jLGZuvSMgIpFK0NzfUzWrc3gbG7/
         RPFA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=a9NwRp86;
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id b22si1147981wmb.128.2019.02.22.08.14.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 08:14:27 -0800 (PST)
Received-SPF: pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) client-ip=5.9.137.197;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=a9NwRp86;
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from zn.tnic (p200300EC2BCB3900F0C56855832FAB14.dip0.t-ipconnect.de [IPv6:2003:ec:2bcb:3900:f0c5:6855:832f:ab14])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id 69EC41EC0324;
	Fri, 22 Feb 2019 17:14:26 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
	t=1550852066;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:in-reply-to:in-reply-to:  references:references;
	bh=TtW/o2236hee295y0l38KlKQhr9G4t9UGeyqpVmzjfk=;
	b=a9NwRp86cR2AQFYae8KVR4Yy4+lZE3yv+GWVs72qb7oHaM6m4WF14MUq1S8WN/i+S/W1+t
	kFGXOo6Nsaa2ObF3jQSUmyu73h1eCiA/LTtjnDrZFdJwViQEin2xP1OQy+L88nRo/VTmiN
	N/L0FcMuJpPh+Cqm16wWUjYndvyN9bQ=
Date: Fri, 22 Feb 2019 17:14:19 +0100
From: Borislav Petkov <bp@alien8.de>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>,
	linux-kernel@vger.kernel.org, x86@kernel.org, hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>, linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org, akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
	will.deacon@arm.com, ard.biesheuvel@linaro.org,
	kristen@linux.intel.com, deneen.t.dock@intel.com
Subject: Re: [PATCH v3 00/20] Merge text_poke fixes and executable lockdowns
Message-ID: <20190222161419.GB30766@zn.tnic>
References: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2019 at 03:44:31PM -0800, Rick Edgecombe wrote:
> Changes v2 to v3:
>  - Fix commit messages and comments [Boris]
>  - Rename VM_HAS_SPECIAL_PERMS [Boris]
>  - Remove unnecessary local variables [Boris]
>  - Rename set_alias_*() functions [Boris, Andy]
>  - Save/restore DR registers when using temporary mm
>  - Move line deletion from patch 10 to patch 17

In your previous submission there was a patch called

Subject: [PATCH v2 01/20] Fix "x86/alternatives: Lockdep-enforce text_mutex in text_poke*()"

What happened to it?

It did introduce a function text_poke_kgdb(), a.o., and I see this
function in the diff contexts in some of the patches in this submission
so it looks to me like you missed that first patch when submitting v3?

Or am *I* missing something?

Thx.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

