Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id DEEDA6B026B
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 05:52:06 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d7-v6so10235102pfj.6
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 02:52:06 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s9-v6si17268605pgk.371.2018.10.17.02.52.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Oct 2018 02:52:05 -0700 (PDT)
Date: Wed, 17 Oct 2018 02:51:55 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2 1/2] mm: Add an F_SEAL_FS_WRITE seal to memfd
Message-ID: <20181017095155.GA354@infradead.org>
References: <20181009222042.9781-1-joel@joelfernandes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181009222042.9781-1-joel@joelfernandes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Joel Fernandes (Google)" <joel@joelfernandes.org>
Cc: linux-kernel@vger.kernel.org, kernel-team@android.com, jreck@google.com, john.stultz@linaro.org, tkjos@google.com, gregkh@linuxfoundation.org, Andrew Morton <akpm@linux-foundation.org>, dancol@google.com, "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, linux-fsdevel@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-mm@kvack.org, Mike Kravetz <mike.kravetz@oracle.com>, minchan@google.com, Shuah Khan <shuah@kernel.org>

On Tue, Oct 09, 2018 at 03:20:41PM -0700, Joel Fernandes (Google) wrote:
> One of the main usecases Android has is the ability to create a region
> and mmap it as writeable, then drop its protection for "future" writes
> while keeping the existing already mmap'ed writeable-region active.

s/drop/add/ ?

Otherwise this doesn't make much sense to me.

> This usecase cannot be implemented with the existing F_SEAL_WRITE seal.
> To support the usecase, this patch adds a new F_SEAL_FS_WRITE seal which
> prevents any future mmap and write syscalls from succeeding while
> keeping the existing mmap active. The following program shows the seal
> working in action:

Where does the FS come from?  I'd rather expect this to be implemented
as a 'force' style flag that applies the seal even if the otherwise
required precondition is not met.

> Note: This seal will also prevent growing and shrinking of the memfd.
> This is not something we do in Android so it does not affect us, however
> I have mentioned this behavior of the seal in the manpage.

This seems odd, as that is otherwise split into the F_SEAL_SHRINK /
F_SEAL_GROW flags.

>  static int memfd_add_seals(struct file *file, unsigned int seals)
>  {
> @@ -219,6 +220,9 @@ static int memfd_add_seals(struct file *file, unsigned int seals)
>  		}
>  	}
>  
> +	if ((seals & F_SEAL_FS_WRITE) && !(*file_seals & F_SEAL_FS_WRITE))
> +		file->f_mode &= ~(FMODE_WRITE | FMODE_PWRITE);
> +

This seems to lack any synchronization for f_mode.
