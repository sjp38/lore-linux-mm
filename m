Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id C30A26B0003
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 17:21:21 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id f35-v6so6045719plb.10
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 14:21:21 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id y27-v6si2283102pfa.181.2018.06.07.14.21.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 14:21:20 -0700 (PDT)
Message-ID: <1528406288.5794.1.camel@2b52.sc.intel.com>
Subject: Re: [PATCH 09/10] mm: Prevent madvise from changing shadow stack
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Thu, 07 Jun 2018 14:18:08 -0700
In-Reply-To: <D1A84B62-E971-4ECD-A873-2072F2692382@gmail.com>
References: <20180607143807.3611-1-yu-cheng.yu@intel.com>
	 <20180607143807.3611-10-yu-cheng.yu@intel.com>
	 <D1A84B62-E971-4ECD-A873-2072F2692382@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-arch@vger.kernel.org, the arch/x86 maintainers <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Mike Kravetz <mike.kravetz@oracle.com>

On Thu, 2018-06-07 at 14:09 -0700, Nadav Amit wrote:
> Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> 
> > Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> > ---
> > mm/madvise.c | 9 +++++++++
> > 1 file changed, 9 insertions(+)
> > 
> > diff --git a/mm/madvise.c b/mm/madvise.c
> > index 4d3c922ea1a1..2a6988badd6b 100644
> > --- a/mm/madvise.c
> > +++ b/mm/madvise.c
> > @@ -839,6 +839,14 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
> > 	if (vma && start > vma->vm_start)
> > 		prev = vma;
> > 
> > +	/*
> > +	 * Don't do anything on shadow stack.
> > +	 */
> > +	if (vma->vm_flags & VM_SHSTK) {
> > +		error = -EINVAL;
> > +		goto out_no_plug;
> > +	}
> > +
> > 	blk_start_plug(&plug);
> > 	for (;;) {
> > 		/* Still start < end. */
> 
> What happens if the madvise() revolves multiple VMAs, the first one is not
> VM_SHSTK, but the another one is? Shouldna??t the test be done inside the
> loop, potentially in madvise_vma() ?
> 

I will fix it.  Thanks!
