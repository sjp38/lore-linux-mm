Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f172.google.com (mail-yk0-f172.google.com [209.85.160.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3DB726B0031
	for <linux-mm@kvack.org>; Thu, 23 Jan 2014 22:43:57 -0500 (EST)
Received: by mail-yk0-f172.google.com with SMTP id 200so4333324ykr.3
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 19:43:56 -0800 (PST)
Received: from bear.ext.ti.com (bear.ext.ti.com. [192.94.94.41])
        by mx.google.com with ESMTPS id q48si17119994yhb.252.2014.01.23.19.43.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 23 Jan 2014 19:43:56 -0800 (PST)
Message-ID: <52E1E174.9040107@ti.com>
Date: Thu, 23 Jan 2014 22:43:48 -0500
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
MIME-Version: 1.0
Subject: Re: Panic on 8-node system in memblock_virt_alloc_try_nid()
References: <52E19C7D.7050603@intel.com>
In-Reply-To: <52E19C7D.7050603@intel.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Strashko, Grygorii" <grygorii.strashko@ti.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

Dave,

On Thursday 23 January 2014 05:49 PM, Dave Hansen wrote:
> Linus's current tree doesn't boot on an 8-node/1TB NUMA system that I
> have.  Its reboots are *LONG*, so I haven't fully bisected it, but it's
> down to a just a few commits, most of which are changes to the memblock
> code.  Since the panic is in the memblock code, it looks like a
> no-brainer.  It's almost certainly the code from Santosh or Grygorii
> that's triggering this.
> 
> Config and good/bad dmesg with memblock=debug are here:
> 
> 	http://sr71.net/~dave/intel/3.13/
> 
> Please let me know if you need it bisected further than this.
> 
Thanks a lot for debug information. Its pretty useful. The oops
seems to be actually side effect of not setting up the numa nodes
correctly first place. At least the setup_node_data() results
indicate that. Actually setup_node_data() operates on the physical
memblock interfaces which are untouched except the alignment change
and thats potentially reason for the change in behavior.

Will you be able revert below commit and give a quick try to see
if the behavior changes ? It might impact other APIs since they
assume the default alignment as SMP_CACHE_BYTES but at least
I want to see if with below revert at least setup_node_data()
reserves correct memory space. 

79f40fa mm/memblock: drop WARN and use SMP_CACHE_BYTES as a default alignment

Regards,
Santosh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
