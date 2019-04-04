Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D9C0C10F06
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 00:13:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 130BB2082E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 00:13:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="NwsoRh6B"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 130BB2082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E3EE6B000C; Wed,  3 Apr 2019 20:13:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 894966B0269; Wed,  3 Apr 2019 20:13:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 710B86B026A; Wed,  3 Apr 2019 20:13:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2B2176B000C
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 20:13:18 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 1so581888ply.14
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 17:13:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Qw5QbQLa/AXv2Uff076pbBbf4T/Jt3ieizFbIrDjQ4c=;
        b=Ftvf14wrvbzqATZqlpVuNyNnfe92JN65SqyMZ9qjn2xCmH4PlfwwgYU/L9jwLgXQiA
         HPn7sdsEQ6QupJpBD4WfZIstNEXEf9QpeqKCwFzcYnxMmXwhXWCsbNu8c3L4qVrw02AF
         eflwbbu1rezk5JnIp5L7oGlruhYLTQPlre7Gl7rYwUs7aoG/sNaPG3AeeIBHhUGI+5El
         g+vDXCcqrCNW4nReToCevawgXsAC+Lz5p/E/RIMWi41JMmOK2+4MdhBOzU0LRoJTm92c
         ZqqWE7T3GvDu/Mi4wnet4FhJo5UrWJfNnxiqJqeZAq+611gPRfavqHRRf//aUuIXSsap
         SQJg==
X-Gm-Message-State: APjAAAV0OyvXq68eCf2uB8bUGnBuQuFsxCVmQ9uqnc9Qp4xoHkLPlfBf
	YetgeQBaNztBHK8ycfp6sRlyx2tVFDTS5Wr9jkQytKW6cFG7UHZfZ9tMfKhDG4AsUWosAywLMgJ
	yFKwab+1kvISRcs1ywtTP0ZGItlbii1Kvz1eWuD2hkrAtS+ud/ngWIdHlscCUGti+Vg==
X-Received: by 2002:a63:20f:: with SMTP id 15mr2633163pgc.90.1554336797643;
        Wed, 03 Apr 2019 17:13:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzA8kATCdNZpekSeZ4PjgAc5Vxf0sCvEjRFQ6wSWsnSbfq3zuECi32RI6VrEwHPBQsf51he
X-Received: by 2002:a63:20f:: with SMTP id 15mr2633108pgc.90.1554336796844;
        Wed, 03 Apr 2019 17:13:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554336796; cv=none;
        d=google.com; s=arc-20160816;
        b=eamNemeHxOtJw59tufvKZq5yMjWMQsIfxkyca/Bd68sCVk7zc31oJq6N6sifASlDo+
         2B6NAN95nMNycL6mkTgx9ebv12YReid6FhqUYoH/wAyao9IzsPgR6jdYU803vY0iZEiW
         tEhXt0AeupUAr4g80L3LAvxbbK/lGXO8ya42r7yxeyAQlXcBxMKBsOya+QYbkx9nLK1/
         h9wPt3BncWQWWt26l2zgPKSKyamEkzCQGBMWYr7zJwlZeBzUWm5k6n8NQxclapOVC+xH
         Z5kCxJsq2SXGvAX8/iVQ8KYrKV4y3fOUuYzHdP6RgHf//4E1sbnpZoQq1mwy97N8Cb0y
         fa+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Qw5QbQLa/AXv2Uff076pbBbf4T/Jt3ieizFbIrDjQ4c=;
        b=IbV6guUo8tmSw6shV3NNBen8H1dFK8Du7ZOX/dxJNLo7TEH4YsbEzJ5gIKtfu25Y3r
         l+tGTGX6FgwZJqoJeszhoWxfp+8wYCjW9OcJMqx/jUDlDk1Dbe3hBsW/BPh0MnwpZJbg
         VK96QRmNWF79urruuVpCUTrtbcIlEit3+WgqYGU0IgjfqpmJvHWPAoL8hbcgIvvT1Nw1
         suYaOsg30qRP4/lt2E43jTC4Y10+hYoxboATlrJlxSLGPS29L7BkOxIN3y76MuPXdEit
         sS+4F/OKZjMZX7mEE/eBe3dxhT3rpro0ExLvASNbTD6s8q8PmVZjAsiN2Z7P2NpJTbj4
         arpA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=NwsoRh6B;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e5si14942279pgk.150.2019.04.03.17.13.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 17:13:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=NwsoRh6B;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wm1-f41.google.com (mail-wm1-f41.google.com [209.85.128.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 195AF21920
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 00:13:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1554336796;
	bh=GGJRHe3KYjcQNLG8aTrg3U7oNNkXkzmOgdq/8cfXfjw=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=NwsoRh6BPwrwAzfdiQ9XHSWmrJWT625FhIjKOop41FfRt21WUy1yDf/PYmmoiltJk
	 6ylzQm7C87ZY91BMa7+qWjjJPp6tbFj+t5d5Ou/IrW/Jf4/0ufCgYfsGNkVyZUKM1Q
	 hmVEB+Hte3ih2OqzssBNx2VAqmc+eHgvOvmmnwsM=
Received: by mail-wm1-f41.google.com with SMTP id z11so838981wmi.0
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 17:13:16 -0700 (PDT)
X-Received: by 2002:a1c:99d5:: with SMTP id b204mr1752292wme.95.1554336787336;
 Wed, 03 Apr 2019 17:13:07 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1554248001.git.khalid.aziz@oracle.com> <e6c57f675e5b53d4de266412aa526b7660c47918.1554248002.git.khalid.aziz@oracle.com>
In-Reply-To: <e6c57f675e5b53d4de266412aa526b7660c47918.1554248002.git.khalid.aziz@oracle.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 3 Apr 2019 17:12:56 -0700
X-Gmail-Original-Message-ID: <CALCETrXvwuwkVSJ+S5s7wTBkNNj3fRVxpx9BvsXWrT=3ZdRnCw@mail.gmail.com>
Message-ID: <CALCETrXvwuwkVSJ+S5s7wTBkNNj3fRVxpx9BvsXWrT=3ZdRnCw@mail.gmail.com>
Subject: Re: [RFC PATCH v9 02/13] x86: always set IF before oopsing from page fault
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Juerg Haefliger <juergh@gmail.com>, Tycho Andersen <tycho@tycho.ws>, jsteckli@amazon.de, 
	Andi Kleen <ak@linux.intel.com>, liran.alon@oracle.com, Kees Cook <keescook@google.com>, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, deepa.srinivasan@oracle.com, 
	chris hyser <chris.hyser@oracle.com>, Tyler Hicks <tyhicks@canonical.com>, 
	"Woodhouse, David" <dwmw@amazon.co.uk>, Andrew Cooper <andrew.cooper3@citrix.com>, 
	Jon Masters <jcm@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, kanth.ghatraju@oracle.com, 
	Joao Martins <joao.m.martins@oracle.com>, Jim Mattson <jmattson@google.com>, 
	pradeep.vincent@oracle.com, John Haxby <john.haxby@oracle.com>, 
	Thomas Gleixner <tglx@linutronix.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, 
	Christoph Hellwig <hch@lst.de>, steven.sistare@oracle.com, Laura Abbott <labbott@redhat.com>, 
	Andrew Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, 
	Peter Zijlstra <peterz@infradead.org>, Aaron Lu <aaron.lu@intel.com>, 
	Andrew Morton <akpm@linux-foundation.org>, alexander.h.duyck@linux.intel.com, 
	Amir Goldstein <amir73il@gmail.com>, Andrey Konovalov <andreyknvl@google.com>, aneesh.kumar@linux.ibm.com, 
	anthony.yznaga@oracle.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>, 
	Arnd Bergmann <arnd@arndb.de>, arunks@codeaurora.org, Ben Hutchings <ben@decadent.org.uk>, 
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Borislav Petkov <bp@alien8.de>, brgl@bgdev.pl, 
	Catalin Marinas <catalin.marinas@arm.com>, Jonathan Corbet <corbet@lwn.net>, cpandya@codeaurora.org, 
	Daniel Vetter <daniel.vetter@ffwll.ch>, Dan Williams <dan.j.williams@intel.com>, 
	Greg KH <gregkh@linuxfoundation.org>, Roman Gushchin <guro@fb.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, "H. Peter Anvin" <hpa@zytor.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	James Morse <james.morse@arm.com>, Jann Horn <jannh@google.com>, Juergen Gross <jgross@suse.com>, 
	Jiri Kosina <jkosina@suse.cz>, James Morris <jmorris@namei.org>, Joe Perches <joe@perches.com>, 
	Souptick Joarder <jrdr.linux@gmail.com>, Joerg Roedel <jroedel@suse.de>, 
	Keith Busch <keith.busch@intel.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, 
	Logan Gunthorpe <logang@deltatee.com>, marco.antonio.780@gmail.com, 
	Mark Rutland <mark.rutland@arm.com>, Mel Gorman <mgorman@techsingularity.net>, 
	Michal Hocko <mhocko@suse.com>, Michal Hocko <mhocko@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>, 
	Ingo Molnar <mingo@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, 
	Marek Szyprowski <m.szyprowski@samsung.com>, Nicholas Piggin <npiggin@gmail.com>, osalvador@suse.de, 
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, pavel.tatashin@microsoft.com, 
	Randy Dunlap <rdunlap@infradead.org>, richard.weiyang@gmail.com, 
	Rik van Riel <riel@surriel.com>, David Rientjes <rientjes@google.com>, 
	Robin Murphy <robin.murphy@arm.com>, Steven Rostedt <rostedt@goodmis.org>, 
	Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	Sai Praneeth Prakhya <sai.praneeth.prakhya@intel.com>, "Serge E. Hallyn" <serge@hallyn.com>, 
	Steve Capper <steve.capper@arm.com>, thymovanbeers@gmail.com, 
	Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will.deacon@arm.com>, 
	Matthew Wilcox <willy@infradead.org>, yang.shi@linux.alibaba.com, yaojun8558363@gmail.com, 
	Huang Ying <ying.huang@intel.com>, zhangshaokun@hisilicon.com, 
	iommu@lists.linux-foundation.org, X86 ML <x86@kernel.org>, 
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, 
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	Linux-MM <linux-mm@kvack.org>, LSM List <linux-security-module@vger.kernel.org>, 
	Khalid Aziz <khalid@gonehiking.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 3, 2019 at 10:36 AM Khalid Aziz <khalid.aziz@oracle.com> wrote:
>
> From: Tycho Andersen <tycho@tycho.ws>
>
> Oopsing might kill the task, via rewind_stack_do_exit() at the bottom, and
> that might sleep:
>


> diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> index 9d5c75f02295..7891add0913f 100644
> --- a/arch/x86/mm/fault.c
> +++ b/arch/x86/mm/fault.c
> @@ -858,6 +858,12 @@ no_context(struct pt_regs *regs, unsigned long error_code,
>         /* Executive summary in case the body of the oops scrolled away */
>         printk(KERN_DEFAULT "CR2: %016lx\n", address);
>
> +       /*
> +        * We're about to oops, which might kill the task. Make sure we're
> +        * allowed to sleep.
> +        */
> +       flags |= X86_EFLAGS_IF;
> +
>         oops_end(flags, regs, sig);
>  }
>


NAK.  If there's a bug in rewind_stack_do_exit(), please fix it in
rewind_stack_do_exit().

