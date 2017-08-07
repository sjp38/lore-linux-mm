Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A08F66B02B4
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 09:23:01 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id k68so984972wmd.14
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 06:23:01 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i96si8841458wri.346.2017.08.07.06.23.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 07 Aug 2017 06:23:00 -0700 (PDT)
Date: Mon, 7 Aug 2017 15:22:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 0/2] mm,fork,security: introduce MADV_WIPEONFORK
Message-ID: <20170807132257.GH32434@dhcp22.suse.cz>
References: <20170806140425.20937-1-riel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170806140425.20937-1-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com
Cc: linux-kernel@vger.kernel.org, mike.kravetz@oracle.com, linux-mm@kvack.org, fweimer@redhat.com, colm@allcosts.net, akpm@linux-foundation.org, keescook@chromium.org, luto@amacapital.net, wad@chromium.org, mingo@kernel.org, kirill@shutemov.name, dave.hansen@intel.com, linux-api@vger.kernel.org

This is an user visible API so make sure you CC linux-api (added)

On Sun 06-08-17 10:04:23, Rik van Riel wrote:
> v2: fix MAP_SHARED case and kbuild warnings
> 
> Introduce MADV_WIPEONFORK semantics, which result in a VMA being
> empty in the child process after fork. This differs from MADV_DONTFORK
> in one important way.
> 
> If a child process accesses memory that was MADV_WIPEONFORK, it
> will get zeroes. The address ranges are still valid, they are just empty.
> 
> If a child process accesses memory that was MADV_DONTFORK, it will
> get a segmentation fault, since those address ranges are no longer
> valid in the child after fork.
> 
> Since MADV_DONTFORK also seems to be used to allow very large
> programs to fork in systems with strict memory overcommit restrictions,
> changing the semantics of MADV_DONTFORK might break existing programs.
> 
> The use case is libraries that store or cache information, and
> want to know that they need to regenerate it in the child process
> after fork.
> 
> Examples of this would be:
> - systemd/pulseaudio API checks (fail after fork)
>   (replacing a getpid check, which is too slow without a PID cache)
> - PKCS#11 API reinitialization check (mandated by specification)
> - glibc's upcoming PRNG (reseed after fork)
> - OpenSSL PRNG (reseed after fork)
> 
> The security benefits of a forking server having a re-inialized
> PRNG in every child process are pretty obvious. However, due to
> libraries having all kinds of internal state, and programs getting
> compiled with many different versions of each library, it is
> unreasonable to expect calling programs to re-initialize everything
> manually after fork.
> 
> A further complication is the proliferation of clone flags,
> programs bypassing glibc's functions to call clone directly,
> and programs calling unshare, causing the glibc pthread_atfork
> hook to not get called.
> 
> It would be better to have the kernel take care of this automatically.
> 
> This is similar to the OpenBSD minherit syscall with MAP_INHERIT_ZERO:
> 
>     https://man.openbsd.org/minherit.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
