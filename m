Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1BD356B02B4
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 18:51:19 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id w63so2901738wrc.5
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 15:51:19 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f65si1939207wmf.130.2017.08.15.15.51.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Aug 2017 15:51:17 -0700 (PDT)
Date: Tue, 15 Aug 2017 15:51:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm,fork: introduce MADV_WIPEONFORK
Message-Id: <20170815155114.ff9f4164eed28bf02db48fbb@linux-foundation.org>
In-Reply-To: <20170811212829.29186-3-riel@redhat.com>
References: <20170811212829.29186-1-riel@redhat.com>
	<20170811212829.29186-3-riel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com
Cc: linux-kernel@vger.kernel.org, mhocko@kernel.org, mike.kravetz@oracle.com, linux-mm@kvack.org, fweimer@redhat.com, colm@allcosts.net, keescook@chromium.org, luto@amacapital.net, wad@chromium.org, mingo@kernel.org, kirill@shutemov.name, dave.hansen@intel.com, linux-api@vger.kernel.org, torvalds@linux-foundation.org, willy@infradead.org

On Fri, 11 Aug 2017 17:28:29 -0400 riel@redhat.com wrote:

> From: Rik van Riel <riel@redhat.com>
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
> MADV_WIPEONFORK only works on private, anonymous VMAs.
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

I'll add "The patch also adds MADV_KEEPONFORK, to undo the effects of a
prior MADV_WIPEONFORK." here.

I guess it isn't worth mentioning that these things can cause VMA
merges and splits. 

> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -80,6 +80,17 @@ static long madvise_behavior(struct vm_area_struct *vma,
>  		}
>  		new_flags &= ~VM_DONTCOPY;
>  		break;
> +	case MADV_WIPEONFORK:
> +		/* MADV_WIPEONFORK is only supported on anonymous memory. */
> +		if (vma->vm_file || vma->vm_flags & VM_SHARED) {
> +			error = -EINVAL;
> +			goto out;
> +		}
> +		new_flags |= VM_WIPEONFORK;
> +		break;
> +	case MADV_KEEPONFORK:
> +		new_flags &= ~VM_WIPEONFORK;
> +		break;
>  	case MADV_DONTDUMP:
>  		new_flags |= VM_DONTDUMP;
>  		break;

It seems odd to permit MADV_KEEPONFORK against other-than-anon vmas?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
