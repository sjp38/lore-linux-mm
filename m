Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 37EFE6B0130
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 13:27:50 -0500 (EST)
Received: by mail-wg0-f48.google.com with SMTP id y19so1449063wgg.21
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 10:27:49 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id gc8si6170139wjb.72.2014.11.11.10.27.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 11 Nov 2014 10:27:49 -0800 (PST)
Date: Tue, 11 Nov 2014 19:27:37 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v9 11/12] x86, mpx: cleanup unused bound tables
In-Reply-To: <545BED0B.8000001@intel.com>
Message-ID: <alpine.DEB.2.11.1411111213450.3935@nanos>
References: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com> <1413088915-13428-12-git-send-email-qiaowei.ren@intel.com> <alpine.DEB.2.11.1410241451280.5308@nanos> <545BED0B.8000001@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Qiaowei Ren <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org

On Thu, 6 Nov 2014, Dave Hansen wrote:
> Instead of all of these games with dropping and reacquiring mmap_sem and
> adding other locks, or deferring the work, why don't we just do a
> get_user_pages()?  Something along the lines of:
> 
> while (1) {
> 	ret = cmpxchg(addr)
> 	if (!ret)
> 		break;
> 	if (ret == -EFAULT)
> 		get_user_pages(addr);
> }
> 
> Does anybody see a problem with that?

You want to do that under mmap_sem write held, right? Not a problem per
se, except that you block normal faults for a possibly long time when
the page(s) need to be swapped in.

But yes, this might solve most of the issues at hand. Did not think
about GUP at all :(

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
