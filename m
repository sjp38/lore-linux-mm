Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A65BC7618F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 18:44:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4ABB7206B8
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 18:44:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4ABB7206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E4E896B0007; Mon, 15 Jul 2019 14:44:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DFFBC6B0008; Mon, 15 Jul 2019 14:44:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CEFFE6B000A; Mon, 15 Jul 2019 14:44:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 799646B0007
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 14:44:55 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id l24so9288047wrb.0
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 11:44:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=kg+UdLDynnxeY0tp+29I3esvbYQ9bWuc98/H8lsPx3g=;
        b=h5urh8g61CWH9a15tT1v3yoGkYFy66ya6cKoG7iRh6KgEQpNDu0QK9rneYXPS2zki4
         dwqwb1usVldNpwKy33phZdIU1rBDmcA4mpZW/p7XB5IldmfxUFAWPW9Ekk+ixoky7Y2v
         7CYYRVRbJm8G7RWefOnRUfUf6gCPeKZ+Wfuryi6k2rwoQx8V1W94ZF6WrP3YmdD49Dhv
         yWC5lAyf4E3fb0T0uapYtaN1ZM6V3zX+Ah9tf97W0sKyZCy9aQ20nZ9QlTI1ML33xwxy
         ocOZhNsB8slpsja5rY9Vb9Ut7Xc74jQX71MfT1xNIwFG8nQF934IWAv5CH3g0VTnZIux
         7mkw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAV0XSjR04V/VrWSzs/Jrkuws1gcT1eZJ1UhVvvtnedZk8yC3Kw5
	x3EhvnGFvUoGOdqo9gS345V3850Cu9gKIg6DZscODchBnCj/q7Fjf7nUX1EJDMsrqHj0inQK0st
	CmB/ocy7Yk1dM9zPzUC9OcKt5bt3eVqh+RaBjuVdjbpw1xEb+Pe0rmeWcRnEEStd0jg==
X-Received: by 2002:a05:600c:2503:: with SMTP id d3mr26595993wma.41.1563216295037;
        Mon, 15 Jul 2019 11:44:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxIM//jyHW4xFRtP65/HMrtVTV6vsSkDaMfYofZdUgNOpAGxkgd+xUBT5EvEd6mu8v+vorH
X-Received: by 2002:a05:600c:2503:: with SMTP id d3mr26595971wma.41.1563216294281;
        Mon, 15 Jul 2019 11:44:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563216294; cv=none;
        d=google.com; s=arc-20160816;
        b=Bp5rko0JIh02XDNYQpBsgBR/b/nWAbi2UN0UlS5Wdgw0nGJJMToVh1LxE7mkMxOpvX
         lBPmZuCP2xAMvydlCopiisRNdcHVc67IjDkWQWauFNxzUfQy/v2OdKMziYxvwy+1nwqh
         l7GFp6Bv7LqjSzfizLqyqD/NxRt+tpI1oXbQNLLZPAw5ZPsuqJ27hVdxiqcQYbps6WQh
         aix7InkOxad39a+j9puUCsFlZwky7aJz9ZYULWe11Q1TkFIwDFi6TbBGZHezD/widiOK
         lMK6IMXdwXcAOpU4z8qMPJKCnPP4/tMgOiXD5B8XjqIcfmO+NAJb6wPGfJKRKdasBnVM
         jFQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=kg+UdLDynnxeY0tp+29I3esvbYQ9bWuc98/H8lsPx3g=;
        b=RW/zh9kvq3DEzz2KFahe6NdriIpjIaorhvL0gFYxHnJL6wiTimFJIiBz0+VT67qmbS
         Nq/6IijB7vC2cXqyEHs9Pz7zGqmzuByH46KnXzy5QMp71LyQkr2HHE78vVUo9DbLZ+W6
         X8bUBpiWuOV5jV0zhzqol6LS9JjHUHe5efsEWma/4ALmzqvvhVkNrZj/3fdfPiecTzOU
         mh8SudxaBw4zHVdg9lF4oc+YdKtItgHuFNQEsGbRxe7LTBMUEOpwe+vy0bI2o9h740th
         1po1vVRZbXnMeRsyLKrjuZtaqN+lWuqgg8uhA/2+FcXuOTBJBpOHS0st30AWgq4hpVjy
         9BIg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a0a:51c0:0:12e:550::1])
        by mx.google.com with ESMTPS id d9si10807354wro.27.2019.07.15.11.44.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 15 Jul 2019 11:44:54 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) client-ip=2a0a:51c0:0:12e:550::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from pd9ef1cb8.dip0.t-ipconnect.de ([217.239.28.184] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hn5wy-00041l-3l; Mon, 15 Jul 2019 20:43:48 +0200
Date: Mon, 15 Jul 2019 20:43:46 +0200 (CEST)
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
Subject: Re: [PATCH v2 3/5] x86: Kconfig: Remove
 CONFIG_NODES_SPAN_OTHER_NODES
In-Reply-To: <1562887528-5896-4-git-send-email-Hoan@os.amperecomputing.com>
Message-ID: <alpine.DEB.2.21.1907152042110.1767@nanos.tec.linutronix.de>
References: <1562887528-5896-1-git-send-email-Hoan@os.amperecomputing.com> <1562887528-5896-4-git-send-email-Hoan@os.amperecomputing.com>
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

On Thu, 11 Jul 2019, Hoan Tran OS wrote:

> Remove CONFIG_NODES_SPAN_OTHER_NODES as it's enabled
> by default with NUMA.

As I told you before this does not mention that the option is now enabled
even for x86(32bit) configurations which did not enable it before and does
not longer depend on X86_64_ACPI_NUMA.

And there is still no rationale why this makes sense.

Thanks,

	tglx

