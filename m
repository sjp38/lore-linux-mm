Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 672F16B004D
	for <linux-mm@kvack.org>; Sun, 18 Dec 2011 17:44:27 -0500 (EST)
Received: by iacb35 with SMTP id b35so7408837iac.14
        for <linux-mm@kvack.org>; Sun, 18 Dec 2011 14:44:26 -0800 (PST)
Date: Sun, 18 Dec 2011 14:44:24 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH][RESEND] mm: Fix off-by-one bug in print_nodes_state
In-Reply-To: <1324209529-15892-1-git-send-email-ozaki.ryota@gmail.com>
Message-ID: <alpine.DEB.2.00.1112181439500.1364@chino.kir.corp.google.com>
References: <1324209529-15892-1-git-send-email-ozaki.ryota@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ryota Ozaki <ozaki.ryota@gmail.com>
Cc: linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@suse.de>, linux-mm@kvack.org, stable@kernel.org

On Sun, 18 Dec 2011, Ryota Ozaki wrote:

> /sys/devices/system/node/{online,possible} involve a garbage byte
> because print_nodes_state returns content size + 1. To fix the bug,
> the patch changes the use of cpuset_sprintf_cpulist to follow the
> use at other places, which is clearer and safer.
> 

It's not a garbage byte, sysdev files use a buffer created with 
get_zeroed_page(), so extra byte is guaranteed to be zero since 
nodelist_scnprintf() won't write to it.  So the issue here is that 
print_nodes_state() returns a size that is off by one according to 
ISO C99 although it won't cause a problem in practice.

> This bug was introduced since v2.6.24.
> 

It's not a bug, the result of a 4-node system would be "0-3\n\0" and 
returns 5 correctly.  You can verify this very simply with strace.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
