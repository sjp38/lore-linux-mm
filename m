Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 744D86B0005
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 12:43:45 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id d10-v6so3568081pll.22
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 09:43:45 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o84-v6si5601301pfa.15.2018.08.03.09.43.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 03 Aug 2018 09:43:44 -0700 (PDT)
Date: Fri, 3 Aug 2018 09:43:37 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v4 0/7] arm64: untag user pointers passed to the kernel
Message-ID: <20180803164337.GB4718@bombadil.infradead.org>
References: <cover.1529507994.git.andreyknvl@google.com>
 <CAAeHK+zqtyGzd_CZ7qKZKU-uZjZ1Pkmod5h8zzbN0xCV26nSfg@mail.gmail.com>
 <20180626172900.ufclp2pfrhwkxjco@armageddon.cambridge.arm.com>
 <CAAeHK+yqWKTdTG+ymZ2-5XKiDANV+fmUjnQkRy-5tpgphuLJRA@mail.gmail.com>
 <CAAeHK+wJbbCZd+-X=9oeJgsqQJiq8h+Aagz3SQMPaAzCD+pvFw@mail.gmail.com>
 <CAAeHK+yWF05XoU+0iuJoXAL3cWgdtxbeLoBz169yP12W4LkcQw@mail.gmail.com>
 <20180801174256.5mbyf33eszml4nmu@armageddon.cambridge.arm.com>
 <CAAeHK+zb7vcehuX9=oxLUJVJr1ZcgmRTODQz7wsPy+rJb=3kbQ@mail.gmail.com>
 <CAAeHK+xTxPhfbVTNxcbsx7VdwQ21Bt-vo2ZU1tEM1_JX7uKnng@mail.gmail.com>
 <20180803150945.GC9297@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180803150945.GC9297@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Andrey Konovalov <andreyknvl@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Mark Rutland <mark.rutland@arm.com>, Kate Stewart <kstewart@linuxfoundation.org>, linux-doc@vger.kernel.org, Will Deacon <will.deacon@arm.com>, Kostya Serebryany <kcc@google.com>, linux-kselftest@vger.kernel.org, Chintan Pandya <cpandya@codeaurora.org>, Shuah Khan <shuah@kernel.org>, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, Jacob Bramley <Jacob.Bramley@arm.com>, Dmitry Vyukov <dvyukov@google.com>, Evgeniy Stepanov <eugenis@google.com>, Kees Cook <keescook@chromium.org>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Al Viro <viro@zeniv.linux.org.uk>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Lee Smith <Lee.Smith@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Robin Murphy <robin.murphy@arm.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Fri, Aug 03, 2018 at 05:09:45PM +0200, Greg Kroah-Hartman wrote:
> On Fri, Aug 03, 2018 at 04:59:18PM +0200, Andrey Konovalov wrote:
> > Started looking at this. When I run sparse with default checks enabled
> > (make C=1) I get countless warnings. Does anybody actually use it?
> 
> Try using a more up-to-date version of sparse.  Odds are you are using
> an old one, there is a newer version in a different branch on kernel.org
> somewhere...

That's not true.  Building the current version of sparse from
git://git.kernel.org/pub/scm/devel/sparse/sparse.git leaves me with a
thousand errors just building the mm/ directory.  A sample:

../mm/filemap.c:2353:21: warning: expression using sizeof(void)
../mm/filemap.c:2618:35: warning: symbol 'generic_file_vm_ops' was not declared. Should it be static?
../include/linux/slab.h:666:13: error: undefined identifier '__builtin_mul_overflow'
../include/linux/slab.h:666:13: warning: call with no type!
../include/linux/rcupdate.h:683:9: warning: context imbalance in 'find_lock_task_mm' - wrong count at exit
../include/linux/sched/mm.h:141:37: warning: dereference of noderef expression
../mm/page_alloc.c:886:1: error: directive in argument list
../include/trace/events/vmscan.h:79:1: warning: cast from restricted gfp_t
../include/trace/events/vmscan.h:196:1: warning: too many warnings (ahem!)
../mm/mmap.c:137:9: warning: cast to non-scalar
../mm/mmap.c:137:9: warning: cast from non-scalar
../mm/page_vma_mapped.c:134:29: warning: Using plain integer as NULL pointer
../include/linux/slab.h:631:13: warning: call with no type!

Basically, nobody is fixing their shit.  The only way that sparse output
is useful is to log the warnings before your changes, log them afterwards
and run diff.  The worst offender (as in: fixing it would remove most of
the warnings) is the new min()/max() macro:

        ra->start = max_t(long, 0, offset - ra->ra_pages / 2);

produces that first warning at line 2353 of filemap.c.  I have no idea if
this is a sparse mistake or something it's genuinely warning us about,
but the sparse warnings are pretty ineffectual because nobody's paying
attention to them.
