Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id 63B726B0254
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 04:08:31 -0500 (EST)
Received: by lbpu9 with SMTP id u9so95315849lbp.2
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 01:08:30 -0800 (PST)
Received: from mail-lf0-x22a.google.com (mail-lf0-x22a.google.com. [2a00:1450:4010:c07::22a])
        by mx.google.com with ESMTPS id r10si16597429lbb.195.2015.12.14.01.08.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 01:08:30 -0800 (PST)
Received: by lfcy184 with SMTP id y184so42064218lfc.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 01:08:29 -0800 (PST)
Date: Mon, 14 Dec 2015 12:08:27 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH RFC] mm: rework virtual memory accounting
Message-ID: <20151214090827.GA14045@uranus>
References: <CALYGNiMTkhb1EeojxvarVOh2q4SGqtKuYU_gv4V+vQ1XocPZ8w@mail.gmail.com>
 <145008075795.15926.4661774822205839673.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <145008075795.15926.4661774822205839673.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On Mon, Dec 14, 2015 at 11:12:38AM +0300, Konstantin Khlebnikov wrote:
> Here several rated changes bundled together:
> * keep vma counting if CONFIG_PROC_FS=n, will be used for limits
> * replace mm->shared_vm with better defined mm->data_vm
> * account anonymous executable areas as executable
> * account file-backed growsdown/up areas as stack
> * drop struct file* argument from vm_stat_account
> * enforce RLIMIT_DATA for size of data areas
> 
> This way code looks cleaner: now code/stack/data
> classification depends only on vm_flags state:
> 
> VM_EXEC & ~VM_WRITE -> code (VmExe + VmLib in proc)
> VM_GROWSUP | VM_GROWSDOWN -> stack (VmStk)
> VM_WRITE & ~VM_SHARED & !stack -> data (VmData)
> 
> The rest (VmSize - VmData - VmStk - VmExe - VmLib) could be called "shared",
> but that might be strange beasts like readonly-private or VM_IO areas.
> 
> RLIMIT_AS limits whole address space "VmSize"
> RLIMIT_STACK limits stack "VmStk" (but each vma individually)
> RLIMIT_DATA now limits "VmData"
> 
> Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>

Looks OK to me. Lets wait for Linus' opinion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
