Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 37AA46B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 09:17:38 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id g12so5863959qtj.22
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 06:17:38 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id j13si368170qtf.307.2018.04.09.06.17.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Apr 2018 06:17:37 -0700 (PDT)
Date: Mon, 9 Apr 2018 15:17:31 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v2 7/9] trace_uprobe/sdt: Fix multiple update of same
 reference counter
Message-ID: <20180409131730.GA25631@redhat.com>
References: <20180404083110.18647-1-ravi.bangoria@linux.vnet.ibm.com>
 <20180404083110.18647-8-ravi.bangoria@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180404083110.18647-8-ravi.bangoria@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Cc: mhiramat@kernel.org, peterz@infradead.org, srikar@linux.vnet.ibm.com, rostedt@goodmis.org, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, jolsa@redhat.com, kan.liang@intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, tglx@linutronix.de, yao.jin@linux.intel.com, fengguang.wu@intel.com, jglisse@redhat.com

On 04/04, Ravi Bangoria wrote:
>
> +static void sdt_add_mm_list(struct trace_uprobe *tu, struct mm_struct *mm)
> +{
> +	struct mmu_notifier *mn;
> +	struct sdt_mm_list *sml = kzalloc(sizeof(*sml), GFP_KERNEL);
> +
> +	if (!sml)
> +		return;
> +	sml->mm = mm;
> +	list_add(&(sml->list), &(tu->sml.list));
> +
> +	/* Register mmu_notifier for this mm. */
> +	mn = kzalloc(sizeof(*mn), GFP_KERNEL);
> +	if (!mn)
> +		return;
> +
> +	mn->ops = &sdt_mmu_notifier_ops;
> +	__mmu_notifier_register(mn, mm);
> +}

I didn't read this version yet, just one question...

So now it depends on CONFIG_MMU_NOTIFIER, yes? I do not see any changes in Kconfig
files, this doesn't look right...

Oleg.
