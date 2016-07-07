Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id D2D416B0260
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 10:45:11 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id v6so36924862vkb.2
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 07:45:11 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id r3si2961543wmf.2.2016.07.07.07.45.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Jul 2016 07:45:10 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 6676E99746
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 14:45:10 +0000 (UTC)
Date: Thu, 7 Jul 2016 15:45:08 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 6/9] x86, pkeys: add pkey set/get syscalls
Message-ID: <20160707144508.GZ11498@techsingularity.net>
References: <20160707124719.3F04C882@viggo.jf.intel.com>
 <20160707124728.C1116BB1@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160707124728.C1116BB1@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, dave.hansen@linux.intel.com, arnd@arndb.de, hughd@google.com, viro@zeniv.linux.org.uk

On Thu, Jul 07, 2016 at 05:47:28AM -0700, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> This establishes two more system calls for protection key management:
> 
> 	unsigned long pkey_get(int pkey);
> 	int pkey_set(int pkey, unsigned long access_rights);
> 
> The return value from pkey_get() and the 'access_rights' passed
> to pkey_set() are the same format: a bitmask containing
> PKEY_DENY_WRITE and/or PKEY_DENY_ACCESS, or nothing set at all.
> 
> These can replace userspace's direct use of the new rdpkru/wrpkru
> instructions.
> 
> With current hardware, the kernel can not enforce that it has
> control over a given key.  But, this at least allows the kernel
> to indicate to userspace that userspace does not control a given
> protection key.  This makes it more likely that situations like
> using a pkey after sys_pkey_free() can be detected.
> 
> The kernel does _not_ enforce that this interface must be used for
> changes to PKRU, whether or not a key has been "allocated".
> 
> This syscall interface could also theoretically be replaced with a
> pair of vsyscalls.  The vsyscalls would just call WRPKRU/RDPKRU
> directly in situations where they are drop-in equivalents for
> what the kernel would be doing.
> 

This one feels like something that can or should be implemented in
glibc.

There is no real enforcement of the values yet looking them up or
setting them takes mmap_sem for write. Applications that frequently get
called will get hammed into the ground with serialisation on mmap_sem
not to mention the cost of the syscall entry/exit.

RIght now, I'm seeing a lot of cost and not much benefit with this
specific patch.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
