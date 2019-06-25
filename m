Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 129D5C48BD6
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 22:47:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86B1F2086D
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 22:47:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86B1F2086D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 02F6C8E0003; Tue, 25 Jun 2019 18:47:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F2CBB8E0002; Tue, 25 Jun 2019 18:47:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D9C548E0003; Tue, 25 Jun 2019 18:47:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 867898E0002
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 18:47:06 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id w11so96107wrl.7
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 15:47:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=+ALHCXLfRK0tTpeLWRRoiJ21Y6NIzxsxOoWgW5QWw8c=;
        b=LaXZrBx5V7dIp9WiB+FJGTxPa/SvJZS1HNFUcLzlCt8U9D0mY3HYF/OvQLAj8wKABS
         zb1spTuBbbvhXt2BVg+prWjwSY1iMX00+4bwGvDkfzG9FhX1kgqTdxFA0f56GX0QoHdG
         0yjVGSSmISN36SstUa/9GR1mIF628Qo8yIQR2VUncM408CuQ4xvS06wikOR4yLQmazFW
         VO2yvymWUZJB4SsKo/PsKNbufSv9QL0Hbx4LvpHUbZ1CyFqrw2XN0x5mf8sT7qKi3vQY
         1NS1hIZTBykNEr2Idk0mDvLzrQfZmZRwT7t1pGkXxqZWIR/AkylQ+ENM2xpUbm1T7As2
         lHhw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAWwJiWvBDMrw7fXhITw1o2am1+IlwSY1AdmHLE5O4n+ypVhlyWn
	JchqLMARnRFKec/59KnE2MmvmDTKHsHv2CwbbvRWuLxg7cerG/V5B197AIkcp0a8oeBcadu/Uve
	MH8dmXyTH5qZzJTSRjA8B0Bpo/VeA+fN5zWROm1DYLWsImLkJUAGv+950WAcjKn784g==
X-Received: by 2002:a1c:7ec7:: with SMTP id z190mr131233wmc.17.1561502826066;
        Tue, 25 Jun 2019 15:47:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwyFFYz8M2Of89u/sVF8xkeTenRnxhX14p36LDNlZkkCBz9xEA/6Vw+mdy4rpquTD9S+ayG
X-Received: by 2002:a1c:7ec7:: with SMTP id z190mr131214wmc.17.1561502825381;
        Tue, 25 Jun 2019 15:47:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561502825; cv=none;
        d=google.com; s=arc-20160816;
        b=sIufo0T6n20cSomrBPKUGj5OxL9jOk1Ae2xkbpiZhkE1BipUgFe0tSfKsdQnWJ6sTQ
         LgMQiE76TbfPwd0/+dSd1u9LwEQCYQuYh+1fSrP5R+gbSjM2JhkbXCs8JB7z4buC0atb
         D0Eb+t2/FYt+ChkymFqaWzQpNVbhzpBALXhyP/MCjxpaQy8DgyLE0sz4BsfSd5Nz4Vqi
         lrFFe1sJzinxSe7F5PUz5feou6h5qBDk7Bs9+DZTBwTzAeN3RNCvakMKrYcI006nmGTp
         upaParZO4cZMIYJjxyqGJ89lcSz0iwGqDiZFODVNjTkily6P2Mf9W5vTk6Zi7uJJD2SX
         wvXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=+ALHCXLfRK0tTpeLWRRoiJ21Y6NIzxsxOoWgW5QWw8c=;
        b=TEBqSaOJR6mLjM/S9+nKo2jg6r8u8VEybLDrcWetC7t0zeBqFt7KWKVAWJs8FZykz0
         r9wIhtwxcWXc4PprnnsYPn7knlD82LF/a36d2s8/6OafKFcvqvPEmvBqm+/lykAEeX2K
         5K1aAgli0BQeoVmo7cOB4qpNG6QMv6jbrAX9AzkpHEkGMk23iGwQSf+OR7Z2zmXVIjwk
         pCQkZ5Ob3n/qtV7oZxVnmXg7X6uO+rM3qTpNnXFihbc6ur1ggZlbvPphe5wXbUfWGzzb
         pw/y+Ips6DeGG4pHDQd3Rvy/L7aESXjpm9QgO9ueyntAbzlR0PjGTSAkbB91PKtUSWEi
         V1WQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a0a:51c0:0:12e:550::1])
        by mx.google.com with ESMTPS id l16si1339055wrq.338.2019.06.25.15.47.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 25 Jun 2019 15:47:05 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) client-ip=2a0a:51c0:0:12e:550::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from p5b06daab.dip0.t-ipconnect.de ([91.6.218.171] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hfuC6-0002Ou-9G; Wed, 26 Jun 2019 00:45:42 +0200
Date: Wed, 26 Jun 2019 00:45:41 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Hoan Tran OS <hoan@os.amperecomputing.com>
cc: Catalin Marinas <catalin.marinas@arm.com>, 
    Will Deacon <will.deacon@arm.com>, 
    Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
    Vlastimil Babka <vbabka@suse.cz>, Oscar Salvador <osalvador@suse.de>, 
    Pavel Tatashin <pavel.tatashin@microsoft.com>, 
    Mike Rapoport <rppt@linux.ibm.com>, 
    Alexander Duyck <alexander.h.duyck@linux.intel.com>, 
    Benjamin Herrenschmidt <benh@kernel.crashing.org>, 
    Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, 
    Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, 
    "H . Peter Anvin" <hpa@zytor.com>, 
    "David S . Miller" <davem@davemloft.net>, 
    Heiko Carstens <heiko.carstens@de.ibm.com>, 
    Vasily Gorbik <gor@linux.ibm.com>, 
    Christian Borntraeger <borntraeger@de.ibm.com>, 
    "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, 
    "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, 
    "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, 
    "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, 
    "x86@kernel.org" <x86@kernel.org>, 
    "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, 
    "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, 
    Open Source Submission <patches@amperecomputing.com>
Subject: Re: [PATCH 3/5] x86: Kconfig: Remove CONFIG_NODES_SPAN_OTHER_NODES
In-Reply-To: <1561501810-25163-4-git-send-email-Hoan@os.amperecomputing.com>
Message-ID: <alpine.DEB.2.21.1906260032250.32342@nanos.tec.linutronix.de>
References: <1561501810-25163-1-git-send-email-Hoan@os.amperecomputing.com> <1561501810-25163-4-git-send-email-Hoan@os.amperecomputing.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Linutronix-Spam-Score: -1.0
X-Linutronix-Spam-Level: -
X-Linutronix-Spam-Status: No , -1.0 points, 5.0 required,  ALL_TRUSTED=-1,SHORTCIRCUIT=-0.0001
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hoan,

On Tue, 25 Jun 2019, Hoan Tran OS wrote:

Please use 'x86/Kconfig: ' as prefix.

> This patch removes CONFIG_NODES_SPAN_OTHER_NODES as it's
> enabled by default with NUMA.

Please do not use 'This patch' in changelogs. It's pointless because we
already know that this is a patch.

See also Documentation/process/submitting-patches.rst and search for 'This
patch'

Simply say:

  Remove CONFIG_NODES_SPAN_OTHER_NODES as it's enabled by default with
  NUMA.

But .....

> @@ -1567,15 +1567,6 @@ config X86_64_ACPI_NUMA
>  	---help---
>  	  Enable ACPI SRAT based node topology detection.
>  
> -# Some NUMA nodes have memory ranges that span
> -# other nodes.  Even though a pfn is valid and
> -# between a node's start and end pfns, it may not
> -# reside on that node.  See memmap_init_zone()
> -# for details.
> -config NODES_SPAN_OTHER_NODES
> -	def_bool y
> -	depends on X86_64_ACPI_NUMA

the changelog does not mention that this lifts the dependency on
X86_64_ACPI_NUMA and therefore enables that functionality for anything
which has NUMA enabled including 32bit.

The core mm change gives no helpful information either. You just copied the
above comment text from some random Kconfig.

This needs a bit more data in the changelogs and the cover letter:

     - Why is it useful to enable it unconditionally

     - Why is it safe to do so, even if the architecture had constraints on
       it

     - What's the potential impact

Thanks,

	tglx

