Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 18D236B0388
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 18:32:49 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 67so132130508pfg.0
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 15:32:49 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 61si11860952plr.217.2017.03.03.15.32.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Mar 2017 15:32:48 -0800 (PST)
Date: Fri, 3 Mar 2017 15:32:47 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 4/4] mm: Adaptive hash table scaling
Message-Id: <20170303153247.f16a31c95404c02a8f3e2c5f@linux-foundation.org>
In-Reply-To: <1488432825-92126-5-git-send-email-pasha.tatashin@oracle.com>
References: <1488432825-92126-1-git-send-email-pasha.tatashin@oracle.com>
	<1488432825-92126-5-git-send-email-pasha.tatashin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-fsdevel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>

On Thu,  2 Mar 2017 00:33:45 -0500 Pavel Tatashin <pasha.tatashin@oracle.com> wrote:

> Allow hash tables to scale with memory but at slower pace, when HASH_ADAPT
> is provided every time memory quadruples the sizes of hash tables will only
> double instead of quadrupling as well. This algorithm starts working only
> when memory size reaches a certain point, currently set to 64G.
> 
> This is example of dentry hash table size, before and after four various
> memory configurations:
> 
> MEMORY	   SCALE	 HASH_SIZE
> 	old	new	old	new
>     8G	 13	 13      8M      8M
>    16G	 13	 13     16M     16M
>    32G	 13	 13     32M     32M
>    64G	 13	 13     64M     64M
>   128G	 13	 14    128M     64M
>   256G	 13	 14    256M    128M
>   512G	 13	 15    512M    128M
>  1024G	 13	 15   1024M    256M
>  2048G	 13	 16   2048M    256M
>  4096G	 13	 16   4096M    512M
>  8192G	 13	 17   8192M    512M
> 16384G	 13	 17  16384M   1024M
> 32768G	 13	 18  32768M   1024M
> 65536G	 13	 18  65536M   2048M

OK, but what are the runtime effects?  Presumably some workloads will
slow down a bit.  How much? How do we know that this is a worthwhile
tradeoff?

If the effect of this change is "undetectable" then those hash tables
are simply too large, and additional tuning is needed, yes?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
