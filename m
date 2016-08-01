Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C00426B0005
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 10:42:56 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id p129so83711953wmp.3
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 07:42:56 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e5si16233082wmd.141.2016.08.01.07.42.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 01 Aug 2016 07:42:55 -0700 (PDT)
Subject: Re: [PATCH 08/10] x86, pkeys: default to a restrictive init PKRU
References: <20160729163009.5EC1D38C@viggo.jf.intel.com>
 <20160729163021.F3C25D4A@viggo.jf.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <cd74ae8b-36e4-a397-e36f-fe3d4281d400@suse.cz>
Date: Mon, 1 Aug 2016 16:42:51 +0200
MIME-Version: 1.0
In-Reply-To: <20160729163021.F3C25D4A@viggo.jf.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>, linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, luto@kernel.org, mgorman@techsingularity.net, dave.hansen@linux.intel.com, arnd@arndb.de

On 07/29/2016 06:30 PM, Dave Hansen wrote:
> From: Dave Hansen <dave.hansen@linux.intel.com>
>
> PKRU is the register that lets you disallow writes or all access
> to a given protection key.
>
> The XSAVE hardware defines an "init state" of 0 for PKRU: its
> most permissive state, allowing access/writes to everything.
> Since we start off all new processes with the init state, we
> start all processes off with the most permissive possible PKRU.
>
> This is unfortunate.  If a thread is clone()'d [1] before a
> program has time to set PKRU to a restrictive value, that thread
> will be able to write to all data, no matter what pkey is set on
> it.  This weakens any integrity guarantees that we want pkeys to
> provide.
>
> To fix this, we define a very restrictive PKRU to override the
> XSAVE-provided value when we create a new FPU context.  We choose
> a value that only allows access to pkey 0, which is as
> restrictive as we can practically make it.
>
> This does not cause any practical problems with applications
> using protection keys because we require them to specify initial
> permissions for each key when it is allocated, which override the
> restrictive default.

Here you mean the init_access_rights parameter of pkey_alloc()? So will 
children of fork() after that pkey_alloc() inherit the new value or go 
default?

> In the end, this ensures that threads which do not know how to
> manage their own pkey rights can not do damage to data which is
> pkey-protected.
>
> 1. I would have thought this was a pretty contrived scenario,
>    except that I heard a bug report from an MPX user who was
>    creating threads in some very early code before main().  It
>    may be crazy, but folks evidently _do_ it.
>
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
