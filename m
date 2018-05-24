Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 21DE56B0007
	for <linux-mm@kvack.org>; Thu, 24 May 2018 12:26:15 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id y62-v6so1626725qkb.15
        for <linux-mm@kvack.org>; Thu, 24 May 2018 09:26:15 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id s37-v6si1741477qts.199.2018.05.24.09.26.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 09:26:14 -0700 (PDT)
Date: Thu, 24 May 2018 18:26:08 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v3 6/9] trace_uprobe: Support SDT markers having
 reference count (semaphore)
Message-ID: <20180524162608.GA27082@redhat.com>
References: <20180417043244.7501-1-ravi.bangoria@linux.vnet.ibm.com>
 <20180417043244.7501-7-ravi.bangoria@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180417043244.7501-7-ravi.bangoria@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Cc: mhiramat@kernel.org, peterz@infradead.org, srikar@linux.vnet.ibm.com, rostedt@goodmis.org, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, jolsa@redhat.com, kan.liang@intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, tglx@linutronix.de, yao.jin@linux.intel.com, fengguang.wu@intel.com, jglisse@redhat.com, Ravi Bangoria <ravi.bangoria@linux.ibm.com>

Hi Ravi,

sorry for delay!

I am trying to recall what this code should do ;) At first glance, I do
not see any serious problem in this version... except it doesn't apply
to Linus's tree. just one question for now.

On 04/17, Ravi Bangoria wrote:
>
> @@ -941,6 +1091,9 @@ typedef bool (*filter_func_t)(struct uprobe_consumer *self,
>  	if (ret)
>  		goto err_buffer;
>  
> +	if (tu->ref_ctr_offset)
> +		sdt_increment_ref_ctr(tu);
> +

iiuc, this is probe_event_enable()...

Looks racy, but afaics the race with uprobe_mmap() will be closed by the next
change. However, it seems that probe_event_disable() can race with trace_uprobe_mmap()
too and the next 7/9 patch won't help,

> +	if (tu->ref_ctr_offset)
> +		sdt_decrement_ref_ctr(tu);
> +
>  	uprobe_unregister(tu->inode, tu->offset, &tu->consumer);
>  	tu->tp.flags &= file ? ~TP_FLAG_TRACE : ~TP_FLAG_PROFILE;

so what if trace_uprobe_mmap() comes right after uprobe_unregister() ?
Note that trace_probe_is_enabled() is T until we update tp.flags.

Oleg.
