Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD205C5B579
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 05:47:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 757A92133F
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 05:47:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sifive.com header.i=@sifive.com header.b="Lh/PXUfN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 757A92133F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sifive.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E011E6B0003; Fri, 28 Jun 2019 01:47:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D88D28E0003; Fri, 28 Jun 2019 01:47:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C4FB68E0002; Fri, 28 Jun 2019 01:47:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id A3CC86B0003
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 01:47:09 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id m1so5404695iop.1
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 22:47:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=fvuYML5uzQgIUwNz7fCS/6vO91+ePnv6G7iaXOVewbE=;
        b=kUEooMemG7MPHoBTC87hIO5MEy4K6RIjiYfxjqMvQGrFDRDj/zpT+uESl7nw+yTs1h
         irBfBQHNgbPgvcfSXd9kcczNuX3mNfeylTajE3DcYbyT/AuT7uQrOKNSIUoxKcnrfLFy
         FAEmV4DCCOFD6omATO60JJvOIUdghSI6btAx+zkO16NjjvGPLnGMxkzfHHWpA3TD6QBR
         DOudZrTJmpNAWT5DVP33SMR9qq0b44ZhZg3W5fii0lZHS1Vt/M24v31Dpv+eI4QmqnKL
         5lz2sfgsA23ZyXrldxPxoC+sSV7fxkkncqTLsZP45UFsrI8xKvV9Xdp6+MULLaLXnhTX
         TYeQ==
X-Gm-Message-State: APjAAAVWP42THQ7w2586BhkQxm6Nifm2znU6xLoBcMNK52HasIgLDj4R
	8WEpR+CMVvtSpCPlz9b+U/EoSDok4hLHIykNwSQSNra+Dza0O1Xv5w66My6jXLDknY12r6nKeen
	C2i9GqdScc4Zv2h6R7GkhTmjljP4kHBcBZCmmlHp6Bap9bwJbwMchtbLQA/CWSFOYeg==
X-Received: by 2002:a6b:f90f:: with SMTP id j15mr8795738iog.43.1561700829393;
        Thu, 27 Jun 2019 22:47:09 -0700 (PDT)
X-Received: by 2002:a6b:f90f:: with SMTP id j15mr8795707iog.43.1561700828816;
        Thu, 27 Jun 2019 22:47:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561700828; cv=none;
        d=google.com; s=arc-20160816;
        b=IeBpawJBft95SmxA0patZOt9BAR663u96oJhc7BDrBcUWMGc0A1Nnfcxkx2jOhkefF
         9L78ksSH15GF3DCjcVmqI9k+APzcxS7z3De5RjTd7VOIwYKMEKZy3bhmckOlDNX3XrA/
         KW8waw1gb3ACHuH8eBYWMcG7Betmw4O2B+dVGJQBea51K5Rxhun3n6GPAV3BuZxNmgea
         VWUmJWUi06Z/RDlyPYoMTlhFDovUTWubRd+eAfFCK08J+wO7xVQkV8xJaqcT65IKBxYz
         VtJDQ6eqaDo2NeCv4mrrRMKY31cbu1uFtvGY0C/pg/8AWXbsDKmpja6k+196shg2NfGB
         UKYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=fvuYML5uzQgIUwNz7fCS/6vO91+ePnv6G7iaXOVewbE=;
        b=u+TvMuEafzju4wJ65DnCrlhEvCDTmtzbsXCIs7FiHpo2uJfKnQ6WSgGC3lLFNU9mF9
         mqcVX5bcGQPV4PWkqT3XHvBTosk1l/+0WKiPaNVV2n1ZSFFYVHv5GXb0tk0Kf9g707xw
         /DLyVW3hgIA08dsXDOSEgby7eF/K42Lalsss+MLhOP+qkq2ULyXv5KguoEmHIF6fGG+z
         jq/Rzh3wzZZujAcDLrpA8x5caXyI5lHkj8URPNDV6vIIdVjd8Y7OGQFAL7jwhIx2GqOF
         H4m3OItiSc2//9vKWWYJbdhIt2ssb+le9AMa9SIfg1n8xGKADaKnc/LxT1pPwXpq4FSl
         WymA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sifive.com header.s=google header.b="Lh/PXUfN";
       spf=pass (google.com: domain of paul.walmsley@sifive.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=paul.walmsley@sifive.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e1sor1004004iom.44.2019.06.27.22.47.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Jun 2019 22:47:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of paul.walmsley@sifive.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sifive.com header.s=google header.b="Lh/PXUfN";
       spf=pass (google.com: domain of paul.walmsley@sifive.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=paul.walmsley@sifive.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=sifive.com; s=google;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=fvuYML5uzQgIUwNz7fCS/6vO91+ePnv6G7iaXOVewbE=;
        b=Lh/PXUfNzB9+Yc3PqmnULJsPt2VQgNpCN5/zylaX+Hmw9OmqW6glMZiI3omQZX96Fc
         nCBpzg8MUVLXTC+3j7tC4tgeXYCZRZWJE/eUPLQwk46X7HbLafSb3pVCBoJyA/mSANfq
         /tb0Vv6rv6sERdmMPDB8fMeo7dUe+noq9BDGDjJfW4BEHMIy+d8lgrO7SgWFQUPtARLC
         Z+GWSFmkad/CsxXWM1JNvClu1KF/qEUBefedqYubAQ9icruKIkzRehlNlZNMbX5Njaif
         PVdGoXQaCWlxSwnkNwT0Vznkmj93gOQUcTNGkDEvbiTpDOjoo3rZ2mS+1SEUJkW/JNZS
         p3gg==
X-Google-Smtp-Source: APXvYqyMCUI3j/PylnvKJ/FaopK/bHzh4vEpw/kHIraAfhhNgKnEs1KXhjU6FRT2a0v5mz1ckRca9w==
X-Received: by 2002:a5d:81c6:: with SMTP id t6mr8927688iol.86.1561700828423;
        Thu, 27 Jun 2019 22:47:08 -0700 (PDT)
Received: from localhost (c-73-95-159-87.hsd1.co.comcast.net. [73.95.159.87])
        by smtp.gmail.com with ESMTPSA id r5sm1049107iom.42.2019.06.27.22.47.07
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 27 Jun 2019 22:47:07 -0700 (PDT)
Date: Thu, 27 Jun 2019 22:47:06 -0700 (PDT)
From: Paul Walmsley <paul.walmsley@sifive.com>
X-X-Sender: paulw@viisi.sifive.com
To: Atish Patra <atish.patra@wdc.com>
cc: linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, 
    Albert Ou <aou@eecs.berkeley.edu>, Thomas Gleixner <tglx@linutronix.de>, 
    Kees Cook <keescook@chromium.org>, Changbin Du <changbin.du@intel.com>, 
    Anup Patel <anup@brainfault.org>, Palmer Dabbelt <palmer@sifive.com>, 
    "maintainer:X86 ARCHITECTURE 32-BIT AND 64-BIT" <x86@kernel.org>, 
    linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, 
    Borislav Petkov <bp@alien8.de>, Vlastimil Babka <vbabka@suse.cz>, 
    Gary Guo <gary@garyguo.net>, "H. Peter Anvin" <hpa@zytor.com>, 
    Andrew Morton <akpm@linux-foundation.org>, linux-riscv@lists.infradead.org, 
    Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH v3 3/3] RISC-V: Update tlb flush counters
In-Reply-To: <20190429212750.26165-4-atish.patra@wdc.com>
Message-ID: <alpine.DEB.2.21.9999.1906272243530.3867@viisi.sifive.com>
References: <20190429212750.26165-1-atish.patra@wdc.com> <20190429212750.26165-4-atish.patra@wdc.com>
User-Agent: Alpine 2.21.9999 (DEB 301 2018-08-15)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 29 Apr 2019, Atish Patra wrote:

> The TLB flush counters under vmstat seems to be very helpful while
> debugging TLB flush performance in RISC-V.
> 
> Update the counters in every TLB flush methods respectively.
> 
> Signed-off-by: Atish Patra <atish.patra@wdc.com>

This one doesn't apply any longer.  Care to update and repost?


- Paul

