Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2122CC742B3
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 10:44:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D2F67208E4
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 10:44:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D2F67208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6194D8E0136; Fri, 12 Jul 2019 06:44:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5FA898E00DB; Fri, 12 Jul 2019 06:44:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4DFAE8E0136; Fri, 12 Jul 2019 06:44:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id F1E918E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 06:44:34 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id l16so2732872wmg.2
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 03:44:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=AnAo6demy34KrUIw2rA7B/oKTEkErUZhT/bC3ShDxLg=;
        b=nyz4/NVvWZKTK0ihnwbZGmjFiWh1yRAwHO8OSXir5brKsGdZEYQ5agUiXsfwz1ieYp
         9HlJk/2c8sazJ2sAIMEba2OffmGWMN810VNM/+RHrzVWGY7B72pUwCILgC/Y0H2rm9qh
         dB4vuqkpm/QhZNNMf6nT+EAjqtLj9nPdHihT1nGGg81STJIOaA3SzoScJajDId7+hIMo
         z6KkVz0g5VAiTkasu3UC0VD1OEloL3tH6o9hJu4qZUZowHQzYLjtETHma3OOnrrW0Icx
         2l20FFo9Y5SwubIRmDICo5Uz+lrG9ZQCH791rAwd5Nc37eUzYJx0AqUpc3PZKDEJQMBT
         6lXQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAVApNzXg6mHZuFg4mTaWGRWN/cudBAzOhyL/FvgiR3G1OhBBXPX
	E+TjfWAfq0b4wis3a9FHHupJzsIeTyugLJ9e3jQmLr8gosHUK68wOX3ZPMNFvGEvkSkhnVxbWxw
	Y+Joqf9XaMmhONVA7bGK/+41t3usfVPjtq7ElrKmp4nrqYE/RWSltBoldcfDr9GBqiQ==
X-Received: by 2002:a5d:43d0:: with SMTP id v16mr10718051wrr.252.1562928274450;
        Fri, 12 Jul 2019 03:44:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxmWkSE19Njqm4w1otUEAW1wwV6TvhLovWRlQd9m+fu6dHMlSSXQjbGE0pbg4kK9JU0qx/Y
X-Received: by 2002:a5d:43d0:: with SMTP id v16mr10717908wrr.252.1562928273098;
        Fri, 12 Jul 2019 03:44:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562928273; cv=none;
        d=google.com; s=arc-20160816;
        b=vBmf5S7jWMWPIEWV0w8IkPikbAvParToyKG23fMQz6extFbALqIfmREOXmyJSTbiI8
         4doUAqV4DsFUEDKIkxCnseFWugS3cUvBcPs9iVlYZvJm6zr3B/syTx+jqcTGoYyP136U
         XVFCXfzb6T8HfqMGGZrYGeOC/nl/6HurKRVEOkRnub8Y4GO1ojca2xlw/FBw9rWjQeOv
         4OtKKeNzo3Zmlg/ZqAqwcFptMlEjViGYhYwqPrDdtFjTzZwhuWhodOpf2Xe8tqPIqXIf
         EaBELauTNHRXUuA3jcykmpV9GWmCE48uGmlK56ie+6dL/qJyN9dlLwghs8NkaEFzOalb
         9pBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=AnAo6demy34KrUIw2rA7B/oKTEkErUZhT/bC3ShDxLg=;
        b=siPhfejtAMse4nV7Bjch9jX8h46nBYIYTuVh1gOMW1Xtzfv1kW/3ALUeRzbXkdTUzc
         AOwW2AQAo8gMhekMiLUNIGd5IuiGUf8ou3ovkWwBi1YnkNDBH6THEsiBR/TX72Lr+u96
         i5Vhw5wAx+SA+KBNYecd3sleSSTUjq+KEsn5be/X3ZBla0a/AT17qZeLp1kIe0o7j7SI
         0PwhEd3qc44Wr5U5qIt4J8yQx7JKDyAv34EnVwIXksgIoBx9ySXQ8CstljOagJ0Eb10d
         uk4ucoOrhx7TiJwf63MQB3+YNzkOhBjF37ZDOd8kXVt3gjuBI+Bq5msj0mIro7VXjIoD
         BOew==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a0a:51c0:0:12e:550::1])
        by mx.google.com with ESMTPS id u8si8181659wrq.53.2019.07.12.03.44.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 12 Jul 2019 03:44:33 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) client-ip=2a0a:51c0:0:12e:550::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from [5.158.153.55] (helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hlt2D-0004oK-MD; Fri, 12 Jul 2019 12:44:13 +0200
Date: Fri, 12 Jul 2019 12:44:02 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Dave Hansen <dave.hansen@intel.com>
cc: Alexandre Chartre <alexandre.chartre@oracle.com>, pbonzini@redhat.com, 
    rkrcmar@redhat.com, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, 
    dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org, 
    kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org, konrad.wilk@oracle.com, 
    jan.setjeeilers@oracle.com, liran.alon@oracle.com, jwadams@google.com, 
    graf@amazon.de, rppt@linux.vnet.ibm.com
Subject: Re: [RFC v2 00/27] Kernel Address Space Isolation
In-Reply-To: <5cab2a0e-1034-8748-fcbe-a17cf4fa2cd4@intel.com>
Message-ID: <alpine.DEB.2.21.1907120911160.11639@nanos.tec.linutronix.de>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com> <5cab2a0e-1034-8748-fcbe-a17cf4fa2cd4@intel.com>
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

On Thu, 11 Jul 2019, Dave Hansen wrote:

> On 7/11/19 7:25 AM, Alexandre Chartre wrote:
> > - Kernel code mapped to the ASI page-table has been reduced to:
> >   . the entire kernel (I still need to test with only the kernel text)
> >   . the cpu entry area (because we need the GDT to be mapped)
> >   . the cpu ASI session (for managing ASI)
> >   . the current stack
> > 
> > - Optionally, an ASI can request the following kernel mapping to be added:
> >   . the stack canary
> >   . the cpu offsets (this_cpu_off)
> >   . the current task
> >   . RCU data (rcu_data)
> >   . CPU HW events (cpu_hw_events).
> 
> I don't see the per-cpu areas in here.  But, the ASI macros in
> entry_64.S (and asi_start_abort()) use per-cpu data.
> 
> Also, this stuff seems to do naughty stuff (calling C code, touching
> per-cpu data) before the PTI CR3 writes have been done.  But, I don't
> see anything excluding PTI and this code from coexisting.

That ASI thing is just PTI on steroids.

So why do we need two versions of the same thing? That's absolutely bonkers
and will just introduce subtle bugs and conflicting decisions all over the
place.

The need for ASI is very tightly coupled to the need for PTI and there is
absolutely no point in keeping them separate.

The only difference vs. interrupts and exceptions is that the PTI logic
cares whether they enter from user or from kernel space while ASI only
cares about the kernel entry.

But most exceptions/interrupts transitions do not require to be handled at
the entry code level because on VMEXIT the exit reason clearly tells
whether a switch to the kernel CR3 is necessary or not. So this has to be
handled at the VMM level already in a very clean and simple way.

I'm not a virt wizard, but according to code inspection and instrumentation
even the NMI on the host is actually reinjected manually into the host via
'int $2' after the VMEXIT and for MCE it looks like manual handling as
well. So why do we need to sprinkle that muck all over the entry code?

From a semantical perspective VMENTER/VMEXIT are very similar to the return
to user / enter to user mechanics. Just that the transition happens in the
VMM code and not at the regular user/kernel transition points.

So why do you want ot treat that differently? There is absolutely zero
reason to do so. And there is no reason to create a pointlessly different
version of PTI which introduces yet another variant of a restricted page
table instead of just reusing and extending what's there already.

Thanks,

	tglx

